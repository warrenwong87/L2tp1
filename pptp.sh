#!/bin/sh
## 安装PPTP服务
apt-get -y install pptpd || {
  echo "无法定位软件，请检查源或依赖"
  exit 1
}

## ubuntu rc.local文件末行exit 0
sed -i '/^exit 0/d' /etc/rc.local

## 添加到开机启动项，并且设置iptables，注意网卡（eth0，ipconfig可查看网卡）
cat >> /etc/rc.local << END
echo 1 > /proc/sys/net/ipv4/ip_forward


iptables -I INPUT -p tcp --dport 22 -j ACCEPT


iptables -I INPUT -p tcp --dport 1723 -j ACCEPT


iptables -I INPUT  --protocol 47 -j ACCEPT

iptables -t nat -A POSTROUTING -s 192.168.18.0/24 -d 0.0.0.0/0 -o eth0 -j MASQUERADE

iptables -I FORWARD -s 192.168.18.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356

service pptpd restart
END

sh /etc/rc.local


END
cat >/etc/pptpd.conf <<END
option /etc/ppp/options.pptpd
logwtmp
localip 192.168.18.1
remoteip 192.168.18.2-10
END
cat >/etc/ppp/options.pptpd <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 223.5.5.5
ms-dns 8.8.4.4
proxyarp
lock
nobsdcomp 
novj
novjccomp
nologfd
END


echo   "安装完成"
sleep 2

service pptpd restart

exit 0
