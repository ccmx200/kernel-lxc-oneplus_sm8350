## 说明
b.sh=build.sh
./b.sh                       # 直连，自动更新，ccache 开
./b.sh -cn                   # 走 https://git.yylx.win/ 加速
./b.sh -cn -nu               # 加速 + 跳过 ReSukiSU 更新
./b.sh -cn --no-ccache       # 加速 + 关 ccache
CLEAN_BUILD=true ./b.sh -cn  # 完全清理 + 加速
ERROR_CTX=300 ./b.sh -cn     # 错误上下文 300 行
DEFCONFIG=vendor/lahaina-qgki_defconfig ./b.sh  # 显式指定 defconfig
