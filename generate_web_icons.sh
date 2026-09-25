#!/bin/bash

# Script para generar íconos web para Paseo del Comercio
# Este script crea íconos en diferentes tamaños a partir del favicon original

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ICON_SOURCE="$PROJECT_DIR/assets/icons/favicon.jpeg"
WEB_DIR="$PROJECT_DIR/web"
ICONS_DIR="$WEB_DIR/icons"

# Verificar si ImageMagick está instalado
if ! command -v convert &> /dev/null; then
    echo -e "${RED}Error: ImageMagick no está instalado.${NC}"
    echo "Instala ImageMagick con:"
    echo "  Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "  macOS: brew install imagemagick"
    echo "  Windows: Descarga desde https://imagemagick.org/"
    exit 1
fi

# Verificar si el ícono fuente existe
if [ ! -f "$ICON_SOURCE" ]; then
    echo -e "${RED}Error: No se encontró el ícono fuente: $ICON_SOURCE${NC}"
    exit 1
fi

# Crear directorio de íconos si no existe
mkdir -p "$ICONS_DIR"

echo -e "${GREEN}Generando íconos web para Paseo del Comercio...${NC}"
echo "Directorio de íconos: $ICONS_DIR"

# Tamaños de íconos necesarios para web
declare -A icon_sizes=(
    ["Icon-16.png"]="16"
    ["Icon-32.png"]="32"
    ["Icon-72.png"]="72"
    ["Icon-96.png"]="96"
    ["Icon-128.png"]="128"
    ["Icon-144.png"]="144"
    ["Icon-152.png"]="152"
    ["Icon-192.png"]="192"
    ["Icon-384.png"]="384"
    ["Icon-512.png"]="512"
    ["apple-touch-icon.png"]="180"
    ["apple-touch-icon-57x57.png"]="57"
    ["apple-touch-icon-60x60.png"]="60"
    ["apple-touch-icon-72x72.png"]="72"
    ["apple-touch-icon-76x76.png"]="76"
    ["apple-touch-icon-114x114.png"]="114"
    ["apple-touch-icon-120x120.png"]="120"
    ["apple-touch-icon-144x144.png"]="144"
    ["apple-touch-icon-152x152.png"]="152"
    ["apple-touch-icon-180x180.png"]="180"
    ["favicon-16x16.png"]="16"
    ["favicon-32x32.png"]="32"
    ["favicon.ico"]="64"
    ["mstile-70x70.png"]="70"
    ["mstile-144x144.png"]="144"
    ["mstile-150x150.png"]="150"
    ["mstile-310x150.png"]="310x150"
    ["mstile-310x310.png"]="310"
)

# Generar cada ícono
for icon_name in "${!icon_sizes[@]}"; do
    size="${icon_sizes[$icon_name]}"
    output_path="$ICONS_DIR/$icon_name"

    echo -e "${YELLOW}Generando: $icon_name (${size})${NC}"

    if [[ "$size" == *"x"* ]]; then
        # Tamaño con dimensiones específicas (ancho x alto)
        convert "$ICON_SOURCE" -resize "${size}!" -background none -gravity center -extent "${size}" "$output_path"
    else
        # Tamaño cuadrado
        convert "$ICON_SOURCE" -resize "${size}x${size}" -background none -gravity center -extent "${size}x${size}" "$output_path"
    fi

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓ Creado: $icon_name${NC}"
    else
        echo -e "  ${RED}✗ Error creando: $icon_name${NC}"
    fi
done

# Crear favicon.ico especial (formato ICO con múltiples tamaños)
echo -e "${YELLOW}Creando favicon.ico (con múltiples resoluciones)...${NC}"
convert "$ICON_SOURCE" -resize 16x16 "$ICONS_DIR/favicon-16.png"
convert "$ICON_SOURCE" -resize 32x32 "$ICONS_DIR/favicon-32.png"
convert "$ICON_SOURCE" -resize 48x48 "$ICONS_DIR/favicon-48.png"
convert "$ICONS_DIR/favicon-16.png" "$ICONS_DIR/favicon-32.png" "$ICONS_DIR/favicon-48.png" "$ICONS_DIR/favicon.ico"
rm -f "$ICONS_DIR/favicon-16.png" "$ICONS_DIR/favicon-32.png" "$ICONS_DIR/favicon-48.png"

# Copiar favicon principal
cp "$ICON_SOURCE" "$WEB_DIR/favicon.jpeg"
convert "$ICON_SOURCE" "$WEB_DIR/favicon.png"

# Crear archivo site.webmanifest actualizado
cat > "$WEB_DIR/site.webmanifest" << EOF
{
    "name": "Paseo del Comercio",
    "short_name": "PaseoComercio",
    "description": "Centro Comercial Virtual Paseo del Comercio",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#000000",
    "theme_color": "#D4AF37",
    "orientation": "portrait-primary",
    "icons": [
        {
            "src": "icons/Icon-72.png",
            "sizes": "72x72",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-96.png",
            "sizes": "96x96",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-128.png",
            "sizes": "128x128",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-144.png",
            "sizes": "144x144",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-152.png",
            "sizes": "152x152",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any"
        },
        {
            "src": "icons/Icon-384.png",
            "sizes": "384x384",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any"
        },
        {
            "src": "icons/Icon-maskable-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "maskable"
        },
        {
            "src": "icons/Icon-maskable-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "maskable"
        }
    ]
}
EOF

# Actualizar index.html con los nuevos íconos
if [ -f "$WEB_DIR/index.html" ]; then
    # Crear backup
    cp "$WEB_DIR/index.html" "$WEB_DIR/index.html.backup"

    # Actualizar las referencias a íconos
    sed -i 's|"icons/Icon-192.png"|"icons/Icon-192.png"|g' "$WEB_DIR/index.html"
    sed -i 's|"icons/Icon-512.png"|"icons/Icon-512.png"|g' "$WEB_DIR/index.html"

    # Agregar meta tags para íconos si no existen
    if ! grep -q "apple-touch-icon" "$WEB_DIR/index.html"; then
        sed -i '/<head>/a \    <link rel="apple-touch-icon" sizes="180x180" href="icons/apple-touch-icon.png">' "$WEB_DIR/index.html"
        sed -i '/<head>/a \    <link rel="icon" type="image/png" sizes="32x32" href="icons/favicon-32x32.png">' "$WEB_DIR/index.html"
        sed -i '/<head>/a \    <link rel="icon" type="image/png" sizes="16x16" href="icons/favicon-16x16.png">' "$WEB_DIR/index.html"
        sed -i '/<head>/a \    <link rel="manifest" href="site.webmanifest">' "$WEB_DIR/index.html"
        sed -i '/<head>/a \    <meta name="msapplication-TileColor" content="#D4AF37">' "$WEB_DIR/index.html"
        sed -i '/<head>/a \    <meta name="theme-color" content="#D4AF37">' "$WEB_DIR/index.html"
    fi
fi

echo -e "${GREEN}¡Íconos web generados exitosamente!${NC}"
echo -e "Total de íconos creados: $(ls -1 "$ICONS_DIR" | wc -l)"
echo -e "Directorio: $ICONS_DIR"

# Verificar los archivos creados
echo -e "\n${YELLOW}Archivos creados:${NC}"
ls -la "$ICONS_DIR" | head -20

echo -e "\n${GREEN}Proceso completado.${NC}"
