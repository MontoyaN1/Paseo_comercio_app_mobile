#!/bin/bash

# Script simple para configurar íconos web para Paseo del Comercio

echo "Configurando íconos web..."

# Directorios
PROJECT_DIR="$(pwd)"
ICON_SOURCE="$PROJECT_DIR/assets/icons/favicon.jpeg"
WEB_DIR="$PROJECT_DIR/web"
ICONS_DIR="$WEB_DIR/icons"

# Verificar si el ícono fuente existe
if [ ! -f "$ICON_SOURCE" ]; then
    echo "Error: No se encontró el ícono fuente: $ICON_SOURCE"
    exit 1
fi

# Crear directorio de íconos
mkdir -p "$ICONS_DIR"

# Copiar el ícono fuente como favicon principal
echo "Copiando favicon principal..."
cp "$ICON_SOURCE" "$WEB_DIR/favicon.jpeg"

# Crear algunos íconos básicos usando convert si está disponible
if command -v convert &> /dev/null; then
    echo "Generando íconos básicos con ImageMagick..."

    # Tamaños básicos para web
    convert "$ICON_SOURCE" -resize 192x192 "$ICONS_DIR/Icon-192.png"
    convert "$ICON_SOURCE" -resize 512x512 "$ICONS_DIR/Icon-512.png"
    convert "$ICON_SOURCE" -resize 32x32 "$ICONS_DIR/favicon-32x32.png"
    convert "$ICON_SOURCE" -resize 16x16 "$ICONS_DIR/favicon-16x16.png"
    convert "$ICON_SOURCE" -resize 180x180 "$ICONS_DIR/apple-touch-icon.png"

    # Crear favicon.ico
    convert "$ICON_SOURCE" -resize 16x16 "$ICONS_DIR/favicon-16.png"
    convert "$ICON_SOURCE" -resize 32x32 "$ICONS_DIR/favicon-32.png"
    convert "$ICON_SOURCE" -resize 48x48 "$ICONS_DIR/favicon-48.png"
    convert "$ICONS_DIR/favicon-16.png" "$ICONS_DIR/favicon-32.png" "$ICONS_DIR/favicon-48.png" "$ICONS_DIR/favicon.ico"
    rm -f "$ICONS_DIR/favicon-16.png" "$ICONS_DIR/favicon-32.png" "$ICONS_DIR/favicon-48.png"

    echo "Íconos generados exitosamente."
else
    echo "ImageMagick no está instalado. Copiando ícono básico..."
    cp "$ICON_SOURCE" "$ICONS_DIR/Icon-192.png"
    cp "$ICON_SOURCE" "$ICONS_DIR/Icon-512.png"
    echo "Nota: Para mejores resultados, instala ImageMagick:"
    echo "  Ubuntu/Debian: sudo apt-get install imagemagick"
    echo "  macOS: brew install imagemagick"
fi

# Actualizar manifest.json
echo "Actualizando manifest.json..."
cat > "$WEB_DIR/manifest.json" << EOF
{
    "name": "Paseo del Comercio",
    "short_name": "PaseoComercio",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#000000",
    "theme_color": "#D4AF37",
    "description": "Centro Comercial Virtual Paseo del Comercio",
    "orientation": "portrait-primary",
    "prefer_related_applications": false,
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ]
}
EOF

echo "¡Configuración completada!"
echo "Íconos creados en: $ICONS_DIR"
ls -la "$ICONS_DIR"
