Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "===  Automated WinGet/ChrisTitus Setup & Tweak Script       ===" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan

Write-Host "--> Checking for Winget installation..." -ForegroundColor Yellow

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "SUCCESS: Winget is already installed." -ForegroundColor Green
} else {
    Write-Host "INFO: Winget not found. Starting installation process..." -ForegroundColor Yellow
    try {
        Write-Host "--> Downloading the latest Winget installer..." -ForegroundColor Yellow
        $wingetInstallerPath = Join-Path -Path $env:TEMP -ChildPath "winget.msixbundle"
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $wingetInstallerPath -ErrorAction Stop

        Write-Host "--> Installing Winget..." -ForegroundColor Yellow
        Add-AppxPackage -Path $wingetInstallerPath -ErrorAction Stop
        
        Write-Host "SUCCESS: Winget has been installed." -ForegroundColor Green
    } catch {
        Write-Error "FATAL: Winget installation failed. Aborting script."
        return # Stop the script if installation fails
    }
}

Write-Host "`n--> Verifying Winget is ready..." -ForegroundColor Yellow
winget --version

Write-Host "`n" # Adds a blank line for spacing
Write-Host "Press ANY KEY to continue and launch the Chris Titus utility..." -ForegroundColor Magenta
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null

Write-Host "`n--> Launching the Chris Titus utility..." -ForegroundColor Cyan
irm "https://christitus.com/win" | iex

Write-Host "`nScript finished." -ForegroundColor Green