#!/bin/bash -x
if [ -f $1 ]; then cp $1 Image.gz-dtb ; fi
rm *.zip
zip -r9 Mi8937-Kernel-4.9-$(date +%Y%m%d).zip * -x .git README.md *placeholder
