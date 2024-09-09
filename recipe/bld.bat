@echo on

rem -- get build datetime
for /f "tokens=*" %%a in (
'python -c "import datetime; print(datetime.datetime.now(datetime.UTC).strftime('%%Y-%%m-%%dT%%H:%%M:%%SZ'))"'
) do (
set BUILDDATE=%%a
)

go generate ./...
if errorlevel 1 exit 1

rem -- run the build
go build ^
  -a ^
  -ldflags "-w -s -X main.version=%PKG_VERSION% -X main.commit=v%PKG_VERSION% -X main.date=%BUILD_DATE% -X main.builtBy=conda-forge" ^
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
