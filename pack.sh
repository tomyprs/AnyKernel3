#!/bin/bash -x
rm *.zip
zip -r9 Mi8937-Kernel-4.9-$(date +%Y%m%d).zip * -x .git README.md *placeholder
