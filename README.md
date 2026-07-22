![](https://badgen.net/github/release/jacklandrin/onlyswitch) ![](https://img.shields.io/badge/UI-SwiftUI-green)
[![Listed on TakoAPI](https://takoapi.com/api/badge/jacklandrin-onlyswitch)](https://takoapi.com/agents/jacklandrin-onlyswitch)
![](https://img.shields.io/badge/Platform-Tahoe-blue)
  ![](https://img.shields.io/badge/License-MIT-orange)
<p align="middle">
    <a href="https://onlyswitch.click">
        <img alt="AppIcon" src="https://github.com/jacklandrin/OnlySwitch/blob/main/OnlySwitch/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png?raw=true" width="128px" align="center" />
    </a>
</p>

‼️ **Auto-updating has failed from 2.5.6 and below, please manually update or use Homebrew.**

# OnlySwitch

[English](README.md) | [简体中文](README.zh-CN.md)

***Menubar is smaller, you only need an All-in-One switch.***

## Install by Homebrew

```
brew install only-switch
```
## Manually Download
[**Download the app**](https://github.com/jacklandrin/OnlySwitch/releases/latest/download/OnlySwitch.dmg)

## Communities
Telegram group: https://t.me/OnlySwitchforMac

Discord: https://discord.gg/UzSNpYdPZj

## What's the OnlySwitch?
OnlySwitch provides a series of toggle switches to simplify your routine work, such as Hidden desktop icons, dark mode, and hide notch of the new Macbook Pro. The switches show on your status bar, you can control them effortlessly. Switch and Shortcuts items can be customized (remove/add or sort) to show on the list. These functionalities even can be put on your desktop as Widgets.

Since Version 1.7, **Shortcuts** can be imported into OnlySwitch.

Since Version 2.0, supports **keyboard shortcuts**. You can control your all switches and Shortcuts with the keyboard.

<p align="center">
<img alt="Only Switch" src="https://github.com/user-attachments/assets/40d94175-6487-4c59-b09e-2261ac5b8453" width="80%" align="center" />
</p>

Since Version 2.3.6, the Switches Availability (including Player and Hide Menu Bar Icons) is moved to System's menu bar.

![](https://github.com/jacklandrin/OnlySwitch/assets/3782279/11c89e33-2007-4913-b320-47c188538b68)

Since Version 2.5.0, OnlySwitch has started to support **Apple Widgets** (Sonoma and above).

Since Version 2.5.4, OnlySwitch has Only Control appearance.

Since Version 2.7.0, OnlySwitch includes an optional **Desktop Pet**: a small, always-on-top desktop companion. Enable it in General settings, drag it anywhere on screen, and click it to show or dismiss Only Control.
<img width="193" height="150" alt="desktop pet" src="https://github.com/user-attachments/assets/1c5dd631-b163-4ec2-a289-65890282a81c" />


## Shortcuts Gallery

Everyone can contribute macOS Shortcuts for OnlySwitch now. Please read [How to contribute to Shortcuts Gallery](ShortcutsGalleryContributing.md). The shared Shortcuts will be displayed here:

<p align="center">
<img alt="Sits in the status bar" src="https://github.com/jacklandrin/OnlySwitch/assets/3782279/a9d90eed-c540-4183-9332-396dce0f72d4" width="70%" align="center" />
</p>

## Switch list

#### Native Switches:

| Switch              | status          | Switch                   | status            |
|:--------------------|-----------------|:-------------------------|:------------------|
| Hide desktop        | finished        | Hide notch               | exist some issues |
| Dark mode           | finished        | Low power mode           | require password  |
| Screen Saver        | finished        | Show Finder Path Bar     | finished          |
| Night Shift         | finished        | Mute mic                 | finished          |
| Autohide Dock       | finished        | Small launchpad icon     | finished          |
| Airpods             | finished        | Pomodoro timer           | finished          |
| Bluetooth           | finished        | Show extension name      | finished          |
| Xcode cache         | finished        | Show user library folder | finished          |
| Autohide Menu Bar   | finished        | Mute                     | finished          |
| Show hidden files   | finished        | Empty pasteboard         | finished          |
| Empty trash          | finished        |                          |                   |
| Keep awake          | finished        | Show Recent Apps on Dock | finished          |
| Spotify             | finished        | Apple Music              | finished          |
| Screen Test & Clean | finished        | Hide Menu Bar Icons      | partly finished   |
| FKey                | finished        |                          |                   |
| Dim Screen          | finished        | Eject Discs              | finished          |
| Hide Windows        | partly finished | True Tone                | finished          |
| Top Sticker         | partly finished | Key Light                | finished          |
| Authenticator       | finished        |                          |                   |

Since Version 1.3, switches can be added to or removed from the list.

#### Shortcuts Gallery:

| Shortcuts                        | Remark                                          | Shortcuts                        | Remark  |
|----------------------------------|-------------------------------------------------|----------------------------------|:--------|
| Toggle Scroll Direction          | Monteray                                        | Invert Scroll Direction(Ventura) | Ventura |
| DarkMode Switch                  |                                                 | Network Details                  |         |
| Split-Screen Apps                |                                                 | Passwords                        |         |
| Google Translate                 |                                                 | IP Address Information           |         |
| Autohide menu bar in full screen | Monteray                                        | Flush DNS Cache                  |         |
| Do Not Disturb                   | Monteray or higher                              | Upcoming Events                  |         |
| S-GPT                            | works with S-GPT Encoder, needs OpenAI API key  | S-GPT Encoder                    |         |

## Shortcuts Actions

| Actions             | status            |
|---------------------|-------------------|
| Get wallpaper image | exist some issues |
| Get wallpaper url   | finished          |
| Is dark mode        | finished          |
| Set dark mode       | finished          |

## Supported Languages 🇺🇳
English, Simplified Chinese, German, Croatian, Turkish, Polish, Filipino, Dutch, Italian, Russian, Spanish, Japanese, Somali, Korean, French, Ukrainian, Slovak, Portuguese (BR), Czech

## Welcome to pull requests for these

* support other languages
* fix bugs

If you have other good ideas 💡, feel free to send an E-mail to me.

## Donate
If you like it, help support this app by giving me a cup of coffee to keep coding. [Donate here](https://www.paypal.com/donate/?hosted_button_id=V3NDUXWZ6GVYG)

### OpenClaw (natural language)

You can also control OnlySwitch by **natural language** using [OpenClaw](https://openclaw.ai/). An OpenClaw-compatible skill is included in this repo: say things like *"empty trash"*, *"toggle keep awake"*, or *"turn on dark mode"* and OpenClaw will trigger the matching switch via deeplink. See [OpenClaw/README.md](OpenClaw/README.md) for setup (extra skill directory or copy into `~/.openclaw/skills`).

## Only Widget

Only Switch supports Apple Widgets since version 2.5.0. The Widgets can be edited to any built-in switches and buttons. Clicking them will trigger the reflection of relevant switches and buttons. You can put Only Widgets anywhere, desktop or notification center.

**NOTE:** After updating version 2.5.0, you might need to reset your language. If your widgets didn't follow your language settings, please kill Only Widget process, it will update.

<img width="370" alt="Only Widget" src="https://github.com/jacklandrin/OnlySwitch/assets/3782279/0c1be202-9e5f-41dd-b62d-52d5a7147139">

## AirPods Switch 
I use `classOfDevice`(2360344) to check if a Bluetooth device is Airpods Pro, but I'm not sure whether other AirPods modules are also 2360344, since I only have two AirPods Pros. If you are using AirPods 1~3, please tell me what the `classOfDevice` is. Or I can detect the count of battery value to check if AirPods (when the count is 3, it's AirPods), like **AirPods Battery Monitor For MAC OS**.

## Hiding new Macbook Notch 

The Hide notch switch only shows on the built-in display of M1 Pro/Max Macbook Pro. The switch just controls the current desktop, not all work desktops.
Now, the Hide notch switch supports dynamic wallpaper, just the processing takes a much longer time.
<p align="center">
<img alt="Sits in the status bar" src="https://github.com/jacklandrin/OnlySwitch/assets/3782279/efddd8d3-edfe-4497-bea0-5051d27625ca" width="60%" align="center" />
</p>


## Low Power Mode
Low Power Mode uses Terminal commands that require root access, so the app will ask you to enter the password on every toggle.

## Screen Test & Clean
In Version 2.3, Only Switch brings a new feature, Screen Test. It provides a pure color view in full-screen mode, you can check dead pixels via it. Press the left and right arrow keys, the color will change from black, white, red, green, and blue. This functionality also can be used for screen cleaning, as you can see the stains on the screen.

## Hide Menu Bar Icons
This feature is new in version 2.3.2. To be honest, Hidden and Dozer are both good apps for this function. Many users install OnlySwitch and them simultaneously, but this also squeezes the menu bar, which is already lacking in space. Therefore, the feature integrates into OnlySwitch.
![](https://github.com/jacklandrin/OnlySwitch/assets/3782279/fdda284e-929f-400e-aba5-9c628f065de6)
When the switch is on, items on the left of the split(arrow-pointing) icon are hidden. Hold ⌘ (command) and drag the icon to configure the hidden section. If you want to use it no longer, you can disable it in preferences, the split icon will disappear. You also can set the interval of autohide for it here. If your date on the menu bar is truncated when it's on, you can set this: System Preferences -> Dock & Menu Bar -> Clock -> Show date -> always.

Since version 2.3.10, this switch can be controlled via right-click icons.

## They talk about it

|                                                                                                                                 |                                                                                                                                            |                                                                                                                                  |                                                                                                                        |
|---------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------|
| [itopnews.de](https://www.itopnews.de/?s=OnlySwitch)                                                                            | [Ifun.de](https://www.ifun.de/suche/OnlySwitch)                                                                                            | [appgefahren.de](https://www.appgefahren.de/onlyswitch-kleines-tool-mit-wichtigen-aktionen-fuer-die-mac-menueleiste-312135.html) | [CASCHYS BLOG](https://stadt-bremerhaven.de/only-switch-fuer-macos-schnellzugriff-auf-einige-systemoptionen/)          |
| [softpedia](https://mac.softpedia.com/get/System-Utilities/OnlySwitch.shtml)                                                    | [macupdate](https://www.macupdate.com/app/mac/63719/onlyswitch)                                                                            | [v1tx](https://www.v1tx.com/post/onlyswitch/)                                                                                    | [OSCHINA](https://www.oschina.net/p/onlyswitch)                                                                        |
| [Macken](https://www.macken.xyz/2021/12/gratis-ar-gott-alla-installningar-pa-ett-stalle-onlyswitch/)                            | [AAPL Ch](https://applech2.com/archives/20220111-onlyswitch-all-in-one-status-bar-button-for-mac.html)                                     | [appsofter](https://appsofter.com/download/1265.html)                                                                            | [lifehacker.ru](https://lifehacker.ru/onlyswitch)                                                                      |
| [appletechnikblog](https://appletechnikblog.com/de/2022/02/25/app-tipp-der-woche-only-switch-fuer-die-menueleiste-auf-dem-mac/) | [All-in-One person](https://en.blog.themarfa.name/how-to-quickly-manage-macos-system-settings/)                                            | [Mac Gadget](https://www.macgadget.de/News/2022/03/24/OnlySwitch-Schnellzugriff-auf-viele-Systemfunktionen-per-Mac-Menueleiste)  | [MaxiApple](https://www.maxiapple.com/2022/05/onlyswitch-macos-mac-gratuit.html)                                       |
| [insmac](https://insmac.org/macosx/5018-onlyswitch.html)                                                                        | [tchgdns](https://tchgdns.de/onlyswitch-macos-open-source/)                                                                                | [insmac](https://insmac.org/macosx/5018-onlyswitch.html)                                                                         | [macbff](https://macbff.com/onlyswitch-2-3-1/)                                                                         |
| [korben](https://korben.info/controler-macos-onlyswitch.html)                                                                   | [macg](https://www.macg.co/logiciels/2023/03/onlyswitch-ajoute-une-pelletee-de-raccourcis-pratiques-votre-barre-des-menus-135357)          | [korben.info](https://korben.info/controler-macos-onlyswitch.html)                                                               | [AlternativeTo](https://alternativeto.net/software/only-switch)                                                        |
| [macsoft.jp](https://macsoft.jp/onlyswitch/)                                                                                    | [macgeneration](https://www.macg.co/logiciels/2023/03/onlyswitch-ajoute-une-pelletee-de-raccourcis-pratiques-votre-barre-des-menus-135357) | [hdwh.de](https://hdwh.de/onlyswitch-vereinfacht-eure-routinearbeit-mit-praktischen-schaltern/)                                  | [MacKed](https://macked.app/onlyswitch.html)                                                                           |
| [Mac Torrents](https://www.tntmactorrent.net/onlyswitch-for-mac-free-download/)                                                 | [PCtipp](https://www.pctipp.ch/praxis/mac/mac-tipp-onlyswitch-2-2892320.html)                                                              | [lifehacker](https://lifehacker.com/tech/change-hidden-mac-settings-with-onlyswitch)                                             | [PHAPLUAT](https://kynguyenso.plo.vn/su-dung-onlyswitch-de-tuy-chinh-tat-ca-cai-dat-may-mac-nhanh-hon-post776151.html) |
| [Techgedöns](https://tchgdns.de/onlyswitch-menueleisten-multitool-bekommt-widgets-fuer-den-mac-desktop/)                        | [MacVince](https://www.youtube.com/watch?v=ARfBLKzRQY4&t=41s)                                                                              |  [onmymenubar](https://onmymenubar.app/onlyswitch/)                                                                                                                                |                                                                                                                        |


## Reference

* NightShift switch refers to [Nocturnal](https://github.com/joshjon/nocturnal)
* [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin)
* AirPods Battery refers to [AirPods Battery Monitor For MAC OS](https://github.com/mohamed-arradi/AirpodsBattery-Monitor-For-Mac)
* Dynamic Wallpaper processing refer to https://itnext.io/macos-mojave-dynamic-wallpaper-fd26b0698223 and [wallpapper](https://github.com/mczachurski/wallpapper)
* [AlertToast](https://github.com/elai950/AlertToast)
* [Alamofire](https://github.com/Alamofire/Alamofire)
* Sound Source: [mixkit](https://mixkit.co) and [pixabay](https://pixabay.com)
* [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)
* Apple Music & Spotify Switch refer to [SpotMenu](https://github.com/kmikiy/SpotMenu)
* The idea of hiding menu bar icons from [Hidden](https://github.com/dwarvesf/hidden)
* FKey refer to [Fluor](https://github.com/Pyroh/Fluor)
* Hide Windows refer to [Later](https://github.com/alyssaxuu/later)
* [The composable architecture](https://github.com/pointfreeco/swift-composable-architecture)
* [Sparkle](https://github.com/sparkle-project/Sparkle)
* True Tone refers to [Shifty](https://github.com/thompsonate/Shifty)
* [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui)
* Key Light refers to [mac-brightnessctl](https://github.com/rakalex/mac-brightnessctl)
## Contributors

**Translation:**

| Language | Contributor              | Language        | Contributor    |
|----------|--------------------------|:----------------|:---------------|
| German   | @C0d3Br3aker             | Italian         | @bellaposa     |
| Croatian | @milotype                | Russian         | @kirillyakopov |
| Turkish  | @berkbatuhans            | Spanish         | @kant          |
| Polish   | @kpacholak               | Japanese        | @ShogoKoyama   |
| Dutch    | Alex                     | Somali          | @abdorizak     |
| Filipino | Rosel                    | Korean          | @iosdevted     |
| French   | @BtKent and Ange Lefrère | Ukrainian       | @andryua       |
| Slovak   | @Svec-Tomas              | Portuguese (BR) | @EvertonCa     |
| Czech    | @ForksApps               |                 |                |

@kant for syntax issue 

@Ryderwe for Authenticator

@lou1s19 for dim mode for the external monitor


## License
MIT

## Star History
[![Star History Chart](https://api.star-history.com/svg?repos=jacklandrin/OnlySwitch&type=Date)](https://star-history.com/#jacklandrin/OnlySwitch&Date)
