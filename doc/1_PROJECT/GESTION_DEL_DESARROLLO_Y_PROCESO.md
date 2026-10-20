# Gestión del Desarrollo y Proceso
## Paseo del Comercio — Aplicación Móvil Android (Flutter)

**Asignatura:** Ingeniería de Software — Primer Semestre, Ingeniería de Sistemas
**Proyecto:** `paseo-del-comercio-app-mobile-flutter`
**Versión del documento:** 1.0 — 26/09/2026
**Fase:** Planeación del proyecto

---

## 1. Metodología de desarrollo

### 1.1 Marco de trabajo: SCRUM
Se adopta **Scrum** como marco ágil por las necesidades del equipo: 4 estudiantes, entregas parciales demostrables cada 2 semanas, requisitos que evolucionan (vitrina → pagos → notificaciones) y necesidad de retroalimentación temprana del docente/cliente.

| Elemento Scrum | Definición en este proyecto |
|---|---|
| Sprint | 2 semanas (Sprint 0 de 1 semana para arranque) |
| Daily Scrum | 15 min, 3 veces por semana (lun/mié/vie, virtual) |
| Sprint Planning | Inicio de cada sprint (2 h): se compromete el backlog |
| Sprint Review | Fin de cada sprint: demo funcional en dispositivo |
| Sprint Retrospective | Fin de cada sprint (45 min): 1 mejora de proceso |
| Incremento | App instalable (APK) + backend desplegado en sandbox |

### 1.2 Roles (equipo de 4)
| Rol | Responsable | Responsabilidades |
|---|---|---|
| Product Owner | Integrante 1 | Backlog priorizado, criterios de aceptación, validación con docente, UX/soporte |
| Scrum Master | Rotativo cada sprint | Facilitar eventos, remover impedimentos, tablero al día |
| Developers (2) | Integrantes 2 y 3 | App Flutter: UI, BLoCs, integración con Supabase/Wompi |
| Backend/DevOps + QA | Integrante 4 | Supabase (tablas, RLS, Edge Functions), CI, plan de pruebas y validación en dispositivo |

### 1.3 Lenguaje de programación
| Capa | Lenguaje | Justificación |
|---|---|---|
| App móvil | **Dart (Flutter 3.7+)** | Un código para Android (alcance actual); tipado nulo-seguro; ecosistema de paquetes verificado |
| Backend serverless | **TypeScript (Deno, Edge Functions)** | Mismo lenguaje que la referencia IMEBU en producción; firma y webhook cerca de la BD |
| Base de datos | **SQL (PostgreSQL/Supabase)** | Modelo relacional del centro comercial; RLS y triggers |

### 1.4 Herramientas de gestión
Backlog y tablero Kanban por sprint (GitHub Projects), control de versiones Git por ramas (`main`, `development`, `feature/*`), Definition of Done: código revisado + pruebas en dispositivo + sin secretos en el repo (lección del incidente GitGuardian).

---

## 2. Cronograma y Planificación

### 2.1 Calendario de sprints (28/09/2026 → 21/11/2026)
| Sprint | Fechas | Objetivo | Hito |
|---|---|---|---|
| Sprint 0 | 28/09 – 03/10 | Arranque: repos, Supabase, backlog, diseño base | M0: entorno listo |
| Sprint 1 | 05/10 – 17/10 | Cuentas + vitrina (plazoletas, tiendas) | — |
| Sprint 2 | 19/10 – 31/10 | Productos, organizaciones, fidelización, calidad móvil | **M1: vitrina navegable** |
| Sprint 3 | 02/11 – 14/11 | BD pagos + Edge Functions + carrito + checkout + webhook | **M2: pago E2E en sandbox** |
| Sprint 4 (cierre) | 16/11 – 21/11 | Notificaciones esenciales + pruebas E2E + entrega | **M3/M4: entrega final 21/11** |

### 2.2 Estructura de Desglose del Trabajo (EDT)
```
1. Gestión del proyecto
   1.1 Configuración Scrum (roles, tablero, DoD)
   1.2 Backlog y priorización por sprint
   1.3 Seguimiento (dailies, reviews, retros)
2. Vitrina y catálogo
   2.1 Autenticación y cuentas (email, Google, Microsoft, invitado, perfil)
   2.2 Plazoletas, tiendas, productos y organizaciones (lista + detalle)
   2.3 Fidelización (favoritos, historial, valoraciones, compartir, notificaciones base)
   2.4 Calidad móvil (offline-first Hive, imágenes multi-CDN, deep links, temas)
3. Comercio electrónico (Wompi por tienda)
   3.1 Tablas orden, pago/transacción, credenciales por tienda (+ RLS)
   3.2 Edge Functions: firmar-pago, webhook-wompi, consultar-pago
   3.3 Carrito (Hive) + checkout WebView + aceptación habeas data
   3.4 Conciliación, estados y reintentos
4. Notificaciones push
   4.1 Centro in-app (tabla notificacion)
   4.2 Push FCM (tokens, envío servidor, deep link al pedido)
5. Release y entrega
   5.1 Pruebas E2E en dispositivo + matriz sandbox
   5.2 Firma release, Play Store (pista interna) y documentación
   5.3 Sustentación y acta de entrega
```

### 2.3 Hitos críticos y dependencias
M1 depende de 2.x; M2 depende de 3.1→3.2→3.3 en orden (no se puede cobrar sin firmar en servidor); M3/M4 dependen de M2 (el push nace del webhook). Ruta crítica: **3.1 → 3.2 → 3.3 → 3.4 → 4.2 → 5.1**.

> Cronograma comprimido al 21/11 (8 semanas, sin buffer): el Sprint 4 ejecuta en paralelo notificaciones esenciales, E2E y entrega; cualquier desvío en la ruta crítica se absorbe recortando alcance de notificaciones (push transaccional mínimo) antes que mover la fecha.

---

## 3. Presupuesto y Recursos

### 3.1 Costos financieros (COP, estimados)
| Concepto | Costo | Observación |
|---|---|---|
| Supabase (hosting, plan gratis) | $0 | 500 MB BD, 500 mil invocaciones/mes: suficiente |
| Firebase (Spark) + FCM | $0 | Auth y push sin costo a esta escala |
| Wompi sandbox | $0 | Solo comisión por transacción aprobada en producción |
| Cloudflare R2 / Storage | $0 | Capas gratuitas |
| Cuenta Google Play Console | ~$105.000 (USD 25, pago único) | Obligatoria para publicar y App Links |
| Reserva de imprevistos | $100.000 | Dominios, pruebas, transporte a sustentación |
| **Total estimado** | **~$205.000** | Talento humano estudiantil no remunerado |

### 3.2 Infraestructura tecnológica
Estaciones de los 4 integrantes + 1 dispositivo Android físico para pruebas (mínimo), cuentas Supabase/Firebase/Wompi sandbox, GitHub, tablero del sprint. Sin servidores propios (todo serverless administrado).

### 3.3 Talento humano y dedicación
4 estudiantes × ~10 h/semana × 8 semanas ≈ **320 horas-persona**. Distribución: 40% desarrollo Flutter, 25% backend/Supabase, 15% QA en dispositivo, 10% gestión/documentación, 10% reserva (dentro de cada sprint, sin buffer final).

*Fin del documento.*
