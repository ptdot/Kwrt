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

# Xóa gói cũ bị lỗi
rm -rf feeds/kiddin9/v2ray-plugin
rm -rf package/feeds/kiddin9/v2ray-plugin

# Sửa lỗi Makefile của v2ray-plugin cho Passwall2 (tương thích Golang mới)
find package/ feeds/ -path "*/v2ray-plugin/Makefile" 2>/dev/null | while read mk; do
    # Thêm cờ bỏ qua kiểm tra VCS của git để tránh lỗi exit status 128
    if ! grep -q "buildvcs=false" "$mk"; then
        sed -i 's/GO_BUILDFLAGS:=/GO_BUILDFLAGS:=-buildvcs=false /g' "$mk"
    fi
    # Sửa đường dẫn build pkg nếu bị lỗi không tìm thấy file go
    sed -i 's#GO_BUILD_PKG:=github.com/shadowsocks/v2ray-plugin$#GO_BUILD_PKG:=github.com/shadowsocks/v2ray-plugin/.#g' "$mk"
done
