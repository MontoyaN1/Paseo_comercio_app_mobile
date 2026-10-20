-- ============================================================
-- 0003_indexes.sql
-- Índices y triggers para Paseo del Comercio
-- ============================================================

-- ── ÍNDICES ─────────────────────────────────────────────────

-- tienda
CREATE INDEX idx_tienda_propietario ON tienda(id_propietario);
CREATE INDEX idx_tienda_nombre ON tienda(nombre_tienda);
CREATE INDEX idx_tienda_visitas ON tienda(total_visitas DESC);
CREATE INDEX idx_tienda_contactos ON tienda(total_contactos_whatsapp DESC);

-- producto
CREATE INDEX idx_producto_visualizaciones ON producto(total_visualizaciones DESC);
CREATE INDEX idx_producto_clicks_whatsapp ON producto(total_clicks_whatsapp DESC);
CREATE INDEX idx_producto_compartidos ON producto(total_compartidos DESC);
CREATE INDEX idx_producto_activo ON producto(estado_producto) WHERE estado_producto = 'activo';

-- organizacion
CREATE INDEX idx_organizacion_anfitrion_id ON organizacion(anfitrion_id);

-- interaccion
CREATE INDEX idx_interaccion_producto_id ON interaccion(producto_id);
CREATE INDEX idx_interaccion_tienda_id ON interaccion(tienda_id);
CREATE INDEX idx_interaccion_tipo ON interaccion(tipo_interaccion);
CREATE INDEX idx_interaccion_fecha ON interaccion(fecha_creacion);
CREATE INDEX idx_interaccion_producto_fecha ON interaccion(producto_id, fecha_creacion);
CREATE INDEX idx_interaccion_sesion ON interaccion(sesion_id);

-- estadisticas_diarias
CREATE INDEX idx_estadisticas_diarias_tienda_fecha ON estadisticas_diarias(tienda_id, fecha DESC);
CREATE INDEX idx_estadisticas_diarias_producto_fecha ON estadisticas_diarias(producto_id, fecha DESC);
CREATE INDEX idx_estadisticas_diarias_fecha ON estadisticas_diarias(fecha DESC);

-- miembros_organizacion
CREATE INDEX idx_miembros_organizacion_id ON miembros_organizacion(organizacion_id);
CREATE INDEX idx_miembros_usuario_id ON miembros_organizacion(usuario_id);
CREATE INDEX idx_miembros_estado ON miembros_organizacion(estado);
CREATE INDEX idx_miembros_email ON miembros_organizacion(email);

-- notificacion
CREATE INDEX idx_notificacion_leida ON notificacion(leida);
CREATE INDEX idx_notificacion_tipo ON notificacion(tipo);
CREATE INDEX idx_notificacion_created_at ON notificacion(created_at DESC);
CREATE INDEX idx_notificacion_referencia ON notificacion(referencia_tipo, referencia_id);
CREATE INDEX idx_notificacion_usuario_fecha ON notificacion(destinatario_id, created_at DESC) WHERE leida = false;

-- imagen_valoracion_producto
CREATE INDEX idx_imagen_valoracion_valoracion_id ON imagen_valoracion_producto(valoracion_id);
CREATE INDEX idx_imagen_valoracion_activa ON imagen_valoracion_producto(activa);
CREATE INDEX idx_imagen_valoracion_orden ON imagen_valoracion_producto(valoracion_id, orden);

-- favoritos
CREATE INDEX idx_tienda_favorito_usuario ON tienda_favorito(usuario_id);
CREATE INDEX idx_tienda_favorito_tienda ON tienda_favorito(tienda_id);
CREATE INDEX idx_producto_favorito_usuario ON producto_favorito(usuario_id);
CREATE INDEX idx_producto_favorito_producto ON producto_favorito(producto_id);

-- imágenes: optimizar consultas de imagen principal
CREATE INDEX idx_imagen_principal ON imagen_tienda(tienda_id, tipo_imagen) WHERE tipo_imagen = 'principal' AND activa = true;
CREATE INDEX idx_tienda_organizacion ON tienda(organizacion_id) WHERE organizacion_id IS NOT NULL;


-- ── TRIGGERS ────────────────────────────────────────────────

-- Actualizar updated_at en miembros_organizacion
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_miembros_organizacion_updated_at
  BEFORE UPDATE ON miembros_organizacion
  FOR EACH ROW
  EXECUTE FUNCTION trigger_set_updated_at();

-- Actualizar fecha_actualizacion en interaccion
CREATE OR REPLACE FUNCTION trigger_set_fecha_actualizacion()
RETURNS TRIGGER AS $$
BEGIN
  NEW.fecha_actualizacion = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_interaccion
  BEFORE UPDATE ON interaccion
  FOR EACH ROW
  EXECUTE FUNCTION trigger_set_fecha_actualizacion();
