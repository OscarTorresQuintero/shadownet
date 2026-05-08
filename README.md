 # ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
# ARCHIVO CLASIFICADO — SHADOWNET
# NIVEL DE ACCESO: OPERADOR SENIOR
# FECHA: [REDACTADO] — AÑO 2084
# ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

```
> Acceso concedido.
> Cargando archivo de briefing...
> Leyendo reporte de misión...  █
```

---

## 📡 DESCRIPCIÓN DEL PROTOCOLO

**SHADOWNET** es la red de comunicaciones encubierta de la Resistencia.
Para operar bajo el radar de **The Core** (IA Central que controla
todas las comunicaciones en 2084), cada Operador debe instalar
este protocolo en su dispositivo de campo.

El sistema tiene tres capas de seguridad:

| Fase | Nombre | Descripción |
|------|--------|-------------|
| 01 | ESCANEO BIOMÉTRICO | Valida que el operador sea humano |
| 02 | GEO-RADAR DE NODOS | Desbloquea misiones por ubicación física |
| 03 | TERMINAL DE COMANDOS | Ejecuta las operaciones encubiertas |

---

## 🔐 CONFIGURACIÓN DE PERMISOS DE CAMPO (Android)

> ⚠️ ATENCIÓN OPERADOR: Sin estos permisos el protocolo
> no podrá acceder al hardware del dispositivo.
> The Core detectará la instalación incompleta.

### PASO 1 — Abrir el archivo de permisos

Localiza este archivo en tu dispositivo de campo:

```
android/app/src/main/AndroidManifest.xml
```

### PASO 2 — Insertar los permisos de hardware

Agrega estas líneas **antes** de la etiqueta `<application>`:

```xml
<!-- ═══ PERMISOS DEL PROTOCOLO SHADOWNET ═══ -->

<!-- FASE 1: Escáner biométrico de identidad -->
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>

<!-- FASE 2: Triangulación de nodos por GPS -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- FASE 3: Señales de confirmación en Código Morse -->
<uses-permission android:name="android.permission.VIBRATE"/>

<!-- Descarga de mapas de la zona de operaciones -->
<uses-permission android:name="android.permission.INTERNET"/>
```

### PASO 3 — Activar la librería biométrica

Dentro de la etiqueta `<application>` agrega:

```xml
<uses-library
    android:name="android.hardware.fingerprint"
    android:required="false"/>
```

### PASO 4 — Configurar versión mínima de Android

Abre este archivo:

```
android/app/build.gradle
```

Localiza `defaultConfig` y cambia `minSdkVersion`:

```gradle
defaultConfig {
    minSdkVersion 23  // Android 6.0 mínimo — requerido por biometría
    targetSdkVersion 34
}
```

> ⚠️ Si usas una versión anterior a Android 6.0 (API 23),
> el escáner biométrico no funcionará y The Core
> detectará la brecha de seguridad.

### PASO 5 — Autorizar permisos en el dispositivo

La primera vez que el Operador ejecute el protocolo,
el sistema solicitará autorización manual:

```
Ajustes → Apps → ShadowNet → Permisos

  ✓ Ubicación      →  Permitir siempre
  ✓ Biometría      →  Se activa automáticamente
```

---

## 📦 DESPLIEGUE DEL PROTOCOLO

```bash
# Clonar el repositorio de la Resistencia
git clone https://github.com/[OPERADOR]/shadownet.git
cd shadownet

# Instalar módulos de operación
flutter pub get

# Verificar integridad del sistema
flutter doctor

# Desplegar en dispositivo de campo
flutter run --release
```

---

## 🗺️ NODOS DE MISIÓN — MOSQUERA, CUNDINAMARCA

Los nodos solo son visibles cuando el Operador
está a menos de **500 metros** de la ubicación.

```
  NODO-ALPHA ──► SENA Mosquera
                 LAT: 4.7073 / LON: -74.2296
                 MISIÓN: Hackear servidor de notas

  NODO-BETA  ──► Parque Principal
                 LAT: 4.7056 / LON: -74.2341
                 MISIÓN: Interceptar señal de radio

  NODO-GAMMA ──► Zona Industrial
                 LAT: 4.7108 / LON: -74.2198
                 MISIÓN: Sabotaje de drones
```

---

## 🌿 PROTOCOLO DE RAMAS — GIT

```
main        ← Código de producción (PROTEGIDO)
  │
  └── develop ← Integración de operaciones
        │
        ├── feature/fase-1-biometria
        ├── feature/fase-2-georadar
        └── feature/fase-3-terminal
```

> REGLA DE CAMPO: Todo código se integra a `main`
> únicamente mediante **Pull Request** revisado
> por al menos 1 Operador Senior.
> Commits directos a `main` están prohibidos.

---

## 🔧 DEPENDENCIAS CLASIFICADAS

```yaml
local_auth: ^2.3.0    # Escáner biométrico
geolocator: ^12.0.0   # Triangulación GPS
flutter_map: ^7.0.0   # Mapas de zona operativa
latlong2: ^0.9.1      # Manejo de coordenadas
vibration: ^2.0.0     # Señales Morse
google_fonts: ^6.2.1  # Interfaz de terminal
```

---

## 📊 ESTADO DEL SISTEMA

```
[██████████] BIOMETRÍA       OPERATIVO
[██████████] GEOLOCALIZACIÓN OPERATIVO
[██████████] TERMINAL        OPERATIVO
[██████████] MORSE           OPERATIVO
```

---

*Este documento se autodestruye si cae en manos de The Core.*

```
> FIN DE TRANSMISIÓN
> Cerrando sesión segura...  █
```