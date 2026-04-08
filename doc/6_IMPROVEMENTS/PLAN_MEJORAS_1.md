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

## Fase 2: Correcciones UI - Formularios y Cards

### 2.1 Formulario editar teléfono - Layout amontonado
- **Descripción**: Los elementos del formulario de editar teléfono están amontonados.
- **Solución propuesta**: Mover el número de teléfono hacia abajo y quitar el texto redundante debajo.

### 2.2 Formulario editar nombre - Título cortado
- **Descripción**: El título "Editar nombre completo" se corta en pantallas pequeñas.
- **Solución propuesta**: Cambiar a "Editar nombre" y configurar salto de línea para "Nombre" para mejor adaptabilidad.

### 2.3 Card de productos - Información amontonada
- **Descripción**: La card de productos muestra información amontonada.
- **Solución propuesta**: Crear un recuadro dedicado en la parte inferior de la card para mostrar: precio, estado, nombre y botón de favorito (corazón).

### 2.4 Precio sin decimales y con marcador de miles
- **Descripción**: Los precios de productos no muestran decimales ni separadores de miles.
- **Solución propuesta**: Formatear precios con `NumberFormat` para mostrar decimales (ej: 1.000,00) según locale.

---

## Fase 3: Soporte y Branding

### 3.1 Logos de redes sociales incorrectos
- **Descripción**: Los logos de redes sociales en la sección de soporte no son los reales.
- **Solución propuesta**: Reemplazar con los iconos oficiales de cada red social (Facebook, Instagram, WhatsApp, etc.).

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
  - Revisar y optimizar深(deep) rebuilds con `PerformanceOverlay` y `DevTools`
  - Considerar implementar splash screen con logo estático en lugar de GIF
  - Revisar uso de `StreamBuilder` y `FutureBuilder` para evitar rebuilds innecesarios

### 4.2 Implementación progresiva
1. **Medición inicial**: Usar DevTools y `flutter analyze` para identificar cuellos de botella
2. **Optimización de assets**: Comprimir imágenes, convertir GIFs a WebP
3. **Optimización de código**: Agregar `const`, `RepaintBoundary`, evitar rebuilds innecesarios
4. **Testing**: Probar en dispositivos reales de gama baja
5. **Iteración**: Repetir hasta lograr rendimiento aceptable

---

## Fase 5: Reestructuración de Vista de Plazoleta

### 5.1 Orden de tabs
- **Descripción**: El orden actual de tabs en la vista de plazoleta no es óptimo.
- **Solución propuesta**: Cambiar el orden de tabs a: Tiendas → Productos → Información (información de último).

---

## Resumen de Fases

| Fase | Descripción | Prioridad | Complejidad |
|------|-------------|-----------|-------------|
| 1 | UI Críticas (Plazoletas) | Alta | Media |
| 2 | UI Formularios y Cards | Alta | Baja-Media |
| 3 | Soporte y Branding | Media | Baja |
| 4 | Rendimiento Gama Baja | Alta | Alta |
| 5 | Reestructuración tabs | Baja | Baja |

## Notas
- La **Fase 4** (rendimiento) es la más compleja y requiere pruebas exhaustivas en dispositivos reales.
- Se recomienda resolver las fases 1-3 antes de abordar la optimización de rendimiento para tener un baseline claro.
- Las pruebas de rendimiento deben hacerse con dispositivos de gama baja reales, no emuladores.
