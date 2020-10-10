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
    ARCHIVE_NAME="$3"
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
if [ ! -e "$ARCHIVE_NAME" ]; then
    echo 'Error. No archive name specified or the file doesn'\''t exist.'
    ERR=1
fi

if [ $ERR = 1 ]; then
     exit 1
fi;


echo '----------------------------------------'
echo 'Begin Mongo restoration.'

# Create directory if it doesn't exist.
mkdir -p /media/backup/$BACKUP_FOLDER &&
# Backup the databases specified
BACKUP_FILE=/media/backup/$BACKUP_FOLDER/${ARCHIVE_NAME}_$(date +%Y-%m-%d_%H-%M-%S).bson.bz2 &&
bzip2 -cd $ARCHIVE_NAME | mongorestore $DROP --host=$MONGO_HOST --db=$DB_NAME --archive &
# The restore function is started in background and we wait for its completion. This allow the script to treat a signal
# immediatly instead of waiting for the end of the command.
wait $!

ERR_CODE="$?"
if [ $ERR_CODE -eq 0 ]; then
    if [ -n "$DELETE_ARCHIVE" ]; then
        echo "Delete file $ARCHIVE_NAME"
        rm -f "$ARCHIVE_NAME"
    fi
    echo 'Mongo restoration completed.'
else
    echo "Mongo restoration failed with error code $ERR_CODE"
fi
echo -e '----------------------------------------\n'
exit $ERR_CODE
