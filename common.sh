script_location=$(pwd)
LOG=/tmp/roboshop.log

print_head (){
  echo -e "\e[1;32m $1 \e[0m"
}

status_check (){
  if [ $? -eq 0 ]; then
    echo "SUCCESS"
  else
    echo "FAILURE"
    echo "refer failure log information LOG- ${LOG}"
    exit
  fi
}

APP_PREREQ (){
  print_head "add application user"
  id roboshop &>> ${LOG}
  if [ $? != 0 ]; then
    useradd roboshop
  fi
  status_check

  print_head "create app directory"
  mkdir -p /app
  status_check

  print_head "download app content"
  curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>> ${LOG}
  status_check

  print_head "remove old app content"
  rm -rf /app/*
  status_check

  print_head "extract app content"
  cd /app
  unzip /tmp/${component}.zip  &>> ${LOG}
  status_check
}

SYSTEMD_SETUP (){
  print_head "load systemd file"
  cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service
  status_check

  print_head "load systemd file"
  systemctl daemon-reload
  status_check

  print_head "enable ${component}"
  systemctl enable ${component} &>> ${LOG}
  status_check

  print_head "start ${component}"
  systemctl restart ${component}
  status_check
}

SCHEMA_LOAD (){
  if [ "${schema_load}" == "true" ]; then
    if [ ${schema_type} == "mongo" ]; then
      print_head "loading mongodb repo file"
      cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongodb.repo
      status_check

      print_head "installing mongodb-org-shell"
      yum install mongodb-org-shell -y &>> ${LOG}
      status_check

      print_head "loading mongodb schema"
      mongo --host mongodb-dev.nvrnagella.online </app/schema/${component}.js &>> ${LOG}
      status_check
    fi
    if [ "${schema_type}" == "mysql" ]; then
      print_head "installing mysql "
      yum install mysql -y &>> ${LOG}
      status_check

      print_head "load schema"
      mysql -h mysql-dev.nvrnagella.online -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>> ${LOG}
      status_check
    fi
  fi
}

NODEJS (){
  print_head "setup nodejs repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG}
  status_check

  print_head "install nodejs"
  yum install nodejs -y &>> ${LOG}
  status_check

  APP_PREREQ

  print_head "install app dependencies"
  npm install &>> ${LOG}
  status_check

  SYSTEMD_SETUP

  SCHEMA_LOAD
}

MAVEN (){
  print_head "install maven"
  yum install maven -y &>> ${LOG}
  status_check

  APP_PREREQ

  print_head "install app dependencies"
  mvn clean package &>> ${LOG}
  mv target/${component}-1.0.jar ${component}.jar
  status_check

  SYSTEMD_SETUP

  SCHEMA_LOAD

#  print_head "restarting shipping"
#  systemctl restart ${component}
#  status_check
}

PYTHON (){
  print_head "install python 3.6 gcc and python devel"
  yum install python36 gcc python3-devel -y &>> ${LOG}
  status_check

  APP_PREREQ

  print_head "download python dependencies"
  pip3.6 install -r requirements.txt &>> ${LOG}
  status_check

  print_head "updating password in service file"
  sed -i -e "s/roboshop_rabbitmq_password/${roboshop_rabbitmq_password}/" ${script_location}/files/payment.service
  status_check

  SYSTEMD_SETUP

  SCHEMA_LOAD
}

GOLANG (){
  print_head "installing golang"
  yum install golang -y &>> ${LOG}
  status_check

  APP_PREREQ

  print_head "installing golang dependencies"
  go mod init dispatch
  go get
  go build
  status_check

  print_head "updating password in service file"
  sed -i -e "s/roboshop_rabbitmq_password/${roboshop_rabbitmq_password}/" ${script_location}/files/dispatch.service
  status_check

  SYSTEMD_SETUP

  SCHEMA_LOAD
}