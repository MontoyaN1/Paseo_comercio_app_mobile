-- ============================================================
-- 0001_enums.sql
-- Tipos personalizados (enums) para Paseo del Comercio
-- ============================================================

-- Roles del sistema (simplificado según RF-01 a RF-12)
CREATE TYPE tipo_rol AS ENUM ('administrador', 'vendedor', 'cliente');

-- Tipo de horario de una tienda
CREATE TYPE tipo_horario AS ENUM ('normal', 'especial', 'festivo');

-- Clasificación de imágenes según su uso
CREATE TYPE tipo_imagen AS ENUM ('principal', 'secundaria', 'galeria', 'logo', 'banner');

-- Categoría de organización
CREATE TYPE tipo_organizacion AS ENUM ('fundacion', 'asociacion', 'cooperativa', 'empresa', 'comunidad', 'otro');

-- Tipo de ubicación física
CREATE TYPE tipo_ubicacion AS ENUM ('plazoleta', 'pasillo', 'area_comun', 'exterior');

-- Estado de disponibilidad de un producto
CREATE TYPE estado_producto AS ENUM ('activo', 'inactivo', 'agotado', 'descontinuado');

-- Estado de la cuenta de usuario
CREATE TYPE estado_usuario AS ENUM ('activo', 'inactivo', 'suspendido', 'eliminado');

-- Estado de moderación de una valoración
CREATE TYPE estado_valoracion AS ENUM ('publicado', 'pendiente', 'rechazado', 'eliminado');
