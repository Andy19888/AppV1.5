# RepoCheck - Sistema de Control de Reposición Tercerizada

RepoCheck es una aplicación multiplataforma desarrollada en Flutter para el control y gestión de tareas de reposición tercerizada. La aplicación permite a repositores, supervisores y administradores gestionar eficientemente el proceso de reposición en diferentes sucursales.

## Características Principales

### 🔐 Sistema de Autenticación
- Login con email y contraseña
- Registro de nuevos usuarios
- Recuperación de contraseña
- Roles diferenciados (Repositor, Supervisor, Administrador)

### 📍 Gestión de Ubicaciones
- Selección jerárquica: Provincia → Localidad → Cadena → Sucursal
- Sistema de autorización para repositores
- Gestión de permisos por ubicación

### 👷 Interfaz del Repositor
- Lista de tareas pendientes y completadas
- Captura de fotos antes/después de la reposición
- Registro automático de GPS y timestamp
- Formulario de datos de reposición
- Historial de actividades

### 👨‍💼 Dashboard del Supervisor
- Revisión y aprobación de tareas completadas
- Gestión de solicitudes de autorización
- Estadísticas y reportes
- Visualización de fotos en pantalla completa

### 🔧 Panel de Administración
- Gestión completa de usuarios
- Administración de ubicaciones
- Creación y asignación de tareas
- Reportes y análisis avanzados
- Exportación de datos

## Soporte Multiplataforma

### 🖥️ Windows
- ✅ Interfaz de usuario completa
- ✅ Firebase Auth, Firestore, Storage
- ❌ GPS/Geolocalización (usa datos mock)
- ❌ Cámara (usa selector de archivos)
- **Uso recomendado**: Desarrollo rápido de UI

### 🌐 Web/Chrome
- ✅ Interfaz de usuario completa
- ✅ Firebase completo
- ⚠️ GPS limitado (requiere permisos web)
- ❌ Cámara nativa (usa selector de archivos)
- **Uso recomendado**: Pruebas de Firebase

### 📱 Android/iOS
- ✅ Funcionalidad completa
- ✅ Firebase completo
- ✅ GPS/Geolocalización nativa
- ✅ Cámara nativa
- **Uso recomendado**: Producción y pruebas completas

## Tecnologías Utilizadas

- **Flutter 3.16+** - Framework de desarrollo
- **Dart 3.2+** - Lenguaje de programación
- **Firebase Core 4.0.0** - Configuración base
- **Firebase Auth 6.0.1** - Autenticación de usuarios
- **Cloud Firestore 6.0.0** - Base de datos NoSQL
- **Firebase Storage 13.0.0** - Almacenamiento de imágenes
- **Riverpod** - Gestión de estado
- **Go Router** - Navegación
- **Geolocator** - Servicios de geolocalización
- **Image Picker** - Captura de fotos
- **Permission Handler** - Gestión de permisos

## Estructura del Proyecto

\`\`\`
lib/
├── core/
│   ├── models/          # Modelos de datos
│   ├── services/        # Servicios (Firebase, Auth, etc.)
│   ├── theme/           # Tema y estilos
│   └── router/          # Configuración de rutas
├── features/
│   ├── auth/            # Autenticación
│   ├── location/        # Selección de ubicación
│   ├── repositor/       # Interfaz del repositor
│   ├── supervisor/      # Dashboard del supervisor
│   ├── admin/           # Panel de administración
│   └── common/          # Componentes compartidos
└── main.dart            # Punto de entrada
\`\`\`

## Configuración

### Prerrequisitos
- Flutter SDK 3.16 o superior
- Dart SDK 3.2 o superior
- Android Studio / VS Code
- Cuenta de Firebase

### Instalación

1. **Clonar el repositorio**
\`\`\`bash
git clone https://github.com/tu-usuario/repocheck.git
cd repocheck
\`\`\`

2. **Instalar dependencias**
\`\`\`bash
flutter pub get
\`\`\`

3. **Configurar Firebase**
   - Crear un proyecto en Firebase Console
   - Configurar aplicaciones para cada plataforma
   - El archivo `firebase_options.dart` ya está configurado
   - Habilitar Authentication, Firestore y Storage

4. **Configurar permisos Android**
   Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`

## Comandos de Ejecución

### Windows (Desarrollo UI)
\`\`\`bash
flutter run -d windows
\`\`\`

### Web/Chrome (Pruebas Firebase)
\`\`\`bash
flutter run -d chrome
\`\`\`

### Android
\`\`\`bash
flutter run -d android
# o especificar dispositivo
flutter devices
flutter run -d <device_id>
\`\`\`

### iOS
\`\`\`bash
flutter run -d ios
# o especificar dispositivo
flutter run -d <device_id>
\`\`\`

## Uso de la Aplicación

### Para Repositores
1. Iniciar sesión con credenciales
2. Seleccionar ubicación (si no está autorizado, solicitar permiso)
3. Ver tareas asignadas
4. Completar tareas con fotos y datos
5. Revisar historial

### Para Supervisores
1. Acceder al dashboard
2. Revisar tareas completadas
3. Aprobar o rechazar con comentarios
4. Gestionar solicitudes de autorización
5. Generar reportes

### Para Administradores
1. Gestionar usuarios y roles
2. Administrar ubicaciones
3. Crear y asignar tareas
4. Acceder a análisis completos
5. Exportar datos

## Base de Datos

### Colecciones Firestore
- `users` - Información de usuarios
- `locations` - Datos de ubicaciones
- `tasks` - Tareas de reposición
- `authorization_requests` - Solicitudes de autorización

### Estructura de Datos
Cada colección tiene modelos bien definidos con validación y serialización JSON.

## Seguridad

- Autenticación obligatoria para todas las funciones
- Reglas de seguridad en Firestore
- Validación de permisos por rol
- Encriptación de datos sensibles

## Testing

\`\`\`bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter test integration_test/
\`\`\`

## Deployment

### Android
\`\`\`bash
flutter build apk --release
# o
flutter build appbundle --release
\`\`\`

### Web
\`\`\`bash
flutter build web --release
\`\`\`

### Windows
\`\`\`bash
flutter build windows --release
\`\`\`

## Recomendaciones de Desarrollo

1. **Desarrollo UI**: Usar Windows para desarrollo rápido de interfaces
2. **Pruebas Firebase**: Usar Chrome/Web para probar funcionalidades de base de datos
3. **Pruebas Completas**: Usar Android/iOS para validar funcionalidad completa
4. **Producción**: Validar siempre en Android/iOS antes de publicar

## Contribución

1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## Soporte

Para soporte técnico o reportar bugs:
- Email: soporte@repocheck.com
- Issues: GitHub Issues

## Changelog

### v1.1.0
- **NUEVO**: Soporte multiplataforma (Windows/Web/Android/iOS)
- **NUEVO**: Condicionales de plataforma para funcionalidades móviles
- **ACTUALIZADO**: Firebase a versiones oficiales más recientes
- **MEJORADO**: Documentación de configuración multiplataforma

### v1.0.0
- Lanzamiento inicial
- Sistema completo de autenticación
- Gestión de ubicaciones y tareas
- Interfaces para todos los roles
- Integración completa con Firebase
