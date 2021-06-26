@echo off

if exist output\ (
  echo Temp Directory exists! 
) else (
  echo Creating Temp Directory! 
  mkdir output 
)

echo Creating playground image, running packer! 
packer build --only=generic-arch-virtualbox template.json