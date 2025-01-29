##############################################################################
# install_ffmpeg.ps1
#  - Downloads FFmpeg from GitHub (BtbN/FFmpeg-Builds)
#  - Extracts and installs to "C:\Program Files\ffmpeg"
#  - Adds "...\bin" to the machine PATH (if not already present)
#  - Requires Administrator privileges
##############################################################################

# === Configuration (adjust if needed) ===
$ffmpegUrl      = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip"
$tempZip        = Join-Path $env:TEMP "ffmpeg.zip"
$tempExtractDir = Join-Path $env:TEMP "temp_ffmpeg_extract"
$installDir     = Join-Path $env:ProgramFiles "ffmpeg"

Write-Host ""
Write-Host "=== Starting FFmpeg installation script ==="
Write-Host ""

# ----------------------------------------------------------------------------
# 1) Remove any existing FFmpeg installation
# ----------------------------------------------------------------------------
try {
    if (Test-Path $installDir) {
        Write-Host "Removing existing FFmpeg installation from: $installDir"
        Remove-Item -Path $installDir -Recurse -Force
        Write-Host "Existing FFmpeg installation removed."
    } else {
        Write-Host "No existing FFmpeg installation found."
    }
}
catch {
    Write-Error "Failed to remove existing FFmpeg. Error: $($_.Exception.Message)"
    exit 1
}

# ----------------------------------------------------------------------------
# 2) Download the ZIP file
# ----------------------------------------------------------------------------
try {
    Write-Host ""
    Write-Host "Downloading FFmpeg from: $ffmpegUrl"
    Invoke-WebRequest -Uri $ffmpegUrl -OutFile $tempZip -UseBasicParsing
    Write-Host "Download completed: $tempZip"
}
catch {
    Write-Error "Failed to download FFmpeg. Error: $($_.Exception.Message)"
    exit 1
}

# ----------------------------------------------------------------------------
# 3) Extract the ZIP file to a temporary folder
# ----------------------------------------------------------------------------
try {
    Write-Host ""
    Write-Host "Preparing temporary extraction folder: $tempExtractDir"
    if (Test-Path $tempExtractDir) {
        Remove-Item $tempExtractDir -Recurse -Force
    }
    New-Item -Path $tempExtractDir -ItemType Directory | Out-Null

    Write-Host "Extracting ZIP file..."
    Expand-Archive -Path $tempZip -DestinationPath $tempExtractDir -Force
    Write-Host "Extraction completed."
}
catch {
    Write-Error "Failed to extract FFmpeg. Error: $($_.Exception.Message)"
    exit 1
}

# ----------------------------------------------------------------------------
# 4) Move the extracted files to the install folder (flattened)
# ----------------------------------------------------------------------------
try {
    Write-Host ""
    Write-Host "Creating install folder: $installDir"
    if (!(Test-Path $installDir)) {
        New-Item -Path $installDir -ItemType Directory | Out-Null
    }

    # In many cases, the ZIP creates a single subfolder named something like:
    # "ffmpeg-master-latest-win64-gpl-shared"
    $subDirs = Get-ChildItem -Path $tempExtractDir -Directory

    if ($subDirs.Count -eq 1) {
        Write-Host "Found a single subfolder. Moving its contents..."
        $contentPath = Join-Path $subDirs[0].FullName "*"
        Move-Item -Path $contentPath -Destination $installDir
    }
    else {
        Write-Host "Multiple or zero subfolders found. Moving all contents..."
        Move-Item -Path (Join-Path $tempExtractDir "*") -Destination $installDir
    }

    Write-Host "Files moved to: $installDir"
}
catch {
    Write-Error "Failed to move FFmpeg files. Error: $($_.Exception.Message)"
    exit 1
}

# ----------------------------------------------------------------------------
# 5) Update machine-level PATH if needed
# ----------------------------------------------------------------------------
try {
    $binPath = Join-Path $installDir "bin"
    if (!(Test-Path $binPath)) {
        Write-Error "FFmpeg bin folder not found: $binPath"
        exit 1
    }

    Write-Host ""
    Write-Host "Checking PATH for FFmpeg bin folder..."

    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $pathItems   = $machinePath -split ";"

    # Normalize bin path (resolve short/long path differences)
    $normalizedBinPath = (Get-Item $binPath).FullName.TrimEnd("\")
    $alreadyExists = $false

    foreach ($item in $pathItems) {
        try {
            $normalizedItem = (Get-Item $item).FullName.TrimEnd("\")
            if ([String]::Compare($normalizedItem, $normalizedBinPath, $true) -eq 0) {
                $alreadyExists = $true
                break
            }
        }
        catch {
            # Ignore any parse errors (e.g. system variables that are not real paths)
        }
    }

    if (-not $alreadyExists) {
        Write-Host "Adding FFmpeg bin folder to PATH..."
        $newPath = $machinePath + ";" + $normalizedBinPath
        [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Host "FFmpeg bin folder added to PATH."
    }
    else {
        Write-Host "FFmpeg bin folder is already in PATH."
    }
}
catch {
    Write-Error "Failed to update PATH. Error: $($_.Exception.Message)"
    exit 1
}

# ----------------------------------------------------------------------------
# 6) Clean up temporary files
# ----------------------------------------------------------------------------
try {
    Write-Host ""
    Write-Host "Cleaning up temporary files..."
    if (Test-Path $tempZip) {
        Remove-Item $tempZip -Force
    }
    if (Test-Path $tempExtractDir) {
        Remove-Item $tempExtractDir -Recurse -Force
    }
    Write-Host "Temporary files removed."
}
catch {
    Write-Warning "Failed to remove temporary files, but this is not critical."
}

Write-Host ""
Write-Host "=== FFmpeg installation completed successfully! ==="
Write-Host "Please restart PowerShell or CMD to use ffmpeg.exe."
Write-Host ""