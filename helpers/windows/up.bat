@echo off

if "%~1"=="boot" (
    echo ">>>>> Booting Playground'"
    vagrant up --color
) else (
    echo ">>>>> Re-Provision Playground'"
    vagrant provision --color
)