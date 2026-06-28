# ============================================================================
# AnyCMS SSG — installer for Windows (PowerShell).
#   iwr -useb https://anycms.org/install.ps1 | iex
#
# Downloads the prebuilt x86_64-msvc binary from https://anycms.org/dl/ into
# $env:ANYCMS_INSTALL_DIR (default $env:LOCALAPPDATA\anycms\bin), adds it to
# the user PATH if missing, and prints next steps.
# ============================================================================
$ErrorActionPreference = 'Stop'

$Version    = '0.1.0'
$Base       = 'https://anycms.org/dl'
$Triple     = 'x86_64-pc-windows-msvc'
$Archive    = "anycms-$Version-$Triple.zip"
$Url        = "$Base/$Archive"
$Staged     = "anycms-$Version-$Triple"

if ($env:ANYCMS_INSTALL_DIR) {
  $InstallDir = $env:ANYCMS_INSTALL_DIR
} else {
  $InstallDir = Join-Path $env:LOCALAPPDATA 'anycms\bin'
}

function Write-Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host $msg -ForegroundColor Green }

Write-Step "Installing AnyCMS v$Version ($Triple)"
Write-Host "    $Url"

# --- download ---------------------------------------------------------------
$tmp = Join-Path $env:TEMP ("anycms-install-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$zip = Join-Path $tmp $Archive

try {
  Invoke-WebRequest -Uri $Url -OutFile $zip -UseBasicParsing
} catch {
  throw "Download failed: $($_.Exception.Message)"
}

# --- extract + install ------------------------------------------------------
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $tmp)

$src = Join-Path $tmp (Join-Path $Staged 'anycms.exe')
if (-not (Test-Path $src)) {
  throw "Archive did not contain $Staged\anycms.exe."
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$dest = Join-Path $InstallDir 'anycms.exe'
Copy-Item $src $dest -Force
Remove-Item -Recurse -Force $tmp

Write-Host ""
Write-Step "Installed to $dest"

# --- add to user PATH if missing -------------------------------------------
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -and ($userPath.Split(';') -notcontains $InstallDir)) {
  $newPath = if ($userPath) { "$userPath;$InstallDir" } else { $InstallDir }
  [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
  $env:Path = "$env:Path;$InstallDir"
  Write-Host "Added $InstallDir to your user PATH (open a new terminal for it to take effect)." -ForegroundColor Yellow
}

# Best-effort version check.
try { & $dest --version } catch { }

Write-Host ""
Write-Ok "Done. Next: anycms init my-site"
