#!/bin/bash
# ReSukiSU + Droidspaces build script for OnePlus 9 (LE2100) SM8350 QGKI kernel
# Kernel: 5.4, variant: vendor/lahaina-qgki_defconfig

set -e

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$CURRENT_DIR"

# ---------------- options ----------------
CLEAN_BUILD="${CLEAN_BUILD:-false}"
ZIP_ANY_KERNEL="${ZIP_ANY_KERNEL:-true}"

# ---------------- clean ----------------
rm -rf out/arch/arm64/boot
rm -rf .config .config.old .tmp_versions
rm -rf include/generated include/config
rm -rf arch/arm64/include/generated
rm -rf vmlinux* System.map modules.builtin*
rm -f Module.symvers modules.order
rm -rf scripts/kconfig/.tmp*

if [ "$CLEAN_BUILD" = true ]; then
    rm -rf out
fi

# ---------------- toolchain ----------------
TC_DIR="${TC_DIR:-$HOME/toolchains/neutron-clang}"
if [ -x "$TC_DIR/bin/clang" ]; then
    export PATH="$TC_DIR/bin:$PATH"
    CLANG="$TC_DIR/bin/clang"
else
    CLANG="$(command -v clang)"
fi

if [ -z "$CLANG" ]; then
    echo "ERROR: clang not found. Set TC_DIR or install clang." >&2
    exit 1
fi

export CC="${CC:-$CLANG}"
export LD="${LD:-ld.lld}"

if command -v ccache >/dev/null 2>&1 && [ -z "${NO_CCACHE:-}" ]; then
    CC="ccache $CC"
fi

# ---------------- device / output ----------------
SECONDS=0
DATE="$(date '+%Y%m%d-%H%M')"
DEFCONFIG="${DEFCONFIG:-vendor/lahaina-qgki_defconfig}"
ZIPNAME="ReSukiSU-QGKI-OnePlus9-LE2100-${DATE}.zip"

# ---------------- ReSukiSU setup ----------------
if [ ! -d "$CURRENT_DIR/ReSukiSU/kernel" ]; then
    echo "ReSukiSU source not found; cloning from git.yylx.win ..."
    GIT_SSL_NO_VERIFY=true git clone --depth=1 --branch main \
        https://git.yylx.win/github.com/ReSukiSU/ReSukiSU.git "$CURRENT_DIR/ReSukiSU"
fi

rm -f drivers/kernelsu
ln -sfn ../ReSukiSU/kernel drivers/kernelsu

grep -q 'obj-$(CONFIG_KSU) += kernelsu/' drivers/Makefile || echo 'obj-$(CONFIG_KSU) += kernelsu/' >> drivers/Makefile
grep -q 'source "drivers/kernelsu/Kconfig"' drivers/Kconfig || \
    sed -i '/endmenu/i source "drivers/kernelsu/Kconfig"' drivers/Kconfig

# ---------------- build ----------------
echo
echo "Using compiler:"
"$CLANG" --version | head -n 2
echo

MAKE_COMMON=(
    O=out
    ARCH=arm64
    CC="$CC"
    LD="$LD"
    LLVM=1
    LLVM_IAS=1
    NM=llvm-nm
    CROSS_COMPILE=aarch64-linux-gnu-
)
if command -v arm-linux-gnueabi-gcc >/dev/null 2>&1; then
    MAKE_COMMON+=(CROSS_COMPILE_ARM32=arm-linux-gnueabi-)
fi

echo "Configuring $DEFCONFIG ..."
make "${MAKE_COMMON[@]}" "$DEFCONFIG"
make "${MAKE_COMMON[@]}" olddefconfig

echo
echo "Compiling kernel Image.gz ..."
if make -j"$(nproc --all)" "${MAKE_COMMON[@]}" \
    LTO=thin \
    KCFLAGS="-Wno-error=default-const-init-var-unsafe -Wno-default-const-init-var-unsafe" \
    Image.gz; then

    echo
    echo "Kernel compiled successfully."
    echo "Image.gz: $CURRENT_DIR/out/arch/arm64/boot/Image.gz"

    if [ "$ZIP_ANY_KERNEL" = true ]; then
        echo
        echo "Packaging AnyKernel3 zip ..."
        rm -rf AnyKernel3
        if GIT_SSL_NO_VERIFY=true git clone -q --depth=1 \
            https://git.yylx.win/github.com/weaponmasterjax/AnyKernel3 AnyKernel3; then
            cp out/arch/arm64/boot/Image.gz AnyKernel3/
            (cd AnyKernel3 && zip -r9 "../$ZIPNAME" . -x '*.git*' README.md '*placeholder' >/dev/null)
            rm -rf AnyKernel3
            echo "Zip: $CURRENT_DIR/$ZIPNAME"
        else
            echo "WARNING: AnyKernel3 clone failed; only Image.gz was produced."
            rm -rf AnyKernel3
        fi
    fi

    echo
    echo "Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)."
else
    echo "Compilation failed." >&2
    exit 1
fi
