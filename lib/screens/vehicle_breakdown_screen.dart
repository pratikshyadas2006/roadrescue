import 'package:flutter/material.dart';
import 'package:rr/theme/app_colors.dart';

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

  void _submitRequest() {
    final String issueText = _selectedIssue == 'Other'
        ? _customIssueController.text.trim()
        : _selectedIssue!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RequestSentSheet(
        vehicle: _selectedVehicle!,
        issue: issueText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
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
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _step == 0 ? _buildVehicleStep() : _buildIssueStep(),
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select your vehicle type to continue',
            style: TextStyle(fontSize: 13, color: Colors.black54),
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
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_selectedVehicle selected',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "What's the problem?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                    decoration: InputDecoration(
                      hintText: 'Describe the issue in your own words...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
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
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canContinue ? _submitRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Request Assistance',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: selected ? AppColors.primary : Colors.black54,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : Colors.black87,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
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
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$vehicle · $issue\nWe\'re finding the nearest garage for you.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                Navigator.of(context).pop(); // back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}