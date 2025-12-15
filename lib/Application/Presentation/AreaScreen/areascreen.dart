// ignore_for_file: depend_on_referenced_packages
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:network_mapping_app/Data/Interface/OfficeAddData/officeadddata.dart';
import 'package:network_mapping_app/Data/Interface/RouteData/routedata.dart';
import 'package:network_mapping_app/Data/Resources/OfficeaddiingApi/officeaddingapi.dart';
import 'package:network_mapping_app/Data/Resources/RouteApi/routeapi.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

// NEW: Choose how the user wants to draw
enum DrawMethod { none, freehand, pointToPoint }

enum RouteType { main, sub, house }

enum MarkerType { mainOffice, suboffice, junction, house }

class CategorizedRoute {
  final String? name;
  final List<LatLng> path;
  final double? lengthKm;
  final int? officeId;
  final RouteType? type;

  CategorizedRoute({
    this.name,
    required this.path,
    this.lengthKm,
    this.officeId,
    this.type,
  });
}

class CategorizedMarker {
  final LatLng location;
  final MarkerType type;
  final String name;
  final int? officeId;
  final String? address;
  CategorizedMarker({
    this.officeId,
    required this.location,
    required this.type,
    required this.name,
    this.address,
  });
}

class Areascreen extends StatefulWidget {
  const Areascreen({super.key});
  @override
  State<Areascreen> createState() => _AreascreenState();
}

class _AreascreenState extends State<Areascreen> {
  final OfficeAController controller = Get.put(OfficeAController());
  final RouteController routeController = Get.put(RouteController());
  final _searchController = TextEditingController();
  LatLng _center = LatLng(10.8505, 76.2711);
  final GlobalKey _mapKey = GlobalKey();
  late final MapController _mapController;

  // NEW: which draw method is active
  DrawMethod _drawMethod = DrawMethod.none;
  RouteType _selectedRouteType = RouteType.main;
  MarkerType? _selectedMarkerType;

  List<CategorizedMarker> allMarkers = [];
  List<CategorizedRoute> allRoutes = [];
  List<LatLng> _currentRoute = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    controller.getOffice().then((offices) {
      if (!mounted) return;
      setState(() {
        allMarkers.addAll(
          offices.map((office) {
            return CategorizedMarker(
              location: LatLng(
                double.parse(office.latitude!),
                double.parse(office.longitude!),
              ),
              type: MarkerType.mainOffice,
              name: office.name!,
              officeId: office.id!,
              address: office.address,
            );
          }).toList(),
        );
      });
    });
    routeController.getRoute(18).then((routes) {
      setState(() {
        allRoutes.addAll(
          routes.map(
            (routeData) => CategorizedRoute(
              name: routeData.name, // name is non-null in RouteData
              path:
                  routeData
                      .path! // List<PathPoint>
                      .map<LatLng>((p) => LatLng(p.latitude, p.longitude))
                      .toList(),
              lengthKm: routeData.lengthKm, // already a double
              officeId: routeData.office,
            ),
          ),
        );
      });
    });
  }

  // --- SEARCH --------------------------------------------------------------
  Future<void> _searchPlace(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );
    final res = await http.get(url, headers: {'User-Agent': 'FlutterApp'});
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        setState(() => _center = LatLng(lat, lon));
        _mapController.move(_center, 13.0);
      }
    }
  }

  // --- DRAW HELPERS --------------------------------------------------------
  LatLng _globalOffsetToLatLng(Offset globalOffset) {
    final box = _mapKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalOffset);
    return _mapController.camera.pointToLatLng(CustomPoint(local.dx, local.dy));
  }

  // Free‑hand drawing handlers
  void _handlePanStart(DragStartDetails d) {
    if (_drawMethod != DrawMethod.freehand) return;
    final p = _globalOffsetToLatLng(d.globalPosition);
    setState(() => _currentRoute = [p]);
  }

  void _handlePanUpdate(DragUpdateDetails d) {
    if (_drawMethod != DrawMethod.freehand) return;
    final p = _globalOffsetToLatLng(d.globalPosition);
    setState(() => _currentRoute.add(p));
  }

  void _handlePanEnd(DragEndDetails _) {
    if (_drawMethod != DrawMethod.freehand) return;
    if (_currentRoute.length > 1) {
      _showPolylineSaveDialog(List.from(_currentRoute));
      setState(() {
        allRoutes.add(
          CategorizedRoute(
            path: List.from(_currentRoute),
            type: _selectedRouteType,
          ),
        );
        _currentRoute = [];
      });
    }
  }

  // --- EDIT & ADD MARKERS --------------------------------------------------
  void _editOfficeMarker(int idx) {
    final marker = allMarkers[idx];
    final nameController = TextEditingController(text: marker.name);
    final addressController = TextEditingController(text: marker.address);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Marker?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const SizedBox.shrink()
                        : TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            controller.editOfficedetails(
                              nameController.text,
                              addressController.text,
                              marker.officeId,
                            );
                            setState(() {
                              allMarkers[idx] = CategorizedMarker(
                                officeId: marker.officeId,
                                location: marker.location,
                                name: nameController.text,
                                address: addressController.text,
                                type: marker.type,
                              );
                            });
                          },
                          child: const Text('Save'),
                        ),
              ),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const SizedBox.shrink()
                        : TextButton(
                          onPressed: () {
                            setState(() {
                              allMarkers.removeAt(idx);
                              controller.deleteOfficeDetails(marker.officeId);
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
              ),
            ],
          ),
    );
  }

  // --- COLOR & ICON HELPERS ------------------------------------------------
  Color _getRouteColor(RouteType t) {
    switch (t) {
      case RouteType.main:
        return Colors.black;
      case RouteType.sub:
        return Colors.red;
      case RouteType.house:
        return Colors.green;
    }
  }

  Color _getMarkerColor(MarkerType t) {
    switch (t) {
      case MarkerType.mainOffice:
        return Colors.blue;
      case MarkerType.suboffice:
        return Colors.black;
      case MarkerType.junction:
        return Colors.orange;
      case MarkerType.house:
        return Colors.purple;
    }
  }

  Widget _getMarkerIcon(MarkerType t) {
    Color color = _getMarkerColor(t);
    switch (t) {
      case MarkerType.mainOffice:
        return Image.asset(
          'asset/images/png-transparent-building-office-computer-icons-office-buildings-angle-building-text-thumbnail-removebg-preview.png',
          width: 40,
          height: 40,
        );
      case MarkerType.suboffice:
        return Icon(Icons.apartment, size: 40, color: color);
      case MarkerType.junction:
        return Image.asset(
          'asset/images/360_F_690988325_KxZyQLpuKYxHfs0LZ06Fy738PzUT66xO-removebg-preview.png',
          width: 40,
          height: 40,
        );
      case MarkerType.house:
        return Icon(Icons.home, size: 40, color: color);
    }
  }

  // String _routeLabel(RouteType t) {
  //   switch (t) {
  //     case RouteType.main:
  //       return 'Main Route';
  //     case RouteType.sub:
  //       return 'Sub Route';
  //     case RouteType.house:
  //       return 'House Route';
  //   }
  // }

  // String _markerLabel(MarkerType t) {
  //   switch (t) {
  //     case MarkerType.mainOffice:
  //       return 'Main Office';
  //     case MarkerType.suboffice:
  //       return 'Sub Office';
  //     case MarkerType.junction:
  //       return 'Junction';
  //     case MarkerType.house:
  //       return 'House';
  //   }
  // }

  String _drawMethodLabel(DrawMethod m) {
    switch (m) {
      case DrawMethod.none:
        return 'Disabled';
      case DrawMethod.freehand:
        return 'Freehand';
      case DrawMethod.pointToPoint:
        return 'Point‑to‑Point';
    }
  }

  // --- MARKER DIALOG -------------------------------------------------------
  void _showMarkerDialog(LatLng tappedPoint) {
    final nameController = TextEditingController();
    final latController = TextEditingController(
      text: tappedPoint.latitude.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: tappedPoint.longitude.toStringAsFixed(6),
    );
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add Marker'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                  TextField(
                    controller: latController,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    readOnly: true,
                  ),
                  TextField(
                    controller: lngController,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    readOnly: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : TextButton(
                          onPressed: () {
                            final post = OfficeAddingData(
                              latitude: latController.text,
                              address: addressController.text,
                              longitude: lngController.text,
                              name: nameController.text,
                            );
                            controller.createPost(post);

                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a name'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              allMarkers.add(
                                CategorizedMarker(
                                  location: tappedPoint,
                                  type: _selectedMarkerType!,
                                  name: nameController.text.trim(),
                                ),
                              );
                            });

                            Navigator.pop(ctx);
                          },
                          child: const Text('Save'),
                        ),
              ),
            ],
          ),
    );
  }

  // --- BUILD MARKERS LIST --------------------------------------------------
  List<Marker> get _markers =>
      allMarkers.asMap().entries.map((e) {
        final idx = e.key;
        final m = e.value;

        return Marker(
          width: 120,
          height: 80,
          point: m.location,
          child: GestureDetector(
            onLongPress: () => _editOfficeMarker(idx),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    m.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                _getMarkerIcon(m.type),
              ],
            ),
          ),
        );
      }).toList();

  void _showPolylineSaveDialog(List<LatLng> route) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Save Route'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LatLng count: ${route.length}'),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Route Name'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveRouteToBackend(nameController.text, route);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  double _calculateDistanceInKm(List<LatLng> points) {
    double totalDistance = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _haversineDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }

    return double.parse(
      totalDistance.toStringAsFixed(2),
    ); // round to 2 decimal places
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);

  void _saveRouteToBackend(String name, List<LatLng> route) {
    final path =
        route.map((p) {
          return {
            "latitude": p.latitude,
            "longitude": p.longitude,
            "description": "",
          };
        }).toList();

    final length = _calculateDistanceInKm(route);

    final routeData = RouteData(
      name: name,
      path: path.map<PathPoint>((e) => PathPoint.fromJson(e)).toList(),
      lengthKm: double.parse(length.toString()),
      office: 18,
    );

    routeController.addRoute(routeData);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Route saved to backend')));
  }

  // --- UI ------------------------------------------------------------------
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: 'Area',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
        actions: [
          Row(
            children: [
              const Text('Draw:', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 6),
              DropdownButton<DrawMethod>(
                dropdownColor: appClr,
                value: _drawMethod,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items:
                    DrawMethod.values.map((d) {
                      return DropdownMenuItem<DrawMethod>(
                        value: d,
                        child: Text(
                          _drawMethodLabel(d),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                onChanged:
                    (d) => setState(() {
                      _drawMethod = d!;
                      _currentRoute = [];
                    }),
              ),
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.white),
                tooltip: 'Undo last route',
                onPressed: () {
                  if (allRoutes.isNotEmpty) {
                    setState(() => allRoutes.removeLast());
                  } else {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Nothing to undo')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          _drawMethod == DrawMethod.pointToPoint && _currentRoute.length > 1
              ? FloatingActionButton(
                onPressed: () {
                  _showPolylineSaveDialog(List.from(_currentRoute));
                  setState(() {
                    allRoutes.add(
                      CategorizedRoute(
                        path: List.from(_currentRoute),
                        type: _selectedRouteType,
                      ),
                    );
                    _currentRoute = [];
                  });
                },

                child: const Icon(Icons.check),
              )
              : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search a place...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchPlace(_searchController.text),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: _searchPlace,
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: FlutterMap(
                key: _mapKey,
                mapController: _mapController,
                options: MapOptions(
                  center: _center,
                  zoom: 12,
                  interactiveFlags:
                      _drawMethod == DrawMethod.freehand
                          ? InteractiveFlag.none
                          : InteractiveFlag.all,
                  onTap: (_, latlng) {
                    if (_drawMethod == DrawMethod.pointToPoint) {
                      setState(() => _currentRoute.add(latlng));
                    } else if (_selectedMarkerType != null) {
                      _showMarkerDialog(latlng);
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a marker type first.'),
                        ),
                      );
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileProvider: NetworkTileProvider(
                      headers: {
                        'User-Agent':
                            'MyFlutterMapApp/1.0 (your_email@example.com)',
                      },
                    ),
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(markers: _markers),
                  PolylineLayer(
                    polylines: [
                      ...allRoutes.map(
                        (r) => Polyline(
                          points: r.path,
                          color: _getRouteColor(r.type ?? RouteType.main),
                          strokeWidth: 4.0,
                        ),
                      ),
                      if (_currentRoute.isNotEmpty)
                        Polyline(
                          points: _currentRoute,
                          color: _getRouteColor(_selectedRouteType),
                          strokeWidth: 4.0,
                          isDotted: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
