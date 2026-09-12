@echo off
set "CITYLIFE_GODOT=F:\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%CITYLIFE_GODOT%" (
  echo Godot executable not found. Update CITYLIFE_GODOT in this launcher.
  pause
  exit /b 1
)
"%CITYLIFE_GODOT%" --path "%~dp0.." --rendering-method gl_compatibility
