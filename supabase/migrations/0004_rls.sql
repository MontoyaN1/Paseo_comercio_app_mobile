-- ============================================================
-- 0004_rls.sql
-- Row Level Security para Paseo del Comercio
--
-- NOTA: La app usa la service_role key de Supabase y se
-- autentica con Firebase Auth (no Supabase Auth). Por lo
-- tanto, las políticas RLS están diseñadas para ser
-- permisivas con el rol `anon` (lectura pública) y el
-- servicio (service_role) ya tiene acceso completo.
--
-- Cuando se migre a Supabase Auth, se reemplazarán las
-- políticas `anon` por `authenticated` con auth.uid().
-- ============================================================

-- ── Lectura pública para tablas de contenido ────────────────

-- usuario: lectura pública (para avatares, nombres en reseñas)
ALTER TABLE usuario ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de usuario"
  ON usuario FOR SELECT
  USING (true);

-- roles: lectura pública
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de roles"
  ON roles FOR SELECT
  USING (true);

-- tienda: lectura pública
ALTER TABLE tienda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de tiendas"
  ON tienda FOR SELECT
  USING (true);

-- producto: lectura pública
ALTER TABLE producto ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de productos"
  ON producto FOR SELECT
  USING (true);

-- categoria: lectura pública
ALTER TABLE categoria ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de categorías"
  ON categoria FOR SELECT
  USING (true);

-- plazoleta: lectura pública
ALTER TABLE plazoleta ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de plazoletas"
  ON plazoleta FOR SELECT
  USING (true);

-- organizacion: lectura pública
ALTER TABLE organizacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de organizaciones"
  ON organizacion FOR SELECT
  USING (true);

-- horario: lectura pública
ALTER TABLE horario ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de horarios"
  ON horario FOR SELECT
  USING (true);

-- valoracion_producto: lectura pública (solo publicadas se filtran en la app)
ALTER TABLE valoracion_producto ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de valoraciones"
  ON valoracion_producto FOR SELECT
  USING (true);

-- miembros_organizacion: lectura pública
ALTER TABLE miembros_organizacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de miembros"
  ON miembros_organizacion FOR SELECT
  USING (true);

-- notificacion: lectura pública (la app filtra por destinatario)
ALTER TABLE notificacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de notificaciones"
  ON notificacion FOR SELECT
  USING (true);

-- imágenes: lectura pública
ALTER TABLE imagen_tienda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de imágenes tienda"
  ON imagen_tienda FOR SELECT
  USING (true);

ALTER TABLE imagen_productos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de imágenes producto"
  ON imagen_productos FOR SELECT
  USING (true);

ALTER TABLE imagen_plazoleta ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de imágenes plazoleta"
  ON imagen_plazoleta FOR SELECT
  USING (true);

ALTER TABLE imagen_organizacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de imágenes organización"
  ON imagen_organizacion FOR SELECT
  USING (true);

ALTER TABLE imagen_valoracion_producto ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de imágenes valoración"
  ON imagen_valoracion_producto FOR SELECT
  USING (true);

-- etiquetas: lectura pública
ALTER TABLE etiqueta_tienda ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de etiquetas tienda"
  ON etiqueta_tienda FOR SELECT
  USING (true);

ALTER TABLE etiqueta_producto ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de etiquetas producto"
  ON etiqueta_producto FOR SELECT
  USING (true);

-- características: lectura pública
ALTER TABLE caracteristicas ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de características"
  ON caracteristicas FOR SELECT
  USING (true);

-- favoritos: lectura pública (la app filtra por usuario)
ALTER TABLE tienda_favorito ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de favoritos tienda"
  ON tienda_favorito FOR SELECT
  USING (true);

ALTER TABLE producto_favorito ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de favoritos producto"
  ON producto_favorito FOR SELECT
  USING (true);

-- contacto y redes de la plataforma: lectura pública
ALTER TABLE contactos_empresa ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de contactos"
  ON contactos_empresa FOR SELECT
  USING (true);

ALTER TABLE redes_sociales ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de redes sociales"
  ON redes_sociales FOR SELECT
  USING (true);

-- interaccion y estadísticas: lectura pública (solo la app escribe)
ALTER TABLE interaccion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de interacciones"
  ON interaccion FOR SELECT
  USING (true);

ALTER TABLE estadisticas_diarias ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lectura pública de estadísticas"
  ON estadisticas_diarias FOR SELECT
  USING (true);

-- ── Escritura con service_role ──────────────────────────────
-- El service_role key BYPASSA RLS automáticamente.
-- No se necesitan políticas de INSERT/UPDATE/DELETE adicionales
-- porque la app usa la service_role key.
--
-- Si en el futuro se migra a Supabase Auth, agregar aquí
-- políticas `authenticated` con condiciones USING/WITH CHECK.
