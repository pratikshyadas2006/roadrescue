import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';
import 'package:rr/services/api_service.dart';
import 'package:rr/services/session_manager.dart';

/// Shared dark/light hybrid theme tokens — kept in sync with home_screen.dart.
class _RRColors {
  static const canvasTop = Color(0xFF0A1220);
  static const canvasMid = Color(0xFF0F1B30);
  static const canvasBottom = Color(0xFF16233D);
  static const moonlight = Color(0xFF3A4C7A);
  static const mistLavender = Color(0xFF8FA6FF);
  static const beaconAmber = Color(0xFFFFB020);
  static const beaconAmberSoft = Color(0xFFFFD27A);
  static const glassFill = Color(0x14FFFFFF);
  static const glassFillHover = Color(0x1FFFFFFF);
  static const glassBorder = Color(0x26FFFFFF);
  static const glassHighlight = Color(0x4DFFFFFF);
  static const textOnDark = Colors.white;
  static const textMutedOnDark = Color(0xFFA9B4C4);
}

/// Vehicle Breakdown flow:
/// Step 1 -> pick vehicle type (Car / Bike)
/// Step 2 -> pick the issue (preset list) OR type it manually
/// Step 3 -> confirm and simulate sending the request
class VehicleBreakdownScreen extends StatefulWidget {
  const VehicleBreakdownScreen({super.key});

  @override
  State<VehicleBreakdownScreen> createState() =>
      _VehicleBreakdownScreenState();
}

class _VehicleBreakdownScreenState extends State<VehicleBreakdownScreen> {
  int _step = 0; // 0 = vehicle type, 1 = issue selection

  String? _selectedVehicle; // 'Car' or 'Bike'
  String? _selectedIssue; // preset issue label, or null if using custom text
  final TextEditingController _customIssueController = TextEditingController();

  final List<_IssueOption> _issues = const [
    _IssueOption('Flat Tyre', Icons.tire_repair_outlined),
    _IssueOption('Battery Dead', Icons.battery_alert_outlined),
    _IssueOption('Engine Overheating', Icons.local_fire_department_outlined),
    _IssueOption('Fuel Finished', Icons.local_gas_station_outlined),
    _IssueOption('Brake Issue', Icons.warning_amber_outlined),
    _IssueOption('Other', Icons.more_horiz_rounded),
  ];

  @override
  void dispose() {
    _customIssueController.dispose();
    super.dispose();
  }

  void _selectVehicle(String vehicle) {
    setState(() {
      _selectedVehicle = vehicle;
      _step = 1;
    });
  }

  void _selectIssue(String issue) {
    setState(() {
      _selectedIssue = issue;
      if (issue != 'Other') {
        _customIssueController.clear();
      }
    });
  }

  bool get _canContinue {
    if (_selectedIssue == null) return false;
    if (_selectedIssue == 'Other') {
      return _customIssueController.text.trim().isNotEmpty;
    }
    return true;
  }

  void _goBackToVehicleStep() {
    setState(() {
      _step = 0;
      _selectedIssue = null;
    });
  }

  Future<void> _submitRequest() async {

  final String issueText = _selectedIssue == 'Other'
      ? _customIssueController.text.trim()
      : _selectedIssue!;


  final user = await SessionManager.getUserDetails();


  final result = await ApiService.sendBreakdownRequest(
  userId: user["user_id"],
  vehicleType: _selectedVehicle!,
  issueType: issueText,
  description: issueText,
  latitude: "0",
  longitude: "0",
);

  if (result["success"] == true) {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => _RequestSentSheet(
        vehicle: _selectedVehicle!,
        issue: issueText,
      ),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result["message"]),
        backgroundColor: Colors.red,
      ),
    );

  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RRColors.canvasTop,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_step == 1) {
              _goBackToVehicleStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'Vehicle Breakdown',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _RRCanvas(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _step == 0 ? _buildVehicleStep() : _buildIssueStep(),
          ),
        ),
      ),
    );
  }

  // ---------------- Step 1: Vehicle type ----------------
  Widget _buildVehicleStep() {
    return Padding(
      key: const ValueKey('vehicle-step'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'What are you driving?',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select your vehicle type to continue',
            style: TextStyle(fontSize: 13, color: _RRColors.textMutedOnDark),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _VehicleTypeCard(
                    label: 'Car',
                    icon: Icons.directions_car_filled_rounded,
                    selected: _selectedVehicle == 'Car',
                    onTap: () => _selectVehicle('Car'),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _VehicleTypeCard(
                    label: 'Bike',
                    icon: Icons.two_wheeler_rounded,
                    selected: _selectedVehicle == 'Bike',
                    onTap: () => _selectVehicle('Bike'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Step 2: Issue selection ----------------
  Widget _buildIssueStep() {
    return Column(
      key: const ValueKey('issue-step'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedVehicle == 'Car'
                          ? Icons.directions_car_filled_rounded
                          : Icons.two_wheeler_rounded,
                      color: _RRColors.beaconAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_selectedVehicle selected',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _RRColors.textMutedOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "What's the problem?",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.3,
                  children: _issues.map((issue) {
                    final bool selected = _selectedIssue == issue.label;
                    return _IssueCard(
                      option: issue,
                      selected: selected,
                      onTap: () => _selectIssue(issue.label),
                    );
                  }).toList(),
                ),
                if (_selectedIssue == 'Other') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customIssueController,
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: _RRColors.beaconAmber,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in your own words...',
                      hintStyle: const TextStyle(color: _RRColors.textMutedOnDark),
                      filled: true,
                      fillColor: _RRColors.glassFill,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _RRColors.glassBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _RRColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _RRColors.beaconAmber, width: 1.4),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _BeaconButton(
            label: 'Request Assistance',
            onPressed: _canContinue ? _submitRequest : null,
          ),
        ),
      ],
    );
  }
}

class _IssueOption {
  final String label;
  final IconData icon;
  const _IssueOption(this.label, this.icon);
}

class _VehicleTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      onTap: onTap,
      borderRadius: 20,
      highlighted: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [_RRColors.beaconAmber.withValues(alpha: 0.16), _RRColors.glassFill]
                : [_RRColors.glassFillHover, _RRColors.glassFill],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _RRColors.beaconAmber : _RRColors.glassBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: selected ? _RRColors.beaconAmber : Colors.white),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final _IssueOption option;
  final bool selected;
  final VoidCallback onTap;

  const _IssueCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassSurface(
      onTap: onTap,
      borderRadius: 16,
      highlighted: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [_RRColors.beaconAmber.withValues(alpha: 0.16), _RRColors.glassFill]
                : [_RRColors.glassFillHover, _RRColors.glassFill],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _RRColors.beaconAmber : _RRColors.glassBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: selected ? _RRColors.beaconAmber : _RRColors.textMutedOnDark,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _RRColors.textMutedOnDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet shown after the request is "submitted" (simulated — no
/// backend call yet, this just demonstrates the flow for the demo/viva).
class _RequestSentSheet extends StatelessWidget {
  final String vehicle;
  final String issue;

  const _RequestSentSheet({required this.vehicle, required this.issue});

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.successGreen.withValues(alpha: 0.3), blurRadius: 16),
              ],
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.successGreen,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Service Request Sent Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$vehicle · $issue\nWe\'re finding the nearest garage for you.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: _RRColors.textMutedOnDark),
          ),
          const SizedBox(height: 24),
          _BeaconButton(
            label: 'Back to Home',
            onPressed: () {
              Navigator.of(context).pop(); // close sheet
              Navigator.of(context).pop(); // back to home
            },
          ),
        ],
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
          top: -140,
          right: -100,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _RRColors.mistLavender.withValues(alpha: 0.16),
                  _RRColors.moonlight.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -130,
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

/// Frosted-glass tappable surface with a light-catching top sheen —
/// the shared building block behind every card in this screen.
class _GlassSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;
  final bool highlighted;

  const _GlassSurface({
    required this.child,
    required this.onTap,
    required this.borderRadius,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              SizedBox(width: double.infinity, child: child),
              Positioned(
                top: 0,
                left: 12,
                right: 12,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (highlighted ? _RRColors.beaconAmberSoft : _RRColors.glassHighlight)
                            .withValues(alpha: highlighted ? 0.6 : 1.0),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Beacon-amber primary action button, matching the home screen's hero glow.
class _BeaconButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _BeaconButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: _RRColors.beaconAmber.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _RRColors.beaconAmber,
          disabledBackgroundColor: _RRColors.glassFill,
          foregroundColor: const Color(0xFF0A1220),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? const Color(0xFF0A1220) : _RRColors.textMutedOnDark,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

/// Dark glass shell for bottom sheets, replacing the default white sheet.
class _SheetShell extends StatelessWidget {
  final Widget child;
  const _SheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_RRColors.canvasMid, _RRColors.canvasBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(top: BorderSide(color: _RRColors.glassBorder)),
          ),
          child: child,
        ),
      ),
    );
  }
}