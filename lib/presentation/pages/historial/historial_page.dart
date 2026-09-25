// lib/presentation/pages/historial/historial_page.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../di/service_locator.dart';
import '../../../data/datasources/local/local_database.dart';

// ── Paleta (idéntica al sistema de diseño) ────────────────────
const Color _kGold = Color(0xFFD4AF37);
const Color _kGoldLight = Color(0xFFFFE082);
const Color _kGoldDeep = Color(0xFF9C7A1A);
const Color _kBg = Color(0xFF07070F);
const Color _kSurface = Color(0xFF0F0F1E);
const Color _kSurfaceCard = Color(0xFF12121F);
const Color _kBorder = Color(0xFF1E1E3A);
const Color _kHint = Color(0xFF6B6B8A);

// ══════════════════════════════════════════════════════════════
//  PÁGINA DE HISTORIAL DE VISITAS
// ══════════════════════════════════════════════════════════════
class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final LocalCacheService _localCache = getIt<LocalCacheService>();

  List<Map<String, dynamic>> _historialTiendas = [];
  List<Map<String, dynamic>> _historialProductos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarHistorial();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _isLoading = true);

    try {
      _historialTiendas = _localCache.obtenerHistorialTiendas();
      _historialProductos = _localCache.obtenerHistorialProductos();
    } catch (e) {
      // Handle error silently
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHistorialList(_historialTiendas, 'tienda'),
                      _buildHistorialList(_historialProductos, 'producto'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar glassmorphism ──────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: _kSurface.withOpacity(0.82),
            border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _GoldIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () {
                  try {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Future.microtask(() => context.go('/plazoletas'));
                    }
                  } catch (e) {
                    Future.microtask(() => context.go('/'));
                  }
                },
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ShaderMask(
                  shaderCallback:
                      (b) => const LinearGradient(
                        colors: [_kGoldDeep, _kGold, _kGoldLight],
                      ).createShader(b),
                  child: const Text(
                    'Historial',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              _GoldIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _showClearConfirmation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TabBar ────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _kGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: _kGold,
        unselectedLabelColor: _kHint,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Tiendas (${_historialTiendas.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Productos (${_historialProductos.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Lista de historial ───────────────────────────────────
  Widget _buildHistorialList(List<Map<String, dynamic>> items, String tipo) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _kGold));
    }

    if (items.isEmpty) {
      return _buildEmptyState(tipo);
    }

    return RefreshIndicator(
      onRefresh: _cargarHistorial,
      color: _kGold,
      backgroundColor: _kSurface,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final datos = item['datos'] as Map<String, dynamic>? ?? {};
          final timestamp = DateTime.tryParse(item['timestamp'] ?? '');

          return _HistorialTile(
            tipo: tipo,
            datos: datos,
            timestamp: timestamp,
            onTap: () {
              if (tipo == 'tienda') {
                final tiendaId = datos['id'] as int? ?? item['id'] as int?;
                if (tiendaId != null) {
                  context.push('/tiendas/$tiendaId');
                }
              } else {
                final productoId = datos['id'] as int? ?? item['id'] as int?;
                if (productoId != null) {
                  context.push('/productos/$productoId', extra: datos);
                }
              }
            },
          );
        },
      ),
    );
  }

  // ── Estado vacío ─────────────────────────────────────────
  Widget _buildEmptyState(String tipo) {
    final isTienda = tipo == 'tienda';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTienda ? Icons.store_outlined : Icons.shopping_bag_outlined,
            size: 64,
            color: _kHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isTienda
                ? 'No has visitado tiendas todavía'
                : 'No has visitado productos todavía',
            style: TextStyle(color: _kHint, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Explora tiendas y productos para verlos aquí',
            style: TextStyle(color: _kHint.withOpacity(0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Confirmación de limpiar ───────────────────────────────
  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: _kSurface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _kBorder, width: 1),
            ),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.10),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.30),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[300],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Limpiar historial',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: const Text(
              '¿Estás seguro de que quieres eliminar todo el historial de visitas?',
              style: TextStyle(color: _kHint, fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: _kHint, fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _localCache.limpiarHistorial();
                  await _cargarHistorial();
                },
                child: Text(
                  'Limpiar',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  WIDGETS AUXILIARES
// ══════════════════════════════════════════════════════════════

class _HistorialTile extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic> datos;
  final DateTime? timestamp;
  final VoidCallback onTap;

  const _HistorialTile({
    required this.tipo,
    required this.datos,
    this.timestamp,
    required this.onTap,
  });

  @override
  State<_HistorialTile> createState() => _HistorialTileState();
}

class _HistorialTileState extends State<_HistorialTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) return 'Hace ${(diff.inDays / 7).floor()} semanas';

    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nombre =
        widget.tipo == 'tienda'
            ? widget.datos['nombre_tienda'] ??
                widget.datos['nombre'] ??
                'Tienda'
            : widget.datos['nombre_producto'] ??
                widget.datos['nombre'] ??
                'Producto';

    final imagenUrl =
        widget.datos['imagen_principal'] ??
        widget.datos['imagen_url'] ??
        widget.datos['logo_url'];

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: _kSurfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _kBorder, width: 1),
                ),
                child: Row(
                  children: [
                    // Imagen
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(13),
                          bottomLeft: Radius.circular(13),
                        ),
                      ),
                      child:
                          imagenUrl != null
                              ? ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(13),
                                  bottomLeft: Radius.circular(13),
                                ),
                                child: Image.network(
                                  imagenUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => _buildIconPlaceholder(),
                                ),
                              )
                              : _buildIconPlaceholder(),
                    ),
                    // Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  widget.tipo == 'tienda'
                                      ? Icons.store_rounded
                                      : Icons.shopping_bag_rounded,
                                  size: 12,
                                  color: _kGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.tipo == 'tienda'
                                      ? 'Tienda'
                                      : 'Producto',
                                  style: TextStyle(
                                    color: _kGold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTimestamp(widget.timestamp),
                              style: TextStyle(color: _kHint, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Flecha
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _kHint,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildIconPlaceholder() {
    return Container(
      color: _kSurface,
      child: Center(
        child: Icon(
          widget.tipo == 'tienda'
              ? Icons.store_rounded
              : Icons.shopping_bag_rounded,
          color: _kGold.withOpacity(0.5),
          size: 28,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  BOTÓN ÍCONO DORADO
// ══════════════════════════════════════════════════════════════
class _GoldIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoldIconButton({required this.icon, required this.onTap});

  @override
  State<_GoldIconButton> createState() => _GoldIconButtonState();
}

class _GoldIconButtonState extends State<_GoldIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder:
            (_, __) => Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGold.withOpacity(0.07),
                  border: Border.all(color: _kGold.withOpacity(0.28), width: 1),
                ),
                child: Icon(widget.icon, color: _kGold, size: 18),
              ),
            ),
      ),
    );
  }
}
