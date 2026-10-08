import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  final tanta = LatLng(30.78, 31.00);
  final List<LatLng> points = [];
  final MapController controller = MapController();
  LatLng? myLocation;
  final TextEditingController searchController = TextEditingController();
  LatLng? searchedPlace;

  void dispose() {
    controller.dispose();
    _positionSub?.cancel();
    searchController.dispose();
    super.dispose();
  }

  initState() {
    super.initState();
    goToLocation();
  }

  //Routing

  List<LatLng> routePoints = []; // نقاط الطريق الحقيقي
  double? routeKm; // المسافة
  double? routeMinutes; // الزمن
  bool loading = false;
  Future<void> getRoute() async {
    if (points.length < 2) {
      _showMessage('الرجاء إضافة عنصرين للطريق الحقيقي');
      return;
    }
    final start = myLocation ?? points.first;
    final end = points.last;

    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['routes'][0];
        final coords = data['geometry']['coordinates'] as List;
        setState(() {
          routePoints = coords.map((e) => LatLng(e[1], e[0])).toList();
          routeKm = data['distance'] / 1000;
          routeMinutes = data['duration'] / 60;

          loading = false;
        });
        log('routeKm: $routeKm');
        log('routeMinutes: $routeMinutes');
        controller.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(routePoints),
            padding: const EdgeInsets.all(50),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });
        _showMessage('خطأ في الطلب');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      _showMessage('خطأ في الطلب');
    }
  }

  Future<void> goToLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showMessage('تم رفض الصلاحية للموقع');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showMessage('تم رفض صلاحية الموقع');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showMessage('الصلاحية مرفوضة نهائياً، فعّلها من إعدادات التطبيق');
        return;
      }
    }

    var position = await Geolocator.getCurrentPosition();
    final here = LatLng(position.latitude, position.longitude);

    setState(() {
      myLocation = here;
      points.add(here);
      controller.move(here, 16);
    });
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'accept-language': 'ar',
    });
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.myapp'}, // غيّره لاسم تطبيقك
      );

      if (response.statusCode != 200) {
        _showMessage('فشل البحث: ${response.statusCode}');
        return;
      }

      final results = jsonDecode(response.body) as List;

      if (results.isEmpty) {
        _showMessage('لم يتم العثور على المكان');
        return;
      }

      final place = results.first;
      final found = LatLng(
        double.parse(place['lat']), // نص ← رقم
        double.parse(place['lon']),
      );

      setState(() {
        points.add(found);
        searchedPlace = found;
      });
      controller.move(found, 15);
      _showMessage(place['display_name']);
    } catch (e) {
      _showMessage('خطأ في الاتصال');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // Marker Cluster

  final List<LatLng> manyPoints = [];
  Future<void> addRandomPlaces() async {
    log('addRandomPlaces');
    final random = Random();
    setState(() {
      for (int i = 0; i < 100; i++) {
        manyPoints.add(
          LatLng(
            30.78 + (random.nextDouble() - 0.5) * 0.1,
            31.00 + (random.nextDouble() - 0.5) * 0.1,
          ),
        );
      }
    });
    log('manyPoints: ${manyPoints}');
  }

  // Live Tracking
  StreamSubscription<Position>? _positionSub;
  bool tracking = false;
  final List<LatLng> trail = [];

  Future<void> startTracking() async {
    if (tracking) {
      await _positionSub?.cancel();
      _positionSub = null;
      setState(() {
        tracking = false;
      });
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _showMessage('تم رفض صلاحية الموقع');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        _showMessage('الصلاحية مرفوضة نهائياً، فعّلها من إعدادات التطبيق');
        return;
      }
    }
    setState(() {
      tracking = true;
    });
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          final here = LatLng(position.latitude, position.longitude);
          setState(() {
            trail.add(here);
            myLocation = here;
            controller.move(here, 16);
          });
        });
  }
  // Fake Tracking
  // Timer? _fakeTimer;

  // void startFakeTracking() {
  //   double lat = 30.78, lng = 31.00;

  //   _fakeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     lat += 0.0003; // يتحرك شمال
  //     lng += 0.0002; // وشرق
  //     final here = LatLng(lat, lng);

  //     setState(() {
  //       myLocation = here;
  //       trail.add(here);
  //     });
  //     controller.move(here, controller.camera.zoom);
  //   });
  // }

  // void stopFakeTracking() => _fakeTimer?.cancel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Map'),
        actions: [
          IconButton(
            onPressed: () {
              // tracking ? stopFakeTracking : startFakeTracking,
              startTracking();
            },
            icon: Icon(tracking ? Icons.stop_circle : Icons.play_circle),
          ),
          IconButton(
            onPressed: () async {
              await addRandomPlaces();
              controller.move(manyPoints.first, 15);
            },
            icon: const Icon(Icons.add_location_alt),
          ),
          IconButton(
            onPressed: () async {
              await getRoute();
              print(points);
              _showMessage('Distance: ${routeKm?.toStringAsFixed(2)} Km');
            },
            icon: const Icon(Icons.directions_car),
          ),
          IconButton(
            onPressed: () {
              points.clear();
              routePoints.clear();
              routeKm = null;
              routeMinutes = null;
              setState(() {});
            },
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToLocation,
        child: const Icon(Icons.my_location),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller,
              options: MapOptions(
                initialCenter: myLocation ?? tanta,
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  setState(() {
                    points.add(point);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('النقطة المضاعفة هي $point')),
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.myapp',
                ),

                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    markers: manyPoints
                        .map(
                          (p) => Marker(
                            point: p,
                            width: 36,
                            height: 36,
                            child: const Icon(
                              Icons.store,
                              color: Colors.deepPurple,
                              size: 32,
                            ),
                          ),
                        )
                        .toList(),
                    builder: (context, markers) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${markers.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (routePoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 4,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                if (trail.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: trail,
                        strokeWidth: 4,
                        color: Colors.red,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // ...routePoints.map((p) {
                    //   if (p == myLocation)
                    //     return Marker(point: p, child: SizedBox.shrink());
                    //   return Marker(
                    //     point: p,
                    //     width: 40,
                    //     height: 40,
                    //     child: const Icon(
                    //       Icons.location_pin,
                    //       color: Colors.red,
                    //       size: 40,
                    //     ),
                    //   );
                    // }),
                    if (searchedPlace != null)
                      Marker(
                        point: searchedPlace!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.place,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                    ...points.map((p) {
                      if (p == myLocation)
                        return Marker(point: p, child: SizedBox.shrink());
                      return Marker(
                        point: p,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.teal,
                          size: 40,
                        ),
                      );
                    }),
                    // علامة موقعي (تظهر فقط إذا عرفناه)
                    if (myLocation != null)
                      Marker(
                        point: myLocation!,
                        width: 30,
                        height: 30,
                        child: const Icon(
                          Icons.circle,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                child: TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: searchPlace, // عند الضغط على Enter/بحث
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مكان...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => searchPlace(searchController.text),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
