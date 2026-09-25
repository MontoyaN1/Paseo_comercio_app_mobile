# 📚 DOCUMENTACIÓN - Paseo del Comercio App Móvil

Esta carpeta contiene toda la documentación del proyecto organizada por categorías.

---

## 📁 ESTRUCTURA DE CARPETAS

```
doc/
├── README.md                          # Este archivo - índice general
│
├── 1_PROJECT/                         # Estado y planificación
│   ├── README.md                       # Índice del proyecto
│   ├── PROGRESO_Y_PLAN.md              # Estado actual y roadmap
│   ├── MOVIL_PLAN.md                   # Plan de implementación móvil
│   └── FUNCIONALIDADES_PENDIENTES.md    # Catálogo de features pendientes
│
├── 2_ARCHITECTURE/                    # Arquitectura técnica
│   ├── README.md                       # Índice de arquitectura
│   └── ESTRUCTURA_PROYECTO.md          # Arquitectura Clean Architecture
│
├── 3_DATABASE/                        # Base de datos
│   ├── README.md                       # Índice de base de datos
│   ├── ESQUEMA_BASE_DATOS.md           # Esquema PostgreSQL (24+ tablas)
│   └── ESQUEMA_FAVORITOS.md            # Sistema de favoritos
│
├── 4_IMPLEMENTATION/                  # Guías de implementación
│   ├── README.md                       # Índice de guías
│   └── DEEP_LINKS_IMPLEMENTATION.md    # Guía de deep links
│
├── 5_DIAGRAMS/                        # Diagramas Mermaid
│   ├── README.md                       # Índice de diagramas
│   ├── entidades_completo.mmd           # Diagrama ER completo
│   └── diagrama_favoritos.mmd          # Diagrama de favoritos
│
├── PROPUESTAS_UI.md                   # Propuestas de diseño UI/UX
└── AGENTS.md                          # Guía para agentes IA
```

---

## 🚀 GUÍA DE INICIO RÁPIDA

### Para desarrolladores nuevos:

1. **了解 Estado del proyecto:** `1_PROJECT/PROGRESO_Y_PLAN.md`
2. **🏗️ Arquitectura:** `2_ARCHITECTURE/ESTRUCTURA_PROYECTO.md`
3. **🗄️ Base de datos:** `3_DATABASE/ESQUEMA_BASE_DATOS.md`
4. **📱 UI/UX:** `PROPUESTAS_UI.md`

---

## 📋 ÍNDICE DE DOCUMENTACIÓN

### 1_PROJECT - Estado y Planificación

| Documento | Descripción |
|-----------|-------------|
| **PROGRESO_Y_PLAN.md** | Estado actual del proyecto, fases completadas, próximo roadmap |
| **MOVIL_PLAN.md** | Plan detallado de implementación móvil (Fases 1-7) |
| **FUNCIONALIDADES_PENDIENTES.md** | Catálogo completo: pendientes de testing, pendientes de implementar, postergadas |

### 2_ARCHITECTURE - Arquitectura

| Documento | Descripción |
|-----------|-------------|
| **ESTRUCTURA_PROYECTO.md** | Arquitectura Clean Architecture, estructura de carpetas, patrones usados |

### 3_DATABASE - Base de Datos

| Documento | Descripción |
|-----------|-------------|
| **ESQUEMA_BASE_DATOS.md** | Esquema completo PostgreSQL con 24+ tablas, relaciones, índices |
| **ESQUEMA_FAVORITOS.md** | Sistema de favoritos: SQL, entidades Flutter, BLoC |

### 4_IMPLEMENTATION - Guías de Implementación

| Documento | Descripción |
|-----------|-------------|
| **DEEP_LINKS_IMPLEMENTATION.md** | Guía paso a paso para implementar deep links (Firebase App Links / Dynamic Links) |

### 5_DIAGRAMS - Diagramas

| Documento | Descripción |
|-----------|-------------|
| **entidades_completo.mmd** | Diagrama ER con 24+ tablas (formato Mermaid) |
| **diagrama_favoritos.mmd** | Diagrama del sistema de favoritos (formato Mermaid) |

### Raíz

| Documento | Descripción |
|-----------|-------------|
| **PROPUESTAS_UI.md** | Propuestas de diseño UI/UX, wireframes, flujos de usuario |
| **AGENTS.md** | Guía para agentes IA, convenciones de código, comandos útiles |

---

## 📊 ESTADÍSTICAS DEL PROYECTO

### Estado General (Marzo 2026)

| Métrica | Valor |
|---------|-------|
| **Total archivos docs** | 15+ |
| **Total tablas BD** | 24 + 2 (favoritos) |
| **BLoCs implementados** | 7 |
| **Pages** | 10+ |
| **Estado** | MVP Funcional |

### Cobertura Funcional

| Feature | Estado |
|---------|--------|
| Autenticación | ✅ 95% (faltan tests) |
| Tiendas | ✅ 95% |
| Productos | ✅ 95% |
| Favoritos | ✅ 100% |
| Imágenes | ✅ 90% |
| Navegación | ✅ 100% |
| Settings/Soporte | ✅ 100% |
| Share | ✅ 100% |
| Google Maps | ⚠️ Parcial (url_launcher funciona) |
| Historial | ⏸️ Postergado (código listo) |
| Tests | ❌ Pendientes (T1-T4) |

---

## 🔧 HERRAMIENTAS Y COMANDOS

Ver `AGENTS.md` para comandos completos de desarrollo:

```bash
# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run

# Analizar código
flutter analyze

# Tests
flutter test

# Build release
flutter build apk --release
```

---

**📅 Última actualización:** Marzo 2026  
**📁 Estructura:** ✅ Organizada en carpetas por categoría  
**🔗 Diagramas:** ✅ Mermaid (.mmd)  
**📊 Total tablas BD:** 24 + 2 nuevas (favoritos)
