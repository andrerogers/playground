@echo off

if "%~1"=="stop" (
    echo ">>>>> Shutting Down Playground'"
    vagrant halt --color
) else (
    echo ">>>>> Moving Playground into 'HIBERNATE'"
    vagrant suspend --color
)