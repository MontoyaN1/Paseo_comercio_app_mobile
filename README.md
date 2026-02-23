# Paseo del Comercio - Aplicación Móvil

Aplicación Flutter para el Centro Comercial Virtual "Paseo del Comercio". 
Arquitectura Clean Architecture con integración Supabase, Clerk y Cloudflare R2.

## 📋 DOCUMENTACIÓN CONSOLIDADA

Para evitar la confusión de múltiples archivos, toda la documentación está organizada en 2 archivos principales + 1 guía específica:

### 1. 📊 [PROGRESO_Y_PLAN.md](PROGRESO_Y_PLAN.md)
- Estado actual del proyecto (85% completado)
- Plan de implementación por fases (12 semanas)
- Lo completado y pendiente por hacer
- Próximos pasos inmediatos
- Métricas y verificaciones técnicas

### 2. 🏗️ [ESTRUCTURA_PROYECTO.md](ESTRUCTURA_PROYECTO.md)
- Estructura completa de carpetas (Clean Architecture)
- Servicios core implementados
- BLoCs, pantallas y widgets disponibles
- Integración con backend (Supabase, Clerk, R2)
- Estrategias técnicas (offline-first, multi-CDN, seguridad)

### 2. 🔧 **Variables de Entorno** - En [ESTRUCTURA_PROYECTO.md](ESTRUCTURA_PROYECTO.md)
- Variables de entorno completas para configuración
- Credenciales para Clerk, Supabase, Cloudflare R2
- Guías paso a paso para obtener credenciales
- Validación y buenas prácticas de seguridad

### 3. 📖 **Guía Cloudflare R2** - [GUIA_CLOUDFLARE_R2.md](GUIA_CLOUDFLARE_R2.md)
- Guía paso a paso específica para Cloudflare R2
- Cómo obtener Account ID, API Tokens, Bucket Name
- Configuración de CORS para app móvil
- Solución de problemas comunes

## 🚀 INICIO RÁPIDO

### 1. Clonar y configurar
```bash
git clone <repository-url>
cd paseo-del-comercio-app-mobile-flutter
# Consulta ESTRUCTURA_PROYECTO.md para todas las variables requeridas
# Para R2, sigue GUIA_CLOUDFLARE_R2.md paso a paso
cp .env.example .env
# Editar .env con tus credenciales (obligatorias: Supabase + Clerk)
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar Clerk (simplificado)
- Obtén `CLERK_PUBLISHABLE_KEY` desde dashboard.clerk.com
- Configura social logins y temas directamente en dashboard.clerk.com
- Clerk maneja todo internamente, solo necesitas la publishableKey

### 4. Configurar Cloudflare R2 (opcional - migración)
- **Sigue la guía:** [GUIA_CLOUDFLARE_R2.md](GUIA_CLOUDFLARE_R2.md)
- Paso a paso: Account ID → API Token → Bucket → CORS
- 5 variables necesarias para multi-CDN

### 5. Ejecutar aplicación
```bash
flutter run
```

## 📱 ESTADO ACTUAL

✅ **FASE 1 COMPLETADA (95%)** - Estructura base lista
- Clean Architecture implementada
- 19 entidades del dominio definidas
- 4 BLoCs completos (Auth, Tienda, Producto, Image)
- Servicios core funcionando
- Conexión Supabase verificada
- **Configuración Clerk simplificada:** Solo publishableKey necesaria
- **Configuración R2 completada:** Variables definidas + Servicio multi-CDN

🎯 **PRÓXIMO MVP:** 7 días para app funcional con:
- Autenticación Clerk (social logins configurados en dashboard)
- Lista de tiendas con imágenes (multi-CDN: R2 → S3 → Supabase)
- Detalle de tienda básico
- Perfil de usuario
- Navegación completa

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
- **Flutter 3.7+** - Framework UI
- **Supabase** - Base de datos PostgreSQL
- **Clerk** - Autenticación simplificada (solo publishableKey)
- **Cloudflare R2** - Almacenamiento de imágenes (migración en progreso)
- **Hive** - Caché local offline-first
- **BLoC** - Gestión de estado
- **Multi-CDN** - Fallback automático: R2 → S3 → Supabase Storage

## 🔧 CONFIGURACIÓN COMPLETA

### Variables obligatorias (mínimo para funcionar):
```env
# Supabase (obligatorio)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon
SUPABASE_SERVICE_ROLE_KEY=tu-clave-servicio

# Clerk (obligatorio)
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
CLERK_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxx
```

### Clerk (configuración simplificada):
```env
# Solo necesitas la publishableKey de Clerk
# Social logins y temas se configuran en dashboard.clerk.com
CLERK_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxxxxxxxxxxxxx
CLERK_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxx  # Para sincronización con Supabase
```

### Cloudflare R2 (opcional - para migración multi-CDN):
```env
CLOUDFLARE_ACCOUNT_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_ACCESS_KEY_ID=1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_SECRET_ACCESS_KEY=abcdef1234567890abcdef1234567890abcdef1234567890abcdef
CLOUDFLARE_R2_BUCKET_NAME=paseo-del-comercio-images
CLOUDFLARE_R2_PUBLIC_URL=https://pub-1234567890abcdef.r2.dev
```

**📋 Ver [ESTRUCTURA_PROYECTO.md](ESTRUCTURA_PROYECTO.md) para configuración completa**
**🔧 Para R2: [GUIA_CLOUDFLARE_R2.md](GUIA_CLOUDFLARE_R2.md) - Guía paso a paso**

## 📊 MÉTRICAS DE CALIDAD

- ✅ **Compila sin errores** - Verificado
- 🎯 **< 2s cold start** - Objetivo
- 🎯 **< 500ms carga imágenes** - Objetivo
- 🎯 **0 crashes flujos principales** - Objetivo
- ✅ **Arquitectura testable** - Implementada

## 🚀 PRÓXIMOS PASOS

### Prioridad Alta (Esta semana):
1. Testing de integración con Supabase real
2. Configuración Cloudflare R2 bucket (obtener credenciales)
3. Pantallas de detalle (TiendaDetailPage, ProductoDetailPage)
4. Testing de integración Clerk (verificar social logins y temas)

### ✅ COMPLETADO ESTA SEMANA:
- Configuración Clerk simplificada (solo publishableKey)
- Variables de entorno R2 definidas y documentadas
- **Guía R2 completa:** Paso a paso para configuración
- Servicio multi-CDN configurado (R2 → S3 → Supabase)
- Documentación consolidada en 2 archivos + 1 guía específica

### Ver [PROGRESO_Y_PLAN.md](PROGRESO_Y_PLAN.md) para plan completo de 12 semanas.

## 📞 SOPORTE Y CONTACTO

### Equipo Recomendado:
- **1-2 Desarrolladores Flutter** - UI + BLoCs + Testing
- **1 Backend/DevOps** - Supabase + Cloudflare + CI/CD
- **1 QA/Testing** - Testing + documentación
- **1 Producto/Diseño** - UX/UI + feedback usuarios

### Credenciales Requeridas:
1. **Cloudflare R2** - Para completar migración multi-CDN
   - `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_R2_ACCESS_KEY_ID`, `CLOUDFLARE_R2_SECRET_ACCESS_KEY`
2. **Clerk Dashboard** - Para obtener publishableKey
   - `CLERK_PUBLISHABLE_KEY` (obligatorio - para autenticación)
   - `CLERK_SECRET_KEY` (opcional - para sincronización con Supabase)
3. **Supabase Dashboard** - Para testing de integración
   - `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`

### Documentación de Configuración:
- **📋 [ESTRUCTURA_PROYECTO.md](ESTRUCTURA_PROYECTO.md)** - Todas las variables con guías paso a paso
- **📖 [GUIA_CLOUDFLARE_R2.md](GUIA_CLOUDFLARE_R2.md)** - Guía específica para Cloudflare R2
- **🔧 Configuración Clerk** - Simplificada en `lib/core/config/clerk_config.dart`
- **☁️ Configuración R2** - Migración multi-CDN en `lib/core/config/r2_config.dart`

---

**📅 Última actualización:** Configuración simplificada completada  
**🎯 Estado:** ✅ **90% COMPLETADO** - CONFIGURACIÓN LISTA PARA MVP  
**📋 Documentación:** Consolidada en 2 archivos + 1 guía específica  
**🔧 Configuración:** Clerk simplificado + R2 multi-CDN implementados  
**📖 Guía R2:** Paso a paso para configuración en Cloudflare Dashboard
