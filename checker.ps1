# Кодировка для красивого баннера
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Авто-админ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Clear-Host
$BANNER = @"
  ▄▄▄▄ ▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄         ▄▄                             
▄█████ ▀▀▀▀████    ▀▀▀▀████ ████████         ██                ▄▄           
   ███   ▄▄██▀       ▄▄██▀      ▄██▀   ▄████ ████▄ ▄█▀█▄ ▄████ ██ ▄█▀ ████▄ 
   ███     ███▄        ███▄    ███     ██    ██ ██ ██▄█▀ ██    ████   ██ ▀▀ 
   ███ ███████▀ ██ ███████▀    ███     ▀████ ██ ██ ▀█▄▄▄ ▀████ ██ ▀█▄ ██    
"@
Write-Host $BANNER -ForegroundColor Cyan

$tempDir = $env:TEMP
$urls = @{
    "EV"  = "https://www.voidtools.com/Everything-1.4.1.1026.x64.zip"
    "PH"  = "https://github.com/processhacker/processhacker/releases/download/v2.39/processhacker-2.39-bin.zip"
    "LAV" = "https://www.nirsoft.net/utils/lastactivityview.zip"
    "SBA" = "https://privazer.com/ru/shellbag_analyzer_cleaner.exe"
}

$paths = @{}

Write-Host "`n[!] ПОДГОТОВКА ИНСТРУМЕНТОВ..." -ForegroundColor White

foreach ($key in $urls.Keys) {
    $folder = Join-Path $tempDir "Checker_$key"
    if (!(Test-Path $folder)) { New-Item -ItemType Directory -Path $folder | Out-Null }
    
    $fileName = if ($key -eq "SBA") { "shellbag_analyzer_cleaner.exe" } else { Split-Path $urls[$key] -Leaf }
    $destFile = Join-Path $folder $fileName
    
    Write-Host "[>] Скачивание $key..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $urls[$key] -OutFile $destFile -UserAgent "Mozilla/5.0" -ErrorAction Stop
        
        if ($destFile.EndsWith(".zip")) {
            Expand-Archive -Path $destFile -DestinationPath $folder -Force
            Remove-Item $destFile
        }
        $paths[$key] = $folder
    } catch {
        Write-Host "[X] Ошибка при скачивании $key" -ForegroundColor Red
    }
}

# Ждем секунду на всякий случай
Start-Sleep -Seconds 1

$exeEv  = Join-Path $paths["EV"]  "Everything.exe"
$exePh  = Join-Path $paths["PH"]  "x64\ProcessHacker.exe"
$exeLav = Join-Path $paths["LAV"] "LastActivityView.exe"
$exeSba = Join-Path $paths["SBA"] "shellbag_analyzer_cleaner.exe"

# 1. Everything
if (Test-Path $exeEv) {
    $query = "size:2263|size:5266|size:6515|size:6770|size:6778|size:7016|size:7218|size:7803|size:7891|size:9327|size:10283|size:10605|size:10958|size:11554|size:16541|size:17308|size:17339|size:18180|size:18527|size:18587|size:18734|size:19266|size:20578|size:20583|size:20639|size:20883|size:21161|size:21234|size:21664|size:22036|size:22861|size:26247|size:27546|size:27809|size:28084|size:28439|size:29304|size:29567|size:30279|size:31549|size:31607|size:34449|size:34669|size:35971|size:35993|size:38149|size:39017|size:39321|size:40142|size:42782|size:47159|size:48242|size:50828|size:51212|size:52426|size:54088|size:59381|size:62782|size:65316|size:65486|size:65765|size:66659|size:67491|size:68794|size:69757|size:72334|size:74105|size:80751|size:88896|size:95530|size:98811|size:100523|size:100799|size:101297|size:101571|size:101703|size:102297|size:102733|size:103761|size:104954|size:105623|size:105672|size:112386|size:120640|size:138417|size:143006|size:143597|size:143600|size:147329|size:147873|size:151762|size:153937|size:156722|size:156779|size:166677|size:169718|size:173698|size:183634|size:183651|size:192156|size:202720|size:257482|size:263070|size:267746|size:274865|size:300286|size:334588|size:343169|size:350629|size:409616|size:410358|size:517248|size:519731|size:532826|size:539151|size:556494|size:597406|size:636621|size:640838|size:878781|size:925493|size:1077149|size:1165063|size:1181556|size:1444714|size:1471429|size:1569093|size:1822841|size:3113569|size:3425801|size:3541075|size:3541138|size:3642292|size:3684385|size:4642998|size:5630483|size:7052171|size:7059952|size:22258750|size:25704986|size:26179274|size:26691896 *.jar"
    Start-Process $exeEv -ArgumentList "-search `"$query`""
}

# 2. ShellBag Analyzer (с проверкой)
if (Test-Path $exeSba) {
    Start-Process $exeSba
} else {
    Write-Host "[X] Ошибка: Файл ShellBag не найден!" -ForegroundColor Red
}

# 3. PH и LAV
if (Test-Path $exePh) { Start-Process $exePh -WorkingDirectory (Split-Path $exePh) }
if (Test-Path $exeLav) { Start-Process $exeLav -WorkingDirectory (Split-Path $exeLav) }

# 4. Авто-поиск LAV
Start-Sleep -Seconds 4
$wshell = New-Object -ComObject WScript.Shell
if ($wshell.AppActivate("LastActivityView")) {
    $wshell.SendKeys("^f")
    Start-Sleep -Milliseconds 800
    $wshell.AppActivate("Find")
    Start-Sleep -Milliseconds 500
    $wshell.SendKeys("java")
    $wshell.SendKeys("%c")
    $wshell.SendKeys("{ENTER}")
}

Write-Host "`n1 - Close`n2 - holycheck" -ForegroundColor Green

while($true) {
    $choice = Read-Host "Select"
    if ($choice -eq "2") { Start-Process "https://mods.holyworld.me/mods/check" }
    if ($choice -eq "1") {
        Write-Host "[!] Cleaning..." -ForegroundColor Red
        "Everything", "ProcessHacker", "LastActivityView", "shellbag_analyzer_cleaner" | ForEach-Object {
            Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 1
        $urls.Keys | ForEach-Object {
            Remove-Item (Join-Path $tempDir "Checker_$_") -Recurse -Force -ErrorAction SilentlyContinue
        }
        break
    }
}
