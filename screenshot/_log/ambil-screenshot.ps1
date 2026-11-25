# Menyalakan server bersih lalu mengambil screenshot setiap kasus uji dengan Chrome headless.
$ErrorActionPreference = "Continue"
$root  = "D:\College\S7\Pemrograman  Web Lanjut\Tugas\Tugas 4 REST API"
$log   = Join-Path $root "screenshot\_log"
$shot  = Join-Path $root "screenshot"
$html  = Join-Path $log "konsol-uji.html"
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$profile = Join-Path $env:TEMP "chrome-shot-t4"

Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Milliseconds 600

Start-Process -FilePath "npm.cmd" -ArgumentList "run","dev" `
    -WorkingDirectory $root -WindowStyle Hidden `
    -RedirectStandardOutput (Join-Path $log "server.log") `
    -RedirectStandardError  (Join-Path $log "server.err.log") | Out-Null

$siap = $false
for ($i = 0; $i -lt 40; $i++) {
    try { Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -TimeoutSec 2 | Out-Null; $siap = $true; break }
    catch { Start-Sleep -Milliseconds 500 }
}
if (-not $siap) { throw "Server tidak mau start" }
Start-Sleep -Milliseconds 1000

$baseUri = ([System.Uri]::new($html)).AbsoluteUri

function Shot($case, $file, $w, $h) {
    $uri = $baseUri + "?case=" + $case
    $out = Join-Path $shot $file
    if (Test-Path $out) { Remove-Item $out -Force }
    & $chrome --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 `
        --disable-web-security --user-data-dir="$profile" `
        --window-size=$w,$h --virtual-time-budget=6000 `
        --screenshot="$out" "$uri" 2>&1 | Out-Null
    if (Test-Path $out) { "OK  $file  $((Get-Item $out).Length) bytes" } else { "GAGAL $file" }
}

Shot "server"                "01-server-berjalan.png"          1440 400
Shot "get-daftar"            "02-get-daftar.png"               1440 2300
Shot "get-detail-200"        "03-get-detail-200.png"           1440 470
Shot "get-detail-404"        "04-get-detail-404.png"           1440 420
Shot "delete-204"            "05-delete-204.png"               1440 420
Shot "get-daftar-setelah"    "06-get-daftar-setelah-delete.png" 1440 2200

"--- server log ---"
Get-Content (Join-Path $log "server.log") -Encoding utf8
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force
"server dimatikan"


