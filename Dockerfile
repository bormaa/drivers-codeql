# escape=`

# Use the latest Windows Server Core 2022 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022
# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Workload.AzureBuildTools `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
        --remove Microsoft.VisualStudio.Component.Windows81SDK `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe
# Add additional commands here
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Set execution policy and install Chocolatey
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Git using Chocolatey
RUN choco install git -y

# Install Cmake using Chocolatey
RUN choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System' -y
# Creating new folder for codeql-home and navigate to it
RUN mkdir CodeQL-Home
WORKDIR C:\CodeQL-Home

# Download codeql and extract file
RUN Invoke-WebRequest -Uri 'https://github.com/github/codeql-cli-binaries/releases/download/v2.6.3/codeql-win64.zip' -OutFile 'codeql-win64.zip' -ErrorAction Stop -UseBasicParsing

RUN Expand-Archive -Path 'codeql-win64.zip' -DestinationPath 'C:\CodeQL-Home'

# Delete the zip file
RUN Remove-Item 'codeql-win64.zip'

# Clone the Windows-Driver-Developer-Supplemental-Tools repo
RUN git clone https://github.com/microsoft/Windows-Driver-Developer-Supplemental-Tools.git

# Go to codeql dir and install the pack
WORKDIR C:\CodeQL-Home\codeql
RUN .\codeql pack install C:\codeql-home\Windows-Driver-Developer-Supplemental-Tools\src

# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
