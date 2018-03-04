# UT3X
UT3X mutator and webadmin

#Installation
Install UT3 webadmin module for Unreal Tournament 3 (http://ut3webadmin.elmuerte.com/#installation)
Clone repository to folder of your choice
Copy UT3X/ content into your UT3 folder
Open buildUT3X.bat with a text editor
Change <UT3_PATH> variable to your UT3 folder and save file. (e.g: UT3_PATH="C:\Program Files (x86)\Steam\SteamApps\common\Unreal Tournament 3")

#Compile
Install UT3X mutator (previous section)
Open <UT3_PATH>\UTGame\Config\UTEditor.ini with a text editor
Below "[ModPackages] section" add line "ModPackages=UT3X" and save file.
Open batch window and execute command "buildUT3X.bat build"