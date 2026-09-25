#!/bin/bash

# Script de configuración inicial para Paseo del Comercio App
# Este script ayuda a configurar el entorno de desarrollo

set -e  # Detener script en caso de error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que estamos en el directorio correcto
check_directory() {
    if [ ! -f "pubspec.yaml" ]; then
        print_error "No se encontró pubspec.yaml. Ejecuta este script desde el directorio raíz del proyecto."
        exit 1
    fi
    print_success "Directorio verificado correctamente"
}

# Verificar dependencias
check_dependencies() {
    print_info "Verificando dependencias..."

    # Verificar Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter no está instalado. Por favor instala Flutter primero."
        exit 1
    fi

    # Verificar Dart
    if ! command -v dart &> /dev/null; then
        print_error "Dart no está instalado."
        exit 1
    fi

    print_success "Dependencias verificadas"
}

# Instalar paquetes Flutter
install_packages() {
    print_info "Instalando paquetes Flutter..."
    flutter pub get
    if [ $? -eq 0 ]; then
        print_success "Paquetes instalados correctamente"
    else
        print_error "Error instalando paquetes"
        exit 1
    fi
}

# Configurar variables de entorno
setup_env() {
    print_info "Configurando variables de entorno..."

    if [ ! -f ".env.example" ]; then
        print_error "No se encontró .env.example"
        exit 1
    fi

    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_warning "Archivo .env creado. Por favor edita .env con tus credenciales."
    else
        print_info "Archivo .env ya existe"
    fi

    # Crear directorio de assets si no existe
    mkdir -p assets/images
    mkdir -p assets/icons
    mkdir -p assets/fonts

    print_success "Variables de entorno configuradas"
}

# Generar código con build_runner
generate_code() {
    print_info "Generando código con build_runner..."

    # Verificar si hay modelos para generar
    if [ -d "lib/data/models/domain" ]; then
        print_info "Generando adaptadores Hive..."
        flutter pub run build_runner build --delete-conflicting-outputs

        if [ $? -eq 0 ]; then
            print_success "Código generado correctamente"
        else
            print_warning "Puede que no haya modelos para generar aún"
        fi
    else
        print_warning "No se encontraron modelos para generar"
    fi
}

# Configurar Git hooks (opcional)
setup_git_hooks() {
    print_info "Configurando Git hooks..."

    if [ -d ".git" ]; then
        # Crear directorio de hooks si no existe
        mkdir -p .git/hooks

        # Crear pre-commit hook para formatear código
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Formateando código Dart..."
flutter format .
EOF

        chmod +x .git/hooks/pre-commit
        print_success "Git hooks configurados"
    else
        print_warning "No es un repositorio Git, omitiendo hooks"
    fi
}

# Verificar estructura del proyecto
check_project_structure() {
    print_info "Verificando estructura del proyecto..."

    # Directorios requeridos
    required_dirs=(
        "lib/core"
        "lib/data"
        "lib/domain"
        "lib/presentation"
        "lib/di"
    )

    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            print_warning "Directorio faltante: $dir"
            mkdir -p "$dir"
            print_info "Creado: $dir"
        fi
    done

    print_success "Estructura verificada"
}

# Mostrar resumen
show_summary() {
    echo ""
    echo "========================================="
    echo "         CONFIGURACIÓN COMPLETADA        "
    echo "========================================="
    echo ""
    echo "✅ Dependencias verificadas"
    echo "✅ Paquetes instalados"
    echo "✅ Variables de entorno configuradas"
    echo "✅ Estructura del proyecto verificada"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Edita el archivo .env con tus credenciales:"
    echo "   - SUPABASE_URL y SUPABASE_ANON_KEY"
    echo "   - CLERK_PUBLISHABLE_KEY"
    echo "   - Credenciales de Contabo S3"
    echo ""
    echo "2. Ejecuta la aplicación:"
    echo "   flutter run"
    echo ""
    echo "3. Para desarrollo con hot reload:"
    echo "   flutter pub run build_runner watch"
    echo ""
    echo "4. Para generar modelos nuevos:"
    echo "   flutter pub run build_runner build --delete-conflicting-outputs"
    echo ""
    echo "🔧 Comandos útiles:"
    echo "   ./setup.sh          # Re-ejecutar configuración"
    echo "   flutter analyze     # Analizar código"
    echo "   flutter test        # Ejecutar tests"
    echo ""
    echo "📚 Documentación:"
    echo "   - Revisa ARQUITECTURA_CENTRO_COMERCIAL.md"
    echo "   - Revisa README.md"
    echo ""
    echo "========================================="
}

# Función principal
main() {
    echo ""
    echo "========================================="
    echo "  Configuración Paseo del Comercio App  "
    echo "========================================="
    echo ""

    check_directory
    check_dependencies
    install_packages
    setup_env
    check_project_structure
    generate_code
    setup_git_hooks
    show_summary
}

# Ejecutar función principal
main "$@"
