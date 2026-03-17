// lib/presentation/pages/favoritos/favoritos_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../core/utils/firebase_auth_service.dart';
import '../../../data/datasources/remote/supabase_client.dart';
import '../../../domain/repositories/tienda_repository_interface.dart';
import '../../../domain/repositories/producto_repository_interface.dart';
import '../../blocs/favorito/favorito_bloc.dart';
import '../../blocs/favorito/favorito_event.dart';
import '../../blocs/favorito/favorito_state.dart';
import '../../widgets/tienda/tienda_card.dart';
import '../../widgets/producto/producto_card.dart';

const _kGold = Color(0xFFD4AF37);
const _kBg = Color(0xFF07070F);
const _kSurface = Color(0xFF0F0F1E);
const _kHint = Color(0xFF6B6B8A);

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _usuarioId = 0;
  late FavoritoBloc _favoritoBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _favoritoBloc = getIt<FavoritoBloc>();
    _loadUsuarioId();
  }

  Future<void> _loadUsuarioId() async {
    final authService = getIt<FirebaseAuthService>();
    final firebaseUser = authService.currentUser;

    debugPrint('Firebase user: ${firebaseUser?.uid}');

    if (firebaseUser != null) {
      final supabaseClient = getIt<SupabaseClientService>();
      final usuario = await supabaseClient.getUsuarioByFirebaseId(
        firebaseUser.uid,
      );
      debugPrint('Usuario: $usuario');
      if (usuario != null && mounted) {
        setState(() {
          _usuarioId = usuario['id'] as int;
        });
        debugPrint('Usuario ID: $_usuarioId');
        _favoritoBloc.add(LoadFavoritos(_usuarioId));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_usuarioId == 0) {
      return Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kSurface,
          foregroundColor: Colors.white,
          title: const Text('Mis Favoritos'),
        ),
        body: const Center(child: CircularProgressIndicator(color: _kGold)),
      );
    }

    return BlocProvider.value(
      value: _favoritoBloc,
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kSurface,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Mis Favoritos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _kGold,
            labelColor: _kGold,
            unselectedLabelColor: _kHint,
            tabs: const [Tab(text: 'Tiendas'), Tab(text: 'Productos')],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _TiendasFavoritasContent(usuarioId: _usuarioId),
            _ProductosFavoritosContent(usuarioId: _usuarioId),
          ],
        ),
      ),
    );
  }
}

class _TiendasFavoritasContent extends StatelessWidget {
  final int usuarioId;

  const _TiendasFavoritasContent({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritoBloc, FavoritoState>(
      builder: (context, state) {
        debugPrint('Tiendas state: $state');

        if (state is FavoritoLoading) {
          return const Center(child: CircularProgressIndicator(color: _kGold));
        }

        if (state is FavoritoError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: _kBg,
                  ),
                  onPressed: () {
                    context.read<FavoritoBloc>().add(LoadFavoritos(usuarioId));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is FavoritosLoaded) {
          if (state.tiendaIds.isEmpty) {
            return _EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No tienes tiendas favoritas',
              subtitle: 'Explora las tiendas y guarda tus favoritas',
              onAction: () => context.go('/plazoletas'),
              actionText: 'Explorar Tiendas',
            );
          }

          return _TiendasList(
            tiendaIds: state.tiendaIds.toList(),
            usuarioId: usuarioId,
          );
        }

        // Initial state - still loading
        return const Center(child: CircularProgressIndicator(color: _kGold));
      },
    );
  }
}

class _TiendasList extends StatelessWidget {
  final List<int> tiendaIds;
  final int usuarioId;

  const _TiendasList({required this.tiendaIds, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadTiendas(tiendaIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kGold));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final tiendas = snapshot.data ?? [];

        return RefreshIndicator(
          color: _kGold,
          backgroundColor: _kSurface,
          onRefresh: () async {
            context.read<FavoritoBloc>().add(LoadFavoritos(usuarioId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tiendas.length,
            itemBuilder: (context, index) {
              final tienda = tiendas[index];
              final tiendaId = int.tryParse(tienda['id'].toString()) ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TiendaCard(
                  tienda: tienda,
                  showFavoriteButton: true,
                  isFavorite: true, // Si está en favoritos, siempre es true
                  onFavoriteToggle: () {
                    debugPrint(
                      'Toggle tienda - usuarioId: $usuarioId, tiendaId: $tiendaId',
                    );
                    context.read<FavoritoBloc>().add(
                      ToggleTiendaFavorito(
                        usuarioId: usuarioId,
                        tiendaId: tiendaId,
                      ),
                    );
                  },
                  onTap: () {
                    context.push('/tiendas/${tienda['id']}', extra: tienda);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadTiendas(List<int> tiendaIds) async {
    final repository = getIt<TiendaRepositoryInterface>();
    final tiendas = <Map<String, dynamic>>[];

    for (final id in tiendaIds) {
      final tienda = await repository.getTiendaById(id);
      if (tienda != null) {
        tiendas.add(tienda);
      }
    }

    return tiendas;
  }
}

class _ProductosFavoritosContent extends StatelessWidget {
  final int usuarioId;

  const _ProductosFavoritosContent({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritoBloc, FavoritoState>(
      builder: (context, state) {
        debugPrint('Productos state: $state');

        if (state is FavoritoLoading) {
          return const Center(child: CircularProgressIndicator(color: _kGold));
        }

        if (state is FavoritoError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: _kBg,
                  ),
                  onPressed: () {
                    context.read<FavoritoBloc>().add(LoadFavoritos(usuarioId));
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is FavoritosLoaded) {
          if (state.productoIds.isEmpty) {
            return _EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'No tienes productos favoritos',
              subtitle: 'Explora los productos y guarda tus favoritos',
              onAction: () => context.go('/plazoletas'),
              actionText: 'Explorar Productos',
            );
          }

          return _ProductosList(
            productoIds: state.productoIds.toList(),
            usuarioId: usuarioId,
          );
        }

        // Initial state
        return const Center(child: CircularProgressIndicator(color: _kGold));
      },
    );
  }
}

class _ProductosList extends StatelessWidget {
  final List<int> productoIds;
  final int usuarioId;

  const _ProductosList({required this.productoIds, required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadProductos(productoIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kGold));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final productos = snapshot.data ?? [];

        return RefreshIndicator(
          color: _kGold,
          backgroundColor: _kSurface,
          onRefresh: () async {
            context.read<FavoritoBloc>().add(LoadFavoritos(usuarioId));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final productoId = int.tryParse(producto['id'].toString()) ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ProductoCard(
                  producto: producto,
                  showFavoriteButton: true,
                  isFavorite: true, // Si está en favoritos, siempre es true
                  onFavoriteToggle: () {
                    debugPrint(
                      'Toggle producto - usuarioId: $usuarioId, productoId: $productoId',
                    );
                    context.read<FavoritoBloc>().add(
                      ToggleProductoFavorito(
                        usuarioId: usuarioId,
                        productoId: productoId,
                      ),
                    );
                  },
                  onTap: () {
                    context.push(
                      '/productos/${producto['id']}',
                      extra: producto,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadProductos(
    List<int> productoIds,
  ) async {
    final repository = getIt<ProductoRepositoryInterface>();
    final productos = <Map<String, dynamic>>[];

    for (final id in productoIds) {
      final producto = await repository.getProductoById(id);
      if (producto != null) {
        productos.add(producto);
      }
    }

    return productos;
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAction;
  final String actionText;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAction,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: _kHint),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: _kHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: _kBg,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: onAction,
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
