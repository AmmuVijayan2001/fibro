// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Interface/OfficeAddData/officeadddata.dart';
import 'package:network_mapping_app/Data/Resources/OfficeaddiingApi/officeaddingapi.dart';
import 'dart:convert';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';

enum RouteType { main, sub, house }

enum MarkerType { mainOffice }

class CategorizedRoute {
  final List<LatLng> path;
  final RouteType type;
  CategorizedRoute({required this.path, required this.type});
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

class AddNewOltScreen extends StatefulWidget {
  const AddNewOltScreen({super.key});
  @override
  State<AddNewOltScreen> createState() => _AddNewOltScreenState();
}

class _AddNewOltScreenState extends State<AddNewOltScreen> {
  final OfficeAController controller = Get.put(OfficeAController());
  final _searchController = TextEditingController();
  LatLng _center = LatLng(10.8505, 76.2711);
  final GlobalKey _mapKey = GlobalKey();
  late final MapController _mapController;

  bool _drawMode = false;
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
  }

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

  LatLng _globalOffsetToLatLng(Offset globalOffset) {
    final box = _mapKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalOffset);
    return _mapController.camera.pointToLatLng(CustomPoint(local.dx, local.dy));
  }

  void _handlePanStart(DragStartDetails d) {
    if (!_drawMode) return;
    final p = _globalOffsetToLatLng(d.globalPosition);
    setState(() => _currentRoute = [p]);
  }

  void _handlePanUpdate(DragUpdateDetails d) {
    if (!_drawMode) return;
    final p = _globalOffsetToLatLng(d.globalPosition);
    setState(() => _currentRoute.add(p));
  }

  void _handlePanEnd(DragEndDetails _) {
    if (!_drawMode) return;
    if (_currentRoute.length > 1) {
      setState(() {
        allRoutes.add(
          CategorizedRoute(
            path: List.from(_currentRoute),
            type: _selectedRouteType,
          ),
        );
      });
    }
    setState(() => _currentRoute = []);
  }

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
                        ? Text("")
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
                          child: Text("Save"),
                        ),
              ),
              Obx(
                () =>
                    controller.isLoading.value
                        ? Text("")
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
    }
  }

  Widget _getMarkerIcon(MarkerType t) {
    _getMarkerColor(t);

    switch (t) {
      case MarkerType.mainOffice:
        return Image.asset(
          'asset/images/png-transparent-building-office-computer-icons-office-buildings-angle-building-text-thumbnail-removebg-preview.png',
          width: 40,
          height: 40,
        );
    }
  }

  String _markerLabel(MarkerType t) {
    switch (t) {
      case MarkerType.mainOffice:
        return 'Main Office';
    }
  }

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
                        ? CircularProgressIndicator()
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
                                  type: MarkerType.mainOffice,
                                  name: nameController.text.trim(),
                                  address: addressController.text,
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

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: 'Add OLT',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: whiteClr,
        ),
        backgroundColor: appClr,
        elevation: 0,
      ),
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
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     const Text('Route Type: '),
                //     const SizedBox(width: 10),
                //     DropdownButton<RouteType>(
                //       value: _selectedRouteType,
                //       items:
                //           RouteType.values.map((t) {
                //             return DropdownMenuItem<RouteType>(
                //               value: t,
                //               child: Row(
                //                 children: [
                //                   Container(
                //                     width: 12,
                //                     height: 12,
                //                     margin: const EdgeInsets.only(right: 8),
                //                     decoration: BoxDecoration(
                //                       color: _getRouteColor(t),
                //                       shape: BoxShape.circle,
                //                     ),
                //                   ),
                //                   Text(_routeLabel(t)),
                //                 ],
                //               ),
                //             );
                //           }).toList(),
                //       onChanged: (t) => setState(() => _selectedRouteType = t!),
                //     ),
                //   ],
                // ),
                Row(
                  children: [
                    const Text('Marker Type: '),
                    const SizedBox(width: 10),
                    DropdownButton<MarkerType?>(
                      value: MarkerType.mainOffice,
                      hint: const Text('Select Marker Type'),
                      items: [
                        const DropdownMenuItem<MarkerType?>(
                          value: null,
                          child: Text('Select Marker Type'),
                        ),

                        ...MarkerType.values.map((t) {
                          return DropdownMenuItem<MarkerType?>(
                            value: t,
                            child: Row(
                              children: [
                                _getMarkerIcon(t),

                                const SizedBox(width: 5),
                                Text(_markerLabel(t)),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (t) => setState(() => _selectedMarkerType = t),
                    ),
                  ],
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
                      _drawMode ? InteractiveFlag.none : InteractiveFlag.all,
                  onTap: (_, latlng) {
                    if (_selectedMarkerType != null && !_drawMode) {
                      _showMarkerDialog(latlng);
                    } else if (!_drawMode) {
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
                          color: _getRouteColor(r.type),
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
