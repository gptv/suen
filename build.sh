#!/bin/bash
echo "Starting build script..."
set -e # Exit on error

# ... (git lfs install, pull 等命令保持不變) ...
echo "LFS pull completed."

echo "Copying fonts directory to build output directory (allinone)..."
# 確保目標目錄存在 (如果 allinone 是空的)
mkdir -p allinone/fonts
# 複製 fonts 文件夾到 allinone/ 下
cp -r fonts allinone/

echo "Fonts copied."
echo "Build script finished."
exit 0