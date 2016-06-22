#!/usr/bin/env bash

if [ "$LICENSE_KEY" = "" ]; then
  (>&2 echo "The LICENSE_KEY environment variable must be set (the license key provided by OpenALPR)")
  exit 1
fi

if [ "$SITE_ID" = "" ]; then
  (>&2 echo "The SITE_ID environment variable must be set (the unique site id provided by OpenALPR)")
  exit 1
fi

if [ "$COMPANY_ID" = "" ]; then
  (>&2 echo "The COMPANY_ID environment variable must be set (the company id as provided by OpenALPR)")
  exit 1
fi

if [ "$CAMERA_URLS" = "" ]; then
  (>&2 echo "The CAMERA_URLS environment variable must be set (a comma-separated list of URLS)")
  exit 1
fi

echo "Updating config"

TEMPLATE=alprd.conf.template
OUTPUT=/etc/openalpr/alprd.conf

sed \
  -e "s/%COUNTRY%/${COUNTRY:-us}/" \
  -e "s/%COMPANY_ID%/${COMPANY_ID}/" \
  -e "s/%SITE_ID%/${SITE_ID}/" \
  -e "s/%ENABLE_PLATE_IMAGES%/${ENABLE_PLATE_IMAGES:-1}/" \
  -e "s|%PLATE_IMAGES_PATH%|${PLATE_IMAGES_PATH:-/var/lib/openalpr/plateimages}|" \
  -e "s/%ENABLE_UPLOAD%/${ENABLE_UPLOAD:-0}/" \
  -e "s|%UPLOAD_ADDRESS%|${UPLOAD_ADDRESS:-http://localhost:9000}|" \
  ${TEMPLATE} > "${OUTPUT}"

echo "key=${LICENSE_KEY}" > /etc/openalpr/license.conf

echo "" >> ${OUTPUT}
echo "store_plates_maxsize_mb ${MAX_PLATES_MB:-250}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "analysis_threads ${ANALYSIS_THREADS:-2}" >> ${OUTPUT}

echo "" >> ${OUTPUT}

IFS=',' read -r -a CAMERAS <<< "$CAMERA_URLS"

for c in "${CAMERAS[@]}"; do
  echo "stream ${c}" >> ${OUTPUT}
done

/proxy.sh 11300 beanstalkd 11300 &

exec $@
