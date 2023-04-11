source common.sh

if [ -z "${mysql_root_password}" ]; then
  echo "mysql root password variable missing"
  exit
fi

print_head "CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version."
dnf module disable mysql -y &>> ${LOG}
status_check

print_head "copy mysql repo file "
cp ${script_location}/files/mysql.repo /etc/yum.repos.d/mysql.repo
status_check

print_head "install mysql"
yum install mysql-community-server -y &>> ${LOG}
status_check

print_head "start mysql"
systemctl start mysqld
status_check

print_head "enable mysql"
systemctl enable mysqld &>> ${LOG}
status_check

print_head "changing mysql root password"
mysql_secure_installation --set-root-pass ${mysql_root_password} &>> ${LOG}
status_check