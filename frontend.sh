source common.sh

print_head "installing nginx"
yum install nginx -y &>> ${LOG}
status_check

print_head "start the nginx"
systemctl start nginx &>> ${LOG}
status_check

print_head "enable nginx"
systemctl enable nginx &>> ${LOG}
status_check

print_head "download the app content"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>> ${LOG}

print_head "remove old app content"
rm -rf /usr/share/nginx/html/* &>> ${LOG}
status_check

print_head "extracting nginx content"
unzip /tmp/frontend.zip &>> ${LOG}
status_check

print_head "copy nginx reverse proxy configuration file"
cp ${script_location}/files/roboshop.conf /etc/nginx/default.d/roboshop.conf
status_check

print_head "restart nginx"
systemctl restart nginx
status_check
