import 'package:location/location.dart';

class LocationServices {
  Location location = Location();
  Future<bool> checkAndRequestLocationServices() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkAndRequestPermissionStatus() async {
    location = Location();
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    }
    return true;
  }

  void getRealTimeData({required void Function(LocationData)? onData}) {
    location.changeSettings(distanceFilter: 2);
    location.onLocationChanged.listen(onData);
  }
}
