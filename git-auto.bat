@echo off
REM Git Automation Batch File
REM Usage: git-auto.bat [operation] [options]

if "%1"=="" (
    echo.
    echo 🤖 Git Automation Commands:
    echo.
    echo   git-auto.bat sync [message]     - Sync repository (pull, commit, push)
    echo   git-auto.bat commit [message]   - Commit changes
    echo   git-auto.bat pull              - Pull latest changes
    echo   git-auto.bat merge [source]    - Merge branch
    echo   git-auto.bat status            - Show repository status
    echo   git-auto.bat all [message]     - Run full automation sequence
    echo.
    echo Options:
    echo   --push                         - Push after commit
    echo   --force                        - Force operations
    echo   --rebase                       - Use rebase for pull (default)
    echo   --no-rebase                    - Use merge for pull
    echo.
    echo Examples:
    echo   git-auto.bat sync "Update feature"
    echo   git-auto.bat commit "Fix bug" --push
    echo   git-auto.bat all "Daily sync"
    echo.
    exit /b 1
)

set OPERATION=%1
shift

set ARGS=
set COMMIT_MESSAGE=

:parse_args
if "%1"=="" goto :run
if "%1"=="--push" (
    set ARGS=%ARGS% -Push
    shift
    goto :parse_args
)
if "%1"=="--force" (
    set ARGS=%ARGS% -Force
    shift
    goto :parse_args
)
if "%1"=="--rebase" (
    set ARGS=%ARGS% -Rebase
    shift
    goto :parse_args
)
if "%1"=="--no-rebase" (
    set ARGS=%ARGS% -Rebase:$false
    shift
    goto :parse_args
)
if "%1"=="--verbose" (
    set ARGS=%ARGS% -Verbose
    shift
    goto :parse_args
)

REM If not a flag, treat as commit message
if "%COMMIT_MESSAGE%"=="" (
    set COMMIT_MESSAGE=%1
) else (
    set COMMIT_MESSAGE=%COMMIT_MESSAGE% %1
)
shift
goto :parse_args

:run
if not "%COMMIT_MESSAGE%"=="" (
    set ARGS=%ARGS% -CommitMessage "%COMMIT_MESSAGE%"
)

powershell -ExecutionPolicy Bypass -File "scripts\git-automation.ps1" -Operation %OPERATION% %ARGS%
