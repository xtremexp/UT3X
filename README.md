# UT3X information
- Description: Unreal Tournament 3 advanced administration mutator.
- Author: Thomas 'XtremeXp/Winter' P.
- Version: 0.7.5 (04/2014)
- Release date (public): 04/03/2018
- Status: **Discontinued**
- Source Code: [GitHub -UT3X](https://github.com/xtremexp/UT3X)

---

# Description
UT3X is an Unreal Tournament 3 server mutator that add advanced features to UT3 like:
* Advanced ban feature
* Advanced afk players management
* Detailled player logs
* Auto-kick players swearing
* Server adverts
* Smileys in chat for players.
* Specific text to sound for players.

This mutator was originally kept internal/private within the former [UT3X.com](http://web.archive.org/web/20071217005257/http://www.ut3x.com:80/forum/index.php) and thelastteam.com community.
I've decided to release it public.

---

# Installation

* Install UT3 webadmin module for Unreal Tournament 3 [UT3 Webadmin](http://ut3webadmin.elmuerte.com/#installation)
* Clone repository to folder of your choice
* Copy UT3X/ content into your UT3 folder
* Change <UT3_PATH> variable to your UT3 folder in buildUT3X.bat file:
> UT3_PATH="C:\Program Files (x86)\Steam\SteamApps\common\Unreal Tournament 3"


--- 

# Compile
* Install UT3X mutator (previous section)
* Open <UT3_PATH>\UTGame\Config\UTEditor.ini with a text editor
* Below "[ModPackages] section" add line "ModPackages=UT3X" and save file.
 > [ModPackages]
 > ModPackages=UT3X
> 
* Open batch window and execute command "buildUT3X.bat build"

---