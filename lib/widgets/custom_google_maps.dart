import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps/models/location_services.dart';
import 'package:maps/models/place_model.dart';
import 'dart:ui' as ui;

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  GoogleMapController? mapController;
  late LocationServices locationServices;
  bool isFirstTime = true;
  @override
  void initState() {
    // initialCameraPosition is the initial position of the camera when the map is loaded
    initialCameraPosition = const CameraPosition(
      target: LatLng(30.112389461758138, 31.343841994108537),
      // zoom level of the map when it is loaded
      /* zoom levels :
    1) World view zoom : 0 => 3
    2) country view zoom : 4 => 6
    3) city view zoom : 10 => 12
    4) street view zoom : 13 => 17
    5) building view zoom : 18 => 20
    */
      zoom: 14,
    );
    // initMarkers();
    initPolyLines();
    initPolygons();
    initCircles();
    locationServices = LocationServices();
    voidUpdateMyLocation();
    super.initState();
  }

  @override
  void dispose() {
    mapController!.dispose();
    super.dispose();
  }

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Set<Polygon> polygons = {};
  Set<Circle> circles = {};
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      polygons: polygons,
      polylines: polylines,
      zoomControlsEnabled: false,
      markers: markers,
      circles: circles,
      // cameraTargetBounds is the bounds of the camera target. The camera target cannot go outside these bounds.
      // cameraTargetBounds: CameraTargetBounds(
      //   LatLngBounds(
      //     southwest: const LatLng(29.96466663084121, 31.185872552967002),
      //     northeast: const LatLng(30.065059815029187, 31.27657462441701),
      //   ),
      // ),
      initialCameraPosition: initialCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        //Initializes the controller once the map is created
        mapController = controller;
      },
    );
  }

  // This function is used to convert the image into raw data to be used in the marker
  // method 1 : using rootBundle if the image is in the assets folder
  Future<Uint8List> getImageData(
      {required String image, required double width}) async {
    var imageData = await rootBundle.load(image);
    var imageCodec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetWidth: width.round());
    var frameInfo = await imageCodec.getNextFrame();
    var finalImage =
        await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return finalImage!.buffer.asUint8List();
  }

  void initMarkers() async {
    var customMarkerIcon = BitmapDescriptor.bytes(
      await getImageData(image: 'asset/images/location.png', width: 20),
    );
    var myMarkers = PlaceModel.places
        .map(
          (place) => Marker(
            // icon is the icon that appears on the marker
            icon: customMarkerIcon,
            // markerId is a unique identifier for the marker, change icon
            markerId: MarkerId(place.id.toString()),
            position: LatLng(place.latitude, place.longitude),
            // infoWindow is the information window that appears when the marker is clicked
            infoWindow: InfoWindow(
              title: place.name,
            ),
          ),
        )
        .toSet();
    markers.addAll(myMarkers);
    setState(() {});
  }

  void initPolyLines() async {
    Polyline polyline = const Polyline(
      // zIndex is the order of the polyline in the map
      zIndex: 1,
      // geodesic is a boolean that make the polyline follow the curvature of the earth
      geodesic: true,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      polylineId: PolylineId('1'),
      color: Colors.purple,
      points: [
        LatLng(30.11235336118366, 31.398796559131704),
        LatLng(30.134088728528685, 31.384617820445133),
      ],
    );
    polylines.add(polyline);
  }

  void initPolygons() {
    Polygon polygon = Polygon(
      // we can use holes to create a polygon with a hole in the middle
      polygonId: const PolygonId('1'),
      points: const [
        LatLng(30.119600460915482, 31.340210283244776),
        LatLng(30.1181898565391, 31.361324631832577),
        LatLng(30.1149973614822, 31.317894305166384),
        LatLng(30.133557054702283, 31.32328748709566),
        LatLng(30.119600460915482, 31.340210283244776),
      ],
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.blue.withOpacity(0.5),
    );
    polygons.add(polygon);
  }

  void initCircles() {
    Circle circle = Circle(
      circleId: const CircleId('1'),
      center: const LatLng(30.092455778679195, 31.347928443506724),
      radius: 500,
      strokeWidth: 2,
      strokeColor: Colors.red,
      fillColor: Colors.deepPurple.withOpacity(0.5),
    );
    circles.add(circle);
  }

  void voidUpdateMyLocation() async {
    await locationServices.checkAndRequestLocationServices();
    var hasPermission =
        await locationServices.checkAndRequestPermissionStatus();
    if (hasPermission) {
      locationServices.getRealTimeData(
        onData: (locationData) {
          setLocationMarker(locationData);
          animateCamera(locationData);
        },
      );
    }
  }

  void animateCamera(LocationData locationData) {
    if (isFirstTime) {
      var cameraPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 17,
      );
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      isFirstTime = false;
    } else {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(locationData.latitude!, locationData.longitude!),
        ),
      );
    }
  }

  void setLocationMarker(LocationData locationData) {
    var locationMarker = Marker(
      markerId: const MarkerId('myLocation'),
      position: LatLng(locationData.latitude!, locationData.longitude!),
    );
    markers.add(locationMarker);
    setState(() {});
  }
}
