import 'package:latlong2/latlong.dart';

/// Estados posibles de un nodo de misión.
///
/// - [locked]: El operador está lejos (>500m). No visible.
/// - [nearby]: El operador está cerca (<500m). Activado.
/// - [active]: El operador entró a la misión.
/// - [completed]: Misión finalizada exitosamente.
enum NodeStatus {
  locked,
  nearby,
  active,
  completed,
}

/// Representa un nodo de misión en el mapa de ShadowNet.
///
/// Cada nodo tiene una ubicación física en Mosquera y se activa
/// cuando el operador se acerca a menos de 500m.
class MissionNode {
  /// Identificador corto del nodo. Ej: "ALPHA".
  final String id;

  /// Nombre en clave del nodo. Ej: "NODO-ALPHA".
  final String codename;

  /// Nombre del lugar físico donde está ubicado el nodo.
  final String location;

  /// Breve descripción de la misión asociada al nodo.
  final String mission;

  /// Detalles extendidos de la misión mostrados en el terminal.
  final String missionDetails;

  /// Coordenadas GPS del nodo en Mosquera, Cundinamarca.
  final LatLng coordinates;

  /// Estado actual del nodo. Cambia según la distancia del operador.
  NodeStatus status;

  MissionNode({
    required this.id,
    required this.codename,
    required this.location,
    required this.mission,
    required this.missionDetails,
    required this.coordinates,
    this.status = NodeStatus.locked,
  });
}

/// Lista de nodos de misión de ShadowNet.
///
/// Cada nodo se activa cuando el operador se acerca a menos de 500m,
/// lo que permite que el juego detecte la presencia y actualice el estado.
final List<MissionNode> shadowNetNodes = [

  MissionNode(
    id: 'ALPHA',
    codename: 'NODO-ALPHA',
    location: 'SENA Mosquera',
    mission: 'Hackear el servidor de notas',
    missionDetails:
      '> OBJETIVO: Infiltrar ACADEMICA-NET\n'
      '> Extraer credenciales del servidor\n'
      '> Modificar registros sin dejar rastro\n'
      '> PRIORIDAD: CRÍTICA',
    coordinates: LatLng(4.7073, -74.2296),
  ),

  MissionNode(
    id: 'BETA',
    codename: 'NODO-BETA',
    location: 'Parque Principal Mosquera',
    mission: 'Interceptar señal de radio',
    missionDetails:
      '> OBJETIVO: Frecuencia 98.7 MHz\n'
      '> Desplegar antena de captura\n'
      '> Decodificar transmisión cifrada\n'
      '> PRIORIDAD: ALTA',
    coordinates: LatLng(4.7056, -74.2341),
  ),

  MissionNode(
    id: 'GAMMA',
    codename: 'NODO-GAMMA',
    location: 'Zona Industrial Mosquera',
    mission: 'Sabotaje de drones',
    missionDetails:
      '> OBJETIVO: 7 drones activos\n'
      '> Inyectar virus en firmware\n'
      '> Redirigir a zona de exclusión\n'
      '> PRIORIDAD: MÁXIMA',
    coordinates: LatLng(4.7108, -74.2198),
  ),

];
