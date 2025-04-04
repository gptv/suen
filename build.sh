#!/bin/bash
echo "--- BUILD SCRIPT IS RUNNING ---"
pwd
ls -la
echo "--- CREATING MARKER FILE ---"
# Create a directory and a dummy file to ensure CF sees build output
mkdir -p build_output
touch build_output/build_ran.txt
echo "--- BUILD SCRIPT FINISHED ---"
exit 0