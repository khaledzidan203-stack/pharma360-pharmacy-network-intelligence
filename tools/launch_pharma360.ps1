[CmdletBinding()]
param([switch]$VerifyOnly, [switch]$ConfigureOnly)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-EncodedFile([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    $offset = 0
    $enc = New-Object Text.UTF8Encoding($false, $true)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 239 -and $bytes[1] -eq 187 -and $bytes[2] -eq 191) {
        $offset = 3; $enc = New-Object Text.UTF8Encoding($true, $true)
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 255 -and $bytes[1] -eq 254) {
        $offset = 2; $enc = New-Object Text.UnicodeEncoding($false, $true, $true)
    } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 254 -and $bytes[1] -eq 255) {
        $offset = 2; $enc = New-Object Text.UnicodeEncoding($true, $true, $true)
    }
    return @{ Bytes = $bytes; Encoding = $enc; Text = $enc.GetString($bytes, $offset, $bytes.Length - $offset) }
}

function Invoke-Pharma360([string]$Root, [switch]$VerifyOnly, [switch]$ConfigureOnly) {
    $rootPath = [IO.Path]::GetFullPath($Root)
    $pbip = Join-Path $rootPath 'powerbi\Pharma_Category_Management_POC.pbip'
    $definition = Join-Path $rootPath 'powerbi\Pharma_Category_Management_POC.SemanticModel\definition'
    $expressionPath = Join-Path $definition 'expressions.tmdl'
    foreach ($path in @($pbip, $expressionPath)) {
        if (-not [IO.File]::Exists($path)) { throw "Required project file missing: $path. Extract or clone the complete repository." }
    }
    $source = Read-EncodedFile $expressionPath
    $parameter = [regex]::new('(?m)^(\s*expression\s+PharmaDataRoot\s*=\s*)"((?:[^"\r\n]|"")*)"(?=\s+meta\s*\[)')
    $parameterMatches = $parameter.Matches($source.Text)
    if ($parameterMatches.Count -ne 1) { throw 'Expected exactly one PharmaDataRoot text parameter; no changes made.' }
    $current = $parameterMatches[0].Groups[2].Value.Replace('""', '"')
    $dataRoot = [IO.Path]::GetFullPath((Join-Path $rootPath 'data')).Replace('\', '/')
    $imports = @()
    $importPattern = [regex]::new('File\.Contents\(\s*PharmaDataRoot\s*&\s*"([^"\r\n]+)"\s*\)')
    foreach ($table in Get-ChildItem -LiteralPath (Join-Path $definition 'tables') -Filter '*.tmdl' -File) {
        $text = (Read-EncodedFile $table.FullName).Text
        $found = $importPattern.Matches($text)
        if ([regex]::Matches($text, 'File\.Contents\s*\(').Count -ne $found.Count) {
            throw "Unsupported File.Contents composition in $($table.Name); no changes made."
        }
        foreach ($match in $found) {
            $suffix = $match.Groups[1].Value.Replace('\', '/')
            if (-not $suffix.StartsWith('/') -or $suffix -match '(^|/)\.\.(/|$)' -or $suffix -notmatch '\.parquet$') {
                throw "Unsupported data suffix: $suffix"
            }
            $candidate = [IO.Path]::GetFullPath((Join-Path $dataRoot $suffix.TrimStart('/')))
            if (-not $candidate.StartsWith($dataRoot.Replace('/', '\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
                throw "Source path escapes data directory: $suffix"
            }
            $imports += $candidate
        }
    }
    $imports = @($imports | Sort-Object -Unique)
    if ($imports.Count -eq 0) { throw 'No supported Parquet imports found; no changes made.' }
    $missing = @($imports | Where-Object { -not [IO.File]::Exists($_) })
    if ($missing.Count -gt 0) { throw ("Missing required Parquet source(s). Restore the complete data folder:`n" + ($missing -join "`n")) }
    Write-Output "PBIP=$pbip"
    Write-Output "REQUIRED_PARQUETS=$($imports.Count) ALL_PRESENT"
    Write-Output "CURRENT_DATA_ROOT=$current"
    Write-Output "EXPECTED_DATA_ROOT=$dataRoot"
    $needsChange = -not [string]::Equals($current.Replace('\', '/').TrimEnd('/'), $dataRoot, [StringComparison]::OrdinalIgnoreCase)
    if ($VerifyOnly) {
        if ($needsChange) { Write-Output 'STATUS=PASS PATH_UPDATE_REQUIRED_ON_LAUNCH' }
        else { Write-Output 'STATUS=PASS NO_CHANGES' }
        return
    }
    if ($needsChange) {
        if (@(Get-Process -Name PBIDesktop -ErrorAction SilentlyContinue).Count -gt 0) {
            throw 'Close Power BI Desktop before changing PharmaDataRoot, then rerun the launcher. No changes made.'
        }
        $newValue = $dataRoot.Replace('"', '""')
        $m = $parameterMatches[0].Groups[2]
        $updated = $source.Text.Substring(0, $m.Index) + $newValue + $source.Text.Substring($m.Index + $m.Length)
        $backupDirectory = Join-Path $rootPath 'qa\_rollback\launcher'
        [IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
        $backup = Join-Path $backupDirectory ('expressions.' + [guid]::NewGuid().ToString('N') + '.tmdl.bak')
        [IO.File]::WriteAllBytes($backup, $source.Bytes)
        $writeStarted = $false
        try {
            $now = [IO.File]::ReadAllBytes($expressionPath)
            if ([Convert]::ToBase64String($now) -ne [Convert]::ToBase64String($source.Bytes)) { throw 'Parameter file changed concurrently.' }
            $bytes = [byte[]]($source.Encoding.GetPreamble() + $source.Encoding.GetBytes($updated))
            $writeStarted = $true
            [IO.File]::WriteAllBytes($expressionPath, $bytes)
            $check = Read-EncodedFile $expressionPath
            if ($check.Text -cne $updated) { throw 'Parameter write verification failed.' }
        } catch {
            if ($writeStarted) { [IO.File]::WriteAllBytes($expressionPath, $source.Bytes) }
            throw "Configuration failed; original parameter file restored. $($_.Exception.Message)"
        }
        Write-Output "CONFIGURED_DATA_ROOT BACKUP=$backup"
    } else { Write-Output 'NO_CHANGES' }
    if ($ConfigureOnly) { return }
    try { Start-Process -FilePath $pbip -ErrorAction Stop | Out-Null }
    catch { throw "Configuration is ready, but Windows could not open the PBIP. Install Power BI Desktop and associate .pbip files. $($_.Exception.Message)" }
    Write-Output 'OPEN_REQUESTED: Refresh, Save, Close and Reopen require owner Desktop QA.'
}

if ($MyInvocation.InvocationName -ne '.') {
    try { Invoke-Pharma360 -Root (Split-Path $PSScriptRoot -Parent) -VerifyOnly:$VerifyOnly -ConfigureOnly:$ConfigureOnly }
    catch { Write-Error $_ -ErrorAction Continue; exit 1 }
}
