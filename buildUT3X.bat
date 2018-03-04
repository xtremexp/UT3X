:: SET THE UT3 FOLDER HERE !
SET UT3PATH=Z:\Games\UT3

:: Version used for packaging UT3X
SET RELEASEVERSION=175
SET RELEASEPASSWORD=somepassword
SET ZPATH=C:\Program Files\7-Zip\7z.exe

SET RELEASEFOLDER=UT3Xv%RELEASEVERSION%
SET UT3GAMEPATH=%UT3PATH%\UTGame
SET UT3WEBPATH=%UT3PATH%\Web
SET UT3CONFIGPATH=%UT3GAMEPATH%\Config
SET SRCPATH=%UT3GAMEPATH%\Src
SET COOKEDPCPATH=%UT3GAMEPATH%\CookedPC
SET UT3BINPATH=%UT3PATH%\Binaries
SET SCRIPTUPPATH=%UT3GAMEPATH%\Unpublished\CookedPC\Script


:: files generated/used for UT3X
SET UT3XFILE=UT3X.u
SET UT3XUZ3FILE=UT3X.u.uz3
SET UT3XWEBADMINFILE=UT3XWebAdmin.u
SET UT3XWEBADMINUZ3FILE=UT3XWebAdmin.u.uz3
SET UT3XCONTENT=UT3XContentV3.upk

:: IP to country database
SET IP2COUNTRYINI=UTUT3XCountries.ini

if %1 EQU release goto :cleaninis else goto :build

:: TODO MOVE TO SOME TEMP FOLDER AND PUT THEM BACK
:cleaninis
del %UT3CONFIGPATH%\UTUT3X.ini
del %UT3CONFIGPATH%\UTUT3XConfig.ini
del %UT3CONFIGPATH%\UTUT3XLog.ini
del %UT3CONFIGPATH%\UTUT3XPlayersDB.ini
del %UT3CONFIGPATH%\UTUT3XCountries.ini
goto :build


:build
:: WE COPY ALL FILES TO UT3 FOLDER
xcopy /S /y UTGame "%UT3GAMEPATH%"
xcopy /S /y Web "%UT3WEBPATH%"

del "%COOKEDPCPATH%\%UT3XFILE%"
del "%SCRIPTUPPATH%\%UT3XFILE%"

del "%UT3BINPATH%\%UT3XFILE%"
cd %UT3BINPATH%

:: Move the ip to country database to some other folder
:: so generated UT3X.u file won t have it embedded (would means large size)
:: <UT3Folder>\UTGame\Config\UTUT3XCountries.ini -> <UT3Folder>\Binaries\UT3XCountries.ini
move "%UT3CONFIGPATH%\%IP2COUNTRYINI%" "%UT3BINPATH%"


:: Compile UT3X, UT3XWebAdmin and so on
:: Binaries are created in folder:
:: <UT3Folder>\UTGame\Unpublished\CookedPC\Script
echo "Compiling"
ut3.com make -nohomedir


:: <UT3Folder>\UTGame\Unpublished\CookedPC\Script\UT3X.u -> <UT3Folder>\Binaries\UT3X.u
copy "%SCRIPTUPPATH%\%UT3XFILE%" "%UT3BINPATH%"
::move "%SCRIPTUPPATH%\%UT3XWEBADMINFILE%" "%UT3BINPATH%"

:: Todo in some near future merge UT3XContentVx into UT3X.u
::echo "MERGING"
::ut3.com mergepackages UT3XContent.upk %UT3XFILE%.u -nohomedir

if %1 EQU release goto :stripsource

:: put back utut3xcountries.ini file
move "%UT3BINPATH%\%IP2COUNTRYINI%" "%UT3CONFIGPATH%"

:: Move binaries to CookedPC folder so we can test them 
:: without using the -unpublished parameter in ut3 server 
echo "Moving binaries to CookedPC folder"

:: <UT3Folder>\Binaries\UT3X.u -> <UT3Folder>\UTGame\CookedPC\UT3X.u
copy "%UT3BINPATH%\%UT3XFILE%" "%COOKEDPCPATH%"

:: <UT3Folder>\Binaries\UT3XWebAdmin.u -> <UT3Folder>\UTGame\CookedPC\UT3XWebAdmin.u
copy "%UT3BINPATH%\%UT3XWEBADMINFILE%" "%COOKEDPCPATH%"

echo All done! Press any key to exit!
pause
exit

:stripsource
:: Remove human readable code from UT3X.u
:: can be disabled if private server 
echo "Strip Source UT3X"
ut3.com stripsource %UT3XFILE% -nohomedir
ut3.com stripsource %UT3XWEBADMINFILE% -nohomedir

if %1 EQU release goto :compress

:compress
echo "Compress UT3X"
ut3.com compress %UT3XFILE% -nohomedir
ut3.com compress %UT3XWEBADMINFILE% -nohomedir
if %1 EQU release goto :copyfilesandzip

:copyfilesandzip
:: Cleaning all .inis
mkdir %RELEASEFOLDER%

SET FULLRELEASEFOLDER=%UT3BINPATH%\%RELEASEFOLDER%

copy "%UT3BINPATH%\%UT3XUZ3FILE%" "%FULLRELEASEFOLDER%"
copy "%UT3BINPATH%\%UT3XCONTENTFILE%.uz3" "%FULLRELEASEFOLDER%"
copy "%UT3BINPATH%\%UT3XWEBADMINFILE%" "%FULLRELEASEFOLDER%\UTGame\CookedPC"
copy "%UT3BINPATH%\%UT3XFILE%" "%FULLRELEASEFOLDER%\UTGame\CookedPC"
copy "%UT3BINPATH%\%UT3XCONTENTFILE%" "%FULLRELEASEFOLDER%\UTGame\CookedPC"

copy "%UT3WEBPATH%\ServerAdmin\UT3X*.*" "%RELEASEFOLDER%\Web\ServerAdmin\"

echo "Adding to archive ..."
del "%UT3PATH%\UT3X*.7z"
"%ZPATH%\7z.exe" a "%RELEASEFOLDER%.7z" "%FULLRELEASEFOLDER%" -p%RELEASEPASSWORD%

echo "Zip file ready!"
pause

