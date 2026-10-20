# Generalidades del Proyecto
## Paseo del Comercio — Aplicación Móvil Android (Flutter)
### Centro Comercial Virtual de Santander para compra a nivel nacional

**Asignatura:** Ingeniería de Software — Primer Semestre, Ingeniería de Sistemas
**Proyecto:** `paseo-del-comercio-app-mobile-flutter`
**Versión del documento:** 1.0 — 26/09/2026
**Documento base:** `doc/1_PROJECT/ANALISIS_DE_REQUERIMIENTOS.md`

---

## 1. Nombre del Proyecto

**Paseo del Comercio — Centro Comercial Virtual de Santander (aplicación móvil Android).**

---

## 2. Descripción del proyecto

### 2.1 Visión general del software a desarrollar
Se desarrollará una aplicación móvil para Android (construida con Flutter) que opera como un **centro comercial virtual**: los comerciantes de Santander publican sus tiendas y productos con imágenes, horarios, contacto, ubicación y organización; y los compradores de cualquier ciudad de Colombia los descubren, consultan, guardan en favoritos, valoran y **los compran en línea mediante pasarela de pagos (Wompi), con el dinero ingresando directo a la cuenta de cada emprendedor**.

El sistema se compone de: vitrina digital organizada por plazoletas, tiendas, productos y organizaciones; gestión de cuentas con inicio social; fidelización (favoritos, historial, valoraciones, compartir, notificaciones); carrito de compras y checkout con pago electrónico por tienda; y sincronización con la aplicación web a través de una misma base de datos.

### 2.2 Problema de negocio y técnico que resuelve
**Negocio:** los comerciantes santandereanos —en su mayoría micro y pequeños empresarios— dependen del canal físico y local: su oferta no trasciende el Área Metropolitana de Bucaramanga, no tienen vitrina digital propia y quedan excluidos del comercio electrónico nacional por costo y complejidad técnica. A su vez, los compradores del resto del país no tienen un punto centralizado, confiable y con pago electrónico para descubrir y adquirir productos santandereanos.

**Técnico:** no existe una plataforma común que unifique catálogo, identidad de comercios, contenidos multimedia y pagos por tienda, con experiencia móvil de calidad (funcionamiento con conectividad intermitente, carga rápida de imágenes y notificaciones), ni una arquitectura que permita a un equipo pequeño mantenerla y escalarla.

### 2.3 Beneficios que aportará
- **A comerciantes:** vitrina nacional permanente, recepción de pagos electrónicos sin montar infraestructura propia, visibilidad por plazoleta y organización, estadísticas de interacción con sus productos.
- **A compradores:** catálogo centralizado y confiable, compra con medios locales (tarjetas, PSE, Nequi y demás medios Wompi), seguimiento del estado del pago y atención por canales integrados.
- **A la región:** digitalización del comercio santandereano, ampliación del mercado más allá del AMB y formalización de ventas en línea.
- **Al equipo:** producto construible y mantenible por 4 personas, con costo inicial cercano a cero (capas gratuitas) y base extensible.

### 2.4 Planteamiento del Problema
Los comerciantes de Santander concentran sus ventas en el canal presencial y en redes sociales dispersas, sin catálogo unificado, sin medios de pago electrónicos integrados y sin alcance nacional. Esto limita sus ingresos, los deja fuera del crecimiento del e-commerce colombiano y obliga al comprador a procesos informales (mensajería, consignaciones) con baja confianza. Se requiere una solución móvil que combine vitrina, confianza y pago electrónico por comercio, construible por un equipo universitario pequeño y escalable al nivel nacional.

### 2.5 Pregunta de Investigación
**¿Cómo puede una aplicación móvil Android, con arquitectura limpia y servicios en la nube de bajo costo, permitir que los comerciantes de Santander oferten sus productos y reciban pagos electrónicos directos a nivel nacional, garantizando seguridad, usabilidad y escalabilidad?**

---

## 3. Objetivos del proyecto

### 3.1 Objetivo general
Desarrollar una aplicación móvil para Android que funcione como centro comercial virtual de Santander, permitiendo a los comerciantes ofertar sus productos y a compradores de todo Colombia descubrirlos, adquirirlos y pagarlos en línea con pasarela Wompi por tienda, con una experiencia segura, rápida y disponible aun con conectividad intermitente.

### 3.2 Objetivos específicos
1. **Vitrina y catálogo nacional:** implementar la exploración por plazoletas, tiendas, productos y organizaciones con imágenes, horarios, contacto y valoraciones, alcanzando al cierre del proyecto un catálogo piloto cargado y navegable en menos de 2 segundos por pantalla en red 4G.
2. **Cuentas y confianza:** implementar registro, inicio de sesión (correo, Google y Microsoft), sesión persistente, perfil y modo invitado, con cero caídas en los flujos de autenticación validados en dispositivo.
3. **Comercio electrónico por tienda:** implementar carrito, órdenes y checkout con pasarela Wompi (tarjetas, PSE, Nequi y demás medios habilitados), con firma y confirmación en servidor (webhook), logrando al menos el 95% de pagos de prueba conciliados automáticamente en sandbox.
4. **Calidad móvil y sincronización:** garantizar funcionamiento offline-first con caché local, carga de imágenes con respaldo multi-CDN por debajo de 500 ms, y consistencia total del catálogo con la aplicación web al compartir la misma base de datos.

---

## 4. Justificación y Alcance (Scope)

### 4.1 Justificación: por qué es necesario
- **Económica:** el e-commerce colombiano crece y los comercios santandereanos no participan por falta de plataforma accesible; el proyecto les abre el mercado nacional con recaudo directo a sus cuentas.
- **Social:** formaliza ventas hoy informales, da confianza al comprador (pagos trazables, contratos y habeas data) y visibiliza agremiaciones y organizaciones locales.
- **Técnica:** Flutter + Supabase + Firebase + Wompi permiten a un equipo de 4 entregar un producto real para Android sin backend propio costoso, con seguridad (RLS, secretos en servidor) y escalabilidad serverless.
- **Académica:** ejercita el ciclo completo de ingeniería de software —análisis, diseño, construcción, pruebas y despliegue— sobre un problema real de la región.

### 4.2 Alcance incluido (límites del proyecto)
- Exploración del centro comercial: plazoletas, tiendas, productos y organizaciones con detalle, imágenes, horarios, contactos y mapas.
- Cuentas: registro, login social, sesión persistente, perfil y modo invitado.
- Fidelización: favoritos, historial de visitas, valoraciones, compartir, notificaciones, ajustes y soporte.
- Comercio electrónico: carrito por tienda, órdenes, checkout Wompi por comercio (firma en servidor, webhook de confirmación, consulta de estado), con dinero directo a cada emprendedor.
- Calidad transversal: offline-first, imágenes multi-CDN, deep links, sincronización con la app web vía la misma base de datos.

### 4.3 Fuera de alcance (explícitamente excluido)
- Panel del comerciante / app de emprendedores (crear y administrar tiendas y productos).
- Logística y envíos nacionales, facturación electrónica y devoluciones.
- Chat comprador–vendedor en tiempo real, cupones y programa de puntos.

> La arquitectura y el modelo de datos quedan preparados para incorporar estos módulos en fases posteriores sin rediseño.

*Fin del documento.*
