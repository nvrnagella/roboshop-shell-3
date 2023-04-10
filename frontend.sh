source common.sh

print_head "installing nginx"
yum install nginx -y &>> ${LOG}
status_check

