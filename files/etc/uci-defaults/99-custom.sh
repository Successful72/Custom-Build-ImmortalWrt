#!/bin/sh
# 99-custom.sh 就是immortalwrt固件首次启动时运行的脚本 位于固件内的/etc/uci-defaults/99-custom.sh
# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
# 设置默认防火墙规则，方便虚拟机首次访问 WebUI
uci set firewall.@zone[1].input='ACCEPT'

# 设置主机名映射，解决安卓原生 TV 无法联网的问题
# uci add dhcp domain
# uci set "dhcp.@domain[-1].name=time.android.com"
# uci set "dhcp.@domain[-1].ip=203.107.6.88"

# 计算网卡数量
count=0
for iface in /sys/class/net/*; do
  iface_name=$(basename "$iface")
  # 检查是否为物理网卡（排除回环设备和无线设备）
  if [ -e "$iface/device" ] && echo "$iface_name" | grep -Eq '^eth|^en'; then
    count=$((count + 1))
  fi
done

# 检查配置文件pppoe-settings是否存在 该文件由build.sh动态生成
SETTINGS_FILE="/etc/config/pppoe-settings"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "PPPoE settings file not found. Skipping." >> $LOGFILE
else
   # 读取pppoe信息($enable_pppoe、$pppoe_account、$pppoe_password)
   . "$SETTINGS_FILE"
fi



# 网络设置
# 无论单网口还是多网口，lan接口都设置为静态IP
uci set network.lan.proto='static'
# 请在下面四行修改自定义的IP地址、子网掩码、网关和DNS
uci set network.lan.ipaddr='200.56.72.198'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='200.56.72.248'
uci set network.lan.dns='114.114.114.114 223.5.5.5'
# 记录IP信息到日志文件（可选修改）
echo "Set static IP 192.168.100.1 at $(date)" >> $LOGFILE

# DHCP设置
# 禁用lan接口的DHCP服务
uci set dhcp.lan.ignore='1'
# 配置本地域名
uci set dhcp.@dnsmasq[0].local='/ycslan/'
uci set dhcp.@dnsmasq[0].domain='ycslan'



# 如果是多网口设备，额外配置WAN口
if [ "$count" -gt 1 ]; then
   # 判断是否启用 PPPoE
   echo "print enable_pppoe value=== $enable_pppoe" >> $LOGFILE
   if [ "$enable_pppoe" = "yes" ]; then
      echo "PPPoE is enabled at $(date)" >> $LOGFILE
      # 设置宽带拨号信息
      uci set network.wan.proto='pppoe'                
      uci set network.wan.username=$pppoe_account     
      uci set network.wan.password=$pppoe_password     
      uci set network.wan.peerdns='1'                  
      uci set network.wan.auto='1' 
      echo "PPPoE配置已成功地完成." >> $LOGFILE
   else
      echo "PPPoE未被启用，跳过配置." >> $LOGFILE
   fi
fi

# 设置所有网口可访问网页终端
# uci delete ttyd.@ttyd[0].interface

# 设置所有网口可连接 SSH
uci set dropbear.@dropbear[0].Interface=''

uci commit

# 设置编译作者信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Compiled by Successful72"
sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

exit 0
