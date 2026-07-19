import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

/// Nearby Services screen.
/// Category tabs for Garages / Fuel Pumps / Hospitals / Police / Ambulance.
/// List uses placeholder data for now — swap `_placeholderResults` for a
/// real Google Places / Maps API call (via your PHP backend) later.
class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  int _selectedCategory = 0;

  final List<_Category> _categories = const [
    _Category('Garages', Icons.car_repair_rounded, AppColors.primary),
    _Category('Fuel Pumps', Icons.local_gas_station_rounded, Colors.orange),
    _Category('Hospitals', Icons.local_hospital_rounded, AppColors.emergencyRed),
    _Category('Police', Icons.local_police_rounded, Colors.blueGrey),
    _Category('Ambulance', Icons.emergency_rounded, Colors.teal),
  ];

  // Placeholder results per category — replace with live API data.
  List<_PlaceResult> get _results {
    switch (_selectedCategory) {
      case 0:
        return const [
          _PlaceResult('Shree Auto Garage', '1.2 km away', 4.3, 'Open now'),
          _PlaceResult('Speedy Motors Service', '2.0 km away', 4.0, 'Open now'),
          _PlaceResult('City Car Care', '2.8 km away', 3.8, 'Closes 9 PM'),
        ];
      case 1:
        return const [
          _PlaceResult('HP Petrol Pump', '0.8 km away', 4.1, 'Open 24 hrs'),
          _PlaceResult('Bharat Fuel Station', '1.5 km away', 4.2, 'Open 24 hrs'),
        ];
      case 2:
        return const [
          _PlaceResult('City General Hospital', '2.1 km away', 4.5, 'Open 24 hrs'),
          _PlaceResult('Sunrise Multispecialty', '3.4 km away', 4.2, 'Open 24 hrs'),
        ];
      case 3:
        return const [
          _PlaceResult('Sector 12 Police Station', '1.7 km away', 4.0, 'Open 24 hrs'),
        ];
      default:
        return const [
          _PlaceResult('Rapid Response Ambulance', '1.0 km away', 4.6, 'Available'),
          _PlaceResult('City Emergency Ambulance', '2.3 km away', 4.4, 'Available'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _categories[_selectedCategory];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nearby Services',
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map placeholder — swap for GoogleMap widget wired to live location.
            Container(
              width: double.infinity,
              height: 160,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 36, color: Colors.blueGrey.shade300),
                  const SizedBox(height: 6),
                  Text(
                    'Map view — ${category.label} near you',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
                  ),
                ],
              ),
            ),

            // Category chip selector.
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final c = _categories[index];
                  final bool selected = index == _selectedCategory;
                  return ChoiceChip(
                    label: Text(c.label, style: const TextStyle(fontSize: 12.5)),
                    avatar: Icon(c.icon, size: 16, color: selected ? Colors.white : c.color),
                    selected: selected,
                    selectedColor: c.color,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                    side: BorderSide(color: selected ? c.color : AppColors.border),
                    onSelected: (_) => setState(() => _selectedCategory = index),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Results list.
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _results.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final place = _results[index];
                  return _PlaceCard(place: place, category: category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

class _PlaceResult {
  final String name;
  final String distance;
  final double rating;
  final String status;
  const _PlaceResult(this.name, this.distance, this.rating, this.status);
}

class _PlaceCard extends StatelessWidget {
  final _PlaceResult place;
  final _Category category;
  const _PlaceCard({required this.place, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text('${place.rating}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 8),
                    Text('· ${place.distance}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(place.status, style: TextStyle(fontSize: 11.5, color: AppColors.successGreen, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.directions_rounded, color: AppColors.primary),
                onPressed: () {},
                tooltip: 'Navigate',
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded, color: AppColors.successGreen, size: 20),
                onPressed: () {},
                tooltip: 'Call',
              ),
            ],
          ),
        ],
      ),
    );
  }
}