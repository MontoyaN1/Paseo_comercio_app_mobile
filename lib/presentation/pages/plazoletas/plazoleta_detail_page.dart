// lib/presentation/pages/plazoletas/plazoleta_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/plazoleta.dart';
import '../../../domain/entities/imagen_base.dart';
import '../../../domain/entities/producto.dart';
import '../../../domain/entities/tienda.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';
import '../../widgets/images/resilient_image.dart';
import '../../widgets/common/loading_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/producto/producto_card.dart';
import '../../widgets/tienda/tienda_card.dart';

/// Pantalla de detalle de una plazoleta específica
class PlazoletaDetailPage extends StatefulWidget {
  final int plazoletaId;

  const PlazoletaDetailPage({super.key, required this.plazoletaId});

  @override
  State<PlazoletaDetailPage> createState() => _PlazoletaDetailPageState();
}

class _PlazoletaDetailPageState extends State<PlazoletaDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Cargar datos de la plazoleta al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlazoletaBloc>().add(
        LoadPlazoletaById(id: widget.plazoletaId, forceRefresh: true),
      );
      context.read<PlazoletaBloc>().add(
        LoadImagenesPlazoleta(plazoletaId: widget.plazoletaId),
      );
      context.read<PlazoletaBloc>().add(
        LoadProductosPlazoleta(plazoletaId: widget.plazoletaId),
      );
      context.read<PlazoletaBloc>().add(
        LoadTiendasPlazoleta(plazoletaId: widget.plazoletaId),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  void _onRefresh() {
    context.read<PlazoletaBloc>().add(
      LoadPlazoletaById(id: widget.plazoletaId, forceRefresh: true),
    );
    context.read<PlazoletaBloc>().add(
      LoadImagenesPlazoleta(
        plazoletaId: widget.plazoletaId,
        forceRefresh: true,
      ),
    );

    if (_currentTabIndex == 1) {
      context.read<PlazoletaBloc>().add(
        LoadProductosPlazoleta(
          plazoletaId: widget.plazoletaId,
          forceRefresh: true,
        ),
      );
    } else if (_currentTabIndex == 2) {
      context.read<PlazoletaBloc>().add(
        LoadTiendasPlazoleta(
          plazoletaId: widget.plazoletaId,
          forceRefresh: true,
        ),
      );
    }
  }

  void _onProductoTap(Producto producto) {
    // Navegar a detalle de producto
    context.go('/productos/${producto.id}');
  }

  void _onTiendaTap(Tienda tienda) {
    // Navegar a detalle de tienda
    context.go('/tiendas/${tienda.id}');
  }

  /// Convertir Producto a Map<String, dynamic> para widgets que esperan Map
  Map<String, dynamic> _productoToMap(Producto producto) {
    return {
      'id': producto.id,
      'nombre_producto': producto.nombreProducto,
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'moneda': producto.moneda,
      'categoria_id': producto.categoriaId,
      'estado_producto': producto.estadoProducto.toString(),
      'stock_disponible': producto.stockDisponible,
      'stock_minimo': producto.stockMinimo,
      'stock_maximo': producto.stockMaximo,
      'caracteristicas': producto.caracteristicas,
      'etiquetas': producto.etiquetas,
      'promedio_valoracion': producto.calificacionPromedio,
      'total_valoraciones': producto.totalValoraciones,
      'total_visualizaciones': producto.totalVisualizaciones,
      'total_compartidos': producto.totalCompartidos,
      'total_favoritos': producto.totalFavoritos,
      'fecha_creacion': producto.fechaCreacion,
      'fecha_actualizacion': producto.fechaActualizacion,
      'fecha_publicacion': producto.fechaPublicacion,
      'fecha_eliminacion': producto.fechaEliminacion,
      'destacado': producto.destacado,
      'en_oferta': producto.enOferta,
      'precio_oferta': producto.precioOferta,
      'fecha_inicio_oferta': producto.fechaInicioOferta,
      'fecha_fin_oferta': producto.fechaFinOferta,
      'sku': producto.sku,
      'codigo_barras': producto.codigoBarras,
      'peso': producto.peso,
      'unidad_peso': producto.unidadPeso,
      'dimension_alto': producto.dimensionAlto,
      'dimension_ancho': producto.dimensionAncho,
      'dimension_profundidad': producto.dimensionProfundidad,
      'unidad_dimension': producto.unidadDimension,
      'material': producto.material,
      'color': producto.color,
      'marca': producto.marca,
      'modelo': producto.modelo,
      'garantia_meses': producto.garantiaMeses,
      'instrucciones_uso': producto.instruccionesUso,
      'cuidados': producto.cuidados,
      'tienda_id': producto.tiendaId,
      // Campos que pueden faltar en la entidad pero los widgets los esperan
      'imagenes': [], // Se puede poblar si hay datos disponibles
      'tienda': {}, // Se puede poblar si hay datos disponibles
      'categoria': {}, // Se puede poblar si hay datos disponibles
    };
  }

  /// Convertir Tienda a Map<String, dynamic> para widgets que esperan Map
  Map<String, dynamic> _tiendaToMap(Tienda tienda) {
    return {
      'id': tienda.id,
      'nombre_tienda': tienda.nombreTienda,
      'descripcion': tienda.descripcion,
      'telefono_contacto': tienda.telefonoContacto,
      'email_contacto': tienda.emailContacto,
      'direccion': tienda.direccion,
      'redes_sociales': tienda.redesSociales,
      'fecha_creacion': tienda.fechaCreacion,
      'total_visitas': tienda.totalVisitas,
      'total_contactos_whatsapp': tienda.totalContactosWhatsapp,
      // Campos que pueden faltar en la entidad pero los widgets los esperan
      'logo_url': null,
      'banner_url': null,
      'categoria_tienda': null,
      'estado_tienda': 'activa',
      'fecha_actualizacion': tienda.updatedAt,
      'fecha_aprobacion': null,
      'fecha_suspension': null,
      'plazoleta_id': tienda.organizacionId,
      'usuario_propietario_id': tienda.idPropietario,
      'sitio_web': null,
      'calificacion_promedio': 0.0,
      'total_valoraciones': 0,
      'total_ventas': 0,
      'total_seguidores': 0,
      'total_productos': 0,
      'verificado': false,
      'destacado': false,
      'activo': true,
      'horarios': null,
      'ubicacion': null,
      'radio_entrega': null,
      'costo_envio': null,
      'tiempo_entrega_promedio': null,
      'politicas': null,
      'terminos_condiciones': null,
      'metodos_pago': null,
      'imagenes': [],
      'productos': [],
      'etiquetas': [],
      'categoria': {},
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PlazoletaBloc, PlazoletaState>(
        listener: (context, state) {
          if (state is PlazoletaErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(PlazoletaState state) {
    if (state is PlazoletaDetailLoading) {
      return const LoadingState(message: 'Cargando plazoleta...');
    }

    if (state is PlazoletaDetailError) {
      return ErrorState(
        message: state.message,
        actionText: 'Reintentar',
        onActionPressed: () {
          context.read<PlazoletaBloc>().add(
            LoadPlazoletaById(id: widget.plazoletaId, forceRefresh: true),
          );
        },
      );
    }

    if (state is PlazoletaLoaded && state.plazoletaSeleccionada != null) {
      final plazoleta = state.plazoletaSeleccionada!;
      return _buildPlazoletaDetail(plazoleta, state);
    }

    return const LoadingState(message: 'Cargando...');
  }

  Widget _buildPlazoletaDetail(Plazoleta plazoleta, PlazoletaState state) {
    final imagenes = state is PlazoletaLoaded ? state.imagenesPlazoleta : null;
    final productos =
        state is PlazoletaLoaded ? state.productosPlazoleta : null;
    final tiendas = state is PlazoletaLoaded ? state.tiendasPlazoleta : null;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                plazoleta.nombre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black87,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              background: _buildHeaderImage(imagenes),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implementar compartir
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implementar favoritos
                },
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              plazoleta: plazoleta,
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Información
          _buildInfoTab(plazoleta, imagenes),
          // Tab 2: Productos
          _buildProductosTab(productos),
          // Tab 3: Tiendas
          _buildTiendasTab(tiendas),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(List<ImagenBase>? imagenes) {
    String? imageUrl;

    if (imagenes != null && imagenes.isNotEmpty) {
      final imagenPrincipal = imagenes.firstWhere(
        (imagen) => imagen.esPrincipal,
        orElse: () => imagenes.first,
      );
      imageUrl = imagenPrincipal.urlPreferida;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          ResilientImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.location_city, size: 64, color: Colors.grey),
              ),
            ),
            errorWidget: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
              ),
            ),
          )
        else
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.location_city, size: 64, color: Colors.grey),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(Plazoleta plazoleta, List<ImagenBase>? imagenes) {
    return RefreshIndicator(
      onRefresh: () async {
        _onRefresh();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            if (plazoleta.descripcion != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plazoleta.descripcion!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Ubicación
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plazoleta.resumenUbicacion,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),

            // Estadísticas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estadísticas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      icon: Icons.store,
                      value: plazoleta.totalTiendas.toString(),
                      label: 'Tiendas',
                    ),
                    _buildStatCard(
                      icon: Icons.people,
                      value: plazoleta.totalVisitas.toString(),
                      label: 'Visitas',
                    ),
                    if (plazoleta.capacidadMaxima != null)
                      _buildStatCard(
                        icon: Icons.space_bar,
                        value:
                            '${plazoleta.porcentajeOcupacion.toStringAsFixed(0)}%',
                        label: 'Ocupación',
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),

            // Servicios
            if (plazoleta.serviciosLista.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicios Disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        plazoleta.serviciosLista.map((servicio) {
                          return Chip(
                            label: Text(servicio),
                            backgroundColor: Colors.blue[50],
                            side: BorderSide(color: Colors.blue[100]!),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Características
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Características',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(
                  icon: Icons.accessibility_new,
                  label: 'Acceso para discapacitados',
                  enabled: plazoleta.tieneAccesoDiscapacitados,
                ),
                _buildFeatureItem(
                  icon: Icons.local_parking,
                  label: 'Estacionamiento',
                  enabled: plazoleta.tieneEstacionamiento,
                ),
                _buildFeatureItem(
                  icon: Icons.chair,
                  label: 'Zona de descanso',
                  enabled: plazoleta.tieneZonaDescanso,
                ),
                _buildFeatureItem(
                  icon: Icons.restaurant,
                  label: 'Zona de comida',
                  enabled: plazoleta.tieneZonaComida,
                ),
                const SizedBox(height: 24),
              ],
            ),

            // Más imágenes
            if (imagenes != null && imagenes.length > 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Galería',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imagenes.length,
                      itemBuilder: (context, index) {
                        final imagen = imagenes[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < imagenes.length - 1 ? 8 : 0,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ResilientImage(
                              imageUrl: imagen.urlPreferida,
                              width: 160,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                width: 160,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                              errorWidget: Container(
                                width: 160,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Información adicional
            if (plazoleta.horarioAcceso != null || plazoleta.normasUso != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información Adicional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (plazoleta.horarioAcceso != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Horario de acceso:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(plazoleta.horarioAcceso!),
                        const SizedBox(height: 12),
                      ],
                    ),
                  if (plazoleta.normasUso != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Normas de uso:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(plazoleta.normasUso!),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosTab(List<Producto>? productos) {
    if (productos == null) {
      return const LoadingState(message: 'Cargando productos...');
    }

    if (productos.isEmpty) {
      return EmptyState(
        message:
            'No hay productos disponibles. Esta plazoleta no tiene productos listados',
        icon: Icons.shopping_bag,
        onActionPressed: () {
          context.read<PlazoletaBloc>().add(
            LoadProductosPlazoleta(plazoletaId: widget.plazoletaId),
          );
        },
        actionText: 'Recargar',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlazoletaBloc>().add(
          LoadProductosPlazoleta(
            plazoletaId: widget.plazoletaId,
            forceRefresh: true,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];
          return ProductoCard(
            producto: _productoToMap(producto),
            onTap: () => _onProductoTap(producto),
          );
        },
      ),
    );
  }

  Widget _buildTiendasTab(List<Tienda>? tiendas) {
    if (tiendas == null) {
      return const LoadingState(message: 'Cargando tiendas...');
    }

    if (tiendas.isEmpty) {
      return EmptyState(
        message:
            'No hay tiendas disponibles. Esta plazoleta no tiene tiendas listadas',
        icon: Icons.store,
        onActionPressed: () {
          context.read<PlazoletaBloc>().add(
            LoadTiendasPlazoleta(plazoletaId: widget.plazoletaId),
          );
        },
        actionText: 'Recargar',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PlazoletaBloc>().add(
          LoadTiendasPlazoleta(
            plazoletaId: widget.plazoletaId,
            forceRefresh: true,
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tiendas.length,
        itemBuilder: (context, index) {
          final tienda = tiendas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TiendaCard(
              tienda: _tiendaToMap(tienda),
              onTap: () => _onTiendaTap(tienda),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: enabled ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: enabled ? Colors.black : Colors.grey),
            ),
          ),
          Icon(
            enabled ? Icons.check_circle : Icons.remove_circle,
            color: enabled ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// Delegado para la barra de pestañas persistente
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final Plazoleta plazoleta;

  _TabBarDelegate({required this.tabController, required this.plazoleta});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        tabs: const [
          Tab(icon: Icon(Icons.info), text: 'Información'),
          Tab(icon: Icon(Icons.shopping_bag), text: 'Productos'),
          Tab(icon: Icon(Icons.store), text: 'Tiendas'),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
