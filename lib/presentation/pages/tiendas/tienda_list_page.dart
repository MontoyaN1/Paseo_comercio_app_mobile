// lib/presentation/pages/tiendas/tienda_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_app_bar.dart';

import '../../../di/service_locator.dart';
import '../../blocs/tienda/tienda_bloc.dart';

import '../../widgets/common/loading_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/tienda/tienda_card.dart';

/// Wrapper para proporcionar el BLoC de tiendas
class TiendaBlocProvider extends StatelessWidget {
  final Widget child;

  const TiendaBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TiendaBloc>.value(
      value: getIt<TiendaBloc>(),
      child: child,
    );
  }
}

/// Pantalla de lista de tiendas
class TiendaListPage extends StatefulWidget {
  const TiendaListPage({super.key});

  @override
  State<TiendaListPage> createState() => _TiendaListPageState();
}

class _TiendaListPageState extends State<TiendaListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Cargar tiendas iniciales
    getIt<TiendaBloc>().add(const TiendaLoadRequested(page: 1, limit: 20));

    // Configurar scroll listener para paginación infinita
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Cargar más tiendas cuando estemos cerca del final
      final tiendaBloc = getIt<TiendaBloc>();
      if (tiendaBloc.hasMoreTiendas) {
        tiendaBloc.add(const TiendaLoadMoreRequested(limit: 20));
      }
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      getIt<TiendaBloc>().add(
        TiendaSearchRequested(query: query, page: 1, limit: 20),
      );
    } else {
      // Si la búsqueda está vacía, volver a cargar todas las tiendas
      getIt<TiendaBloc>().add(
        const TiendaLoadRequested(page: 1, limit: 20, forceRefresh: true),
      );
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _isSearching = false;
    getIt<TiendaBloc>().add(
      const TiendaLoadRequested(page: 1, limit: 20, forceRefresh: true),
    );
  }

  void _onRefresh() {
    getIt<TiendaBloc>().add(const TiendaRefreshRequested());
  }

  void _onTiendaTap(Map<String, dynamic> tienda) {
    final tiendaId = tienda['id'] as int;
    context.go('/tiendas/$tiendaId');
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar tiendas...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _onClearSearch,
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
          if (value.isNotEmpty) {
            _onSearch(value);
          }
        },
        onSubmitted: _onSearch,
      ),
    );
  }

  Widget _buildTiendaList(List<Map<String, dynamic>> tiendas) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: tiendas.length + 1, // +1 para el loading indicator
      itemBuilder: (context, index) {
        if (index < tiendas.length) {
          final tienda = tiendas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TiendaCard(
              tienda: tienda,
              onTap: () => _onTiendaTap(tienda),
            ),
          );
        } else {
          // Mostrar loading indicator al final si hay más tiendas
          final tiendaBloc = getIt<TiendaBloc>();
          if (tiendaBloc.hasMoreTiendas) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }

  Widget _buildEmptyState(TiendaState state) {
    if (state is TiendaSearchEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        message:
            'No se encontraron resultados. No hay tiendas que coincidan con "${state.query}"',
        actionText: 'Limpiar búsqueda',
        onActionPressed: _onClearSearch,
      );
    } else if (state is TiendaEmpty) {
      return EmptyState(
        icon: Icons.storefront_outlined,
        message:
            'No hay tiendas disponibles. ${state.message ?? 'No se encontraron tiendas en este momento'}',
        actionText: 'Recargar',
        onActionPressed: _onRefresh,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorState(TiendaError state) {
    return ErrorState(
      message: state.message,
      actionText: state.isRetryable ? 'Reintentar' : null,
      onActionPressed: state.isRetryable ? _onRefresh : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isSearching ? null : 'Tiendas',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implementar filtros
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtros - En desarrollo')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh),
        ],
      ),
      body: BlocBuilder<TiendaBloc, TiendaState>(
        bloc: getIt<TiendaBloc>(),
        builder: (context, state) {
          return Column(
            children: [
              if (_isSearching) _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _onRefresh();
                    // Esperar un momento para que se complete el refresh
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: _buildContent(state),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar creación de tienda
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear tienda - En desarrollo')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(TiendaState state) {
    if (state is TiendaLoading && state is! TiendaSearchLoading) {
      return const LoadingState(message: 'Cargando tiendas...');
    }

    if (state is TiendaSearchLoading) {
      return LoadingState(message: 'Buscando "${state.query}"...');
    }

    if (state is TiendaError) {
      return _buildErrorState(state);
    }

    if (state is TiendaEmpty || state is TiendaSearchEmpty) {
      return _buildEmptyState(state);
    }

    if (state is TiendaLoaded || state is TiendaSearchLoaded) {
      final tiendas =
          state is TiendaLoaded
              ? state.tiendas
              : (state as TiendaSearchLoaded).tiendas;

      if (tiendas.isEmpty) {
        return _buildEmptyState(state);
      }

      return _buildTiendaList(tiendas);
    }

    if (state is TiendaDetailLoaded) {
      // Esto no debería ocurrir en esta pantalla, pero manejarlo por si acaso
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Pantalla incorrecta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Esta es la pantalla de lista, no de detalle'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                getIt<TiendaBloc>().add(
                  const TiendaLoadRequested(page: 1, limit: 20),
                );
              },
              child: const Text('Volver a la lista'),
            ),
          ],
        ),
      );
    }

    // Estado inicial o desconocido
    return const LoadingState(message: 'Inicializando...');
  }
}
