@echo off

echo ">>>>> Creating Playground'"
for /f %%i in ('dir /b output') do set VAR=%%i
vagrant box add --name playground output\%VAR%