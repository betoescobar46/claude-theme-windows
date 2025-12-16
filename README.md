# Claude Theme for Windows 11

A beautiful Windows 11 theme inspired by [Claude AI](https://claude.ai) from Anthropic. Features an elegant, desaturated color palette with warm pastel tones.

![Claude Theme Preview](https://img.shields.io/badge/Windows-11-blue?style=flat-square) ![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-purple?style=flat-square) ![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

## Features

- **Three color modes**: Dark, Light, and OLED Black
- **Official Claude colors**: Pampas (#F4F3EE), Cloudy (#B1ADA1), and soft salmon accents
- **Artistic wallpapers**: Generated with multi-layer Bezier wave algorithms
- **Windows Terminal profiles**: Claude-themed color schemes
- **Custom icons**: Minimalist style with warm accents
- **Inter font**: Clean typography similar to Claude's interface
- **Full backup & restore**: Safe to try, easy to revert

## Color Palette

### Dark Mode (V3 Elegant)
| Element | Hex | Preview |
|---------|-----|---------|
| Accent Primary | `#D4A08A` | Soft salmon |
| Accent Light | `#E8CABA` | Cream pink |
| Background | `#2D2B2A` | Warm neutral gray |
| Text | `#ECECEC` | Soft white |
| Secondary | `#B1ADA1` | Cloudy (official) |

### Light Mode
| Element | Hex | Preview |
|---------|-----|---------|
| Background | `#F4F3EE` | Pampas (official) |
| Text | `#2D2B2A` | Warm dark gray |
| Accent | `#D4A08A` | Soft salmon |

## Installation

### Quick Install
```powershell
# Run as Administrator
cd ClaudeTheme
.\Set-ClaudeTheme.ps1 -Mode Dark
```

### Interactive Mode
```powershell
.\Set-ClaudeTheme.ps1
# Follow the menu to select mode and components
```

### Select Specific Components
```powershell
.\Set-ClaudeTheme.ps1 -Mode Dark -Components Colors,Wallpaper,Terminal
```

## Switching Modes

```powershell
.\Set-ClaudeTheme.ps1 -Mode Dark   # Warm dark theme
.\Set-ClaudeTheme.ps1 -Mode Light  # Pampas cream theme
.\Set-ClaudeTheme.ps1 -Mode OLED   # Pure black for OLED displays
```

## Reverting Changes

```powershell
.\Restore-OriginalTheme.ps1
```

This will restore all original settings from the backup created during installation.

## Directory Structure

```
ClaudeTheme/
├── Set-ClaudeTheme.ps1          # Main installation script
├── Restore-OriginalTheme.ps1    # Revert to original settings
├── Switch-ClaudeMode.ps1        # Quick mode switcher
├── New-ClaudeIcons.ps1          # Icon generator
│
├── Wallpapers/                  # Generated artistic wallpapers
│   ├── Claude-Waves-Dark-V3.png
│   ├── Claude-Waves-Light.png
│   └── Claude-Waves-OLED.png
│
├── Terminal/                    # Windows Terminal color schemes
│   ├── claude-dark.json
│   ├── claude-light.json
│   └── claude-oled.json
│
├── Icons/Custom/                # Custom minimalist icons
├── Cursors/                     # Custom cursors
├── Themes/                      # Exportable .theme files
├── PowerShell/                  # PS profile configurations
└── Backups/                     # System backups (auto-generated)
```

## Optional Enhancements

For the full "Claude OS" experience, install:

- **[Inter Font](https://fonts.google.com/specimen/Inter)** - Already included in installation

## Requirements

- Windows 11 22H2 or later
- PowerShell 5.1 or later
- Administrator privileges
- .NET Framework 4.7.2+ (for wallpaper generation)

## Credits

- Color palette inspired by [Claude AI](https://claude.ai) by Anthropic
- Official brand colors: Pampas, Cloudy, Crail
- Created with Claude Code

## License

MIT License - Feel free to use and modify.

---

*Made with Claude Code*
