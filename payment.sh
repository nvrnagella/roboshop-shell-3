source common.sh

if[ -z "${roboshop_rabbitmq_password}" ]
then
  echo "variable roboshop_rabbitmq_password is missing"
  exit
fi

component=payment
schema_load=false

PYTHON

