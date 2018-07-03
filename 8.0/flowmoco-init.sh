#!/bin/bash

function shouldS3 {
  if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then 
    echo "S3_ACCESS_KEY_ID variable not set.  Not downloading backup from S3."  
    return 1
  fi
  if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then 
    echo "S3_SECRET_ACCESS_KEY variable not set.  Not downloading backup from S3."  
    return 1
  fi
  if [ "${S3_BUCKET}" == "**None**" ]; then 
    echo "S3_BUCKET variable not set.  Not downloading backup from S3."  
    return 1
  fi
  if [ "${S3_FILE_PATH}" == "**None**" ]; then 
    echo "S3_FILE_PATH variable not set.  Not downloading backup from S3."  
    return 1
  fi
  return 0
}

function downloadBackupFromS3 {
  file="${S3_FILE_PATH}"
  bucket="${S3_BUCKET}"
  resource="/${bucket}/${file}" 
  contentType="application/gzip" 
  dateValue="`date +'%a, %d %b %Y %H:%M:%S %z'`" 
  stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}" 
  s3Key="${S3_ACCESS_KEY_ID}"
  s3Secret="${S3_SECRET_ACCESS_KEY}"
  signature=`/bin/echo -en "$stringToSign" | openssl sha1 -hmac ${s3Secret} -binary | base64`
  echo `/bin/echo -en "$stringToSign" | openssl sha1 -hmac ${s3Secret}`
  curl -H "Host: ${bucket}.s3.amazonaws.com" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${s3Key}:${signature}" \
  https://${bucket}.s3.amazonaws.com/${file} | gunzip | "${mysql[@]}"
}

shouldS3 || (echo "Not downloading from S3" & exit 0)

echo "Downloading from S3"
downloadBackupFromS3



