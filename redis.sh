source common.sh

print_head "installing redis rpm repo file "
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> ${LOG}
status_check

print_head "Enable Redis 6.2 from package streams"
dnf module enable redis:remi-6.2 -y &>> ${LOG}
status_check

print_head "install redis"
yum install redis -y &>> ${LOG}
status_check

print_head "enable redis"
systemctl enable redis &>> ${LOG}
status_check

print_head "start redis"
systemctl start redis
status_check

print_head "update listen address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf
status_check

print_head "restart redis"
systemctl restart redis
status_check