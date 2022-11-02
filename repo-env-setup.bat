@echo off

set ORIGIN=%cd%

echo [92mPART 1: SET UP REPOSITORY...[0m
set /p ROOT=Enter full path to root folder: 
set /p URL=Enter repo URL or template type (n=new, c=cookiecutter): 

if "%url%"=="n" goto initNew
if "%url%"=="c" goto initCC

:: init from URL
echo [92mCreating repository from URL...[0m
set REPO=none
set /p REPO=Enter local repo name (leave empty if same name):
cd "%ROOT%"
if "%REPO%"=="none" (
	git clone %URL%
	:: get repo name from URL (last part without .git)
	FOR /F "delims=|" %%A IN ("%URL%") DO (
	    set URLREPO=%%~nxA
	)
	set REPO=%URLREPO:~0,-4%
) else (
	git clone %URL% "%REPO%"
)
goto commonexitrepo

:initNew
echo [92mCreating new repository...[0m
set /p REPO=Enter new repo name:
mkdir "%ROOT%\%REPO%"
copy requirements.txt "%ROOT%\%REPO%"\requirements.txt
cd "%ROOT%\%REPO%"
git init
mkdir data outputs data\raw data\processed notebooks
echo /data >> .gitignore
echo /outputs >> .gitignore
echo /.venv >> .gitignore
echo /__pycache__ >> .gitignore
git add .
git commit -m "Initialized project"
cd ..
goto commonexitrepo

:initCC
echo [92mCreating repository from template...[0m
cd "%ROOT%"
cookiecutter https://github.com/khuyentran1401/data-science-template
goto commonexitrepo

:commonexitrepo
echo [92mPART 2: SET UP ENVIRONMENT...[0m
:: goto instead of if else because of errors
if "%URL%"=="c" goto chooseCC else goto chooseNonCC

:chooseNonCC
set /p ENVTYPE=Create virtual/conda environment or none? (v=virtual, c=conda, n=none):
if %ENVTYPE%==v goto envVirtual
if %ENVTYPE%==c goto envConda
goto installEnv

:chooseCC
set /p ENVTYPE=Create conda environment or none? (conda/none):
if %ENVTYPE%==c goto envConda

:installEnv
:: no installation
goto commonexit

:envVirtual
cd "%ROOT%\%REPO%"
echo [92mCreating and activating virtual environment .venv for in %ROOT%\%REPO%...[0m
python -m venv .venv
call .venv\Scripts\activate.bat
if "%URL%"=="c" (goto commonexit) else (goto installRequirements)

:envConda
set /p PYTHON_VERSION=Enter Python version (e.g. 3.8):
set /p ENV_NAME=Enter environment name (e.g. "myenv"):
echo [92mCreating and activating conda environment %ENV_NAME% for python %PYTHON_VERSION%...[0m
call conda create --name %ENV_NAME% python=%PYTHON_VERSION%
call conda activate %ENV_NAME%
goto installRequirements

:installRequirements
cd "%ROOT%\%REPO%"
if exist requirements.txt (
	echo [92mInstall package versions from requirements.txt inside environment %ENV_NAME%...[0m
	pip install -r requirements.txt
) else (
	echo. >> .gitignore
	echo [92mNo additional packages installed; added empty requirements.txt...[0m
)

:commonexit
cd %ORIGIN%
echo [92mDone![0m
pause