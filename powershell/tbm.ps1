$tbm = "Tunnel Boring Maching (TBM) 1.0"
Write-Output $tbm 

$wc = New-Object System.Net.WebClient;
$wc.Headers.Add("user-agent", $tbm)

if (![System.IO.File]::Exists("$pwd\caddy.exe")) {
    Write-Output "Downloading Caddy"
    $wc.DownloadFile("https://caddyserver.com/api/download?os=windows&arch=amd64", "$pwd\caddy.exe")
}

if (![System.IO.File]::Exists("$pwd\cloudflared.exe")) {
    Write-Output "Downloading cloudflared"
    $cloudflaredreleases = ConvertFrom-Json ( $wc.DownloadString("https://api.github.com/repos/cloudflare/cloudflared/releases/latest") )
    $cloudflared = $cloudflaredreleases.assets | where-object { $_.name -match "windows-amd64" -and $_.name -match ".exe"}
    $wc.DownloadFile("$($cloudflared.browser_download_url)", "$pwd\cloudflared.exe")
}


if (![System.IO.File]::Exists("$pwd\Caddyfile.template")) {
    Write-Output "Downloading Caddyfile template"
    $wc.DownloadFile("https://raw.githubusercontent.com/MattOfNZ/tbm/main/powershell/Caddyfile.template", "$pwd\Caddyfile.template")
}

$TBM_ORIGIN = Read-Host -Prompt 'Origin server'

$TBM_YES_NO  = '&yes', '&no'

$TBM_BASIC_AUTH = $Host.UI.PromptForChoice("", "Would you like to add basic auth?", $TBM_YES_NO, 1)
if ($TBM_BASIC_AUTH -eq 0) {
    $TBM_USERNAME_DEFAULT = "tbm"
    if (!($TBM_USERNAME = Read-Host "Basic auth username [$TBM_USERNAME_DEFAULT]")) { $TBM_USERNAME = $TBM_USERNAME_DEFAULT }
    $TBM_PASSWORD_DEFAULT = [guid]::NewGuid()
    if (!($TBM_PASSWORD = Read-Host "Basic auth password [$TBM_PASSWORD_DEFAULT]")) { $TBM_PASSWORD = $TBM_PASSWORD_DEFAULT }
    $TBM_PORT_DEFAULT = "7070"
    if (!($TBM_PORT = Read-Host "Basic auth reverse proxy port [$TBM_PORT_DEFAULT]")) { $TBM_PORT = $TBM_PORT_DEFAULT }

    $TBM_BASIC_AUTH_ORIGIN = $TBM_ORIGIN
    $TBM_ORIGIN = "http://localhost:$TBM_PORT_DEFAULT"

    $TBM_PASSWORD_HASH  = $(./caddy hash-password --plaintext $TBM_PASSWORD)

    (Get-Content "$pwd\Caddyfile.template") | Foreach-Object {
    $_ -replace '__TBM_PORT__', $TBM_PORT `
       -replace '__TBM_USERNAME__', $TBM_USERNAME`
       -replace '__TBM_PASSWORD_HASH__', $TBM_PASSWORD_HASH `
       -replace '__TBM_ORIGIN__', $TBM_BASIC_AUTH_ORIGIN
    } | Set-Content "$pwd\Caddyfile"
}


$TBM_READY = $Host.UI.PromptForChoice("", "Ready to launch?", $TBM_YES_NO, 1)


if ($TBM_READY -eq 0) {

    if ($TBM_BASIC_AUTH -eq 0) { 
        Write-Output "Starting caddy + cloudflared"

        Invoke-Expression 'cmd /c start powershell -Command { .\caddy run }'

    }

    .\cloudflared.exe tunnel --url $TBM_ORIGIN 

    if ($TBM_BASIC_AUTH -eq 0) { 
        Write-Output "(FYI:  Caddy launched in a new window)"
    }

} else {
    Write-Output "Server not started"
}
