// lib/presentation/pages/plazoletas/plazoleta_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../domain/entities/plazoleta.dart';
import '../../blocs/plazoleta/plazoleta_bloc.dart';
import '../../blocs/plazoleta/plazoleta_event.dart';
import '../../blocs/plazoleta/plazoleta_state.dart';
import '../../widgets/profile_floating_button.dart';

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

/// Pantalla de lista de plazoletas con diseño de centro comercial premium
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
    getIt<PlazoletaBloc>().add(const LoadPlazoletasActivas(page: 1, limit: 20));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePlazoletas();
    }
  }

  Future<void> _loadMorePlazoletas() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final plazoletaBloc = getIt<PlazoletaBloc>();
      final state = plazoletaBloc.state;
      if (state is PlazoletaLoaded && state.hasMore) {
        plazoletaBloc.add(
          LoadPlazoletasActivas(page: state.currentPage + 1, limit: 20),
        );
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    getIt<PlazoletaBloc>().add(
      const LoadPlazoletasActivas(page: 1, limit: 20, forceRefresh: true),
    );
  }

  void _onPlazoletaTap(int plazoletaId) {
    context.go('/plazoletas/$plazoletaId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Fondo con gradiente sutil
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
              ),
            ),
          ),

          BlocBuilder<PlazoletaBloc, PlazoletaState>(
            bloc: getIt<PlazoletaBloc>(),
            builder: (context, state) {
              return Column(
                children: [
                  // Contador de plazoletas
                  _buildMallHeader(state),
                  const SizedBox(height: 16),

                  // Lista de plazoletas
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _onRefresh();
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: _buildContent(state),
                    ),
                  ),
                ],
              );
            },
          ),

          // Botón de perfil flotante
          Positioned(
            bottom: 24,
            right: 24,
            child: ProfileFloatingButton(
              size: 64,
              backgroundColor: const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMallHeader(PlazoletaState state) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      child: _buildStatsBar(state),
    );
  }

  Widget _buildStatsBar(PlazoletaState state) {
    int count = 0;
    if (state is PlazoletaLoaded) {
      count = state.plazoletas.length;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.store_mall_directory,
            size: 16,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(width: 6),
          Text(
            '$count plazoletas',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PlazoletaState state) {
    if (state is PlazoletaLoading) {
      return _buildLoadingState();
    }

    if (state is PlazoletaLoaded) {
      if (state.plazoletas.isEmpty) {
        return _buildEmptyState();
      }

      return _buildPlazoletaList(state);
    }

    if (state is PlazoletaErrorState) {
      return _buildErrorState(state);
    }

    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFD4AF37),
              ),
              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando plazoletas...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Preparando tu experiencia de centro comercial',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlazoletaList(PlazoletaLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 100, left: 8, right: 8),
      itemCount: state.plazoletas.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.plazoletas.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: const Color(0xFFD4AF37)),
            ),
          );
        }

        final plazoleta = state.plazoletas[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _buildPlazoletaCard(plazoleta, state),
        );
      },
    );
  }

  String? _getPlazoletaImageUrl(Plazoleta plazoleta, PlazoletaLoaded state) {
    if (state.imagenesPlazoleta != null) {
      // Buscar imagen principal
      for (final imagen in state.imagenesPlazoleta!) {
        if (imagen.entidadRelacionadaId == plazoleta.id && imagen.esPrincipal) {
          return imagen.urlPreferida;
        }
      }

      // Buscar cualquier imagen
      for (final imagen in state.imagenesPlazoleta!) {
        if (imagen.entidadRelacionadaId == plazoleta.id) {
          return imagen.urlPreferida;
        }
      }
    }

    return plazoleta.icono;
  }

  Widget _buildPlazoletaImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholderImage();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[800]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.store_mall_directory,
          size: 64,
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
    );
  }

  Widget _buildPlazoletaCard(Plazoleta plazoleta, PlazoletaLoaded state) {
    final imageUrl = _getPlazoletaImageUrl(plazoleta, state);
    final nombre = plazoleta.nombre;
    final descripcion = plazoleta.descripcion;
    final ubicacion = plazoleta.resumenUbicacion;
    final tieneZonaComida = plazoleta.tieneZonaComida ?? false;
    final tieneEstacionamiento = plazoleta.tieneEstacionamiento ?? false;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onPlazoletaTap(plazoleta.id),
          splashColor: const Color(0xFFD4AF37).withOpacity(0.3),
          highlightColor: const Color(0xFFD4AF37).withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen con overlay
              Stack(
                children: [
                  // Imagen principal
                  SizedBox(
                    height: 220,
                    child:
                        imageUrl != null && imageUrl.isNotEmpty
                            ? _buildPlazoletaImage(imageUrl)
                            : _buildPlaceholderImage(),
                  ),

                  // Overlay degradado
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Badge de ubicación
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37),
                            const Color(0xFFC19B2E),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_pin,
                            size: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ubicacion.isNotEmpty ? ubicacion : 'Piso 1',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Iconos de servicios
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        if (tieneZonaComida)
                          _buildServiceIcon(Icons.restaurant),
                        if (tieneZonaComida && tieneEstacionamiento)
                          const SizedBox(width: 8),
                        if (tieneEstacionamiento)
                          _buildServiceIcon(Icons.local_parking),
                      ],
                    ),
                  ),

                  // Nombre y descripción
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (descripcion?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              descripcion!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.6),
                                    blurRadius: 6,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador de disponibilidad
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.7),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Abierto ahora',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Botón de explorar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37),
                            const Color(0xFFC19B2E),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Explorar',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.black,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 80,
            color: const Color(0xFFD4AF37).withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay plazoletas disponibles',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pronto tendremos nuevas plazoletas para explorar',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.2),
                  const Color(0xFFC19B2E).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            ),
            child: Text(
              'Vuelve más tarde',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PlazoletaErrorState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Error al cargar las plazoletas',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.message.isNotEmpty
                ? state.message
                : 'Ocurrió un problema al cargar la información',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.2),
                  const Color(0xFFC19B2E).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            ),
            child: InkWell(
              onTap: () {
                getIt<PlazoletaBloc>().add(
                  const LoadPlazoletasActivas(page: 1, limit: 20),
                );
              },
              child: Text(
                'Reintentar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
