// lib/presentation/pages/organizaciones/organizacion_list_page.dart
//
// 🏛️  PLAZA UNIVERSE — Organizaciones de Lujo
// ────────────────────────────────────────────────────────────
//  Fragmentado: widgets extraídos a lib/presentation/widgets/organizacion/
//  USA Theme.of(context) para colores de UI genéricos
// ────────────────────────────────────────────────────────────

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/entities/organizacion.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../presentation/blocs/organizacion/organizacion_bloc.dart';
import '../../../../presentation/widgets/organizacion/organizacion_bg_painter.dart';
import '../../../../presentation/widgets/organizacion/list/organizacion_card.dart';
import '../../../../presentation/widgets/organizacion/list/organizacion_filter_chip.dart';
import '../../../../presentation/widgets/organizacion/organizacion_components.dart';
import '../../../../presentation/widgets/shared/profile_floating_button.dart';

const _kGold = Color(0xFFD4AF37);
const _kGoldDeep = Color(0xFF9C7A1A);

class OrganizacionListPage extends StatefulWidget {
  const OrganizacionListPage({super.key});

  @override
  State<OrganizacionListPage> createState() => _OrganizacionListPageState();
}

class _OrganizacionListPageState extends State<OrganizacionListPage>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  bool _searchFocused = false;
  TipoOrganizacion? _selectedTipoFilter;
  int _currentPage = 1;
  final int _limit = 20;
  bool _isResetting = false;

  late final AnimationController _bgCtrl;
  late final AnimationController _listCtrl;
  late final AnimationController _searchFocusCtrl;
  late final Animation<double> _searchGlow;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _searchFocusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchGlow = CurvedAnimation(
      parent: _searchFocusCtrl,
      curve: Curves.easeOut,
    );

    _listCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resetToInitial();
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _listCtrl.dispose();
    _searchFocusCtrl.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrganizaciones() {
    final bloc = context.read<OrganizacionBloc>();
    if (!bloc.isClosed) {
      bloc.add(LoadOrganizaciones(page: _currentPage, limit: _limit));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreOrganizaciones();
    }
  }

  void _loadMoreOrganizaciones() {
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    final state = bloc.state;
    if (state is OrganizacionLoaded && state.hasMore) {
      _currentPage++;
      if (!bloc.isClosed) {
        bloc.add(LoadOrganizaciones(page: _currentPage, limit: _limit));
      }
    }
  }

  void _onSearchChanged(String query) {
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    if (query.isNotEmpty) {
      bloc.add(SearchOrganizaciones(query: query));
    } else {
      _resetToInitial();
    }
  }

  void _onTipoFilterChanged(TipoOrganizacion? tipo) {
    setState(() => _selectedTipoFilter = tipo);
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    if (tipo != null) {
      bloc.add(FilterByTipo(tipo: tipo));
    } else {
      _resetToInitial();
    }
  }

  void _onOrganizacionTap(Organizacion organizacion) async {
    await context.push(
      '/organizaciones/${organizacion.id}',
      extra: organizacion,
    );

    if (mounted) {
      _isResetting = false;
      _resetToInitial();
    }
  }

  void _onRefresh() {
    _currentPage = 1;
    _loadOrganizaciones();
  }

  void _resetToInitial() {
    if (_isResetting) return;
    _isResetting = true;

    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) {
      _isResetting = false;
      return;
    }

    bloc.add(const ResetOrganizacionState());
    _currentPage = 1;
    _loadOrganizaciones();
  }

  void _reloadOrganizationsIfNeeded() {
    final bloc = context.read<OrganizacionBloc>();
    if (bloc.isClosed) return;
    final state = bloc.state;

    bool needsReload = false;

    if (state is OrganizacionInitial) {
      needsReload = true;
    } else if (state is OrganizacionErrorState) {
      needsReload = true;
    } else if (state is OrganizacionLoaded) {
      if (state.organizaciones.isEmpty) {
        needsReload = true;
      }
    }

    if (needsReload) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _resetToInitial();
        }
      });
    }
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
        return 'Otra';
    }
  }

  String _getIconoTipo(TipoOrganizacion tipo) {
    switch (tipo) {
      case TipoOrganizacion.fundacion:
        return '🏛️';
      case TipoOrganizacion.asociacion:
        return '🤝';
      case TipoOrganizacion.cooperativa:
        return '👥';
      case TipoOrganizacion.empresa:
        return '🏢';
      case TipoOrganizacion.comunidad:
        return '🏘️';
      case TipoOrganizacion.otro:
        return '🏠';
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<OrganizacionBloc, OrganizacionState>(
      listener: (context, state) {
        if (state is OrganizacionErrorState) {
          _showGoldSnackBar(state.message, isError: true);
        }
        if (state is OrganizacionLoaded) {
          _listCtrl.forward(from: 0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _bgCtrl,
                builder:
                    (_, __) => CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: OrganizacionBgPainter(
                        _bgCtrl.value,
                        theme.brightness,
                      ),
                    ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildFilterBar(),
                    Expanded(child: _buildBody(state)),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: ProfileFloatingButton(
            hideOrganizacionesOption: true,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.82),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.surfaceContainerHighest,
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder:
                      (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                  child: _isSearching ? _buildSearchField() : _buildTitleRow(),
                ),
              ),
              const SizedBox(width: 8),
              OrganizacionIconButton(
                icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
                onTap: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _searchFocusCtrl.reverse();
                      _resetToInitial();
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      key: const ValueKey('title'),
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isDark
                      ? _kGold.withOpacity(0.55)
                      : theme.colorScheme.primary.withOpacity(0.50),
              width: 1.4,
            ),
            color:
                isDark
                    ? _kGold.withOpacity(0.08)
                    : theme.colorScheme.primary.withOpacity(0.08),
          ),
          child: Icon(
            Icons.account_balance_rounded,
            color: isDark ? _kGold : theme.colorScheme.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback:
                  (b) =>
                      isDark
                          ? const LinearGradient(
                            colors: [_kGoldDeep, _kGold, Color(0xFFFFE082)],
                          ).createShader(b)
                          : LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ).createShader(b),
              child: Text(
                'Organizaciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Text(
              'Paseo del Comercio',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _searchGlow,
      builder:
          (_, child) => Container(
            key: const ValueKey('search'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.20 * _searchGlow.value),
                  blurRadius: 14 * _searchGlow.value + 1,
                  spreadRadius: _searchGlow.value,
                ),
              ],
            ),
            child: child,
          ),
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _searchFocused = focused);
          focused ? _searchFocusCtrl.forward() : _searchFocusCtrl.reverse();
        },
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
          cursorColor: accentColor,
          decoration: InputDecoration(
            hintText: 'Buscar organizaciones...',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color:
                  _searchFocused
                      ? accentColor
                      : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            filled: true,
            fillColor:
                isDark
                    ? Colors.black.withOpacity(0.30)
                    : theme.colorScheme.surfaceContainerHighest.withOpacity(
                      0.5,
                    ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 1.5),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.70),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.surfaceContainerHighest,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            OrganizacionFilterChip(
              label: 'Todas',
              selected: _selectedTipoFilter == null,
              onSelected: () => _onTipoFilterChanged(null),
            ),
            const SizedBox(width: 8),
            ...TipoOrganizacion.values.map(
              (tipo) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OrganizacionFilterChip(
                  label: _getDescripcionTipo(tipo),
                  emoji: _getIconoTipo(tipo),
                  selected: _selectedTipoFilter == tipo,
                  onSelected: () => _onTipoFilterChanged(tipo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OrganizacionState state) {
    final theme = Theme.of(context);

    if (state is OrganizacionInitial) {
      _reloadOrganizationsIfNeeded();
      return const OrganizacionLoader();
    }

    if (state is OrganizacionLoading) {
      return const OrganizacionLoader();
    }

    if (state is OrganizacionErrorState) {
      return _buildErrorState(state.message);
    }

    List<Organizacion> organizaciones = [];
    bool hasMore = false;

    if (state is OrganizacionLoaded) {
      organizaciones = state.organizaciones;
      hasMore = state.hasMore;
    } else if (state is OrganizacionSearchApplied) {
      organizaciones = state.resultados;
    } else if (state is OrganizacionFilterApplied) {
      organizaciones = state.organizacionesFiltradas;
    }

    if (organizaciones.isEmpty) {
      if (state is OrganizacionSearchApplied ||
          state is OrganizacionFilterApplied) {
        return _buildEmptyState(isFiltered: true);
      } else {
        return _buildEmptyState(isFiltered: false);
      }
    }

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: organizaciones.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == organizaciones.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: OrganizacionLoader(),
            );
          }
          final org = organizaciones[index];
          return AnimatedBuilder(
            animation: _listCtrl,
            builder: (_, child) {
              final delay = (index * 0.07).clamp(0.0, 0.7);
              final progress = Curves.easeOutCubic.transform(
                (((_listCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0)),
              );
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - progress)),
                  child: child,
                ),
              );
            },
            child: OrganizacionCard(
              organizacion: org,
              onTap: () => _onOrganizacionTap(org),
              getDescripcionTipo: _getDescripcionTipo,
              getColorFromHex: _getColorFromHex,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.error.withOpacity(0.08),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.25),
              ),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 36,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Error al cargar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          OrganizacionOutlineButton(label: 'Reintentar', onTap: _onRefresh),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool isFiltered = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? _kGold : theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.06),
              border: Border.all(
                color: accentColor.withOpacity(0.22),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              size: 36,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback:
                (b) =>
                    isDark
                        ? const LinearGradient(
                          colors: [_kGoldDeep, _kGold, Color(0xFFFFE082)],
                        ).createShader(b)
                        : LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ).createShader(b),
            child: const Text(
              'Sin organizaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? (_selectedTipoFilter != null
                    ? 'No hay resultados para este filtro'
                    : 'No se encontraron resultados para la búsqueda')
                : 'No se encontraron organizaciones',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          OrganizacionOutlineButton(
            label: isFiltered ? 'Limpiar' : 'Recargar',
            onTap: isFiltered ? () => _onTipoFilterChanged(null) : _onRefresh,
          ),
        ],
      ),
    );
  }

  void _showGoldSnackBar(String message, {bool isError = false}) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isError
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isError
                    ? theme.colorScheme.error.withOpacity(0.35)
                    : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded,
              color:
                  isError ? theme.colorScheme.error : theme.colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
