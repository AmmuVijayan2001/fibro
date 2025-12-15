// ignore_for_file: depend_on_referenced_packages
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Application/Presentation/PaymentScreen/paymentScreen.dart';
import 'package:network_mapping_app/Data/Interface/CustomerData/customerdata.dart';
import 'package:network_mapping_app/Data/Interface/DeviceportData/deviceportdata.dart';
import 'package:network_mapping_app/Data/Interface/JunctionData/junctiondata.dart';
import 'package:network_mapping_app/Data/Interface/NetworkDeviceData/networkdevicedata.dart';
import 'package:network_mapping_app/Data/Interface/RouteData/routedata.dart';
import 'package:network_mapping_app/Data/Interface/SubBranchData/subbranchdata.dart';
import 'package:network_mapping_app/Data/Resources/CustomerApi/customerapi.dart';
import 'package:network_mapping_app/Data/Resources/DevicePortApi/deviceportapi.dart';
import 'package:network_mapping_app/Data/Resources/JunctionApi/junctionapi.dart';
import 'package:network_mapping_app/Data/Resources/NetworkDeciceApi/networkdeciceapi.dart';
import 'package:network_mapping_app/Data/Resources/OfficeaddiingApi/officeaddingapi.dart';
import 'package:network_mapping_app/Data/Resources/RouteApi/routeapi.dart';
import 'package:network_mapping_app/Data/Resources/SubOfficeApi/subofficedata.dart';
import 'dart:convert';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';
import 'package:network_mapping_app/Domine/Utils/widgets/App%20Text%20Widget/apptextwidget.dart';
import 'package:url_launcher/url_launcher.dart';

enum DrawMethod { none, freehand, pointToPoint }

enum RouteType { main }

enum MarkerType { mainOffice, suboffice, junction, networkdevices, customer }

enum DeviceMarker {
  splitter,
  coupler,
  olt,
  ont,
  // opticalSwitch,
  // mediaConverter,
  // networkInterfaceCard,
  // router,
  // switchs,
  // firewall,
}

// class CategorizedRoute {
//   final List<LatLng> path;
//   final RouteType type;
//   CategorizedRoute({required this.path, required this.type});
// }
class CategorizedRoute {
  final String? name;
  final List<LatLng> path;
  final double? lengthKm;
  final int? officeId;
  final RouteType? type;
  final int? id;

  CategorizedRoute({
    this.name,
    required this.path,
    this.lengthKm,
    this.officeId,
    this.type,
    this.id,
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

class SubBranchMarker {
  final LatLng location;
  final MarkerType type;
  final String name;
  final int? branchId;
  final String? address;
  final int? officeId;

  SubBranchMarker({
    this.branchId,
    required this.location,
    required this.type,
    required this.name,
    this.address,
    this.officeId,
  });
}

class JunctionMarker {
  final LatLng location;
  final MarkerType type;
  final String name;
  final int? junctionId;
  final String? postCode;
  final int? officeId;

  JunctionMarker({
    this.junctionId,
    required this.location,
    required this.type,
    required this.name,
    this.postCode,
    this.officeId,
  });
}

class CustomerMarker {
  final LatLng location;
  final MarkerType type;
  final int? customerID;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? address;
  final int? staff;
  final int? office;

  CustomerMarker({
    required this.location,
    required this.type,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.address,
    this.office,
    this.staff,
    this.customerID,
  });
}

class NetworkDeviceMarker {
  final LatLng location;
  final DeviceMarker type;
  final String modelName;
  final int? officeId;
  final int? staffInd;
  final int? deviceId;
  final String? deviceType;
  final String? description;
  final String? ratio;
  final int? maxSpeed;
  final String? colorCode;
  final double? insertionloss;
  final double? returnloss;
  final int? portCount;
  final String? latitude;
  final String? longitude;
  final String? supportProtocol;

  NetworkDeviceMarker({
    required this.location,
    required this.type,
    required this.modelName,
    this.officeId,
    this.staffInd,
    this.deviceId,
    this.deviceType,
    this.description,
    this.ratio,
    this.maxSpeed,
    this.colorCode,
    this.insertionloss,
    this.returnloss,
    this.portCount,
    this.latitude,
    this.longitude,
    this.supportProtocol,
  });
}

class Mapdetailsscreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String name;
  final int index;
  final int id;
  const Mapdetailsscreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.index,
    required this.id,
    required this.name,
  });

  @override
  State<Mapdetailsscreen> createState() => _MapdetailsscreenState();
}

class _MapdetailsscreenState extends State<Mapdetailsscreen> {
  final DeviceportController portController = Get.put(DeviceportController());
  final OfficeAController controller = Get.put(OfficeAController());
  final SubOfficeController subController = Get.put(SubOfficeController());
  final JunctionController junctionController = Get.put(JunctionController());
  final NetworkDeviceController networkDeviceController = Get.put(
    NetworkDeviceController(),
  );
  final RouteController routeController = Get.put(RouteController());
  final CustomerController customerController = Get.put(CustomerController());
  final _searchController = TextEditingController();
  late LatLng _center;
  final GlobalKey _mapKey = GlobalKey();
  late final MapController _mapController;

  RouteType _selectedRouteType = RouteType.main;
  MarkerType? _selectedMarkerType;
  DeviceMarker? _selectedDeviceType;
  DrawMethod _drawMethod = DrawMethod.none;
  List<CategorizedMarker> officeMarkers = [];
  List<CustomerMarker> customerMarkers = [];
  List<SubBranchMarker> allSubMarker = [];
  List<JunctionMarker> allJunMarkers = [];
  List<NetworkDeviceMarker> networkDeviceMarkers = [];
  List<CategorizedRoute> allRoutes = [];
  List<LatLng> _currentRoute = [];
  final List<Map<String, dynamic>> deviceTypes = [
    {'name': 'Splitter', 'icon': Icons.call_split},
    {'name': 'Coupler', 'icon': Icons.merge_type},
    {'name': 'OLT', 'icon': Icons.sync},
    {'name': 'ONT', 'icon': Icons.dashboard_customize},
    // {'name': 'Optical Switch', 'icon': Icons.toggle_on},
    // {'name': 'Media Converter', 'icon': Icons.transform},
    // {'name': 'Network Interface Card (NIC)', 'icon': Icons.device_hub},
    // {'name': 'Router', 'icon': Icons.router},
    // {'name': 'Switch', 'icon': Icons.swap_horiz},
    // {'name': 'Firewall', 'icon': Icons.security},
  ];

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.latitude, widget.longitude);
    _mapController = MapController();
    controller.getOffice().then((offices) {
      if (!mounted) return;
      setState(() {
        officeMarkers.addAll(
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
    routeController.getRoute(widget.id).then((routes) {
      if (!mounted) return;
      setState(() {
        allRoutes.addAll(
          routes.map(
            (routeData) => CategorizedRoute(
              id: routeData.id,
              name: routeData.name,
              path:
                  routeData.path!
                      .map<LatLng>((p) => LatLng(p.latitude, p.longitude))
                      .toList(),
              lengthKm: routeData.lengthKm,
              officeId: routeData.office,
            ),
          ),
        );
      });
    });
    subController.getSubOffice().then((branches) {
      if (!mounted) return;
      setState(() {
        allSubMarker.addAll(
          branches.map((branch) {
            return SubBranchMarker(
              location: LatLng(
                double.parse(branch.latitude!),
                double.parse(branch.longitude!),
              ),
              type: MarkerType.suboffice,
              name: branch.name!,
              branchId: branch.id!,
              address: branch.address,
              officeId: branch.officeId,
            );
          }).toList(),
        );
      });
    });

    junctionController.getJunction().then((junctions) {
      if (!mounted) return;
      setState(() {
        allJunMarkers.addAll(
          junctions.map((junction) {
            return JunctionMarker(
              location: LatLng(
                double.parse(junction.latitude!),
                double.parse(junction.longitude!),
              ),
              type: MarkerType.junction,
              name: junction.name!,
              postCode: junction.postCode,
              junctionId: junction.id,
              officeId: junction.officeId,
            );
          }).toList(),
        );
      });
    });
    customerController.getCustomers(widget.id).then((customers) {
      if (!mounted) return;
      setState(() {
        customerMarkers.addAll(
          customers.map((customer) {
            return CustomerMarker(
              location: LatLng(customer.latitude!, customer.longitude!),
              type: MarkerType.customer,
              customerName: customer.customerName,
              customerID: customer.customerID,
              address: customer.address,
              customerEmail: customer.customerEmail,
              customerPhone: customer.customerPhone,
            );
          }).toList(),
        );
      });
    });
    networkDeviceController.getNetworkDevices().then((devices) {
      if (!mounted) return;
      setState(() {
        networkDeviceMarkers.addAll(
          devices
              .map((device) {
                final markerType = deviceMarkerFromLabel(
                  device.deviceType ?? '',
                );

                if (markerType == null) {
                  return null;
                }

                return NetworkDeviceMarker(
                  location: LatLng(
                    double.parse(device.latitude!),
                    double.parse(device.longitude!),
                  ),
                  type: markerType,
                  modelName: device.modelName!,
                  staffInd: device.staff,
                  deviceId: device.id,
                  officeId: device.officeId,
                  deviceType: device.deviceType,
                  colorCode: device.colorCoding,
                  description: device.description,
                  insertionloss: device.insertionLoss,
                  latitude: device.latitude,
                  longitude: device.longitude,
                  maxSpeed: device.maxSpeed,
                  portCount: device.portCount,
                  ratio: device.ratio,
                  returnloss: device.returnLoss,
                  supportProtocol: device.supportProtocol,
                );
              })
              .whereType<NetworkDeviceMarker>()
              .toList(), // Filter out nulls
        );
      });
    });
  }

  Future<void> _connectCustomerToFiber(CustomerMarker customer) async {
    if (allRoutes.isEmpty) {
      print("No fiber routes available!");
      return;
    }

    LatLng nearestPoint = allRoutes[0].path[0];
    double nearestDistance = double.infinity;

    for (var route in allRoutes) {
      for (var point in route.path) {
        final d = _distance(customer.location, point);
        if (d < nearestDistance) {
          nearestDistance = d;
          nearestPoint = point;
        }
      }
    }

    final newRoute = [nearestPoint, customer.location];

    setState(() {
      allRoutes.add(CategorizedRoute(path: newRoute, type: RouteType.main));
    });
  }

  double _distance(LatLng a, LatLng b) {
    const R = 6371e3; // meters
    final phi1 = a.latitude * (3.14159 / 180);
    final phi2 = b.latitude * (3.14159 / 180);
    final dPhi = (b.latitude - a.latitude) * (3.14159 / 180);
    final dLambda = (b.longitude - a.longitude) * (3.14159 / 180);

    final c =
        2 *
        atan2(
          sqrt(
            sin(dPhi / 2) * sin(dPhi / 2) +
                cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2),
          ),
          sqrt(
            1 -
                (sin(dPhi / 2) * sin(dPhi / 2) +
                    cos(phi1) *
                        cos(phi2) *
                        sin(dLambda / 2) *
                        sin(dLambda / 2)),
          ),
        );

    return R * c;
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

  int _activeFingers = 0;
  bool _isDrawing = false;
  List<List<LatLng>> _previewFreehandRoutes = [];
  List<LatLng> currentRoute = [];
  List<LatLng> _currentRouteBuffer = [];
  bool get _mapInteractionAllowed =>
      _drawMethod != DrawMethod.freehand || _activeFingers > 1;

  void _handlePointerDown(PointerDownEvent event) {
    _activeFingers++;
    if (_drawMethod == DrawMethod.freehand && _activeFingers == 1) {
      _isDrawing = true;
      final point = _globalOffsetToLatLng(event.position);
      setState(() => _currentRoute = [point]);
    } else {
      _isDrawing = false;
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_drawMethod == DrawMethod.freehand &&
        _isDrawing &&
        _activeFingers == 1) {
      final point = _globalOffsetToLatLng(event.position);
      setState(() => _currentRoute.add(point));
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _activeFingers = (_activeFingers - 1).clamp(0, 10);

    if (_drawMethod == DrawMethod.freehand &&
        _isDrawing &&
        _currentRoute.length > 1) {
      _currentRouteBuffer.addAll(_currentRoute);
      _previewFreehandRoutes.add(List.from(_currentRoute)); // For live display
      currentRoute = []; // Reset for next draw
    }

    if (_activeFingers == 0) {
      _isDrawing = false;
    }

    setState(() {}); // Rebuild to show drawn lines
  }

  void _editOfficeMarker(int idx) {
    final marker = officeMarkers[idx];
    final nameController = TextEditingController(text: marker.name);
    final addressController = TextEditingController(text: marker.address);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Office?'),
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
                              officeMarkers[idx] = CategorizedMarker(
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
            ],
          ),
    );
  }

  void _editSubOfficeMarker(int idx) {
    final marker = allSubMarker[idx];
    final nameController = TextEditingController(text: marker.name);
    final addressController = TextEditingController(text: marker.address);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Sub-Office?'),
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
                    subController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            subController.editSubOfficedetails(
                              nameController.text,
                              addressController.text,
                              marker.branchId,
                            );
                            setState(() {
                              allSubMarker[idx] = SubBranchMarker(
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
                    subController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (confirmCtx) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                      'Are you sure you want to delete this sub-office ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(confirmCtx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            confirmCtx,
                                          ); // Close confirmation dialog
                                          Navigator.pop(
                                            ctx,
                                          ); // Close edit dialog
                                          setState(() {
                                            allSubMarker.removeAt(idx);
                                            subController
                                                .deleteSubOfficeDetails(
                                                  marker.branchId,
                                                );
                                          });
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
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

  void _editJuncMarker(int idx) {
    final marker = allJunMarkers[idx];
    final nameController = TextEditingController(text: marker.name);
    final postcodeController = TextEditingController(text: marker.postCode);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Junction?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: postcodeController,
                  decoration: const InputDecoration(labelText: 'Postcode'),
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
                    junctionController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            junctionController.editJuncdetails(
                              nameController.text,
                              postcodeController.text,
                              marker.junctionId,
                            );
                            setState(() {
                              allJunMarkers[idx] = JunctionMarker(
                                officeId: marker.officeId,
                                location: marker.location,
                                name: nameController.text,
                                postCode: postcodeController.text,
                                type: marker.type,
                              );
                            });
                          },
                          child: Text("Save"),
                        ),
              ),
              Obx(
                () =>
                    junctionController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (confirmCtx) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                      'Are you sure you want to delete this junction ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(confirmCtx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(confirmCtx);
                                          Navigator.pop(ctx);
                                          setState(() {
                                            allJunMarkers.removeAt(idx);
                                            junctionController.deleteJunDetails(
                                              marker.junctionId,
                                            );
                                          });
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
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

  void _editCustomer(int idx) {
    final marker = customerMarkers[idx];
    final nameController = TextEditingController(text: marker.customerName);
    final phoneController = TextEditingController(text: marker.customerPhone);
    final emailController = TextEditingController(text: marker.customerEmail);
    final addressController = TextEditingController(text: marker.address);
    final lat = marker.location.latitude;
    final long = marker.location.longitude;

    // Helper function to open Google Maps
    Future<void> _openInGoogleMaps(double lat, double lng) async {
      final Uri googleMapUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );

      if (await canLaunchUrl(googleMapUrl)) {
        await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }

    // Show main options dialog first
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(marker.customerName ?? 'Customer Options'),
            content: const Text('Choose an action'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Open Google Maps
                  _openInGoogleMaps(lat, long);
                },
                child: const Text('View in Google Maps'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Open edit dialog
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Edit Customer'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),
                              TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                ),
                              ),
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                              ),
                              TextField(
                                controller: addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                ),
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
                                  customerController.isLoading.value
                                      ? const SizedBox.shrink()
                                      : TextButton(
                                        onPressed: () async {
                                          Navigator.pop(ctx);

                                          final post = Customerdata(
                                            customerName: nameController.text,
                                            customerPhone: phoneController.text,
                                            customerEmail: emailController.text,
                                            address: addressController.text,
                                            customerID: marker.customerID,
                                            latitude: lat,
                                            longitude: long,
                                            office: widget.id,
                                          );

                                          customerController.updateCustomer(
                                            post,
                                          );
                                          setState(() {
                                            customerMarkers[idx] =
                                                CustomerMarker(
                                                  location: marker.location,
                                                  customerName:
                                                      nameController.text,
                                                  address:
                                                      addressController.text,
                                                  customerEmail:
                                                      emailController.text,
                                                  customerPhone:
                                                      phoneController.text,
                                                  type: marker.type,
                                                );
                                          });
                                        },
                                        child: const Text('Save'),
                                      ),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Confirm delete
                  showDialog(
                    context: context,
                    builder:
                        (confirmCtx) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                            'Are you sure you want to delete this Customer?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(confirmCtx);
                                setState(() {
                                  customerController.deleteCustomers(
                                    marker.customerID,
                                  );
                                  customerMarkers.removeAt(idx);
                                });
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void addPort(int deviceId) {
    final portNumberController = TextEditingController();
    final speedController = TextEditingController();
    String? selectedPortType;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add port'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: portNumberController,
                  decoration: const InputDecoration(labelText: 'Port Number'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: speedController,
                  decoration: const InputDecoration(labelText: 'Speed'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Device Type',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedPortType,
                  items:
                      ['SFP', 'Ethernet', 'QSFP'].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPortType = value;
                    });
                  },
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
                    portController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final post = Deviceportdata(
                              deviceId: deviceId,
                              portnumber: portNumberController.text,
                              porttype: selectedPortType,
                              speed: speedController.text,
                            );

                            portController.createDevicePort(post);
                            Navigator.pop(ctx);

                            // setState(() {
                            //   networkDeviceMarkers[idx] = NetworkDeviceMarker(
                            //     officeId: marker.officeId,
                            //     location: marker.location,
                            //     modelName: nameController.text,
                            //     type: marker.type,
                            //   );
                            // });
                          },
                          child: Text("Save"),
                        ),
              ),
            ],
          ),
    );
  }

  void _editDeviceMarker(int idx) {
    final marker = networkDeviceMarkers[idx];
    final nameController = TextEditingController(text: marker.modelName);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Edit Network Device?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    addPort(marker.deviceId!);
                  },
                  child: Text("CLICK TO ADD PORT"),
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
                    networkDeviceController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            final updated = NetworkDeviceData(
                              deviceType: marker.deviceType,
                              modelName: nameController.text,
                              description: marker.description,
                              ratio: marker.ratio,
                              maxSpeed: marker.maxSpeed,
                              colorCoding: marker.colorCode,
                              insertionLoss: marker.insertionloss,
                              returnLoss: marker.returnloss,
                              portCount: marker.portCount,
                              supportProtocol: marker.supportProtocol,
                              longitude: marker.longitude,
                              latitude: marker.latitude,
                              staff: marker.staffInd,
                              officeId: marker.officeId,
                              id: marker.deviceId,
                            );

                            networkDeviceController.editNetworkDevices(updated);
                            setState(() {
                              networkDeviceMarkers[idx] = NetworkDeviceMarker(
                                officeId: marker.officeId,
                                location: marker.location,
                                modelName: nameController.text,
                                type: marker.type,
                              );
                            });
                          },
                          child: Text("Save"),
                        ),
              ),
              Obx(
                () =>
                    networkDeviceController.isLoading.value
                        ? Text("")
                        : TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (confirmCtx) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text(
                                      'Are you sure you want to delete this device ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(confirmCtx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            confirmCtx,
                                          ); // Close confirmation dialog
                                          Navigator.pop(
                                            ctx,
                                          ); // Close edit dialog
                                          setState(() {
                                            networkDeviceMarkers.removeAt(idx);
                                            networkDeviceController
                                                .deleteNetworkDevice(
                                                  marker.deviceId,
                                                );
                                          });
                                        },
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
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
      // case RouteType.sub:
      //   return Colors.red;
      // case RouteType.house:
      //   return Colors.green;
    }
  }

  Color _getMarkerColor(MarkerType t) {
    switch (t) {
      case MarkerType.mainOffice:
        return Colors.blue;
      case MarkerType.suboffice:
        return Colors.brown;
      case MarkerType.junction:
        return Colors.orange;
      case MarkerType.networkdevices:
        return Colors.green;
      case MarkerType.customer:
        return const Color.fromARGB(255, 25, 1, 141);
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
      case MarkerType.networkdevices:
        return Icon(Icons.network_cell, size: 40, color: color);
      case MarkerType.customer:
        return Icon(Icons.person_pin_circle_outlined, size: 40, color: color);
    }
  }

  DeviceMarker? deviceMarkerFromLabel(String label) {
    switch (label) {
      case 'Splitter':
        return DeviceMarker.splitter;
      case 'Coupler':
        return DeviceMarker.coupler;
      case 'OLT':
        return DeviceMarker.olt;
      case 'ONT':
        return DeviceMarker.ont;
      // case 'Optical Switch':
      //   return DeviceMarker.opticalSwitch;
      // case 'Media Converter':
      //   return DeviceMarker.mediaConverter;
      // case 'Network Interface Card (NIC)':
      //   return DeviceMarker.networkInterfaceCard;
      // case 'Router':
      //   return DeviceMarker.router;
      // case 'Switch':
      //   return DeviceMarker.switchs;
      // case 'Firewall':
      //   return DeviceMarker.firewall;
      default:
        return null;
    }
  }

  Widget _getDeviceIcon(DeviceMarker d, double? size) {
    switch (d) {
      case DeviceMarker.splitter:
        return Icon(Icons.call_split, size: size, color: Colors.black);
      case DeviceMarker.coupler:
        return Icon(Icons.merge_type, size: size, color: Colors.black);
      case DeviceMarker.olt:
        return Icon(Icons.sync, size: size, color: Colors.purple);
      case DeviceMarker.ont:
        return Icon(
          Icons.dashboard_customize,
          size: size,
          color: Colors.deepOrange,
        );
      // case DeviceMarker.opticalSwitch:
      //   return Icon(Icons.toggle_on, size: size, color: Colors.blueGrey);
      // case DeviceMarker.mediaConverter:
      //   return Icon(Icons.transform, size: size, color: Colors.blueAccent);
      // case DeviceMarker.networkInterfaceCard:
      //   return Icon(Icons.device_hub, size: size, color: Colors.black);
      // case DeviceMarker.router:
      //   return Icon(Icons.router, size: size, color: Colors.red);
      // case DeviceMarker.switchs:
      //   return Icon(Icons.swap_horiz, size: size, color: Colors.black);
      // case DeviceMarker.firewall:
      //   return Icon(Icons.security, size: size, color: Colors.amber);
    }
  }

  String _routeLabel(RouteType t) {
    switch (t) {
      case RouteType.main:
        return 'Main Route';
      // case RouteType.sub:
      //   return 'Sub Route';
      // case RouteType.house:
      //   return 'House Route';
    }
  }

  String _markerLabel(MarkerType t) {
    switch (t) {
      case MarkerType.mainOffice:
        return 'Main Office';
      case MarkerType.suboffice:
        return 'Sub Office';
      case MarkerType.junction:
        return 'Junction';
      case MarkerType.networkdevices:
        return 'Network Devices';
      case MarkerType.customer:
        return 'Customer';
    }
  }

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

  String _deviceLabel(DeviceMarker t) {
    switch (t) {
      case DeviceMarker.splitter:
        return 'Splitter';
      case DeviceMarker.coupler:
        return 'Coupler';
      case DeviceMarker.olt:
        return 'OLT';
      case DeviceMarker.ont:
        return 'ONT';
      // case DeviceMarker.opticalSwitch:
      //   return 'Optical Switch';
      // case DeviceMarker.mediaConverter:
      //   return 'Media Converter';
      // case DeviceMarker.networkInterfaceCard:
      //   return 'Network Interface Card (NIC)';
      // case DeviceMarker.router:
      //   return 'Router';
      // case DeviceMarker.switchs:
      //   return 'Switch';
      // case DeviceMarker.firewall:
      //   return 'Firewall';
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
                            final post = SucbOfficeAddingData(
                              officeId: widget.id,
                              latitude: latController.text,
                              address: addressController.text,
                              longitude: lngController.text,
                              name: nameController.text,
                            );
                            subController.createSubOffice(post);

                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a name'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              officeMarkers.add(
                                CategorizedMarker(
                                  location: tappedPoint,
                                  type: _selectedMarkerType!,
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

  void _addJunction(LatLng tappedPoint) {
    final nameController = TextEditingController();
    final latController = TextEditingController(
      text: tappedPoint.latitude.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: tappedPoint.longitude.toStringAsFixed(6),
    );
    final postcodeController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add Junction'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: postcodeController,
                    decoration: const InputDecoration(labelText: 'Postcode'),
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
                    junctionController.isLoading.value
                        ? CircularProgressIndicator()
                        : TextButton(
                          onPressed: () {
                            final post = JunctionAddingData(
                              officeId: widget.id,
                              latitude: latController.text,
                              postCode: postcodeController.text,
                              longitude: lngController.text,
                              name: nameController.text,
                            );
                            junctionController.createJunction(post);

                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a name'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              allJunMarkers.add(
                                JunctionMarker(
                                  location: tappedPoint,
                                  type: _selectedMarkerType!,
                                  name: nameController.text.trim(),
                                  postCode: postcodeController.text,
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

  void _addNetworkDevices(LatLng tappedPoint) {
    final modelNameController = TextEditingController();
    final latController = TextEditingController(
      text: tappedPoint.latitude.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: tappedPoint.longitude.toStringAsFixed(6),
    );

    final descriptionController = TextEditingController();
    String? ratio;

    final maxSpeedController = TextEditingController();
    final colorcodeController = TextEditingController();
    final insertionLossController = TextEditingController();
    final returnController = TextEditingController();
    final supProtocolController = TextEditingController();
    final portCountController = TextEditingController();
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
                    controller: modelNameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<DeviceMarker?>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Device Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedDeviceType,
                    items: [
                      DropdownMenuItem<DeviceMarker>(
                        value: null,
                        child: Text('Select Device Type'),
                      ),
                      ...DeviceMarker.values.map((t) {
                        return DropdownMenuItem<DeviceMarker>(
                          value: t,
                          child: Row(
                            children: [
                              _getDeviceIcon(t, 15),

                              const SizedBox(width: 5),
                              Text(_deviceLabel(t)),
                            ],
                          ),
                        );
                      }),
                    ],

                    onChanged: (value) {
                      setState(() {
                        _selectedDeviceType = value;
                      });
                    },
                  ),

                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Ratio',
                      border: OutlineInputBorder(),
                    ),
                    value: ratio,
                    items:
                        [
                          '1:2',
                          '1:3',
                          '1:4',
                          '1:5',
                          '1:6',
                          '1:8',
                          '1:10',
                          '1:16',
                        ].map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        ratio = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: maxSpeedController,
                    decoration: const InputDecoration(labelText: 'Max_Speed'),
                  ),
                  TextField(
                    controller: colorcodeController,
                    decoration: const InputDecoration(labelText: 'Colorcode'),
                  ),
                  TextField(
                    controller: insertionLossController,
                    decoration: const InputDecoration(
                      labelText: 'Insertion_loss',
                    ),
                  ),
                  TextField(
                    controller: returnController,
                    decoration: const InputDecoration(labelText: 'ReturnLoss'),
                  ),
                  TextField(
                    controller: supProtocolController,
                    decoration: const InputDecoration(
                      labelText: 'Support Protocol',
                    ),
                  ),
                  TextField(
                    controller: portCountController,
                    decoration: const InputDecoration(labelText: 'Port Count'),
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
                    networkDeviceController.isLoading.value
                        ? CircularProgressIndicator()
                        : TextButton(
                          onPressed: () {
                            final post = NetworkDeviceData(
                              officeId: widget.id,
                              latitude: latController.text,
                              longitude: lngController.text,
                              colorCoding: colorcodeController.text,
                              description: descriptionController.text,
                              deviceType: _deviceLabel(_selectedDeviceType!),
                              insertionLoss: double.parse(
                                insertionLossController.text,
                              ),
                              maxSpeed: int.parse(maxSpeedController.text),
                              modelName: modelNameController.text,
                              portCount: int.parse(portCountController.text),
                              ratio: ratio,
                              returnLoss: double.parse(returnController.text),
                              supportProtocol: supProtocolController.text,
                            );
                            networkDeviceController.addNetworkDevices(post);

                            if (modelNameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a name'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              networkDeviceMarkers.add(
                                NetworkDeviceMarker(
                                  location: tappedPoint,
                                  type: _selectedDeviceType!,
                                  modelName: modelNameController.text.trim(),
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

  void _addCustomer(LatLng tappedPoint) {
    final nameController = TextEditingController();
    final latController = TextEditingController(
      text: tappedPoint.latitude.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: tappedPoint.longitude.toStringAsFixed(6),
    );
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Add Customer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'phone'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'address'),
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              Obx(
                () =>
                    customerController.isLoading.value
                        ? CircularProgressIndicator()
                        : TextButton(
                          onPressed: () {
                            final post = Customerdata(
                              customerName: nameController.text,
                              customerEmail: emailController.text,
                              address: addressController.text,
                              customerPhone: phoneController.text,
                              office: widget.id,
                              latitude: double.tryParse(latController.text),
                              longitude: double.tryParse(lngController.text),
                            );
                            customerController.addCustomer(post);

                            // Connect the newly added customer to fiber
                            final newCustomerMarker = CustomerMarker(
                              location: LatLng(
                                double.tryParse(latController.text) ??
                                    tappedPoint.latitude,
                                double.tryParse(lngController.text) ??
                                    tappedPoint.longitude,
                              ),
                              type: MarkerType.customer,
                              customerName: nameController.text,
                              customerEmail: emailController.text,
                              customerPhone: phoneController.text,
                              address: addressController.text,
                              office: widget.id,
                            );
                            _connectCustomerToFiber(newCustomerMarker);

                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a name'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              officeMarkers.add(
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

  List<Marker> get _markers => [
    ...officeMarkers.asMap().entries.map((e) {
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    }),

    ...allSubMarker.asMap().entries.map((m) {
      final idx = m.key;
      final n = m.value;
      return Marker(
        width: 120,
        height: 80,
        point: n.location,
        child: GestureDetector(
          onLongPress: () => _editSubOfficeMarker(idx),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  n.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              _getMarkerIcon(n.type),
            ],
          ),
        ),
      );
    }),
    ...allJunMarkers.asMap().entries.map((m) {
      final idx = m.key;
      final n = m.value;
      return Marker(
        width: 120,
        height: 80,
        point: n.location,
        child: GestureDetector(
          onLongPress: () => _editJuncMarker(idx),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  n.name,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              _getMarkerIcon(n.type),
            ],
          ),
        ),
      );
    }),
    ...customerMarkers.asMap().entries.map((m) {
      final idx = m.key;
      final n = m.value;
      return Marker(
        width: 120,
        height: 80,
        point: n.location,
        child: GestureDetector(
          onLongPress: () => _editCustomer(idx),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  n.customerName!,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              _getMarkerIcon(n.type),
            ],
          ),
        ),
      );
    }),
    ...networkDeviceMarkers.asMap().entries.map((m) {
      final idx = m.key;
      final n = m.value;
      return Marker(
        width: 120,
        height: 80,
        point: n.location,
        child: GestureDetector(
          onLongPress: () => _editDeviceMarker(idx),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  n.modelName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),

              GestureDetector(
                onTap: () async {
                  List<Deviceportdata> ports = await portController
                      .getDevicePort(n.deviceId!);

                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: Text('Device Ports (${ports.length})'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children:
                                  ports.map((e) {
                                    return Image.asset(
                                      'asset/images/port.png',
                                      width: 30,
                                      height: 30,
                                    );
                                  }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
                child: _getDeviceIcon(n.type, 30),
              ),
            ],
          ),
        ),
      );
    }),
  ];
  void _showPolylineSaveDialog(List<LatLng> route, VoidCallback onCancel) {
    final nameController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder:
              (ctx, setState) => AlertDialog(
                title: const Text('Save Route'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LatLng count: ${route.length}'),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Route Name',
                        errorText: errorText,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Mapdetailsscreen(
                                index: widget.index,
                                longitude: widget.longitude,
                                latitude: widget.latitude,
                                id: widget.id,
                                name: widget.name,
                              ),
                        ),
                      );

                      onCancel();
                    },
                    child: const Text('Cancel'),
                  ),
                  Obx(
                    () =>
                        routeController.isLoading.value
                            ? const SizedBox.shrink()
                            : TextButton(
                              onPressed: () {
                                if (nameController.text.trim().isEmpty) {
                                  setState(() {
                                    errorText = 'Route name cannot be empty';
                                  });
                                } else {
                                  Navigator.pop(ctx);
                                  _saveRouteToBackend(
                                    nameController.text.trim(),
                                    route,
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                  ),
                ],
              ),
        );
      },
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

    return double.parse(totalDistance.toStringAsFixed(2));
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371;
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

  Future<void> _saveRouteToBackend(String name, List<LatLng> route) async {
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
      office: widget.id,
    );
    final result = await routeController.addRoute(routeData);

    if (result['success']) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Route saved to backend')));
    } else {
      final message = result['message'] ?? 'Failed to save route';

      if (message.contains("Fiber length limit exceeded")) {
        Get.defaultDialog(
          title: "Fiber Limit Reached",
          titleStyle: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: appClr,
          ),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "You have exceeded the maximum allowed fiber length (500 km). "
                  "To add more routes, please upgrade to the premium plan.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          confirm: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.amber[600]!, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PaymentScreen()),
              );
            },
            icon: Icon(
              FontAwesomeIcons.crown,
              size: 16,
              color: Colors.amber[600],
            ),
            label: Text(
              "Upgrade to Premium",
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          cancel: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Mapdetailsscreen(
                        index: widget.index,
                        longitude: widget.longitude,
                        latitude: widget.latitude,
                        id: widget.id,
                        name: widget.name,
                      ),
                ),
              );
            },
            child: const Text("Exit", style: TextStyle(color: Colors.grey)),
          ),
          radius: 12,
        );
      } else {
        Get.snackbar(
          "Error",
          message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _deleteLastRoute() async {
    if (allRoutes.isEmpty) return;

    final lastRoute = allRoutes.last;
    try {
      await routeController.deleteRoute(lastRoute.id);

      if (!mounted) return;

      setState(() {
        allRoutes.removeLast();
      });
    } catch (e) {
      if (!mounted) return; // Add this check as well
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete route: $e')));
    }
  }

  void _discardDrawnRoutes() {
    setState(() {
      _currentRoute.clear();
      _currentRouteBuffer.clear();
      _previewFreehandRoutes.clear();
    });
  }

  void _undoLastRoute() {
    if (_previewFreehandRoutes.isNotEmpty) {
      // Remove last preview segment
      final lastSegment = _previewFreehandRoutes.removeLast();

      // Remove corresponding points from buffer
      _currentRouteBuffer.removeRange(
        _currentRouteBuffer.length - lastSegment.length,
        _currentRouteBuffer.length,
      );

      _currentRoute = [];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: whiteClr,
        title: AppTextwidget(
          text: widget.name,
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
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: appClr,
                onSelected: (value) {
                  if (value == 'delete_route') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Undo'),
                          content: const Text(
                            'Are you sure you want to delete the last route?',
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deleteLastRoute();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem<String>(
                        value: 'delete_route',
                        child: Text(
                          'Delete Last Route',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ],
      ),

      // floatingActionButton:
      //     (_drawMethod == DrawMethod.pointToPoint &&
      //                 _currentRoute.length > 1) ||
      //             (_drawMethod == DrawMethod.freehand &&
      //                 _currentRouteBuffer.isNotEmpty)
      //         ? FloatingActionButton(
      //           onPressed: () {
      //             if (_drawMethod == DrawMethod.pointToPoint) {
      //               // Save point-to-point
      //               _showPolylineSaveDialog(List.from(_currentRoute));
      //               setState(() {
      //                 allRoutes.add(
      //                   CategorizedRoute(
      //                     path: List.from(_currentRoute),
      //                     type: _selectedRouteType,
      //                   ),
      //                 );
      //                 _currentRoute = [];
      //               });
      //             } else if (_drawMethod == DrawMethod.freehand) {
      //               // Save all drawn freehand segments
      //               final combinedPath = List<LatLng>.from(_currentRouteBuffer);
      //               _showPolylineSaveDialog(combinedPath);
      //               setState(() {
      //                 allRoutes.add(
      //                   CategorizedRoute(
      //                     path: combinedPath,
      //                     type: _selectedRouteType,
      //                   ),
      //                 );
      //                 _currentRouteBuffer.clear();
      //                 _previewFreehandRoutes.clear(); // Clear visual preview
      //               });
      //             }
      //           },
      //           child: const Icon(Icons.check),
      //         )
      //         : null,
      floatingActionButton: Stack(
        children: [
          if ((_drawMethod == DrawMethod.pointToPoint &&
                  _currentRoute.length > 1) ||
              (_drawMethod == DrawMethod.freehand &&
                  _currentRouteBuffer.isNotEmpty))
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'saveBtn',
                onPressed: () {
                  if (_drawMethod == DrawMethod.pointToPoint) {
                    _showPolylineSaveDialog(
                      List.from(_currentRoute),
                      _discardDrawnRoutes,
                    );
                    setState(() {
                      allRoutes.add(
                        CategorizedRoute(
                          path: List.from(_currentRoute),
                          type: _selectedRouteType,
                        ),
                      );
                      _currentRoute = [];
                    });
                  } else if (_drawMethod == DrawMethod.freehand) {
                    final combinedPath = List<LatLng>.from(_currentRouteBuffer);
                    _showPolylineSaveDialog(combinedPath, _discardDrawnRoutes);
                    setState(() {
                      allRoutes.add(
                        CategorizedRoute(
                          path: combinedPath,
                          type: _selectedRouteType,
                        ),
                      );
                      _currentRouteBuffer.clear();
                      _previewFreehandRoutes.clear();
                    });
                  }
                },
                child: const Icon(Icons.check),
              ),
            ),
          if (_drawMethod == DrawMethod.freehand &&
              _previewFreehandRoutes.isNotEmpty)
            Positioned(
              bottom: 86,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'undoBtn',
                mini: true,
                backgroundColor: Colors.redAccent,
                onPressed: _undoLastRoute,
                child: const Icon(Icons.undo),
              ),
            ),
        ],
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Route Type: '),
                    const SizedBox(width: 10),
                    DropdownButton<RouteType>(
                      value: _selectedRouteType,
                      items:
                          RouteType.values.map((t) {
                            return DropdownMenuItem<RouteType>(
                              value: t,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: _getRouteColor(t),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Text(_routeLabel(t)),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (t) => setState(() => _selectedRouteType = t!),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Marker Type: '),
                    const SizedBox(width: 10),
                    DropdownButton<MarkerType?>(
                      value: _selectedMarkerType,
                      hint: const Text('Select Marker Type'),
                      items: [
                        const DropdownMenuItem<MarkerType?>(
                          value: null,
                          child: Text('Select Marker Type'),
                        ),
                        ...MarkerType.values
                            .where(
                              (t) => t != MarkerType.mainOffice,
                            ) // Hide mainOffice
                            .map((t) {
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
            child: Listener(
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              behavior: HitTestBehavior.translucent,
              child: FlutterMap(
                key: _mapKey,
                mapController: _mapController,
                options: MapOptions(
                  center: _center,
                  zoom: 12,
                  interactiveFlags:
                      _mapInteractionAllowed
                          ? InteractiveFlag.all
                          : InteractiveFlag.none,
                  onTap: (_, latlng) {
                    if (_drawMethod == DrawMethod.pointToPoint) {
                      setState(() => _currentRoute.add(latlng));
                    } else if (_selectedMarkerType != null) {
                      switch (_selectedMarkerType) {
                        case MarkerType.junction:
                          _addJunction(latlng);
                          break;
                        case MarkerType.networkdevices:
                          _addNetworkDevices(latlng);
                          break;
                        case MarkerType.customer:
                          _addCustomer(latlng);
                          break;
                        default:
                          _showMarkerDialog(latlng);
                      }
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
                      ..._previewFreehandRoutes.map(
                        (segment) => Polyline(
                          points: segment,
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                      ),
                      if (_currentRoute.isNotEmpty)
                        Polyline(
                          points: currentRoute,
                          color: Colors.red,
                          strokeWidth: 4,
                        ),
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
