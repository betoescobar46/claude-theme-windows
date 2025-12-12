<#
.SYNOPSIS
    Genera iconos personalizados estilo Claude
.DESCRIPTION
    Crea iconos minimalistas con la paleta de colores Claude
    para el escritorio de Windows
#>

Add-Type -AssemblyName System.Drawing

$IconsPath = "$PSScriptRoot\Icons\Custom"
if (!(Test-Path $IconsPath)) {
    New-Item -ItemType Directory -Path $IconsPath -Force | Out-Null
}

# Colores Claude
$Terracotta = [System.Drawing.Color]::FromArgb(255, 204, 120, 92)
$Gold = [System.Drawing.Color]::FromArgb(255, 212, 165, 116)
$DarkBg = [System.Drawing.Color]::FromArgb(255, 24, 20, 16)
$LightBg = [System.Drawing.Color]::FromArgb(255, 255, 248, 240)
$White = [System.Drawing.Color]::White
$DarkText = [System.Drawing.Color]::FromArgb(255, 26, 26, 26)

function New-IconBitmap {
    param(
        [int]$Size = 256,
        [System.Drawing.Color]$Background,
        [scriptblock]$DrawContent
    )

    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

    # Fondo redondeado
    $graphics.Clear([System.Drawing.Color]::Transparent)

    $radius = $Size * 0.15
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Size, $Size)

    $path.AddArc($rect.X, $rect.Y, $radius * 2, $radius * 2, 180, 90)
    $path.AddArc($rect.Right - $radius * 2, $rect.Y, $radius * 2, $radius * 2, 270, 90)
    $path.AddArc($rect.Right - $radius * 2, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
    $path.CloseFigure()

    $bgBrush = New-Object System.Drawing.SolidBrush($Background)
    $graphics.FillPath($bgBrush, $path)

    # Dibujar contenido
    & $DrawContent $graphics $Size

    $bgBrush.Dispose()
    $path.Dispose()
    $graphics.Dispose()

    return $bitmap
}

function Save-AsIco {
    param(
        [System.Drawing.Bitmap]$Bitmap,
        [string]$Path
    )

    # Crear versiones de diferentes tamanos
    $sizes = @(256, 48, 32, 16)
    $images = @()

    foreach ($size in $sizes) {
        $resized = New-Object System.Drawing.Bitmap($size, $size)
        $g = [System.Drawing.Graphics]::FromImage($resized)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.DrawImage($Bitmap, 0, 0, $size, $size)
        $g.Dispose()
        $images += $resized
    }

    # Crear archivo ICO
    $ms = New-Object System.IO.MemoryStream
    $bw = New-Object System.IO.BinaryWriter($ms)

    # ICONDIR
    $bw.Write([UInt16]0)           # Reserved
    $bw.Write([UInt16]1)           # Type (1 = ICO)
    $bw.Write([UInt16]$images.Count)  # Number of images

    $offset = 6 + (16 * $images.Count)
    $imageDataList = @()

    # ICONDIRENTRY para cada imagen
    foreach ($img in $images) {
        $imgMs = New-Object System.IO.MemoryStream
        $img.Save($imgMs, [System.Drawing.Imaging.ImageFormat]::Png)
        $imgData = $imgMs.ToArray()
        $imageDataList += ,$imgData
        $imgMs.Dispose()

        $bw.Write([byte]$(if ($img.Width -eq 256) { 0 } else { $img.Width }))
        $bw.Write([byte]$(if ($img.Height -eq 256) { 0 } else { $img.Height }))
        $bw.Write([byte]0)         # Colors
        $bw.Write([byte]0)         # Reserved
        $bw.Write([UInt16]1)       # Color planes
        $bw.Write([UInt16]32)      # Bits per pixel
        $bw.Write([UInt32]$imgData.Length)
        $bw.Write([UInt32]$offset)
        $offset += $imgData.Length
    }

    # Image data
    foreach ($imgData in $imageDataList) {
        $bw.Write($imgData)
    }

    [System.IO.File]::WriteAllBytes($Path, $ms.ToArray())

    $bw.Dispose()
    $ms.Dispose()
    foreach ($img in $images) { $img.Dispose() }
}

Write-Host "Generando iconos Claude..." -ForegroundColor Cyan

# 1. Icono de Computadora (Monitor)
$computerBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.04)
    $brush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Monitor
    $monitorRect = New-Object System.Drawing.RectangleF(($s * 0.15), ($s * 0.15), ($s * 0.7), ($s * 0.5))
    $g.DrawRectangle($pen, [System.Drawing.Rectangle]::Round($monitorRect))

    # Pantalla interior
    $screenRect = New-Object System.Drawing.RectangleF(($s * 0.2), ($s * 0.2), ($s * 0.6), ($s * 0.4))
    $screenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, $Terracotta.R, $Terracotta.G, $Terracotta.B))
    $g.FillRectangle($screenBrush, $screenRect)

    # Soporte
    $g.DrawLine($pen, ($s * 0.5), ($s * 0.65), ($s * 0.5), ($s * 0.75))
    $g.DrawLine($pen, ($s * 0.3), ($s * 0.75), ($s * 0.7), ($s * 0.75))

    # Punto de acento
    $g.FillEllipse($brush, ($s * 0.46), ($s * 0.58), ($s * 0.08), ($s * 0.04))

    $pen.Dispose()
    $brush.Dispose()
    $screenBrush.Dispose()
}
Save-AsIco -Bitmap $computerBitmap -Path "$IconsPath\Computer.ico"
$computerBitmap.Dispose()
Write-Host "  [+] Computer.ico" -ForegroundColor Green

# 2. Icono de Papelera (Trash)
$trashBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.035)
    $brush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Tapa
    $g.DrawLine($pen, ($s * 0.25), ($s * 0.25), ($s * 0.75), ($s * 0.25))
    $g.FillRectangle($brush, ($s * 0.4), ($s * 0.18), ($s * 0.2), ($s * 0.07))

    # Cuerpo
    $points = @(
        [System.Drawing.PointF]::new(($s * 0.28), ($s * 0.28)),
        [System.Drawing.PointF]::new(($s * 0.72), ($s * 0.28)),
        [System.Drawing.PointF]::new(($s * 0.68), ($s * 0.8)),
        [System.Drawing.PointF]::new(($s * 0.32), ($s * 0.8))
    )
    $g.DrawPolygon($pen, $points)

    # Lineas internas
    $g.DrawLine($pen, ($s * 0.4), ($s * 0.35), ($s * 0.38), ($s * 0.72))
    $g.DrawLine($pen, ($s * 0.5), ($s * 0.35), ($s * 0.5), ($s * 0.72))
    $g.DrawLine($pen, ($s * 0.6), ($s * 0.35), ($s * 0.62), ($s * 0.72))

    $pen.Dispose()
    $brush.Dispose()
}
Save-AsIco -Bitmap $trashBitmap -Path "$IconsPath\RecycleBin.ico"
Save-AsIco -Bitmap $trashBitmap -Path "$IconsPath\RecycleBinEmpty.ico"
$trashBitmap.Dispose()
Write-Host "  [+] RecycleBin.ico" -ForegroundColor Green

# 3. Icono de Carpeta
$folderBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $bodyBrush = New-Object System.Drawing.SolidBrush($Gold)
    $tabBrush = New-Object System.Drawing.SolidBrush($Terracotta)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.02)

    # Pestana
    $tabPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $tabPath.AddPolygon(@(
        [System.Drawing.PointF]::new(($s * 0.15), ($s * 0.3)),
        [System.Drawing.PointF]::new(($s * 0.35), ($s * 0.3)),
        [System.Drawing.PointF]::new(($s * 0.4), ($s * 0.22)),
        [System.Drawing.PointF]::new(($s * 0.15), ($s * 0.22))
    ))
    $g.FillPath($tabBrush, $tabPath)

    # Cuerpo de carpeta
    $bodyRect = New-Object System.Drawing.RectangleF(($s * 0.15), ($s * 0.3), ($s * 0.7), ($s * 0.5))
    $g.FillRectangle($bodyBrush, $bodyRect)
    $g.DrawRectangle($pen, [System.Drawing.Rectangle]::Round($bodyRect))

    $tabPath.Dispose()
    $bodyBrush.Dispose()
    $tabBrush.Dispose()
    $pen.Dispose()
}
Save-AsIco -Bitmap $folderBitmap -Path "$IconsPath\Folder.ico"
$folderBitmap.Dispose()
Write-Host "  [+] Folder.ico" -ForegroundColor Green

# 4. Icono de Documentos
$docsBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.03)
    $brush = New-Object System.Drawing.SolidBrush($Gold)
    $lineBrush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Pagina
    $pagePoints = @(
        [System.Drawing.PointF]::new(($s * 0.2), ($s * 0.15)),
        [System.Drawing.PointF]::new(($s * 0.65), ($s * 0.15)),
        [System.Drawing.PointF]::new(($s * 0.8), ($s * 0.3)),
        [System.Drawing.PointF]::new(($s * 0.8), ($s * 0.85)),
        [System.Drawing.PointF]::new(($s * 0.2), ($s * 0.85))
    )
    $g.DrawPolygon($pen, $pagePoints)

    # Esquina doblada
    $cornerPoints = @(
        [System.Drawing.PointF]::new(($s * 0.65), ($s * 0.15)),
        [System.Drawing.PointF]::new(($s * 0.65), ($s * 0.3)),
        [System.Drawing.PointF]::new(($s * 0.8), ($s * 0.3))
    )
    $g.FillPolygon($brush, $cornerPoints)
    $g.DrawPolygon($pen, $cornerPoints)

    # Lineas de texto
    for ($i = 0; $i -lt 4; $i++) {
        $y = ($s * 0.4) + ($i * $s * 0.1)
        $g.FillRectangle($lineBrush, ($s * 0.28), $y, ($s * 0.44), ($s * 0.025))
    }

    $pen.Dispose()
    $brush.Dispose()
    $lineBrush.Dispose()
}
Save-AsIco -Bitmap $docsBitmap -Path "$IconsPath\Documents.ico"
$docsBitmap.Dispose()
Write-Host "  [+] Documents.ico" -ForegroundColor Green

# 5. Icono de Descargas
$downloadsBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.04)
    $brush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Flecha hacia abajo
    $arrowPoints = @(
        [System.Drawing.PointF]::new(($s * 0.5), ($s * 0.65)),
        [System.Drawing.PointF]::new(($s * 0.3), ($s * 0.45)),
        [System.Drawing.PointF]::new(($s * 0.4), ($s * 0.45)),
        [System.Drawing.PointF]::new(($s * 0.4), ($s * 0.2)),
        [System.Drawing.PointF]::new(($s * 0.6), ($s * 0.2)),
        [System.Drawing.PointF]::new(($s * 0.6), ($s * 0.45)),
        [System.Drawing.PointF]::new(($s * 0.7), ($s * 0.45))
    )
    $g.FillPolygon($brush, $arrowPoints)

    # Linea de base
    $g.DrawLine($pen, ($s * 0.2), ($s * 0.75), ($s * 0.8), ($s * 0.75))

    $pen.Dispose()
    $brush.Dispose()
}
Save-AsIco -Bitmap $downloadsBitmap -Path "$IconsPath\Downloads.ico"
$downloadsBitmap.Dispose()
Write-Host "  [+] Downloads.ico" -ForegroundColor Green

# 6. Icono de Imagenes
$picturesBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.03)
    $brush = New-Object System.Drawing.SolidBrush($Gold)
    $sunBrush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Marco
    $frameRect = New-Object System.Drawing.RectangleF(($s * 0.15), ($s * 0.2), ($s * 0.7), ($s * 0.6))
    $g.DrawRectangle($pen, [System.Drawing.Rectangle]::Round($frameRect))

    # Montanas
    $mountainPoints = @(
        [System.Drawing.PointF]::new(($s * 0.15), ($s * 0.75)),
        [System.Drawing.PointF]::new(($s * 0.4), ($s * 0.45)),
        [System.Drawing.PointF]::new(($s * 0.55), ($s * 0.6)),
        [System.Drawing.PointF]::new(($s * 0.75), ($s * 0.35)),
        [System.Drawing.PointF]::new(($s * 0.85), ($s * 0.75))
    )
    $g.FillPolygon($brush, $mountainPoints)

    # Sol
    $g.FillEllipse($sunBrush, ($s * 0.6), ($s * 0.25), ($s * 0.15), ($s * 0.15))

    $pen.Dispose()
    $brush.Dispose()
    $sunBrush.Dispose()
}
Save-AsIco -Bitmap $picturesBitmap -Path "$IconsPath\Pictures.ico"
$picturesBitmap.Dispose()
Write-Host "  [+] Pictures.ico" -ForegroundColor Green

# 7. Icono de Musica
$musicBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.035)
    $brush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Notas musicales
    $g.FillEllipse($brush, ($s * 0.25), ($s * 0.55), ($s * 0.15), ($s * 0.12))
    $g.FillEllipse($brush, ($s * 0.6), ($s * 0.45), ($s * 0.15), ($s * 0.12))

    # Lineas verticales
    $g.DrawLine($pen, ($s * 0.38), ($s * 0.6), ($s * 0.38), ($s * 0.2))
    $g.DrawLine($pen, ($s * 0.73), ($s * 0.5), ($s * 0.73), ($s * 0.2))

    # Linea conectora
    $g.DrawLine($pen, ($s * 0.38), ($s * 0.2), ($s * 0.73), ($s * 0.2))

    $pen.Dispose()
    $brush.Dispose()
}
Save-AsIco -Bitmap $musicBitmap -Path "$IconsPath\Music.ico"
$musicBitmap.Dispose()
Write-Host "  [+] Music.ico" -ForegroundColor Green

# 8. Icono de Videos
$videosBitmap = New-IconBitmap -Size 256 -Background $DarkBg -DrawContent {
    param($g, $s)
    $pen = New-Object System.Drawing.Pen($Terracotta, $s * 0.03)
    $brush = New-Object System.Drawing.SolidBrush($Terracotta)

    # Cuerpo de camara
    $bodyRect = New-Object System.Drawing.RectangleF(($s * 0.15), ($s * 0.3), ($s * 0.5), ($s * 0.4))
    $g.DrawRectangle($pen, [System.Drawing.Rectangle]::Round($bodyRect))

    # Lente/Vista
    $lensPoints = @(
        [System.Drawing.PointF]::new(($s * 0.65), ($s * 0.35)),
        [System.Drawing.PointF]::new(($s * 0.85), ($s * 0.25)),
        [System.Drawing.PointF]::new(($s * 0.85), ($s * 0.75)),
        [System.Drawing.PointF]::new(($s * 0.65), ($s * 0.65))
    )
    $g.FillPolygon($brush, $lensPoints)

    # Boton de grabar
    $g.FillEllipse($brush, ($s * 0.2), ($s * 0.35), ($s * 0.1), ($s * 0.1))

    $pen.Dispose()
    $brush.Dispose()
}
Save-AsIco -Bitmap $videosBitmap -Path "$IconsPath\Videos.ico"
$videosBitmap.Dispose()
Write-Host "  [+] Videos.ico" -ForegroundColor Green

Write-Host ""
Write-Host "Iconos generados en: $IconsPath" -ForegroundColor Green
Write-Host ""

# Aplicar iconos al escritorio
Write-Host "Aplicando iconos al escritorio..." -ForegroundColor Cyan

$clsids = @{
    # Este equipo
    "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" = "$IconsPath\Computer.ico"
    # Papelera llena
    "{645FF040-5081-101B-9F08-00AA002F954E}" = "$IconsPath\RecycleBin.ico"
    # Documentos
    "Documents" = "$IconsPath\Documents.ico"
    # Descargas
    "Downloads" = "$IconsPath\Downloads.ico"
}

foreach ($clsid in $clsids.Keys) {
    $iconPath = $clsids[$clsid]
    if ($clsid -like "{*}") {
        # CLSID del sistema
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$clsid\DefaultIcon"
        if (!(Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        Set-ItemProperty -Path $regPath -Name "(Default)" -Value $iconPath -ErrorAction SilentlyContinue
        Write-Host "  [+] Aplicado: $clsid" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Iconos aplicados! Reinicia explorer para ver los cambios." -ForegroundColor Green
