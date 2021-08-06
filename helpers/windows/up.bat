@echo off

set "FLAG=provision"

if "%~1"=="" set "FLAG=boot" 

if %FLAG%==boot (
    echo ">>>>> Booting Playground'"
    vagrant up --color
) else (
    echo ">>>>> Re-Provision Playground'"
    vagrant provision --color
)