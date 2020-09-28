#!/bin/sh

dir=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

cd ${dir}

echo "Cleaning up EFI directory and below -- ${dir}"

find . -name "._*" -type f -delete

find . -name ".DS_Store" -type f -delete
