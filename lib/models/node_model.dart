import 'package:latlong2/latlong.dart';

// ── ESTADOS POSIBLES DE UN NODO ──────────────
enum NodeStatus {
  locked,     // Estás lejos, no se ve en el mapa
  nearby,     // Estás a menos de 500m, se activa
  active,     // Entraste a la misión
  completed,  // Misión terminada
}
class MissionNode {
  final String id;           // "ALPHA", "BETA", "GAMMA"
  final String codename;     // "NODO-ALPHA"
  final String location;     // Nombre del lugar real
  final String mission;      // Descripción corta
  final String missionDetails; // Texto largo del terminal
  final LatLng coordinates;  // Coordenadas GPS
  NodeStatus status;         // Estado actual del nodo

  MissionNode({
    required this.id,
    required this.codename,
    required this.location,
    required this.mission,
    required this.missionDetails,
    required this.coordinates,
    this.status = NodeStatus.locked, // Por defecto bloqueado
  });
}
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