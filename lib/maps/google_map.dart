import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller; // null حتى تُبنى الخريطة
  List<LatLng> points = [];
  List<LatLng> routPoints = [];
  double? routeKm; // المسافة
  double? routeMinutes; // الزمن
  bool _locationGranted = false;
  bool loading = false;
  static const _routesKey = 'AIzaSyCNb8RQB8sDWALRDSaoW-9udUgrawSPeys';

  static const LatLng tanta = LatLng(30.78, 31.00);

  // نبني Set العلامات من قائمة النقاط
  Set<Marker> get _markers => {
    for (int i = 0; i < points.length; i++)
      Marker(
        markerId: MarkerId('point_$i'), // لازم id فريد لكل علامة
        position: points[i],
        infoWindow: InfoWindow(title: 'نقطة ${i + 1}'),
      ),
  };

  Set<Polyline> get _polylines => {
    if (routPoints.length >= 2)
      Polyline(
        polylineId: const PolylineId('line'),
        points: routPoints,
        width: 4,
        color: Colors.blue,
      ),
  };

  Future<void> _goToMyLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showMessage('فعّل خدمة الموقع (GPS)');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showMessage('صلاحية الموقع مرفوضة');
      return;
    }

    // بعد الموافقة نشغّل النقطة الزرقاء
    setState(() => _locationGranted = true);

    final pos = await Geolocator.getCurrentPosition();
    points.add(LatLng(pos.latitude, pos.longitude));
    log('pos: $pos');
    await _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
    );
  }

  Future<void> getRoute() async {
    if (points.length < 2) {
      _showMessage('اضغط على الخريطة نقطتين على الأقل');
      return;
    }
    log('routesKey: ${_routesKey.length}');
    if (_routesKey.isEmpty) {
      _showMessage('المفتاح غير موجود (dart-define)');
      return;
    }

    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse('https://routes.googleapis.com/directions/v2:computeRoutes'),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _routesKey,
          'X-Goog-FieldMask':
              'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline',
        },
        body: jsonEncode({
          'origin': {
            'location': {
              'latLng': {
                'latitude': points.first.latitude,
                'longitude': points.first.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': points.last.latitude,
                'longitude': points.last.longitude,
              },
            },
          },
          'travelMode': 'DRIVE',
        }),
      );

      log('Response: ${response.body}');

      if (response.statusCode != 200) {
        _showMessage('خطأ في الطلب: ${response.statusCode}');
        return;
      }

      final json = jsonDecode(response.body);
      final routes = json['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        _showMessage('لم يتم العثور على الطريق');
        return;
      }

      final route = routes[0];
      final encoded = route['polyline']['encodedPolyline'] as String;
      final seconds = int.parse(
        (route['duration'] as String).replaceAll('s', ''),
      );

      setState(() {
        routPoints = decodePolyline(encoded);
        routeKm = (route['distanceMeters'] as num) / 1000;
        routeMinutes = seconds / 60;
      });

      _showMessage(
        'المسافة: ${routeKm!.toStringAsFixed(1)} كم | الزمن: ${routeMinutes!.round()} دقيقة',
      );
    } catch (e) {
      log('Error: $e');
      _showMessage('خطأ في الطلب');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    final result = <LatLng>[];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      // فك الـ latitude
      int shift = 0, value = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        value |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (value & 1) != 0 ? ~(value >> 1) : (value >> 1);

      // فك الـ longitude
      shift = 0;
      value = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        value |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (value & 1) != 0 ? ~(value >> 1) : (value >> 1);

      result.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return result;
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.directions_car),
            onPressed: getRoute,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() {
              points.clear();
              points = [];
              routeKm = null;
              routeMinutes = null;
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(target: tanta, zoom: 13),
          onMapCreated: (c) => _controller = c,
          onTap: (latLng) => setState(() => points.add(latLng)),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: _locationGranted,
          myLocationButtonEnabled: false, // عندنا زرنا الخاص
        ),
      ),
    );
  }
}
