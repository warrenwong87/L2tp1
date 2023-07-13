Install L2tp and PPTP.

wget --no-check-certificate https://raw.githubusercontent.com/warrenwong87/L2tp1/main/l2tp.sh

chmod +x l2tp.sh

./l2tp.sh

apt-get install pptpd

vi /etc/pptpd.conf

去掉下面两行的注释或者直接添加这两行(在文件的最后).这一步是配置ip地址的范围。

localip 192.168.18.1

remoteip 192.168.18.2-10,192.168.18.245

为了让你的用户连上VPN后能够正常地解析域名，我们需要手动设置DNS. vi /etc/ppp/options，找到ms-dns这一项，设置你的DNS.这里我推荐的是Google 最近发布的Public DNS,原因是因

为好记。

ms-dns 8.8.8.8

ms-dns 8.8.4.4

/etc/init.d/pptpd restart

最后开启iptables转发

iptables -t nat -A POSTROUTING -s 192.168.18.0/24 -o eth0 -j MASQUERADE

iptables -t nat -A POSTROUTING -s 192.168.18.0/24 -d 0.0.0.0/0 -o eth0 -j MASQUERADE

iptables -I FORWARD -s 192.168.18.0/24 -p tcp --syn -i ppp+ -j TCPMSS --set-mss 1300

if not wowking

iptables -t nat -A POSTROUTING -s 192.168.18.0/24 -o eth0 -j SNAT --to-source 10.0.8.46

iptables -t nat -A POSTROUTING -s 10.0.8.0/24 -o eth0 -j MASQUERADE

iptables -I FORWARD -s 192.168.18.0/24 -j ACCEPT

iptables -I FORWARD -d 192.168.18.0/24 -j ACCEPT
