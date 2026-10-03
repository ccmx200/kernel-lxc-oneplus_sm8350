# OnePlus 9 LE2100 QGKI 5.4 ReSukiSU + Droidspaces 构建说明

## 当前结论

- 设备：OnePlus 9 / LE2100
- 内核：Linux 5.4 QGKI
- defconfig：`arch/arm64/configs/vendor/lahaina-qgki_defconfig`
- 已验证可用：最小 GKI 配置 + BBR + ReSukiSU + SYSVIPC kABI `3_4_5`
- 对应刷机包：
  `ReSukiSU-QGKI-OnePlus9-LE2100-minimal-GKI-BBR-kabi345.zip`

## Droidspaces 补丁

已应用：

- `002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch`
- `001.GKI-below-6.12-fix_sysvipc_kabi_3_4_5.patch`

`user.h` 的 POSIX_MQUEUE hunk 已按本内核实际结构手动适配，
因为本内核没有 `ANDROID_OEM_DATA_ARRAY`。

## 关键配置

开启：

```text
CONFIG_SYSVIPC=y
CONFIG_POSIX_MQUEUE=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_DEVTMPFS=y
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_USER_NS=y
CONFIG_NETFILTER_XT_TARGET_REJECT=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_IP_SET=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_NETFILTER_XT_SET=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BBR=y
CONFIG_KSU=y
CONFIG_KSU_MANUAL_HOOK=y
```

关闭：

```text
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_BTRFS_FS is not set
```

## 构建

```sh
./build.sh
```

快速检查：

```sh
./build.sh --check --no-ccache --no-update
```

## 备注

- GitHub 默认走 `https://git.yylx.win/`
- 不要开启 `CONFIG_FAIR_GROUP_SCHED`
- 不要开启 BTRFS
- 如果 `3_4_5` 仍卡一屏，尝试 `1_2_3` SYSVIPC kABI 变体
