-- ============================================================
-- 0005_seed.sql
-- Datos de prueba para Paseo del Comercio
-- Genéricos, sin datos reales de personas.
-- ============================================================

-- ── Roles ───────────────────────────────────────────────────
INSERT INTO roles (rol) VALUES
  ('administrador'),
  ('vendedor'),
  ('cliente');

-- ── Usuarios de prueba ──────────────────────────────────────
INSERT INTO usuario (
  clerk_user_id, firebase_user_id, nombre_completo, email,
  telefono, avatar_url, perfil_publico, estado_usuario, roles_id
) VALUES
  ('seed_admin_001', 'firebase_admin_001', 'Admin Demo',     'admin@paseo.test',    '3000000001', 'https://picsum.photos/seed/admin/200/200',   true, 'activo', 1),
  ('seed_vend_001',  'firebase_vend_001',  'Vendedor Uno',   'vendedor1@paseo.test','3000000002', 'https://picsum.photos/seed/vendedor1/200/200', true, 'activo', 2),
  ('seed_vend_002',  'firebase_vend_002',  'Vendedor Dos',   'vendedor2@paseo.test','3000000003', 'https://picsum.photos/seed/vendedor2/200/200', true, 'activo', 2),
  ('seed_vend_003',  'firebase_vend_003',  'Vendedor Tres',  'vendedor3@paseo.test','3000000004', 'https://picsum.photos/seed/vendedor3/200/200', true, 'activo', 2),
  ('seed_cli_001',   'firebase_cli_001',   'Cliente Uno',    'cliente1@paseo.test', '3000000005', 'https://picsum.photos/seed/cliente1/200/200', true, 'activo', 3),
  ('seed_cli_002',   'firebase_cli_002',   'Cliente Dos',    'cliente2@paseo.test', '3000000006', 'https://picsum.photos/seed/cliente2/200/200', true, 'activo', 3);

-- ── Categorías ──────────────────────────────────────────────
INSERT INTO categoria (nombre, descripcion, activa) VALUES
  ('Ropa y Moda',      'Prendas de vestir y accesorios',   true),
  ('Calzado',          'Zapatos y calzado en general',     true),
  ('Comida Rápida',    'Restaurantes y comida para llevar', true),
  ('Electrónica',      'Dispositivos y gadgets',           true),
  ('Servicios',        'Servicios profesionales',          true),
  ('Hogar y Decoro',   'Artículos para el hogar',          true);

-- ── Plazoletas ──────────────────────────────────────────────
INSERT INTO plazoleta (nombre, descripcion, tipo_ubicacion, slug, categoria_principal_id) VALUES
  ('Plazoleta Norte',  'Zona comercial norte del centro',  'plazoleta', 'plazoleta-norte',  1),
  ('Plazoleta Sur',    'Zona comercial sur del centro',    'plazoleta', 'plazoleta-sur',    3),
  ('Plazoleta Central','Zona principal del centro comercial','plazoleta','plazoleta-central', 4),
  ('Área de Comida',   'Zona gastronómica',                'area_comun','area-comida',      3);

-- ── Imágenes de plazoletas ──────────────────────────────────
INSERT INTO imagen_plazoleta (id_ubicacion, url_imagen, tipo_imagen, orden, alt_text, activa) VALUES
  (1, 'https://picsum.photos/seed/plaz1/800/600', 'principal', 1, 'Plazoleta Norte',     true),
  (2, 'https://picsum.photos/seed/plaz2/800/600', 'principal', 1, 'Plazoleta Sur',       true),
  (3, 'https://picsum.photos/seed/plaz3/800/600', 'principal', 1, 'Plazoleta Central',   true),
  (4, 'https://picsum.photos/seed/plaz4/800/600', 'principal', 1, 'Área de Comida',      true);

-- ── Tiendas ─────────────────────────────────────────────────
INSERT INTO tienda (
  id_propietario, nombre_tienda, descripcion, logo_url,
  email_contacto, telefono_contacto, direccion, organizacion_id
) VALUES
  (2, 'Moda Norte',   'Ropa y accesorios de tendencia',   'https://picsum.photos/seed/tienda1/200/200',
   'modanorte@paseo.test',  '3001110001', 'Calle 10 #5-20, Plazoleta Norte', NULL),
  (3, 'Tech Sur',     'Electrónica y gadgets modernos',   'https://picsum.photos/seed/tienda2/200/200',
   'techsur@paseo.test',    '3001110002', 'Calle 15 #8-30, Plazoleta Sur',   NULL),
  (4, 'La Esquina',   'Comida rápida y snacks',           'https://picsum.photos/seed/tienda3/200/200',
   'laesquina@paseo.test',  '3001110003', 'Calle 12 #6-15, Área de Comida',  NULL);

-- ── Imágenes de tiendas ─────────────────────────────────────
INSERT INTO imagen_tienda (tienda_id, url_imagen, tipo_imagen, orden, alt_text, activa) VALUES
  (1, 'https://picsum.photos/seed/tienda1/800/600', 'principal', 1, 'Moda Norte - Principal', true),
  (1, 'https://picsum.photos/seed/tienda1b/800/600', 'galeria',  2, 'Moda Norte - Interior',  true),
  (2, 'https://picsum.photos/seed/tienda2/800/600', 'principal', 1, 'Tech Sur - Principal',   true),
  (3, 'https://picsum.photos/seed/tienda3/800/600', 'principal', 1, 'La Esquina - Principal', true);

-- ── Horarios (lunes a sábado 8:00–18:00, domingo cerrado) ──
INSERT INTO horario (tienda_id, dia_semana, apertura, cierre, cerrado) VALUES
  -- Tienda 1
  (1, 0, NULL,        NULL,        true),  -- domingo cerrado
  (1, 1, '08:00',     '18:00',     false),
  (1, 2, '08:00',     '18:00',     false),
  (1, 3, '08:00',     '18:00',     false),
  (1, 4, '08:00',     '18:00',     false),
  (1, 5, '08:00',     '18:00',     false),
  (1, 6, '09:00',     '16:00',     false),
  -- Tienda 2
  (2, 0, NULL,        NULL,        true),
  (2, 1, '09:00',     '19:00',     false),
  (2, 2, '09:00',     '19:00',     false),
  (2, 3, '09:00',     '19:00',     false),
  (2, 4, '09:00',     '19:00',     false),
  (2, 5, '09:00',     '20:00',     false),
  (2, 6, '10:00',     '16:00',     false),
  -- Tienda 3
  (3, 0, '10:00',     '15:00',     false),
  (3, 1, '07:00',     '20:00',     false),
  (3, 2, '07:00',     '20:00',     false),
  (3, 3, '07:00',     '20:00',     false),
  (3, 4, '07:00',     '20:00',     false),
  (3, 5, '07:00',     '21:00',     false),
  (3, 6, '08:00',     '18:00',     false);

-- ── Productos ───────────────────────────────────────────────
INSERT INTO producto (
  tienda_id, categoria_id, nombre, descripcion, precio_base,
  cantidad, calificacion_promedio, total_valoracion, estado_producto
) VALUES
  -- Moda Norte (tienda 1) → categoría 1 (Ropa)
  (1, 1, 'Camisa Polo Clásica',     'Camisa polo de algodón, varios colores',        45000, 50, 4.5, 2, 'activo'),
  (1, 1, 'Jeans Slim Fit',          'Pantalón jeans ajustado, talla 28-38',          89000, 30, 4.0, 1, 'activo'),
  (1, 1, 'Chaqueta Bomber',         'Chaqueta bomber acolchada, talla S-XL',        120000, 15, NULL, 0, 'activo'),
  -- Tech Sur (tienda 2) → categoría 4 (Electrónica)
  (2, 4, 'Audífonos Bluetooth',     'Audífonos inalámbricos con cancelación de ruido', 75000, 40, 4.7, 3, 'activo'),
  (2, 4, 'Cable USB-C 2m',          'Cable de carga rápida USB-C reforzado',         15000, 100, 4.2, 1, 'activo'),
  (2, 4, 'Funda Protectora',        'Funda antimanchas para celular',                25000, 80, NULL, 0, 'activo'),
  (2, 4, 'Power Bank 10000mAh',     'Batería externa con carga rápida',              55000, 25, 4.8, 2, 'activo'),
  -- La Esquina (tienda 3) → categoría 3 (Comida Rápida)
  (3, 3, 'Hamburguesa Clásica',     'Hamburguesa con carne, lechuga, tomate y pan',  18000, 999, 4.6, 4, 'activo'),
  (3, 3, 'Papas Fritas Grandes',    'Porción grande de papas fritas con aderezo',    10000, 999, 4.3, 2, 'activo'),
  (3, 3, 'Gaseosa 400ml',           'Gaseosa personal 400ml',                        5000, 999, NULL, 0, 'activo'),
  (3, 3, 'Combo Almuerzo',          'Hamburguesa + papas + gaseosa',                 25000, 999, 4.9, 3, 'activo'),
  (3, 3, 'Jugo Natural 500ml',      'Jugo de naranja o maracuyá natural',            8000, 999, 4.1, 1, 'activo');

-- ── Imágenes de productos ───────────────────────────────────
INSERT INTO imagen_productos (id_producto, url_imagen, tipo_imagen, orden, alt_text, activa) VALUES
  (1,  'https://picsum.photos/seed/prod1/600/600', 'principal', 1, 'Camisa Polo',       true),
  (2,  'https://picsum.photos/seed/prod2/600/600', 'principal', 1, 'Jeans Slim Fit',    true),
  (3,  'https://picsum.photos/seed/prod3/600/600', 'principal', 1, 'Chaqueta Bomber',   true),
  (4,  'https://picsum.photos/seed/prod4/600/600', 'principal', 1, 'Audífonos',         true),
  (5,  'https://picsum.photos/seed/prod5/600/600', 'principal', 1, 'Cable USB-C',       true),
  (6,  'https://picsum.photos/seed/prod6/600/600', 'principal', 1, 'Funda',             true),
  (7,  'https://picsum.photos/seed/prod7/600/600', 'principal', 1, 'Power Bank',        true),
  (8,  'https://picsum.photos/seed/prod8/600/600', 'principal', 1, 'Hamburguesa',       true),
  (9,  'https://picsum.photos/seed/prod9/600/600', 'principal', 1, 'Papas Fritas',      true),
  (10, 'https://picsum.photos/seed/prod10/600/600','principal', 1, 'Gaseosa',           true),
  (11, 'https://picsum.photos/seed/prod11/600/600','principal', 1, 'Combo Almuerzo',    true),
  (12, 'https://picsum.photos/seed/prod12/600/600','principal', 1, 'Jugo Natural',      true);

-- ── Valoraciones ────────────────────────────────────────────
INSERT INTO valoracion_producto (producto_id, usuario_id, calificacion, comentario, estado_valoracion) VALUES
  (1,  5, 5, 'Excelente calidad, muy recomendada',          'publicado'),
  (1,  6, 4, 'Buena pero el tallaje es pequeño',           'publicado'),
  (2,  5, 4, 'Cómodos y buen precio',                      'publicado'),
  (4,  5, 5, 'Excelente cancelación de ruido',             'publicado'),
  (4,  6, 5, 'Los mejores audífonos que he tenido',        'publicado'),
  (4,  6, 4, 'Buen sonido pero algo grandes',              'publicado'),
  (7,  5, 5, 'Carga rápido, dura mucho',                   'publicado'),
  (8,  5, 5, 'La mejor hamburguesa del centro',            'publicado'),
  (8,  6, 4, 'Rica pero un poco cara',                     'publicado'),
  (8,  6, 5, 'Porción generosa y deliciosa',               'publicado'),
  (11, 5, 5, 'El combo vale mucho la pena',                'publicado'),
  (12, 6, 4, 'Jugo fresco y natural',                      'publicado');

-- ── Organizaciones ──────────────────────────────────────────
INSERT INTO organizacion (anfitrion_id, nombre, descripcion, email_anfitrion, tipo, logo_url) VALUES
  (2, 'Gremio Comercial Norte', 'Agrupación de comerciantes de la zona norte', 'gremio@paseo.test', 'asociacion', 'https://picsum.photos/seed/org1/200/200'),
  (3, 'Asociación Tech Sur',    'Asociación de negocios de electrónica',       'techsur@paseo.test', 'asociacion', 'https://picsum.photos/seed/org2/200/200');

-- ── Miembros de organizaciones ──────────────────────────────
INSERT INTO miembros_organizacion (organizacion_id, usuario_id, email, nombre, rol_id, estado, fecha_aceptacion) VALUES
  (1, 2, 'vendedor1@paseo.test', 'Vendedor Uno',  1, 'Activo', now()),
  (2, 3, 'vendedor2@paseo.test', 'Vendedor Dos',  1, 'Activo', now()),
  (2, 4, 'vendedor3@paseo.test', 'Vendedor Tres', 3, 'Activo', now());

-- ── Etiquetas de tiendas ────────────────────────────────────
INSERT INTO etiqueta_tienda (tienda_id, nombre, icono, color) VALUES
  (1, 'Moda',        'checkroom', '#E91E63'),
  (1, 'Popular',     'star',      '#FFC107'),
  (2, 'Tech',        'devices',   '#2196F3'),
  (2, 'Nuevo',       'fiber_new', '#4CAF50'),
  (3, 'Comida',      'restaurant', '#FF5722'),
  (3, 'Económico',   'savings',   '#8BC34A');

-- ── Etiquetas de productos ──────────────────────────────────
INSERT INTO etiqueta_producto (producto_id, nombre, color, icono) VALUES
  (1,  'Nuevo',      '#4CAF50', 'fiber_new'),
  (4,  'Oferta',     '#FF9800', 'local_offer'),
  (8,  'Popular',    '#FFC107', 'star'),
  (11, 'Combo',      '#9C27B0', 'combo'),
  (11, 'Recomendado','#E91E63', 'thumb_up');

-- ── Contactos de la plataforma ──────────────────────────────
INSERT INTO contactos_empresa (nombre, valor, url_icono) VALUES
  ('Soporte',      'soporte@pasedelcomercio.com',  NULL),
  ('WhatsApp',     '+57 300 000 0000',             NULL),
  ('Teléfono',     '+57 601 000 0000',             NULL);

-- ── Redes sociales de la plataforma ─────────────────────────
INSERT INTO redes_sociales (nombre, link_red, url_icono) VALUES
  ('Instagram', 'https://instagram.com/pasedelcomercio', NULL),
  ('Facebook',  'https://facebook.com/pasedelcomercio',  NULL);
