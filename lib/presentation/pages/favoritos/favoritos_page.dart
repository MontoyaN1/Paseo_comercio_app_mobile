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
import '../../widgets/tienda/list/tienda_card.dart';
import '../../widgets/producto/list/producto_card.dart';

const _kGold = Color(0xFFD4AF37);

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
    final theme = Theme.of(context);

    if (_usuarioId == 0) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          title: const Text('Mis Favoritos'),
        ),
        body: const Center(child: CircularProgressIndicator(color: _kGold)),
      );
    }

    return BlocProvider.value(
      value: _favoritoBloc,
      child: BlocBuilder<FavoritoBloc, FavoritoState>(
        builder: (context, state) {
          final tiendaCount =
              state is FavoritosLoaded ? state.tiendaIds.length : 0;
          final productoCount =
              state is FavoritosLoaded ? state.productoIds.length : 0;

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _kGold,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Mis Favoritos',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: _kGold,
                labelColor: _kGold,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: [
                  Tab(text: 'Tiendas ($tiendaCount)'),
                  Tab(text: 'Productos ($productoCount)'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _TiendasFavoritasContent(usuarioId: _usuarioId),
                _ProductosFavoritosContent(usuarioId: _usuarioId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TiendasFavoritasContent extends StatelessWidget {
  final int usuarioId;

  const _TiendasFavoritasContent({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: Colors.black,
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
    final theme = Theme.of(context);

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
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          );
        }

        final tiendas = snapshot.data ?? [];

        return RefreshIndicator(
          color: _kGold,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          onRefresh: () async {
            context.read<FavoritoBloc>().add(LoadFavoritos(usuarioId));
          },
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: tiendas.length,
            itemBuilder: (context, index) {
              final tienda = tiendas[index];
              final tiendaId = int.tryParse(tienda['id'].toString()) ?? 0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 280,
                  child: TiendaCard(
                    tienda: tienda,
                    showFavoriteButton: true,
                    isFavorite: true,
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

    final results = await Future.wait(
      tiendaIds.map((id) => repository.getTiendaById(id)),
    );

    return results.whereType<Map<String, dynamic>>().toList();
  }
}

class _ProductosFavoritosContent extends StatelessWidget {
  final int usuarioId;

  const _ProductosFavoritosContent({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: Colors.black,
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
    final theme = Theme.of(context);

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
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          );
        }

        final productos = snapshot.data ?? [];

        return RefreshIndicator(
          color: _kGold,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          onRefresh: () async {
            context.read<FavoritoBloc>().add(LoadFavoritos(usuarioId));
          },
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];
              final productoId = int.tryParse(producto['id'].toString()) ?? 0;

              return ProductoCard(
                producto: producto,
                showDetails: true,
                showFavoriteButton: true,
                isFavorite: true,
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
                  context.push('/productos/${producto['id']}', extra: producto);
                },
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

    final results = await Future.wait(
      productoIds.map((id) => repository.getProductoById(id)),
    );

    return results.whereType<Map<String, dynamic>>().toList();
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: Colors.black,
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
