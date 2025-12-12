<#
.SYNOPSIS
    Configura el cambio automatico entre modo claro y oscuro

.DESCRIPTION
    Crea tareas programadas en Windows para cambiar automaticamente
    entre el modo claro (dia) y oscuro (noche) del tema Claude.

.PARAMETER DayTime
    Hora para cambiar a modo claro (formato HH:mm). Default: 07:00

.PARAMETER NightTime
    Hora para cambiar a modo oscuro (formato HH:mm). Default: 19:00

.PARAMETER Remove
    Elimina las tareas programadas existentes

.PARAMETER Status
    Muestra el estado de las tareas programadas

.EXAMPLE
    .\Set-ClaudeAutoSwitch.ps1                              # Usar horas por defecto
    .\Set-ClaudeAutoSwitch.ps1 -DayTime "08:00" -NightTime "20:00"
    .\Set-ClaudeAutoSwitch.ps1 -Remove
    .\Set-ClaudeAutoSwitch.ps1 -Status

.NOTES
    Author: Claude Code Assistant
    Version: 1.0.0
    Requires: Administrator privileges
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$DayTime = "07:00",

    [Parameter()]
    [string]$NightTime = "19:00",

    [Parameter()]
    [switch]$Remove,

    [Parameter()]
    [switch]$Status
)

$Script:BasePath = $PSScriptRoot
$Script:TaskNameDay = "Claude Theme - Day Mode"
$Script:TaskNameNight = "Claude Theme - Night Mode"

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-Banner {
    Write-Host ""
    Write-Host "  Claude Theme Auto-Switch" -ForegroundColor Cyan
    Write-Host "  Cambio automatico dia/noche" -ForegroundColor Gray
    Write-Host ""
}

function Get-TaskStatus {
    $dayTask = Get-ScheduledTask -TaskName $Script:TaskNameDay -ErrorAction SilentlyContinue
    $nightTask = Get-ScheduledTask -TaskName $Script:TaskNameNight -ErrorAction SilentlyContinue

    Write-Host "  Estado de tareas programadas:" -ForegroundColor White
    Write-Host ""

    if ($dayTask) {
        $dayTrigger = ($dayTask.Triggers | Select-Object -First 1).StartBoundary
        $dayTime = if ($dayTrigger) { ([DateTime]$dayTrigger).ToString("HH:mm") } else { "N/A" }
        Write-Host "  [+] $($Script:TaskNameDay)" -ForegroundColor Green
        Write-Host "      Hora: $dayTime" -ForegroundColor Gray
        Write-Host "      Estado: $($dayTask.State)" -ForegroundColor Gray
    } else {
        Write-Host "  [-] $($Script:TaskNameDay) - No configurada" -ForegroundColor Yellow
    }

    Write-Host ""

    if ($nightTask) {
        $nightTrigger = ($nightTask.Triggers | Select-Object -First 1).StartBoundary
        $nightTime = if ($nightTrigger) { ([DateTime]$nightTrigger).ToString("HH:mm") } else { "N/A" }
        Write-Host "  [+] $($Script:TaskNameNight)" -ForegroundColor Green
        Write-Host "      Hora: $nightTime" -ForegroundColor Gray
        Write-Host "      Estado: $($nightTask.State)" -ForegroundColor Gray
    } else {
        Write-Host "  [-] $($Script:TaskNameNight) - No configurada" -ForegroundColor Yellow
    }

    Write-Host ""
}

function Remove-AutoSwitchTasks {
    Write-Host "  Eliminando tareas programadas..." -ForegroundColor Yellow

    try {
        Unregister-ScheduledTask -TaskName $Script:TaskNameDay -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "  [+] Tarea de dia eliminada" -ForegroundColor Green
    } catch {
        Write-Host "  [-] Tarea de dia no existe" -ForegroundColor Gray
    }

    try {
        Unregister-ScheduledTask -TaskName $Script:TaskNameNight -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "  [+] Tarea de noche eliminada" -ForegroundColor Green
    } catch {
        Write-Host "  [-] Tarea de noche no existe" -ForegroundColor Gray
    }

    Write-Host ""
}

function New-AutoSwitchTasks {
    param(
        [string]$Day,
        [string]$Night
    )

    $switchScript = Join-Path $Script:BasePath "Switch-ClaudeMode.ps1"

    if (!(Test-Path $switchScript)) {
        Write-Host "  [X] Script Switch-ClaudeMode.ps1 no encontrado" -ForegroundColor Red
        return $false
    }

    Write-Host "  Configurando tareas programadas..." -ForegroundColor White
    Write-Host "  Modo claro a las: $Day" -ForegroundColor Gray
    Write-Host "  Modo oscuro a las: $Night" -ForegroundColor Gray
    Write-Host ""

    try {
        # Eliminar tareas existentes primero
        Remove-AutoSwitchTasks

        # Crear tarea para modo dia (Light)
        $dayAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$switchScript`" -Mode Light"
        $dayTrigger = New-ScheduledTaskTrigger -Daily -At $Day
        $daySettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        $dayPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

        Register-ScheduledTask -TaskName $Script:TaskNameDay -Action $dayAction -Trigger $dayTrigger -Settings $daySettings -Principal $dayPrincipal -Description "Cambia a modo claro de Claude Theme" | Out-Null

        Write-Host "  [+] Tarea de dia creada: $Day -> Modo Light" -ForegroundColor Green

        # Crear tarea para modo noche (Dark)
        $nightAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$switchScript`" -Mode Dark"
        $nightTrigger = New-ScheduledTaskTrigger -Daily -At $Night
        $nightSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
        $nightPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

        Register-ScheduledTask -TaskName $Script:TaskNameNight -Action $nightAction -Trigger $nightTrigger -Settings $nightSettings -Principal $nightPrincipal -Description "Cambia a modo oscuro de Claude Theme" | Out-Null

        Write-Host "  [+] Tarea de noche creada: $Night -> Modo Dark" -ForegroundColor Green

        Write-Host ""
        Write-Host "  Auto-switch configurado exitosamente!" -ForegroundColor Green
        Write-Host ""

        return $true
    } catch {
        Write-Host "  [X] Error al crear tareas: $_" -ForegroundColor Red
        return $false
    }
}

# Main
Show-Banner

if (!(Test-Administrator)) {
    Write-Host "  [!] Se requieren permisos de administrador" -ForegroundColor Red
    Write-Host "      Ejecuta PowerShell como administrador" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

if ($Status) {
    Get-TaskStatus
    exit 0
}

if ($Remove) {
    Remove-AutoSwitchTasks
    exit 0
}

# Validar formato de hora
try {
    $null = [DateTime]::ParseExact($DayTime, "HH:mm", $null)
    $null = [DateTime]::ParseExact($NightTime, "HH:mm", $null)
} catch {
    Write-Host "  [X] Formato de hora invalido. Usa HH:mm (ej: 07:00, 19:30)" -ForegroundColor Red
    exit 1
}

# Crear tareas
New-AutoSwitchTasks -Day $DayTime -Night $NightTime
