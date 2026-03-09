// lib/presentation/pages/productos/producto_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../di/service_locator.dart';
import '../../blocs/producto/producto_bloc.dart';
import '../../widgets/common/loading_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/producto/producto_card.dart';
import '../../widgets/profile_floating_button.dart';
import '../../../core/utils/firebase_auth_service.dart';

/// Wrapper para proporcionar el BLoC de productos
class ProductoBlocProvider extends StatelessWidget {
  final Widget child;

  const ProductoBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductoBloc>.value(
      value: getIt<ProductoBloc>(),
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
  // String? _selectedCategoria; // TODO: Implementar filtro por categoría
  // String? _selectedTienda; // TODO: Implementar filtro por tienda

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearch);

    // Cargar productos iniciales
    getIt<ProductoBloc>().add(const ProductoLoadRequested(page: 1, limit: 20));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // TODO: Implementar carga infinita
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      getIt<ProductoBloc>().add(ProductoSearchRequested(query: query));
    } else {
      getIt<ProductoBloc>().add(
        const ProductoLoadRequested(page: 1, limit: 20),
      );
    }
  }

  void _onClearSearch() {
    _searchController.clear();
    _isSearching = false;
    getIt<ProductoBloc>().add(const ProductoLoadRequested(page: 1, limit: 20));
  }

  Future<void> _onRefresh() async {
    getIt<ProductoBloc>().add(
      const ProductoLoadRequested(page: 1, limit: 20, forceRefresh: true),
    );
  }

  void _onProductoTap(int productoId) {
    context.go('/productos/$productoId');
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
        ),
        onChanged: (_) => _onSearch(),
      ),
    );
  }

  Widget _buildProductoList(List<dynamic> productos) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return ProductoCard(
          producto: producto,
          onTap: () => _onProductoTap(producto.id),
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic state) {
    String message = 'No hay productos disponibles';

    if (state is ProductoSearchEmpty) {
      message = 'No se encontraron productos que coincidan con la búsqueda';
    }

    return EmptyState(
      icon: Icons.shopping_bag_outlined,
      message: message,
      actionText: 'Recargar',
      onActionPressed: _onRefresh,
    );
  }

  Widget _buildErrorState(ProductoError state) {
    return ErrorState(
      message: state.message,
      actionText: 'Reintentar',
      onActionPressed: _onRefresh,
    );
  }

  void _showProfileMenu(BuildContext context, User currentUser) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  currentUser.photoURL != null
                      ? NetworkImage(currentUser.photoURL!)
                      : null,
              backgroundColor: Colors.grey[800],
              child:
                  currentUser.photoURL == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              currentUser.displayName ?? 'Usuario',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (currentUser.email != null) ...[
              const SizedBox(height: 8),
              Text(
                currentUser.email!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi perfil'),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a configuración
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout();
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    final authService = getIt<FirebaseAuthService>();
    try {
      final result = await authService.signOut();
      result.fold(
        (success) {
          context.go('/login');
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<ProductoBloc, ProductoState>(
            bloc: getIt<ProductoBloc>(),
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
          // Botón de perfil flotante en esquina inferior derecha
          Positioned(
            bottom: 24,
            right: 24,
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final isAuthenticated =
                    snapshot.hasData && snapshot.data != null;
                final currentUser = snapshot.data;

                if (!isAuthenticated || currentUser == null) {
                  return FloatingActionButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    backgroundColor: const Color(0xFFD4AF37),
                    child: const Icon(
                      Icons.login,
                      color: Colors.black,
                      size: 28,
                    ),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  );
                }

                return FloatingActionButton(
                  onPressed: () {
                    _showProfileMenu(context, currentUser);
                  },
                  backgroundColor: const Color(0xFFD4AF37),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        currentUser.photoURL != null
                            ? NetworkImage(currentUser.photoURL!)
                            : null,
                    backgroundColor: Colors.grey[800],
                    child:
                        currentUser.photoURL == null
                            ? const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botón de perfil flotante en esquina inferior derecha
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 24),
        child: ProfileFloatingButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
