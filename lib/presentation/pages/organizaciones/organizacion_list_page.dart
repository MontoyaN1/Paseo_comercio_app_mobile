// lib/presentation/pages/organizaciones/organizacion_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/organizacion.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../presentation/blocs/organizacion/organizacion_bloc.dart';
import '../../../../presentation/widgets/profile_floating_button.dart';
import '../../../../core/routing/app_router.dart';

class OrganizacionListPage extends StatefulWidget {
  const OrganizacionListPage({super.key});

  @override
  State<OrganizacionListPage> createState() => _OrganizacionListPageState();
}

class _OrganizacionListPageState extends State<OrganizacionListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _isSearching = false;
  TipoOrganizacion? _selectedTipoFilter;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrganizaciones();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrganizaciones() {
    context.read<OrganizacionBloc>().add(
      LoadOrganizaciones(page: _currentPage, limit: _limit),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreOrganizaciones();
    }
  }

  void _loadMoreOrganizaciones() {
    final state = context.read<OrganizacionBloc>().state;
    if (state is OrganizacionLoaded && state.hasMore) {
      _currentPage++;
      context.read<OrganizacionBloc>().add(
        LoadOrganizaciones(page: _currentPage, limit: _limit),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      context.read<OrganizacionBloc>().add(SearchOrganizaciones(query: query));
    } else {
      _resetToInitial();
    }
  }

  void _onTipoFilterChanged(TipoOrganizacion? tipo) {
    setState(() {
      _selectedTipoFilter = tipo;
    });

    if (tipo != null) {
      context.read<OrganizacionBloc>().add(FilterByTipo(tipo: tipo));
    } else {
      _resetToInitial();
    }
  }

  void _onOrganizacionTap(Organizacion organizacion) {
    AppRouter.router.go(
      '/organizaciones/${organizacion.id}',
      extra: organizacion,
    );
  }

  void _onRefresh() {
    _currentPage = 1;
    _loadOrganizaciones();
  }

  void _resetToInitial() {
    context.read<OrganizacionBloc>().add(const ResetOrganizacionState());
    _currentPage = 1;
    _loadOrganizaciones();
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
        return 'Otra Organización';
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
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizacionBloc, OrganizacionState>(
      listener: (context, state) {
        if (state is OrganizacionErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title:
                _isSearching
                    ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Buscar organizaciones...',
                        border: InputBorder.none,
                      ),
                      onChanged: _onSearchChanged,
                    )
                    : const Text('Organizaciones'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey[800],
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                      _resetToInitial();
                    }
                  });
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildFilterBar(),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: _buildBody(state),
          ),
          floatingActionButton: ProfileFloatingButton(
            hideOrganizacionesOption: true,
          ),
        );
      },
    );
  }

  Widget _buildBody(OrganizacionState state) {
    if (state is OrganizacionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrganizacionErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar organizaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    List<Organizacion> organizacionesToShow = [];

    if (state is OrganizacionLoaded) {
      organizacionesToShow = state.organizaciones;
    } else if (state is OrganizacionSearchApplied) {
      organizacionesToShow = state.resultados;
    } else if (state is OrganizacionFilterApplied) {
      organizacionesToShow = state.organizacionesFiltradas;
    } else if (state is OrganizacionInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay organizaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTipoFilter != null
                  ? 'No hay organizaciones de tipo ${_getDescripcionTipo(_selectedTipoFilter!).toLowerCase()}'
                  : 'No se encontraron organizaciones',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    if (organizacionesToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay organizaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTipoFilter != null
                  ? 'No hay organizaciones de tipo ${_getDescripcionTipo(_selectedTipoFilter!).toLowerCase()}'
                  : 'No se encontraron organizaciones',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount:
          organizacionesToShow.length +
          (state is OrganizacionLoaded && state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == organizacionesToShow.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final organizacion = organizacionesToShow[index];
        return _OrganizacionCard(
          organizacion: organizacion,
          onTap: () => _onOrganizacionTap(organizacion),
          getDescripcionTipo: _getDescripcionTipo,
          getColorFromHex: _getColorFromHex,
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: 'Todas',
              selected: _selectedTipoFilter == null,
              onSelected: () => _onTipoFilterChanged(null),
            ),
            const SizedBox(width: 8),
            ...TipoOrganizacion.values.map((tipo) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: _getDescripcionTipo(tipo).split(' ').last,
                  selected: _selectedTipoFilter == tipo,
                  onSelected: () => _onTipoFilterChanged(tipo),
                  icon: Text(_getIconoTipo(tipo)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OrganizacionCard extends StatelessWidget {
  final Organizacion organizacion;
  final VoidCallback onTap;
  final String Function(TipoOrganizacion) getDescripcionTipo;
  final Color Function(String) getColorFromHex;

  const _OrganizacionCard({
    required this.organizacion,
    required this.onTap,
    required this.getDescripcionTipo,
    required this.getColorFromHex,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: getColorFromHex(
                        organizacion.colorTipo,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: getColorFromHex(
                          organizacion.colorTipo,
                        ).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child:
                          organizacion.logoUrlPrincipal != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  organizacion.logoUrlPrincipal!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Text(
                                organizacion.iconoTipo,
                                style: const TextStyle(fontSize: 24),
                              ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          organizacion.nombreParaMostrar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          organizacion.descripcion ?? 'Sin descripción',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getColorFromHex(
                              organizacion.colorTipo,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            getDescripcionTipo(
                              organizacion.tipo,
                            ).split(' ').last,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: getColorFromHex(organizacion.colorTipo),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.store,
                    value: organizacion.totalTiendas ?? 0,
                    label: 'Tiendas',
                    color: Colors.blue,
                  ),
                  _StatItem(
                    icon: Icons.people,
                    value: organizacion.totalMiembros ?? 0,
                    label: 'Miembros',
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Widget? icon;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      avatar: icon,
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
      checkmarkColor: const Color(0xFF4CAF50),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF4CAF50) : Colors.grey[700],
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
          width: selected ? 1.5 : 1,
        ),
      ),
    );
  }
}
