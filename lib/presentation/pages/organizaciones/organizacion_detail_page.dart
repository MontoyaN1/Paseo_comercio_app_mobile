// lib/presentation/pages/organizaciones/organizacion_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/organizacion.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../presentation/blocs/organizacion/organizacion_bloc.dart';
import '../../../../di/service_locator.dart';
import '../../../../core/routing/app_router.dart';

class OrganizacionDetailPage extends StatefulWidget {
  final int organizacionId;
  final Organizacion? organizacion;

  const OrganizacionDetailPage({
    super.key,
    required this.organizacionId,
    this.organizacion,
  });

  @override
  State<OrganizacionDetailPage> createState() => _OrganizacionDetailPageState();
}

class _OrganizacionDetailPageState extends State<OrganizacionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  late OrganizacionBloc _organizacionBloc;

  @override
  void initState() {
    super.initState();
    // Inicializar con 2 tabs (Información y Tiendas)
    _tabController = TabController(length: 2, vsync: this);
    _organizacionBloc = getIt<OrganizacionBloc>();

    // Cargar datos de la organización
    if (widget.organizacion != null) {
      // Si ya tenemos la organización, cargar tiendas
      _organizacionBloc.add(
        LoadOrganizacionDetail(
          organizacionId: widget.organizacionId,
          organizacion: widget.organizacion!,
          loadTiendas: true,
          loadMiembros: false,
        ),
      );
    } else {
      // Si no tenemos la organización, cargarla primero
      _organizacionBloc.add(
        LoadOrganizacionById(
          organizacionId: widget.organizacionId,
          loadTiendas: true,
          loadMiembros: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    print('=== DISPOSE ORGANIZACION DETAIL ===');
    _tabController.dispose();
    _scrollController.dispose();
    _organizacionBloc.close();
    super.dispose();
  }

  void _onJoinOrganizacion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unirse a organización (pendiente)')),
    );
  }

  void _onShareOrganizacion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartir organización (pendiente)')),
    );
  }

  void _onTiendaTap(BuildContext context, Map<String, dynamic> tienda) {
    final tiendaId = tienda['id'];
    if (tiendaId != null) {
      AppRouter.router.go('/tiendas/$tiendaId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se puede navegar a esta tienda')),
      );
    }
  }

  /// Obtener la URL del logo de la tienda
  String? _getTiendaLogoUrl(Map<String, dynamic> tienda) {
    // Primero verificar si hay imagen_tienda en el objeto
    final imagenes = tienda['imagen_tienda'];

    if (imagenes != null) {
      if (imagenes is List && imagenes.isNotEmpty) {
        // Buscar imagen de tipo 'logo'
        for (final imagen in imagenes) {
          if (imagen is Map<String, dynamic> &&
              imagen['tipo_imagen'] == 'logo') {
            return imagen['url_imagen'] as String?;
          }
        }
        // Si no hay logo, usar la primera imagen
        final primeraImagen = imagenes[0];
        if (primeraImagen is Map<String, dynamic>) {
          return primeraImagen['url_imagen'] as String?;
        }
      } else if (imagenes is Map<String, dynamic>) {
        // Si es un solo objeto en lugar de lista
        return imagenes['url_imagen'] as String?;
      }
    }

    // También verificar si hay logo_url directamente en la tienda
    final logoUrl = tienda['logo_url'] ?? tienda['url_logo'];
    if (logoUrl != null && logoUrl is String && logoUrl.isNotEmpty) {
      return logoUrl;
    }

    return null;
  }

  /// Obtener el nombre de la tienda
  String _getTiendaNombre(Map<String, dynamic> tienda) {
    // Intentar varios campos posibles para el nombre
    final nombre =
        tienda['nombre'] ??
        tienda['nombre_tienda'] ??
        tienda['titulo'] ??
        'Tienda';

    // Si el nombre es muy genérico, agregar ID para diferenciar
    if (nombre == 'Tienda' || nombre == 'Tienda sin nombre') {
      final id = tienda['id'] ?? tienda['tienda_id'];
      if (id != null) {
        return 'Tienda $id';
      }
    }

    return nombre;
  }

  /// Obtener la descripción de la tienda
  String _getTiendaDescripcion(Map<String, dynamic> tienda) {
    final descripcion =
        tienda['descripcion'] ??
        tienda['descripcion_tienda'] ??
        tienda['descripcion_corta'] ??
        'Sin descripción disponible';

    // Limitar la longitud si es muy larga
    if (descripcion.length > 100) {
      return '${descripcion.substring(0, 100)}...';
    }

    return descripcion;
  }

  /// Obtener la categoría de la tienda
  String? _getTiendaCategoria(Map<String, dynamic> tienda) {
    final categoria =
        tienda['categoria'] ??
        tienda['categoria_tienda'] ??
        tienda['tipo'] ??
        tienda['rubro'];

    if (categoria != null && categoria is String && categoria.isNotEmpty) {
      return categoria;
    }

    return null;
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _getDescripcionTipo(TipoOrganizacion tipo) {
    switch (tipo) {
      case TipoOrganizacion.fundacion:
        return 'Fundación';
      case TipoOrganizacion.asociacion:
        return 'Asociación';
      case TipoOrganizacion.cooperativa:
        return 'Cooperativa';
      case TipoOrganizacion.empresa:
        return 'Empresa';
      case TipoOrganizacion.comunidad:
        return 'Comunidad';
      case TipoOrganizacion.otro:
        return 'Otra Organización';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizacionBloc, OrganizacionState>(
      bloc: _organizacionBloc,
      builder: (context, state) {
        // Obtener organización del estado o usar la pasada como parámetro
        Organizacion? organizacion;
        List<dynamic> tiendas = [];
        List<dynamic> miembros = [];

        if (state is OrganizacionDetailLoaded) {
          organizacion = state.organizacion;
          tiendas = state.tiendas ?? [];
          miembros = state.miembros ?? [];
        } else if (widget.organizacion != null) {
          organizacion = widget.organizacion;
        }

        // No necesitamos miembros, así que siempre será lista vacía
        miembros = [];

        // Si no hay organización, mostrar loading
        if (organizacion == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final tipoColor = _getColorFromHex(organizacion.colorTipo);
        final logoUrl = organizacion.logoUrlPrincipal;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 250,
                  floating: false,
                  pinned: true,
                  backgroundColor: tipoColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: tipoColor,
                      child:
                          logoUrl != null
                              ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                              : Center(
                                child: Text(
                                  organizacion!.iconoTipo,
                                  style: const TextStyle(
                                    fontSize: 80,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                    ),
                    title: Text(
                      organizacion!.nombreParaMostrar,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: _onShareOrganizacion,
                    ),
                  ],
                ),
              ];
            },
            body: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: tipoColor,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: tipoColor,
                    tabs: [
                      Tab(icon: Icon(Icons.info), text: 'Información'),
                      Tab(icon: Icon(Icons.store), text: 'Tiendas'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab de Información
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tipo de organización
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: tipoColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getDescripcionTipo(organizacion!.tipo),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: tipoColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Estadísticas
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _HeaderStat(
                                  icon: Icons.store,
                                  value: organizacion!.totalTiendas ?? 0,
                                  label: 'Tiendas',
                                ),
                                _HeaderStat(
                                  icon: Icons.people,
                                  value: organizacion!.totalMiembros ?? 0,
                                  label: 'Miembros',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Descripción
                            if (organizacion!.descripcion != null &&
                                organizacion!.descripcion!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Descripción',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    organizacion!.descripcion!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),

                            // Información de contacto
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información de Contacto',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _InfoItem(
                                  icon: Icons.email,
                                  label: 'Email del anfitrión',
                                  value: organizacion!.emailAnfitrion,
                                ),
                                _InfoItem(
                                  icon: Icons.calendar_today,
                                  label: 'Fecha de creación',
                                  value: organizacion!.tiempoDesdeCreacion,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Tab de Tiendas (datos reales)
                      tiendas.isNotEmpty
                          ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: tiendas.length,
                            itemBuilder: (context, index) {
                              final tienda = tiendas[index];
                              return _TiendaCard(
                                tienda: tienda,
                                onTap:
                                    (tienda) => _onTiendaTap(context, tienda),
                                getLogoUrl: _getTiendaLogoUrl,
                                getNombre: _getTiendaNombre,
                                getDescripcion: _getTiendaDescripcion,
                                getCategoria: _getTiendaCategoria,
                              );
                            },
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay tiendas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Esta organización aún no tiene tiendas asociadas',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _onJoinOrganizacion,
            backgroundColor: tipoColor,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text('Unirse', style: TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.grey[800],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TiendaCard extends StatelessWidget {
  final Map<String, dynamic> tienda;
  final void Function(Map<String, dynamic>) onTap;
  final String? Function(Map<String, dynamic>) getLogoUrl;
  final String Function(Map<String, dynamic>) getNombre;
  final String Function(Map<String, dynamic>) getDescripcion;
  final String? Function(Map<String, dynamic>) getCategoria;

  const _TiendaCard({
    required this.tienda,
    required this.onTap,
    required this.getLogoUrl,
    required this.getNombre,
    required this.getDescripcion,
    required this.getCategoria,
  });

  @override
  Widget build(BuildContext context) {
    final logoUrl = getLogoUrl(tienda);
    final nombre = getNombre(tienda);
    final descripcion = getDescripcion(tienda);
    final categoria = getCategoria(tienda);
    final tieneLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onTap.call(tienda),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      tieneLogo
                          ? Colors.transparent
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        tieneLogo
                            ? Colors.transparent
                            : Colors.blue.withOpacity(0.3),
                    width: tieneLogo ? 0 : 1,
                  ),
                ),
                child:
                    tieneLogo
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            logoUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.store,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                              );
                            },
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store, color: Colors.blue, size: 28),
                              SizedBox(height: 4),
                              Text(
                                nombre.length > 1
                                    ? nombre.substring(0, 1).toUpperCase()
                                    : 'T',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (categoria != null && categoria.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          categoria,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
