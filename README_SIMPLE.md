# Paseo del Comercio - Aplicación Móvil (Versión Simplificada)

Esta es una versión simplificada de la aplicación para probar la conexión con Supabase y validar el backend antes de construir la UI completa.

## 🚀 Comenzar Rápido

### 1. Configurar variables de entorno
```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env con tus credenciales
# Necesitas: SUPABASE_URL y SUPABASE_ANON_KEY
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar aplicación de prueba
```bash
flutter run lib/main_simple.dart
```

## 📁 Estructura Simplificada

```
lib/
├── main_simple.dart          # Aplicación de prueba de conexión
├── main.dart                # Aplicación completa (en desarrollo)
└── (otros archivos)         # Arquitectura completa
```

## 🔧 Archivo .env (Mínimo requerido)

```env
# Configuración MÍNIMA requerida
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anon

# Configuración opcional (para desarrollo)
DEBUG_MODE=true
APP_NAME=Paseo del Comercio
```

## 🧪 Qué prueba main_simple.dart

1. **Conexión con Supabase** - Verifica que puedas conectarte a tu base de datos
2. **Consulta de tiendas** - Obtiene las primeras 10 tiendas de la tabla `tienda`
3. **Manejo de errores** - Muestra errores de conexión claramente
4. **Interfaz básica** - Muestra tiendas en una lista interactiva

## 📊 Funcionalidades de la App de Prueba

- ✅ Conexión a Supabase
- ✅ Listado de tiendas
- ✅ Detalles de cada tienda
- ✅ Botón de recarga
- ✅ Indicador de estado de conexión
- ✅ Manejo de errores

## 🚨 Solución de Problemas

### Error: "Invalid login credentials"
- Verifica que `SUPABASE_URL` y `SUPABASE_ANON_KEY` sean correctos
- Asegúrate de que tu proyecto Supabase esté activo

### Error: "relation does not exist"
- La tabla `tienda` no existe en tu base de datos
- Ejecuta el script SQL proporcionado para crear las tablas

### Error: "Network error"
- Verifica tu conexión a internet
- Asegúrate de que la URL de Supabase sea accesible

## 📈 Próximos Pasos

Una vez que la app de prueba funcione:

1. **Implementar autenticación** - Integrar Clerk
2. **Agregar sistema de caché** - Usar Hive para offline
3. **Crear repositorios** - Para cada tabla de la base de datos
4. **Construir UI completa** - Pantallas de tiendas, productos, etc.

## 🔗 Recursos

- [Documentación de Supabase Flutter](https://supabase.com/docs/guides/flutter)
- [Tablas de la base de datos](ARQUITECTURA_CENTRO_COMERCIAL.md)
- [Arquitectura completa](ARQUITECTURA_CENTRO_COMERCIAL.md)

## 📞 Soporte

Si encuentras problemas:
1. Verifica las credenciales en `.env`
2. Revisa la consola de Flutter para errores detallados
3. Consulta la documentación de Supabase

---

**Nota**: Esta versión simplificada es solo para validar la conexión con el backend. La arquitectura completa está documentada en `ARQUITECTURA_CENTRO_COMERCIAL.md`.