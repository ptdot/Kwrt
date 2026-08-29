#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

rm -rf package/boot package/firmware/ipq-wifi target/linux/generic target/linux/qualcommax package/firmware/ath11k-firmware package/kernel/mac80211 package/kernel/nat46

git_clone_path 25.12-nss https://github.com/LiBwrt/openwrt-6.x target/linux/generic target/linux/qualcommax package/boot package/firmware/ipq-wifi package/firmware/ath11k-firmware package/kernel/mac80211 package/kernel/nat46

wget -N https://github.com/LiBwrt/LibWrt/raw/refs/heads/25.12-nss/include/image-commands.mk -P include/
wget -N https://github.com/LiBwrt/LibWrt/raw/refs/heads/25.12-nss/config/Config-ipq.in -P config/
wget -N https://github.com/LiBwrt/LibWrt/raw/refs/heads/25.12-nss/Config.in -P ./

rm -rf feeds/kiddin9/shortcut-fe

git clone https://github.com/qosmio/nss-packages.git package/nss-packages
git clone https://github.com/qosmio/sqm-scripts-nss.git package/sqm-scripts-nss
git clone https://github.com/amnezia-vpn/amneziawg-openwrt.git package/amneziawg-openwrt

sed -i "/ECM_INTERFACE_RAWIP_ENABLE/d" package/nss-packages/qca-nss-ecm/Makefile
rm -rf package/nss-packages/nss-userspace-oss

sed -i "s/luci uboot-envtools wpad-openssl/luci uboot-envtools wpad-mbedtls/" target/linux/qualcommax/Makefile


echo "CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_jdcloud_re-ss-01=y" >> .config

#!/bin/bash

# 1. Xóa sạch mã nguồn các gói không dùng khỏi feeds và package
rm -rf feeds/*/v2ray-plugin package/feeds/*/v2ray-plugin package/v2ray-plugin
rm -rf feeds/*/geoview package/feeds/*/geoview package/geoview
rm -rf feeds/*/v2ray-geoip package/feeds/*/v2ray-geoip package/v2ray-geoip
rm -rf feeds/*/v2ray-geosite package/feeds/*/v2ray-geosite package/v2ray-geosite
rm -rf feeds/*/sing-box package/feeds/*/sing-box package/sing-box

# 2. Lọc bỏ sạch sẽ phụ thuộc (dependency) liên quan trong tất cả các Makefile
find package/ feeds/ -type f -name "Makefile" -exec sed -i \
    -e '/v2ray-plugin/d' \
    -e '/geoview/d' \
    -e '/v2ray-geoip/d' \
    -e '/v2ray-geosite/d' \
    -e '/sing-box/d' {} +

# 3. Làm sạch cache cấu hình cũ
rm -rf tmp/ .config*
