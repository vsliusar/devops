#!/bin/bash

if [ $# -eq 0 ]; then
  echo "No directory provided"
  exit 1
fi


count_files() {
    directory=$1
    count=$(find "$directory" -type f | wc -l)
    echo "There are $count files in directory $directory"
}

for dir in "$@"; do
    count_files "$dir"
done