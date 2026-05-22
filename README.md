

# ShadowNet - Operación Camaleón

Aplicación Flutter con **perfil dinámico** que cambia completamente su identidad visual según la facción seleccionada por el agente.

---

## 🎯 Objetivo del Proyecto

Desarrollar una aplicación donde al cambiar de facción (**Hacker**, **Enforcer** o **Ghost**), toda la interfaz se adapte dinámicamente: colores, tipografía, imágenes y estilo.

---

## 🔧 Cómo se extrae el SeedColor / Paleta de Colores

En este proyecto **no se utiliza** `ColorScheme.fromSeed()` ni extracción automática de color desde la imagen, ya que se buscaba un control total y coherencia visual.

### Enfoque implementado:

- Los colores de cada facción están **definidos manualmente** en `lib/models/faction_model.dart`.

- Cada facción tiene su propia paleta diseñada para mantener la estética cyberpunk/terminal.

- Se utiliza la clase `Faction` para generar un `ThemeData` completo.

- El `FactionProvider` maneja el estado global y aplica el tema dinámicamente.

**Ventaja:** Mayor control artístico y mejor rendimiento.

---

## ♿ Configuración del Árbol de Semantics (Accesibilidad)

Se implementó un buen nivel de accesibilidad para cumplir con el requisito del reto:

### Principales implementaciones:

- **Botón de Cerrar Sesión** (requisito obligatorio):

  ```dart

  Semantics(

    label: 'Botón: Finalizar misión y borrar rastro',

    button: true,

    hint: 'Esta acción cerrará tu sesión y eliminará todo el rastro de actividad',

    child: ...

  );

  ```

- Todos los botones y elementos interactivos tienen etiquetas semánticas claras.

- Selector de facciones con descripción completa y estado `selected`.

- Uso combinado de `Semantics` + `Tooltip` donde es necesario.

- Textos con `overflow: TextOverflow.ellipsis` y `maxLines` para mejor compatibilidad con lectores de pantalla.

- AppBar con labels descriptivos.

---

## 🛠️ Tecnologías Utilizadas

- Flutter + Dart

- Provider (State Management)

- Google Fonts (JetBrains Mono, Orbitron, Share Tech)

- flutter_map + geolocator

- Semantics (Accesibilidad)

- Animaciones con AnimationController

---

## 📁 Estructura del Proyecto

```

shadownet/

├── assets/

│   └── images/

│       └── factions/

│           ├── hacker.jpg

│           ├── enforcer.jpg

│           └── ghost.jpg

├── lib/

│   ├── models/

│   │   ├── faction_model.dart

│   │   └── node_model.dart

│   ├── screens/

│   │   ├── profile_screen.dart

│   │   ├── radar_screen.dart

│   │   └── ...

│   ├── services/

│   │   ├── faction_provider.dart

│   │   └── vibration_service.dart

│   ├── widgets/

│   │   └── terminal_widgets.dart

│   ├── theme/

│   │   └── terminal_theme.dart

│   └── main.dart

├── pubspec.yaml

└── README.md

```

---

## 🚀 Cómo Ejecutar el Proyecto

```bash

# Clonar el repositorio

git clone -b developer https://github.com/OscarTorresQuintero/shadownet.git

# Entrar a la carpeta

cd shadownet

# Instalar dependencias

flutter pub get

# Ejecutar

flutter run

```

---

**Desarrollado como entrega final de la "Operación Camaleón"**
