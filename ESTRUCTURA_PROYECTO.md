# ESTRUCTURA DEL PROYECTO - App Móvil Paseo del Comercio

## 📱 INFORMACIÓN GENERAL

**Nombre:** Paseo del Comercio - Aplicación Móvil  
**Plataforma:** Flutter (iOS & Android)  
**Arquitectura:** Clean Architecture  
**Estado:** Fase 1 completada (85%)  
**Próximo Hito:** MVP funcional en 7 días

---

## 🏗️ ARQUITECTURA TÉCNICA

### Clean Architecture - 4 Capas

#### 1. **Capa Core** - Funcionalidades Centrales
```
lib/core/
├── app/                    # Configuración global
│   └── app_config.dart    # Variables de entorno
├── constants/             # Constantes reutilizables
│   └── app_constants.dart
├── errors/                # Manejo de errores
│   └── app_exceptions.dart
└── utils/                 # Servicios compartidos
    ├── app_utils.dart     # Utilidades generales
    ├── cache_service.dart # Caché local con Hive
    ├── connectivity_service.dart # Monitoreo de red
    ├── image_service.dart # Multi-CDN (R2 → S3 → Supabase)
    ├── auth_service.dart  # Autenticación Clerk + Supabase
    ├── auth_state.dart    # Estados de autenticación
    ├── image_info.dart    # Información de imágenes
    └── result.dart        # Patrón Result para operaciones
```

#### 2. **Capa Domain** - Lógica de Negocio
```
lib/domain/
├── entities/              # 19 Entidades del dominio
│   ├── usuario.dart      # Usuarios del sistema
│   ├── tienda.dart       # Tiendas del centro comercial
│   ├── producto.dart     # Productos de las tiendas
│   ├── plazoleta.dart    # Ubicaciones/zonas
│   ├── organizacion.dart # Grupos/colectivos
│   ├── categoria.dart    # Categorías de productos
│   ├── horario.dart      # Horarios de atención
│   ├── valoracion_producto.dart # Reseñas
│   ├── etiqueta_tienda.dart     # Etiquetas tiendas
│   ├── etiqueta_producto.dart   # Etiquetas productos
│   ├── imagen_base.dart         # Base para imágenes
│   ├── imagen_tienda.dart       # Imágenes tiendas
│   ├── imagen_producto.dart     # Imágenes productos
│   ├── imagen_plazoleta.dart    # Imágenes plazoletas
│   ├── imagen_organizacion.dart # Imágenes organizaciones
│   ├── interaccion.dart         # Interacciones usuarios
│   ├── estadisticas_diarias.dart # Estadísticas
│   ├── miembros_organizacion.dart # Miembros
│   └── notificacion.dart        # Notificaciones
├── repositories/          # Interfaces abstractas
│   ├── tienda_repository_interface.dart
│   ├── producto_repository_interface.dart
│   ├── auth_repository_interface.dart
│   ├── categoria_repository_interface.dart
│   └── imagen_repository_interface.dart
└── usecases/             # Casos de uso
    ├── get_tiendas_usecase.dart
    ├── get_tienda_by_id_usecase.dart
    ├── search_tiendas_usecase.dart
    ├── authenticate_user_usecase.dart
    ├── get_productos_usecase.dart
    └── get_producto_by_id_usecase.dart
```

#### 3. **Capa Data** - Implementación de Datos
```
lib/data/
├── datasources/          # Fuentes de datos
│   ├── remote/          # APIs externas
│   │   ├── supabase_client.dart # Cliente Supabase
│   │   └── s3_client.dart       # Cliente S3/R2
│   └── local/           # Almacenamiento local
│       └── local_database.dart # Hive cache
├── models/              # Modelos de datos
│   └── response/       # Modelos para APIs
└── repositories/       # Implementaciones concretas
    ├── auth_repository.dart
    ├── tienda_repository.dart
    ├── producto_repository.dart
    ├── categoria_repository.dart
    └── imagen_repository.dart
```

#### 4. **Capa Presentation** - Interfaz de Usuario
```
lib/presentation/
├── blocs/              # Gestión de estado (BLoC)
│   ├── auth/          # Autenticación
│   │   ├── auth_bloc.dart
│   │   ├── auth_event.dart
│   │   └── auth_state.dart
│   ├── tienda/        # Gestión de tiendas
│   │   ├── tienda_bloc.dart
│   │   ├── tienda_event.dart
│   │   └── tienda_state.dart
│   ├── producto/      # Gestión de productos
│   │   ├── producto_bloc.dart
│   │   ├── producto_event.dart
│   │   └── producto_state.dart
│   └── image/         # Gestión de imágenes
│       ├── image_bloc.dart
│       ├── image_event.dart
│       └── image_state.dart
├── pages/             # Pantallas de la aplicación
│   ├── auth/         # Autenticación
│   │   └── login_page.dart
│   ├── profile/      # Perfil
│   │   └── profile_page.dart
│   ├── tiendas/      # Tiendas
│   │   └── tienda_list_page.dart
│   └── productos/    # Productos
│       └── producto_list_page.dart
└── widgets/          # Widgets reutilizables
    ├── common/       # Widgets comunes
    │   ├── loading_state.dart
    │   ├── error_state.dart
    │   └── empty_state.dart
    ├── tienda/       # Widgets de tiendas
    │   └── tienda_card.dart
    ├── producto/     # Widgets de productos
    │   └── producto_card.dart
    └── images/       # Widgets de imágenes
        └── resilient_image.dart
```

#### 5. **Dependency Injection**
```
lib/di/
└── service_locator.dart # Configuración GetIt
```

---

## 🔧 SERVICIOS CORE IMPLEMENTADOS

### 1. **CacheService** (Hive)
- Caché local con Time-To-Live (TTL)
- Estadísticas de uso y limpieza automática
- Categorías para organización de datos
- Soporte offline-first

### 2. **ConnectivityService**
- Monitoreo en tiempo real de estado de red
- Detección de tipo de conexión (WiFi, móvil, etc.)
- Reconexión automática
- Helpers para operaciones offline

### 3. **ImageService** (Multi-CDN)
- **Cloudflare R2** (Primario - migración en progreso)
- **Contabo S3** (Fallback 1 - existente actualmente)
- **Supabase Storage** (Fallback 2 - para imágenes pequeñas)
- Generación automática de variantes (150px, 500px, 1200px)
- Fallback automático entre proveedores

### 4. **AuthService** (Clerk + Supabase)
- Autenticación con Clerk (social logins)
- Sincronización con tabla `usuario` en Supabase
- Modo invitado con funcionalidad limitada
- Gestión de tokens y sesiones

### 5. **AppConfig**
- Gestión centralizada de variables de entorno
- Diferentes configuraciones por entorno (dev, staging, prod)
- Validación de configuraciones requeridas

---

## 🎮 BLOCS IMPLEMENTADOS

### **AuthBloc** - Gestión de Autenticación
- **15+ eventos:** Login, Logout, GuestLogin, CheckAuth, etc.
- **20+ estados:** Initial, Loading, Success, Error, Guest, etc.
- Integración completa con Clerk y Supabase
- Manejo de errores robusto

### **TiendaBloc** - Gestión de Tiendas
- **30+ eventos:** LoadTiendas, SearchTiendas, LoadById, LoadMore, etc.
- **25+ estados:** Initial, Loading, Loaded, Error, Empty, etc.
- Paginación infinita implementada
- Búsqueda en tiempo real con debounce

### **ProductoBloc** - Gestión de Productos
- **40+ eventos:** LoadProductos, SearchProductos, FilterByCategory, etc.
- **30+ estados:** Initial, Loading, Loaded, Error, etc.
- Filtros por categoría y tienda
- Manejo de stock y disponibilidad

### **ImageBloc** - Gestión de Imágenes
- Fallback automático entre CDNs
- Cache local con TTL configurable
- Estadísticas de uso de proveedores
- Retry automático en fallos

---

## 📱 PANTALLAS IMPLEMENTADAS

### 1. **LoginPage** (`presentation/pages/auth/login_page.dart`)
- Autenticación con Clerk
- Estados: SignedIn, SignedOut, Loading, Error
- UI profesional con tema oscuro
- Manejo de errores de autenticación

### 2. **ProfilePage** (`presentation/pages/profile/profile_page.dart`)
- Información del usuario Clerk
- Secciones: Información, Acciones, Configuración
- Modo invitado con opción de login
- Gestión de sesión

### 3. **TiendaListPage** (`presentation/pages/tiendas/tienda_list_page.dart`)
- Lista de tiendas con paginación infinita
- Búsqueda en tiempo real
- Filtros por categoría y ubicación
- Integración completa con TiendaBloc
- Pull-to-refresh para actualización

### 4. **ProductoListPage** (`presentation/pages/productos/producto_list_page.dart`)
- Lista de productos con filtros avanzados
- Búsqueda por nombre, categoría, tienda
- Indicadores de stock y disponibilidad
- Integración con ProductoBloc
- Navegación a detalle de producto

---

## 🎨 WIDGETS REUTILIZABLES

### **TiendaCard** (`presentation/widgets/tienda/tienda_card.dart`)
- Tarjeta profesional para tiendas
- Imagen principal con fallback
- Información: nombre, categoría, valoración
- Estados: abierta/cerrada, destacada
- Versión compacta y detallada

### **ProductoCard** (`presentation/widgets/producto/producto_card.dart`)
- Tarjeta profesional para productos
- Imagen con indicador de descuento
- Información: nombre, precio, stock
- Botones: favorito, añadir al carrito
- Indicadores de valoración y ventas

### **ResilientImage** (`presentation/widgets/images/resilient_image.dart`)
- Imagen con fallback multi-CDN (R2 → S3 → Supabase)
- Cache local con TTL configurable
- Optimización automática según tamaño de pantalla
- Placeholder y error widget personalizables
- Variantes: `ResilientCircleImage`, `ResilientRoundedImage`

### **Widgets Comunes**
- **LoadingState:** Indicadores de carga estandarizados
- **ErrorState:** Manejo de errores con reintento
- **EmptyState:** Estados vacíos con acciones

---

## 🔗 INTEGRACIÓN CON BACKEND

### **Supabase** - Base de Datos Principal
- **19 tablas** accesibles a través del cliente
- **Cliente configurado:** `supabase_client.dart`
- **Data mappers:** Conversión JSON ↔ Entidades
- **Paginación:** Soporte para listas grandes
- **Real-time:** Suscripciones en tiempo real
- **Offline-first:** Cache local con sincronización

### **Cloudflare R2** - Almacenamiento de Imágenes
- **Estrategia de migración gradual:**
  1. Fase Actual: Supabase Storage como primario
  2. Fase 1: R2 como fallback (✅ COMPLETADO)
  3. Fase 2: Migrar imágenes nuevas a R2
  4. Fase 3: Migrar imágenes existentes gradualmente
  5. Fase 4: R2 como primario, Supabase como fallback
- **Configuración completa:** Variables de entorno definidas
- **Servicio implementado:** ImageService con soporte multi-CDN
- **Guía detallada:** Instrucciones paso a paso para obtener credenciales
- **CORS configurable:** Para acceso desde app móvil

### **Clerk** - Autenticación
- SDK Flutter integrado (versión beta)
- **Social logins:** Configurados en dashboard.clerk.com (Google, Facebook, etc.)
- **Temas:** Configurados en dashboard.clerk.com (light/dark mode)
- **Configuración simplificada:** Solo necesita `CLERK_PUBLISHABLE_KEY`
- Sincronización automática con Supabase
- Modo invitado implementado
- Localización en español completa

---

## 🗺️ NAVEGACIÓN

### **GoRouter** Configurado
- **15+ rutas** nombradas con parámetros
- **AuthGuard:** Middleware para rutas protegidas
- **Deep linking:** Soporte para enlaces profundos
- **Transiciones:** Animaciones entre pantallas
- **Error handling:** Página de error personalizada

### **Rutas Principales:**
- `/` - Página de inicio (condicional según autenticación)
- `/login` - Autenticación con Clerk
- `/profile` - Perfil de usuario
- `/tiendas` - Lista de tiendas
- `/tiendas/:id` - Detalle de tienda
- `/productos` - Lista de productos
- `/productos/:id` - Detalle de producto
- `/search` - Búsqueda global
- `/favorites` - Favoritos
- `/cart` - Carrito de compras

---

## 📦 DEPENDENCY INJECTION

### **GetIt** Configurado
- **Service Locator:** `service_locator.dart`
- **Singleton registration:** Todos los servicios registrados
- **Lazy initialization:** Inicialización bajo demanda
- **Ready-check:** Verificación de inicialización completa
- **Dependency graph:** Gestión de dependencias cíclicas

### **Servicios Registrados:**
- CacheService, ConnectivityService, ImageService, AuthService
- SupabaseClientService, S3ImageService (si configurado)
- Todos los repositorios y casos de uso
- Todos los BLoCs (AuthBloc, TiendaBloc, ProductoBloc, ImageBloc)

---

## 🔐 ESTRATEGIA DE SEGURIDAD

### **Autenticación Híbrida:**
1. **Primario:** Clerk con social logins
2. **Fallback 1:** Email/password con Supabase Auth
3. **Fallback 2:** Modo invitado (solo lectura)
4. **Sincronización:** Usuarios Clerk → tabla `usuario` en Supabase

### **Manejo de Tokens:**
- Tokens JWT validados en cada request
- Refresh automático de tokens expirados
- Almacenamiento seguro en dispositivo
- Revocación de sesiones

### **Políticas de Acceso:**
- Usuarios autenticados: lectura/escritura limitada
- Usuarios invitados: solo lectura pública
- Dueños de tiendas: gestión de sus tiendas
- Administradores: acceso completo

---

## 💾 ESTRATEGIA OFFLINE-FIRST

### **Niveles de Caché:**
1. **Memoria:** CacheService con Hive (TTL configurable)
2. **Disco:** Imágenes y datos persistentes
3. **Red:** Datos frescos del servidor (prioridad baja)

### **Estados de Conexión:**
- `connected`: Conexión activa, datos frescos
- `disconnected`: Sin conexión, usar caché local
- `checking`: Verificando conectividad
- `limited`: Conexión limitada (solo datos esenciales)

### **Sincronización:**
- Cache-first strategy
- Background sync cuando hay conexión
- Resolución de conflictos (última modificación gana)
- Queue de operaciones pendientes

---

## 🚀 PRÓXIMOS PASOS TÉCNICOS

### **Inmediatos (7 días):**
1. Testing de integración con Supabase real
2. Configuración Cloudflare R2 bucket (credenciales)
3. Pantallas de detalle (TiendaDetailPage, ProductoDetailPage)
4. Testing de integración Clerk (social logins y temas)

### **Corto Plazo (2-4 semanas):**
1. Testing unitario (cobertura 70%)
2. CI/CD pipeline (GitHub Actions)
3. Optimización de performance
4. Analytics básico

### **Mediano Plazo (1-2 meses):**
1. Dark mode completo
2. Sistema de notificaciones push
3. Carrito de compras avanzado
4. Dashboard para emprendedores

---

## 🔧 VARIABLES DE ENTORNO REQUERIDAS

### **Nivel 1 - Críticas (obligatorias):**
```env
# Supabase
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
SUPABASE_SERVICE_ROLE_KEY=tu-clave-servicio

# Clerk
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
CLERK_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxx
```

### **Nivel 2 - Cloudflare R2 (para migración):**
```env
# Cloudflare R2 - Almacenamiento de imágenes
CLOUDFLARE_ACCOUNT_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
CLOUDFLARE_R2_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
CLOUDFLARE_R2_BUCKET_NAME=paseo-del-comercio-images
CLOUDFLARE_R2_PUBLIC_URL=https://pub-1234567890abcdef.r2.dev
```

### **Nivel 3 - Contabo S3 (fallback existente):**
```env
# Contabo S3 - Fallback existente
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_S3_BUCKET_NAME=paseo-del-comercio
AWS_REGION=us-east-1
S3_ENDPOINT_URL=https://eu2.contabostorage.com
S3_BASE_URL=https://eu2.contabostorage.com/paseo-del-comercio
CONTABO_TENANT_ID=12345678-1234-1234-1234-123456789012
CONTABO_BUCKET_FOLDER=images
```

### **Cómo Obtener Credenciales:**

#### 1. **Supabase:**
- Dashboard → Settings → API
- Copia `Project URL` como `SUPABASE_URL`
- Copia `anon public` como `SUPABASE_ANON_KEY`
- Copia `service_role` como `SUPABASE_SERVICE_ROLE_KEY`

#### 2. **Clerk:**
- Dashboard → API Keys
- Copia `Publishable Key` como `CLERK_PUBLISHABLE_KEY`
- Copia `Secret Key` como `CLERK_SECRET_KEY`

#### 3. **Cloudflare R2 - GUÍA DETALLADA:**

**Paso 1: Account ID**
- Ve a Cloudflare Dashboard
- Selecciona tu cuenta
- En la barra lateral derecha, busca "Account ID"
- Copia el ID (ej: `1234567890abcdef1234567890abcdef`)

**Paso 2: Crear API Token**
1. Ve a **R2 → Overview**
2. Haz clic en **"Manage R2 API Tokens"**
3. Haz clic en **"Create API Token"**
4. Configura:
   - **Token name:** `paseo-del-comercio-app`
   - **Permissions:** Selecciona tu bucket y da permisos de:
     - `Object Read` (para leer imágenes)
     - `Object Write` (para subir imágenes)
5. Haz clic en **"Create Token"**
6. **IMPORTANTE:** Copia inmediatamente:
   - **Access Key ID** → `CLOUDFLARE_R2_ACCESS_KEY_ID`
   - **Secret Access Key** → `CLOUDFLARE_R2_SECRET_ACCESS_KEY`
   - ⚠️ **No podrás ver el Secret Access Key nuevamente**

**Paso 3: Bucket Name**
- Ve a **R2 → Buckets**
- Selecciona tu bucket existente
- El nombre del bucket es `CLOUDFLARE_R2_BUCKET_NAME`

**Paso 4: Public URL**
1. En tu bucket, ve a **Settings**
2. Busca **"Public Access"** o **"Custom Domain"**
3. Si no tienes dominio personalizado, Cloudflare proporciona:
   - `https://pub-[ACCOUNT_ID].r2.dev`
   - Reemplaza `[ACCOUNT_ID]` con tu Account ID
4. Para habilitar acceso público:
   - Ve a **R2 → Buckets → [tu-bucket] → Settings**
   - Busca **"Public Access"** y habilítalo
   - Configura **CORS** si es necesario (para la app móvil)

**Ejemplo de CORS para desarrollo:**
```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"]
  }
]
```

#### 4. **Contabo S3 (si ya tienes configuración):**
- Customer Panel → Object Storage → Access Keys
- Crea nuevas credenciales o usa las existentes

## 📞 SOPORTE Y MANTENIMIENTO

### **Durante Desarrollo:**
- Revisar logs de debug en consola
- Monitorear uso de caché y memoria
- Verificar estados de conexión
- Probar modos offline y reconexión
- **Verificar CORS en Cloudflare R2** para acceso desde la app

### **Post-Lanzamiento:**
- Monitorear errores con Crashlytics/Firebase
- Analizar métricas de performance
- Revisar costos de Cloudflare R2
- Actualizar dependencias regularmente
- Configurar social logins en dashboard.clerk.com
- Ajustar temas en dashboard.clerk.com según feedback
- **Monitorear uso de R2:** Estadísticas en Cloudflare Dashboard

### **Solución de Problemas Comunes - Cloudflare R2:**

#### **"CORS Error" en la app:**
1. Ve a **R2 → Buckets → [tu-bucket] → Settings**
2. Configura CORS para permitir tu dominio/app
3. Ejemplo de configuración CORS:
```json
[
  {
    "AllowedOrigins": ["*"],
    "AllowedMethods": ["GET"],
    "AllowedHeaders": ["*"],
    "ExposeHeaders": ["ETag"]
  }
]
```

#### **"Access Denied" al cargar imágenes:**
1. Verifica que el bucket tenga **Public Access** habilitado
2. Verifica que las credenciales API Token sean correctas
3. Verifica permisos del token: necesita `Object Read`

#### **No se puede subir imágenes:**
1. Verifica permisos del token: necesita `Object Write`
2. Verifica que el bucket exista y esté activo
3. Verifica límites de tamaño de archivo (R2 tiene límites)

#### **URL pública no funciona:**
1. Verifica formato: `https://pub-[ACCOUNT_ID].r2.dev`
2. Verifica que el bucket tenga acceso público habilitado
3. Prueba acceder directamente desde navegador

### **Equipo Recomendado:**
- **1-2 Desarrolladores Flutter:** UI + BLoCs + Testing
- **1 Backend/DevOps:** Supabase + Cloudflare + CI/CD
- **1 QA/Testing:** Testing + documentación
- **1 Producto/Diseño:** UX/UI + feedback usuarios

---

## 🎯 MÉTRICAS DE ÉXITO

### **Técnicas:**
- ✅ Compila sin errores
- < 2s cold start
- < 500ms carga de imágenes
- < 150MB uso de memoria
- 0