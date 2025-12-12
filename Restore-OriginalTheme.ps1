<#
.SYNOPSIS
    Restaura la configuracion original antes de aplicar el tema Claude

.DESCRIPTION
    Este script restaura todos los valores originales del registro
    que fueron respaldados antes de aplicar el tema Claude.

.PARAMETER BackupDate
    Fecha del backup a restaurar (formato: yyyy-MM-dd_HHmmss)
    Si no se especifica, usa el backup mas reciente.

.PARAMETER KeepBackups
    No eliminar los archivos de backup despues de restaurar

.PARAMETER RestoreOnly
    Lista de componentes a restaurar (separados por coma)
    Disponibles: Registry, Cursors, Fonts, All

.EXAMPLE
    .\Restore-OriginalTheme.ps1
    .\Restore-OriginalTheme.ps1 -BackupDate "2025-12-11_235200"
    .\Restore-OriginalTheme.ps1 -RestoreOnly Registry

.NOTES
    Author: Claude Code Assistant
    Version: 1.0.0
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$BackupDate,

    [Parameter()]
    [switch]$KeepBackups,

    [Parameter()]
    [ValidateSet('Registry', 'Cursors', 'Fonts', 'All')]
    [string[]]$RestoreOnly = @('All')
)

$Script:BasePath = $PSScriptRoot

#region Logging
function Write-RestoreLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Success')]
        [string]$Level = 'Info'
    )

    $colors = @{
        Info = 'White'
        Warning = 'Yellow'
        Error = 'Red'
        Success = 'Green'
    }

    $prefix = @{
        Info = "[*]"
        Warning = "[!]"
        Error = "[X]"
        Success = "[+]"
    }

    Write-Host "$($prefix[$Level]) $Message" -ForegroundColor $colors[$Level]
}

function Show-Banner {
    $banner = @"

   _____ _                 _        _____          _
  / ____| |               | |      |  __ \        | |
 | |    | | __ _ _   _  __| | ___  | |__) |___  __| |_ ___  _ __ ___
 | |    | |/ _` | | | |/ _` |/ _ \ |  _  // _ \/ _` __/ _ \| '__/ _ \
 | |____| | (_| | |_| | (_| |  __/ | | \ \  __/ (_| || (_) | | |  __/
  \_____|_|\__,_|\__,_|\__,_|\___| |_|  \_\___|\__,_\__\___/|_|  \___|

  Restauracion de Configuracion Original

"@
    Write-Host $banner -ForegroundColor Yellow
}
#endregion

#region Admin Check
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
#endregion

#region Backup Discovery
function Get-AvailableBackups {
    $backupPath = Join-Path $Script:BasePath "Backups"

    if (!(Test-Path $backupPath)) {
        return @()
    }

    # Buscar archivos JSON de configuracion
    $backups = Get-ChildItem -Path $backupPath -Filter "Original-Settings-*.json" | ForEach-Object {
        $timestamp = $_.Name -replace 'Original-Settings-', '' -replace '\.json', ''
        @{
            Timestamp = $timestamp
            JsonFile = $_.FullName
            RegFiles = Get-ChildItem -Path $backupPath -Filter "*$timestamp.reg"
        }
    } | Sort-Object { $_.Timestamp } -Descending

    return $backups
}

function Select-Backup {
    $backups = Get-AvailableBackups

    if ($backups.Count -eq 0) {
        Write-RestoreLog "No se encontraron backups disponibles" -Level Error
        return $null
    }

    if ($BackupDate) {
        $selected = $backups | Where-Object { $_.Timestamp -eq $BackupDate }
        if ($selected) {
            return $selected
        }
        Write-RestoreLog "Backup con fecha '$BackupDate' no encontrado" -Level Error
        return $null
    }

    # Mostrar menu de seleccion
    Write-Host ""
    Write-Host "  Backups disponibles:" -ForegroundColor White
    Write-Host ""

    for ($i = 0; $i -lt [Math]::Min($backups.Count, 10); $i++) {
        $backup = $backups[$i]
        $date = [DateTime]::ParseExact($backup.Timestamp, "yyyy-MM-dd_HHmmss", $null)
        Write-Host "  [$($i + 1)] $($date.ToString('dd/MM/yyyy HH:mm:ss'))" -ForegroundColor Gray
    }

    Write-Host "  [Q] Cancelar" -ForegroundColor Gray
    Write-Host ""

    $choice = Read-Host "  Selecciona el backup a restaurar"

    if ($choice -eq 'Q' -or $choice -eq 'q') {
        return $null
    }

    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $backups.Count) {
        return $backups[$index]
    }

    Write-RestoreLog "Seleccion invalida" -Level Error
    return $null
}
#endregion

#region Restore Functions
function Restore-RegistryBackup {
    param([object]$Backup)

    Write-RestoreLog "Restaurando registro desde backup..." -Level Info

    try {
        foreach ($regFile in $Backup.RegFiles) {
            Write-RestoreLog "Importando: $($regFile.Name)" -Level Info
            $result = reg import $regFile.FullName 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-RestoreLog "Importado exitosamente: $($regFile.Name)" -Level Success
            } else {
                Write-RestoreLog "Error al importar: $($regFile.Name)" -Level Warning
            }
        }

        return $true
    } catch {
        Write-RestoreLog "Error al restaurar registro: $_" -Level Error
        return $false
    }
}

function Restore-JsonSettings {
    param([object]$Backup)

    Write-RestoreLog "Restaurando configuracion desde JSON..." -Level Info

    try {
        $settings = Get-Content $Backup.JsonFile | ConvertFrom-Json

        $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $dwmPath = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"

        # Restaurar valores si existen en el backup
        if ($null -ne $settings.AccentColor) {
            Set-ItemProperty -Path $dwmPath -Name "AccentColor" -Value $settings.AccentColor -Type DWord -ErrorAction SilentlyContinue
        }

        if ($null -ne $settings.AppsUseLightTheme) {
            Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value $settings.AppsUseLightTheme -Type DWord -ErrorAction SilentlyContinue
        }

        if ($null -ne $settings.SystemUsesLightTheme) {
            Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value $settings.SystemUsesLightTheme -Type DWord -ErrorAction SilentlyContinue
        }

        if ($null -ne $settings.ColorPrevalence) {
            Set-ItemProperty -Path $themePath -Name "ColorPrevalence" -Value $settings.ColorPrevalence -Type DWord -ErrorAction SilentlyContinue
        }

        if ($null -ne $settings.EnableTransparency) {
            Set-ItemProperty -Path $themePath -Name "EnableTransparency" -Value $settings.EnableTransparency -Type DWord -ErrorAction SilentlyContinue
        }

        Write-RestoreLog "Configuracion JSON restaurada" -Level Success
        return $true
    } catch {
        Write-RestoreLog "Error al restaurar desde JSON: $_" -Level Error
        return $false
    }
}

function Restore-DefaultCursors {
    Write-RestoreLog "Restaurando cursores por defecto..." -Level Info

    try {
        $cursorPath = "HKCU:\Control Panel\Cursors"

        # Restaurar a valores por defecto de Windows
        Set-ItemProperty -Path $cursorPath -Name "Arrow" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "Help" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "AppStarting" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "Wait" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "Crosshair" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "IBeam" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "NWPen" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "No" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "SizeNS" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "SizeWE" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "SizeNWSE" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "SizeNESW" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "SizeAll" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "UpArrow" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "Hand" -Value "" -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cursorPath -Name "(Default)" -Value "Windows Default" -ErrorAction SilentlyContinue

        # Notificar al sistema
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class CursorRestore {
                [DllImport("user32.dll", SetLastError = true)]
                public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);

                public const uint SPI_SETCURSORS = 0x0057;
                public const uint SPIF_SENDCHANGE = 0x02;
            }
"@

        [CursorRestore]::SystemParametersInfo([CursorRestore]::SPI_SETCURSORS, 0, $null, [CursorRestore]::SPIF_SENDCHANGE) | Out-Null

        Write-RestoreLog "Cursores restaurados a valores por defecto" -Level Success
        return $true
    } catch {
        Write-RestoreLog "Error al restaurar cursores: $_" -Level Error
        return $false
    }
}

function Restart-Explorer {
    Write-RestoreLog "Reiniciando explorer.exe..." -Level Info

    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process explorer

        Write-RestoreLog "Explorer reiniciado" -Level Success
        return $true
    } catch {
        Write-RestoreLog "Error al reiniciar explorer: $_" -Level Error
        return $false
    }
}

function Remove-Backups {
    param([object]$Backup)

    Write-RestoreLog "Eliminando archivos de backup..." -Level Info

    try {
        # Eliminar archivo JSON
        if (Test-Path $Backup.JsonFile) {
            Remove-Item $Backup.JsonFile -Force
        }

        # Eliminar archivos REG
        foreach ($regFile in $Backup.RegFiles) {
            if (Test-Path $regFile.FullName) {
                Remove-Item $regFile.FullName -Force
            }
        }

        Write-RestoreLog "Backups eliminados" -Level Success
        return $true
    } catch {
        Write-RestoreLog "Error al eliminar backups: $_" -Level Warning
        return $false
    }
}
#endregion

#region Main
try {
    Show-Banner

    # Verificar admin
    if (!(Test-Administrator)) {
        Write-RestoreLog "Se requieren permisos de administrador" -Level Error
        exit 1
    }

    Write-RestoreLog "Permisos de administrador: OK" -Level Success

    # Seleccionar backup
    $selectedBackup = Select-Backup

    if ($null -eq $selectedBackup) {
        Write-RestoreLog "Operacion cancelada" -Level Warning
        exit 0
    }

    $timestamp = $selectedBackup.Timestamp
    $date = [DateTime]::ParseExact($timestamp, "yyyy-MM-dd_HHmmss", $null)
    Write-RestoreLog "Backup seleccionado: $($date.ToString('dd/MM/yyyy HH:mm:ss'))" -Level Info

    # Confirmar
    Write-Host ""
    $confirm = Read-Host "  Esto restaurara la configuracion anterior. Continuar? (S/N)"
    if ($confirm -ne 'S' -and $confirm -ne 's') {
        Write-RestoreLog "Operacion cancelada por el usuario" -Level Warning
        exit 0
    }

    Write-Host ""
    $results = @{}

    # Restaurar segun lo solicitado
    if ('All' -in $RestoreOnly -or 'Registry' -in $RestoreOnly) {
        $results['Registry'] = Restore-RegistryBackup -Backup $selectedBackup
        $results['JsonSettings'] = Restore-JsonSettings -Backup $selectedBackup
    }

    if ('All' -in $RestoreOnly -or 'Cursors' -in $RestoreOnly) {
        $results['Cursors'] = Restore-DefaultCursors
    }

    # Mostrar resumen
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "       RESUMEN DE RESTAURACION          " -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""

    foreach ($key in $results.Keys) {
        $status = if ($results[$key]) { "[OK]" } else { "[FAIL]" }
        $color = if ($results[$key]) { "Green" } else { "Red" }
        Write-Host "  $status $key" -ForegroundColor $color
    }

    Write-Host ""

    # Preguntar si eliminar backups
    if (!$KeepBackups) {
        $deleteBackups = Read-Host "  Eliminar archivos de backup? (S/N)"
        if ($deleteBackups -eq 'S' -or $deleteBackups -eq 's') {
            Remove-Backups -Backup $selectedBackup
        }
    }

    # Reiniciar explorer
    Write-Host ""
    $restart = Read-Host "  Reiniciar explorer.exe para aplicar cambios? (S/N)"
    if ($restart -eq 'S' -or $restart -eq 's') {
        Restart-Explorer
    }

    Write-Host ""
    Write-RestoreLog "Restauracion completada!" -Level Success
    Write-Host ""

} catch {
    Write-RestoreLog "Error fatal: $_" -Level Error
    exit 1
}
#endregion
