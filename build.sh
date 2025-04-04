#!/bin/bash
echo "Starting build script..."
set -e # Exit on error

# Check if git-lfs command exists, install if not (should already be in CF build env)
if ! command -v git-lfs &> /dev/null
then
    echo "git-lfs not found, attempting to install..."
    apt-get update && apt-get install -y git-lfs
else
    echo "git-lfs found."
fi

echo "Initializing LFS (Skipping repo setup)..."
git lfs install --system --skip-repo

echo "Attempting to fetch LFS objects..."
git lfs fetch --all || echo "LFS fetch command failed, continuing build..."

echo "Attempting to pull LFS objects to replace pointers..."
git lfs pull || { echo "LFS pull command failed!"; exit 1; }

echo "LFS pull completed."

# --- 新增的複製步驟 ---
echo "Copying fonts directory to build output directory (allinone)..."
# 確保目標目錄的父目錄存在
mkdir -p allinone
# 複製整個 fonts 文件夾到 allinone/ 目錄下
cp -r fonts allinone/
echo "Fonts copied to allinone/fonts."
# --- 複製步驟結束 ---

echo "Build script finished."
exit 0