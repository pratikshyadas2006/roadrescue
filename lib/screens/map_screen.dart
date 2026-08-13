import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rr/services/places_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(19.0760, 72.8777),
    zoom: 14,
  );

  Position? currentPosition;
  GoogleMapController? mapController;

  final PlacesService placesService = PlacesService();
  String selectedType = "car_repair";
  String selectedPlaceName = "";
  String selectedPlaceAddress = "";
  double selectedPlaceRating = 0.0;
  double selectedPlaceLat = 0.0;
  double selectedPlaceLng = 0.0;
  String selectedPlacePhone = "";
  String selectedPlaceId = "";

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    currentPosition = await Geolocator.getCurrentPosition();

    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: LatLng(
            currentPosition!.latitude,
            currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: "You are here",
          ),
        ),
      );
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        16,
      ),
    );

    await loadNearbyMechanics();
  }

  Future<void> loadNearbyMechanics() async {
    if (currentPosition == null) return;

    final places = await placesService.getNearbyPlaces(
      latitude: currentPosition!.latitude,
      longitude: currentPosition!.longitude,
      type: selectedType,
    );

    setState(() {
      for (var place in places) {
        markers.add(
          Marker(
            markerId: MarkerId(place["place_id"]),
            position: LatLng(
              place["geometry"]["location"]["lat"],
              place["geometry"]["location"]["lng"],
            ),
            infoWindow: InfoWindow(
              title: place["name"],
              snippet: place["vicinity"] ?? "",
            ),
            onTap: () async {
              setState(() {
                selectedPlaceName = place["name"] ?? "";
                selectedPlaceAddress = place["vicinity"] ?? "";
                selectedPlaceRating = (place["rating"] ?? 0).toDouble();
                selectedPlaceLat = place["geometry"]["location"]["lat"];
                selectedPlaceLng = place["geometry"]["location"]["lng"];
                selectedPlaceId = place["place_id"];
                selectedPlacePhone = "";
              });

              final details =
                  await placesService.getPlaceDetails(selectedPlaceId);

              if (details != null) {
                selectedPlacePhone =
                    details["formatted_phone_number"] ??
                    details["international_phone_number"] ??
                    "";
              }

              showPlaceDetails();
            },
          ),
        );
      }
    });
  }

  void showPlaceDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPlaceName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedPlaceAddress,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "⭐ Rating: $selectedPlaceRating",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (selectedPlacePhone.isEmpty) {
                            return;
                          }

                          final Uri phoneUrl = Uri.parse(
                            "tel:$selectedPlacePhone",
                          );

                          if (await canLaunchUrl(phoneUrl)) {
                            await launchUrl(phoneUrl);
                          }
                        },
                        icon: const Icon(Icons.call),
                        label: const Text("Call"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri googleMapsUrl = Uri.parse(
                            "https://www.google.com/maps/dir/?api=1&destination=$selectedPlaceLat,$selectedPlaceLng",
                          );

                          if (await canLaunchUrl(googleMapsUrl)) {
                            await launchUrl(
                              googleMapsUrl,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text("Navigate"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    selectedType = "car_repair";
                    markers.clear();
                    await getCurrentLocation();
                  },
                  child: const Text("🔧 Mechanics"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    selectedType = "gas_station";
                    markers.clear();
                    await getCurrentLocation();
                  },
                  child: const Text("⛽ Petrol"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    selectedType = "hospital";
                    markers.clear();
                    await getCurrentLocation();
                  },
                  child: const Text("🏥 Hospital"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    selectedType = "police";
                    markers.clear();
                    await getCurrentLocation();
                  },
                  child: const Text("👮 Police"),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}