# Docker image to backup mongo databases
This image creates bz2 archive from a mongo database dump. The archive is created in location /media/backup/$BACKUP_FOLDER with the name ${ARCHIVE\_NAME}\_$(date +%Y-%m-%d\_%H-%M-%S).bson.bz2 (e.g. myArchive\_2020-08-15\_17-32-45.bson.bz2). The location /media/backup must exists in order to make the backup. It means you must mount a volume at that location.

The information to specify to make the backup can be either with environment variables or with command line arguments. The syntax of the command line argument is [--drop] DB_NAME MONGO_HOST ARCHIVE_NAME. Here is an explanation of the parameters.
| Variable        | Parameter        | Description                                                                   |
| --------------- | ---------------- | ----------------------------------------------------------------------------- |
| $DROP           | --drop           | If specified, mongorestore will drop the collections in the database that are restored before restoring them. |
| $DELETE_ARCHIVE | --delete-archive | If specified, delete the archive file after succesfully restoring it.         |
| $DB_NAME        | DB_NAME          | The name of the database to restore into. Only one database name can be specified. |
| $MONGO_HOST     | MONGO_HOST       | The host address to communicate with.                                         |
| $BACKUP_FOLDER  | BACKUP_FOLDER    | The name of the service inside /media/backup.                                 |
| $ARCHIVE_NAME   | ARCHIVE_NAME     | The path and name of the bz2 archive containing the data to restore.          |
| $DATE_DIR_FILE  | DATE_DIR_FILE    | The name of the file containing the directory to look inside for ARCHIVE_NAME |

## Examples of execution
You can run the backup by specifying the parameters with environment variables.
> docker run --env DB_NAME=my\_database --env MONGO\_HOST=my\_mongo\_host --env BACKUP\_FOLDER=my\_service --env ARCHIVE\_NAME=my\_database.bson.bz2 --network mongodb --mount type=volume,src=_my\_backup_,dst=/media/backup restore\_mongo

You can also run the backup by specifying the parameters with command line parameters.
> docker run --network mongodb --mount src=_my\_backup_,dst=/media/backup backup\_mongo my\_database my\_mongo\_host my\_service my\_database.bson.bz2
