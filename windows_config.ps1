#----------------------------------------------------------------------------
$python_version = "3.8.2"
# TODO: Make Script Idempotent
powershell.exe -NoLogo -NoProfile -Command 'Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber'
#-----------------------------------------------------------------------------
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent())`
    .IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
    exit 
}

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# -----------------------------------------------------------------------------
$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Powercfg /Change monitor-timeout-ac 20
Powercfg /Change standby-timeout-ac 0

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Removing Edge Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$edgeLink = $env:USERPROFILE + "\Desktop\Microsoft Edge.lnk"
Remove-Item $edgeLink
# TODO: Remove taskbar shortcut too
# TODO: Remove Microsoft Store shortcut
# -----------------------------------------------------------------------------
# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
    "Microsoft.Messaging",
    "king.com.CandyCrushSaga",
    "Microsoft.BingNews",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.MicrosoftOfficeHub",
    "Fitbit.FitbitCoach",
    "4DF9E0F8.Netflix",
    "Microsoft.GetHelp")

foreach ($uwp in $uwpRubbishApps) {
    Get-AppxPackage -Name $uwp | Remove-AppxPackage
}
# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Installing IIS..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionDynamic -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ServerSideIncludes
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Windows 10 Developer Mode..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# -----------------------------------------------------------------------------
Write-Host ""
Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

#------------------------------------------------------------------------------
Read-Host "Enable WSL"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

#------------------------------------------------------------------------------
if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; 
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
    iex ((New-Object System.Net.WebClient).`
            DownloadString('https://chocolatey.org/install.ps1'))}

Install-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

if (Check-Command -cmdname 'git') {
    Write-Host "Git is already installed, checking new version..."
    choco update git -y
}
else {
    Write-Host ""
    Write-Host "Installing Git for Windows..." -ForegroundColor Green
    choco install git -y
}
Install-Module posh-git -Scope CurrentUser -Force
Import-Module posh-git
Add-PoshGitToProfile -AllHosts​​​​​​​

Write-Host "------------------------------------" -ForegroundColor Green
$chocoPackages = @(
    # Tools
    "vlc",
    "7zip.install",
    "wget",
    "sysinternals",
    "keepass",
    "openssl.light",
    # Developer Apps
    "vscode",
    "vscode-python",
    "github-desktop",
    "pyenv-win",
    # Virtualisations
    "virtualbox",
    "vagrant",
    "docker-desktop",
    "wsl-ubuntu-1804",
    # General Windows tools/Other
    "firefox",
    "office-tool",
    "google-backup-and-sync",
    "ubiquiti-unifi-controller"
)

foreach ($pkg in $chocoPackages) {
    choco install $pkg -y
}
Write-Host ""
Write-Host "Installing Python Version $pyVersion..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

if (-Not (Check-Command -cmdname 'pyenv')) {
    pyenv install 
else {
    $env:Path += ";%USERPROFILE%\.pyenv\pyenv-win\bin;%USERPROFILE%\.pyenv\pyenv-win\shims;"
    pyenv install 3.8.2
}
#-------------------------------------------------------------------------
Invoke-WebRequest -Uri `
    https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/PowerShell-7.0.0-win-x64.msi`
    -OutFile .\PS7.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I PS7.msi /quiet'

#-------------------------------------------------------------------------
Write-Host "Configuring SSH for Github"
Write-Host "---------------------------------"
ssh-keygen -b 4096 -t rsa -f $HOME\.ssh\samhiggs.metabox.github.id_rsa
Copy-Item config $HOME\.ssh\config #TODO: Turn this into a symlink if that's a thing?

# TODO: Format cURL to align with powershell command...More importantly, learn powershell
# $github_key = Get-Content $HOME\.ssh\samhiggs.metabox.github.id_rsa.pub
# curl -UserAgent "samhiggs" -Method "Post" -Body "{'title': 'test-key', 'key':$github_key}" https://api.github.com/user/key

# TODO: Add shortcuts to taskbar
#---------------------------------------------------------------------
& ${Env:ProgramFiles}\Mozilla Firefox\firefox.exe --make-default-browser

Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer