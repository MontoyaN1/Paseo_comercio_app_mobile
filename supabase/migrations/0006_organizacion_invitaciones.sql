-- ============================================================
-- 0006_organizacion_invitaciones.sql
-- Una organización por usuario y una organización por dueño.
-- Limpia duplicados del seed antes de crear los índices únicos.
-- ============================================================

-- 1. Asegurar que cada dueño figure como miembro activo de su organización.
--    rol_id 1 = dueño/anfitrión, rol_id 3 = miembro.
UPDATE miembros_organizacion m
SET rol_id = 1,
    estado = 'Activo'
FROM organizacion o
WHERE o.anfitrion_id = m.usuario_id
  AND o.id = m.organizacion_id;

INSERT INTO miembros_organizacion (
  organizacion_id, usuario_id, email, nombre, rol_id, estado, fecha_aceptacion
)
SELECT o.id, o.anfitrion_id, u.email, u.nombre_completo, 1, 'Activo', now()
FROM organizacion o
JOIN usuario u ON u.id = o.anfitrion_id
WHERE NOT EXISTS (
  SELECT 1
  FROM miembros_organizacion m
  WHERE m.usuario_id = o.anfitrion_id
    AND m.organizacion_id = o.id
);

-- 2. Eliminar membresías duplicadas.
--    Se conserva la organización donde el usuario es dueño.
--    Si no es dueño de ninguna, se conserva la más reciente.
WITH ranked AS (
  SELECT
    m.id,
    ROW_NUMBER() OVER (
      PARTITION BY m.usuario_id
      ORDER BY
        CASE
          WHEN EXISTS (
            SELECT 1
            FROM organizacion o
            WHERE o.anfitrion_id = m.usuario_id
              AND o.id = m.organizacion_id
          ) THEN 0
          ELSE 1
        END,
        m.id DESC
    ) AS rn
  FROM miembros_organizacion m
)
DELETE FROM miembros_organizacion m
USING ranked r
WHERE m.id = r.id
  AND r.rn > 1;

-- 3. Una sola membresía por usuario.
ALTER TABLE miembros_organizacion
  DROP CONSTRAINT IF EXISTS unique_usuario_organizacion;

CREATE UNIQUE INDEX IF NOT EXISTS miembros_organizacion_usuario_unico
  ON miembros_organizacion(usuario_id);

-- 4. Una sola organización por dueño.
CREATE UNIQUE INDEX IF NOT EXISTS organizacion_anfitrion_unico
  ON organizacion(anfitrion_id);

-- 5. Al eliminar una organización, eliminar sus miembros e imágenes.
ALTER TABLE miembros_organizacion
  DROP CONSTRAINT IF EXISTS fk_miembro_organizacion;

ALTER TABLE miembros_organizacion
  ADD CONSTRAINT fk_miembro_organizacion
  FOREIGN KEY (organizacion_id) REFERENCES organizacion(id)
  ON DELETE CASCADE;

ALTER TABLE miembros_organizacion
  DROP CONSTRAINT IF EXISTS fk_miembro_usuario;

ALTER TABLE miembros_organizacion
  ADD CONSTRAINT fk_miembro_usuario
  FOREIGN KEY (usuario_id) REFERENCES usuario(id)
  ON DELETE CASCADE;

ALTER TABLE imagen_organizacion
  DROP CONSTRAINT IF EXISTS imagen_organizacion_organizacion_id_fkey;

ALTER TABLE imagen_organizacion
  ADD CONSTRAINT imagen_organizacion_organizacion_id_fkey
  FOREIGN KEY (organizacion_id) REFERENCES organizacion(id)
  ON DELETE CASCADE;
