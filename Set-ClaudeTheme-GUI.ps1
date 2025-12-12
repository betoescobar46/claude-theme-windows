<#
.SYNOPSIS
    Claude Theme Installer - Version con Interfaz Grafica

.DESCRIPTION
    Interfaz grafica amigable para instalar el tema Claude en Windows 11.
    Permite seleccionar componentes y ver preview de colores.

.NOTES
    Author: Claude Code Assistant
    Version: 1.0.0
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Script:BasePath = $PSScriptRoot

#region Colors
$Script:ClaudeColors = @{
    Dark = @{
        AccentPrimary = [System.Drawing.Color]::FromArgb(204, 120, 92)
        Background = [System.Drawing.Color]::FromArgb(28, 28, 28)
        BackgroundElevated = [System.Drawing.Color]::FromArgb(45, 45, 45)
        Text = [System.Drawing.Color]::FromArgb(239, 239, 239)
        TextSecondary = [System.Drawing.Color]::FromArgb(160, 160, 160)
    }
    Light = @{
        AccentPrimary = [System.Drawing.Color]::FromArgb(204, 120, 92)
        Background = [System.Drawing.Color]::FromArgb(255, 255, 255)
        BackgroundElevated = [System.Drawing.Color]::FromArgb(244, 244, 244)
        Text = [System.Drawing.Color]::FromArgb(26, 26, 26)
        TextSecondary = [System.Drawing.Color]::FromArgb(107, 107, 107)
    }
}
#endregion

#region Admin Check
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
#endregion

#region Create Form
function New-ClaudeThemeForm {
    # Form principal
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Claude Theme Installer"
    $form.Size = New-Object System.Drawing.Size(600, 700)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false
    $form.BackColor = $Script:ClaudeColors.Dark.Background
    $form.ForeColor = $Script:ClaudeColors.Dark.Text

    # Panel de titulo
    $titlePanel = New-Object System.Windows.Forms.Panel
    $titlePanel.Location = New-Object System.Drawing.Point(0, 0)
    $titlePanel.Size = New-Object System.Drawing.Size(600, 80)
    $titlePanel.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated

    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Claude Theme"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = $Script:ClaudeColors.Dark.AccentPrimary
    $titleLabel.Location = New-Object System.Drawing.Point(20, 15)
    $titleLabel.AutoSize = $true
    $titlePanel.Controls.Add($titleLabel)

    $subtitleLabel = New-Object System.Windows.Forms.Label
    $subtitleLabel.Text = "Windows 11 Theme by Anthropic"
    $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $subtitleLabel.ForeColor = $Script:ClaudeColors.Dark.TextSecondary
    $subtitleLabel.Location = New-Object System.Drawing.Point(22, 55)
    $subtitleLabel.AutoSize = $true
    $titlePanel.Controls.Add($subtitleLabel)

    $form.Controls.Add($titlePanel)

    # Seccion: Seleccion de modo
    $modeGroupBox = New-Object System.Windows.Forms.GroupBox
    $modeGroupBox.Text = "Modo del Tema"
    $modeGroupBox.Location = New-Object System.Drawing.Point(20, 100)
    $modeGroupBox.Size = New-Object System.Drawing.Size(540, 80)
    $modeGroupBox.ForeColor = $Script:ClaudeColors.Dark.Text
    $modeGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    $radioDark = New-Object System.Windows.Forms.RadioButton
    $radioDark.Text = "Modo Oscuro (Dark)"
    $radioDark.Location = New-Object System.Drawing.Point(20, 30)
    $radioDark.Size = New-Object System.Drawing.Size(200, 30)
    $radioDark.ForeColor = $Script:ClaudeColors.Dark.Text
    $radioDark.Checked = $true
    $modeGroupBox.Controls.Add($radioDark)

    $radioLight = New-Object System.Windows.Forms.RadioButton
    $radioLight.Text = "Modo Claro (Light)"
    $radioLight.Location = New-Object System.Drawing.Point(250, 30)
    $radioLight.Size = New-Object System.Drawing.Size(200, 30)
    $radioLight.ForeColor = $Script:ClaudeColors.Dark.Text
    $modeGroupBox.Controls.Add($radioLight)

    $form.Controls.Add($modeGroupBox)

    # Panel de preview de colores
    $previewPanel = New-Object System.Windows.Forms.Panel
    $previewPanel.Location = New-Object System.Drawing.Point(20, 190)
    $previewPanel.Size = New-Object System.Drawing.Size(540, 60)
    $previewPanel.BorderStyle = "FixedSingle"

    $previewLabel = New-Object System.Windows.Forms.Label
    $previewLabel.Text = "Preview del tema"
    $previewLabel.Location = New-Object System.Drawing.Point(10, 5)
    $previewLabel.AutoSize = $true
    $previewPanel.Controls.Add($previewLabel)

    # Muestras de color
    $sample0 = New-Object System.Windows.Forms.Panel
    $sample0.Location = New-Object System.Drawing.Point(10, 25)
    $sample0.Size = New-Object System.Drawing.Size(100, 25)
    $sample0.BorderStyle = "FixedSingle"
    $sample0.BackColor = $Script:ClaudeColors.Dark.AccentPrimary
    $previewPanel.Controls.Add($sample0)

    $sample1 = New-Object System.Windows.Forms.Panel
    $sample1.Location = New-Object System.Drawing.Point(115, 25)
    $sample1.Size = New-Object System.Drawing.Size(100, 25)
    $sample1.BorderStyle = "FixedSingle"
    $sample1.BackColor = $Script:ClaudeColors.Dark.Background
    $previewPanel.Controls.Add($sample1)

    $sample2 = New-Object System.Windows.Forms.Panel
    $sample2.Location = New-Object System.Drawing.Point(220, 25)
    $sample2.Size = New-Object System.Drawing.Size(100, 25)
    $sample2.BorderStyle = "FixedSingle"
    $sample2.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated
    $previewPanel.Controls.Add($sample2)

    $sample3 = New-Object System.Windows.Forms.Panel
    $sample3.Location = New-Object System.Drawing.Point(325, 25)
    $sample3.Size = New-Object System.Drawing.Size(100, 25)
    $sample3.BorderStyle = "FixedSingle"
    $sample3.BackColor = $Script:ClaudeColors.Dark.Text
    $previewPanel.Controls.Add($sample3)

    $sample4 = New-Object System.Windows.Forms.Panel
    $sample4.Location = New-Object System.Drawing.Point(430, 25)
    $sample4.Size = New-Object System.Drawing.Size(100, 25)
    $sample4.BorderStyle = "FixedSingle"
    $sample4.BackColor = $Script:ClaudeColors.Dark.TextSecondary
    $previewPanel.Controls.Add($sample4)

    # Actualizar colores del preview segun modo
    $radioDark.Add_CheckedChanged({
        $colors = $Script:ClaudeColors.Dark
        $previewPanel.BackColor = $colors.Background
        $previewLabel.ForeColor = $colors.Text
        $sample0.BackColor = $colors.AccentPrimary
        $sample1.BackColor = $colors.Background
        $sample2.BackColor = $colors.BackgroundElevated
        $sample3.BackColor = $colors.Text
        $sample4.BackColor = $colors.TextSecondary
    })

    $radioLight.Add_CheckedChanged({
        $colors = $Script:ClaudeColors.Light
        $previewPanel.BackColor = $colors.Background
        $previewLabel.ForeColor = $colors.Text
        $sample0.BackColor = $colors.AccentPrimary
        $sample1.BackColor = $colors.Background
        $sample2.BackColor = $colors.BackgroundElevated
        $sample3.BackColor = $colors.Text
        $sample4.BackColor = $colors.TextSecondary
    })

    $form.Controls.Add($previewPanel)

    # Seccion: Componentes
    $compGroupBox = New-Object System.Windows.Forms.GroupBox
    $compGroupBox.Text = "Componentes a Instalar"
    $compGroupBox.Location = New-Object System.Drawing.Point(20, 260)
    $compGroupBox.Size = New-Object System.Drawing.Size(540, 280)
    $compGroupBox.ForeColor = $Script:ClaudeColors.Dark.Text
    $compGroupBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)

    $components = @(
        @{ Name = "Colors"; Text = "Colores del sistema"; Checked = $true },
        @{ Name = "Theme"; Text = "Tema claro/oscuro"; Checked = $true },
        @{ Name = "Taskbar"; Text = "Barra de tareas"; Checked = $true },
        @{ Name = "Borders"; Text = "Bordes de ventanas"; Checked = $true },
        @{ Name = "Wallpaper"; Text = "Fondo de pantalla"; Checked = $true },
        @{ Name = "Cursors"; Text = "Cursores personalizados"; Checked = $true },
        @{ Name = "Font"; Text = "Fuente Inter"; Checked = $false },
        @{ Name = "Terminal"; Text = "Perfil Windows Terminal"; Checked = $true },
        @{ Name = "PowerShell"; Text = "Colores PowerShell"; Checked = $true },
        @{ Name = "ExplorerPatcher"; Text = "ExplorerPatcher (avanzado)"; Checked = $false }
    )

    $checkBoxes = @{}
    $yPos = 25
    $col = 0
    foreach ($comp in $components) {
        $cb = New-Object System.Windows.Forms.CheckBox
        $cb.Text = $comp.Text
        $cb.Name = $comp.Name
        $cb.Checked = $comp.Checked
        $cb.Location = New-Object System.Drawing.Point((20 + ($col * 260)), $yPos)
        $cb.Size = New-Object System.Drawing.Size(240, 25)
        $cb.ForeColor = $Script:ClaudeColors.Dark.Text
        $compGroupBox.Controls.Add($cb)
        $checkBoxes[$comp.Name] = $cb

        $col++
        if ($col -ge 2) {
            $col = 0
            $yPos += 30
        }
    }

    # Botones Select All / Deselect All
    $selectAllBtn = New-Object System.Windows.Forms.Button
    $selectAllBtn.Text = "Seleccionar todo"
    $selectAllBtn.Location = New-Object System.Drawing.Point(20, 240)
    $selectAllBtn.Size = New-Object System.Drawing.Size(120, 25)
    $selectAllBtn.FlatStyle = "Flat"
    $selectAllBtn.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated
    $selectAllBtn.ForeColor = $Script:ClaudeColors.Dark.Text
    $selectAllBtn.Add_Click({
        foreach ($key in $checkBoxes.Keys) {
            $checkBoxes[$key].Checked = $true
        }
    })
    $compGroupBox.Controls.Add($selectAllBtn)

    $deselectAllBtn = New-Object System.Windows.Forms.Button
    $deselectAllBtn.Text = "Deseleccionar todo"
    $deselectAllBtn.Location = New-Object System.Drawing.Point(150, 240)
    $deselectAllBtn.Size = New-Object System.Drawing.Size(130, 25)
    $deselectAllBtn.FlatStyle = "Flat"
    $deselectAllBtn.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated
    $deselectAllBtn.ForeColor = $Script:ClaudeColors.Dark.Text
    $deselectAllBtn.Add_Click({
        foreach ($key in $checkBoxes.Keys) {
            $checkBoxes[$key].Checked = $false
        }
    })
    $compGroupBox.Controls.Add($deselectAllBtn)

    $form.Controls.Add($compGroupBox)

    # Botones de accion
    $installBtn = New-Object System.Windows.Forms.Button
    $installBtn.Text = "Instalar Tema"
    $installBtn.Location = New-Object System.Drawing.Point(20, 560)
    $installBtn.Size = New-Object System.Drawing.Size(170, 45)
    $installBtn.FlatStyle = "Flat"
    $installBtn.BackColor = $Script:ClaudeColors.Dark.AccentPrimary
    $installBtn.ForeColor = [System.Drawing.Color]::White
    $installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $installBtn.Add_Click({
        # Recopilar componentes seleccionados
        $selectedComponents = @()
        foreach ($key in $checkBoxes.Keys) {
            if ($checkBoxes[$key].Checked) {
                $selectedComponents += $key
            }
        }

        if ($selectedComponents.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show(
                "Selecciona al menos un componente para instalar.",
                "Sin componentes",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            return
        }

        $mode = if ($radioDark.Checked) { "Dark" } else { "Light" }
        $componentsStr = $selectedComponents -join ","

        # Confirmar
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Se instalara el tema Claude en modo $mode con los siguientes componentes:`n`n$($selectedComponents -join ', ')`n`nContinuar?",
            "Confirmar instalacion",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $form.Hide()

            # Ejecutar script principal
            $scriptPath = Join-Path $Script:BasePath "Set-ClaudeTheme.ps1"
            $arguments = "-Mode $mode -Components $componentsStr"

            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" $arguments" -Verb RunAs -Wait

            [System.Windows.Forms.MessageBox]::Show(
                "Instalacion completada.`nPuede ser necesario reiniciar explorer.exe para ver todos los cambios.",
                "Completado",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )

            $form.Close()
        }
    })
    $form.Controls.Add($installBtn)

    $previewBtn = New-Object System.Windows.Forms.Button
    $previewBtn.Text = "Vista Previa"
    $previewBtn.Location = New-Object System.Drawing.Point(200, 560)
    $previewBtn.Size = New-Object System.Drawing.Size(120, 45)
    $previewBtn.FlatStyle = "Flat"
    $previewBtn.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated
    $previewBtn.ForeColor = $Script:ClaudeColors.Dark.Text
    $previewBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $previewBtn.Add_Click({
        $mode = if ($radioDark.Checked) { "Dark" } else { "Light" }
        $scriptPath = Join-Path $Script:BasePath "Set-ClaudeTheme.ps1"

        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -Mode $mode -Preview" -Wait

        [System.Windows.Forms.MessageBox]::Show(
            "Revisa la ventana de PowerShell para ver que cambios se aplicarian.",
            "Vista Previa",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    })
    $form.Controls.Add($previewBtn)

    $restoreBtn = New-Object System.Windows.Forms.Button
    $restoreBtn.Text = "Restaurar Original"
    $restoreBtn.Location = New-Object System.Drawing.Point(330, 560)
    $restoreBtn.Size = New-Object System.Drawing.Size(130, 45)
    $restoreBtn.FlatStyle = "Flat"
    $restoreBtn.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated
    $restoreBtn.ForeColor = $Script:ClaudeColors.Dark.Text
    $restoreBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $restoreBtn.Add_Click({
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Esto restaurara la configuracion original de Windows.`n`nContinuar?",
            "Restaurar configuracion",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )

        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            $form.Hide()
            $scriptPath = Join-Path $Script:BasePath "Restore-OriginalTheme.ps1"
            Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait
            $form.Close()
        }
    })
    $form.Controls.Add($restoreBtn)

    $exitBtn = New-Object System.Windows.Forms.Button
    $exitBtn.Text = "Salir"
    $exitBtn.Location = New-Object System.Drawing.Point(470, 560)
    $exitBtn.Size = New-Object System.Drawing.Size(90, 45)
    $exitBtn.FlatStyle = "Flat"
    $exitBtn.BackColor = $Script:ClaudeColors.Dark.BackgroundElevated
    $exitBtn.ForeColor = $Script:ClaudeColors.Dark.TextSecondary
    $exitBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $exitBtn.Add_Click({ $form.Close() })
    $form.Controls.Add($exitBtn)

    # Status bar
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = "Listo para instalar"
    $statusLabel.Location = New-Object System.Drawing.Point(20, 620)
    $statusLabel.Size = New-Object System.Drawing.Size(540, 20)
    $statusLabel.ForeColor = $Script:ClaudeColors.Dark.TextSecondary
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($statusLabel)

    # Inicializar preview con colores oscuros
    $previewPanel.BackColor = $Script:ClaudeColors.Dark.Background
    $previewLabel.ForeColor = $Script:ClaudeColors.Dark.Text

    return $form
}
#endregion

#region Main
# Verificar admin
if (!(Test-Administrator)) {
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Se requieren permisos de administrador para instalar el tema.`n`nReiniciar como administrador?",
        "Permisos requeridos",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    exit
}

# Crear y mostrar formulario
$mainForm = New-ClaudeThemeForm
[void]$mainForm.ShowDialog()
#endregion
