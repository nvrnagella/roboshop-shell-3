source common.sh

print_head "setup repo for mongodb"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo
status_check

print_head "install mongodb"
yum install mongodb-org &>> ${LOG}
status_check

print_head "enable mongodb"
systemctl enable mongod &>> ${LOG}
status_check

print_head "start mongodb"
systemctl start mongod
status_check

print_head "update listed address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
status_check

print_head "restart mongodb"
systemctl restart mongod
status_check