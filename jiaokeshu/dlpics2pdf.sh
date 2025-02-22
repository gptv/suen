#!/bin/bash
# Description: This script downloads a series of images and merges them into a single PDF file.
# It is based on the image URL structure from the provided JSON data, designed specifically for macOS.
# Assumes necessary command-line tools (wget, img2pdf) are installed.

# ** Step 0: Check for required tools **
command -v wget >/dev/null 2>&1 || { echo >&2 "Error: wget is not installed. Please install it (e.g., 'brew install wget' on macOS or 'sudo apt-get install wget' on Debian/Ubuntu)."; exit 1; }
command -v img2pdf >/dev/null 2>&1 || { echo >&2 "Error: img2pdf is not installed. Please install it (e.g., 'brew install img2pdf' on macOS or 'sudo apt-get install img2pdf' on Debian/Ubuntu)."; exit 1; }

# ** Step 1: Create directories **
mkdir -p book_images book_pdf  # Creates two directories:
                               # - book_images: For storing downloaded images (JPG format)
                               # - book_pdf:    For storing the final PDF file
                               # The '-p' option ensures that parent directories are created if needed and no error is thrown if directories already exist.

# ** Step 2: Change to the image directory **
cd book_images                # Change the working directory to 'book_images' folder.
                              # The images will be downloaded into this folder.

# ** Step 3: Loop to download images **
for i in $(seq 1 127); do     # For loop, iterates through page numbers 1 to 127 (127 pages in total).
                               # 'seq 1 127' generates a sequence from 1 to 127.
                               # The variable 'i' represents the current page number in each iteration.

  # Calculate server number (r1, r2, r3 will be used in rotation)
  server_num=$(( (i - 1) % 3 + 1 ))
  #  - '(i - 1) % 3': Calculates the remainder when (i - 1) is divided by 3, resulting in 0, 1, or 2 (for cyclic sequence).
  #  - '+ 1': Add 1 to the result, producing 1, 2, or 3 (the cyclic sequence for r1, r2, r3 servers).
  #  - 'server_num=$(( ... ))': Assigns the result to the variable 'server_num'.

  # Set page number
  slide_num=$i                # Assign the current loop page number 'i' to the 'slide_num' variable.

  # Build the image URL
  url="https://r${server_num}-ndr.ykt.cbern.com.cn/edu_product/esp/assets/b87e153f-a64c-451a-aa6c-6ed9ac7d6821.t/zh-CN/1737863383133/transcode/image/${slide_num}.jpg"
  #  - 'https://r${server_num}-...image/': Using the calculated 'server_num', selects the corresponding server r1, r2, or r3.
  #  - '${slide_num}.jpg': Uses the current page number 'slide_num' as the image file name.

  # Check if the image already exists
  if [ ! -f "slide_${slide_num}.jpg" ]; then
    # Use wget to download the image
    wget -O "slide_${slide_num}.jpg" "$url"
    if [ $? -ne 0 ]; then
      echo "Error downloading image $slide_num. wget exited with status $?. Skipping."
      continue  # Skip this iteration if the download fails
    fi
  else
    echo "Image $slide_num already downloaded, skipping."
  fi

done  # End of the loop

# ** Step 4: Change to the PDF directory **
cd ../book_pdf                # After downloading all images, change to the 'book_pdf' folder.
                              # The PDF file will be generated here.

# ** Step 5: Convert images to PDF **
img2pdf ../book_images/slide_*.jpg -o book.pdf
if [ $? -ne 0 ]; then
  echo "Error generating PDF. img2pdf exited with status $?. Please check if all images downloaded correctly in book_images folder."
  exit 1  # Exit the script with error if PDF generation fails
fi

# ** Step 6: Output completion message **
echo "PDF file has been generated in book_pdf/book.pdf" # Output message notifying the user that the PDF file is ready.

# ** Step 7: (Optional) Return to the parent directory **
cd ..                         # Returns to the parent directory, allowing you to go back to the directory where the script was executed.

# ** Script usage instructions **

# 1. Save the script:
#     Copy and paste the above code into a text editor (e.g., macOS built-in "TextEdit").
#     Save the file with a '.sh' extension, such as 'download_book.sh'.

# 2. Make the script executable:
#     Open the "Terminal" app and navigate to the directory where you saved the script (use the 'cd' command).
#     Then, run the following command to make the script executable:
#     chmod +x download_book.sh

# 3. Run the script:
#     In the "Terminal", run the following command to execute the script:
#     ./download_book.sh

# ** Ensure necessary tools are installed **
#   This script requires 'wget' and 'img2pdf' to be installed on your system.
#   On macOS, you can use the Homebrew package manager. If you don't have Homebrew installed,
#   visit https://brew.sh/ for installation instructions.
#   After installing Homebrew, run the following commands in "Terminal" to install 'wget' and 'img2pdf':
#   brew install wget img2pdf

# ** Optional: Use 'convert' (ImageMagick) as an alternative PDF conversion tool **
#   If you don't have 'img2pdf' or wish to use 'convert', you can replace the command in Step 5.
#   First, install ImageMagick (if not installed):
#   brew install imagemagick
#   Then, replace the command in Step 5 with:
#   convert ../book_images/slide_*.jpg book.pdf

# ** Cleanup (Optional) **
#   After the PDF file is successfully generated, if you wish to save disk space, you can delete the 'book_images' folder and its JPG images:
#   rm -rf book_images