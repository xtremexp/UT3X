# Information
- Description: Unreal Tournament 3 advanced administration mutator.
- Author: Thomas 'XtremeXp/Winter' P.
- Version: 0.7.5 (04/2014)
- Release date (public): 04/03/2018
- Status: **Discontinued**
- Source code and latest documentation: [GitHub -UT3X](https://github.com/xtremexp/UT3X)

---

# Description

UT3X is an Unreal Tournament 3 server mutator that add advanced features to UT3.
It is made of two parts:
* UT3X Mutator that runs client-side
* UT3X Webadmin that runs server-side

UT3X was originally kept internal/private within the former [UT3X.com](http://web.archive.org/web/20071217005257/http://www.ut3x.com:80/forum/index.php) and thelastteam.com community. I've decided to release it public.

 ---
 
## UT3X Mutator  - Client side
This mutator is runned client-side, from player-side. 
It features:
* Advanced scoreboard with
° AFK player highlight color
° Real country flag
* Advanced chat
° Smileys
° Private messaging
° "Sound" chat
* Server adverts

---

## UT3X Webadmin - Server side
This module is runned from server side only and is never downloaded by client (player).
It features global configuration settings for UT3X Mutator
* Embedded team balancer
* Advanced kick ban management
° Temporary / permanent ban
° Customized kick / ban message
° Multi-criteria ban (playername, ip range, hashed cd-key, ...)
* Advanced server logs
° Log type: map change, kickvotes
* AFK players management
* Auto-kick players with bad language
* Auto-kick fake players
---

# Requirements
* Unreal Tournament 3 server
* UT3 player account (for starting UT3 server)
* [UT3 Webadmin module](http://ut3webadmin.elmuerte.com) by Michiel 'El Muerte' Hendricks
---

# Installation

* Install UT3 webadmin module for Unreal Tournament 3 [UT3 Webadmin](http://ut3webadmin.elmuerte.com/#installation)
* Unzip UT3X-vXXX.7z into your UT3 folder

---
# Run UT3X Webadmin on server
In order to make UT3X webadmin run on your server add this to your command line
> ?mutator=UT3X.UT3X

Example:
> ut3.com server VCTF-Suspense?mutator=UT3X.UT3X -login=<UT3_LOGIN> -password=<UT3_PASSWORD>

You can also run it using the provided file (edit it with right settings):
> startUT3XServer.bat

--- 

# Compile UT3X Mutator
* Install UT3X mutator (previous section)
* Change <UT3_PATH> variable to your UT3 folder in buildUT3X.bat file:
> UT3_PATH="C:\Program Files (x86)\Steam\SteamApps\common\Unreal Tournament 3"
* Open <UT3_PATH>\UTGame\Config\UTEditor.ini
* Add line"[ModPackages]" below "[ModPackages]" section and save file.
 > [ModPackages]
 > ModPackages=UT3X
> 
* Open batch window and execute command in UT3 folder:
> buildUT3X.bat build

---

# Compile UT3X Webadmin (no longer works)
* Install UT3X (previous section)
* Open <UT3_PATH>\UTGame\Config\UTEditor.ini
* Add line"[ModPackages]" below "[ModPackages]" section and save file.
 > [ModPackages]
 > ModPackages=UT3XWebAdmin
> 
* Open batch window and execute command in UT3 folder:
> buildUT3X.bat build

Note: UT3X Webadmin compiling no longer works due to some circular dependency issue that started a while ago ...
---