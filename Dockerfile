FROM alpine
ENV DB_NAME=
ENV MONGO_HOST=
ENV BACKUP_FOLDER=
ENV ARCHIVE_NAME=

RUN apk add mongodb-tools

COPY mongoRestore.sh /
RUN chmod 700 mongoRestore.sh

WORKDIR /

# The double quotes around $@ ensure that a parameter containing is transfered as a single parameter to mongoRestore.sh
ENTRYPOINT ["/bin/ash", "-c", "$0 \"$@\"", "./mongoRestore.sh"]
