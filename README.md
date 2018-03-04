
UT3X mutator Readme file
------------------------------

- Version: 0.7.5 pre-release
- Release date (public): 04/03/2018
- Author: Thomas 'XtremeXp/Winter' P.
- Source Code: https://github.com/xtremexp/UT3X


Description
------------------------------
UT3X is an Unreal Tournament 3 server mutator that add advanced features to UT3 like:
* Advanced ban feature
* Advanced afk players management
* Detailled player logs
* Auto-kick players swearing
* Server adverts
* Player sounds

This mutator was originally kept internal/private within the former UT3X.com and thelastteam.com community.
I've decided to release it public.

Installation
------------------------------
Install UT3 webadmin module for Unreal Tournament 3 (http://ut3webadmin.elmuerte.com/#installation)
Clone repository to folder of your choice
Copy UT3X/ content into your UT3 folder
Open buildUT3X.bat with a text editor
Change <UT3_PATH> variable to your UT3 folder and save file. (e.g: UT3_PATH="C:\Program Files (x86)\Steam\SteamApps\common\Unreal Tournament 3")

Compile
------------------------------
Install UT3X mutator (previous section)
Open <UT3_PATH>\UTGame\Config\UTEditor.ini with a text editor
Below "[ModPackages] section" add line "ModPackages=UT3X" and save file.
Open batch window and execute command "buildUT3X.bat build"