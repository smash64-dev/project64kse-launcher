:: build.bat
:: compiles project64kse-launcher using ahk2exe.exe
:: you may have to whitelist with antivirus to build this

@ECHO OFF
ECHO Building project64kse-launcher...

IF EXIST "%ProgramFiles%\AutoHotkey\Compiler\Ahk2Exe.exe" (
    SET "AHK=%ProgramFiles%\AutoHotkey\Compiler\Ahk2Exe.exe"
) ELSE (
    IF EXIST "%ProgramFiles(x86)%\AutoHotkey\Compiler\Ahk2Exe.exe" (
        SET "AHK=%ProgramFiles(x86)%\AutoHotkey\Compiler\Ahk2Exe.exe"
    ) ELSE (
        ECHO - Unable to find Ahk2Exe.exe, please install AutoHotkey first (https://www.autohotkey.com/)
        EXIT 1
    )
)

if EXIST "build" (
    ECHO - Cleaning build environment...
    RMDIR /S /Q "build" >nul
)
MKDIR "build"

ECHO - Building to 'build' directory...
"%AHK%" /in "src\launcher.ahk" /out "build\kse-launcher.exe" /icon "res\icon.ico" /cp 65001

ECHO - Finshed
EXIT 0
