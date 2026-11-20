@echo off
REM ============================================================================
REM QUICK GUI / WINDOW LAUNCHER NEOVIM (C:\_neovim)
REM ============================================================================
set "PATH=C:\_neovim\bin;C:\msys64\ucrt64\bin;%PATH%"
if exist "C:\_neovim\bin\nvim-qt.exe" (
  start "" "C:\_neovim\bin\nvim-qt.exe" %*
) else (
  start "Neovim IDE - Muhammad Bintang" powershell -NoExit -Command "C:\_neovim\bin\nvim.exe %*"
)
