@echo off

if “%1%” == “precustomization” (
@rem First Boot
echo Do precustomization tasks
cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm quickconfig -transport:http
cmd.exe /c winrm set winrm/config @{MaxTimeoutms="1800000"}
cmd.exe /c winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"}
cmd.exe /c winrm set winrm/config/service @{AllowUnencrypted="true"}
cmd.exe /c winrm set winrm/config/service/auth @{Basic="true"}
cmd.exe /c winrm set winrm/config/client/auth @{Basic="true"}
cmd.exe /c winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"} 
@rem Make sure winrm is off for this boot, but enabled on next
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net accounts /maxpwage:unlimited
echo %DATE% %TIME% > C:\vm-is-customized

) else if “%1%” == “postcustomization” (
@rem Second Boot / start winrm, just incase, and fix firewall
cmd.exe /c net start winrm 
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes
cmd.exe /c netsh advfirewall firewall set rule name="WinRM" profile=public protocol=tcp localport=5985 remoteip=localsubnet new remoteip=any
cmd.exe /c reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
cmd.exe /c netsh advfirewall firewall set rule name="RDP" profile=public protocol=tcp localport=3389 remoteip=localsubnet new remoteip=any

@rem Password Setting, Force Password Change, and Autologin currently seem broken
@rem Forcing the password here at least allows us to connect remotely
cmd.exe /c net user administrator Password1
@rem Incase DNS failed to be set
@rem cmd.exe /c netsh interface ipv4 add dnsserver "Ethernet" address=8.8.8.8
@rem cmd.exe /c netsh interface ipv4 add dnsserver "Ethernet0" address=8.8.8.8
echo %DATE% %TIME% > C:\vm-is-ready

)
