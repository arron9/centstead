#!/usr/bin/env bash

# 检测是否需要安装
if [ -f /home/vagrant/.env/pgsql94 ]
then
    exit 0
fi

# 清洁
sudo /bin/bash /home/vagrant/.remove/pgsql.sh

# 安装 Postgres
yum install -y postgresql94 postgresql94-server postgresql94-devel postgresql94-contrib --enablerepo=pgdg94

# 建立 环境标识
rm -rf /home/vagrant/.env/pgsql*
touch /home/vagrant/.env/pgsql94

/usr/pgsql-9.4/bin/postgresql94-setup initdb
systemctl enable postgresql-9.4.service
systemctl start postgresql-9.4.service

# 配置 Postgres 远程访问
sed -i "/#listen_addresses/alisten_addresses = '*'" /var/lib/pgsql/9.4/data/postgresql.conf
sed -i "/local.*all.*all.*peer/s/peer/trust/" /var/lib/pgsql/9.4/data/pg_hba.conf
echo "host    all             all             10.0.2.2/32               md5" | tee -a /var/lib/pgsql/9.4/data/pg_hba.conf
sudo -i -u postgres psql -c "CREATE ROLE vagrant LOGIN UNENCRYPTED PASSWORD 'vagrant' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"

systemctl restart postgresql-9.4.service