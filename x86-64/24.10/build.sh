#!/bin/bash
# Log file for debugging
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
echo "编译固件大小为: $PROFILE MB"
echo "Include Docker: $INCLUDE_DOCKER"

echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入环境变量ENABLE_PPPOE等 写入配置文件 供99-custom.sh读取
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings
# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始编译..."



# 定义所需安装的软件列表 下列插件可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
#24.10
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"

# 不需要参与编译的软件包
# PACKAGES="$PACKAGES luci-i18n-filebrowser-zh-cn"
# PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
# PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
# PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
# PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
# PACKAGES="$PACKAGES luci-app-openclash"
# 增加几个必备组件 方便用户安装iStore
# PACKAGES="$PACKAGES fdisk"
# PACKAGES="$PACKAGES script-utils"

# 若有未列出的软件，前往下面的网站，自行搜索。能搜到就说明能安装。根据上面的格式增加代码即可。
# https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/
# https://downloads.immortalwrt.org/releases/packages-24.10.1/x86_64/packages/



# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE="generic" PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$PROFILE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
