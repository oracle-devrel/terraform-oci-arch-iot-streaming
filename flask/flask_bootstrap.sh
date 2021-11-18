#!/bin/bash

echo '== 1. Install Oracle instant client'
if [[ $(uname -r | sed 's/^.*\(el[0-9]\+\).*$/\1/') == "el8" ]]
then 
   dnf install -y oracle-instantclient-release-el8
   dnf install -y oracle-instantclient-basic
else
  yum install -y oracle-instantclient-release-el7
  yum install -y oracle-instantclient-basic
fi 

echo '== 2. Install Python3, and then with pip3 cx_Oracle and flask'
yum install -y python36
pip3 install cx_Oracle
pip3 install flask

echo '== 3. Disabling firewall and starting HTTPD service'
service firewalld stop
service firewalld disable

echo '== 4. Prepare index.html file'
mkdir /tmp/templates/
chown opc /tmp/templates/
mv /tmp/index.html /tmp/templates/index.html

echo '== 5. Unzip TDE wallet zip file'
unzip -o /tmp/${atp_tde_wallet_zip_file} -d /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/

echo '== 6. Move sqlnet.ora to /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/'
cp /tmp/sqlnet.ora /usr/lib/oracle/${oracle_instant_client_version_short}/client64/lib/network/admin/

echo '== 7. Run Flask with ATP access'
python3 --version
chmod +x /tmp/flask_atp.sh
nohup /tmp/flask_atp.sh > /tmp/flask_atp.log &
sleep 5
ps -ef | grep flask