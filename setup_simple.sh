#!/bin/bash

echo '🚀 Configuración simple para Paseo del Comercio'

# Verificar que .env existe
if [ ! -f .env ]; then
    echo '📝 Creando archivo .env desde ejemplo...'
    cp .env.example .env
    echo '⚠️  Por favor edita el archivo .env con tus credenciales'
fi

# Instalar dependencias
echo '📦 Instalando dependencias...'
flutter pub get

echo ''
echo '✅ Configuración completada!'
echo ''
echo '📋 Próximos pasos:'
echo '1. Edita el archivo .env con tus credenciales de Supabase'
echo '2. Ejecuta: flutter run lib/main_simple.dart'
echo '3. Para probar la conexión con Supabase'
echo ''
echo '🔧 Comandos útiles:'
echo '   flutter run lib/main_simple.dart'
echo '   flutter analyze'
echo '   flutter pub get'
