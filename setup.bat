@echo off
setlocal EnableExtensions
cd /d "%~dp0"
chcp 65001 >nul

echo === Codex++ setup (Windows) ===

where pnpm >nul 2>&1
if errorlevel 1 (
  where corepack >nul 2>&1
  if not errorlevel 1 (
    echo pnpm chua co. Bat corepack...
    call corepack enable
    call corepack prepare pnpm@latest --activate
  )
)
where pnpm >nul 2>&1
if errorlevel 1 (
  echo pnpm khong co tren PATH. Cai: npm i -g pnpm  hoac  corepack enable
  echo Can Node.js 22: https://nodejs.org/
  exit /b 1
)

set "PNPM_CUR="
set "PNPM_LATEST="
for /f "delims=" %%i in ('pnpm --version 2^>nul') do set "PNPM_CUR=%%i"
where npm >nul 2>&1
if not errorlevel 1 (
  for /f "delims=" %%i in ('npm view pnpm version 2^>nul') do set "PNPM_LATEST=%%i"
)
if defined PNPM_CUR if defined PNPM_LATEST (
  echo pnpm %PNPM_CUR%  latest %PNPM_LATEST%
  node -e "const c=process.env.PNPM_CUR.split('.').map(Number);const l=process.env.PNPM_LATEST.split('.').map(Number);for(let i=0;i<Math.max(c.length,l.length);i++){const a=c[i]||0,b=l[i]||0;if(b>a)process.exit(0);if(b<a)process.exit(1);}process.exit(1);"
  if not errorlevel 1 (
    echo Updating pnpm %PNPM_CUR% -^> %PNPM_LATEST%
    call pnpm self-update
    if errorlevel 1 (
      where corepack >nul 2>&1
      if not errorlevel 1 call corepack prepare pnpm@latest --activate
    )
    if errorlevel 1 call npm i -g pnpm@latest
    if errorlevel 1 (
      echo pnpm update fail.
      exit /b 1
    )
    for /f "delims=" %%i in ('pnpm --version 2^>nul') do set "PNPM_CUR=%%i"
    echo pnpm now %PNPM_CUR%
  )
)

echo [1/5] pnpm install
pushd apps\codex-plus-manager
call pnpm install --config.onlyBuiltDependencies[]=esbuild
if errorlevel 1 (
  popd
  exit /b 1
)

echo [2/5] tsc check
call pnpm run check
if errorlevel 1 (
  popd
  exit /b 1
)

echo [3/5] pnpm test
set "NODE_OPTIONS=--experimental-strip-types"
call pnpm test
if errorlevel 1 echo WARN: pnpm test fail. Tiep tuc build.
set "NODE_OPTIONS="

echo [4/5] vite:build
call pnpm run vite:build
if errorlevel 1 (
  popd
  exit /b 1
)
popd

if exist "%USERPROFILE%\.cargo\bin\cargo.exe" set "PATH=%USERPROFILE%\.cargo\bin;%PATH%"
where cargo >nul 2>&1
if errorlevel 1 (
  echo cargo khong co tren PATH.
  echo Cai Rust: https://rustup.rs/
  echo Can Visual Studio Build Tools, workload "Desktop development with C++".
  echo Mo lai terminal sau khi cai, roi chay setup.bat lai.
  exit /b 1
)

echo [5/5] cargo test + cargo build --release
cargo test --workspace
if errorlevel 1 exit /b 1
cargo build --release
if errorlevel 1 exit /b 1

echo.
echo Xong.
echo Launcher: target\release\codex-plus-plus.exe
echo Manager:  target\release\codex-plus-plus-manager.exe
echo Chay: start.bat
exit /b 0
