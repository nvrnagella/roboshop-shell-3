source common.sh

print_head "setup nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG}
status_check

print_head "install nodejs"
yum install nodejs -y &>> ${LOG}
status_check

print_head "add application user"
id roboshop
if[ $? -ne 0 ]
then
  useradd roboshop
fi
status_check

print_head "create app directory"
mkdir -p /app
status_check

print_head "download app content"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>> ${LOG}
status_check

print_head "remove old app content"
rm -rm /app/*
status_check

print_head "extract app content"
cd /app
unzip /tmp/catalogue.zip  &>> ${LOG}
status_check

print_head "install app dependencies"
npm install &>> ${LOG}
status_check

print_head "load systemd file"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service
status_check

print_head "load systemd file"
systemctl daemon-reload
status_check

print_head "enable catalogue"
systemctl enable catalogue &>> ${LOG}
status_check

print_head "start catalogue"
systemctl start catalogue
status_check

print_head "loading mongodb repo file"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo
status_check

print_head "installing mongodb-org-shell"
yum install mongodb-org-shell &>> ${LOG}
status_check

print_head "loading mongodb schema"
mongo --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js
status_check