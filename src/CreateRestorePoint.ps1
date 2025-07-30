# Prompt user for a restore point name
$rpName = Read-Host "Enter a name for the restore point"

# Create the restore point
Checkpoint-Computer -Description $rpName -RestorePointType MODIFY_SETTINGS

# Confirm and wait
Write-Host "Restore point '$rpName' created successfully." -ForegroundColor Green
Start-Sleep -Seconds 5