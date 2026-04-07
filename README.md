# Paseo del Comercio - Aplicación Móvil

Aplicación Flutter para el Centro Comercial Virtual "Paseo del Comercio". 
Arquitectura Clean Architecture con integración Supabase, Clerk y Cloudflare R2.

## 📋 DOCUMENTACIÓN ORGANIZADA


Toda la documentación está organizada en la carpeta `doc/`:

### 📁 **doc/ESQUEMA_BASE_DATOS.md** - **NUEVO**
- **Entidades:** 22 tablas documentadas con columnas y tipos
- **Relaciones:** 40+ relaciones entre tablas
- **Enums/Tipos:** 8 tipos personalizados (tipo_horario, tipo_imagen, etc.)
- **Índices y Triggers:** Optimizaciones para performance móvil
- **Consideraciones Flutter:** BLoCs recomendados, modelos, consultas optimizadas

### 📊 **doc/PROGRESO_Y_PLAN.md**
- Estado actual del proyecto (92% completado - Fase 1)
- Plan de implementación por fases (12 semanas)
- Lo completado y pendiente por hacer
- Próximos pasos inmediatos
- Métricas y verificaciones técnicas

### 🏗️ **doc/ESTRUCTURA_PROYECTO.md**
- Estructura completa de carpetas (Clean Architecture)
- Servicios core implementados (Cache, Connectivity, Image, Auth)
- BLoCs, pantallas y widgets disponibles
- Integración con backend (Supabase, Clerk, R2)
- Estrategias técnicas (offline-first, multi-CDN, seguridad)

### 🎨 **doc/PROPUESTAS_UI.md**
- Propuestas de diseño y experiencia de usuario
- Wireframes y flujos de navegación
- Componentes de interfaz recomendados

### 🤖 **doc/AGENTS.md**
- Configuración de agentes y automatizaciones
- Workflows de desarrollo
- Integraciones con herramientas externas

## 🎯 OBJETIVOS DE LA APP

### ✅ **OBJETIVOS PRINCIPALES:**
1. **Permitir login y crear cuenta** → Clerk configurado
2. **Ver todas las plazoletas** → Tabla `plazoleta` disponible
3. **Ver cada plazoleta** → Relaciones con imágenes definidas
4. **Ver las tiendas y productos** → Tablas `tienda` y `producto` con relaciones
5. **Ver las organizaciones** → Tabla `organizacion` con miembros e imágenes
6. **Ver cada organización** → Relaciones completas definidas

### 🔄 **SINCRONIZACIÓN CON APP WEB:**
- **Misma base de datos** → Compatibilidad garantizada
- **Estrategia multi-CDN** → Imágenes compartidas (R2 → S3 → Supabase)
- **Autenticación unificada** → Clerk como SSO
- **Datos consistentes** → Triggers y constraints en DB

## 🚀 INICIO RÁPIDO

### 1. Clonar y configurar
```bash
git clone <repository-url>
cd paseo-del-comercio-app-mobile-flutter
# Consulta doc/ESTRUCTURA_PROYECTO.md para todas las variables requeridas
cp .env.example .env
# Editar .env con tus credenciales
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar credenciales (mínimo para funcionar):
```env
# Supabase (obligatorio)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
SUPABASE_SERVICE_ROLE_KEY=tu-clave-servicio

# Clerk (obligatorio)
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
```

### 4. Ejecutar aplicación
```bash
flutter run
```

## 📱 ESTADO ACTUAL

✅ **FASE 1 COMPLETADA (92%)** - Estructura base lista
- Clean Architecture implementada (4 capas)
- **19 entidades** del dominio definidas
- **4 BLoCs** completos (Auth, Tienda, Producto, Image)
- **Servicios core** funcionando (Cache, Connectivity, ImageService)
- **Conexión Supabase** verificada (22 tablas accesibles)
- **Autenticación Clerk** integrada (solo publishableKey necesaria)
- **Navegación GoRouter** configurada (15+ rutas)
- **Widgets reutilizables** creados (TiendaCard, ProductoCard, ResilientImage)

🎯 **PRÓXIMO MVP:** 7 días para app funcional con:
- Autenticación Clerk + modo invitado
- Lista de tiendas con imágenes (multi-CDN)
- Detalle de tienda básico
- Perfil de usuario completo
- Navegación fluida entre secciones

## 🏗️ ARQUITECTURA TÉCNICA

### Clean Architecture - 4 Capas
```
lib/
├── core/      # Configuración y servicios compartidos
├── domain/    # Lógica de negocio (19 entidades)
├── data/      # Implementación de datos (Supabase + Hive)
├── presentation/ # UI (BLoCs + Widgets + Pages)
└── di/        # Dependency Injection (GetIt)
```

### Tecnologías Principales
- **Flutter 3.7+** - Framework UI multiplataforma
- **Supabase** - Base de datos PostgreSQL + Realtime
- **Clerk** - Autenticación simplificada (social logins, temas en dashboard)
- **Cloudflare R2** - Almacenamiento de imágenes (migración multi-CDN)
- **Hive** - Caché local offline-first
- **BLoC** - Gestión de estado reactiva
- **GetIt** - Service Locator / Dependency Injection
- **GoRouter** - Navegación declarativa con deep linking

### Estrategia Multi-CDN para Imágenes
```dart
// Orden de fallback automático:
1. Cloudflare R2 (primary - mejor performance/costo)
2. Contabo S3 (fallback 1 - existente)
3. Supabase Storage (fallback 2 - garantizado)
4. Asset local (último recurso - placeholder)
```

## 📊 BASE DE DATOS - RESUMEN

### 📋 **22 Tablas Principales:**
1. `usuario` - Usuarios con autenticación Clerk
2. `tienda` - Tiendas del centro comercial
3. `producto` - Productos ofrecidos
4. `organizacion` - Organizaciones que agrupan tiendas
5. `plazoleta` - Ubicaciones físicas
6. `valoracion_producto` - Reseñas de productos
7. `interaccion` - Registro de interacciones
8. `estadisticas_diarias` - Estadísticas agregadas
9. `miembros_organizacion` - Miembros de organizaciones
10. `notificacion` - Sistema de notificaciones
11. `horario` - Horarios de tiendas
12. `etiqueta_tienda` / `etiqueta_producto` - Categorización
13. `imagen_tienda` / `imagen_productos` / `imagen_plazoleta` / `imagen_organizacion` - Imágenes
14. `contactos_empresa` / `redes_sociales` - Información de contacto
15. `roles` - Roles del sistema
16. `trigger_logs` - Logs para debugging

### 🔗 **8 Tipos Personalizados (Enums):**
- `tipo_horario`, `tipo_imagen`, `tipo_organizacion`, `tipo_ubicacion`
- `estado_producto`, `estado_usuario`, `estado_valoracion`, `tipo_rol`

**📖 Ver `doc/ESQUEMA_BASE_DATOS.md` para documentación completa**

## 🔧 CONFIGURACIÓN COMPLETA

### Variables obligatorias (mínimo):
```env
# Supabase
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
SUPABASE_SERVICE_ROLE_KEY=tu-clave-servicio

# Clerk (solo publishableKey necesaria)
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
```

### Cloudflare R2 (opcional - para migración multi-CDN):
```env
CLOUDFLARE_ACCOUNT_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_ACCESS_KEY_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_SECRET_ACCESS_KEY=abcdef1234567890abcdef1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_BUCKET_NAME=paseo-del-comercio-images
CLOUDFLARE_R2_PUBLIC_URL=https://pub-1234567890abcdef.r2.dev
```

**📋 Ver `doc/ESTRUCTURA_PROYECTO.md` para configuración completa con guías paso a paso**

## 📊 MÉTRICAS DE CALIDAD

- ✅ **Compila sin errores** - Verificado
- 🎯 **< 2s cold start** - Objetivo
- 🎯 **< 500ms carga imágenes** - Objetivo con multi-CDN
- 🎯 **0 crashes flujos principales** - Objetivo
- ✅ **Arquitectura testable** - Implementada (Clean Architecture)
- ✅ **Offline-first** - Cache con Hive + sincronización
- ✅ **Performance móvil** - Índices y consultas optimizadas

## 🚀 PRÓXIMOS PASOS

### 🔥 **Prioridad Alta (Esta semana):**
1. **Testing de integración** - Verificar conexión real con Supabase
2. **Pantallas de detalle** - TiendaDetailPage y ProductoDetailPage
3. **BLoCs faltantes** - OrganizacionBloc y PlazoletaBloc
4. **Testing R2** - Verificar carga de imágenes desde Cloudflare R2

### 📅 **Prioridad Media (Próxima semana):**
1. **Testing Unitario** - Coverage mínimo 70%
2. **Optimización Performance** - Bundle size y lazy loading
3. **CI/CD Pipeline** - GitHub Actions para builds automáticos
4. **Pantallas según objetivos** - PlazoletaListPage, OrganizacionDetailPage

### 🎨 **Prioridad Baja (Mes 2):**
1. **Temas Avanzados** - Dark mode completo
2. **Animaciones** - Transiciones y micro-interacciones
3. **Accessibilidad** - Soporte completo para screen readers
4. **Internacionalización** - Soporte multi-idioma

**📅 Ver `doc/PROGRESO_Y_PLAN.md` para plan completo de 12 semanas**

## 📞 SOPORTE Y CONTACTO

### Equipo Recomendado:
- **1-2 Desarrolladores Flutter** - UI + BLoCs + Testing
- **1 Backend/DevOps** - Supabase + Cloudflare + CI/CD
- **1 QA/Testing** - Testing + documentación
- **1 Producto/Diseño** - UX/UI + feedback usuarios

### Credenciales Requeridas:
1. **Supabase Dashboard** - `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`
2. **Clerk Dashboard** - `CLERK_PUBLISHABLE_KEY` (dashboard.clerk.com)
3. **Cloudflare R2** (opcional) - Para migración multi-CDN

### Documentación Completa:
- **📖 `doc/ESQUEMA_BASE_DATOS.md`** - Esquema completo de base de datos
- **📊 `doc/PROGRESO_Y_PLAN.md`** - Estado y planificación
- **🏗️ `doc/ESTRUCTURA_PROYECTO.md`** - Arquitectura y configuración
- **🎨 `doc/PROPUESTAS_UI.md`** - Diseño y experiencia
- **🤖 `doc/AGENTS.md`** - Automatizaciones y workflows

---

**📅 Última actualización:** Documentación reorganizada y esquema DB agregado  
**🎯 Estado:** ✅ **92% FASE 1 COMPLETADA** - LISTO PARA MVP  
**📁 Documentación:** Organizada en carpeta `doc/`  
**🗃️ Base de datos:** 22 tablas documentadas con relaciones  
**📱 Objetivos:** 6 objetivos principales definidos y alineados con DB  
**🔧 Configuración:** Clerk simplificado + Supabase + R2 multi-CDN
