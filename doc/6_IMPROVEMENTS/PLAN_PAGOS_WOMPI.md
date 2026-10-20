# Plan de Pagos con Wompi — Opción A (Widget / Links)
## Paseo del Comercio · Centro comercial virtual de Santander

**Fecha:** 25/09/2026
**Estado:** 📋 PLAN APROBADO — pendiente de implementación
**Equipo:** 4 personas (2 Flutter + 1 backend/DevOps + 1 QA)
**Estimación total:** 3–4 semanas a sandbox funcional + 1 semana de pulida

### Decisiones confirmadas
1. **Opción A**: checkout oficial de Wompi (Widget/WebView o link `checkout.wompi.co`), sin UI propia de tarjetas.
2. **Cada emprendedor con su cuenta Wompi**: el dinero entra **directo a la cuenta bancaria de cada tienda**, la plataforma no toca los fondos.
3. **Credenciales por tienda**: solo se necesitan 4 cosas por comercio — **llave pública, llave privada, llave de integridad y URL de eventos (webhook)** apuntando a nuestro backend.
4. **Medios**: todos los que Wompi habilite al comercio (tarjetas, PSE, Nequi, DaviPlata, QR, Bancolombia, efectivo, BNPL) sin código adicional.

---

## Fase 0: Base y cuentas (semana 1, en paralelo al desarrollo)

### 0.1 Cuentas Wompi por tienda piloto
- **Responsable:** QA + backend.
- Cada tienda piloto completa vinculación en Wompi (RUT + cuenta bancaria a su NIT/nombre).
- Del dashboard de cada comercio se copian: `public_key`, `private_key`, `integrity_secret` (sandbox y producción conviven; empezar en **sandbox**).
- En el dashboard de cada comercio se configura la **URL de eventos** → `https://<proyecto>.supabase.co/functions/v1/webhook-wompi`.
- **Criterio de salida:** 2–3 tiendas piloto con llaves sandbox + webhook configurado.

### 0.2 Infra Supabase
- **Responsable:** backend.
- Crear carpeta `supabase/` + `supabase/functions/` en el repo (hoy no existe) y vincular proyecto (`supabase link`).
- Guardar secretos con `supabase secrets set` (nunca en código ni `.env` del repo).
- **Archivos:** `supabase/config.toml`, funciones `firmar-pago`, `consultar-pago`, `webhook-wompi`.

---

## Fase 1: Base de datos (semana 1 — backend)

### 1.1 `tienda_wompi_config` — llaves por tienda (SOLO lectura servidor)
- **Descripción:** guarda las 4 credenciales de cada tienda. Jamás se exponen al cliente.
- Columnas: `id`, `tienda_id` (FK única), `public_key`, `private_key_enc`, `integrity_secret_enc`, `ambiente` (`sandbox|produccion`), `webhook_configurado` (bool), `activa` (bool), timestamps.
- **Seguridad:** RLS que **niega todo acceso** a `anon`/`authenticated`; solo `service_role` (Edge Functions). Cifrado en reposo vía Supabase Vault o columna cifrada.
- **Archivos:** migración SQL en `supabase/migrations/`.

### 1.2 `orden` — pedido del comprador
- **Descripción:** cabecera del pedido antes del pago.
- Columnas: `id`, `usuario_id` (FK), `tienda_id` (FK), `total_centavos` (integer, sin decimales), `moneda` (default `COP`), `estado` (`borrador|pendiente_pago|pagada|rechazada|expirada`), `referencia` (única, ej. `PDC-<tienda>-<timestamp>`), timestamps.
- RLS: el comprador solo ve/crea sus órdenes; la tienda solo lee las suyas.

### 1.3 `pago_wompi` — trazabilidad del pago
- **Descripción:** un registro por intento de pago, fuente de verdad para conciliación.
- Columnas: `id`, `orden_id` (FK), `tienda_id` (FK), `referencia`, `monto_centavos`, `wompi_transaction_id`, `estado` (`PENDING|APPROVED|DECLINED|VOIDED|ERROR`), `metodo_pago` (`CARD|PSE|NEQUI|...`), `ambiente`, `payload_evento` (jsonb del webhook), timestamps.
- RLS: lectura restringida a dueño de la orden y a la tienda; **escritura solo vía service_role**.

---

## Fase 2: Backend — Edge Functions (semanas 1–2 — backend)

### 2.1 `firmar-pago` — crea orden + firma de integridad
- **Descripción:** el único camino para iniciar un pago. La app nunca firma nada.
- Flujo: recibe `orden_id` + `tienda_id` → valida totales contra BD (recalcula del lado servidor, no confía en el cliente) → lee llaves de la tienda desde `tienda_wompi_config` → pide tokens de aceptación al API de Wompi (GET merchant con `private_key`) → genera firma SHA-256 `referencia+monto+moneda+integrity_secret` → crea fila en `pago_wompi` (`PENDING`) → devuelve `{ public_key, firma, referencia, monto, acceptance_token, contratos_urls }`.
- **Archivos:** `supabase/functions/firmar-pago/index.ts`.

### 2.2 `webhook-wompi` — confirma el dinero (fuente de verdad)
- **Descripción:** Wompi notifica cada cambio de estado a esta URL (la que cada comercio pega en su dashboard).
- Flujo: verifica firma SHA-256 del evento con el `events_secret` del comercio → identifica tienda por `public_key`/referencia → actualiza `pago_wompi` + `orden` (`pagada|rechazada`) → dispara `notificacion` al comprador y a la tienda.
- Idempotencia: procesar cada `event_id` una sola vez (constraint único).
- **Archivos:** `supabase/functions/webhook-wompi/index.ts`.

### 2.3 `consultar-pago` — estado bajo demanda
- **Descripción:** la app pregunta el estado (respaldo del webhook por si el usuario cierra el WebView antes de la notificación).
- Flujo: recibe `referencia` → valida que la orden sea del usuario → consulta `GET /transactions/:id` con la privada de la tienda → sincroniza BD → devuelve estado.
- **Archivos:** `supabase/functions/consultar-pago/index.ts`.

---

## Fase 3: App Flutter — carrito y checkout (semanas 2–3 — 2 devs Flutter)

### 3.1 Carrito local (Hive, offline-first)
- **Descripción:** carrito por tienda (un pedido = una tienda, simplifica el ruteo de llaves).
- Entidad `CartItem` (producto, cantidad, precio congelado) + `CartBloc` (agregar, quitar, vaciar, total en centavos).
- Reutiliza patrón de `FavoritoBloc` (reactivo a sesión).
- **Archivos:** `lib/domain/entities/cart_item.dart`, `lib/presentation/blocs/cart/`, `lib/presentation/pages/cart/cart_page.dart`, ruta `/cart` en GoRouter.

### 3.2 Checkout: aceptación legal + pago
- **Descripción:** por ley (habeas data) el usuario debe ver y aceptar los contratos de Wompi antes de pagar.
- Flujo: resumen de orden → checkbox con links de contratos (devueltos por `firmar-pago`) → botón "Pagar" → abre checkout Wompi en WebView (`webview_flutter`, paquete nuevo) con `public_key + firma + referencia + monto` → intercepta `redirect_url` de retorno → cierra y va a resultado.
- **Archivos:** `lib/presentation/pages/checkout/checkout_page.dart`, `lib/presentation/pages/checkout/payment_result_page.dart`, `lib/data/datasources/remote/wompi_datasource.dart` (Dio), `pubspec.yaml` (+ `webview_flutter`).

### 3.3 Estado del pago (webhook + respaldo)
- **Descripción:** la pantalla de resultado no confía solo en el retorno del WebView.
- Flujo: al volver, llama a `consultar-pago`; si sigue `PENDING`, muestra "procesando" y reintenta con backoff; el webhook actualiza en segundo plano y llega notificación push (Firebase Messaging ya integrado).
- **Archivos:** `lib/presentation/blocs/checkout/checkout_bloc.dart`, polling con `connectivity_plus` (ya existe).

---

## Fase 4: Pruebas sandbox + pulida (semana 3–4 — QA + todo el equipo)

### 4.1 Matriz de pruebas (sandbox Wompi, 24/7)
- Tarjeta aprobada / rechazada / fondos insuficientes (datos de prueba oficiales).
- PSE: selección de banco → redirección → retorno aprobado y rechazado.
- Nequi: push de aprobación en sandbox + polling.
- Casos borde: cerrar WebView a mitad del pago, sin internet al retornar, doble webhook (idempotencia), monto manipulado desde cliente (el servidor debe rechazarlo).
- **Criterio de salida:** 0 secretos en código (repetir escaneo tipo GitGuardian), coverage de funciones ≥70%.

### 4.2 Onboarding de comercios (documento + checklist)
- Guía paso a paso para el emprendedor: crear cuenta Wompi → copiar las 4 llaves → pegar URL de eventos → pasar a producción.
- La app de emprendedores (futuro) consumirá el mismo `tienda_wompi_config`.

---

## Roles y cronograma resumido

| Semana | Flutter A | Flutter B | Backend/DevOps | QA |
|---|---|---|---|---|
| 1 | Entidades carrito + `/cart` | Diseño checkout/resultado | Tablas + RLS + `firmar-pago` | Cuentas piloto + matriz de pruebas |
| 2 | `CartBloc` + `cart_page` | WebView checkout + aceptación | `webhook-wompi` + `consultar-pago` | Pruebas sandbox tarjeta/PSE |
| 3 | `CheckoutBloc` + polling | Resultado + notificaciones | Endurecer firmas + logs | Nequi + casos borde + guía comercios |
| 4 | Pulida general (buffer) | Pulida general (buffer) | Paso a producción piloto | Validación final + demo |

## Riesgos y mitigación
- **Llave privada en cliente:** imposible por diseño — solo Edge Functions con `service_role` la leen; RLS bloquea todo lo demás.
- **Webhook no llega / llega doble:** `consultar-pago` como respaldo + constraint de idempotencia por `event_id`.
- **Comercio sin cuenta activa:** checkout deshabilitado por tienda (`activa=false` → botón "contactar por WhatsApp" como hoy).
- **Montos en centavos:** toda la aritmética en enteros (`total_centavos`), sin flotantes.

## Evolución futura (Opción B)
Todo lo construido se reutiliza: `orden`, `pago_wompi`, las 3 funciones y el webhook quedan igual; solo se reemplaza el WebView por formularios propios por medio de pago.

*Fin del plan.*
