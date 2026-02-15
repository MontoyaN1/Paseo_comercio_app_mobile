# Paseo del Comercio - Aplicación Móvil

Aplicación Flutter para el Centro Comercial Virtual "Paseo del Comercio". Esta aplicación permite a los usuarios explorar tiendas, productos, plazoletas virtuales y realizar compras en un entorno de centro comercial digital.

## 🚀 Características Principales

- **Autenticación con Clerk**: Sistema de login/registro seguro
- **Backend con Supabase**: Base de datos PostgreSQL en la nube
- **Gestión de imágenes con Contabo S3**: Almacenamiento de imágenes optimizado
- **Caché local offline-first**: Funcionalidad sin conexión
- **Arquitectura limpia**: Separación de capas (data, domain, presentation)
- **Gestión de estado con BLoC**: Estado predecible y reactivo

## 🏗️ Arquitectura del Proyecto

```
lib/
├── core/                    # Configuración y utilidades
├── data/                   # Capa de datos
│   ├── datasources/       # Fuentes de datos (local/remote)
│   ├── models/           # Modelos de datos
│   └── repositories/     # Repositorios
├── domain/               # Lógica de negocio
├── presentation/         # UI y widgets
└── di/                  # Inyección de dependencias
```

## 📋 Prerrequisitos

- Flutter SDK >= 3.7.2
- Dart >= 3.0.0
- Cuenta en [Supabase](https://supabase.com)
- Cuenta en [Clerk](https://clerk.com)
- Cuenta en [Contabo Object Storage](https://contabo.com)

## 🔧 Configuración Inicial

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd paseo-del-comercio-app-mobile-flutter
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

1. Copiar el archivo de ejemplo:
```bash
cp .env.example .env
```

2. Editar el archivo `.env` con tus credenciales:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Clerk Authentication
CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Contabo Object Storage
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET_NAME=paseocomercio
AWS_REGION=usc1
S3_ENDPOINT_URL=https://usc1.contabostorage.com
S3_BASE_URL=https://usc1.contabostorage.com/paseocomercio
CONTABO_TENANT_ID=your-tenant-id
CONTABO_BUCKET_FOLDER=plazoletas

# App Configuration
APP_NAME=Paseo del Comercio
APP_VERSION=1.0.0
DEBUG_MODE=true
```

### 4. Generar código con build_runner

```bash
# Generar adaptadores Hive
flutter pub run build_runner build --delete-conflicting-outputs

# Para desarrollo con watch mode:
flutter pub run build_runner watch
```

## 🚀 Ejecutar la aplicación

### Desarrollo

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

### Build para producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📁 Estructura de la Base de Datos

La aplicación utiliza las siguientes tablas principales en Supabase:

### Tablas Principales
- `usuario` - Información de usuarios (sincronizado con Clerk)
- `tienda` - Tiendas del centro comercial
- `producto` - Productos de las tiendas
- `categoria` - Categorías de productos
- `plazoleta` - Plazoletas virtuales
- `imagen_tienda` - Imágenes de tiendas
- `imagen_productos` - Imágenes de productos
- `imagen_plazoleta` - Imágenes de plazoletas
- `valoracion_producto` - Valoraciones de productos
- `horario` - Horarios de atención de tiendas

### Enums Definidos
- `estado_producto` - publicado, agotado, eliminado, inactivo
- `estado_usuario` - activo, inactivo, bloqueado
- `tipo_imagen` - principal, galeria, detalle, zoom, logo, banner
- `tipo_horario` - normal, festivo, especial
- `tipo_organizacion` - fundacion, asociacion, cooperativa, empresa, comunidad

## 🔄 Sistema de Caché

La aplicación implementa una estrategia **cache-first**:

### Características:
- **TTL (Time To Live)**: Datos expiran después de tiempo configurable
- **LRU (Least Recently Used)**: Elimina datos menos usados cuando se excede límite
- **Prioridades**: Datos importantes se mantienen más tiempo
- **Offline-first**: Funciona sin conexión usando caché local

### Configuración de caché:
```dart
// En AppConfig
cacheTtlHours: 1        // 1 hora por defecto
maxCacheSizeMB: 100     // 100MB máximo
maxImageCacheItems: 500 // Máximo 500 imágenes
```

## 🛠️ Desarrollo

### Patrones Utilizados

1. **Repository Pattern**: Abstracción de fuentes de datos
2. **Dependency Injection**: Gestión de dependencias con GetIt
3. **BLoC Pattern**: Gestión de estado reactivo
4. **Clean Architecture**: Separación de responsabilidades

### Comandos útiles

```bash
# Analizar código
flutter analyze

# Formatear código
flutter format .

# Ejecutar tests
flutter test

# Generar reporte de cobertura
flutter test --coverage
```

### Generación de código

Los modelos usan Hive para persistencia local. Para generar los adaptadores:

```bash
# Una vez
flutter pub run build_runner build

# Modo watch (desarrollo)
flutter pub run build_runner watch
```

## 📱 Pantallas Principales

1. **Login/Registro**: Autenticación con Clerk
2. **Home**: Dashboard con tiendas destacadas
3. **Tiendas**: Listado y detalle de tiendas
4. **Productos**: Catálogo de productos
5. **Plazoletas**: Navegación por áreas temáticas
6. **Perfil**: Gestión de cuenta y preferencias

## 🔒 Seguridad

- **Clerk**: Autenticación y gestión de usuarios
- **Supabase RLS**: Row Level Security en base de datos
- **Variables de entorno**: Credenciales fuera del código
- **Caché segura**: Datos sensibles encriptados

## 📊 Monitoreo y Analytics

- **Logger**: Logs estructurados para debugging
- **Supabase Analytics**: Seguimiento de interacciones
- **Crashlytics**: Reporte de errores (configurable)

## 🤝 Contribuir

1. Fork el repositorio
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📄 Licencia

Este proyecto está bajo licencia MIT. Ver `LICENSE` para más detalles.

## 🆘 Soporte

Para soporte o preguntas:
- Crear un issue en GitHub
- Contactar al equipo de desarrollo
- Revisar documentación en `ARQUITECTURA_CENTRO_COMERCIAL.md`

## 📞 Contacto

Proyecto Paseo del Comercio - [contacto@paseodelcomercio.com](mailto:contacto@paseodelcomercio.com)

---

**Nota**: Esta aplicación está en desarrollo activo. Características y APIs pueden cambiar.