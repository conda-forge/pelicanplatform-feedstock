@echo on

rem -- get build datetime
for /f "tokens=*" %%a in (
'python -c "import datetime; print(datetime.datetime.now(datetime.UTC).strftime('%%Y-%%m-%%dT%%H:%%M:%%SZ'))"'
) do (
set BUILD_DATE=%%a
)

go generate ./...
if errorlevel 1 exit 1

set "CONFIG_PKG=github.com/pelicanplatform/pelican/config"
set "LDFLAGS=-w -s -X %CONFIG_PKG%.version=%PKG_VERSION% -X %CONFIG_PKG%.commit=v%PKG_VERSION% -X %CONFIG_PKG%.date=%BUILD_DATE% -X %CONFIG_PKG%.builtBy=conda-forge"

rem -- run the build
go build ^
  -a ^
  -ldflags "%LDFLAGS%" ^
  -tags forceposix ^
  -p "%CPU_COUNT%" ^
  -v ^
  -o "%LIBRARY_BIN%\pelican.exe" ^
  .\cmd
if errorlevel 1 exit 1

rem -- generate the license pack
go get ./...
go-licenses save .\cmd --save_path license-files --ignore "modernc.org/mathutil"
if errorlevel 1 exit 1
