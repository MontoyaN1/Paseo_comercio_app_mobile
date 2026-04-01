# Plan de Implementación: Fragmentación + Tema Oscuro/Claro

**Fecha:** Abril 2026  
**Estado:** Fase 8 ✅ COMPLETADA - Próximo: Fase 9  
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

> **NOTA IMPORTANTE:** Cada fase de fragmentación DEBE incluir la sustitución de colores de UI genéricos por `Theme.of(context)`. Los únicos colores que permanecen hardcodeados son los de branding ( painters, neons, oro decorativo).

### 4.1 Archivo Crítico: `plazoleta_list_page.dart` (3332 líneas)

**ANTES:**
```
lib/presentation/pages/plazoletas/
  plazoleta_list_page.dart  (3332 líneas)
    - Constants de colores (_kBg, _kSurface, etc.)
    - Models _Slot, _Plaza
    - _PlazoletaListPageState (lógica)
    - _MallBackground + _BgPainter (painter - NO cambia con tema)
    - _WorldPainter (painter isométrico - NO cambia con tema)
    - _DetailPanel (panel de preview - USA tema)
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    mall/
      mall_background.dart       (~150 líneas)
        - _MallBackground (widget - NO cambia con tema)
        - _BgPainter (skylight, beams, ambient glow, bokeh - NO cambia)
      
      mall_world_painter.dart    (~1100 líneas)
        - _WorldPainter (suelo mármol, columnas, tiendas, atrio - NO cambia)
        - Métodos helper de dibujo isométrico
        - _path4(), _iso() helpers
        ⚠️ COLORES: Todos hardcodeados (branding isométrico)
      
    plazoleta/
      plazoleta_detail_panel.dart (~350 líneas)
        - _DetailPanel (panel de preview al tocar plaza)
        ⚠️ COLORES: USA Theme.of(context) para background, bordes, texto
        
  pages/plazoletas/
    plazoleta_list_page.dart     (~600 líneas)
      - Models _Slot, _Plaza
      - _PlazoletaListPageState (lógica principal)
      - Integración de MallBackground
      - Header glassmorphism con gradientes → USAR Theme.of(context)
```

**Cambios de color requeridos en fragmentación:**
| Antes (hardcoded) | Después (tema) |
|-------------------|----------------|
| `_kBg` (background) | `Theme.of(context).colorScheme.surface` |
| `_kSurface` | `Theme.of(context).colorScheme.surfaceContainerHighest` |
| `_kBorder` | `Theme.of(context).colorScheme.outline` |
| `_kHint` | `Theme.of(context).colorScheme.onSurfaceVariant` |
| Colores de texto blanco | `Theme.of(context).colorScheme.onSurface` |

**QUE NO CAMBIA (branding):**
- `_kGold`, `_kGoldGlow`, `_kGoldDeep` (orado decorativo)
- Colores del painter (`_kNeonBlue`, `_kNeonPink`, etc.)
- Gradientes del mall isométrico

---

### 4.2 Archivo: `organizacion_list_page.dart` (1471 líneas)

**ANTES:**
```
lib/presentation/pages/organizaciones/
  organizacion_list_page.dart  (1471 líneas)
    - _BgPainter (partículas isométricas - NO cambia)
    - _OrganizacionCard (card completa - USA tema)
    - _GoldFilterChip (USA tema)
    - Filtros, búsqueda (USA tema)
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
        ⚠️ COLORES: USA Theme.of(context)
      
      organizacion_filter_chip.dart   (~150 líneas)
        - _GoldFilterChip
        ⚠️ COLORES: USA Theme.of(context)
      
      organizacion_bg_painter.dart    (~200 líneas)
        - _BgPainter (partículas flotantes - NO cambia)
        ⚠️ COLORES: Todos hardcodeados (branding)
        
  pages/organizaciones/
    organizacion_list_page.dart       (~500 líneas)
      - Lógica principal
      - Filtros y búsqueda
      - Integración de widgets
```

---

### 4.3 Archivo: `login_page.dart` (1416 líneas)

**ANTES:**
```
lib/presentation/pages/auth/
  login_page.dart  (1416 líneas)
    - _BgPainter (partículas + rayos de luz - NO cambia)
    - Decorators de glassmorphism (USA tema)
    - Login UI completa (USA tema)
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    auth/
      login_background.dart     (~200 líneas)
        - _BgPainter
        ⚠️ COLORES: Todos hardcodeados (branding)
      
      login_decorators.dart     (~150 líneas)
        - Decorators glassmorphism
        ⚠️ COLORES: USA Theme.of(context)
      
  pages/auth/
    login_page.dart             (~800 líneas)
      - UI de login
      - Integración con Firebase Auth
      - Campos de texto, botones → USAR Theme.of(context)
```

---

### 4.4 Archivo: `profile_page.dart` (2539 líneas)

**ANTES:**
```
lib/presentation/pages/profile/
  profile_page.dart  (2539 líneas)
    - Header con avatar (USA tema)
    - Stats cards (USA tema)
    - Menu items (USA tema)
    - Dialogs (USA tema)
```

**DESPUÉS:**
```
lib/presentation/
  widgets/
    profile/
      profile_header.dart       (~300 líneas)
        - Avatar, nombre, email
        - Decorators
        ⚠️ COLORES: USA Theme.of(context)
      
      profile_stats_card.dart   (~200 líneas)
        - Stats de usuario
        ⚠️ COLORES: USA Theme.of(context)
      
      profile_menu_item.dart    (~150 líneas)
        - Items del menú
        - Iconos, acciones
        ⚠️ COLORES: USA Theme.of(context)
      
  pages/profile/
    profile_page.dart          (~800 líneas)
      - Dialogs
      - Lógica de estado
      - Integración de widgets
```

---

### 4.5 Archivos Pendientes de Revisión

| Archivo | Líneas | Acción Sugerida |
|---------|--------|----------------|
| `tienda_detail_page.dart` | 2210 | Extraer tabs, info widgets, reviews list + USAR tema |
| `producto_detail_page.dart` | 2142 | Similar a tienda + USAR tema |
| `plazoleta_detail_page.dart` | 1577 | Extraer widgets de detalle + USAR tema |
| `settings_page.dart` | 695 | Ya tiene toggle, mejorar colores UI con tema |
| `soporte_page.dart` | 649 | Mantener, revisar colores con tema |
| `historial_page.dart` | 627 | Mantener, revisar colores con tema |

---

## PARTE 5: FASES DE IMPLEMENTACIÓN

### Fase 1: Sistema de Tema Base ✅ COMPLETADA

**Objetivo:** Crear infraestructura de temas sin afectar funcionalidad existente.

#### 1.1-1.5 Completado
- `app_colors.dart` creado
- `app_theme.dart` creado
- `main.dart` integrado
- `ThemeProvider` con persistencia
- Toggle en Settings

---

### Fase 2: Widgets Compartidos con Tema ✅ COMPLETADA

**Objetivo:** Aplicar tema a widgets reutilizables existentes.

Widgets refactorizados:
- `loading_state.dart` ✅
- `empty_state.dart` ✅
- `error_state.dart` ✅
- `custom_app_bar.dart` ✅
- `favorite_button.dart` ✅

---

### Fase 3: Fragmentar `plazoleta_list_page.dart` + Aplicar Tema ✅ COMPLETADA

**Objetivo:** Reducir de 3332 a ~600 líneas + reemplazar colores UI con tema.

#### 3.1 Crear estructura de carpetas
```bash
mkdir -p lib/presentation/widgets/mall
mkdir -p lib/presentation/widgets/plazoleta
```

#### 3.2 Extraer `mall_background.dart`
```
Crear: lib/presentation/widgets/mall/mall_background.dart
Mover: _MallBackground, _BgPainter
⚠️ NOTA: Este archivo NO usa tema (branding isométrico)
```

#### 3.3 Extraer `mall_world_painter.dart`
```
Crear: lib/presentation/widgets/mall/mall_world_painter.dart
Mover: _WorldPainter y helpers
⚠️ NOTA: Este archivo NO usa tema (branding isométrico)
```

#### 3.4 Extraer `plazoleta_detail_panel.dart`
```
Crear: lib/presentation/widgets/plazoleta/plazoleta_detail_panel.dart
Mover: _DetailPanel
⚠️ IMPORTANTE: Reemplazar colores hardcodeados por Theme.of(context):
  - background → theme.colorScheme.surface
  - bordes → theme.colorScheme.outline
  - texto → theme.colorScheme.onSurface / onSurfaceVariant
```

#### 3.5 Refactorizar `plazoleta_list_page.dart`
```
Mantener:
  - Models _Slot, _Plaza
  - _PlazoletaListPageState
  - Integración de MallBackground

Reemplazar colores en widgets de UI:
  - Header glassmorphism → theme.colorScheme.surface
  - Map controls → theme.colorScheme.surfaceContainerHighest
  - Texto UI → theme.colorScheme.onSurface
  - Bordes → theme.colorScheme.outline
```

**Colores que PERMANECEN hardcoded (branding):**
- `_kGold`, `_kGoldGlow`, `_kGoldDeep` - oro decorativo
- `_kWarmLight`, `_kCoolLight`, `_kSkylight` - iluminación del painter
- `_kNeonBlue`, `_kNeonPink`, etc. - neons del painter

**Archivos afectados:** 1 modificado, 3 nuevos  
**Líneas:** 3332 → ~600 (page) + ~1500 (widgets)

---

### Fase 4: Fragmentar `organizacion_list_page.dart` + Aplicar Tema ✅ COMPLETADA

**Objetivo:** Reducir de 1471 a ~500 + reemplazar colores UI con tema.

#### 4.1-4.4 Extraer widgets
```
lib/presentation/widgets/organizacion/
  organizacion_card.dart          (~400 líneas) → USA TEMA
  organizacion_filter_chip.dart   (~150 líneas) → USA TEMA
  organizacion_bg_painter.dart    (~200 líneas) → NO USA TEMA (branding)
```

#### 4.5 Refactorizar page
```
Reemplazar colores hardcodeados por Theme.of(context)
```

**Archivos afectados:** 1 modificado, 3 nuevos  
**Líneas:** 1471 → ~500 (page) + ~750 (widgets)

---

### Fase 5: Fragmentar `login_page.dart` + Aplicar Tema

**Objetivo:** Reducir de 1416 a ~800 + reemplazar colores UI con tema.

#### 5.1-5.4 Extraer widgets
```
lib/presentation/widgets/auth/
  login_background.dart     (~200 líneas) → NO USA TEMA (branding)
  login_decorators.dart    (~150 líneas) → USA TEMA
```

**Archivos afectados:** 1 modificado, 2 nuevos  
**Líneas:** 1416 → ~800 (page) + ~600 (widgets)

---

### Fase 6: Fragmentar `profile_page.dart` + Aplicar Tema

**Objetivo:** Reducir de 2539 a ~800 + reemplazar colores UI con tema.

#### 6.1-6.3 Extraer widgets
```
lib/presentation/widgets/profile/
  profile_header.dart       (~300 líneas) → USA TEMA
  profile_stats_card.dart  (~200 líneas) → USA TEMA
  profile_menu_item.dart   (~150 líneas) → USA TEMA
```

**Archivos afectados:** 1 modificado, 3 nuevos  
**Líneas:** 2539 → ~800 (page) + ~700 (widgets)

---

### Fase 7: Fragmentar Detalle Pages + Aplicar Tema ✅ COMPLETADA (Parcial)

**Objetivo:** Reducir páginas de detalle + reemplazar colores UI con tema.

#### 7.1 Widgets Creados (Tienda)
```
lib/presentation/widgets/tienda/
  tienda_bg_painter.dart    (136 líneas) → NO USA TEMA (branding)
  tienda_components.dart    (435 líneas) → USA TEMA
    - TiendaHeroStatPill
    - TiendaGoldStatCard
    - TiendaGoldInfoRow
    - TiendaPhoneInfo
    - TiendaGoldDivider
    - TiendaIconButton
    - TiendaActionButton
    - TiendaOutlineButton
  tienda_hero.dart         (~340 líneas) → USA TEMA
  tienda_info_tab.dart      (~560 líneas) → USA TEMA
  tienda_productos_tab.dart (~115 líneas) → USA TEMA
  tienda_app_bar.dart       (~122 líneas) → USA TEMA
```

#### 7.2 Widgets Creados (Producto)
```
lib/presentation/widgets/producto/
  producto_bg_painter.dart  (127 líneas) → NO USA TEMA (branding)
  producto_components.dart   (131 líneas) → USA TEMA
    - ProductoPhoneInfo
    - ProductoGoldStatCard
    - ProductoIconButton
  producto_hero.dart        (~220 líneas) → USA TEMA
  producto_app_bar.dart     (~119 líneas) → USA TEMA
  producto_info_tab.dart    (~253 líneas) → USA TEMA
  producto_tienda_tab.dart  (~60 líneas) → USA TEMA
  producto_valoraciones_tab.dart (~355 líneas) → USA TEMA
  producto_valoracion_dialog.dart (~165 líneas) → USA TEMA
```

#### 7.3 Pages Actualizadas
- `tienda_detail_page.dart` (2210 → 621 líneas, 70% reducción) ✅
- `producto_detail_page.dart` (2142 → 917 líneas, 54% reducción) ✅

---

### Fase 8: Detalle Pages + Organizacion/Plazoleta + Tema ✅ COMPLETADA

#### 8.1 plazoleta_detail_page.dart ✅ COMPLETADO
```
lib/presentation/widgets/plazoleta/
  plazoleta_bg_painter.dart  ✅ NO USA TEMA (branding)
  plazoleta_hero.dart       ✅ USA TEMA
  plazoleta_app_bar.dart    ✅ USA TEMA
  plazoleta_info_tab.dart   ✅ USA TEMA
  plazoleta_productos_tab.dart ✅ USA TEMA (nuevo)
  plazoleta_tiendas_tab.dart ✅ USA TEMA (nuevo)

lib/presentation/pages/plazoletas/
  plazoleta_detail_page.dart ✅ (1577 → 516 líneas, 67% reducción)
```

#### 8.2 organizacion_detail_page.dart ✅ COMPLETADO
```
lib/presentation/widgets/organizacion/
  organizacion_bg_painter.dart  ✅ USA TEMA (adaptado)
  organizacion_components.dart  ✅ USA TEMA (expandido)
  organizacion_hero.dart        ✅ USA TEMA (nuevo)
  organizacion_app_bar.dart     ✅ USA TEMA (nuevo)
  organizacion_info_tab.dart    ✅ USA TEMA (nuevo)
  organizacion_tiendas_tab.dart ✅ USA TEMA (nuevo)

lib/presentation/pages/organizaciones/
  organizacion_detail_page.dart ✅ (1272 → 372 líneas, 71% reducción)
```

---

### Fase 9: Más Fragmentación + Tema 🚧 EN PROGRESO

#### 9.1 plazoleta_list_page.dart (~950 líneas) ⏳ PENDIENTE

```
lib/presentation/pages/plazoletas/
  plazoleta_list_page.dart (~950 líneas)

widgets/plazoleta/
  mall_background.dart        ✅ Ya existe
  mall_world_painter.dart    ✅ Ya existe  
  plazoleta_detail_panel.dart ✅ Ya existe

Fragmentación propuesta:
  plazoleta_list_header.dart    → Header con búsqueda
  plazoleta_map_controls.dart   → Controles del mapa
  plazoleta_empty_state.dart    → Estado vacío/sin resultados
  plazoleta_loading_shimmer.dart → Shimmer de carga
```

#### 9.2 profile_page.dart (936 líneas) ⏳ PENDIENTE

```
lib/presentation/pages/profile/
  profile_page.dart (936 líneas)

widgets/profile/
  profile_bg_painter.dart  ✅ Ya existe
  profile_components.dart ✅ Ya existe
  profile_buttons.dart    ✅ Ya existe
  profile_edit_dialog.dart ✅ Ya existe
  country_picker_dialog.dart ✅ Ya existe

Fragmentación propuesta:
  profile_avatar_section.dart  → Hero del avatar (líneas 299-488)
  profile_info_section.dart   → Sección de información (líneas 681-742)
  profile_actions_section.dart → Sección de acciones (líneas 744-776)
  profile_skeleton.dart      → Estados loading/empty/signed-out
```

#### 9.3 producto_detail_page.dart (917 líneas) ⏳ PENDIENTE

```
lib/presentation/pages/productos/
  producto_detail_page.dart (917 líneas)

widgets/producto/
  producto_bg_painter.dart  ✅ Ya existe
  producto_hero.dart       ✅ Ya existe  
  producto_app_bar.dart    ✅ Ya existe
  producto_info_tab.dart   ✅ Ya existe
  producto_tienda_tab.dart ✅ Ya existe
  producto_valoraciones_tab.dart ✅ Ya existe
  producto_valoracion_dialog.dart ✅ Ya existe

Fragmentación propuesta:
  producto_estadisticas.dart → Helper de stats (registrar vista, visita, etc - líneas 232-399)
  producto_compartir.dart    → Lógica de compartir (líneas 489-532)
  producto_whatsapp.dart     → Lógica WhatsApp (líneas 534-592)
  producto_tienda_helper.dart → Transformación tienda + tienda tap (líneas 594-601)
  producto_valoracion_helper.dart → Crear valoración (líneas 603-668)
  producto_empty_state.dart → Estados loading/empty/error (líneas 725-743)
```

**Resumen Phase 9:**
| Archivo | Líneas actual | Líneas objetivo | Reducción |
|---------|-------------|-----------------|-----------|
| plazoleta_list_page.dart | ~950 | ~500 | 47% |
| profile_page.dart | 936 | ~500 | 47% |
| producto_detail_page.dart | 917 | ~500 | 45% |

---

### Fase 10: Solo Tema ⏳ PENDIENTE

**Archivos que solo necesitan adaptaciones de tema (sin fragmentación significativa):**

| Archivo | Líneas | Estado | Notas |
|---------|--------|--------|-------|
| `soporte_page.dart` | 649 | ❌ | necesita tema |
| `settings_page.dart` | 687 | ❌ | necesita tema |
| `favoritos_page.dart` | 495 | ❌ | necesita tema |
| `splash_page.dart` | 191 | ❌ | necesita tema |

---

## PARTE 6: ORDEN DE IMPLEMENTACIÓN

| Orden | Fase | Archivos | Esfuerzo | Dependencias |
|-------|------|----------|----------|--------------|
| 1 | Fase 1 | Sistema de tema base ✅ | Bajo | Ninguna |
| 2 | Fase 2 | Widgets compartidos ✅ | Bajo | Fase 1 |
| 3 | Fase 3 | plazoleta_list_page + tema ✅ | Alto | Ninguna |
| 4 | Fase 4 | organizacion_list_page + tema ✅ | Medio | Fase 2 |
| 5 | Fase 5 | login_page + tema ✅ | Medio | Ninguna |
| 6 | Fase 6 | profile_page + tema ✅ | Medio | Fase 2 |
| 7 | Fase 7 | tienda/producto detail pages ✅ | Alto | Fase 2 |
| 8 | Fase 8 | plazoleta/organizacion detail + tema ✅ | Alto | Fase 2 |
| 9 | Fase 9 | Más fragmentación (lista/detail) ⏳ | Medio | Fase 2 |
| 10 | Fase 10 | Solo tema (soporte/settings/favoritos/splash) ⏳ | Bajo | Fase 1 |

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

- [x] `app_colors.dart` creado con todos los colores
- [x] `app_theme.dart` creado con light/dark ThemeData
- [x] `main.dart` integrado con tema
- [x] `ThemeProvider` con persistencia
- [x] Toggle en Settings funcionando
- [x] Widgets compartidos refactorizados
- [x] plazoleta_list_page fragmentado ✅
- [x] plazoleta_list_page theme fixes ✅
- [x] organizacion_list_page fragmentado ✅
- [x] organizacion_list_page theme fixes ✅
- [x] login_page fragmentado ✅
- [x] profile_page fragmentado ✅
- [x] tienda_detail_page fragmentado ✅
- [x] tienda_detail_page theme ✅
- [x] producto_detail_page fragmentado ✅
- [x] producto_detail_page theme ✅
- [x] plazoleta_detail_page fragmentado (Fase 8 - COMPLETADA)
- [x] organizacion_detail_page fragmentado (Fase 8 - COMPLETADA)
- [ ] plazoleta_list_page fragmentación adicional (Fase 9 - pendiente)
- [ ] producto_detail_page fragmentación adicional (Fase 9 - pendiente)
- [ ] soporte_page tema (Fase 10 - pendiente)
- [ ] settings_page tema (Fase 10 - pendiente)
- [ ] favoritos_page tema (Fase 10 - pendiente)
- [ ] splash_page tema (Fase 10 - pendiente)
- [ ] Análisis estático sin errores

### Testing Post-Implementación

- [x] Tema cambia al cambiar toggle en Settings
- [x] Tema sigue al sistema cuando está en "Sistema"
- [ ] Navegación de返回 a listas funciona correctamente
- [x] Painters mantienen estética dark
- [x] Widgets usan colores de tema correctamente

---

## ARCHIVOS RELACIONADOS

- `doc/FUNCIONALIDADES_PENDIENTES.md` - Catálogo de funcionalidades pendientes
- `doc/AGENTS.md` - Guía para desarrolladores
- `lib/presentation/providers/theme_provider.dart` - Provider de tema (ya existe)
- `lib/core/theme/` - Directorio para nuevos archivos de tema

---

**Última actualización:** Abril 2026  
**Estado:** Fase 8 Completada, Fases 9-10 Pendientes  
**Responsable:** Equipo de desarrollo
