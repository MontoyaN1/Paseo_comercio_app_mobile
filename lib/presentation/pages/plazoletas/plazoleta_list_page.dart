// lib/presentation/pages/plazoletas/plazoleta_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../../domain/entities/imagen_base.dart';
import '../../../domain/entities/enums.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';
import '../../widgets/images/resilient_image.dart';
import '../../widgets/common/loading_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';

/// Wrapper para proporcionar el BLoC de plazoletas
class PlazoletaBlocProvider extends StatelessWidget {
  final Widget child;

  const PlazoletaBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlazoletaBloc>(
      create: (context) => getIt<PlazoletaBloc>(),
      child: child,
    );
  }
}

/// Pantalla principal que muestra la lista de plazoletas
class PlazoletaListPage extends StatefulWidget {
  const PlazoletaListPage({super.key});

  @override
  State<PlazoletaListPage> createState() => _PlazoletaListPageState();
}

class _PlazoletaListPageState extends State<PlazoletaListPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar plazoletas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlazoletaBloc>().add(const LoadPlazoletasActivas());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Cargar más datos cuando estamos cerca del final
    if (currentScroll >= maxScroll * 0.8) {
      _loadMorePlazoletas();
    }
  }

  void _loadMorePlazoletas() {
    if (_isLoadingMore) return;

    final state = context.read<PlazoletaBloc>().state;
    if (state is PlazoletaLoaded && state.hasMore) {
      setState(() {
        _isLoadingMore = true;
      });

      context.read<PlazoletaBloc>().add(
        LoadPlazoletasActivas(page: state.currentPage + 1, limit: 20),
      );

      // Resetear flag después de un tiempo
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  void _onRefresh() {
    context.read<PlazoletaBloc>().add(
      const LoadPlazoletasActivas(forceRefresh: true),
    );
  }

  void _onPlazoletaTap(Plazoleta plazoleta) {
    // Navegar a la pantalla de detalle de la plazoleta
    context.go('/plazoletas/${plazoleta.id}');
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      context.read<PlazoletaBloc>().add(
        const LoadPlazoletasActivas(forceRefresh: true),
      );
    } else {
      context.read<PlazoletaBloc>().add(SearchPlazoletas(query: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plazoletas'),
        backgroundColor: const Color(0xFF121212),
        elevation: 6,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PlazoletaSearchDelegate(onSearch: _onSearch),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: BlocConsumer<PlazoletaBloc, PlazoletaState>(
        listener: (context, state) {
          // Manejar estados específicos si es necesario
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
    // Manejar estado inicial - también mostrar loading
    if (state is PlazoletaInitial) {
      return const LoadingState(message: 'Inicializando plazoletas...');
    }

    if (state is PlazoletaLoading) {
      return const LoadingState(message: 'Cargando plazoletas...');
    }

    if (state is PlazoletasActivasLoading) {
      return const LoadingState(message: 'Cargando plazoletas activas...');
    }

    if (state is PlazoletaErrorState) {
      return ErrorState(
        message: state.message,
        actionText: 'Reintentar',
        onActionPressed: () {
          context.read<PlazoletaBloc>().add(
            const LoadPlazoletasActivas(forceRefresh: true),
          );
        },
      );
    }

    if (state is PlazoletaNoResults) {
      return EmptyState(
        message:
            'No se encontraron resultados. Intenta con otros términos de búsqueda.',
        icon: Icons.search_off,
        onActionPressed: () {
          context.read<PlazoletaBloc>().add(const LoadPlazoletasActivas());
        },
        actionText: 'Ver todas las plazoletas',
      );
    }

    if (state is PlazoletaLoaded) {
      if (!state.hasPlazoletas) {
        return EmptyState(
          message:
              'No hay plazoletas disponibles. Pronto agregaremos más plazoletas.',
          icon: Icons.location_city,
          onActionPressed: _onRefresh,
          actionText: 'Recargar',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _onRefresh();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.plazoletas.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.plazoletas.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final plazoleta = state.plazoletas[index];
            return _buildPlazoletaCard(plazoleta, state);
          },
        ),
      );
    }

    if (state is PlazoletaOffline) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Sin conexión a internet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mostrando datos en caché',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (state.hasCachedData && state.cachedPlazoletas != null)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.cachedPlazoletas!.length,
                itemBuilder: (context, index) {
                  final plazoleta = state.cachedPlazoletas![index];
                  return _buildPlazoletaCard(plazoleta, state);
                },
              ),
            )
          else
            const Text('No hay datos en caché'),
        ],
      );
    }

    return const LoadingState(message: 'Inicializando...');
  }

  Widget _buildPlazoletaCard(Plazoleta plazoleta, PlazoletaState state) {
    // Obtener imagen principal si está disponible
    String? imageUrl;
    if (state is PlazoletaLoaded && state.imagenesPlazoleta != null) {
      final imagenPrincipal = state.imagenesPlazoleta!.firstWhere(
        (imagen) =>
            imagen.entidadRelacionadaId == plazoleta.id && imagen.esPrincipal,
        orElse:
            () => state.imagenesPlazoleta!.firstWhere(
              (imagen) => imagen.entidadRelacionadaId == plazoleta.id,
              orElse:
                  () => ImagenPlazoleta(
                    id: 0,
                    urlOriginal: '',
                    nombreArchivo: '',
                    extension: '',
                    tamanoBytes: 0,
                    ancho: 0,
                    alto: 0,
                    tipoImagen: TipoImagen.principal,
                    esPrincipal: true,
                    ordenVisual: 0,
                    fechaCreacion: DateTime.now(),
                    activa: true,
                    plazoletaId: 0,
                  ),
            ),
      );
      imageUrl = imagenPrincipal.urlPreferida;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onPlazoletaTap(plazoleta),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen de la plazoleta
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 180,
                child:
                    imageUrl != null && imageUrl.isNotEmpty
                        ? ResilientImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.location_city,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          errorWidget: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.location_city,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
              ),
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre de la plazoleta
                  Text(
                    plazoleta.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Descripción
                  if (plazoleta.descripcion != null)
                    Text(
                      plazoleta.descripcion!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Información adicional
                  Row(
                    children: [
                      // Ubicación
                      if (plazoleta.piso != null || plazoleta.sector != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plazoleta.resumenUbicacion,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              plazoleta.disponible
                                  ? Colors.green[50]
                                  : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                plazoleta.disponible
                                    ? Colors.green[100]!
                                    : Colors.red[100]!,
                          ),
                        ),
                        child: Text(
                          plazoleta.estadoDescripcion,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                plazoleta.disponible
                                    ? Colors.green[800]
                                    : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Estadísticas
                  Row(
                    children: [
                      // Tiendas
                      _buildStatItem(
                        icon: Icons.store,
                        value: plazoleta.totalTiendas.toString(),
                        label: 'Tiendas',
                      ),

                      const SizedBox(width: 16),

                      // Visitas
                      _buildStatItem(
                        icon: Icons.people,
                        value: plazoleta.totalVisitas.toString(),
                        label: 'Visitas',
                      ),

                      const Spacer(),

                      // Capacidad
                      if (plazoleta.capacidadMaxima != null)
                        _buildStatItem(
                          icon: Icons.space_bar,
                          value:
                              '${plazoleta.totalTiendas}/${plazoleta.capacidadMaxima}',
                          label: 'Capacidad',
                        ),
                    ],
                  ),

                  // Servicios
                  if (plazoleta.serviciosLista.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children:
                              plazoleta.serviciosLista
                                  .take(3)
                                  .map(
                                    (servicio) => Chip(
                                      label: Text(
                                        servicio,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: Colors.blue[50],
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Plazoletas'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // TODO: Implementar filtros específicos
                const Text('Filtros disponibles próximamente...'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Aplicar filtros
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }
}

/// Delegado para búsqueda de plazoletas
class _PlazoletaSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  _PlazoletaSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Mostrar sugerencias basadas en búsquedas anteriores
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Buscar plazoletas por nombre'),
          onTap: () {
            query = 'plazoleta';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text('Buscar por ubicación'),
          onTap: () {
            query = 'piso 1';
            showResults(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.restaurant),
          title: const Text('Zonas de comida'),
          onTap: () {
            query = 'comida';
            showResults(context);
          },
        ),
      ],
    );
  }

  @override
  String get searchFieldLabel => 'Buscar plazoletas...';
}
