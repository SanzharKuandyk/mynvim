@echo off
rem Compatibility for oil.nvim's: wmic logicaldisk get name
if /I "%~1 %~2 %~3"=="logicaldisk get name" (
    echo Name
    powershell.exe -NoLogo -NoProfile -NonInteractive -Command "[IO.DriveInfo]::GetDrives() | ForEach-Object { $_.Name.TrimEnd('\') }"
    exit /b
)

echo This WMIC compatibility shim only supports: logicaldisk get name 1>&2
exit /b 1
