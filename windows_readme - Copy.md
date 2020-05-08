# Windows 10 Provision and Configuration Steps
The aim of this repository is to create a reusable pattern that enables a fast spin up of windows 10 desktop environments with application exe available .  

## Prerequisites

## How To Use
Optional

Import "Add_PS1_Run_as_administrator.reg" to your registry to enable context menu on the powershell files to run as Administrator.  
  

## Table of Application and resources

| Name | URL | Manually Configured | In Script/Choco |
|-------|-----|---------------------|-----------|
| 7zip 				   | choco| x | Choco |
| PC Drivers (Metabox) | | x |  **Choco** |
| Microsoft Updates    | | x | **script** |
| Firefox              | | x |  **Choco** |
| Make Firefox Default | | x |  **Choco** |
| Add Account		   | | x |  Choco |
| Keepass 			   | | x |  **Choco** |
| Google Drive Sync	   | | x |  **Choco** |
| SSH keys			   | | x |  github |
| WSL (App Store)	   | | x |  **Choco** |
| Enable WSL		   | | x |  **Script** |
| VS Code			   | | x |  **Choco** |
| Docker			   | | x |  **Choco** |
| Vagrant			   | | x |  **Choco** |
| pyenv				   | |  |  **Choco** |
| pyenv-virtualenv	   | |  |  Might not be available for win |
| python 3.8.2		   | |  |  **Script** |
| Office			   | | x | **Choco** |
| Unifi Controller	   | |  |  **Choco** |
| github Repos		   | |  |  Choco |
| VLC				   | |  |  **Choco** |

## Configuration Changes

| Type | description |
|------|---------------|
| Hostname | Prompts user to create their hostname |
| Timeout | Disable sleep on AC Power |

## Best Practices
- Run applications and environments within Docker
- Ensure every project has a repo that includes a Dockerfile & Vagrantfile if necessary
	- Django
	- Python
	- Node
	- React
	- Ansible
	- Tutorials
	- LAMP stack
	- sqlite
	- MongoDB

## TODOs
1. Get familiar with working within docker environments (spinning them up, operating inside of it, mounting volumes etc)
2. Setup windows docker to test script
3. Make Script Idempotent
4. Learn how to use powershell 