import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:paseo_del_comercio/presentation/widgets/custom_app_bar.dart';
import 'package:paseo_del_comercio/di/service_locator.dart';
import 'package:paseo_del_comercio/core/utils/firebase_auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DetailAppBar(title: 'Perfil', showProfileButton: false),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user != null) {
            return _buildProfileContent(context, user);
          } else {
            return _buildSignedOutContent(context);
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar y nombre
          CircleAvatar(
            radius: 60,
            backgroundImage:
                user.photoURL != null && user.photoURL!.isNotEmpty
                    ? NetworkImage(user.photoURL!)
                    : null,
            child:
                user.photoURL == null || user.photoURL!.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
          ),
          const SizedBox(height: 20),
          Text(
            user.displayName ?? 'Usuario',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            user.email ?? 'usuario@ejemplo.com',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Sección de información
          _buildInfoSection(context, user),

          // Sección de acciones
          _buildActionsSection(context),

          // Botón de cerrar sesión
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => _performLogout(context),
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Cerrar sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información de la cuenta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            _buildInfoItem(
              icon: Icons.person_outline,
              label: 'Nombre completo',
              value: user?.displayName ?? 'No disponible',
            ),
            const Divider(height: 20),
            _buildInfoItem(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? 'No disponible',
            ),
            const Divider(height: 20),
            _buildInfoItem(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: user?.phoneNumber ?? 'No disponible',
            ),
            const Divider(height: 20),
            _buildInfoItem(
              icon: Icons.calendar_today_outlined,
              label: 'Miembro desde',
              value:
                  user?.metadata?.creationTime != null
                      ? '${user!.metadata!.creationTime!.day}/${user!.metadata!.creationTime!.month}/${user!.metadata!.creationTime!.year}'
                      : 'No disponible',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          _buildActionTile(
            context,
            icon: Icons.favorite_outline,
            title: 'Favoritos',
            subtitle: 'Tus tiendas y productos favoritos',
            onTap: () {
              // TODO: Navegar a favoritos
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildActionTile(
            context,
            icon: Icons.history_outlined,
            title: 'Historial',
            subtitle: 'Actividad reciente',
            onTap: () {
              // TODO: Navegar a historial
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildActionTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Configurar preferencias',
            onTap: () {
              // TODO: Navegar a notificaciones
            },
          ),
          const Divider(height: 1, indent: 16),
          _buildActionTile(
            context,
            icon: Icons.help_outline,
            title: 'Ayuda y soporte',
            subtitle: 'Preguntas frecuentes y contacto',
            onTap: () {
              // TODO: Navegar a ayuda
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// Realizar cierre de sesión con manejo adecuado
  Future<void> _performLogout(BuildContext context) async {
    // Mostrar diálogo de confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '¿Estás seguro de que quieres cerrar sesión?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    // Si el usuario cancela, no hacer nada
    if (confirm != true) {
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
      );

      final authService = getIt<FirebaseAuthService>();
      final result = await authService.signOut();

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      result.fold(
        (success) {
          // Redirigir a login
          context.go('/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión cerrada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
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
    } catch (error) {
      // Cerrar diálogo de carga si existe
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSignedOutContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Inicia sesión para ver tu perfil',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Accede a tus favoritos, historial y configuración personal',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Navegar a login
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Continuar como invitado'),
            ),
          ],
        ),
      ),
    );
  }
}
