
# variables
$osprovisionFilePath = "C:\Users\WDAGUtilityAccount\Desktop\AI_Home\bin\osprovision.exe"
$dataExchangeFilePath = "C:\Users\WDAGUtilityAccount\Desktop\AI_Output\DataExchangeFile.json"
$dataExchangeKeyPath = "HKLM:\Software\Caphyon\Advanced Installer Remote Tools\External"

Write-Host "Launching Advanced Installer Remote Tools installer ..."
$process = Start-Process -FilePath $osprovisionFilePath -ArgumentList "/qb" -PassThru -Wait

if ($process.ExitCode -ne 0) {
    Write-Host "[AI ERROR] Advanced Installer Remote Tools installer could not be launched. Error code: $($process.ExitCode)."
} else {
    Write-Host "[AI INFO] Advanced Installer Remote Tools installer was launched successfully."

    Write-Host "[AI INFO] Waiting for RexecServer service to start..."
    Wait-Service -Name 'RexecServer' -Status Running

    Write-Host "[AI INFO] Exporting data exchange info ..."

    $registryValues = Get-ItemProperty -Path $dataExchangeKeyPath | Select-Object -Property * -Exclude PS*

    $jsonObject = ConvertTo-Json -InputObject $registryValues
    $jsonObject | Out-File -FilePath $dataExchangeFilePath 
}
