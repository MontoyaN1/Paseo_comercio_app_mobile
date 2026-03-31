# Plan de Implementación: Fragmentación + Tema Oscuro/Claro

**Fecha:** Marzo 2026  
**Estado:** Planificado - Pendiente de implementación  
**Proyecto:** Paseo del Comercio - Mobile App  

---

## 📋 RESUMEN EJECUTIVO

Este documento detalla el plan de trabajo para dos mejoras arquitecturales fundamentales:

1. **Fragmentación de archivos** - Reducir archivos muy grandes para mejor mantenibilidad
2. **Sistema de Tema Oscuro/Claro** - Implementar soporte de temas basado en el sistema operativo con UI adaptable

### Objetivos

| Objetivo | Meta |
|----------|------|
| Mayor línea en archivo | 3332 → ~600 (pages) + ~1100 (painters) |
| Archivos > 500 líneas | ~15 → < 5 |
| Soporte tema automático | ❌ → ✅ |
| Colores UI hardcodeados | ~200 → ~30 (solo branding) |

---

## PARTE 1: LÍMITES DE LÍNEAS POR TIPO DE ARCHIVO

| Tipo de Archivo | Límite Recomendado | Justificación |
|----------------|-------------------|---------------|
| **Pages/Vistas** | **500-600 líneas** | Facilitan navegación, mantenimiento y code review |
| **BLoCs** | **400-500 líneas** | Separar eventos/estados si crece |
| **Repositories** | **400-500 líneas** | Dividir por métodos de query si crece |
| **Widgets reutilizables** | **200-300 líneas** | Pequeños y enfocados = más mantenibles |
| **Services** | **300-400 líneas** | Dividir por provider si crece |
| **Models/Entities** | **150-250 líneas** | Usar composición o mixins si crece |

---

## PARTE 2: CLASIFICACIÓN DE COLORES

### 2.1 Colores de UI Genéricos (APLICAN A TEMA)

Estos colores definen la interfaz y **SÍ deben cambiar** con el tema:

| Categoría | Dark (actual) | Light (nuevo) | Uso |
|-----------|---------------|---------------|-----|
| `background` | `#0A0A0F` | `#FAFAFA` | Fondo principal |
| `surface` | `#0F0F1E` | `#FFFFFF` | Cards, dialogs |
| `onSurface` | `#FFFFFF` | `#1A1A1A` | Texto principal |
| `goldAccent` | `#D4AF37` | `#C9A227` | Acentos, íconos |
| `border` | `#1E1E3A` | `#E0E0E0` | Bordes, divisores |
| `error` | `#CF6679` | `#B00020` | Estados de error |
| `hint` | `#6B6B8A` | `#757575` | Texto hint, placeholders |
| `success` | `#4CAF50` | `#388E3C` | Estados de éxito |

### 2.2 Colores de Branding/Decorativos (NO CAMBIAN)

Estos colores son parte de la identidad visual y **NO deben cambiar** con el tema:

| Categoría | Ejemplo | Razón |
|-----------|---------|-------|
| **Mall Floor** | `_kBg`, mármol | Diseño isométrico específico del mall |
| **Painter Effects** | neons, skylight, bokeh | Efectos visuales únicos de la app |
| **Gradientes atmosféricos** | glows, ambient particles | Parte del branding "lujo" |
| **Suelo isométrico** | mármol noir, corredores | Estética visual específica |

**Decisión de diseño:** Los painters (`_BgPainter`, `_WorldPainter`) permanecerán siempre en modo oscuro, considerados "hero images" de branding, no componentes de UI genéricos.

---

## PARTE 3: ARQUITECTURA DEL SISTEMA DE TEMA

### 3.1 Estructura de Archivos

```
lib/
  core/
    theme/
      app_colors.dart           (~150 líneas)
        - Colores para tema light/dark
        - Extensiones de ColorScheme
      
      app_theme.dart           (~100 líneas)
        - ThemeData.light
        - ThemeData.dark
        - Extensiones de tema

  presentation/
    providers/
      theme_provider.dart      (ya existe, ~24 líneas)
        - ThemeProvider con persistencia
```

### 3.2 Toggle de Tema en Settings

```
Settings
├── Tema
│   ├── [●] Sistema (default) - Sigue configuración del SO
│   ├── [ ] Claro
│   └── [ ] Oscuro
```

El usuario puede elegir:
- **Sistema (default):** `ThemeMode.system` - Detecta automáticamente
- **Claro:** `ThemeMode.light` - Forza light mode
- **Oscuro:** `ThemeMode.dark` - Forza dark mode

### 3.3 Cambios en main.dart

```dart
// Antes
MaterialApp.router(
  debugShowCheckedModeBanner: false,
  title: AppConfig().appName,
  locale: const Locale('es', 'ES'),
  routerConfig: AppRouter.router,
)

// Después
MaterialApp.router(
  debugShowCheckedModeBanner: false,
  title: AppConfig().appName,
  locale: const Locale('es', 'ES'),
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeProvider.themeMode, // system/light/dark
  routerConfig: AppRouter.router,
)
```

---

## PARTE 4: FRAGMENTACIÓN DE ARCHIVOS

### 4.1 Archivo Crítico: `plazoleta_list_page.dart` (3332 líneas)

**ANTES:**
```
lib/presentation/pages/plazoletas/
  plazoleta_list_page.dart  (3332 líneas)
    - Constants de colores
    - Models _Slot, _Plaza
    - _PlazoletaListPageState (lógica)
    - _MallBackground + _BgPainter (painter atmosférico)
    - _WorldPainter (painter isométrico completo)
    - _DetailPanel (panel de preview)
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    mall/
      mall_background.dart       (~150 líneas)
        - _MallBackground (widget)
        - _BgPainter (skylight, beams, ambient glow, bokeh)
      
      mall_world_painter.dart    (~1100 líneas)
        - _WorldPainter (suelo mármol, columnas, tiendas, atrio)
        - Métodos helper de dibujo isométrico
        - _path4(), _iso() helpers
      
    plazoleta/
      plazoleta_detail_panel.dart (~350 líneas)
        - _DetailPanel (panel de preview al tocar plaza)
        
  pages/plazoletas/
    plazoleta_list_page.dart     (~600 líneas)
      - Constants de colores (solo UI genéricos)
      - Models _Slot, _Plaza
      - _PlazoletaListPageState (lógica principal)
      - Integración de MallBackground
```

---

### 4.2 Archivo: `organizacion_list_page.dart` (1471 líneas)

**ANTES:**
```
lib/presentation/pages/organizaciones/
  organizacion_list_page.dart  (1471 líneas)
    - _BgPainter (partículas isométricas)
    - _OrganizacionCard (card completa)
    - _GoldFilterChip
    - Filtros, búsqueda
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    organizacion/
      organizacion_card.dart          (~400 líneas)
        - _OrganizacionCard
        - _TypeBadge
        - _GoldStatItem
      
      organizacion_filter_chip.dart   (~150 líneas)
        - _GoldFilterChip
      
      organizacion_bg_painter.dart    (~200 líneas)
        - _BgPainter (partículas flotantes)
        
  pages/organizaciones/
    organizacion_list_page.dart       (~500 líneas)
      - Lógica principal
      - Filtros y búsqueda
```

---

### 4.3 Archivo: `login_page.dart` (1416 líneas)

**ANTES:**
```
lib/presentation/pages/auth/
  login_page.dart  (1416 líneas)
    - _BgPainter (partículas + rayos de luz)
    - Decorators de glassmorphism
    - Login UI completa
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    auth/
      login_background.dart     (~200 líneas)
        - _BgPainter
        - Partículas flotantes
      
      login_decorators.dart     (~150 líneas)
        - Decorators glassmorphism
      
  pages/auth/
    login_page.dart             (~800 líneas)
      - UI de login
      - Integración con Firebase Auth
```

---

### 4.4 Archivo: `profile_page.dart` (2539 líneas)

**ANTES:**
```
lib/presentation/pages/profile/
  profile_page.dart  (2539 líneas)
    - Header con avatar
    - Stats cards
    - Menu items
    - Dialogs
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    profile/
      profile_header.dart       (~300 líneas)
        - Avatar, nombre, email
        - Decorators
      
      profile_stats_card.dart   (~200 líneas)
        - Stats de usuario
      
      profile_menu_item.dart    (~150 líneas)
        - Items del menú
        - Iconos, acciones
      
  pages/profile/
    profile_page.dart          (~800 líneas)
      - Dialogs
      - Integración de widgets
```

---

### 4.5 Archivos Pendientes de Revisión

| Archivo | Líneas | Acción Sugerida |
|---------|--------|----------------|
| `tienda_detail_page.dart` | 2210 | Extraer tabs, info widgets, reviews list |
| `producto_detail_page.dart` | 2142 | Similar a tienda |
| `plazoleta_detail_page.dart` | 1577 | Extraer widgets de detalle |
| `settings_page.dart` | 695 | Agregar toggle de tema cuando se implemente |
| `soporte_page.dart` | 649 | Mantener, ya está bien estructurado |
| `historial_page.dart` | 627 | Mantener, está bien |

---

## PARTE 5: FASES DE IMPLEMENTACIÓN

### Fase 1: Sistema de Tema Base

**Objetivo:** Crear infraestructura de temas sin afectar funcionalidad existente.

#### 1.1 Crear sistema de colores
```
Crear: lib/core/theme/app_colors.dart
  - Colores para light/dark
  - Extensiones de ColorScheme
```

#### 1.2 Crear ThemeData
```
Crear: lib/core/theme/app_theme.dart
  - ThemeData.light
  - ThemeData.dark
  - Extensiones de TextTheme
```

#### 1.3 Integrar en main.dart
```
Modificar: lib/main.dart
  - Agregar theme: AppTheme.lightTheme
  - Agregar darkTheme: AppTheme.darkTheme
  - themeMode: ThemeMode.system (default)
```

#### 1.4 Agregar persistencia
```
Modificar: lib/presentation/providers/theme_provider.dart
  - SharedPreferences para guardar preferencia
  - Método para cargar preferencia al inicio
```

#### 1.5 Toggle en Settings
```
Modificar: lib/presentation/pages/settings/settings_page.dart
  - Agregar sección de Tema
  - Radio buttons o dropdown
```

**Archivos afectados:** 2 nuevos, 2 modificados  
**Líneas de código:** ~300 nuevas

---

### Fase 2: Widgets Compartidos con Tema

**Objetivo:** Aplicar tema a widgets reutilizables existentes.

#### 2.1 Identificar widgets a modificar
```
- lib/presentation/widgets/common/loading_state.dart
- lib/presentation/widgets/common/empty_state.dart
- lib/presentation/widgets/common/error_state.dart
- lib/presentation/widgets/custom_app_bar.dart
- lib/presentation/widgets/favorite_button.dart
```

#### 2.2 Refactorizar para usar Theme
```
Cambiar colores hardcodeados por Theme.of(context)
Ejemplo:
  antes: Color(0xFF0A0A0F)
  después: Theme.of(context).colorScheme.surface
```

**Archivos afectados:** ~6 widgets  
**Líneas de código:** ~150 modificadas

---

### Fase 3: Fragmentar `plazoleta_list_page.dart`

**Objetivo:** Reducir de 3332 a ~600 líneas en page + ~1500 en widgets separados.

#### 3.1 Crear estructura de carpetas
```bash
mkdir -p lib/presentation/widgets/mall
mkdir -p lib/presentation/widgets/plazoleta
```

#### 3.2 Extraer `mall_background.dart`
```
Crear: lib/presentation/widgets/mall/mall_background.dart
Mover:
  - _MallBackground (widget Stateless)
  - _BgPainter (CustomPainter)
```

#### 3.3 Extraer `mall_world_painter.dart`
```
Crear: lib/presentation/widgets/mall/mall_world_painter.dart
Mover:
  - _WorldPainter (CustomPainter principal)
  - Métodos helper (_path4, _iso, etc.)
```

#### 3.4 Extraer `plazoleta_detail_panel.dart`
```
Crear: lib/presentation/widgets/plazoleta/plazoleta_detail_panel.dart
Mover:
  - _DetailPanel
```

#### 3.5 Limpiar `plazoleta_list_page.dart`
```
Mantener:
  - Constants de colores UI
  - Models _Slot, _Plaza
  - _PlazoletaListPageState
  - Integración de widgets extraídos
```

**Archivos afectados:** 1 modificado, 3 nuevos  
**Líneas:** 3332 → ~600 (page) + ~1500 (widgets)

---

### Fase 4: Fragmentar `organizacion_list_page.dart`

**Objetivo:** Reducir de 1471 a ~500 líneas en page + widgets separados.

#### 4.1 Crear estructura de carpetas
```bash
mkdir -p lib/presentation/widgets/organizacion
```

#### 4.2 Extraer `organizacion_card.dart`
```
Crear: lib/presentation/widgets/organizacion/organizacion_card.dart
Mover:
  - _OrganizacionCard
  - _TypeBadge
  - _GoldStatItem
```

#### 4.3 Extraer `organizacion_filter_chip.dart`
```
Crear: lib/presentation/widgets/organizacion/organizacion_filter_chip.dart
Mover:
  - _GoldFilterChip
```

#### 4.4 Extraer `organizacion_bg_painter.dart`
```
Crear: lib/presentation/widgets/organizacion/organizacion_bg_painter.dart
Mover:
  - _BgPainter
```

#### 4.5 Limpiar `organizacion_list_page.dart`
```
Mantener:
  - Lógica de estado
  - Búsqueda y filtros
  - Integración de widgets
```

**Archivos afectados:** 1 modificado, 3 nuevos  
**Líneas:** 1471 → ~500 (page) + ~750 (widgets)

---

### Fase 5: Fragmentar `login_page.dart`

**Objetivo:** Reducir de 1416 a ~800 líneas + widgets separados.

#### 5.1 Crear estructura de carpetas
```bash
mkdir -p lib/presentation/widgets/auth
```

#### 5.2 Extraer `login_background.dart`
```
Crear: lib/presentation/widgets/auth/login_background.dart
Mover:
  - _BgPainter
```

#### 5.3 Extraer `login_decorators.dart`
```
Crear: lib/presentation/widgets/auth/login_decorators.dart
Mover:
  - Decorators glassmorphism
```

#### 5.4 Limpiar `login_page.dart`
```
Mantener:
  - UI de login
  - Métodos de autenticación
  - Integración
```

**Archivos afectados:** 1 modificado, 2 nuevos  
**Líneas:** 1416 → ~800 (page) + ~600 (widgets)

---

### Fase 6: Fragmentar `profile_page.dart`

**Objetivo:** Reducir de 2539 a ~800 líneas + widgets separados.

#### 6.1 Crear estructura de carpetas
```bash
mkdir -p lib/presentation/widgets/profile
```

#### 6.2 Extraer widgets
```
Crear: lib/presentation/widgets/profile/profile_header.dart
Crear: lib/presentation/widgets/profile/profile_stats_card.dart
Crear: lib/presentation/widgets/profile/profile_menu_item.dart
```

#### 6.3 Limpiar `profile_page.dart`
```
Mantener:
  - Dialogs
  - Lógica de estado
  - Integración
```

**Archivos afectados:** 1 modificado, 3 nuevos  
**Líneas:** 2539 → ~800 (page) + ~700 (widgets)

---

### Fase 7: Fragmentar Detalle Pages

**Objetivo:** Reducir páginas de detalle muy grandes.

#### 7.1 `tienda_detail_page.dart` (2210 líneas)
```
widgets/tienda/
  tienda_info_section.dart     (~300 líneas)
  tienda_reviews_list.dart    (~400 líneas)
  tienda_tab_content.dart     (~200 líneas)

pages/tiendas/
  tienda_detail_page.dart     (~1000 líneas)
```

#### 7.2 `producto_detail_page.dart` (2142 líneas)
```
widgets/producto/
  producto_info_section.dart   (~300 líneas)
  producto_reviews_list.dart  (~400 líneas)

pages/productos/
  producto_detail_page.dart    (~1000 líneas)
```

---

## PARTE 6: ORDEN DE IMPLEMENTACIÓN SUGERIDO

| Orden | Fase | Archivos | Esfuerzo | Dependencias |
|-------|------|----------|----------|--------------|
| 1 | Fase 1 | Sistema de tema base | Bajo | Ninguna |
| 2 | Fase 2 | Widgets compartidos | Bajo | Fase 1 |
| 3 | Fase 3 | plazoleta_list_page | Alto | Ninguna |
| 4 | Fase 4 | organizacion_list_page | Medio | Fase 2 |
| 5 | Fase 5 | login_page | Medio | Ninguna |
| 6 | Fase 6 | profile_page | Medio | Fase 2 |
| 7 | Fase 7 | detail pages | Alto | Fase 2 |

**Total estimado:** 6-8 sprints de trabajo

---

## PARTE 7: MÉTRICAS OBJETIVO

| Métrica | Antes | Después |
|---------|-------|---------|
| Mayor archivo (pages) | 3332 | ~600 |
| Mayor painter | N/A | ~1100 (no cambia) |
| Archivos > 500 líneas | ~15 | < 5 |
| Archivos > 1000 líneas | ~8 | 0 |
| Líneas promedio pages | ~1800 | < 600 |
| Soporte tema automático | ❌ | ✅ |
| Toggle de tema en Settings | ❌ | ✅ |
| Colores UI hardcodeados | ~200 | ~30 (branding) |
| Widgets usando Theme.of() | ~0 | 100% UI genérica |

---

## PARTE 8: NOTAS TÉCNICAS

### 8.1 Cómo usar Theme.of(context)

```dart
// Ejemplo: Color de fondo
// ANTES (hardcodeado):
Container(color: Color(0xFF0A0A0F))

// DESPUÉS (tema):
Container(color: Theme.of(context).colorScheme.surface)

// Para colores que NO existen en ColorScheme:
Container(color: context.theme.colorScheme.surface)
```

### 8.2 Custom ColorScheme Extension

```dart
extension CustomColorScheme on ColorScheme {
  Color get goldAccent => brightness == Brightness.dark 
    ? Color(0xFFD4AF37) 
    : Color(0xFFC9A227);
}
```

### 8.3 Painters como Branding

Los painters (_BgPainter, _WorldPainter) son considerados "hero images" de branding y **NO** deben cambiar con el tema. Son excepciones intencionales al sistema de temas.

---

## PARTE 9: VALIDACIÓN

### Checklist de Implementación

- [ ] `app_colors.dart` creado con todos los colores
- [ ] `app_theme.dart` creado con light/dark ThemeData
- [ ] `main.dart` integrado con tema
- [ ] `ThemeProvider` con persistencia
- [ ] Toggle en Settings funcionando
- [ ] Widgets compartidos refactorizados
- [ ] plazoleta_list_page fragmentado
- [ ] organizacion_list_page fragmentado
- [ ] login_page fragmentado
- [ ] profile_page fragmentado
- [ ] Detail pages fragmentados
- [ ] Análisis estático sin errores

### Testing Post-Implementación

- [ ] Tema cambia al cambiar toggle en Settings
- [ ] Tema sigue al sistema cuando está en "Sistema"
- [ ] Navegación de返回 a listas funciona correctamente
- [ ] Painters mantienen estética dark
- [ ] Widgets usan colores de tema correctamente

---

## ARCHIVOS RELACIONADOS

- `doc/FUNCIONALIDADES_PENDIENTES.md` - Catálogo de funcionalidades pendientes
- `doc/AGENTS.md` - Guía para desarrolladores
- `lib/presentation/providers/theme_provider.dart` - Provider de tema (ya existe)
- `lib/core/theme/` - Directorio para nuevos archivos de tema

---

**Última actualización:** Marzo 2026  
**Estado:** Planificado - Listo para implementar  
**Responsable:** Equipo de desarrollo
