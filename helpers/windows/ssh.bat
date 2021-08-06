@echo off

if "%~1"=="" (
    set "BOX=nobox" 
) else (
    set "BOX=%1%" 
)

if "%~1"=="" (
    echo ">>>>> SSH into playground'"
    vagrant ssh
) else (
    echo ">>>>> SSH into %1%'"
    vagrant ssh %1% 
)