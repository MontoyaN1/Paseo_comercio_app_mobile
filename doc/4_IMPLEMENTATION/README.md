# 4. Guías de Implementación

Guías técnicas para implementar features específicas.

## Archivos

| Archivo | Descripción |
|---------|-------------|
| [DEEP_LINKS_IMPLEMENTATION.md](./DEEP_LINKS_IMPLEMENTATION.md) | Guía completa para implementar deep links (Firebase App Links / Dynamic Links) |

## Contenido

### Deep Links
Guía paso a paso para configurar deep links que permitan:
- Abrir la app directamente desde links compartidos
- Manejar URLs de tipo `/store/{id}`, `/producto/{id}`, etc.
- Configurar Android App Links y iOS Universal Links

### Opciones de Deep Links

| Opción | Plataforma | Costo | Complejidad |
|--------|-----------|-------|-------------|
| Firebase Dynamic Links | iOS + Android | Gratis hasta 500K/month | Media |
| App Links (Android) | Solo Android | Gratis | Baja |
| Universal Links (iOS) | Solo iOS | Gratis | Baja |

### Pendientes de Documentación

Las siguientes guías serán añadidas según se implementen:
- [ ] Google Maps SDK - Migración de url_launcher a SDK
- [ ] Push Notifications - Configuración de FCM
- [ ] Historial de Visitas - Activación del código existente

---

**Última actualización:** Marzo 2026
