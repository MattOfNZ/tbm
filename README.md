# Tunnel Boring Machine (TBM)

A quick and easy way to set up an HTTP tunnel using Caddy + cloudflared.

Currently only available for Powershell.

## Powershell:  How to use

In an empty directory (eg `c:\tbm`), run this command:

```
$wc = New-Object System.Net.WebClient; $wc.Headers.Add("user-agent",$tbm); Invoke-Command -ScriptBlock  $([Scriptblock]::Create($wc.DownloadString("https://raw.githubusercontent.com/MattOfNZ/tbm/main/powershell/tbm.ps1")));
```

This will:

* Download the script from this repository
* Download caddy
* Download cloudflared
* Run you through a basic config script, allowing you to add basic auth to your endpoint
* Launch caddy and cloudflared

It's a lazy, no-signup NGROK alternative.

## Known bugs

Sometimes the GitHub API returns a 403, not sure why.  It works well enough for me.
