:: Script to start an UT3 server

:: These values need to be changed!
SET UT3PATH=Z:\Games\UT3
SET UT3LOGIN=UT3_LOGIN
SET UT3PASSWORD=UT3_PASSWORD

:: Optional other changes
SET QUERYPORT=6500
SET GAMEPORT=7777

:: We clean the logs and demos
del /Q "%UT3PATH%\UTGame\Logs\*.*"
del /Q "%UT3PATH%\UTGame\Demos\*.*"

cd %UT3PATH%\Binaries

:: let's start the server !
ut3.com server VCTF-Suspense?mutator=UT3X.UT3X?GoalScore=1?MinNetPlayers=1?MaxPlayers=6?numplay=0?TimeLimit=10?bIsDedicated=True?bShouldAdvertise=False -unattended -nohomedir -login=%UT3LOGIN% -password=%UT3PASSWORD%  -queryport=%QUERYPORT% -log=server.log -port=%GAMEPORT%
