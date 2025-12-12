================================================================================
                    CLAUDE ANTHROPIC THEME FOR WINDOWS 11
                              Version 1.0.0
================================================================================

Este paquete personaliza Windows 11 con la estetica de Claude de Anthropic,
incluyendo el distintivo color terracota (#CC785C) y una experiencia visual
coherente en modo claro y oscuro.

================================================================================
                              CONTENIDO
================================================================================

Scripts principales:
  - Set-ClaudeTheme.ps1        : Instalador principal del tema
  - Restore-OriginalTheme.ps1  : Restaura la configuracion original
  - Switch-ClaudeMode.ps1      : Cambia rapidamente entre modo claro/oscuro
  - Set-ClaudeAutoSwitch.ps1   : Configura cambio automatico dia/noche

Carpetas:
  - Themes/        : Archivos .theme exportables para Windows
  - Wallpapers/    : Fondos de pantalla generados
  - Cursors/       : Cursores personalizados
  - Fonts/         : Fuente Inter (descargada automaticamente)
  - Icons/         : Pack de iconos (si se instala)
  - Terminal/      : Perfiles de color para Windows Terminal
  - PowerShell/    : Configuracion de colores para PowerShell
  - Tools/         : Herramientas adicionales (ExplorerPatcher)
  - Backups/       : Respaldos de configuracion original
  - Logs/          : Archivos de log de instalacion

================================================================================
                           INSTALACION RAPIDA
================================================================================

1. Abre PowerShell como ADMINISTRADOR

2. Navega a la carpeta del tema:
   cd C:\Users\betoe\ClaudeTheme

3. Ejecuta el instalador:
   .\Set-ClaudeTheme.ps1

4. Sigue las instrucciones en pantalla para elegir el modo (Dark/Light)

================================================================================
                            USO AVANZADO
================================================================================

APLICAR MODO ESPECIFICO:
  .\Set-ClaudeTheme.ps1 -Mode Dark
  .\Set-ClaudeTheme.ps1 -Mode Light

INSTALAR SOLO ALGUNOS COMPONENTES:
  .\Set-ClaudeTheme.ps1 -Mode Dark -Components Colors,Wallpaper,Cursors

OMITIR COMPONENTES ESPECIFICOS:
  .\Set-ClaudeTheme.ps1 -Mode Dark -SkipComponents ExplorerPatcher,Icons,Font

VER QUE HARIA SIN APLICAR (Preview):
  .\Set-ClaudeTheme.ps1 -Mode Dark -Preview

MODO OFFLINE (usar recursos locales):
  .\Set-ClaudeTheme.ps1 -Mode Dark -Offline

COMPONENTES DISPONIBLES:
  - Colors          : Color de acento del sistema
  - Theme           : Tema claro/oscuro
  - Taskbar         : Color y transparencia de la barra de tareas
  - Borders         : Colorizacion de bordes de ventanas
  - Cursors         : Cursores personalizados
  - Wallpaper       : Fondo de pantalla generado
  - LockScreen      : Pantalla de bloqueo
  - Font            : Fuente Inter
  - Icons           : Pack de iconos minimalista
  - ExplorerPatcher : Herramienta de personalizacion avanzada
  - Terminal        : Perfil de Windows Terminal
  - PowerShell      : Configuracion de colores de PS

================================================================================
                         CAMBIO RAPIDO DE MODO
================================================================================

Para alternar rapidamente entre modo claro y oscuro:

  .\Switch-ClaudeMode.ps1           # Alterna al modo opuesto
  .\Switch-ClaudeMode.ps1 -Mode Dark
  .\Switch-ClaudeMode.ps1 -Mode Light

================================================================================
                       CAMBIO AUTOMATICO DIA/NOCHE
================================================================================

Para configurar el cambio automatico:

1. Ejecuta como administrador:
   .\Set-ClaudeAutoSwitch.ps1 -DayTime "07:00" -NightTime "20:00"

2. Ver estado de las tareas:
   .\Set-ClaudeAutoSwitch.ps1 -Status

3. Eliminar tareas programadas:
   .\Set-ClaudeAutoSwitch.ps1 -Remove

================================================================================
                         RESTAURAR CONFIGURACION
================================================================================

Si deseas volver a la configuracion original:

1. Ejecuta como administrador:
   .\Restore-OriginalTheme.ps1

2. Selecciona el backup a restaurar (por defecto usa el mas reciente)

3. Confirma la restauracion

================================================================================
                        WINDOWS TERMINAL
================================================================================

Para usar el esquema de colores en Windows Terminal:

1. Abre Windows Terminal > Configuracion (Ctrl+,)
2. Haz clic en "Abrir archivo JSON" (esquina inferior izquierda)
3. Busca la seccion "schemes": []
4. Copia el contenido de Terminal/claude-dark.json o claude-light.json
5. Pegalo dentro del array "schemes"
6. Guarda el archivo
7. En Configuracion > Perfiles > Predeterminado > Apariencia
8. Selecciona "Claude Dark" o "Claude Light" en Esquema de colores

================================================================================
                           POWERSHELL
================================================================================

Para activar los colores de Claude en PowerShell:

1. Abre tu perfil de PowerShell:
   notepad $PROFILE

2. Agrega esta linea al final:
   . "C:\Users\betoe\ClaudeTheme\PowerShell\Claude-Profile.ps1"

3. Guarda y reinicia PowerShell

================================================================================
                         SOLUCCION DE PROBLEMAS
================================================================================

P: Los cambios no se aplican inmediatamente
R: Reinicia explorer.exe o cierra sesion y vuelve a entrar

P: Los cursores no cambian
R: Ve a Configuracion > Personalizacion > Temas > Cursor del mouse
   y selecciona el esquema "Claude Theme"

P: El wallpaper no se muestra
R: Verifica que existe en Wallpapers/ y aplica manualmente desde
   Configuracion > Personalizacion > Fondo

P: Error de permisos
R: Asegurate de ejecutar PowerShell como administrador

P: ExplorerPatcher causa problemas
R: Desinstala desde Programas y caracteristicas, o ejecuta:
   .\Set-ClaudeTheme.ps1 -Mode Dark -SkipComponents ExplorerPatcher

================================================================================
                            PALETA DE COLORES
================================================================================

MODO OSCURO:
  Acento primario    : #CC785C (Terracota)
  Acento secundario  : #D4A574 (Beige calido)
  Fondo              : #1C1C1C (Gris oscuro)
  Fondo elevado      : #2D2D2D (Gris medio)
  Bordes             : #3D3D3D (Gris sutil)
  Texto primario     : #EFEFEF (Blanco suave)
  Texto secundario   : #A0A0A0 (Gris)

MODO CLARO:
  Acento primario    : #CC785C (Terracota)
  Acento secundario  : #E8A88C (Terracota suave)
  Fondo              : #FFFFFF (Blanco)
  Fondo elevado      : #F4F4F4 (Gris muy claro)
  Bordes             : #E5E5E5 (Gris claro)
  Texto primario     : #1A1A1A (Negro suave)
  Texto secundario   : #6B6B6B (Gris)

================================================================================
                             CREDITOS
================================================================================

Creado con Claude Code Assistant
Inspirado en la UI de Claude de Anthropic (https://claude.ai)

Fuente Inter por Rasmus Andersson (https://rsms.me/inter/)

================================================================================
                             LICENCIA
================================================================================

Este tema es de uso personal y educativo.
Los colores y estetica estan inspirados en Claude de Anthropic.
La fuente Inter tiene licencia SIL Open Font License.

================================================================================
