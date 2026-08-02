import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

/// Shared dark/light hybrid theme tokens — kept in sync with home_screen.dart.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillHover = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassHighlight = Color(0x4DFFFFFF);
  static const textOnDark = Colors.white;
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

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
    _Category('Garages', Icons.car_repair_rounded, Color(0xFF5B8DEF)),
    _Category('Fuel Pumps', Icons.local_gas_station_rounded, Color(0xFFFFA940)),
    _Category('Hospitals', Icons.local_hospital_rounded, AppColors.emergencyRed),
    _Category('Police', Icons.local_police_rounded, Color(0xFF7C93B8)),
    _Category('Ambulance', Icons.emergency_rounded, Color(0xFF4FD1C5)),
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
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Nearby Services',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48), // clears the transparent app bar

              // Map placeholder — swap for GoogleMap widget wired to live location.
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [category.color.withValues(alpha: 0.14), _RRColors.glassFill],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _RRColors.glassBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, size: 36, color: category.color),
                        const SizedBox(height: 6),
                        Text(
                          'Map view — ${category.label} near you',
                          style: const TextStyle(fontSize: 12, color: _RRColors.textMutedOnDark),
                        ),
                      ],
                    ),
                  ),
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
                      avatar: Icon(c.icon, size: 16, color: selected ? const Color(0xFF0A1220) : c.color),
                      selected: selected,
                      selectedColor: c.color,
                      backgroundColor: _RRColors.glassFill,
                      labelStyle: TextStyle(
                        color: selected ? const Color(0xFF0A1220) : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(color: selected ? c.color : _RRColors.glassBorder),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [category.color.withValues(alpha: 0.08), _RRColors.glassFill],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _RRColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: category.color.withValues(alpha: 0.3), blurRadius: 10),
                      ],
                    ),
                    child: Icon(category.icon, color: category.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(place.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: _RRColors.beaconAmber),
                            const SizedBox(width: 2),
                            Text('${place.rating}', style: const TextStyle(fontSize: 12, color: _RRColors.textMutedOnDark)),
                            const SizedBox(width: 8),
                            Text('· ${place.distance}', style: const TextStyle(fontSize: 12, color: _RRColors.textMutedOnDark)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(place.status, style: const TextStyle(fontSize: 11.5, color: AppColors.successGreen, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.directions_rounded, color: category.color),
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
            ),
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, _RRColors.glassHighlight, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dark gradient canvas + soft moonlight glows, shared across screens.
class _RRCanvas extends StatelessWidget {
  final Widget child;
  const _RRCanvas({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_RRColors.canvasTop, _RRColors.canvasMid, _RRColors.canvasBottom],
              stops: [0.0, 0.45, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -130,
          right: -100,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.mistLavender.withValues(alpha: 0.15),
                  _RRColors.mistLavender.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -110,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.beaconAmber.withValues(alpha: 0.07),
                  _RRColors.beaconAmber.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}