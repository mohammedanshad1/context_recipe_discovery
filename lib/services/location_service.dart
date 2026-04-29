import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async'; // ← add this

class LocationService {
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        return false; // ← was missing! causes silent hang on some devices
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return false;
        }
      }

      return permission == LocationPermission.whileInUse ||
             permission == LocationPermission.always;
    } catch (e) {
     // debugPrint('requestPermission error: $e');
      return false;
    }
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5), // ← THIS was missing — the root cause
      );
    } on TimeoutException {
  //    debugPrint('GPS timed out, skipping location');
      return null;
    } catch (e) {
     // debugPrint('getCurrentPosition error: $e');
      return null;
    }
  }

  Future<String?> getCountryFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5)); // ← also add timeout here

      if (placemarks.isNotEmpty) {
        return placemarks[0].country;
      }
    } on TimeoutException {
    //  debugPrint('Geocoding timed out');
    } catch (e) {
     // debugPrint('getCountryFromPosition error: $e');
    }
    return null;
  }
}