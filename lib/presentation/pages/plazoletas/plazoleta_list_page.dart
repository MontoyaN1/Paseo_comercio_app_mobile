// lib/presentation/pages/plazoletas/plazoleta_list_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../../domain/entities/imagen_base.dart';
import '../../../domain/entities/enums.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';

import '../../widgets/common/loading_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';

/// Wrapper para proporcionar el BLoC de plazoletas
class PlazoletaBlocProvider extends StatelessWidget {
  final Widget child;

  const PlazoletaBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlazoletaBloc>.value(
      value: getIt<PlazoletaBloc>(),
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
      if (mounted) {
        try {
          final bloc = context.read<PlazoletaBloc>();
          if (!bloc.isClosed) {
            bloc.add(const LoadPlazoletasActivas());
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error loading plazoletas: $e');
          }
        }
      }
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
      appBar: ListAppBar(
        title: 'Plazoletas',
        showSearchButton: true,
        onSearchPressed: () {
          showSearch(
            context: context,
            delegate: _PlazoletaSearchDelegate(onSearch: _onSearch),
          );
        },
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros
              // _showFilterDialog(); // Método movido a la clase correcta
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
    print(
      '🎯 _buildPlazoletaCard llamado para plazoleta ${plazoleta.id} (${plazoleta.nombre})',
    );
    print('🎯 Estado: ${state.runtimeType}');
    if (state is PlazoletaLoaded) {
      print(
        '🎯 imagenesPlazoleta: ${state.imagenesPlazoleta?.length ?? 0} imágenes',
      );
      if (state.imagenesPlazoleta != null) {
        for (var img in state.imagenesPlazoleta!.where(
          (i) => i.entidadRelacionadaId == plazoleta.id,
        )) {
          print(
            '🎯   Imagen: id=${img.id}, plazoletaId=${img.entidadRelacionadaId}, esPrincipal=${img.esPrincipal}, url=${img.urlPreferida}, tipoImagen=${img.tipoImagen}',
          );
        }
      }
    }

    // Obtener imagen principal si está disponible
    String? imageUrl;
    ImagenBase? imagenPrincipalObj;
    if (state is PlazoletaLoaded && state.imagenesPlazoleta != null) {
      print('🎯 Buscando imagen principal para plazoleta ${plazoleta.id}');
      final foundImagenPrincipal = state.imagenesPlazoleta!.firstWhere(
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
      imagenPrincipalObj = foundImagenPrincipal;
      print(
        '🎯 Imagen encontrada: id=${imagenPrincipalObj.id}, urlOriginal=${imagenPrincipalObj.urlOriginal}, urlPreferida=${imagenPrincipalObj.urlPreferida}',
      );
      print('🎯 Es imagen dummy? ${imagenPrincipalObj.id == 0 ? 'SÍ' : 'NO'}');
      imageUrl = imagenPrincipalObj.urlPreferida;
    }

    // Si no se encontró imagen principal, intentar usar el icono de la plazoleta
    if (imageUrl == null || imageUrl.isEmpty) {
      print(
        '🎯 No se encontró imagen principal, usando icono: ${plazoleta.icono}',
      );
      imageUrl = plazoleta.icono;
    }

    // Debug: log image URL
    print(
      '🔍 Plazoleta ${plazoleta.id} (${plazoleta.nombre}) - imageUrl: $imageUrl',
    );
    if (imageUrl != null && imageUrl.isNotEmpty) {
      print('🔍 URL tipo: ${imageUrl.endsWith('.gif') ? 'GIF' : 'Imagen'}');
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
                        ? _buildMultiFallbackImage(imageUrl, plazoleta, state)
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

  Widget _buildMultiFallbackImage(
    String primaryUrl,
    Plazoleta plazoleta,
    PlazoletaState state,
  ) {
    return _MultiFallbackImage(
      primaryUrl: primaryUrl,
      plazoleta: plazoleta,
      state: state,
    );
  }
}

class _MultiFallbackImage extends StatefulWidget {
  final String primaryUrl;
  final Plazoleta plazoleta;
  final PlazoletaState state;

  const _MultiFallbackImage({
    required this.primaryUrl,
    required this.plazoleta,
    required this.state,
  });

  @override
  State<_MultiFallbackImage> createState() => __MultiFallbackImageState();
}

class __MultiFallbackImageState extends State<_MultiFallbackImage> {
  List<String> _urlsToTry = [];
  int _currentUrlIndex = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _generateFallbackUrls();
  }

  void _generateFallbackUrls() {
    _urlsToTry.clear();

    // 1. Add primary URL (HTTPS)
    _urlsToTry.add(widget.primaryUrl);

    // 2. Add HTTP version if primary is HTTPS
    if (widget.primaryUrl.startsWith('https://')) {
      final httpUrl = widget.primaryUrl.replaceFirst('https://', 'http://');
      _urlsToTry.add(httpUrl);
    }

    // 3. Try to get variant URLs from the imagen object
    if (widget.state is PlazoletaLoaded) {
      final loadedState = widget.state as PlazoletaLoaded;
      if (loadedState.imagenesPlazoleta != null) {
        final imagenPrincipal = loadedState.imagenesPlazoleta!.firstWhere(
          (imagen) =>
              imagen.entidadRelacionadaId == widget.plazoleta.id &&
              imagen.esPrincipal,
          orElse:
              () => loadedState.imagenesPlazoleta!.firstWhere(
                (imagen) => imagen.entidadRelacionadaId == widget.plazoleta.id,
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

        // Add variant URLs if they exist
        if (imagenPrincipal.tieneVariantes) {
          final thumbUrl = imagenPrincipal.getVarianteUrl('thumb');
          final mediumUrl = imagenPrincipal.getVarianteUrl('medium');
          final largeUrl = imagenPrincipal.getVarianteUrl('large');

          if (thumbUrl != null && !_urlsToTry.contains(thumbUrl)) {
            _urlsToTry.add(thumbUrl);
          }
          if (mediumUrl != null && !_urlsToTry.contains(mediumUrl)) {
            _urlsToTry.add(mediumUrl);
          }
          if (largeUrl != null && !_urlsToTry.contains(largeUrl)) {
            _urlsToTry.add(largeUrl);
          }

          // Also add HTTP versions of variants
          for (final variantUrl in [thumbUrl, mediumUrl, largeUrl]) {
            if (variantUrl != null && variantUrl.startsWith('https://')) {
              final httpVariant = variantUrl.replaceFirst(
                'https://',
                'http://',
              );
              if (!_urlsToTry.contains(httpVariant)) {
                _urlsToTry.add(httpVariant);
              }
            }
          }
        }
      }
    }

    print('🔄 URLs a intentar para plazoleta ${widget.plazoleta.id}:');
    for (int i = 0; i < _urlsToTry.length; i++) {
      print('   $i: ${_urlsToTry[i]}');
    }
  }

  void _tryNextUrl() {
    if (_currentUrlIndex < _urlsToTry.length - 1) {
      setState(() {
        _currentUrlIndex++;
        _hasError = false;
      });
      print(
        '🔄 Intentando siguiente URL (${_currentUrlIndex + 1}/${_urlsToTry.length}): ${_urlsToTry[_currentUrlIndex]}',
      );
    } else {
      setState(() {
        _hasError = true;
      });
      print('❌ Todas las URLs fallaron para plazoleta ${widget.plazoleta.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl =
        _urlsToTry.isNotEmpty
            ? _urlsToTry[_currentUrlIndex]
            : widget.primaryUrl;

    if (_hasError || _urlsToTry.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      currentUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.location_city, size: 48, color: Colors.grey),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error cargando imagen $currentUrl: $error');
        print('📋 Stack trace: $stackTrace');

        // Schedule try next URL for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _tryNextUrl();
        });

        // Show loading placeholder while trying next URL
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.location_city, size: 48, color: Colors.grey),
          ),
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
