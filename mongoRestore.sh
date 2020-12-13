#!/bin/ash

set -o pipefail

function cleanup()
{
    # Kill the background task if it exists before removing the backup file
    kill %1 2> /dev/null
    echo "Mongo restoration interrupted. Collections could be in unstable state."
    exit 3
}

trap 'cleanup' SIGINT
trap 'cleanup' SIGTERM

# Read parameters from command line if there is at least one parameter.
# Otherwise, the environment variables are assumed to be already defined.
if [ -n "$1" ]; then
    DROP=""
    DELETE_ARCHIVE=""
    while [ $# -gt 0 -a "${1::2}" = "--" ]; do
        case $1 in
            --drop)
            DROP=--drop
            ;;

            --delete-archive)
            DELETE_ARCHIVE=yes
            ;;

            *)
            echo "Invalid option $1"
            exit 2
            ;;
        esac
        shift
    done

    DB_NAME="$1"
    MONGO_HOST="$2"
    BACKUP_FOLDER="$3"
    ARCHIVE_NAME="$4"
    DATE_DIR_FILE="$5"
else
    if [ -n "$DROP" ]; then
        DROP=--drop
    fi
fi

# Verify if arguments exist
ERR=0
if [ -z "$DB_NAME" ]; then
    echo 'Error. No Database name specified.'
    ERR=1
fi
if [ -z "$MONGO_HOST" ]; then
    echo 'Error. No host specified.'
    ERR=1
fi
if [ -z "$BACKUP_FOLDER" ]; then
    echo '$BACKUP_FOLDER' is not defined
    ERR=1
fi;
if [ -n "$DATE_DIR_FILE" ]; then
    if [ ! -f "$DATE_DIR_FILE" ]; then
        echo "\$DATE_DIR_FILE ($DATE_DIR_FILE) is not a file."
        ERR=1
    fi
    date_dir=$(head -n 1 $DATE_DIR_FILE)
    if [ -z "$date_dir" ]; then
        echo "The file $DATE_DIR_FILE is empty."
        ERR=1
    fi
else
    echo "\$DATE_DIR_FILE is not defined."
    ERR=1
fi;
BACKUP_FILE=/media/backup/$BACKUP_FOLDER/$date_dir/$ARCHIVE_NAME
if [ $ERR -eq 0 ]; then
    if [ -z "$ARCHIVE_NAME" ]; then
        echo "\$ARCHIVE_NAME is empty."
        ERR=1
    elif [ ! -f "$BACKUP_FILE" ]; then
        echo "The file $BACKUP_FILE doesn't exist."
        ERR=1
    fi
fi

if [ $ERR = 1 ]; then
     exit 1
fi;


echo '----------------------------------------'
echo 'Begin Mongo restoration.'

# Restore the databases specified
bzip2 -cd $BACKUP_FILE | mongorestore $DROP --host=$MONGO_HOST --db=$DB_NAME --archive &
# The restore function is started in background and we wait for its completion. This allow the script to treat a signal
# immediatly instead of waiting for the end of the command.
wait $!

ERR_CODE="$?"
if [ $ERR_CODE -eq 0 ]; then
    if [ -n "$DELETE_ARCHIVE" ]; then
        echo "Delete file $BACKUP_FILE"
        rm -f "$BACKUP_FILE"
    fi
    echo 'Mongo restoration completed.'
else
    echo "Mongo restoration failed with error code $ERR_CODE"
fi
echo -e '----------------------------------------\n'
exit $ERR_CODE
