import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/bus_stop_data.dart';
import '../models/bus_stop.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  BusStop? departureStop;
  BusStop? arrivalStop;

  double _calculateFare() {
    if (departureStop != null && arrivalStop != null) {
      int startIndex = busStops.indexOf(departureStop!);
      int endIndex = busStops.indexOf(arrivalStop!);

      if (startIndex <= endIndex) {
        return busStops
            .sublist(startIndex, endIndex + 1)
            .map((stop) => stop.priceFromPrevious)
            .reduce((a, b) => a + b);
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bus Fare Calculator")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Select Departure and Arrival Points", style: TextStyle(fontSize: 18)),
                DropdownButton<BusStop>(
                  value: departureStop,
                  hint: Text("Select Departure Point"),
                  onChanged: (BusStop? newValue) {
                    setState(() {
                      departureStop = newValue;
                      arrivalStop = null; // Reset arrival stop
                    });
                  },
                  items: busStops.map((stop) {
                    return DropdownMenuItem(
                      value: stop,
                      child: Text(stop.name),
                    );
                  }).toList(),
                ),
                DropdownButton<BusStop>(
                  value: arrivalStop,
                  hint: Text("Select Arrival Point"),
                  onChanged: (BusStop? newValue) {
                    setState(() {
                      arrivalStop = newValue;
                    });
                  },
                  items: busStops
                      .where((stop) => departureStop == null || busStops.indexOf(stop) > busStops.indexOf(departureStop!))
                      .map((stop) {
                    return DropdownMenuItem(
                      value: stop,
                      child: Text(stop.name),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(6.0351, 80.2168), // Centered on Galle
                zoom: 14.0,
              ),
              markers: busStops.map((stop) {
                return Marker(
                  markerId: MarkerId(stop.id),
                  position: LatLng(stop.latitude, stop.longitude),
                  infoWindow: InfoWindow(title: stop.name),
                );
              }).toSet(),
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Fare: \$${_calculateFare().toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
