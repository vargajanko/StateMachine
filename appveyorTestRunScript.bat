SETLOCAL EnableDelayedExpansion

rem Disable launching the JIT debugger for ctest.exe
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug\AutoExclusionList" /v "ctest.ext" /t REG_DWORD /d 1
if "%CONFIGURATION%"=="Debug" (
  if "%coverage%"=="1" (
    ctest -j 2 -C %CONFIGURATION% -D ExperimentalMemCheck || exit /b !ERRORLEVEL!
    python ..\tools\misc\appveyorMergeCoverageScript.py || exit /b !ERRORLEVEL!
    codecov --root .. --no-color --disable gcov -f cobertura.xml -t %CODECOV_TOKEN% || exit /b !ERRORLEVEL!
  ) else (
    .\x64\Debug\TESTS.exe -r Junit >> test.xml
  )
)
if "%CONFIGURATION%"=="Release" (
  ctest -j 2 -C %CONFIGURATION% || exit /b !ERRORLEVEL!
)