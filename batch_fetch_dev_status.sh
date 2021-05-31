#! /bin/bash

# usage
# ./get_device_status.sh devices.list
#

MENDER_SERVER_URI='https://devices.mender.host.url'
MENDER_SERVER_USER='admin@devices.mender.host.url'
MENDER_SERVER_PASSWORD='abrilliantpassword'
JWT=$(curl -s -X POST -u $MENDER_SERVER_USER:$MENDER_SERVER_PASSWORD $MENDER_SERVER_URI/api/management/v1/useradm/auth/login -k)
echo -n "${JWT}" > .mender_jwt
API_KEY=$(cat .mender_jwt)


echo "[{\"Connected\" :[" > .mender_connected
echo "\"Disconnected\":[" > .mender_disconnected
#list all status of devices.list
devicelist="devices.list"
Devices=$(cat $devicelist)
for id in $Devices
do
  RESPONSE=$(curl -s --insecure -X GET $MENDER_SERVER_URI/api/management/v1/deviceconnect/devices/${id} -H 'Accept: application/json' -H "Authorization: Bearer $API_KEY")
  if [[ ${RESPONSE} == *"disconnected"* ]]; then
    echo ${RESPONSE} >> .mender_disconnected
    echo "," >> .mender_disconnected
  else
    echo ${RESPONSE} >> .mender_connected
    echo "," >> .mender_connected
  fi
done

sed -i '$ s/.$//' .mender_connected
echo "]},{" >> .mender_connected

sed -i '$ s/.$//' .mender_disconnected
echo "]}]" >> .mender_disconnected


cat .mender_connected > .mender_dev_report
cat .mender_disconnected >> .mender_dev_report

#cat .mender_dev_report
CHANGED=$(diff .mender_dev_report .mender_dev_report_last)

if [[ ${CHANGED} == *"device_id"* ]]; then
  cp .mender_dev_report device.status
  echo
  echo "=================================================="
  echo "+ The following devices changed state            +"
  echo "=================================================="
  date
  echo "=================================================="
  echo ${CHANGED}
  echo "=================================================="
fi

rm .mender_connected
rm .mender_disconnected
rm .mender_dev_report_last
mv .mender_dev_report .mender_dev_report_last
rm .mender_jwt
