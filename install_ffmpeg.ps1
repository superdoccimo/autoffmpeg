# This script must be run as an administrator

# Download URL
$ffmpegUrl = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip"

# Temporary download path
$tempZip = "$env:TEMP\ffmpeg.zip"

# Installation directory
$installDir = "$env:ProgramFiles\ffmpeg"

# If an existing installation exists, remove it
if (Test-Path -Path $installDir) {
    Write-Output "Removing existing FFmpeg installation..."
    try {
        Remove-Item -Path $installDir -Recurse -Force
        Write-Output "Existing FFmpeg has been removed."
    } catch {
        Write-Error "Failed to remove existing FFmpeg. Exiting script."
        exit 1
    }
}

# Download FFmpeg
Write-Output "Downloading FFmpeg..."
try {
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $tempZip -UseBasicParsing
    Write-Output "Download completed."
} catch {
    Write-Error "Failed to download FFmpeg."
    exit 1
}

# Extract the ZIP file
Write-Output "Extracting FFmpeg..."
try {
    Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
    Write-Output "Extraction completed."
} catch {
    Write-Error "Failed to extract FFmpeg."
    exit 1
}

# Get the extracted folder name (may vary depending on the version)
$extractedFolder = Get-ChildItem -Path $installDir -Directory | Sort-Object -Descending | Select-Object -First 1

# Path to the bin folder
$binPath = "$($extractedFolder.FullName)\bin"

# Add to the PATH environment variable
$envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

if ($envPath -notlike "*$binPath*") {
    Write-Output "Adding FFmpeg to PATH..."
    try {
        [System.Environment]::SetEnvironmentVariable("Path", "$envPath;$binPath", [System.EnvironmentVariableTarget]::Machine)
        Write-Output "FFmpeg has been added to PATH."
    } catch {
        Write-Error "Failed to add FFmpeg to PATH."
        exit 1
    }
} else {
    Write-Output "FFmpeg path is already set."
}

# Clean up the temporary ZIP file
Remove-Item -Path $tempZip -Force

Write-Output "Installation completed. Please restart PowerShell to use FFmpeg."
