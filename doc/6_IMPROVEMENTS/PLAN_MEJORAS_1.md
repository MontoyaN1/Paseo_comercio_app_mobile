# Plan de Mejoras - Paseo del Comercio

## Fase 1: Correcciones UI Críticas (Vista de Plazoletas) ✅ COMPLETADA

### 1.1 Botones de zoom, centrar y recargar amontonados ✅
- **Descripción**: Los botones de control en la vista de plazoletas se superponen en diferentes resoluciones.
- **Solución implementada**: Cambiado `Row` por `Wrap` en `plazoleta_list_map_controls.dart` para adaptar la posición de los botones según el espacio disponible.
- **Archivos modificados**: `lib/presentation/widgets/plazoleta/list/plazoleta_list_map_controls.dart`

### 1.2 Botón centrar no funciona correctamente ✅
- **Descripción**: El botón de centrar en la vista de plazoletas no realiza el centrado adecuado del mapa.
- **Solución implementada**: Corregida la lógica de `_resetView()` para usar `pan.dy = -_kOriginOffsetY` que compensa correctamente el offset isométrico.
- **Archivos modificados**: `lib/presentation/pages/plazoletas/plazoleta_list_page.dart`

### 1.3 Recarga excesiva de la vista de plazoletas ✅
- **Descripción**: La vista se recarga apenas se sale un momento, causando molesta recarga constante.
- **Solución implementada**: Eliminada la recarga automática en `didChangeAppLifecycleState`. El usuario puede hacer pull-to-refresh si quiere actualizar.
- **Archivos modificados**: 
  - `lib/presentation/pages/plazoletas/plazoleta_list_page.dart`
  - `lib/presentation/pages/plazoletas/plazoleta_detail_page.dart`

### 1.4 Optimización de carga de imágenes ✅
- **Descripción**: Las imágenes se cargan sin optimización causando lentitud.
- **Solución implementada**: Agregado `memCacheWidth: 800` a `CachedNetworkImage` para limitar el tamaño en caché.
- **Archivos modificados**: `lib/presentation/widgets/plazoleta/detail/plazoleta_hero.dart`

### 1.5 Imagen principal debe ser la de fondo (no el GIF) ✅
- **Descripción**: Currently se muestra el GIF como imagen principal. En el tab de información se repite la imagen de fondo y el GIF, lo cual es redundante.
- **Solución implementada**: Cambiada la lógica para buscar primero imagen con `tipoImagen == 'plazoleta_productos_fondo'`, luego `esPrincipal`, luego la primera disponible.
- **Archivos modificados**: `lib/presentation/widgets/plazoleta/detail/plazoleta_hero.dart`

---

## Fase 2: Correcciones UI - Formularios y Cards ✅ COMPLETADA

### 2.1 Formulario editar teléfono - Layout amontonado ✅
- **Descripción**: Los elementos del formulario de editar teléfono están amontonados.
- **Solución implementada**: Reestructurado el layout para que el selector de código de país esté arriba y el campo del número debajo. Eliminado el texto explicativo redundante.
- **Archivos modificados**: `lib/presentation/widgets/profile/profile_edit_dialog.dart`

### 2.2 Formulario editar nombre - Título cortado ✅
- **Descripción**: El título "Editar nombre completo" se corta en pantallas pequeñas.
- **Solución implementada**: Cambiado `_displayLabel` de 'Nombre completo' a 'Nombre' para evitar que se corte el título.
- **Archivos modificados**: `lib/presentation/widgets/profile/profile_edit_dialog.dart`

### 2.3 Card de productos - Información amontonada ✅
- **Descripción**: La card de productos muestra información amontonada.
- **Solución implementada**: Creado un recuadro dedicado en la parte inferior de la card con fondo sólido (`_kSurfaceCard`) que contiene: nombre del producto, precio con ShaderMask dorado, rating, y estado del producto (con punto de color).
- **Archivos modificados**: `lib/presentation/widgets/producto/list/producto_card.dart`

### 2.4 Precio sin decimales y con marcador de miles ✅
- **Descripción**: Los precios de productos no deben mostrar decimales y deben tener separadores de miles.
- **Solución implementada**: Agregada función `_formatPrice()` que formatea precios sin decimales con marcador de miles (ej: 1.000, 10.000, 100.000). Reemplazado `toStringAsFixed(2)` por `_formatPrice()` en `_buildFullCard` y `_buildCompactCard`.
- **Archivos modificados**: `lib/presentation/widgets/producto/list/producto_card.dart`

---

## Fase 3: Soporte y Branding ✅ COMPLETADA

### 3.1 Logos de redes sociales incorrectos ✅
- **Descripción**: Los logos de redes sociales en la sección de soporte y en la vista de tienda no son los reales.
- **Solución implementada**: Instalado paquete `simple_icons` para usar iconos oficiales de redes sociales. Actualizados los iconos en soporte_page.dart (WhatsApp, Instagram, TikTok, YouTube) y en tienda_info_tab.dart (Facebook, Instagram, TikTok, YouTube, WhatsApp). LinkedIn y Web usan Material Icons ya que simple_icons no los tiene.
- **Archivos modificados**: 
  - `pubspec.yaml` (añadido simple_icons: ^14.6.1)
  - `lib/presentation/pages/soporte/soporte_page.dart`
  - `lib/presentation/widgets/tienda/detail/tienda_info_tab.dart`

---

## Fase 4: Optimización de Rendimiento (Gama Baja)

### 4.1 Rendimiento lento en dispositivos de 4GB RAM
- **Descripción**: La aplicación tiene problemas de rendimiento severos al iniciar en dispositivos con 4GB RAM y procesadores deficientes.
- **Solución propuesta**:
  - Implementar `flutter build apk --split-per-abi` para generar APKs optimizadas por arquitectura
  - Lazy loading de imágenes pesadas
  - Code splitting: cargar solo módulos necesarios al inicio
  - Optimizar widgets con `const` constructors donde sea posible
  - Implementar `RepaintBoundary` en áreas estáticas
  - Considerar usar `CachedNetworkImage` en lugar de `Image.network`
  - Revisar y optimizar deep rebuilds con `PerformanceOverlay` y `DevTools`
  - Considerar implementar splash screen con logo estático en lugar de GIF
  - Revisar uso de `StreamBuilder` y `FutureBuilder` para evitar rebuilds innecesarios

### 4.2 Implementación progresiva
1. **Medición inicial**: Usar DevTools y `flutter analyze` para identificar cuellos de botella
2. **Optimización de assets**: Comprimir imágenes, convertir GIFs a WebP
3. **Optimización de código**: Agregar `const`, `RepaintBoundary`, evitar rebuilds innecesarios
4. **Testing**: Probar en dispositivos reales de gama baja
5. **Iteración**: Repetir hasta lograr rendimiento aceptable

### 4.3 Análisis Exhaustivo - Problemas Identificados

#### 4.3.1 Image.network sin optimización (5 archivos) ⚠️ ALTO
| Archivo | Líneas | Descripción |
|---------|--------|-------------|
| `lib/presentation/widgets/shared/profile_floating_button.dart` | 166, 391 | `Image.network` sin cache |
| `lib/presentation/widgets/organizacion/detail/organizacion_hero.dart` | 52 | `Image.network` sin cache |
| `lib/presentation/widgets/profile/profile_avatar_hero.dart` | 95 | `Image.network` sin cache |
| `lib/presentation/pages/historial/historial_page.dart` | 468 | `Image.network` sin cache |

**Impacto**: Cada carga de imagen consume memoria sin caché. En gama baja esto causa lentitud severa.
**Solución**: Reemplazar por `CachedNetworkImage` con `memCacheWidth: 800`

#### 4.3.2 Sin RepaintBoundary (0 encontrados) ⚠️ ALTO
**Resultado**: No se usa `RepaintBoundary` en toda la aplicación.

| Ubicación | Problema |
|-----------|----------|
| `splash_page.dart` | Animación compleja que redibuja toda la pantalla |
| `profile_floating_button.dart` | Menú lateral con animaciones que afecta toda la UI |
| `login_page.dart` | CustomPainter con animación continua |
| `custom_app_bar.dart` | StreamBuilder que rebuild toda la AppBar |

**Impacto**: Las animaciones fuerzan redibujados completos innecesarios.
**Solución**: Agregar `RepaintBoundary` en splash_page y login_page

#### 4.3.3 ListView sin lazy loading (2 archivos) ⚠️ ALTO
| Archivo | Línea | Estado |
|---------|-------|--------|
| `lib/presentation/pages/soporte/soporte_page.dart` | 39 | `ListView(` - carga todo de golpe |
| `lib/presentation/pages/settings/settings_page.dart` | 33 | `ListView(` - carga todo de golpe |

**Impacto**: Carga todos los widgets simultáneamente, consumiendo memoria innecesaria.
**Solución**: Convertir a `ListView.builder` para lazy loading

#### 4.3.4 Widgets sin const (4 archivos) ℹ️ BAJO
| Archivo | Líneas | Descripción |
|---------|--------|-------------|
| `lib/presentation/pages/splash/splash_page.dart` | 125, 130, 140, 151, 162-175 | Text y SizedBox sin const |
| `lib/presentation/pages/soporte/soporte_page.dart` | 151-195 | Múltiples Text widgets |
| `lib/presentation/pages/settings/settings_page.dart` | 90-115 | Text y Column widgets |
| `lib/presentation/pages/auth/login_page.dart` | 467, 503 | Text widgets |

**Impacto**: Construcción innecesaria de widgets idénticos.
**Solución**: Agregar `const` donde los valores sean constantes.

#### 4.3.5 StreamBuilder causando rebuilds (3 archivos) ⚠️ MEDIO
| Archivo | Línea | Tipo | Problema |
|---------|-------|------|----------|
| `lib/presentation/widgets/shared/profile_floating_button.dart` | 83 | StreamBuilder | Rebuild completo del FAB |
| `lib/presentation/widgets/shared/custom_app_bar.dart` | 39 | StreamBuilder | Rebuild de toda la AppBar |
| `lib/presentation/pages/auth/login_page.dart` | 30 | StreamBuilder | Rebuild de todo el scaffold |

**Impacto**: Cada cambio de auth fuerza rebuild completo de la UI.
**Solución**: Usar Provider/Selector para evitar rebuilds innecesarios.

#### 4.3.6 Splash screen con animaciones pesadas ⚠️ MEDIO
**Estado actual**: `splash_page.dart` NO usa GIF - usa AnimationController.

| Característica | Valor |
|----------------|-------|
| Animaciones simultáneas | 3 (scale, fade, color) |
| Duración total | ~4.5s (1500ms + 3000ms delay) |
| BackdropFilter | blur pesado en build |
| RepaintBoundary | NO tiene |

**Impacto**: Tiempo de inicio excesivo en gama baja.
**Solución**: Reducir a 2s, usar una sola animación, agregar RepaintBoundary.

---

### 4.4 Resumen de Hallazgos

| # | Problema | Impacto | Facilidad | Prioridad |
|---|----------|---------|-----------|-----------|
| 1 | Image.network -> CachedNetworkImage | ALTO | MEDIA | CRÍTICA |
| 2 | Sin RepaintBoundary | ALTO | FÁCIL | CRÍTICA |
| 3 | ListView -> ListView.builder | ALTO | FÁCIL | CRÍTICA |
| 4 | Widgets sin const | BAJO | FÁCIL | MENOR |
| 5 | StreamBuilder rebuilds | MEDIO | MEDIA | IMPORTANTE |
| 6 | Splash screen 4.5s | MEDIO | FÁCIL | IMPORTANTE |

### 4.5 Recomendaciones de Implementación

**CRÍTICAS (arreglar primero):**
1. Reemplazar `Image.network` por `CachedNetworkImage` con `memCacheWidth: 800`
2. Agregar `RepaintBoundary` en splash_page y login_page
3. Convertir `ListView` → `ListView.builder` en soporte_page y settings_page

**IMPORTANTES:**
4. Agregar `const` a widgets estáticos (texto, iconos)
5. Reducir duración splash de 3s a 2s
6. Separar build methods grandes en widgets pequeños

**NOTA**: Las pruebas de rendimiento deben hacerse con dispositivos de gama baja reales (no emuladores) para validar las optimizaciones.

---

## Fase 5: Reestructuración de Vista de Plazoleta ✅ COMPLETADA

### 5.1 Orden de tabs ✅
- **Descripción**: El orden actual de tabs en la vista de plazoleta no es óptimo.
- **Solución implementada**: Cambiado el orden de tabs a: Tiendas → Productos → Información (información de último).
- **Archivos modificados**: 
  - `lib/presentation/widgets/plazoleta/detail/plazoleta_app_bar.dart`
  - `lib/presentation/pages/plazoletas/plazoleta_detail_page.dart`

---

## Resumen de Fases

| Fase | Descripción | Prioridad | Complejidad | Estado |
|------|-------------|-----------|-------------|--------|
| 1 | UI Críticas (Plazoletas) | Alta | Media | ✅ Completada |
| 2 | UI Formularios y Cards | Alta | Baja-Media | ✅ Completada |
| 3 | Soporte y Branding | Media | Baja | ✅ Completada |
| 4 | Rendimiento Gama Baja | Alta | Alta | Pendiente |
| 5 | Reestructuración tabs | Baja | Baja | ✅ Completada |

## Notas
- La **Fase 4** (rendimiento) es la más compleja y requiere pruebas exhaustivas en dispositivos reales.
- Se recomienda resolver las fases 1-3 antes de abordar la optimización de rendimiento para tener un baseline claro.
- Las pruebas de rendimiento deben hacerse con dispositivos de gama baja reales, no emuladores.
