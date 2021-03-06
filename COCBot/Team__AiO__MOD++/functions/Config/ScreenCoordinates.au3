; #Variables# ====================================================================================================================
; Name ..........: Screen Position Variables
; Description ...: Global variables for commonly used X|Y positions, screen check color, and tolerance
; Syntax ........: $aXXXXX[Y]  : XXXX is name of point or item being checked, Y = 2 for position only, or 4 when color/tolerance value included
; Author ........:
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

;Clan Hop
Global $aJoinClanBtn[4] = [157, 510, 0x6CBB1F, 20] ; Green Join Button on Chat Tab when you are not in a Clan
Global $aClanPage[4] = [725, 410, 0xEF5D5F, 20] ; Red Leave Clan Button on Clan Page
Global $aClanPageJoin[4] = [720, 407, 0xBCE764, 20] ; Green Join Clan Button on Clan Page
Global $aJoinClanPage[4] = [755, 319, 0xE8C672, 20] ; Trophy Amount of Clan Background of first Clan
Global $aClanChat[4] = [83, 650, 0x8BD004, 30] ; *Your Name* joined the Clan Message Check to verify loaded Clan Chat
Global $aClanBadgeNoClan[4] = [150, 315, 0xEB4C30, 20] ; Orange Tile of Clan Logo on Chat Tab if you are not in a Clan
Global $aClanChatRules[4] = [158, 493, 0x6CB531, 20]
Global $aClanNameBtn[2] = [89, 63] ; Button to open Clan Page from Chat Tab

;Chat Actions
Global $aGlobalChatTab[4] = [20, 24, 0x706C50, 20] ; Global Chat Tab on Top, check if right one is selected
Global $aClanChatTab[4] = [170, 24, 0x706C50, 20] ; Clan Chat Tab on Top, check if right one is selected
Global $aChatRules[4] = [75, 495, 0xB4E35C, 20]
Global $aChatSelectTextBox[4] = [277, 700, 0xFFFFFF, 10] ; color white Select Chat Textbox
Global $aOpenedChatSelectTextBox[4] = [100, 700, 0xFFFFFF, 10] ; color white Select Chat Textbox Opened
Global $aChatSendBtn[4] = [840, 700, 0xFFFFFF, 10] ; color white Send Chat Textbox
Global $aSelectLangBtn[2] = [260, 415] ; On Setting screen select language button
Global $aOpenedSelectLang[4] = [90, 113, 0xD7F37F, 20] ; On Setting screen language screen back button
Global $aLangSelected[4] = [118, 185, 0xCAFF40, 20] ; V color green to the left of the language
Global $aLangSettingOK[4] = [506, 446, 0x6DBC1F, 20] ; Language Selection Dialog Ok button

Global $aButtonFriendlyChallenge[4] = [200, 695, 0xDDF685, 20]
Global $aButtonFCChangeLayout[4] = [240, 286, 0XDDF685, 20]
Global $aButtonFCBack[4] = [160, 106, 0xD5F27D, 20]
Global $aButtonFCStart[4] = [638, 285, 0xDDF685, 20]

; Super XP
Global $aLootInfo[5] = [300, 590, 0xFFFFFF, 0xFFFFFF, 10] ; Color in the frame of Loot Available info
Global $aEndMapPosition[4] = [337, 664, 0x403828, 10] ; Safe Coordinates To Avoid Conflict With Stars Color - June Update 2019
Global $aFirstMapPosition[4] = [752, 139, 0x403828, 15] ; Safe Coordinates To Avoid Conflict With Stars Color - June Update 2019
Global $aCloseSingleTab[4] = [808, 70, 0xFF8D95, 20] ; X color red on the 'Close' button
Global $aIsInAttack[4] = [60, 576, 0x0A0A0A, 10] ; color black on the 'End Battle' button
Global Const $EndBattleText1[4] = [30, 565 + $g_iMidOffsetY, 0xFFFFFF, 10] ; color white 'E' on the 'End Battle' button
Global Const $EndBattleText2[4] = [377, 244 + $g_iMidOffsetY, 0xFFFFFF, 10] ; color white 'n' on the 'End Battle' popup
Global Const $ReturnHomeText[4] = [373, 545 + $g_iMidOffsetY, 0xFFFFFF, 10] ; color white 'R' on the 'Return Home' button
Global $aEarnedStar[4] = [455, 405, 0xD0D8D0, 20] ; color gray in the star in the middle of the screen
Global $aOneStar[4] = [714, 594, 0xD2D4CE, 20] ; color gray in the 'one star' in the bottom right of the screen
Global $aTwoStar[4] = [739, 594, 0xD2D4CE, 20] ; color gray in the 'tow star' in the bottom right of the screen
Global $aThreeStar[4] = [764, 594, 0xD2D4CE, 20] ; color gray in the 'three star' in the bottom right of the screen
Global $aIsLaunchSinglePage[4] = [830, 48, 0x98918F, 15] ; color brown in the 'Single Player' popup
