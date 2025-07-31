param(
    [string]$SourceDir
)
Add-Type -AssemblyName System.Windows.Forms

# =============================
# CONFIG: Define source folder for original files
# =============================
# Set the source directory containing the actual files to be linked.

# Fallback if none passed (optional)
if (-not $SourceDir -or -not (Test-Path $SourceDir)) {
    $SourceDir = Get-Location
}


# =============================
# FUNCTION: Folder picker that defaults to C:\Scripts
# =============================
function Select-Folder {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.InitialDirectory = "C:\Scripts"
    $dialog.Title = "Select a folder for symlinks"
    $dialog.FileName = "Select Folder"
    $dialog.CheckFileExists = $false

    if ($dialog.ShowDialog() -eq "OK") {
        return Split-Path $dialog.FileName
    } else {
        return $null
    }
}

# =============================
# STEP 1: Display list of available source files
# =============================
$AllFiles = Get-ChildItem -Path $SourceDir -File

if ($AllFiles.Count -eq 0) {
    Write-Host "❌ No files found in source folder: $SourceDir"
    exit
}

Write-Host "`nAvailable files to link FROM '$SourceDir':"
$AllFiles | ForEach-Object -Begin { $i = 0 } -Process {
    Write-Host "[$i] $($_.Name)"
    $i++
}

# =============================
# STEP 2: Prompt user to select which files to link
# =============================
$Indexes = Read-Host "`nEnter the numbers of the files you want to symlink (comma-separated)"
$SelectedIndexes = $Indexes -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }

$SelectedFiles = @()
foreach ($index in $SelectedIndexes) {
    if ($index -lt 0 -or $index -ge $AllFiles.Count) {
        Write-Host "⚠️ Invalid index: $index. Skipping."
        continue
    }
    $SelectedFiles += $AllFiles[$index]
}

if ($SelectedFiles.Count -eq 0) {
    Write-Host "❌ No valid files selected. Exiting."
    exit
}

# =============================
# STEP 3: Ask user to choose the destination folder
# =============================
$TargetDir = Select-Folder

if (-not $TargetDir -or -not (Test-Path $TargetDir)) {
    Write-Host "❌ No folder selected. Exiting."
    exit
}

# =============================
# STEP 4: Create symlinks in the selected destination
# =============================
foreach ($file in $SelectedFiles) {
    $SourcePath = $file.FullName
    $LinkPath = Join-Path $TargetDir $file.Name

    if (Test-Path $LinkPath) {
        Write-Host "⏭️  Link already exists: $LinkPath (skipped)"
        continue
    }

    New-Item -ItemType SymbolicLink -Path $LinkPath -Target $SourcePath | Out-Null
    Write-Host "✅ Created symlink: $LinkPath → $SourcePath"
}
