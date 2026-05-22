import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/faction_model.dart';
import '../models/node_model.dart';
import '../services/faction_provider.dart';
import '../services/vibration_service.dart';
import '../widgets/terminal_widgets.dart';
import 'mission_screen.dart';
import 'profile_screen.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  static const double _kActivationRadius = 500.0;
  final List<MissionNode> _nodes = shadowNetNodes;
  String _statusLine = '> Triangulando posición...';

  late AnimationController _radarController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _initLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _radarController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _statusLine = '> ERROR: GPS desactivado');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _statusLine = '> ERROR: Permiso de ubicación denegado');
      return;
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position position) {
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _updateNodes(position);
    });
    try {
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        _mapController.camera.zoom,
      );
    } catch (_) {}
  }

  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dPhi = (lat2 - lat1) * pi / 180;
    final dLambda = (lon2 - lon1) * pi / 180;
    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) *
        sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  void _updateNodes(Position userPos) {
    double minDist = double.infinity;
    MissionNode? nearest;

    for (final node in _nodes) {
      if (node.status == NodeStatus.completed) continue;

      final dist = _calcularDistancia(
        userPos.latitude, userPos.longitude,
        node.coordinates.latitude, node.coordinates.longitude,
      );

      if (dist < minDist) {
        minDist = dist;
        nearest = node;
      }

      final wasLocked = node.status == NodeStatus.locked;
      node.status = dist <= _kActivationRadius
          ? NodeStatus.nearby
          : NodeStatus.locked;

      if (wasLocked && node.status == NodeStatus.nearby) {
        VibrationService.nodeDetected();
      }
    }

    _statusLine = nearest != null
        ? '> NODO MÁS CERCANO: ${nearest.codename} (${minDist.round()}m)'
        : '> Escaneando zona...';
  }

  Future<void> _abrirMision(MissionNode node) async {
    if (node.status != NodeStatus.nearby) return;
    node.status = NodeStatus.active;

    final completada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MissionScreen(node: node)),
    );

    setState(() {
      node.status = completada == true ? NodeStatus.completed : NodeStatus.nearby;
    });
  }

  @override
  Widget build(BuildContext context) {
    final faction = context.watch<FactionProvider>().currentFaction;

    return Scaffold(
      backgroundColor: faction.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(faction),
            Expanded(child: _buildMapa(faction)),
            _buildListaNodos(faction),
            _buildBottomBar(faction),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGETS ====================

  Widget _buildTopBar(Faction faction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: faction.appBarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _radarController,
                builder: (_, __) => Transform.rotate(
                  angle: _radarController.value * 2 * pi,
                  child: Icon(Icons.radar, color: faction.primaryColor, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GEO-RADAR DE NODOS',
                  style: faction.textStyle(size: 14, bold: true),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                _currentPosition != null ? 'GPS ●' : 'GPS ○',
                style: faction.textStyle(
                  size: 12,
                  color: _currentPosition != null ? faction.primaryColor : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 110),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: faction.primaryColor.withOpacity(0.8)),
                    color: faction.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(faction.symbol, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          faction.name,
                          style: faction.textStyle(size: 11, bold: true),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _statusLine,
            style: faction.textStyle(size: 11, color: faction.primaryColor.withOpacity(0.8)),
            overflow: TextOverflow.ellipsis,
          ),
          if (_currentPosition != null)
            Text(
              '> LAT: ${_currentPosition!.latitude.toStringAsFixed(5)}  LON: ${_currentPosition!.longitude.toStringAsFixed(5)}',
              style: faction.textStyle(size: 10, color: faction.primaryColor.withOpacity(0.5)),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildMapa(Faction faction) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: faction.primaryColor.withOpacity(0.4)),
      ),
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(4.7066, -74.2296),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.shadownet.app',
            tileBuilder: (context, tile, _) => ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -0.2, 0, 0, 0, 0.1,
                 0, -0.2, 0, 0, 0.3,
                 0, 0, -0.2, 0, 0.1,
                 0, 0,  0,  1, 0,
              ]),
              child: tile,
            ),
          ),

          CircleLayer(
            circles: _nodes.map((node) {
              final color = node.status == NodeStatus.completed
                  ? faction.accentColor
                  : node.status == NodeStatus.nearby
                      ? faction.primaryColor
                      : faction.primaryColor.withOpacity(0.4);

              return CircleMarker(
                point: node.coordinates,
                radius: _kActivationRadius,
                useRadiusInMeter: true,
                color: color.withOpacity(0.05),
                borderColor: color.withOpacity(0.4),
                borderStrokeWidth: 1,
              );
            }).toList(),
          ),

          MarkerLayer(
            markers: [
              if (_currentPosition != null)
                Marker(
                  point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  width: 40,
                  height: 40,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: faction.primaryColor.withOpacity(0.25),
                        border: Border.all(color: faction.primaryColor, width: 2),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ),
                ),

              ..._nodes.map((node) => Marker(
                point: node.coordinates,
                width: 60,
                height: 55,
                child: GestureDetector(
                  onTap: () => _abrirMision(node),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          border: Border.all(
                            color: node.status == NodeStatus.completed
                                ? faction.accentColor
                                : node.status == NodeStatus.nearby
                                    ? faction.primaryColor
                                    : faction.primaryColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          node.id,
                          style: faction.textStyle(
                            size: 9,
                            bold: true,
                            color: node.status == NodeStatus.nearby
                                ? faction.primaryColor
                                : faction.primaryColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Icon(
                        node.status == NodeStatus.completed
                            ? Icons.check_circle
                            : node.status == NodeStatus.nearby
                                ? Icons.wifi_tethering
                                : Icons.lock,
                        color: node.status == NodeStatus.completed
                            ? faction.accentColor
                            : node.status == NodeStatus.nearby
                                ? faction.primaryColor
                                : faction.primaryColor.withOpacity(0.5),
                        size: node.status == NodeStatus.nearby ? 24 : 18,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListaNodos(Faction faction) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8),
        itemCount: _nodes.length,
        itemBuilder: (_, i) {
          final node = _nodes[i];
          final isNearby = node.status == NodeStatus.nearby;
          final isCompleted = node.status == NodeStatus.completed;
          final cardColor = isCompleted
              ? faction.accentColor
              : isNearby
                  ? faction.primaryColor
                  : faction.primaryColor.withOpacity(0.3);

          double? dist;
          if (_currentPosition != null) {
            dist = _calcularDistancia(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              node.coordinates.latitude,
              node.coordinates.longitude,
            );
          }

          return GestureDetector(
            onTap: () => _abrirMision(node),
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: cardColor, width: isNearby ? 2 : 1),
                color: cardColor.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.codename,
                      style: faction.textStyle(size: 11, bold: true, color: cardColor)),
                  const SizedBox(height: 4),
                  Text(node.mission,
                      style: faction.textStyle(size: 10),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text(
                    isCompleted ? '✓ COMPLETADO' : dist != null ? '${dist.round()}m' : '---m',
                    style: faction.textStyle(
                      size: 11,
                      color: isCompleted ? faction.accentColor : cardColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(Faction faction) {
    return Container(
      color: faction.appBarColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ACTIVOS: ${_nodes.where((n) => n.status == NodeStatus.nearby).length}',
            style: faction.textStyle(size: 11),
          ),
          Text(
            '${_nodes.where((n) => n.status == NodeStatus.completed).length}/${_nodes.length} COMPLETADOS',
            style: faction.textStyle(size: 11, color: faction.accentColor),
          ),
          const BlinkingCursor(),
        ],
      ),
    );
  }
}
