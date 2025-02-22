#!/bin/bash
# Description: This script downloads images for five distinct books into separate directories.
# It is based on the image URL structure from the provided JSON data, designed for macOS.
# Assumes necessary command-line tool (wget) is installed.
# ** Version 1.0: Added empty image deletion and validation to ensure only valid images are kept. **

# ** Step 0: Check for required tools **
command -v wget >/dev/null 2>&1 || { echo >&2 "Error: wget is not installed. Please install it (e.g., 'brew install wget' on macOS or 'sudo apt-get install wget' on Debian/Ubuntu)."; exit 1; }

# ** Step 1: Book Information Array (Corrected and Complete for 5 Distinct Books) **
declare -a book_ids=(
  "b8e9a3fe-dae7-49c0-86cb-d146f883fd8e" # 必修上
  "9085151a-b698-4b28-8c00-2c4aaf0c91ad" # 必修下
  "3b7a3baf-4e1e-4380-b2cc-3bf330d00cc3" # 選擇性必修上
  "da694670-f25b-46a0-9c3f-a31f5a2f131a" # 選擇性必修中
  "2de54e6d-1f82-4fdc-9f26-c94dfed9c5af" # 選擇性必修下 
)
declare -a book_timestamps=(
  "1725006625292" # 必修上
  "1738722831044" # 必修下
  "1725006626158" # 選擇性必修上
  "1725006627037" # 選擇性必修中
  "1738722955012" # 選擇性必修下 
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
  empty_image_count=0 # Counter for deleted empty images
  empty_image_threshold=10K # Threshold size for considering an image empty (adjust if needed)

  while true; do
    # Calculate server number (r1, r2, r3 will be used in rotation)
    server_num=$(( (page_num - 1) % 3 + 1 ))

    # Set page number
    slide_num=$page_num

    # ** Corrected URL Structure: Using 'assets_document.t' for all books **
    url="https://r${server_num}-ndr.ykt.cbern.com.cn/edu_product/esp/assets/assets_document.t/zh-CN/${book_timestamp}/transcode/image/${slide_num}.jpg"

    # Check if the image already exists
    if [ ! -f "slide_${slide_num}.jpg" ]; then

      echo -ne "下载第 ${slide_num} 页 for ${book_title}...\r"

      # ** Download to a temporary file **
      temp_image_file="temp_slide.jpg"
      wget -q -S -O "${temp_image_file}" "$url"
      wget_status=$?

      if [ "$wget_status" -ne 0 ]; then
        echo "" # Newline after progress indicator
        echo "Error downloading image $slide_num for ${book_title}. wget exited with status $wget_status (Server Request Rejected). URL: $url."
        rm -f "${temp_image_file}" # Cleanup temp file on error
        break # Break inner loop on download failure - assuming end of pages or server issue
      else
        temp_file_size=$(du -b "${temp_image_file}" | awk '{print $1}') # Get size in bytes
        if [ "$temp_file_size" -lt "$(numfmt --from=iec ${empty_image_threshold})" ]; then # Compare size with threshold
          echo "" # Newline after progress indicator
          echo "Downloaded image $slide_num for ${book_title} is empty (Size: $(du -h "${temp_image_file}" | awk '{print $1}')). Deleting."
          rm -f "${temp_image_file}" # Delete temporary empty file
          empty_image_count=$((empty_image_count + 1))
          break # Assume end of book if we encounter an empty image
        else
          file_size=$(du -h "${temp_image_file}" | awk '{print $1}')
          echo "" # Newline after progress indicator
          echo "Downloaded image $slide_num for ${book_title}. Size: ${file_size}."
          mv "${temp_image_file}" "slide_${slide_num}.jpg" # Move temp file to final name
          downloaded_count=$((downloaded_count + 1))
        fi
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

  # ** Step 2.5: Cleanup empty images (Alternative - now we delete empty images during download loop) **
  # echo "Checking and deleting empty images for ${book_title}..."
  # find . -name "slide_*.jpg" -size -10k -print -delete # Example: Delete files smaller than 10KB

  book_end_time=$(date +%s)
  book_download_duration=$((book_end_time - book_start_time))
  total_estimated_time=$((total_estimated_time + book_download_duration))
  echo "Deleted ${empty_image_count} empty images for ${book_title}." # Report empty image count

  # ** Step 2.6: Return to the script's directory **
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