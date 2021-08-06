@echo off

set "FLAG=hibernate"

if "%~1"=="" set "FLAG=stop" 

if %FLAG%==stop (
    echo ">>>>> Shutting Down Playground'"
    vagrant halt --color
) else (
    echo ">>>>> Moving Playground into 'HIBERNATE'"
    vagrant suspend --color
)