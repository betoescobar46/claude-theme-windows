# ClaudeTheme - Instrucciones para Claude Code

## Descripcion del Proyecto
Tema de Windows 11 inspirado en Claude AI de Anthropic. Usa una paleta de colores elegante y desaturada con tonos salmon calidos.

## Paleta de Colores Principal
- **Salmon primario**: `#D4A08A` - Color de acento principal
- **Salmon claro**: `#E8CABA` - Highlights
- **Salmon oscuro**: `#C4978A` - Sombras
- **Fondo oscuro**: `#2D2B2A` - Background dark mode
- **Pampas**: `#F4F3EE` - Background light mode (oficial Anthropic)
- **Cloudy**: `#B1ADA1` - Color secundario (oficial Anthropic)

## Archivos Clave
- `Set-ClaudeTheme.ps1` - Script principal de instalacion
- `Wallpapers/Claude-Waves-Dark.png` - Wallpaper con ondas solo en tonos salmon
- `Terminal/` - Esquemas de color para Windows Terminal
- `Themes/` - Archivos .theme exportables

## Reglas de Desarrollo
1. **Solo tonos salmon** en wallpapers - no usar grises ni marrones
2. **Sin TranslucentTB** - fue removido del proyecto
3. Color de acento siempre `#D4A08A` en formato ABGR: `0xFF8AA0D4`
4. Barras de titulo compactas (CaptionHeight: -200)
5. Animaciones tipo fade/dissolve, no slide/zoom

## Registro de Windows Relevante
```powershell
# Accent color (ABGR format)
$dwm = "HKCU:\SOFTWARE\Microsoft\Windows\DWM"
$personalize = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$accent = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent"

# Virtual desktops wallpaper
$desktops = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops\Desktops"
```

## Comandos Utiles
```powershell
# Aplicar tema dark
.\Set-ClaudeTheme.ps1 -Mode Dark

# Reiniciar explorer para aplicar cambios
Stop-Process -Name explorer -Force; Start-Sleep -Seconds 2; Start-Process explorer
```
