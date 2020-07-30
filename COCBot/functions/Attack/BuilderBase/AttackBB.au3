; #FUNCTION# ====================================================================================================================
; Name ..........: PrepareAttackBB
; Description ...: This file controls attacking preperation of the builders base
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........: Chilly-Chill (04-2019)
; Modified ......: Boldina & vDragon - AIO++ (06-2020)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2017
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#Region - Custom BB - Team AIO Mod++ ; Thx Chilly-Chill by you hard work.
Func AttackBB($aAvailableTroops = GetAttackBarBB())
	Local $iSide = Random(0, 1, 1) ; randomly choose top left or top right
	Local $aBMPos = 0

	Local $Size = GetBuilderBaseSize()

	If Not $g_bRunState Then Return

	Setlog("Builder Base Diamond: " & $Size)
	Local $i = 0
	Do
		Setlog("Builder Base Attack Zoomout.")
		$Size = GetBuilderBaseSize(False) ; WihtoutClicks

		If ($Size < 575 And $Size > 620) Or ($Size = 0) Then
			BuilderBaseZoomOut()
			If _Sleep(1000) Then Return
		EndIf

		If $i > 5 Then ExitLoop
		$i += 1
	Until ($Size >= 575 And $Size <= 620) Or ($Size <> 0)

	If $Size = 0 Then
		SetLog("Fail AttackBB 0x1")
		Return False
	EndIf

	$g_aBuilderBaseDiamond = BuilderBaseAttackDiamond()
	If IsArray($g_aBuilderBaseDiamond) <> True Or Not (UBound($g_aBuilderBaseDiamond) > 0) Then Return False

	$g_aExternalEdges = BuilderBaseGetEdges($g_aBuilderBaseDiamond, "External Edges")


	Local $sSideNames[4] = ["TopLeft", "TopRight", "BottomRight", "BottomLeft"]

	Local $BuilderHallPos = findMultipleQuick($g_sBundleBuilderHall, 1)
	If $BuilderHallPos <> -1 And UBound($BuilderHallPos) > 0 Then
		$g_aBuilderHallPos[0][0] = $BuilderHallPos[0][1]
		$g_aBuilderHallPos[0][1] = $BuilderHallPos[0][2]
	Else
		_DebugFailedImageDetection("BuilderHall")
		Setlog("Builder Hall detection Error!", $Color_Error)
		$g_aBuilderHallPos[0][0] = 450
		$g_aBuilderHallPos[0][1] = 425
	EndIf

	Local $iSide = _ArraySearch($sSideNames, BuilderBaseAttackMainSide(), 0, 0, 0, 0, 0, 0)

	If $iSide < 0 Then
		SetLog("Fail AttackBB 0x2")
		Return False
	EndIf

	Local $aVar = $g_aExternalEdges[$iSide]

	;BuilderBaseGetDeployPoints()
	;
	;$aVar = $g_aDeployPoints[1]

    If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Disabled")

	; Get troops on attack bar and their quantities
	Local $aBBAttackBar = $aAvailableTroops

	If Not IsArray($aBBAttackBar) Or RandomSleep($DELAYRESPOND) Then Return

	; Deploy all troops
	Local $iLoopControl = 0, $iUBound1 = UBound($aBBAttackBar)
	SetLog($g_bBBDropOrderSet = True ? "Deploying Troops in Custom Order." : "Deploying Troops in Order of Attack Bar.", $COLOR_BLUE)
	; Loop until nothing has left in Attack Bar
	Do
		Local $iNumSlots = UBound($aBBAttackBar, 1)
		If $g_bBBDropOrderSet = True Then
			; Dropping using Customer Order!
			; Loop through each name in the drop order
			For $i = 0 To UBound($g_aiCmbBBDropOrder) - 1
				; There might be several slots containing same Troop, so even here we should make another loop
				For $j = 0 To $iNumSlots - 1
					; If The Troop name in Slot were the same as Troop name in Current Drop Order index
					If $aBBAttackBar[$j][0] = $g_asAttackBarBB2[Number($g_aiCmbBBDropOrder[$i])] Then ; Custom BB Army - Team AIO Mod++
						; Increase Total Dropped so at the end we can see if it hasn't dropped any, exit the For loop
						If Not ($aBBAttackBar[$j][0] == "Machine") Then
							; The Slot is not Battle Machine, is just a simple troop
							SetLog("Deploying " & $aBBAttackBar[$j][0] & " x" & String($aBBAttackBar[$j][4]), $COLOR_ACTION)
							 ; select troop
							PureClick($aBBAttackBar[$j][1] - Random(0, 5, 1), $aBBAttackBar[$j][2] - Random(0, 5, 1))
							; If the Quantity of the Slot is more than Zero, Start Dropping the Slot
							If $aBBAttackBar[$j][4] > 0 Then
								For $iAmount = 1 To $aBBAttackBar[$j][4]
									Local $vDP = Random(0, UBound($aVar) - 1)
									; Drop
									PureClick($aVar[$vDP][0], $aVar[$vDP][1])
									; Check for Battle Machine Ability
									If TriggerMachineAbility() Then
										; Battle Machine Ability Trigged, Then we have to reselect the Slot we were in.
										PureClick($aBBAttackBar[$j][1] - Random(0, 5, 1), $aBBAttackBar[$j][2] - Random(0, 5, 1))
									EndIf
									; Sleep as much as the user wants for Same Troop Delay
									If RandomSleep($g_iBBSameTroopDelay) Then Return
								Next
							EndIf
						Else
							; The Slot is a Battle Machine!
							Click($aBBAttackBar[$j][1], $aBBAttackBar[$j][2])
							If RandomSleep($g_iBBSameTroopDelay) Then Return
							Local $vDP = Random(0, UBound($aVar) - 1)
							PureClick($aVar[$vDP][0], $aVar[$vDP][1])
							Global $g_aMachineBB[2] = [$aBBAttackBar[$j][1], $aBBAttackBar[$j][2]]
							$g_bIsBBMachineD = True
						EndIf

						;---------------------------
						; If the Attack Bar Array has one more index that can be checked, Then Check if the Current Slot troop is the same as the next slot
						; If not the same, Add a Random Delay according to Next Troop delay in settings
						If UBound($aBBAttackBar) > $j + 1 Then
							If $aBBAttackBar[$j][0] <> $aBBAttackBar[$j + 1][0] Then
								; The next Slot has a different troop, Here we Sleep as set in Next Troop delay settings
								If RandomSleep($g_iBBNextTroopDelay) Then ; wait before next troop
									If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
									Return
								EndIf
								; Now we exit the Slot Loop for the Troop Order, as the next slot has a different troop
								ExitLoop
							EndIf
						EndIf
					EndIf
				Next ; Slot Loop
			Next ; Custom Drop Order Loop
		Else
			; No Custom Drop Order has been set!
			For $i = 0 To $iNumSlots - 1
				If Not ($aBBAttackBar[$i][0] == "Machine") Then
					SetLog("Deploying " & $aBBAttackBar[$i][0] & " x" & String($aBBAttackBar[$i][4]), $COLOR_ACTION)
					PureClick($aBBAttackBar[$i][1] - Random(0, 5, 1), $aBBAttackBar[$i][2] - Random(0, 5, 1))     ; select troop
					If $aBBAttackBar[$i][4] <> 0 Then
						For $iAmount = 0 To $aBBAttackBar[$i][4]
							Local $vDP = Random(0, UBound($aVar) - 1)
							PureClick($aVar[$vDP][0], $aVar[$vDP][1])
							If TriggerMachineAbility() Then PureClick($aBBAttackBar[$i][1] - Random(0, 5, 1), $aBBAttackBar[$i][2] - Random(0, 5, 1))     ; select troop
							If RandomSleep($g_iBBSameTroopDelay) Then Return     ; slow down selecting then dropping troops
						Next
					EndIf
				Else
					Click($aBBAttackBar[$i][1], $aBBAttackBar[$i][2])
					If RandomSleep($g_iBBSameTroopDelay) Then Return
					Local $vDP = Random(0, UBound($aVar) - 1)
					PureClick($aVar[$vDP][0], $aVar[$vDP][1])
					Global $g_aMachineBB[2] = [$aBBAttackBar[$i][1], $aBBAttackBar[$i][2]]
					$g_bIsBBMachineD = True
				EndIf

				;---------------------------
				If $i = $iNumSlots - 1 Or $aBBAttackBar[$i][0] <> $aBBAttackBar[$i + 1][0] Then
					If RandomSleep($g_iBBNextTroopDelay) Then ; wait before next troop
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				Else
					If RandomSleep($DELAYRESPOND) Then ; we are still on same troop so lets drop them all down a bit faster
						If $g_bDebugSetlog = True Then SetDebugLog("Android Suspend Mode Enabled")
						Return
					EndIf
				EndIf
			Next
		EndIf

		; Attack bar loop control.
		$aBBAttackBar = GetAttackBarBB(True)

		If UBound($aBBAttackBar) = $iUBound1 Then $iLoopControl += 1
		If ($iLoopControl > 3) Then ExitLoop
		$iUBound1 = UBound($aBBAttackBar)
		
	Until Not IsArray($aBBAttackBar)
	SetLog("All Troops Deployed", $COLOR_SUCCESS)

	If $g_bDebugSetlog Then SetDebugLog("Android Suspend Mode Enabled")
EndFunc   ;==>AttackBB
#EndRegion - Custom BB - Team AIO Mod++ ; Thx Chilly-Chill by you hard work.
Func Okay()
	local $timer = __TimerInit()

	While 1
		local $aCoords = decodeSingleCoord(findImage("OkayButton", $g_sImgOkButton, "FV", 1, True))
		If IsArray($aCoords) And UBound($aCoords) = 2 Then
			PureClickP($aCoords)
			Return True
		EndIf

		If __TimerDiff($timer) >= 180000 Then
			SetLog("Could not find button 'Okay'", $COLOR_ERROR)
			If $g_bDebugImageSave Then SaveDebugImage("BBFindOkay")
			Return False
		EndIf

		If Mod(__TimerDiff($timer), 3000) Then
			If _Sleep($DELAYRESPOND) Then Return
		EndIf

	WEnd

	Return True
EndFunc