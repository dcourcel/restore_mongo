# Docker image to restore mongo databases
This image restores a mongo database dump compressed as a bz2 archive. The archive is restored from the location /media/backup/$BACKUP\_FOLDER/${ARCHIVE\_NAME}.bson.bz2. This image is intended to run as a Docker job. If the restoration file does not exist, the process just exit succesfully, otherwise it proceeds with the restoration.

The information to specify to make the backup can be either with environment variables or with command line arguments. The syntax of the command line argument is [--drop] DB_NAME MONGO_HOST ARCHIVE_NAME. Here is an explanation of the parameters.
| Variable        | Parameter        | Description                                                                  |
| --------------- | ---------------- | ---------------------------------------------------------------------------- |
| $DROP           | --drop           | If specified, mongorestore will drop the collections in the database that are restored before restoring them. |
| $DELETE_ARCHIVE | --delete-archive | If specified, delete the archive file after succesfully restoring it.        |
| $DB_NAME        | DB_NAME          | The name of the database to restore into. Only one database name can be specified. |
| $MONGO_HOST     | MONGO_HOST       | The host address to communicate with.                                        |
| $ARCHIVE_NAME   | ARCHIVE_NAME     | The path and name of the bz2 archive containing the data to restore.         |

## Examples of execution
You can run the backup by specifying the parameters with environment variables.
> docker run --env DB_NAME=my_database --env MONGO_HOST=my_mongo_host --env ARCHIVE_NAME=/media/backup/my_database.bson.bz2 --network mongodb --mount src=_my\_backup_,dst=/media/backup backup_mongo

You can also run the backup by specifying the parameters with command line parameters.
> docker run --network mongodb --mount src=_my\_backup_,dst=/media/backup backup_mongo my_database my_mongo_host /media/backup/my_database.bson.bz2
