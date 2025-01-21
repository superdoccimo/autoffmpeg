# FFmpeg Automatic Installation Script

This PowerShell script automates the installation of FFmpeg on Windows systems. It handles downloading, extraction, and environment variable setup automatically.

## Features

- Downloads FFmpeg from official BtbN builds
- Automatically sets up environment variables
- Removes existing installations if present (safe for reinstallation)
- Provides clear status messages during installation
- Verifies installation success

## Requirements

- Windows 10/11
- PowerShell (Run as Administrator)
- Internet connection

## Usage

1. Save the script as `install_ffmpeg.ps1`
2. Open PowerShell as Administrator
3. If needed, set execution policy:
    ```powershell
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    ```
4. Run the script:
    ```powershell
    .\install_ffmpeg.ps1
    ```
5. Verify installation:
    ```powershell
    ffmpeg -version
    ```

## Important Note After Installation

After running the script:
1. Close the current PowerShell window
2. Open a new PowerShell window
3. Then verify the installation with `ffmpeg -version`

This restart is necessary for the environment variable changes to take effect.

## Reinstallation

The script can be used for reinstallation purposes:

Automatically removes existing FFmpeg installation
Updates to the latest version
Reconfigures environment variables
No manual cleanup required

Security Notes

Script should be run with administrator privileges
Review the script content before execution
Downloads from trusted source (BtbN's FFmpeg builds)

Troubleshooting

If FFmpeg command is not recognized after installation, restart PowerShell
Check if PATH environment variable is correctly set
Ensure you have proper permissions for Program Files directory

References

Official FFmpeg Website: https://www.ffmpeg.org/

BtbN FFmpeg Builds: https://github.com/BtbN/FFmpeg-Builds/releases

Additional Resources
[Coming Soon]

Blog Article
Blog Article (Japanese)
Blog Article (Hindi)
YouTube Tutorial
YouTube Tutorial (Japanese)

License
MIT License
Author
[Your Name/Handle]
Contributing
Contributions are welcome! Please feel free to submit a Pull Request.