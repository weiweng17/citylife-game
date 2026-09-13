@echo off
setlocal
rem ---------------------------------------------------------------------------
rem  Sync local main to origin/main. Double-click this file.
rem
rem  Why a separate script: this machine has only a portable Git, and its
rem  credential helpers (git-credential-helper-selector / git-credential-manager)
rem  are shell scripts that need "git" itself on PATH. They also need the
rem  remote helper git-remote-https, which lives in mingw64\bin while git's
rem  exec-path points at mingw64\libexec\git-core. Setting PATH here fixes all
rem  of that. An automated/sandboxed shell replaces PATH, so there it fails.
rem ---------------------------------------------------------------------------
set "GITROOT=C:\Users\86139\.workbuddy\binaries\PortableGit\versions\1.2.0"
set "PATH=%GITROOT%\mingw64\bin;%GITROOT%\mingw64\libexec\git-core;%GITROOT%\usr\bin;%GITROOT%\cmd;%PATH%"
set "GIT_TERMINAL_PROMPT=0"

rem %~dp0 is this script's own folder (tools\); the project root is one level up.
cd /d "%~dp0.."

echo ============================================================
echo  Project: %CD%
echo ============================================================
echo.
echo --- uncommitted changes (should be empty) ---
git status --short
echo.
echo --- pushing local main to origin/main ---
git push origin main
echo.
echo ============================================================
echo  If you see the push summary above, it worked.
echo  GitHub Actions will rebuild and publish the web preview.
echo ============================================================
echo.
pause
