import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCountryFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        return placemarks[0].country;
      }
    } catch (e) {
      // Fallback or handle error
    }
    return null;
  }
}