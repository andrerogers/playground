@echo off

echo ">>>>> Cleaning Playground'"
rmdir /s/q packer_cache .vagrant output
vagrant box remove playground