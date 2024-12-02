import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bus_stop.dart';
import '../data/bus_stop_data.dart';

class MapScreen extends StatefulWidget {

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  BusStop? departureStop;
  BusStop? arrivalStop;

  void _onMarkerTapped(BusStop stop) {
    setState(() {
      if (departureStop == null) {
        departureStop = stop;
      } else if (arrivalStop == null) {
        arrivalStop = stop;
      } else {
        departureStop = stop;
        arrivalStop = null;
      }
    });
  }

  double _calculateFare() {
    if (departureStop != null && arrivalStop != null) {
      int startIndex = busStops.indexOf(departureStop!);
      int endIndex = busStops.indexOf(arrivalStop!);

      if (startIndex < endIndex) {
        return busStops.sublist(startIndex, endIndex + 1).map((e) => e.priceFromPrevious).reduce((a, b) => a + b);
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Route Fare")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(6.0351, 80.2168),
              zoom: 12,
            ),
            markers: busStops.map((stop) {
              return Marker(
                markerId: MarkerId(stop.id),
                position: LatLng(stop.latitude, stop.longitude),
                infoWindow: InfoWindow(title: stop.name),
                onTap: () => _onMarkerTapped(stop),
              );
            }).toSet(),
            onMapCreated: (controller) => _mapController = controller,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Departure: ${departureStop?.name ?? 'None'}"),
                    Text("Arrival: ${arrivalStop?.name ?? 'None'}"),
                    Text("Fare: \$${_calculateFare().toStringAsFixed(2)}"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
