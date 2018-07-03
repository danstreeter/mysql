#!/bin/bash

SHOULD_GET_S3_BACKUP="true"

if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then
  SHOULD_GET_S3_BACKUP="false"
  echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable. Not backing up..."
  return
fi

if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then
  echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
fi

if [ "${S3_BUCKET}" == "**None**" ]; then
  echo "You need to set the S3_BUCKET environment variable."
  exit 1
fi

function shouldS3 {
  if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then 
    echo "S3_ACCESS_KEY_ID variable not set.  Not downloading backup from S3."  
    return "false"
  fi
  if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then 
    echo "S3_SECRET_ACCESS_KEY variable not set.  Not downloading backup from S3."  
    return "false"
  fi
  if [ "${S3_BUCKET}" == "**None**" ]; then 
    echo "S3_BUCKET variable not set.  Not downloading backup from S3."  
    return "false"
  fi
  if [ "${S3_FILE_PATH}" == "**None**" ]; then 
    echo "S3_FILE_PATH variable not set.  Not downloading backup from S3."  
    return "false"
  fi
  return "true"
}

downloadBackupFromS3 {
  file="${S3_FILE_PATH}"
  bucket="${S3_BUCKET}"
  resource="/${bucket}/${file}" 
  contentType="application/x-compressed-tar" 
  dateValue="`date +'%a, %d %b %Y %H:%M:%S %z'`" 
  stringToSign="GET 
  ${contentType} 
  ${dateValue} 
  ${resource}" 
  s3Key="${S3_ACCESS_KEY_ID}"
  s3Secret="${S3_SECRET_ACCESS_KEY}"
  signature=`/bin/echo -en "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64`
  curl -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \ 
  -H "Authorization: AWS ${s3Key}:${signature}" \ 
  https://${bucket}.s3.amazonaws.com/${file} 
}

if [ shouldS3 == "true" ]; then
  downloadBackupFromS3  
fi

