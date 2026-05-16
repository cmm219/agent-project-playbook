param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"
$failed = $false

function Add-Failure {
    param([string]$Message)
    Write-Error $Message -ErrorAction Continue
    $script:failed = $true
}

function Get-TextFiles {
    param([string]$Base)

    $binaryExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".ico", ".pdf", ".zip", ".gz", ".tgz")
    Get-ChildItem -LiteralPath $Base -Recurse -File -Force |
        Where-Object {
            $_.FullName -notmatch "[\\/]\.git[\\/]" -and
            $binaryExtensions -notcontains $_.Extension.ToLowerInvariant()
        }
}

function Get-RelativePath {
    param([string]$Base, [string]$Path)

    $baseFull = [System.IO.Path]::GetFullPath($Base).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $pathFull = [System.IO.Path]::GetFullPath($Path)

    if ($pathFull.StartsWith($baseFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $pathFull.Substring($baseFull.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    }

    return $pathFull
}

function Search-Pattern {
    param([string]$Pattern, [string]$Label)

    $hits = @()
    foreach ($file in Get-TextFiles -Base $Root) {
        $found = Select-String -LiteralPath $file.FullName -Pattern $Pattern -AllMatches -ErrorAction SilentlyContinue
        foreach ($match in $found) {
            $relative = Get-RelativePath -Base $Root -Path $file.FullName
            $hits += "${relative}:$($match.LineNumber):$($match.Line.Trim())"
        }
    }

    if ($hits.Count -gt 0) {
        Add-Failure "$Label`n$($hits -join "`n")"
    }
}

$windowsUsers = "C:" + [char]92 + "Users"
$windowsDevNotes = "Dev" + [char]92 + "notes"
$macUsers = "/" + "Users" + "/"
$linuxHome = "/" + "home" + "/"
$tokenPattern = ("g" + "hp_") + "[A-Za-z0-9]|" + ("xo" + "x") + "[baprs]-|" + ("AK" + "IA") + "[0-9A-Z]{16}|" + "-----BEGIN " + "(RSA|OPENSSH|EC|DSA) " + ("PRI" + "VATE") + " KEY-----"

Search-Pattern ([regex]::Escape($windowsUsers)) "Found Windows user path"
Search-Pattern ([regex]::Escape($macUsers)) "Found macOS user path"
Search-Pattern ([regex]::Escape($linuxHome)) "Found Linux home path"
Search-Pattern ([regex]::Escape($windowsDevNotes)) "Found local notes path"
Search-Pattern $tokenPattern "Found token/private-key pattern"

$forbiddenDirs = @("control", "tasks", "sessions")
foreach ($dir in $forbiddenDirs) {
    $path = Join-Path $Root $dir
    if (Test-Path -LiteralPath $path) {
        Add-Failure "Forbidden private-state directory exists at repo root: $dir"
    }
}

$localDenylist = Join-Path $Root ".sanitize-denylist.local"
if (Test-Path -LiteralPath $localDenylist) {
    $patterns = Get-Content -LiteralPath $localDenylist | Where-Object {
        $trimmed = $_.Trim()
        $trimmed -and -not $trimmed.StartsWith("#")
    }
    foreach ($pattern in $patterns) {
        Search-Pattern ([regex]::Escape($pattern)) "Found local denylist term: $pattern"
    }
}

if ($failed) {
    exit 1
}

Write-Output "Sanitize check passed."
