<#
.SYNOPSIS
    Claude Anthropic Theme for Windows 11
    Personaliza Windows 11 con la estetica de Claude de Anthropic

.DESCRIPTION
    Este script configura Windows 11 con la paleta de colores de Claude:
    - Color de acento terracota (#CC785C)
    - Tema oscuro o claro seleccionable
    - Cursores personalizados
    - Wallpapers generados
    - Fuente Inter
    - Y mas...

.PARAMETER Mode
    Modo del tema: Dark, Light, o Interactive (menu)

.PARAMETER Components
    Lista de componentes a instalar (separados por coma)
    Disponibles: Colors, Theme, Taskbar, Borders, Cursors, Wallpaper, LockScreen, Font, Icons, ExplorerPatcher, Terminal, PowerShell

.PARAMETER SkipComponents
    Lista de componentes a omitir

.PARAMETER NoBackup
    No crear backup antes de aplicar cambios

.PARAMETER Offline
    Usar recursos locales sin descargar

.PARAMETER Preview
    Solo mostrar que cambios se harian

.EXAMPLE
    .\Set-ClaudeTheme.ps1 -Mode Dark
    .\Set-ClaudeTheme.ps1 -Mode Light -SkipComponents Icons,ExplorerPatcher

.NOTES
    Author: Claude Code Assistant
    Version: 1.0.0
    Requires: Windows 11 22H2+, PowerShell 5.1+, Administrator privileges
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Dark', 'Light', 'OLED', 'All', 'Interactive')]
    [string]$Mode = 'Interactive',

    [Parameter()]
    [string[]]$Components,

    [Parameter()]
    [string[]]$SkipComponents,

    [Parameter()]
    [switch]$NoBackup,

    [Parameter()]
    [switch]$Offline,

    [Parameter()]
    [switch]$Preview
)

#region Configuration
$Script:Config = @{
    Version = "2.0.0"
    BasePath = $PSScriptRoot

    # Colores Claude V3 - Modo Oscuro (ELEGANTE - tonos pastel desaturados)
    # Basado en: Pampas #F4F3EE, Cloudy #B1ADA1, Crail suavizado
    DarkMode = @{
        AccentPrimary = "D4A08A"      # Salmon suave (desaturado de CC785C)
        AccentLight = "E8CABA"        # Crema rosado muy suave
        AccentGold = "C9B8A8"         # Beige dorado apagado (Cloudy derivado)
        Background = "2D2B2A"         # Gris calido neutro (no tan oscuro)
        BackgroundElevated = "383634" # Gris medio calido
        Border = "454240"             # Gris borde calido
        TextPrimary = "ECECEC"        # Blanco suave
        TextSecondary = "B1ADA1"      # Cloudy - gris oficial Claude
        # Colores para ondas del wallpaper (suaves)
        WaveBack = "3D3A38"           # Onda trasera sutil
        WaveMid = "5A5450"            # Onda media gris calido
        WaveAccent = "D4A08A"         # Onda principal salmon suave
        WaveHighlight = "E8CABA"      # Highlights crema rosado
    }

    # Colores Claude V3 - Modo Claro (ELEGANTE - Pampas oficial)
    LightMode = @{
        AccentPrimary = "D4A08A"      # Salmon suave
        AccentLight = "E8D4C8"        # Crema muy suave
        Background = "F4F3EE"         # Pampas - COLOR OFICIAL Claude
        BackgroundElevated = "FAFAF8" # Blanco calido
        Border = "E5E3DE"             # Borde crema suave
        TextPrimary = "2D2B2A"        # Gris oscuro calido
        TextSecondary = "8A8580"      # Gris medio
        # Colores para ondas del wallpaper (suaves)
        WaveBack = "E8E6E0"           # Onda trasera crema
        WaveMid = "DDD5CA"            # Onda media arena suave
        WaveAccent = "D4A08A"         # Onda principal salmon
        WaveHighlight = "F8F6F2"      # Highlights blancos suaves
    }

    # Colores Claude V3 - Modo OLED Black (elegante)
    OLEDMode = @{
        AccentPrimary = "D4A08A"      # Salmon suave
        AccentLight = "E8CABA"        # Crema rosado
        AccentGold = "C9B8A8"         # Beige dorado apagado
        Background = "000000"         # Negro puro OLED
        BackgroundElevated = "0D0C0B" # Casi negro calido
        Border = "1E1C1A"             # Gris muy oscuro calido
        TextPrimary = "ECECEC"        # Blanco suave
        TextSecondary = "7A7672"      # Gris medio
        # Colores para ondas del wallpaper
        WaveBack = "1A1816"           # Onda trasera muy sutil
        WaveMid = "2A2624"            # Onda media
        WaveAccent = "D4A08A"         # Onda principal salmon
        WaveHighlight = "C9B8A8"      # Highlights beige suave
    }

    # Componentes disponibles
    AllComponents = @(
        'Colors', 'Theme', 'Taskbar', 'Borders', 'Cursors',
        'Wallpaper', 'LockScreen', 'Font', 'Icons',
        'ExplorerPatcher', 'Terminal', 'PowerShell', 'TranslucentTB'
    )

    # URLs de recursos
    Resources = @{
        InterFont = "https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip"
        ExplorerPatcher = "https://github.com/valinet/ExplorerPatcher/releases/latest/download/ep_setup.exe"
        TranslucentTB = "winget:TranslucentTB"
    }
}
#endregion

#region Logging Functions
function Write-ClaudeLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Warning', 'Error', 'Success', 'Verbose')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logPath = Join-Path $Script:Config.BasePath "Logs"
    $logFile = Join-Path $logPath "install-$(Get-Date -Format 'yyyy-MM-dd').log"

    # Colores para consola
    $colors = @{
        Info = 'White'
        Warning = 'Yellow'
        Error = 'Red'
        Success = 'Green'
        Verbose = 'Gray'
    }

    $prefix = @{
        Info = "[*]"
        Warning = "[!]"
        Error = "[X]"
        Success = "[+]"
        Verbose = "[-]"
    }

    # Escribir a consola
    Write-Host "$($prefix[$Level]) $Message" -ForegroundColor $colors[$Level]

    # Escribir a archivo
    if (!(Test-Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    "$timestamp [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

function Show-Banner {
    $banner = @"

   _____ _                 _        _____ _
  / ____| |               | |      |_   _| |
 | |    | | __ _ _   _  __| | ___    | | | |__   ___ _ __ ___   ___
 | |    | |/ _` | | | |/ _` |/ _ \   | | | '_ \ / _ \ '_ ` _ \ / _ \
 | |____| | (_| | |_| | (_| |  __/   | | | | | |  __/ | | | | |  __/
  \_____|_|\__,_|\__,_|\__,_|\___|   |_| |_| |_|\___|_| |_| |_|\___|

  Windows 11 Theme by Anthropic Claude
  Version $($Script:Config.Version)

"@
    Write-Host $banner -ForegroundColor Cyan
}
#endregion

#region Verification Functions
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-WindowsVersion {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $build = [int]$os.BuildNumber

    # Windows 11 22H2 es build 22621
    if ($build -lt 22000) {
        return @{ Valid = $false; Message = "Se requiere Windows 11 (build 22000+). Actual: $build" }
    }

    return @{ Valid = $true; Message = "Windows 11 Build $build detectado" }
}

function Test-Prerequisites {
    Write-ClaudeLog "Verificando prerequisitos..." -Level Info

    # Verificar admin
    if (!(Test-Administrator)) {
        Write-ClaudeLog "Se requieren permisos de administrador" -Level Error
        return $false
    }
    Write-ClaudeLog "Permisos de administrador: OK" -Level Success

    # Verificar version de Windows
    $winCheck = Test-WindowsVersion
    if (!$winCheck.Valid) {
        Write-ClaudeLog $winCheck.Message -Level Error
        return $false
    }
    Write-ClaudeLog $winCheck.Message -Level Success

    # Verificar espacio en disco (100MB minimo)
    $drive = Get-PSDrive C
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    if ($drive.Free -lt 100MB) {
        Write-ClaudeLog "Espacio insuficiente en disco C: ($freeGB GB libres)" -Level Error
        return $false
    }
    Write-ClaudeLog "Espacio en disco: $freeGB GB libres" -Level Success

    # Verificar .NET Framework
    $dotnet = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue
    if ($dotnet.Release -lt 461808) {
        Write-ClaudeLog ".NET Framework 4.7.2+ requerido para generacion de graficos" -Level Warning
    } else {
        Write-ClaudeLog ".NET Framework: OK" -Level Success
    }

    return $true
}

function Test-NetworkConnection {
    if ($Script:Offline) {
        Write-ClaudeLog "Modo offline activado - usando recursos locales" -Level Warning
        return $true
    }

    try {
        $response = Test-NetConnection -ComputerName "github.com" -Port 443 -WarningAction SilentlyContinue
        if ($response.TcpTestSucceeded) {
            Write-ClaudeLog "Conectividad de red: OK" -Level Success
            return $true
        }
    } catch {
        # Silenciar errores
    }

    Write-ClaudeLog "Sin conexion a internet - algunas funciones no estaran disponibles" -Level Warning
    return $false
}
#endregion

#region Backup Functions
function New-ThemeBackup {
    if ($Script:NoBackup) {
        Write-ClaudeLog "Backup omitido por parametro -NoBackup" -Level Warning
        return $true
    }

    Write-ClaudeLog "Creando backup de configuracion actual..." -Level Info

    $backupPath = Join-Path $Script:Config.BasePath "Backups"
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"

    try {
        # Backup del registro - Accent
        $regBackup = Join-Path $backupPath "Registry-Backup-$timestamp.reg"
        $regPaths = @(
            "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent",
            "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize",
            "HKCU\SOFTWARE\Microsoft\Windows\DWM",
            "HKCU\Control Panel\Desktop",
            "HKCU\Control Panel\Cursors"
        )

        foreach ($path in $regPaths) {
            $safePath = $path -replace "\\", "_"
            $singleBackup = Join-Path $backupPath "Reg_$safePath`_$timestamp.reg"
            $null = reg export $path $singleBackup /y 2>&1
        }

        Write-ClaudeLog "Backup del registro creado" -Level Success

        # Guardar configuracion actual en JSON
        $jsonBackup = Join-Path $backupPath "Original-Settings-$timestamp.json"
        $currentSettings = @{
            Timestamp = $timestamp
            AccentColor = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\DWM" -ErrorAction SilentlyContinue).AccentColor
            AppsUseLightTheme = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction SilentlyContinue).AppsUseLightTheme
            SystemUsesLightTheme = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction SilentlyContinue).SystemUsesLightTheme
            ColorPrevalence = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction SilentlyContinue).ColorPrevalence
            EnableTransparency = (Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -ErrorAction SilentlyContinue).EnableTransparency
        }

        $currentSettings | ConvertTo-Json -Depth 5 | Out-File $jsonBackup -Encoding UTF8
        Write-ClaudeLog "Configuracion guardada en JSON" -Level Success

        # Crear punto de restauracion del sistema
        Write-ClaudeLog "Creando punto de restauracion del sistema..." -Level Info
        try {
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "Claude Theme - Pre-installation backup" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
            Write-ClaudeLog "Punto de restauracion creado" -Level Success
        } catch {
            Write-ClaudeLog "No se pudo crear punto de restauracion: $_" -Level Warning
        }

        return $true
    } catch {
        Write-ClaudeLog "Error al crear backup: $_" -Level Error
        return $false
    }
}
#endregion

#region Color Conversion Functions
function Convert-RGBtoABGR {
    <#
    .SYNOPSIS
    Convierte color RGB hex a formato ABGR DWORD de Windows
    #>
    param([string]$RGB)

    $RGB = $RGB -replace '#', ''

    $R = $RGB.Substring(0, 2)
    $G = $RGB.Substring(2, 2)
    $B = $RGB.Substring(4, 2)

    # Windows usa ABGR: Alpha-Blue-Green-Red
    $ABGR = "FF$B$G$R"

    return [Convert]::ToUInt32($ABGR, 16)
}

function Get-AccentPalette {
    <#
    .SYNOPSIS
    Genera la paleta de 8 colores de acento para Windows
    #>
    param(
        [string]$BaseColor,
        [bool]$IsDarkMode = $true
    )

    $BaseColor = $BaseColor -replace '#', ''

    # Extraer componentes RGB
    $R = [Convert]::ToInt32($BaseColor.Substring(0, 2), 16)
    $G = [Convert]::ToInt32($BaseColor.Substring(2, 2), 16)
    $B = [Convert]::ToInt32($BaseColor.Substring(4, 2), 16)

    # Generar 8 variaciones (de mas claro a mas oscuro)
    $palette = @()
    $factors = @(1.4, 1.25, 1.1, 1.0, 0.9, 0.75, 0.6, 0.45)

    foreach ($factor in $factors) {
        $newR = [Math]::Min(255, [Math]::Max(0, [int]($R * $factor)))
        $newG = [Math]::Min(255, [Math]::Max(0, [int]($G * $factor)))
        $newB = [Math]::Min(255, [Math]::Max(0, [int]($B * $factor)))

        # Formato: ABGR en little-endian
        $palette += [byte]$newR
        $palette += [byte]$newG
        $palette += [byte]$newB
        $palette += [byte]0xFF
    }

    return [byte[]]$palette
}
#endregion

#region Theme Application Functions
function Set-AccentColor {
    param(
        [string]$Color,
        [bool]$IsDarkMode = $true
    )

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Aplicaria color de acento: #$Color" -Level Info
        return $true
    }

    Write-ClaudeLog "Aplicando color de acento: #$Color" -Level Info

    try {
        $abgrColor = Convert-RGBtoABGR -RGB $Color
        $palette = Get-AccentPalette -BaseColor $Color -IsDarkMode $IsDarkMode

        # Rutas del registro
        $accentPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"
        $dwmPath = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"

        # Crear claves si no existen
        if (!(Test-Path $accentPath)) {
            New-Item -Path $accentPath -Force | Out-Null
        }

        # Aplicar AccentPalette (32 bytes)
        Set-ItemProperty -Path $accentPath -Name "AccentPalette" -Value $palette -Type Binary

        # Aplicar AccentColorMenu
        Set-ItemProperty -Path $accentPath -Name "AccentColorMenu" -Value $abgrColor -Type DWord

        # Aplicar StartColorMenu
        Set-ItemProperty -Path $accentPath -Name "StartColorMenu" -Value $abgrColor -Type DWord

        # Aplicar en DWM
        Set-ItemProperty -Path $dwmPath -Name "AccentColor" -Value $abgrColor -Type DWord
        Set-ItemProperty -Path $dwmPath -Name "ColorizationColor" -Value $abgrColor -Type DWord
        Set-ItemProperty -Path $dwmPath -Name "ColorizationAfterglow" -Value $abgrColor -Type DWord

        Write-ClaudeLog "Color de acento aplicado exitosamente" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al aplicar color de acento: $_" -Level Error
        return $false
    }
}

function Set-ThemeMode {
    param([bool]$IsDarkMode = $true)

    $modeName = if ($IsDarkMode) { "Oscuro" } else { "Claro" }

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Aplicaria modo: $modeName" -Level Info
        return $true
    }

    Write-ClaudeLog "Aplicando modo $modeName..." -Level Info

    try {
        $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"

        # 0 = Dark, 1 = Light
        $themeValue = if ($IsDarkMode) { 0 } else { 1 }

        # Aplicar a sistema y apps
        Set-ItemProperty -Path $themePath -Name "AppsUseLightTheme" -Value $themeValue -Type DWord
        Set-ItemProperty -Path $themePath -Name "SystemUsesLightTheme" -Value $themeValue -Type DWord

        Write-ClaudeLog "Modo $modeName aplicado" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al aplicar modo de tema: $_" -Level Error
        return $false
    }
}

function Set-TaskbarAppearance {
    param([bool]$EnableAccentColor = $true, [bool]$EnableTransparency = $true)

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Configuraria barra de tareas (acento: $EnableAccentColor, transparencia: $EnableTransparency)" -Level Info
        return $true
    }

    Write-ClaudeLog "Configurando barra de tareas..." -Level Info

    try {
        $themePath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $dwmPath = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"

        # Color de acento en barra de tareas
        Set-ItemProperty -Path $themePath -Name "ColorPrevalence" -Value ([int]$EnableAccentColor) -Type DWord
        Set-ItemProperty -Path $dwmPath -Name "ColorPrevalence" -Value ([int]$EnableAccentColor) -Type DWord

        # Transparencia
        Set-ItemProperty -Path $themePath -Name "EnableTransparency" -Value ([int]$EnableTransparency) -Type DWord

        Write-ClaudeLog "Barra de tareas configurada" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al configurar barra de tareas: $_" -Level Error
        return $false
    }
}

function Set-WindowBorders {
    param([bool]$EnableColorization = $true)

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Configuraria bordes de ventana (colorizacion: $EnableColorization)" -Level Info
        return $true
    }

    Write-ClaudeLog "Configurando bordes de ventanas..." -Level Info

    try {
        $dwmPath = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"

        # Habilitar colorizacion de ventanas
        Set-ItemProperty -Path $dwmPath -Name "EnableWindowColorization" -Value ([int]$EnableColorization) -Type DWord

        # Intensidad de color en bordes (0-100)
        Set-ItemProperty -Path $dwmPath -Name "ColorizationColorBalance" -Value 89 -Type DWord

        Write-ClaudeLog "Bordes de ventanas configurados" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al configurar bordes: $_" -Level Error
        return $false
    }
}
#endregion

#region Wallpaper Generation V2 - Artistic Bezier Waves
function New-ClaudeWallpaper {
    param(
        [string]$ThemeMode = "Dark",  # Dark, Light, OLED
        [string]$OutputPath
    )

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Generaria wallpaper modo $ThemeMode con ondas artisticas" -Level Info
        return $true
    }

    Write-ClaudeLog "Generando wallpaper V2 modo $ThemeMode con ondas Bezier..." -Level Info

    try {
        Add-Type -AssemblyName System.Drawing
        Add-Type -AssemblyName System.Windows.Forms

        # Obtener resolucion del monitor principal
        $screen = [System.Windows.Forms.Screen]::PrimaryScreen
        $width = $screen.Bounds.Width
        $height = $screen.Bounds.Height

        Write-ClaudeLog "Resolucion detectada: ${width}x${height}" -Level Verbose

        # Seleccionar paleta de colores
        $colors = switch ($ThemeMode) {
            "Light" { $Script:Config.LightMode }
            "OLED"  { $Script:Config.OLEDMode }
            default { $Script:Config.DarkMode }
        }

        # Crear bitmap con alta calidad
        $bitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        # === CAPA 0: Gradiente de fondo vertical ===
        $bgTop = [System.Drawing.ColorTranslator]::FromHtml("#$($colors.Background)")
        $bgBottom = if ($ThemeMode -eq "Light") {
            [System.Drawing.ColorTranslator]::FromHtml("#FDF0E5")  # Crema mas profundo abajo
        } elseif ($ThemeMode -eq "OLED") {
            [System.Drawing.ColorTranslator]::FromHtml("#000000")  # Negro puro
        } else {
            [System.Drawing.ColorTranslator]::FromHtml("#0D0A08")  # Marron muy oscuro
        }

        $bgRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
        $bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            $bgRect, $bgTop, $bgBottom, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
        )
        $graphics.FillRectangle($bgBrush, $bgRect)
        $bgBrush.Dispose()

        # === FUNCION HELPER: Dibujar capa de onda ===
        $DrawWaveLayer = {
            param($g, $w, $h, $color, $opacity, $baseY, $amplitude, $frequency, $phase, $fillDown)

            $waveColor = [System.Drawing.ColorTranslator]::FromHtml("#$color")
            $fillColor = [System.Drawing.Color]::FromArgb($opacity, $waveColor.R, $waveColor.G, $waveColor.B)

            $path = New-Object System.Drawing.Drawing2D.GraphicsPath

            # Generar puntos de la onda usando funcion sinusoidal compuesta
            $points = New-Object System.Collections.ArrayList
            $segments = 200  # Mas segmentos = curva mas suave

            for ($i = 0; $i -le $segments; $i++) {
                $x = ($w / $segments) * $i
                $normalizedX = $x / $w

                # Onda compuesta para aspecto mas organico
                $wave1 = [Math]::Sin($normalizedX * $frequency * [Math]::PI + $phase)
                $wave2 = [Math]::Sin($normalizedX * $frequency * 2 * [Math]::PI + $phase * 1.5) * 0.3
                $wave3 = [Math]::Sin($normalizedX * $frequency * 0.5 * [Math]::PI + $phase * 0.7) * 0.2

                $y = $baseY + ($amplitude * ($wave1 + $wave2 + $wave3))
                $null = $points.Add([System.Drawing.PointF]::new($x, $y))
            }

            # Construir path: empezar desde esquina, seguir onda, cerrar
            if ($fillDown) {
                $path.AddLine(0, $h, 0, $points[0].Y)
            } else {
                $path.AddLine(0, 0, 0, $points[0].Y)
            }

            # Agregar curva suave a traves de los puntos
            $path.AddCurve($points.ToArray(), 0.5)

            # Cerrar el path
            if ($fillDown) {
                $path.AddLine($w, $points[$points.Count - 1].Y, $w, $h)
                $path.AddLine($w, $h, 0, $h)
            } else {
                $path.AddLine($w, $points[$points.Count - 1].Y, $w, 0)
                $path.AddLine($w, 0, 0, 0)
            }

            $path.CloseFigure()

            # Rellenar
            $brush = New-Object System.Drawing.SolidBrush($fillColor)
            $g.FillPath($brush, $path)
            $brush.Dispose()
            $path.Dispose()
        }

        # === CAPAS DE ONDAS ===
        # Los parametros: graphics, width, height, color, opacity(0-255), baseY, amplitude, frequency, phase, fillDown

        # Capa 1: Onda trasera (sutil, grande)
        $baseYBack = $height * 0.55
        $ampBack = $height * 0.12
        & $DrawWaveLayer $graphics $width $height $colors.WaveBack 180 $baseYBack $ampBack 1.2 0 $true

        # Capa 2: Onda media
        $baseYMid = $height * 0.62
        $ampMid = $height * 0.10
        & $DrawWaveLayer $graphics $width $height $colors.WaveMid 140 $baseYMid $ampMid 1.5 1.5 $true

        # Capa 3: Onda principal (terracota)
        $baseYMain = $height * 0.70
        $ampMain = $height * 0.08
        & $DrawWaveLayer $graphics $width $height $colors.WaveAccent 200 $baseYMain $ampMain 1.8 3.0 $true

        # Capa 4: Highlights
        $baseYHigh = $height * 0.68
        $ampHigh = $height * 0.06
        $highlightOpacity = if ($ThemeMode -eq "Light") { 60 } else { 80 }
        & $DrawWaveLayer $graphics $width $height $colors.WaveHighlight $highlightOpacity $baseYHigh $ampHigh 2.0 4.5 $true

        # === CAPA ADICIONAL PARA DARK/OLED: Puntos de luz dorados ===
        if ($ThemeMode -ne "Light") {
            $random = New-Object System.Random(42)  # Seed fijo para reproducibilidad
            $glowColor = [System.Drawing.ColorTranslator]::FromHtml("#$($colors.WaveHighlight)")

            for ($i = 0; $i -lt 15; $i++) {
                $glowX = $random.Next(0, $width)
                $glowY = $random.Next([int]($height * 0.5), [int]($height * 0.85))
                $glowSize = $random.Next(2, 8)
                $glowOpacity = $random.Next(30, 80)

                $glowBrush = New-Object System.Drawing.SolidBrush(
                    [System.Drawing.Color]::FromArgb($glowOpacity, $glowColor.R, $glowColor.G, $glowColor.B)
                )
                $graphics.FillEllipse($glowBrush, $glowX, $glowY, $glowSize, $glowSize)
                $glowBrush.Dispose()
            }
        }

        # === GUARDAR ===
        if ([string]::IsNullOrEmpty($OutputPath)) {
            $OutputPath = Join-Path $Script:Config.BasePath "Wallpapers\Claude-Waves-$ThemeMode.png"
        }

        # Asegurar que el directorio existe
        $dir = Split-Path $OutputPath -Parent
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

        # Limpiar recursos
        $graphics.Dispose()
        $bitmap.Dispose()

        Write-ClaudeLog "Wallpaper V2 generado: $OutputPath" -Level Success
        return $OutputPath
    } catch {
        Write-ClaudeLog "Error al generar wallpaper V2: $_" -Level Error
        Write-ClaudeLog $_.ScriptStackTrace -Level Error
        return $null
    }
}

function Set-DesktopWallpaper {
    param([string]$Path)

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Aplicaria wallpaper: $Path" -Level Info
        return $true
    }

    if (!(Test-Path $Path)) {
        Write-ClaudeLog "Wallpaper no encontrado: $Path" -Level Error
        return $false
    }

    Write-ClaudeLog "Aplicando wallpaper..." -Level Info

    try {
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class Wallpaper {
                [DllImport("user32.dll", CharSet = CharSet.Auto)]
                public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
            }
"@

        $SPI_SETDESKWALLPAPER = 0x0014
        $SPIF_UPDATEINIFILE = 0x01
        $SPIF_SENDCHANGE = 0x02

        [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Path, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE) | Out-Null

        Write-ClaudeLog "Wallpaper aplicado exitosamente" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al aplicar wallpaper: $_" -Level Error
        return $false
    }
}
#endregion

#region Cursor Generation
function New-ClaudeCursors {
    param([bool]$IsDarkMode = $true)

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Generaria cursores personalizados" -Level Info
        return $true
    }

    Write-ClaudeLog "Generando cursores personalizados..." -Level Info

    try {
        Add-Type -AssemblyName System.Drawing

        $colors = if ($IsDarkMode) { $Script:Config.DarkMode } else { $Script:Config.LightMode }
        $accentColor = [System.Drawing.ColorTranslator]::FromHtml("#$($colors.AccentPrimary)")
        $outlineColor = if ($IsDarkMode) { [System.Drawing.Color]::White } else { [System.Drawing.Color]::FromArgb(30, 30, 30) }

        $cursorPath = Join-Path $Script:Config.BasePath "Cursors"

        # Generar cursor normal (flecha)
        $size = 32
        $bitmap = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::Transparent)

        # Dibujar flecha
        $arrowPoints = @(
            [System.Drawing.Point]::new(4, 4),
            [System.Drawing.Point]::new(4, 24),
            [System.Drawing.Point]::new(10, 18),
            [System.Drawing.Point]::new(14, 26),
            [System.Drawing.Point]::new(18, 24),
            [System.Drawing.Point]::new(14, 16),
            [System.Drawing.Point]::new(20, 16)
        )

        # Borde
        $outlinePen = New-Object System.Drawing.Pen($outlineColor, 2)
        $graphics.DrawPolygon($outlinePen, $arrowPoints)

        # Relleno con color de acento
        $fillBrush = New-Object System.Drawing.SolidBrush($accentColor)
        $graphics.FillPolygon($fillBrush, $arrowPoints)

        # Guardar como PNG temporal (luego se convierte a .cur)
        $tempPath = Join-Path $cursorPath "normal_temp.png"
        $bitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)

        # Convertir a .cur usando estructura binaria
        $curFile = Join-Path $cursorPath "normal.cur"
        Convert-PngToCursor -PngPath $tempPath -CurPath $curFile -HotspotX 4 -HotspotY 4

        # Limpiar
        $fillBrush.Dispose()
        $outlinePen.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
        Remove-Item $tempPath -ErrorAction SilentlyContinue

        Write-ClaudeLog "Cursores generados en: $cursorPath" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al generar cursores: $_" -Level Error
        return $false
    }
}

function Convert-PngToCursor {
    param(
        [string]$PngPath,
        [string]$CurPath,
        [int]$HotspotX = 0,
        [int]$HotspotY = 0
    )

    try {
        Add-Type -AssemblyName System.Drawing

        $png = [System.Drawing.Image]::FromFile($PngPath)
        $width = $png.Width
        $height = $png.Height

        # Estructura del archivo .cur
        # ICONDIR (6 bytes) + ICONDIRENTRY (16 bytes) + imagen

        $ms = New-Object System.IO.MemoryStream
        $bw = New-Object System.IO.BinaryWriter($ms)

        # ICONDIR
        $bw.Write([UInt16]0)         # Reserved
        $bw.Write([UInt16]2)         # Type (2 = cursor)
        $bw.Write([UInt16]1)         # Number of images

        # ICONDIRENTRY
        $bw.Write([byte]$width)      # Width
        $bw.Write([byte]$height)     # Height
        $bw.Write([byte]0)           # Colors
        $bw.Write([byte]0)           # Reserved
        $bw.Write([UInt16]$HotspotX) # Hotspot X
        $bw.Write([UInt16]$HotspotY) # Hotspot Y

        # Convertir PNG a memoria para obtener tamano
        $pngMs = New-Object System.IO.MemoryStream
        $png.Save($pngMs, [System.Drawing.Imaging.ImageFormat]::Png)
        $pngBytes = $pngMs.ToArray()

        $bw.Write([UInt32]$pngBytes.Length)  # Size of image data
        $bw.Write([UInt32]22)                # Offset to image data (6 + 16)

        # Escribir datos PNG
        $bw.Write($pngBytes)

        # Guardar archivo
        [System.IO.File]::WriteAllBytes($CurPath, $ms.ToArray())

        # Limpiar
        $bw.Dispose()
        $ms.Dispose()
        $pngMs.Dispose()
        $png.Dispose()

        return $true
    } catch {
        Write-ClaudeLog "Error convirtiendo a cursor: $_" -Level Error
        return $false
    }
}

function Set-SystemCursors {
    param([string]$CursorPath)

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Aplicaria cursores del sistema" -Level Info
        return $true
    }

    Write-ClaudeLog "Aplicando cursores del sistema..." -Level Info

    try {
        $cursorRegPath = "HKCU:\Control Panel\Cursors"
        $normalCursor = Join-Path $CursorPath "normal.cur"

        if (Test-Path $normalCursor) {
            Set-ItemProperty -Path $cursorRegPath -Name "Arrow" -Value $normalCursor
            Set-ItemProperty -Path $cursorRegPath -Name "(Default)" -Value "Claude Theme"
        }

        # Notificar al sistema del cambio
        Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;

            public class CursorHelper {
                [DllImport("user32.dll", SetLastError = true)]
                public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);

                public const uint SPI_SETCURSORS = 0x0057;
                public const uint SPIF_SENDCHANGE = 0x02;
            }
"@

        [CursorHelper]::SystemParametersInfo([CursorHelper]::SPI_SETCURSORS, 0, $null, [CursorHelper]::SPIF_SENDCHANGE) | Out-Null

        Write-ClaudeLog "Cursores aplicados" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al aplicar cursores: $_" -Level Error
        return $false
    }
}
#endregion

#region TranslucentTB Integration
function Install-TranslucentTB {
    param([string]$ThemeMode = "Dark")

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Instalaria y configuraria TranslucentTB" -Level Info
        return $true
    }

    Write-ClaudeLog "Configurando TranslucentTB para taskbar flotante..." -Level Info

    try {
        # Verificar si TranslucentTB esta instalado
        $ttbInstalled = Get-Command "TranslucentTB" -ErrorAction SilentlyContinue

        if (-not $ttbInstalled) {
            # Intentar instalar via winget
            Write-ClaudeLog "Instalando TranslucentTB via winget..." -Level Info

            $wingetResult = & winget install "TranslucentTB" --accept-source-agreements --accept-package-agreements 2>&1

            if ($LASTEXITCODE -ne 0) {
                Write-ClaudeLog "No se pudo instalar TranslucentTB automaticamente" -Level Warning
                Write-ClaudeLog "Instala manualmente desde Microsoft Store: TranslucentTB" -Level Info
                Write-ClaudeLog "O ejecuta: winget install TranslucentTB" -Level Info
                return $false
            }

            Write-ClaudeLog "TranslucentTB instalado correctamente" -Level Success
        } else {
            Write-ClaudeLog "TranslucentTB ya esta instalado" -Level Success
        }

        # Crear configuracion para TranslucentTB
        $ttbConfigPath = Join-Path $env:APPDATA "TranslucentTB"
        if (!(Test-Path $ttbConfigPath)) {
            New-Item -ItemType Directory -Path $ttbConfigPath -Force | Out-Null
        }

        # Colores segun modo
        $colors = switch ($ThemeMode) {
            "Light" { $Script:Config.LightMode }
            "OLED"  { $Script:Config.OLEDMode }
            default { $Script:Config.DarkMode }
        }

        # Configuracion de TranslucentTB
        # Nota: TranslucentTB usa formato AARRGGBB
        $bgColor = $colors.Background
        $accentWithAlpha = "80$bgColor"  # 50% transparencia

        $ttbSettings = @{
            "Desktop" = @{
                "accent" = "blur"
                "color" = "#$accentWithAlpha"
                "show_peek" = $false
            }
            "VisibleWindow" = @{
                "accent" = "blur"
                "color" = "#$accentWithAlpha"
            }
            "MaximizedWindow" = @{
                "accent" = "opaque"
                "color" = "#FF$bgColor"
            }
            "StartOpened" = @{
                "accent" = "blur"
                "color" = "#$accentWithAlpha"
            }
            "SearchOpened" = @{
                "accent" = "blur"
                "color" = "#$accentWithAlpha"
            }
            "TaskViewOpened" = @{
                "accent" = "blur"
                "color" = "#$accentWithAlpha"
            }
        }

        # Guardar configuracion en carpeta del tema tambien
        $localConfigPath = Join-Path $Script:Config.BasePath "Tools\TranslucentTB"
        if (!(Test-Path $localConfigPath)) {
            New-Item -ItemType Directory -Path $localConfigPath -Force | Out-Null
        }

        $configFile = Join-Path $localConfigPath "settings-$ThemeMode.json"
        $ttbSettings | ConvertTo-Json -Depth 5 | Out-File $configFile -Encoding UTF8

        Write-ClaudeLog "Configuracion de TranslucentTB creada: $configFile" -Level Success
        Write-ClaudeLog "Para aplicar: Abre TranslucentTB y carga esta configuracion" -Level Info

        # Centrar iconos del taskbar (Windows 11 nativo)
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
            -Name "TaskbarAl" -Value 1 -Type DWord -ErrorAction SilentlyContinue

        Write-ClaudeLog "Iconos del taskbar centrados" -Level Success

        return $true
    } catch {
        Write-ClaudeLog "Error al configurar TranslucentTB: $_" -Level Error
        return $false
    }
}
#endregion

#region Font Installation
function Install-InterFont {
    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Instalaria fuente Inter" -Level Info
        return $true
    }

    Write-ClaudeLog "Instalando fuente Inter..." -Level Info

    $fontPath = Join-Path $Script:Config.BasePath "Fonts"
    $interZip = Join-Path $fontPath "Inter.zip"

    try {
        # Verificar si ya existe
        $fontsFolder = [Environment]::GetFolderPath('Fonts')
        if (Test-Path (Join-Path $fontsFolder "Inter-Regular.ttf")) {
            Write-ClaudeLog "Fuente Inter ya instalada" -Level Success
            return $true
        }

        # Descargar si no existe y no estamos offline
        if (!(Test-Path $interZip) -and !$Script:Offline) {
            if (!(Test-NetworkConnection)) {
                Write-ClaudeLog "No se puede descargar fuente sin conexion" -Level Warning
                return $false
            }

            Write-ClaudeLog "Descargando Inter desde Google Fonts..." -Level Info

            try {
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $Script:Config.Resources.InterFont -OutFile $interZip -UseBasicParsing
            } catch {
                Write-ClaudeLog "Error al descargar fuente: $_" -Level Error
                return $false
            }
        }

        if (!(Test-Path $interZip)) {
            Write-ClaudeLog "Archivo de fuente no disponible" -Level Error
            return $false
        }

        # Extraer
        $extractPath = Join-Path $fontPath "Inter_extracted"
        Expand-Archive -Path $interZip -DestinationPath $extractPath -Force

        # Instalar fuentes TTF
        $shell = New-Object -ComObject Shell.Application
        $fontsFolder = $shell.Namespace(0x14) # Fonts folder

        $ttfFiles = Get-ChildItem -Path $extractPath -Filter "*.ttf" -Recurse | Where-Object { $_.Name -like "Inter-*" }

        foreach ($ttf in $ttfFiles) {
            Write-ClaudeLog "Instalando: $($ttf.Name)" -Level Verbose
            $fontsFolder.CopyHere($ttf.FullName, 0x14) # 0x14 = no UI
        }

        # Limpiar
        Remove-Item $extractPath -Recurse -Force -ErrorAction SilentlyContinue

        Write-ClaudeLog "Fuente Inter instalada exitosamente" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al instalar fuente: $_" -Level Error
        return $false
    }
}
#endregion

#region Terminal Profile
function New-TerminalProfile {
    param([bool]$IsDarkMode = $true)

    $modeName = if ($IsDarkMode) { "Dark" } else { "Light" }

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Crearia perfil de Windows Terminal modo $modeName" -Level Info
        return $true
    }

    Write-ClaudeLog "Creando perfil de Windows Terminal modo $modeName..." -Level Info

    try {
        $colors = if ($IsDarkMode) { $Script:Config.DarkMode } else { $Script:Config.LightMode }

        $profile = @{
            name = "Claude $modeName"
            background = "#$($colors.Background)"
            foreground = "#$($colors.TextPrimary)"
            cursorColor = "#$($colors.AccentPrimary)"
            selectionBackground = "#$($colors.AccentPrimary)40"
            black = "#$($colors.Background)"
            red = if ($IsDarkMode) { "#E55A5A" } else { "#C44040" }
            green = if ($IsDarkMode) { "#5AE55A" } else { "#40A040" }
            yellow = if ($IsDarkMode) { "#E5E55A" } else { "#A0A040" }
            blue = if ($IsDarkMode) { "#5A5AE5" } else { "#4040A0" }
            purple = "#$($colors.AccentPrimary)"
            cyan = if ($IsDarkMode) { "#5AE5E5" } else { "#40A0A0" }
            white = "#$($colors.TextPrimary)"
            brightBlack = "#$($colors.Border)"
            brightRed = if ($IsDarkMode) { "#FF7A7A" } else { "#E55A5A" }
            brightGreen = if ($IsDarkMode) { "#7AFF7A" } else { "#5AC05A" }
            brightYellow = if ($IsDarkMode) { "#FFFF7A" } else { "#C0C05A" }
            brightBlue = if ($IsDarkMode) { "#7A7AFF" } else { "#5A5AC0" }
            brightPurple = "#$($colors.AccentLight)"
            brightCyan = if ($IsDarkMode) { "#7AFFFF" } else { "#5AC0C0" }
            brightWhite = "#FFFFFF"
        }

        $outputPath = Join-Path $Script:Config.BasePath "Terminal\claude-$($modeName.ToLower()).json"
        $profile | ConvertTo-Json -Depth 5 | Out-File $outputPath -Encoding UTF8

        Write-ClaudeLog "Perfil de Terminal creado: $outputPath" -Level Success

        # Instrucciones
        $readmePath = Join-Path $Script:Config.BasePath "Terminal\README-Terminal.txt"
        @"
INSTRUCCIONES PARA WINDOWS TERMINAL
====================================

Para instalar el esquema de colores de Claude en Windows Terminal:

1. Abre Windows Terminal
2. Ve a Configuracion (Ctrl+,)
3. En la barra lateral izquierda, haz clic en "Abrir archivo JSON"
4. Busca la seccion "schemes" en el archivo
5. Agrega el contenido de claude-dark.json o claude-light.json dentro del array "schemes"
6. Guarda el archivo
7. En Configuracion > Perfiles > Predeterminado > Apariencia > Esquema de colores
8. Selecciona "Claude Dark" o "Claude Light"

Ejemplo de como se veria en settings.json:

"schemes": [
    { ... otros esquemas ... },
    {
        "name": "Claude Dark",
        ... contenido del archivo ...
    }
]
"@ | Out-File $readmePath -Encoding UTF8

        return $true
    } catch {
        Write-ClaudeLog "Error al crear perfil de terminal: $_" -Level Error
        return $false
    }
}
#endregion

#region PowerShell Profile
function New-PowerShellProfile {
    param([bool]$IsDarkMode = $true)

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Crearia perfil de PowerShell" -Level Info
        return $true
    }

    Write-ClaudeLog "Creando configuracion de PowerShell..." -Level Info

    try {
        $colors = if ($IsDarkMode) { $Script:Config.DarkMode } else { $Script:Config.LightMode }

        $psProfileContent = @"
# Claude Theme PowerShell Configuration
# Generated by Set-ClaudeTheme.ps1

# Configurar colores de PSReadLine
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -Colors @{
        Command            = '#$($colors.AccentPrimary)'
        Comment            = '#$($colors.TextSecondary)'
        ContinuationPrompt = '#$($colors.TextSecondary)'
        Default            = '#$($colors.TextPrimary)'
        Emphasis           = '#$($colors.AccentLight)'
        Error              = '#E55A5A'
        InlinePrediction   = '#$($colors.Border)'
        Keyword            = '#$($colors.AccentPrimary)'
        ListPrediction     = '#$($colors.AccentLight)'
        Member             = '#$($colors.TextPrimary)'
        Number             = '#$($colors.AccentLight)'
        Operator           = '#$($colors.TextSecondary)'
        Parameter          = '#$($colors.AccentLight)'
        Selection          = '#$($colors.AccentPrimary)'
        String             = '#5AE55A'
        Type               = '#$($colors.AccentPrimary)'
        Variable           = '#$($colors.AccentLight)'
    }
}

# Prompt personalizado con colores de Claude
function prompt {
    `$lastSuccess = `$?
    `$statusColor = if (`$lastSuccess) { '#$($colors.AccentPrimary)' } else { '#E55A5A' }

    Write-Host ""
    Write-Host "`$([char]0x250C)" -NoNewline -ForegroundColor DarkGray
    Write-Host " " -NoNewline
    Write-Host `$env:USERNAME -NoNewline -ForegroundColor '$($colors.AccentPrimary)'
    Write-Host "@" -NoNewline -ForegroundColor DarkGray
    Write-Host `$env:COMPUTERNAME -NoNewline -ForegroundColor '$($colors.AccentLight)'
    Write-Host " " -NoNewline
    Write-Host `$(Get-Location) -ForegroundColor '$($colors.TextSecondary)'
    Write-Host "`$([char]0x2514)`$([char]0x2500)" -NoNewline -ForegroundColor DarkGray
    Write-Host " `$([char]0x276F)" -NoNewline -ForegroundColor `$statusColor
    return " "
}

Write-Host "Claude Theme loaded!" -ForegroundColor '#$($colors.AccentPrimary)'
"@

        $outputPath = Join-Path $Script:Config.BasePath "PowerShell\Claude-Profile.ps1"
        $psProfileContent | Out-File $outputPath -Encoding UTF8

        Write-ClaudeLog "Perfil de PowerShell creado: $outputPath" -Level Success
        Write-ClaudeLog "Para activar, agrega esta linea a tu `$PROFILE:" -Level Info
        Write-ClaudeLog "  . '$outputPath'" -Level Info

        return $true
    } catch {
        Write-ClaudeLog "Error al crear perfil de PowerShell: $_" -Level Error
        return $false
    }
}
#endregion

#region Theme File Generation
function Export-ThemeFile {
    param([bool]$IsDarkMode = $true)

    $modeName = if ($IsDarkMode) { "Dark" } else { "Light" }

    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Exportaria archivo .theme modo $modeName" -Level Info
        return $true
    }

    Write-ClaudeLog "Exportando archivo de tema modo $modeName..." -Level Info

    try {
        $colors = if ($IsDarkMode) { $Script:Config.DarkMode } else { $Script:Config.LightMode }
        $wallpaperPath = Join-Path $Script:Config.BasePath "Wallpapers\Claude-Wallpaper-$modeName.png"
        $cursorPath = Join-Path $Script:Config.BasePath "Cursors"

        $themeContent = @"
; Claude Anthropic Theme - $modeName Mode
; Generated by Set-ClaudeTheme.ps1
; Version $($Script:Config.Version)

[Theme]
DisplayName=Claude Anthropic $modeName
ThemeId={$(([guid]::NewGuid()).ToString())}

[Control Panel\Colors]
Background=$(if ($IsDarkMode) { "28 28 28" } else { "255 255 255" })
Window=$(if ($IsDarkMode) { "45 45 45" } else { "244 244 244" })
WindowText=$(if ($IsDarkMode) { "239 239 239" } else { "26 26 26" })
Hilight=204 120 92
HilightText=$(if ($IsDarkMode) { "255 255 255" } else { "26 26 26" })
ButtonFace=$(if ($IsDarkMode) { "45 45 45" } else { "244 244 244" })
ButtonText=$(if ($IsDarkMode) { "239 239 239" } else { "26 26 26" })

[Control Panel\Desktop]
Wallpaper=$wallpaperPath
TileWallpaper=0
WallpaperStyle=10

[Control Panel\Cursors]
Arrow=$cursorPath\normal.cur
AppStarting=
Crosshair=
Hand=
Help=
IBeam=
No=
NWPen=
SizeAll=
SizeNESW=
SizeNS=
SizeNWSE=
SizeWE=
UpArrow=
Wait=
DefaultValue=Claude Theme

[VisualStyles]
Path=%SystemRoot%\resources\themes\Aero\Aero.msstyles
ColorStyle=NormalColor
Size=NormalSize
AutoColorization=0
ColorizationColor=0xFF$($colors.AccentPrimary -replace '#','')
SystemMode=$(if ($IsDarkMode) { "Dark" } else { "Light" })
AppMode=$(if ($IsDarkMode) { "Dark" } else { "Light" })

[MasterThemeSelector]
MTSM=RJSPBS
"@

        $outputPath = Join-Path $Script:Config.BasePath "Themes\Claude-Anthropic-$modeName.theme"
        $themeContent | Out-File $outputPath -Encoding ASCII

        Write-ClaudeLog "Archivo de tema exportado: $outputPath" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al exportar tema: $_" -Level Error
        return $false
    }
}
#endregion

#region Explorer Restart
function Restart-Explorer {
    if ($Script:Preview) {
        Write-ClaudeLog "[PREVIEW] Reiniciaria explorer.exe" -Level Info
        return $true
    }

    Write-ClaudeLog "Reiniciando explorer.exe para aplicar cambios..." -Level Info

    try {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Start-Process explorer

        Write-ClaudeLog "Explorer reiniciado" -Level Success
        return $true
    } catch {
        Write-ClaudeLog "Error al reiniciar explorer: $_" -Level Error
        return $false
    }
}
#endregion

#region Interactive Menu
function Show-InteractiveMenu {
    Clear-Host
    Show-Banner

    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║         SELECCIONA EL MODO DEL TEMA V2            ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] " -NoNewline -ForegroundColor Yellow
    Write-Host "Claude Dark" -NoNewline -ForegroundColor White
    Write-Host "   - Tonos marrones calidos, dorados" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [2] " -NoNewline -ForegroundColor Yellow
    Write-Host "Claude Light" -NoNewline -ForegroundColor White
    Write-Host "  - Fondo crema calido, acentos terracota" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [3] " -NoNewline -ForegroundColor Yellow
    Write-Host "OLED Black" -NoNewline -ForegroundColor White
    Write-Host "   - Negro puro con acentos terracota" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [4] " -NoNewline -ForegroundColor Yellow
    Write-Host "Todos" -NoNewline -ForegroundColor White
    Write-Host "        - Generar recursos para los 3 modos" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [Q] Salir" -ForegroundColor DarkGray
    Write-Host ""

    # Mostrar preview de colores
    Write-Host "  Preview de colores:" -ForegroundColor White
    Write-Host "  " -NoNewline
    Write-Host "████" -NoNewline -ForegroundColor DarkRed      # Terracota aproximado
    Write-Host " Terracota #CC785C  " -NoNewline -ForegroundColor Gray
    Write-Host "████" -NoNewline -ForegroundColor DarkYellow   # Dorado aproximado
    Write-Host " Dorado #D4A574" -ForegroundColor Gray
    Write-Host ""

    $choice = Read-Host "  Opcion"

    switch ($choice.ToUpper()) {
        '1' { return 'Dark' }
        '2' { return 'Light' }
        '3' { return 'OLED' }
        '4' { return 'All' }
        'Q' { return $null }
        default {
            Write-Host "  Opcion invalida" -ForegroundColor Red
            Start-Sleep -Seconds 1
            return Show-InteractiveMenu
        }
    }
}
#endregion

#region Main Execution
function Invoke-ClaudeTheme {
    param([string]$SelectedMode)

    # Determinar modos a procesar
    # Nota: Usar if/else en lugar de switch para evitar problemas con arrays
    if ($SelectedMode -eq 'All') {
        $modesToProcess = @('Dark', 'Light', 'OLED')
    } else {
        $modesToProcess = @($SelectedMode)
    }

    $isMultiple = $modesToProcess.Count -gt 1
    # Usar Select-Object -First 1 para obtener el primer elemento de forma segura
    $primaryMode = $modesToProcess | Select-Object -First 1
    $isDark = ($primaryMode -eq 'Dark') -or ($primaryMode -eq 'OLED')

    # Determinar componentes a instalar
    $componentsToInstall = if ($Script:Components) {
        $Script:Components
    } else {
        $Script:Config.AllComponents
    }

    # Remover componentes omitidos
    if ($Script:SkipComponents) {
        $componentsToInstall = $componentsToInstall | Where-Object { $_ -notin $Script:SkipComponents }
    }

    Write-ClaudeLog "Modo(s): $($modesToProcess -join ', ')" -Level Info
    Write-ClaudeLog "Componentes a instalar: $($componentsToInstall -join ', ')" -Level Info

    # Ejecutar cada componente
    $results = @{}

    # Obtener colores segun modo primario
    $colors = switch ($primaryMode) {
        "Light" { $Script:Config.LightMode }
        "OLED"  { $Script:Config.OLEDMode }
        default { $Script:Config.DarkMode }
    }

    if ('Colors' -in $componentsToInstall) {
        $results['Colors'] = Set-AccentColor -Color $colors.AccentPrimary -IsDarkMode $isDark
    }

    if ('Theme' -in $componentsToInstall -and !$isMultiple) {
        $results['Theme'] = Set-ThemeMode -IsDarkMode $isDark
    }

    if ('Taskbar' -in $componentsToInstall) {
        $results['Taskbar'] = Set-TaskbarAppearance -EnableAccentColor $true -EnableTransparency $true
    }

    if ('Borders' -in $componentsToInstall) {
        $results['Borders'] = Set-WindowBorders -EnableColorization $true
    }

    # Generar wallpapers V2 con ondas Bezier
    if ('Wallpaper' -in $componentsToInstall) {
        foreach ($mode in $modesToProcess) {
            $wpPath = New-ClaudeWallpaper -ThemeMode $mode
            if ($wpPath -and !$isMultiple) {
                $results["Wallpaper-$mode"] = Set-DesktopWallpaper -Path $wpPath
            } else {
                $results["Wallpaper-$mode"] = ($null -ne $wpPath)
            }
        }
    }

    if ('Cursors' -in $componentsToInstall) {
        $results['Cursors-Generate'] = New-ClaudeCursors -IsDarkMode $isDark
        $cursorPath = Join-Path $Script:Config.BasePath "Cursors"
        $results['Cursors-Apply'] = Set-SystemCursors -CursorPath $cursorPath
    }

    if ('Font' -in $componentsToInstall) {
        $results['Font'] = Install-InterFont
    }

    # TranslucentTB para taskbar flotante
    if ('TranslucentTB' -in $componentsToInstall) {
        $results['TranslucentTB'] = Install-TranslucentTB -ThemeMode $primaryMode
    }

    # Generar perfiles de Terminal para todos los modos
    if ('Terminal' -in $componentsToInstall) {
        foreach ($mode in $modesToProcess) {
            $termIsDark = $mode -in @('Dark', 'OLED')
            $results["Terminal-$mode"] = New-TerminalProfile -IsDarkMode $termIsDark
        }
    }

    if ('PowerShell' -in $componentsToInstall) {
        $results['PowerShell'] = New-PowerShellProfile -IsDarkMode $isDark
    }

    # Exportar archivos .theme para todos los modos
    foreach ($mode in $modesToProcess) {
        $themeIsDark = $mode -in @('Dark', 'OLED')
        $results["ThemeFile-$mode"] = Export-ThemeFile -IsDarkMode $themeIsDark
    }

    return $results
}

# Entry Point
try {
    Show-Banner

    # Verificar prerequisitos
    if (!(Test-Prerequisites)) {
        Write-ClaudeLog "Prerequisitos no cumplidos. Abortando." -Level Error
        exit 1
    }

    # Verificar red
    $hasNetwork = Test-NetworkConnection

    # Seleccionar modo
    $selectedMode = if ($Mode -eq 'Interactive') {
        Show-InteractiveMenu
    } else {
        $Mode
    }

    if ($null -eq $selectedMode) {
        Write-ClaudeLog "Operacion cancelada por el usuario" -Level Warning
        exit 0
    }

    Write-ClaudeLog "Modo seleccionado: $selectedMode" -Level Info

    # Crear backup
    if (!(New-ThemeBackup)) {
        Write-ClaudeLog "Error al crear backup. Abortando por seguridad." -Level Error
        exit 1
    }

    # Aplicar tema
    Write-ClaudeLog "Aplicando tema Claude..." -Level Info
    $results = Invoke-ClaudeTheme -SelectedMode $selectedMode

    # Mostrar resumen
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         RESUMEN DE INSTALACION         " -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    $successCount = 0
    $failCount = 0

    foreach ($key in $results.Keys) {
        $status = if ($results[$key]) {
            $successCount++
            "[OK]"
        } else {
            $failCount++
            "[FAIL]"
        }
        $color = if ($results[$key]) { "Green" } else { "Red" }
        Write-Host "  $status $key" -ForegroundColor $color
    }

    Write-Host ""
    Write-Host "  Exitosos: $successCount | Fallidos: $failCount" -ForegroundColor White
    Write-Host ""

    # Reiniciar explorer si no es preview
    if (!$Script:Preview -and $successCount -gt 0) {
        $restart = Read-Host "Reiniciar explorer.exe para aplicar cambios? (S/N)"
        if ($restart -eq 'S' -or $restart -eq 's') {
            Restart-Explorer
        }
    }

    Write-ClaudeLog "Instalacion completada!" -Level Success
    Write-Host ""
    Write-Host "  Archivos generados en: $($Script:Config.BasePath)" -ForegroundColor Gray
    Write-Host ""

} catch {
    Write-ClaudeLog "Error fatal: $_" -Level Error
    Write-ClaudeLog $_.ScriptStackTrace -Level Error
    exit 1
}
#endregion
