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
git lfs fetch --all || echo "LFS fetch command failed, continuing build..." # Try fetching first

echo "Attempting to pull LFS objects to replace pointers..."
git lfs pull || { echo "LFS pull command failed!"; exit 1; } # Pull LFS files, exit if it fails

echo "LFS pull completed (or failed and exited)."
echo "No further build steps needed for static site."
echo "Build script finished."