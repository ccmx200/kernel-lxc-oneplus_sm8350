# OnePlus 9 (LE2100) SM8350 QGKI Kernel

ReSukiSU + Droidspaces 内核源码，适用于 OnePlus 9 / LE2100。

- 设备：OnePlus 9 / LE2100
- 平台：Qualcomm SM8350 / lahaina
- 内核版本：Linux 5.4
- 内核变体：QGKI
- 默认配置：`arch/arm64/configs/vendor/lahaina-qgki_defconfig`
- 当前状态：已编译验证，使用最小 GKI 配置 + BBR + ReSukiSU

---

## 功能

- ReSukiSU Root
- Droidspaces GKI kABI 兼容
- 最小 GKI 安全配置
- BBR TCP 拥塞控制
- 已禁用 BTRFS
- GitHub 下载默认走 `https://git.yylx.win/`

---

## ReSukiSU

- 源码：`ReSukiSU/`
- 内核入口：

```text
drivers/kernelsu -> ../ReSukiSU/kernel
```

- Hook 模式：

```text
CONFIG_KSU=y
# CONFIG_KSU_TRACEPOINT_HOOK is not set
CONFIG_KSU_MANUAL_HOOK=y
# CONFIG_KSU_SUSFS is not set
CONFIG_KSU_MANUAL_HOOK_AUTO_SETUID_HOOK=y
CONFIG_KSU_MANUAL_HOOK_AUTO_INITRC_HOOK=y
CONFIG_KSU_MANUAL_HOOK_AUTO_INPUT_HOOK=y
```

已修改 manual hook 文件：

```text
fs/stat.c
fs/open.c
fs/exec.c
kernel/reboot.c
```

---

## Droidspaces GKI kABI 补丁

必须应用：

```text
002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch
```

SYSVIPC kABI 补丁使用：

```text
001.GKI-below-6.12-fix_sysvipc_kabi_3_4_5.patch
```

即：

```text
ANDROID_KABI_USE(3, struct sysv_sem sysvsem);
_ANDROID_KABI_REPLACE(ANDROID_KABI_RESERVE(4); ANDROID_KABI_RESERVE(5), struct sysv_shm sysvshm);
```

说明：

- 推荐补丁 `6_7_8` 在 OnePlus 9 上仍可能卡一屏，实际验证 `3_4_5` 可用。
- 如果仍然卡一屏，可再换 `1_2_3` 变体。

---

## 内核配置

当前只保留 GKI 安全配置 + BBR + ReSukiSU：

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

必须保持关闭：

```text
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_BTRFS_FS is not set
```

`CONFIG_FAIR_GROUP_SCHED` 会改变 `task_struct` 内嵌的 `sched_entity`
布局，破坏 GKI kABI，可能导致卡第一屏。

---

## 构建

```sh
cd /root/android_kernel_oneplus_sm8350-resukisu-droidspaces
./build.sh
```

只检查环境和配置，不完整编译：

```sh
./build.sh --check --no-ccache --no-update
```

### 输出

```text
out/arch/arm64/boot/Image.gz
ReSukiSU-QGKI-OnePlus9-LE2100-YYYYMMDD-HHMM.zip
```

当前已验证可用的测试包：

```text
ReSukiSU-QGKI-OnePlus9-LE2100-minimal-GKI-BBR-kabi345.zip
```

---

## 刷入

可使用 AnyKernel3 zip 刷入，或自行替换 boot 镜像中的 kernel。

刷机前请务必备份 boot。

---

## License

内核源码遵循其原始 GPL-2.0 许可证。
ReSukiSU 与 Droidspaces 补丁遵循各自仓库许可证。
