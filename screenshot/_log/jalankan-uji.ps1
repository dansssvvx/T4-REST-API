# Menjalankan server lalu menguji semua endpoint dengan curl.
# Hasil nyata (status + body) disimpan ke screenshot/_log/*.txt
$ErrorActionPreference = "Stop"
$root = "D:\College\S7\Pemrograman  Web Lanjut\Tugas\Tugas 4 REST API"
$log  = Join-Path $root "screenshot\_log"
New-Item -ItemType Directory -Force -Path $log | Out-Null
Get-ChildItem $log -Filter "*.txt" | Remove-Item -Force

$server = Start-Process -FilePath "npm.cmd" -ArgumentList "run","dev" `
    -WorkingDirectory $root -PassThru -NoNewWindow `
    -RedirectStandardOutput (Join-Path $log "server.log") `
    -RedirectStandardError  (Join-Path $log "server.err.log")

for ($i = 0; $i -lt 40; $i++) {
    try { Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing -TimeoutSec 2 | Out-Null; break }
    catch { Start-Sleep -Milliseconds 500 }
}
Start-Sleep -Milliseconds 800

function Uji($nama, $method, $url) {
    $tmp = Join-Path $log "_tmp-body.txt"
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
    $status = & curl.exe -s -o $tmp -w "%{http_code}" -X $method $url
    $body = ""
    if (Test-Path $tmp) { $body = (Get-Content $tmp -Raw -Encoding utf8) }
    if ($null -eq $body) { $body = "" }
    @(
        "METHOD : $method",
        "URL    : $url",
        "STATUS : $status",
        "BODY   :",
        $body.TrimEnd()
    ) | Set-Content -Path (Join-Path $log "$nama.txt") -Encoding utf8
    $potong = if ($body.Length -gt 80) { $body.Substring(0, 80) + "..." } else { $body }
    "$status  $method $url  ->  $potong"
}

Uji "02-get-daftar"         "GET"    "http://localhost:3000/tanaman"
Uji "03-get-detail-200"     "GET"    "http://localhost:3000/tanaman/3"
Uji "04-get-detail-404"     "GET"    "http://localhost:3000/tanaman/999"
Uji "05-delete-204"         "DELETE" "http://localhost:3000/tanaman/5"
Uji "06-get-daftar-setelah" "GET"    "http://localhost:3000/tanaman"
Uji "07-delete-404"         "DELETE" "http://localhost:3000/tanaman/5"
Uji "08-get-root"           "GET"    "http://localhost:3000/"
Remove-Item (Join-Path $log "_tmp-body.txt") -Force -ErrorAction SilentlyContinue

"--- server log ---"
Get-Content (Join-Path $log "server.log") -Encoding utf8

if ($env:MATIKAN_SERVER -ne "0") {
    & taskkill /PID $server.Id /T /F | Out-Null
    "server dimatikan"
}
