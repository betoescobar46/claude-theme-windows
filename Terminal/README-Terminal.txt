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
