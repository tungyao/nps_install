#! /bin/bash
mkdir -p nps
cd nps
if ! test -f "linux_amd64_server.tar.gz"; then
  echo "文件不存在 开始下载"
  wget https://github.com/ehang-io/nps/releases/download/v0.26.10/linux_amd64_server.tar.gz	  
  tar xvf linux_amd64_server.tar.gz
fi
read -p "是否进行快捷配置 y/n " fast_config
fast_config=${fast_config:-n}
if [ "$fast_config" = "y" ]; then
  read -p "brige port default: 8024 " port
  port=${port:-8024}
  read -p "web port default: 8080 " web_port
  web_port=${web_port:-8080}
  read -p "web user default: admin " web_user
  web_user=${web_user:-admin}
  read -p "web password default: password " web_pass
  web_pass=${web_pass:-password}
  sed -i "s/bridge_port[ = a-z 0-9]*/bridge_port=$port/g" conf/nps.conf
  sed -i "s/web_username[ = a-z 0-9]*/web_username=$web_user/g" conf/nps.conf
  sed -i "s/web_port[ = a-z 0-9]*/web_port=$web_port/g" conf/nps.conf
  sed -i "s/web_password[ = a-z 0-9]*/web_password=$web_pass/g" conf/nps.conf
  sed -i "s/http_proxy_port=80/#http_proxy_port=80/" conf/nps.conf
  sed -i "s/https_proxy_port=443/#http_proxy_port=443/" conf/nps.conf
fi

echo "注册到系统服务"
this_pwd=$(pwd)
echo $this_pwd
cat > /etc/systemd/system/nps.service <<EOF
[Unit]
Description=nps
After=network.target
[Service]
Type=simple
ExecStart=$this_pwd/nps
[Install]
WantedBy=multi-user.target
EOF

systemctl enable nps
systemctl start nps
