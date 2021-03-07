; #FUNCTION# ====================================================================================================================
; Name ..........: GetVillageSize
; Description ...: Measures the size of village. After CoC October 2016 update, max'ed zoomed out village is 440 (reference!)
;                  But usually sizes around 470 - 490 pixels are measured due to lock on max zoom out.
; Syntax ........: GetVillageSize()
; Parameters ....:
; Return values .: 0 if not identified or Array with index
;                      0 = Size of village (float)
;                      1 = Zoom factor based on 440 village size (float)
;                      2 = X offset of village center (int)
;                      3 = Y offset of village center (int)
;                      4 = X coordinate of stone
;                      5 = Y coordinate of stone
;                      6 = stone image file name
;                      7 = X coordinate of tree
;                      8 = Y coordinate of tree
;                      9 = tree image file name
; Author ........: Cosote (Oct 17th 2016)
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Global $g_sZoomOutModes = "Normal"

Func GetVillageSize($DebugLog = Default, $sStonePrefix = Default, $sTreePrefix = Default, $sFixedPrefix = Default, $bOnBuilderBase = Default)
	FuncEnter(GetVillageSize)
	
	#Region - Builder Base - Team AIO Mod++
	Global $g_aPosSizeVillage = 0
	Global $g_iXVOffset = 0
	#EndRegion - Builder Base - Team AIO Mod++
	
	If $DebugLog = Default Then $DebugLog = False
	If $sStonePrefix = Default Then $sStonePrefix = "stone"
	If $sTreePrefix = Default Then $sTreePrefix = "tree"
	If $sFixedPrefix = Default Then
		$sFixedPrefix = ""
		If $g_bUpdateSharedPrefs Then $sFixedPrefix = "fixed"
	EndIf
	
	
	Local $aResult = 0
	Local $sDirectoryOri, $sDirectory ; Team AIO Mod++
	Local $stone = [0, 0, 0, 0, 0, ""], $tree = [0, 0, 0, 0, 0, ""], $fixed = [0, 0, 0, 0, 0, ""]
	Local $x0, $y0, $d0, $x, $y, $x1, $y1, $right, $bottom, $a

	Local $iAdditionalY = 75
	Local $iAdditionalX = 100
	
	#Region - Custom themes - Team AIO Mod++
	If $bOnBuilderBase = Default Then
		$bOnBuilderBase = isOnBuilderBase(True)
	EndIf
	
	; Team AIO Mod++
	; If $bOnBuilderBase Then
	; $sDirectory = $g_sImgZoomOutDirBB
	; Else
	; $sDirectoryOri = $g_sImgZoomOutDir
	; EndIf
	
	; GetVillageSize(Default, Default, Default, Default, False)
	Local $aZoomOutModes[1] = [""]
	
	$sDirectory = $g_sImgZoomOutDir
	$sDirectoryOri = $sDirectory
	
	If $bOnBuilderBase Then
		$sDirectory = $g_sImgZoomOutDirBB
		$sDirectoryOri = $sDirectory
	Else
		Local $aModes = StringSplit($g_sZoomOutModes, "|")
		
		; Reset to Default if it fail.
		If Not (UBound($aModes) > 0) Then
			$aModes = StringSplit("Normal", "|")
		EndIf
		
		; List all files to check.
		Local $aZoomOutModes = _FileListToArray($g_sImgZoomOutDir, "*", $FLTA_FOLDERS)
		If Not @error Then
			_ArrayDelete($aZoomOutModes, 0)
		EndIf
	EndIf
	
	Local $eError = ""
	; Local $sImOk = False
	
	; initial reference village had a width of 473.60282919315 (and not 440) and stone located at 226, 567, so center on that reference and used zoom factor on that size
	;Local $z = $c / 473.60282919315 ; don't use size of 440, as beta already using reference village
	Local Const $iRefSize = 445 ;458 ; 2019-01-02 Update village measuring as outer edges didn't align anymore
	Local Const $iDefSize = 444 ; 2019-04-01 New default size using shared_prefs zoom level
	
	_CaptureRegion2()
	For $iB = 0 To UBound($aZoomOutModes) - 1
		$sDirectory = $sDirectoryOri & $aZoomOutModes[$iB] & "\"
		$eError = ""
		
		Local $aStoneFiles = _FileListToArray($sDirectory, $sStonePrefix & "*.*", $FLTA_FILES)
		$eError = @error
		If $eError Then
			SetDebugLog("Error: Missing stone files (" & $eError & ") " & $aZoomOutModes[$iB], $COLOR_ERROR)
			ContinueLoop
			; Return FuncReturn($aResult)
		EndIf
		
		; use stoneBlueStacks2A stones first
		; For $i = 1 To $aStoneFiles[0]
		; If StringInStr($aStoneFiles[$i], "stoneBlueStacks2A") = 1 Then
		; _ArraySwap($aStoneFiles, $i, 0)
		; ExitLoop
		; EndIf
		; Next
		
		Local $aTreeFiles = _FileListToArray($sDirectory, $sTreePrefix & "*.*", $FLTA_FILES)
		$eError = @error
		If $eError Then
			SetDebugLog("Error: Missing tree (" & $eError & ") " & $aZoomOutModes[$iB], $COLOR_ERROR)
			ContinueLoop
			; Return FuncReturn($aResult)
		EndIf
		Local $i, $findImage, $sArea, $a
		
		Local $aFixedFiles = ($sFixedPrefix ? _FileListToArray($sDirectory, $sFixedPrefix & "*.*", $FLTA_FILES) : 0)
		
		If UBound($aFixedFiles) > 0 Then
			For $i = 1 To $aFixedFiles[0]
				$findImage = $aFixedFiles[$i]
				$a = StringRegExp($findImage, ".*-(\d+)-(\d+)-(\d*,*\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
				If UBound($a) = 4 Then
					
					$x0 = $a[0]
					$y0 = $a[1]
					$d0 = StringReplace($a[2], ",", ".")
					
					$x1 = $x0 - $iAdditionalX
					$y1 = $y0 - $iAdditionalY
					$right = $x0 + $iAdditionalX
					$bottom = $y0 + $iAdditionalY
					$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
					;SetDebugLog("GetVillageSize check for image " & $findImage)
					$a = decodeSingleCoord(findImage($findImage, $sDirectory & $findImage, $sArea, 1, False))
					If UBound($a) = 2 Then
						$x = Int($a[0])
						$y = Int($a[1])
						;SetDebugLog("Found fixed image at " & $x & ", " & $y & ": " & $findImage)
						$fixed[0] = $x ; x center of fixed found
						$fixed[1] = $y ; y center of fixed found
						$fixed[2] = $x0 ; x ref. center of fixed
						$fixed[3] = $y0 ; y ref. center of fixed
						$fixed[4] = $d0 ; distance to village map in pixel
						$fixed[5] = $findImage
						ExitLoop
					EndIf
					
				Else
					;SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
				EndIf
			Next
		EndIf
		
		For $i = 1 To $aStoneFiles[0]
			$findImage = $aStoneFiles[$i]
			$a = StringRegExp($findImage, ".*-(\d+)-(\d+)-(\d*,*\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
			If UBound($a) = 4 Then
				
				$x0 = $a[0]
				$y0 = $a[1]
				$d0 = StringReplace($a[2], ",", ".")
				
				$x1 = $x0 - $iAdditionalX
				$y1 = $y0 - $iAdditionalY
				$right = $x0 + $iAdditionalX
				$bottom = $y0 + $iAdditionalY
				$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
				;SetDebugLog("GetVillageSize check for image " & $findImage)
				$a = decodeSingleCoord(findImage($findImage, $sDirectory & $findImage, $sArea, 1, False))
				If UBound($a) >= 2 Then
					$x = Int($a[0])
					$y = Int($a[1])
					;SetDebugLog("Found stone image at " & $x & ", " & $y & ": " & $findImage)
					$stone[0] = $x ; x center of stone found
					$stone[1] = $y ; y center of stone found
					$stone[2] = $x0 ; x ref. center of stone
					$stone[3] = $y0 ; y ref. center of stone
					$stone[4] = $d0 ; distance to village map in pixel
					$stone[5] = $findImage
					ExitLoop
				EndIf
				
			Else
				;SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
			EndIf
		Next
		
		If $stone[0] = 0 And $fixed[0] = 0 Then
			SetDebugLog("GetVillageSize cannot find stone " & $aZoomOutModes[$iB], $COLOR_WARNING)
			ContinueLoop
			; Return FuncReturn($aResult)
		EndIf
		
		If $stone[0] Then
			For $i = 1 To $aTreeFiles[0]
				$findImage = $aTreeFiles[$i]
				$a = StringRegExp($findImage, ".*-(\d+)-(\d+)-(\d*,*\d+)_.*[.](xml|png|bmp)$", $STR_REGEXPARRAYMATCH)
				If UBound($a) = 4 Then
					
					$x0 = $a[0]
					$y0 = $a[1]
					$d0 = StringReplace($a[2], ",", ".")
					
					$x1 = $x0 - $iAdditionalX
					$y1 = $y0 - $iAdditionalY
					$right = $x0 + $iAdditionalX
					$bottom = $y0 + $iAdditionalY
					$sArea = Int($x1) & "," & Int($y1) & "|" & Int($right) & "," & Int($y1) & "|" & Int($right) & "," & Int($bottom) & "|" & Int($x1) & "," & Int($bottom)
					;SetDebugLog("GetVillageSize check for image " & $findImage)
					$a = decodeMultipleCoords(findImage($findImage, $sDirectory & $findImage, $sArea, 2, False), Default, Default, 0) ; sort by x because there can be a 2nd at the right that should not be used
					If UBound($a) <> 0 Then
						$a = $a[0]
						$x = Int($a[0])
						$y = Int($a[1])
						;SetDebugLog("Found tree image at " & $x & ", " & $y & ": " & $findImage)
						$tree[0] = $x ; x center of tree found
						$tree[1] = $y ; y center of tree found
						$tree[2] = $x0 ; x ref. center of tree
						$tree[3] = $y0 ; y ref. center of tree
						$tree[4] = $d0 ; distance to village map in pixel
						$tree[5] = $findImage
						ExitLoop
					EndIf
					
				Else
					;SetDebugLog("GetVillageSize ignore image " & $findImage & ", reason: " & UBound($a), $COLOR_WARNING)
				EndIf
			Next
			
			If $g_bUpdateSharedPrefs And Not $bOnBuilderBase And $tree[0] = 0 And $fixed[0] = 0 Then
				; On main village use stone as fixed point
				$fixed = $stone
			EndIf
			
			If $tree[0] = 0 And $fixed[0] = 0 And Not $g_bRestart Then
				SetDebugLog("GetVillageSize cannot find tree " & $aZoomOutModes[$iB], $COLOR_WARNING)
				ContinueLoop
				; Return FuncReturn($aResult)
			EndIf
		EndIf
		
		If $tree[0] = 0 Or $stone[0] = 0 Then ContinueLoop
		
		; $sImOk = True
		
		If StringIsSpace($aZoomOutModes[$iB]) = False Then
			Local $iSave = $aZoomOutModes[$iB]
			_ArrayDelete($aZoomOutModes, $iB)
			_ArrayInsert($aZoomOutModes, 0, $iSave)
			$g_sZoomOutModes = _ArrayToString($aZoomOutModes, "|")
		EndIf
		
		SetDebugLog("GetVillageSize: " & $g_sZoomOutModes)
		
		; If $sImOk = False Then
			; SetDebugLog("GetVillageSize: fail.", $COLOR_WARNING)
			; Return FuncReturn($aResult)
		; EndIf
		
		; calculate village size, see https://en.wikipedia.org/wiki/Pythagorean_theorem
		Local $a = $tree[0] - $stone[0]
		Local $b = $stone[1] - $tree[1]
		Local $c = Sqrt($a * $a + $b * $b) - $stone[4] - $tree[4]
		
		If $g_bUpdateSharedPrefs And Not $bOnBuilderBase And $fixed[0] = 0 And $c >= 500 Then
			; On main village use stone as fixed point when village size is too large, as that might cause an infinite loop when obstacle blocked (and another tree found)
			$fixed = $stone
		EndIf
		
		Local $z = $c / $iRefSize
		
		Local $stone_x_exp = $stone[2]
		Local $stone_y_exp = $stone[3]
		ConvertVillagePos($stone_x_exp, $stone_y_exp, $z) ; expected x, y position of stone
		$x = $stone[0] - $stone_x_exp
		$y = $stone[1] - $stone_y_exp
		
		If $fixed[0] = 0 And Not $g_bRestart Then
			
			If $DebugLog Then SetDebugLog("GetVillageSize measured: " & $c & ", Zoom factor: " & $z & ", Offset: " & $x & ", " & $y, $COLOR_INFO)
			
			#Region - Builder Base - Team AIO Mod++
			Local $aTempResult[10] = [$c, $z, $x, $y, $stone[0], $stone[1], $stone[5], $tree[0], $tree[1], $tree[5]]
			$aResult = $aTempResult
			$g_aPosSizeVillage = $aResult
			$g_iXVOffset = $aResult[2]
			#EndRegion - Builder Base - Team AIO Mod++
			Return FuncReturn($aResult)
			
		Else
			
			; used fixed tile position for village offset
			Local $bReset = $g_bUpdateSharedPrefs And $c >= 500
			If $tree[0] = 0 Or $stone[0] = 0 Or $bReset Then
				; missing a tile or reset required
				If $bReset Then SetDebugLog("GetVillageSize resets village size from " & $c & " to " & $iDefSize, $COLOR_WARNING)
				$c = $iDefSize
				$z = $iDefSize / $iRefSize
			EndIf
			
			$x = $fixed[0] - $fixed[2]
			$y = $fixed[1] - $fixed[3]
			
			If $DebugLog Then SetDebugLog("GetVillageSize measured (fixed): " & $c & ", Zoom factor: " & $z & ", Offset: " & $x & ", " & $y, $COLOR_INFO)
			
			#Region - Builder Base - Team AIO Mod++
			Local $aTempResultn[10] = [$c, $z, $x, $y, $stone[0], $stone[1], $stone[5], $tree[0], $tree[1], $tree[5]]
			$aResult = $aTempResultn
			$g_aPosSizeVillage = $aResult
			$g_iXVOffset = $aResult[2]
			#EndRegion - Builder Base - Team AIO Mod++
			Return FuncReturn($aResult)
			
		EndIf
	Next
	
	#EndRegion - Custom themes - Team AIO Mod++

	FuncReturn()

EndFunc   ;==>GetVillageSize

Func UpdateGlobalVillageOffset($x, $y)

	Local $updated = False

	If $g_sImglocRedline <> "" Then

		Local $newReadLine = ""
		Local $aPoints = StringSplit($g_sImglocRedline, "|", $STR_NOCOUNT)

		For $sPoint In $aPoints

			Local $aPoint = GetPixel($sPoint, ",")
			$aPoint[0] += $x
			$aPoint[1] += $y

			If StringLen($newReadLine) > 0 Then $newReadLine &= "|"
			$newReadLine &= ($aPoint[0] & "," & $aPoint[1])

		Next

		; set updated red line
		$g_sImglocRedline = $newReadLine

		$updated = True
	EndIf

	If $g_aiTownHallDetails[0] <> 0 And $g_aiTownHallDetails[1] <> 0 Then
		$g_aiTownHallDetails[0] += $x
		$g_aiTownHallDetails[1] += $y
		$updated = True
	EndIf
	If $g_iTHx <> 0 And $g_iTHy <> 0 Then
		$g_iTHx += $x
		$g_iTHy += $y
		$updated = True
	EndIf

	ConvertInternalExternArea()

	Return $updated

EndFunc   ;==>UpdateGlobalVillageOffset

#Region - COC Themes Fake AI - Team AIO Mod++
Func Brujula2D($iX, $iY)
	Local $iMitadWidth = $g_iGAME_WIDTH / 2
	Local $iMitadHeight = $g_iGAME_HEIGHT / 2

	Switch True
		Case $iX <= $iMitadWidth
			Switch True
				Case $iMitadWidth >= $iY
					Return "LT"
				Case Else
					Return "LB"
			EndSwitch
		Case Else
			Switch True
				Case $iMitadWidth >= $iY
					Return "RT"
				Case Else
					Return "RB"
			EndSwitch
	EndSwitch
EndFunc   ;==>Brujula2D
#EndRegion - COC Themes Fake AI - Team AIO Mod++
