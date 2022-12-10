#! /bin/bash
# Convert all HEIC files in the directory to JPG
# sudo apt install libheif-examples

i=1
for file in *.HEIC; do
    echo "#$i: working on $file"
    heif-convert "$file" "${file/%.HEIC/.jpg}";
    (( i=i+1 ))
done

for file in *.heic; do
    echo "#$i: working on $file"
    heif-convert "$file" "${file/%.heic/.jpg}";
    (( i=i+1 ))
done

echo "done"
