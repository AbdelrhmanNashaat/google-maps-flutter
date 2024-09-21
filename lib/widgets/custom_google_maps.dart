import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps/models/place_model.dart';
import 'dart:ui' as ui;

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  late GoogleMapController mapController;
  @override
  void initState() {
    // initialCameraPosition is the initial position of the camera when the map is loaded
    initialCameraPosition = const CameraPosition(
      target: LatLng(30.112653392692135, 31.344195679445313),
      // zoom level of the map when it is loaded
      /* zoom levels :
    1) World view zoom : 0 => 3
    2) country view zoom : 4 => 6
    3) city view zoom : 10 => 12
    4) street view zoom : 13 => 17
    5) building view zoom : 18 => 20
    */
      zoom: 16,
    );
    initMarkers();
    super.initState();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          zoomControlsEnabled: false,
          markers: markers,
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
        ),
      ],
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
      await getImageData(image: 'asset/images/location.png', width: 40),
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
}
