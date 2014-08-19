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
cmd.exe /c netsh firewall add portopening TCP 5985 "Port 5985 for WinRM"

@rem Password Setting and Autologin currently seem broken
cmd.exe /c net user administrator Password1
@rem cmd.exe /c netsh interface ipv4 add dnsserver "Ethernet" address=8.8.8.8
@rem cmd.exe /c netsh interface ipv4 add dnsserver "Ethernet0" address=8.8.8.8
echo %DATE% %TIME% > C:\vm-is-ready

)
