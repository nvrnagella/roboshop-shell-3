source common.sh

if [ -z "${roboshop_rabbitmq_password}" ]; then
  echo "variable roboshop_rabbitmq_password is missing"
  exit
fi

print_head "Configure YUM Repos from the script provided by vendor"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>> ${LOG}
status_check

print_head "Install erlang"
yum install erlang -y &>> ${LOG}
status_check

print_head "Configure YUM Repos for RabbitMQ."
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> ${LOG}
status_check

print_head "install rabbitmq server"
yum install rabbitmq-server -y &>> ${LOG}
status_check

print_head "start rabbitmq server"
rabbitmqctl start rabbitmq-server
status_check

print_head "enable rabbitmq server"
rabbitmqctl enable rabbitmq-server &>> ${LOG}
status_check

print_head "RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence, we need to create one user for the application."
rabbitmqctl add_user roboshop ${roboshop_rabbitmq_password} &>> ${LOG}
status_check

print_head "setting admin tag for roboshop user"
rabbitmqctl set_user_tags roboshop administrator &>> ${LOG}
status_check

print_head "setting permissions for roboshop user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> ${LOG}
status_check