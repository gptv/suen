#!/bin/bash
# Description: This script downloads images for five distinct books into separate directories.
# It is based on the image URL structure from the provided JSON data, designed for macOS.
# Assumes necessary command-line tool (wget) is installed.
# PDF generation and cleanup functionalities have been removed as per request.
# ** Version 4.5: Improved error handling, removed consecutive error limit, added file size output, and estimated time (basic). **

# ** Step 0: Check for required tools **
command -v wget >/dev/null 2>&1 || { echo >&2 "Error: wget is not installed. Please install it (e.g., 'brew install wget' on macOS or 'sudo apt-get install wget' on Debian/Ubuntu)."; exit 1; }

# ** Step 1: Book Information Array (Corrected and Complete for 5 Distinct Books) **
declare -a book_ids=(
  "b8e9a3fe-dae7-49c0-86cb-d146f883fd8e" # 必修上
  "9085151a-b698-4b28-8c00-2c4aaf0c91ad" # 必修下
  "3b7a3baf-4e1e-4380-b2cc-3bf330d00cc3" # 選擇性必修上
  "da694670-f25b-46a0-9c3f-a31f5a2f131a" # 選擇性必修中
  "2de54e6d-1f82-4fdc-9f26-c94dfed9c5af" # 選擇性必修下 (Corrected and now distinct book)
)
declare -a book_timestamps=(
  "1725006625292" # 必修上
  "1738722831044" # 必修下
  "1725006626158" # 選擇性必修上
  "1725006627037" # 選擇性必修中
  "1738722955012" # 選擇性必修下 (Corrected and distinct timestamp)
)
declare -a book_titles=(
  "必修上"
  "必修下"
  "选择性必修上"
  "选择性必修中"
  "选择性必修下" # Shortened for filename (Corrected and distinct book title)
)

# ** Step 2: Loop through books **
start_time=$(date +%s) # Script start time
total_estimated_time=0

for book_index in "${!book_ids[@]}"; do
  book_id="${book_ids[book_index]}"
  book_timestamp="${book_timestamps[book_index]}"
  book_title="${book_titles[book_index]}"
  safe_book_title=$(echo "$book_title" | sed 's/[/ ]/_/g') # Make title safe for directory names

  echo "开始下载图片: ${book_title}"

  # ** Step 2.1: Create book directories **
  book_image_dir="book_images_${safe_book_title}"
  mkdir -p "${book_image_dir}"

  # ** Step 2.2: Change to the image directory **
  cd "${book_image_dir}" || { echo >&2 "Error: Failed to change directory to ${book_image_dir}"; continue; }

  # ** Step 2.3: Loop to download images **
  page_num=1
  downloaded_count=0
  book_start_time=$(date +%s)
  last_download_time=0
  estimated_remaining_time="N/A"

  while true; do
    # Calculate server number (r1, r2, r3 will be used in rotation)
    server_num=$(( (page_num - 1) % 3 + 1 ))

    # Set page number
    slide_num=$page_num

    # Build the image URL
    url="https://r${server_num}-ndr.ykt.cbern.com.cn/edu_product/esp/assets/${book_id}.t/zh-CN/${book_timestamp}/transcode/image/${slide_num}.jpg"

    # Check if the image already exists
    if [ ! -f "slide_${slide_num}.jpg" ]; then
      current_time=$(date +%s)
      if [ "$downloaded_count" -gt 0 ]; then
        average_time_per_page=$(awk "BEGIN {printf \"%.2f\", ($current_time - $book_start_time) / $downloaded_count}")
        estimated_remaining_pages=300 # Maximum page limit, adjust if needed, or remove if you have better stop condition
        estimated_remaining_time_seconds=$(( $(echo "$estimated_remaining_pages * $average_time_per_page" | bc) ))

        if [ "$estimated_remaining_time_seconds" -gt 0 ]; then
          estimated_minutes=$((estimated_remaining_time_seconds / 60))
          estimated_seconds=$((estimated_remaining_time_seconds % 60))
          estimated_remaining_time="${estimated_minutes}m ${estimated_seconds}s"
        else
          estimated_remaining_time="Calculating..."
        fi
      else
        estimated_remaining_time="Calculating..."
      fi
      echo -ne "下载第 ${slide_num} 页 for ${book_title}. 预计剩余时间: ${estimated_remaining_time}...\r"

      # Use wget to download the image
      wget -q -O "slide_${slide_num}.jpg" "$url"
      wget_status=$?
      if [ "$wget_status" -ne 0 ]; then
        echo "" # Newline after progress indicator
        echo "Error downloading image $slide_num for ${book_title}. wget exited with status $wget_status. URL: $url. Assuming end of book or network issue."
        break # Break inner loop if download fails - assuming end of pages
      else
        file_size=$(du -h "slide_${slide_num}.jpg" | awk '{print $1}')
        echo "" # Newline after progress indicator
        echo "Downloaded image $slide_num for ${book_title}. Size: ${file_size}."
        downloaded_count=$((downloaded_count + 1))
        last_download_time=$(date +%s)
      fi
    else
      echo "Image $slide_num for ${book_title} already downloaded, skipping."
    fi

    page_num=$((page_num + 1))
    if [ "$page_num" -gt 300 ]; then # Safety break in case of infinite loop, maximum page limit
      echo "Reached page limit of 300. Stopping download for ${book_title}."
      break
    fi
  done

  book_end_time=$(date +%s)
  book_download_duration=$((book_end_time - book_start_time))
  total_estimated_time=$((total_estimated_time + book_download_duration))

  # ** Step 2.4: Return to the script's directory **
  cd .. # Go back to the directory where the script started, relative to book_image_dir

done # ** End of book loop **

end_time=$(date +%s)
total_duration=$((end_time - start_time))
minutes=$((total_duration / 60))
seconds=$((total_duration % 60))

echo "Image downloads for all books are complete."
echo "Images are saved in their respective book_images directories."
echo "Total download time: ${minutes}m ${seconds}s"

# ** Script usage instructions **
# (Same as before, but PDF generation step is removed)

# ** Ensure necessary tools are installed **
# (Same as before, only wget is required now)

# ** Cleanup (Manual if needed) **
#   To save disk space, you can delete the 'book_images_*' folders and their JPG images when you no longer need them:
#   rm -rf book_images_*