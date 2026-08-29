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

#!/bin/bash

# =========================================================
# 1. XÓA TẬN GỐC CÁC GÓI GÂY LỖI KCONFIG & RECURSIVE DEPENDENCY
# =========================================================
# Xóa NekoBox (gây lỗi PHP8_INTL)
rm -rf feeds/*/luci-app-nekobox package/feeds/*/luci-app-nekobox
rm -rf feeds/*/nekobox package/feeds/*/nekobox

# Xóa ipsec-server (gây lỗi vòng lặp ppp)
rm -rf feeds/*/luci-app-ipsec-server package/feeds/*/luci-app-ipsec-server

# Xóa triệt để các gói Geoview / V2ray / Sing-box không dùng
rm -rf feeds/*/v2ray-plugin package/feeds/*/v2ray-plugin
rm -rf feeds/*/geoview package/feeds/*/geoview
rm -rf feeds/*/v2ray-geoip package/feeds/*/v2ray-geoip
rm -rf feeds/*/v2ray-geosite package/feeds/*/v2ray-geosite
rm -rf feeds/*/sing-box package/feeds/*/sing-box

# =========================================================
# 2. XÓA KHAI BÁO DEPENDENCY TRONG TẤT CẢ MAKEFILE
# =========================================================
find package/ feeds/ -type f -name "Makefile" -exec sed -i \
    -e '/luci-app-nekobox/d' \
    -e '/luci-app-ipsec-server/d' \
    -e '/v2ray-plugin/d' \
    -e '/geoview/d' \
    -e '/v2ray-geoip/d' \
    -e '/v2ray-geosite/d' \
    -e '/sing-box/d' {} +

# =========================================================
# 3. LÀM SẠCH CACHE VÀ CẬP NHẬT LẠI FEEDS INDEX
# =========================================================
# Xóa cache tmp cũ để ép OpenWrt tạo lại tmp/.config-package.in sạch
rm -rf tmp/

# Cài đặt lại chỉ mục feeds sau khi đã dọn rác
./scripts/feeds install -a
