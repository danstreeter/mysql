FROM mysql:8.0

RUN apt-get update && apt-get install -y curl

ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_FILE_PATH **None**

COPY flowmoco-init.sh /docker-entrypoint-initdb.d/

