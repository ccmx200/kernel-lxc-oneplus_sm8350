# OnePlus 9 (LE2100) SM8350 QGKI Kernel

ReSukiSU + Droidspaces 内核源码，适用于 OnePlus 9 / LE2100。

- 设备：OnePlus 9 / LE2100
- 平台：Qualcomm SM8350 / lahaina
- 内核版本：Linux 5.4
- 内核变体：QGKI
- 默认配置：`arch/arm64/configs/vendor/lahaina-qgki_defconfig`
- 主要功能：ReSukiSU Root、Droidspaces 容器支持、LXC/Docker 内核配置、BBR

---

## 功能与修改

### ReSukiSU

- ReSukiSU 源码内置在 `ReSukiSU/`
- 内核入口软链接：

```text
drivers/kernelsu -> ../ReSukiSU/kernel
```

- 使用 manual hook：

```text
CONFIG_KSU=y
# CONFIG_KSU_TRACEPOINT_HOOK is not set
CONFIG_KSU_MANUAL_HOOK=y
# CONFIG_KSU_SUSFS is not set
CONFIG_KSU_MANUAL_HOOK_AUTO_SETUID_HOOK=y
CONFIG_KSU_MANUAL_HOOK_AUTO_INITRC_HOOK=y
CONFIG_KSU_MANUAL_HOOK_AUTO_INPUT_HOOK=y
```

已修改 manual hook 的内核源码：

- `fs/stat.c`
- `fs/open.c`
- `fs/exec.c`
- `kernel/reboot.c`

### Droidspaces GKI kABI 补丁

已应用 Droidspaces 官方 GKI 补丁：

```text
001.GKI-below-6.12-fix_sysvipc_kabi_6_7_8.patch
002.5.10_or_lower_use_android_abi_padding_for_posix_mqueue.patch
```

来源：

```text
ravindu644/Droidspaces-OSS
Documentation/resources/kernel-patches/GKI/below-kernel-6.12/
```

这些补丁用于避免启用 `CONFIG_SYSVIPC` / `CONFIG_POSIX_MQUEUE` 后
`task_struct` / `user_struct` ABI 偏移变化导致不开机。

### Droidspaces / LXC / Docker 配置

已开启：

```text
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

### 禁用 BTRFS

已确认关闭：

```text
# CONFIG_BTRFS_FS is not set
```

---

## 编译

环境：WSL Arch Linux + clang / LLVM

```sh
cd /root/android_kernel_oneplus_sm8350-resukisu-droidspaces
./build.sh
```

脚本会：

1. 清理旧构建产物；
2. 设置 `drivers/kernelsu`；
3. 使用 `vendor/lahaina-qgki_defconfig`；
4. 使用 clang / LLVM / LTO=thin 编译；
5. 生成 `Image.gz`；
6. 使用 AnyKernel3 打包 zip。

### 输出

```text
out/arch/arm64/boot/Image.gz
ReSukiSU-QGKI-OnePlus9-LE2100-YYYYMMDD-HHMM.zip
```

---

## 注意事项

- `CONFIG_CGROUP_NET_PRIO` 在该 5.4 QGKI 源码上会触发
  `struct cgroup has no member named 'id'` 编译错误。
  该选项不属于 Droidspaces GKI 必需项，已关闭以保证可编译。
- 当前未启用 SUSFS。如需 SUSFS，需要额外移植 SUSFS 内核侧补丁。
- 请自行确认 AnyKernel3 包适用于你的设备与当前系统版本，刷机前务必备份 boot。

---

## 推送到新仓库

```sh
git remote add origin <你的新仓库地址>
git push -u origin resukisu
```

如果新仓库默认分支为 `main`：

```sh
git branch -M main
git push -u origin main
```

---

## License

内核源码遵循其原始 GPL-2.0 许可证。
ReSukiSU 源码遵循其仓库内对应许可证。
