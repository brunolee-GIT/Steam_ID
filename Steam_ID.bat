@echo off
title Steam ID 
set HOME=%~dp0
cd /d "%HOME%"
rem mode con cols=120 lines=40

set PRIVATESTEAMID=id/8runo1ee

: IMPUT
set STEAMKEY=76561197960265728
cls
echo.
echo [90m Use one of these Steam ID formats to discover more[0m
echo [35m Steam ID (x64) : [94m76561197960287930[0m
echo [35m Steam ID (x32) : [94m[U:1:22202][0m
echo [35m Steam ID       : [94mSTEAM_0:0:11101[0m
echo [35m Custom ID      : [94mid/GabeLoganNewell[0m
echo.
if defined PRIVATESTEAMID set steamvalue=%PRIVATESTEAMID%
set /p steamvalue= "[96m Steam ID: [0m"

::id/
if "%steamvalue:~0,3%"=="id/" (
	for /f "tokens=1-9 delims=<>[]" %%1 in ('curl -s "https://steamcommunity.com/id/%steamvalue:~3%?xml=1"') do (
		if "%%2"=="steamID64" (
			set steamvalue=%%3
			set ID=steam64ID
			goto SELECT
		)
	)
)
::steamID or steamID32
for /f "tokens=1-9 delims=_[:]" %%1 in ("%steamvalue%") do (
	if "%%1"=="STEAM" (
		set ID=steamID
		set Y=%%3
		set steamvalue=%%4
		goto SELECT
	)
	if "%%1"=="U" (
		set ID=steam32ID
		set steamvalue=%%3
		goto SELECT
	)
)
::steamID64
set length=0
for /f %%a in ('powershell -Command "('%steamvalue%' -replace '[^0-9]' , '').ToString()"') do (
	set steamvalue=%%a
	for /f %%b in ('powershell -Command "('%%a').length"') do set length=%%b
)
if "%steamvalue%" EQU "%STEAMKEY%" (
	set ID=steam64ID
	goto SELECT
)
if "%length%" EQU "17" (
	if "%steamvalue:~0,7%"=="7656119" (
		set ID=steam64ID
		goto SELECT
	)
)
::empty or invalid
if "%length%" EQU "0" (
	set redmsg=[91mTYPE A VALID STEAM ID FORMAT!                                                                              [0m
) else (
	set redmsg=[91mIS NOT A VALID STEAM ID OR FORMAT!                                                                         [0m
)
powershell -Command "[Console]::CursorTop=7 ; [Console]::CursorLeft=11"
echo %redmsg%
timeout 2 >NUL
powershell -Command "[Console]::CursorTop=7 ; [Console]::CursorLeft=11"
echo [92mTRY AGAIN!                                                                                                 [0m
timeout 1 >NUL
goto IMPUT

: SELECT
if "%ID%"=="steamID" set steamID=%steamvalue%&call :function_convert_steamID_to_rest
if "%ID%"=="steam32ID" set steam32ID=%steamvalue%&call :function_convert_steamID32_to_rest
if "%ID%"=="steam64ID" set steam64ID=%steamvalue%&call :function_convert_steamID64_to_rest

chcp 65001>NUL
set name=&set onlineState=&set stateMessage=&set privacyState=&set visibilityState=&set vacBanned=&set tradeBanState=&set isLimitedAccount=&set customid=&set customURL=&set memberSince=&set location=&set realname=&set avatarURL=
for /f "tokens=1-9 delims=<>[]" %%1 in ('curl -s "https://steamcommunity.com/profiles/%steam64ID%?xml=1"') do (
	if "%%2"=="steamID" if not "%%5"=="/steamID" set name=[93m Name             : [92m%%5[0m
	if "%%2"=="onlineState" set onlineState=[93m Online State     : [92m%%3[0m
	if "%%2"=="stateMessage" set stateMessage=[93m State Message    : [92m%%5[0m
	if "%%2"=="privacyState" set privacyState=[93m Privacy State    : [92m%%3[0m
	if "%%2"=="visibilityState" (
		if "%%3"=="1" set visibilityState=[93m Visibility State : [92mPrivate[0m
		if "%%3"=="3" set visibilityState=[93m Visibility State : [92mPublic[0m
	)
	if "%%2"=="avatarIcon" (
		if not defined avatarURL (
			set avatarURL=%%5
			for /f "tokens=1-9 delims=." %%a in ("%%5") do set avatarLink=%%a.%%b.%%c.%%d&set avatarExtension=.%%e
		)
	)
	if "%%2"=="vacBanned" (
		if "%%3"=="0" set vacBanned=[93m Banned           : [92mFalse[0m
		if "%%3"=="1" set vacBanned=[93m Banned           : [92mTrue[0m
	)
	if "%%2"=="tradeBanState" set tradeBanState=[93m Trade Ban State  : [92m%%3[0m
	if "%%2"=="isLimitedAccount" (
		if "%%3"=="0" set isLimitedAccount=[93m Limited Account  : [92mFalse[0m
		if "%%3"=="1" set isLimitedAccount=[93m Limited Account  : [92mTrue[0m
	)
	if "%%2"=="customURL" if not "%%5"=="/customURL" set customid=%%5&set customURL=[93m Custom URL       : [92mhttps://steamcommunity.com/id/%%5[0m
	if "%%2"=="memberSince" set memberSince=[93m Member Since     : [92m%%3[0m
	if "%%2"=="location" if not "%%5"=="/location" set location=[93m Location         : [92m%%5[0m
	if "%%2"=="realname" if not "%%5"=="/realname" set realname=[93m Real Name        : [92m%%5[0m
)
set level=
for /f "tokens=1-9 delims=<>" %%1 in ('curl -s "https://steamcommunity.com/id/%customid%"') do (
	if "%%3"=="Level " set level=[93m Level            : [92m%%6[0m
)
set friends=&set groups=
for /f "tokens=1-9 delims=:, " %%1 in ('curl -s "https://steamcommunity.com/id/%customid%/friends"') do (
	if "%%2"=="g_rgCounts" (
		set friends=[93m Friends          : [92m%%5[0m
		set groups=[93m Groups           : [92m%%7[0m
	)
)


: OUTPUT
chcp 850>NUL
echo.
::show steam IDs by calc
echo [93m Steam ID (x64)   : [92m%steam64ID%[0m
echo [93m Steam ID (x32)   : [90m[U:1:[92m%steam32ID%[90m][0m
echo [93m Steam ID         : [90mSTEAM_0:[92m%Y%[90m:[92m%steamID%[0m
echo [93m Hex Format       : [90msteam:[92m%hex%[0m
echo [93m Account ID       : [92m%steam32ID%[0m
::show some things by html
echo.
if defined name echo %name%
if defined level echo %level%
if defined friends echo %friends%
if defined groups echo %groups%
if defined onlineState echo %onlineState%
if defined stateMessage echo %stateMessage%
if defined privacyState echo %privacyState%
if defined visibilityState echo %visibilityState%
if defined vacBanned echo %vacBanned%
if defined tradeBanState echo %tradeBanState%
if defined isLimitedAccount echo %isLimitedAccount%
if defined customURL echo %customURL%
if defined memberSince echo %memberSince%
if defined location echo %location%
if defined realname echo %realname%
::show avatar
if defined avatarURL (
	curl -s "%avatarLink%_full%avatarExtension%" -o "%steam64ID%%avatarExtension%"
		if exist "%steam64ID%%avatarExtension%" (
			findstr /c:"Not Found" "%steam64ID%%avatarExtension%">NUL:&&(
				del "%steam64ID%%avatarExtension%">NUL
			)||(
				powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Application]::EnableVisualStyles(); $img = [System.Drawing.Image]::Fromfile('%steam64ID%%avatarExtension%'); $SScreen = New-Object system.Windows.Forms.Form; $SScreen.Width = $img.Width; $SScreen.Height = $img.Height; $SScreen.TopMost = $true; $SScreen.BackgroundImage = $img; $SScreen.AllowTransparency = $true; $SScreen.StartPosition = 1; $SScreen.FormBorderStyle = 0; $SScreen.Show(); Start-Sleep -Seconds 3; $SScreen.Close(); $SScreen.Dispose()"
				del "%steam64ID%%avatarExtension%">NUL
			)
		)
	)
)
echo.&echo  Press any key to try another Steam ID . . .&pause>NUL
goto IMPUT


:function_convert_steamID_to_rest
for /f %%a in ('powershell -Command "[math]::Abs(%steamID% * 2 + %Y%)"') do set steam32ID=%%a
for /f %%a in ('powershell -Command "[math]::Abs(%steamID% * 2 + %STEAMKEY% + %Y%)"') do set steam64ID=%%a
for /f %%a in ('powershell -Command "'{0:X}' -f %steam64ID%"') do set hex=%%a
goto :EOF

:function_convert_steamID32_to_rest
for /f %%a in ('powershell -Command "[math]::Abs(%steam32ID% / 2)"') do set steamID=%%a
if "%steamID:~-2,1%"=="," (set Y=1&set steamID=%steamID:~0,-2%) else (set Y=0)
for /f %%a in ('powershell -Command "[math]::Abs(%steam32ID% + %STEAMKEY%)"') do set steam64ID=%%a
for /f %%a in ('powershell -Command "'{0:X}' -f %steam64ID%"') do set hex=%%a
goto :EOF

:function_convert_steamID64_to_rest
for /f %%a in ('powershell -Command "[math]::Abs((%steam64ID% - %STEAMKEY%) / 2)"') do set steamID=%%a
if "%steamID:~-2,1%"=="," (set Y=1&set steamID=%steamID:~0,-2%) else (set Y=0)
for /f %%a in ('powershell -Command "[math]::Abs(%steam64ID% - %STEAMKEY%)"') do set steam32ID=%%a
for /f %%a in ('powershell -Command "'{0:X}' -f %steam64ID%"') do set hex=%%a
goto :EOF