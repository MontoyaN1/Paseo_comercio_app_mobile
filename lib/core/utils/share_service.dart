// lib/core/utils/share_service.dart

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_config.dart';

/// Servicio para compartir tiendas, productos, plazoletas y organizaciones
class ShareService {
  final AppConfig _appConfig = AppConfig();

  /// Compartir una tienda
  Future<void> compartirTienda({
    required int tiendaId,
    required String nombreTienda,
    String? descripcion,
  }) async {
    final url = '${_appConfig.companyUrl}/store/$tiendaId';
    final texto =
        descripcion != null && descripcion.isNotEmpty
            ? 'Mira esta tienda: $nombreTienda\n$descripcion\n\n$url'
            : 'Mira esta tienda: $nombreTienda\n\n$url';

    await Share.share(texto, subject: nombreTienda);
  }

  /// Compartir un producto
  Future<void> compartirProducto({
    required int productoId,
    required String nombreProducto,
    String? descripcion,
    double? precio,
  }) async {
    final url = '${_appConfig.companyUrl}/producto/$productoId';
    String texto = 'Mira este producto: $nombreProducto';

    if (precio != null) {
      texto += ' - \$${precio.toStringAsFixed(0)}';
    }
    if (descripcion != null && descripcion.isNotEmpty) {
      texto += '\n$descripcion';
    }
    texto += '\n\n$url';

    await Share.share(texto, subject: nombreProducto);
  }

  /// Compartir una plazoleta
  Future<void> compartirPlazoleta({
    required String slug,
    required String nombrePlazoleta,
    String? descripcion,
  }) async {
    final url = '${_appConfig.companyUrl}/plazoleta/$slug';
    final texto =
        descripcion != null && descripcion.isNotEmpty
            ? 'Mira esta plazoleta: $nombrePlazoleta\n$descripcion\n\n$url'
            : 'Mira esta plazoleta: $nombrePlazoleta\n\n$url';

    await Share.share(texto, subject: nombrePlazoleta);
  }

  /// Compartir una organización
  Future<void> compartirOrganizacion({
    required int organizacionId,
    required String nombreOrganizacion,
    String? descripcion,
  }) async {
    final url = '${_appConfig.companyUrl}/organizacion/$organizacionId';
    final texto =
        descripcion != null && descripcion.isNotEmpty
            ? 'Mira esta organización: $nombreOrganizacion\n$descripcion\n\n$url'
            : 'Mira esta organización: $nombreOrganizacion\n\n$url';

    await Share.share(texto, subject: nombreOrganizacion);
  }

  /// Abrir URL en navegador
  Future<void> abrirUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
