# Define variables
$repoUrl = "https://codeload.github.com/DuseTrive/System-Info-Reporter/zip/refs/heads/master"
$downloadPath = "$env:TEMP\SystemInfoGather.zip"
$extractPath = "$env:TEMP\SystemInfoGather"
$expectedChecksum = "b5c50b6f608fbcdf9fcb3f3da9f93e68ee93a5339f107581fcc2f1d09fe5916e"
$outputDirectory = "$env:USERPROFILE\Desktop\SystemInfoReport"

# Function to calculate checksum
function Get-FileChecksum {
    param (
        [string]$filePath
    )
    $hashAlgorithm = [System.Security.Cryptography.SHA256]::Create()
    $fileStream = [System.IO.File]::OpenRead($filePath)
    $hashBytes = $hashAlgorithm.ComputeHash($fileStream)
    $fileStream.Close()
    return [BitConverter]::ToString($hashBytes) -replace "-", ""
}

# Download the repository
Write-Output "Downloading System Info Gather..."
Invoke-WebRequest -Uri $repoUrl -OutFile $downloadPath
Write-Output "Downloaded to: $env:TEMP\SystemInfoGather.zip"
Start-Sleep 2

# Validate checksum
$actualChecksum = Get-FileChecksum -filePath $downloadPath
if ($actualChecksum -ne $expectedChecksum) {
    Write-Output "Checksum validation failed. The file may be corrupted."
    Exit 1
}

Write-Output "Checksum verified successfully."
Start-Sleep 2

# Extract the archive
Write-Output "Extracting files..."
Write-Output "Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force"
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
Start-Sleep 2
Write-Output "outputDirector = $outputDirectory"
Start-Sleep 2

# Navigate to the extracted folder
$scriptPath = Get-ChildItem -Path $extractPath -Filter "SystemInfoGather.lnk" -Recurse | Select-Object -ExpandProperty FullName

if (-not $scriptPath) {
    Write-Output "Error: Could not find SystemInfoGather.lnk"
    Exit 1
} else {
    Write-Output "ScriptPath: $scriptPath"
}

# Create output directory if it doesn't exist
if (!(Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

Write-Output "changing dir to $extractPath"
Push-Location
Set-Location "$extractPath\System-Info-Reporter-master"
# Run the script
Write-Output "Running the System Info Gather script..."
Start-Process -FilePath $scriptPath -ArgumentList $outputDirectory -Wait

Write-Output "System information collection complete. The report is saved in $outputDirectory"
Pop-Location
