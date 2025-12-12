<#
.SYNOPSIS
    Cambia rapidamente entre modo oscuro y claro de Claude Theme

.DESCRIPTION
    Script ligero para alternar entre el modo oscuro y claro sin reinstalar todo.
    Solo modifica el tema del sistema y aplica el wallpaper correspondiente.

.PARAMETER Mode
    Dark o Light. Si no se especifica, alterna al modo opuesto.

.EXAMPLE
    .\Switch-ClaudeMode.ps1           # Alterna al modo opuesto
    .\Switch-ClaudeMode.ps1 -Mode Dark
    .\Switch-ClaudeMode.ps1 -Mode Light

.NOTES
    Author: Claude Code Assistant
    Version: 1.0.0
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Dark', 'Light')]
    [string]$Mode
)

$Script:BasePath = $PSScriptRoot

function Get-CurrentMode {
    try {
        $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $appsLight = (Get-ItemProperty $themePath -ErrorAction SilentlyContinue).AppsUseLightTheme

        if ($appsLight -eq 0) {
            return 'Dark'
        } else {
            return 'Light'
        }
    } catch {
        return 'Unknown'
    }
}

function Set-ThemeMode {
    param([string]$TargetMode)

    $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    $themeValue = if ($TargetMode -eq 'Dark') { 0 } else { 1 }

    Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value $themeValue -Type DWord
    Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value $themeValue -Type DWord
}

function Set-Wallpaper {
    param([string]$TargetMode)

    $wallpaperPath = Join-Path $Script:BasePath "Wallpapers\Claude-Wallpaper-$TargetMode.png"

    if (!(Test-Path $wallpaperPath)) {
        Write-Host "[!] Wallpaper no encontrado: $wallpaperPath" -ForegroundColor Yellow
        return
    }

    Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class WallpaperSwitch {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        }
"@

    [WallpaperSwitch]::SystemParametersInfo(0x0014, 0, $wallpaperPath, 0x03) | Out-Null
}

# Main
$currentMode = Get-CurrentMode
Write-Host ""
Write-Host "  Claude Theme Mode Switch" -ForegroundColor Cyan
Write-Host "  Modo actual: $currentMode" -ForegroundColor Gray
Write-Host ""

# Determinar modo objetivo
$targetMode = if ($Mode) {
    $Mode
} else {
    # Alternar
    if ($currentMode -eq 'Dark') { 'Light' } else { 'Dark' }
}

if ($currentMode -eq $targetMode) {
    Write-Host "  Ya estas en modo $targetMode" -ForegroundColor Yellow
    exit 0
}

Write-Host "  Cambiando a modo: $targetMode" -ForegroundColor White

# Aplicar cambios
Set-ThemeMode -TargetMode $targetMode
Set-Wallpaper -TargetMode $targetMode

Write-Host ""
Write-Host "  [+] Modo cambiado a $targetMode" -ForegroundColor Green
Write-Host ""
