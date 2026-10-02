# OnePlus 9 (LE2100) SM8350 QGKI 5.4 ReSukiSU + Droidspaces 构建说明

## 基本信息

- 设备：OnePlus 9 / LE2100
- 平台：Qualcomm SM8350 / lahaina
- 内核版本：5.4
- 内核变体：QGKI
- 默认 defconfig：`arch/arm64/configs/vendor/lahaina-qgki_defconfig`
- 构建脚本：`build.sh`

## ReSukiSU 集成

- 源码：`ReSukiSU/`
- 内核入口：`drivers/kernelsu -> ../ReSukiSU/kernel`
- Hook 方式：`CONFIG_KSU_MANUAL_HOOK=y`
- 已修改 manual hook 文件：
  - `fs/stat.c`
  - `fs/open.c`
  - `fs/exec.c`
  - `kernel/reboot.c`
- 已关闭：
  - `CONFIG_KSU_TRACEPOINT_HOOK`
  - `CONFIG_KSU_SUSFS`

## Droidspaces GKI kABI 补丁

已应用：

- `001.GKI-below-6.12-fix_sysvipc_kabi_6_7_8.patch`
- `002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch`

补丁来源：`ravindu644/Droidspaces-OSS` 的
`Documentation/resources/kernel-patches/GKI/below-kernel-6.12/`。

这两个补丁用于在启用 `CONFIG_SYSVIPC` / `CONFIG_POSIX_MQUEUE` 后，
避免 `task_struct` / `user_struct` 的 ABI 偏移变化导致开机循环。

注意：`user.h` 的第二个 hunk 已根据本内核实际结构手动适配，
因为本内核没有 `ANDROID_OEM_DATA_ARRAY`。

## defconfig 关键配置

已开启：

```text
CONFIG_KSU=y
# CONFIG_KSU_TRACEPOINT_HOOK is not set
CONFIG_KSU_MANUAL_HOOK=y
# CONFIG_KSU_SUSFS is not set
CONFIG_KSU_MANUAL_HOOK_AUTO_SETUID_HOOK=y
CONFIG_KSU_MANUAL_HOOK_AUTO_INITRC_HOOK=y
CONFIG_KSU_MANUAL_HOOK_AUTO_INPUT_HOOK=y

CONFIG_SYSVIPC=y
CONFIG_POSIX_MQUEUE=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_UTS_NS=y
CONFIG_NET_NS=y
CONFIG_USER_NS=y
CONFIG_DEVTMPFS=y
CONFIG_OVERLAY_FS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_VETH=y
CONFIG_BRIDGE=y
CONFIG_NETFILTER=y
CONFIG_NF_NAT=y
CONFIG_NF_TABLES=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_TCP_CONG_BBR=y
```

已绝对禁用：

```text
# CONFIG_BTRFS_FS is not set
```

说明：

- `CONFIG_CGROUP_NET_PRIO` 在本 5.4 QGKI 源码上会触发
  `struct cgroup has no member named 'id'` 编译错误；该选项不属于
  Droidspaces GKI 必需配置，因此已关闭，以保证正常编译。
- `CONFIG_BTRFS_FS` 已确认关闭。

## 构建

```sh
cd /root/android_kernel_oneplus_sm8350
./build.sh
```

输出：

- `out/arch/arm64/boot/Image.gz`
- `ReSukiSU-QGKI-OnePlus9-LE2100-YYYYMMDD-HHMM.zip`

## 推送新仓库

```sh
cd <新源码目录>
git remote add origin <你的新仓库地址>
git push -u origin resukisu
```
