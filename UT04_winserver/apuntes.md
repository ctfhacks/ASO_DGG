# APUNTES

## Cambiar IP powershell
```powershell
New-NetIpAddress -InterfaceIndex 4 -IPAddress 172.25.0.32 -PrefixLength 16 -DefaultGateway 172.25.0.1
```

## Ver configuración de red
```powershell
Get-NetIpConfiguration
```