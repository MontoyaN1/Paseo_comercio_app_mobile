// lib/presentation/pages/productos/producto_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../blocs/producto/producto_bloc.dart';

import '../../widgets/common/loading_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/producto/producto_card.dart';

/// Wrapper para proporcionar el BLoC de productos
class ProductoBlocProvider extends StatelessWidget {
  final Widget child;

  const ProductoBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductoBloc>(
      create: (context) => getIt<ProductoBloc>(),
      child: child,
    );
  }
}

/// Pantalla de lista de productos
class ProductoListPage extends StatefulWidget {
  const ProductoListPage({super.key});

  @override
  State<ProductoListPage> createState() => _ProductoListPageState();
}

class _ProductoListPageState extends State<ProductoListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _selectedCategoria;
  String? _selectedTienda;

  @override
  void initState() {
    super.initState();
    // Cargar productos iniciales
    getIt<ProductoBloc>().add(const ProductoLoadRequested(page: 1, limit: 20));

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
      // Cargar más productos cuando estemos cerca del final
      final productoBloc = getIt<ProductoBloc>();
      if (productoBloc.hasMoreProductos) {
        productoBloc.add(const ProductoLoadMoreRequested(limit: 20));
      }
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      getIt<ProductoBloc>().add(
        ProductoSearchRequested(
          query: query,
          page: 1,
          limit: 20,
          categoriaId:
              _selectedCategoria != null
                  ? int.tryParse(_selectedCategoria!)
                  : null,
          tiendaId:
              _selectedTienda != null ? int.tryParse(_selectedTienda!) : null,
        ),
      );
    } else {
      // Si la búsqueda está vacía, volver a cargar todos los productos
      getIt<ProductoBloc>().add(
        const ProductoLoadRequested(page: 1, limit: 20, forceRefresh: true),
      );
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _isSearching = false;
    _selectedCategoria = null;
    _selectedTienda = null;
    getIt<ProductoBloc>().add(
      const ProductoLoadRequested(page: 1, limit: 20, forceRefresh: true),
    );
  }

  void _onRefresh() {
    getIt<ProductoBloc>().add(const ProductoRefreshRequested());
  }

  void _onProductoTap(Map<String, dynamic> producto) {
    final productoId = producto['id'] as int;
    context.go('/productos/$productoId');
  }

  void _onCategoriaFilter(String? categoriaId) {
    setState(() {
      _selectedCategoria = categoriaId;
    });

    if (_searchController.text.isNotEmpty) {
      // Si hay búsqueda, aplicar filtro a la búsqueda
      getIt<ProductoBloc>().add(
        ProductoSearchRequested(
          query: _searchController.text,
          page: 1,
          limit: 20,
          categoriaId: categoriaId != null ? int.tryParse(categoriaId) : null,
          tiendaId:
              _selectedTienda != null ? int.tryParse(_selectedTienda!) : null,
        ),
      );
    } else {
      // Si no hay búsqueda, cargar productos con filtro
      getIt<ProductoBloc>().add(
        ProductoLoadRequested(
          page: 1,
          limit: 20,
          categoriaId: categoriaId != null ? int.tryParse(categoriaId) : null,
          tiendaId:
              _selectedTienda != null ? int.tryParse(_selectedTienda!) : null,
          forceRefresh: true,
        ),
      );
    }
  }

  void _onTiendaFilter(String? tiendaId) {
    setState(() {
      _selectedTienda = tiendaId;
    });

    if (_searchController.text.isNotEmpty) {
      // Si hay búsqueda, aplicar filtro a la búsqueda
      getIt<ProductoBloc>().add(
        ProductoSearchRequested(
          query: _searchController.text,
          page: 1,
          limit: 20,
          categoriaId:
              _selectedCategoria != null
                  ? int.tryParse(_selectedCategoria!)
                  : null,
          tiendaId: tiendaId != null ? int.tryParse(tiendaId) : null,
        ),
      );
    } else {
      // Si no hay búsqueda, cargar productos con filtro
      getIt<ProductoBloc>().add(
        ProductoLoadRequested(
          page: 1,
          limit: 20,
          categoriaId:
              _selectedCategoria != null
                  ? int.tryParse(_selectedCategoria!)
                  : null,
          tiendaId: tiendaId != null ? int.tryParse(tiendaId) : null,
          forceRefresh: true,
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
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

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedCategoria != null)
            FilterChip(
              label: const Text('Categoría filtrada'),
              selected: true,
              onSelected: (selected) {
                if (!selected) {
                  _onCategoriaFilter(null);
                }
              },
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _onCategoriaFilter(null),
            ),
          if (_selectedTienda != null)
            FilterChip(
              label: const Text('Tienda filtrada'),
              selected: true,
              onSelected: (selected) {
                if (!selected) {
                  _onTiendaFilter(null);
                }
              },
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => _onTiendaFilter(null),
            ),
        ],
      ),
    );
  }

  Widget _buildProductoList(List<Map<String, dynamic>> productos) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: productos.length + 1, // +1 para el loading indicator
      itemBuilder: (context, index) {
        if (index < productos.length) {
          final producto = productos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductoCard(
              producto: producto,
              onTap: () => _onProductoTap(producto),
            ),
          );
        } else {
          // Mostrar loading indicator al final si hay más productos
          final productoBloc = getIt<ProductoBloc>();
          if (productoBloc.hasMoreProductos) {
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

  Widget _buildEmptyState(ProductoState state) {
    if (state is ProductoSearchEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        message:
            'No se encontraron resultados. No hay productos que coincidan con "${state.query}"',
        actionText: 'Limpiar búsqueda',
        onActionPressed: _onClearSearch,
      );
    } else if (state is ProductoEmpty) {
      return EmptyState(
        icon: Icons.shopping_bag_outlined,
        message:
            'No hay productos disponibles. ${state.message ?? 'No se encontraron productos en este momento'}',
        actionText: 'Recargar',
        onActionPressed: _onRefresh,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorState(ProductoError state) {
    return ErrorState(
      message: state.message,
      actionText: state.isRetryable ? 'Reintentar' : null,
      onActionPressed: state.isRetryable ? _onRefresh : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? null
                : const Text(
                  'Productos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'categoria') {
                // TODO: Implementar selector de categorías
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtro por categoría - En desarrollo'),
                  ),
                );
              } else if (value == 'tienda') {
                // TODO: Implementar selector de tiendas
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtro por tienda - En desarrollo'),
                  ),
                );
              } else if (value == 'precio') {
                // TODO: Implementar filtro por precio
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtro por precio - En desarrollo'),
                  ),
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'categoria',
                    child: Row(
                      children: [
                        Icon(Icons.category, size: 20),
                        SizedBox(width: 8),
                        Text('Filtrar por categoría'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'tienda',
                    child: Row(
                      children: [
                        Icon(Icons.store, size: 20),
                        SizedBox(width: 8),
                        Text('Filtrar por tienda'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'precio',
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, size: 20),
                        SizedBox(width: 8),
                        Text('Filtrar por precio'),
                      ],
                    ),
                  ),
                ],
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh),
        ],
      ),
      body: BlocBuilder<ProductoBloc, ProductoState>(
        bloc: getIt<ProductoBloc>(),
        builder: (context, state) {
          return Column(
            children: [
              if (_isSearching) _buildSearchBar(),
              if (_selectedCategoria != null || _selectedTienda != null)
                _buildFilterChips(),
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
          // TODO: Implementar creación de producto
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Crear producto - En desarrollo')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(ProductoState state) {
    if (state is ProductoLoading && state is! ProductoSearchLoading) {
      return const LoadingState(message: 'Cargando productos...');
    }

    if (state is ProductoSearchLoading) {
      return LoadingState(message: 'Buscando "${state.query}"...');
    }

    if (state is ProductoError) {
      return _buildErrorState(state);
    }

    if (state is ProductoEmpty || state is ProductoSearchEmpty) {
      return _buildEmptyState(state);
    }

    if (state is ProductoLoaded || state is ProductoSearchLoaded) {
      final productos =
          state is ProductoLoaded
              ? state.productos
              : (state as ProductoSearchLoaded).productos;

      if (productos.isEmpty) {
        return _buildEmptyState(state);
      }

      return _buildProductoList(productos);
    }

    if (state is ProductoDetailLoaded) {
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
                getIt<ProductoBloc>().add(
                  const ProductoLoadRequested(page: 1, limit: 20),
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
