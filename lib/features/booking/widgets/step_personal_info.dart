import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepPersonalInfo extends ConsumerStatefulWidget {
  const StepPersonalInfo({super.key});

  @override
  ConsumerState<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends ConsumerState<StepPersonalInfo> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _initializeFromBookingState() {
    if (_initialized) return;
    _initialized = true;

    final flowState = ref.read(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    
    // If booking already has contact info (navigating back), restore it
    if (booking.contactName != null && booking.contactName!.isNotEmpty) {
      _nameController.text = booking.contactName ?? '';
      _phoneController.text = booking.contactPhone ?? '';
      _addressController.text = booking.address ?? '';
    } else if (!flowState.isBookingForOther) {
      // First time entering step with "Book for myself" selected
      // Auto-fill with current user's profile
      final userProfileAsync = ref.read(userProfileProvider);
      userProfileAsync.whenData((profile) {
        if (profile != null) {
          _fillUserProfile(profile);
        }
      });
    }
  }

  void _fillUserProfile(UserProfile? profile) {
    if (profile == null) return;
    _nameController.text = profile.fullName ?? '';
    _phoneController.text = profile.phone ?? '';
    _addressController.text = profile.address ?? '';

    // Update booking state
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final booking = ref.read(bookingFlowViewModelProvider).booking;
    notifier.updateBooking(
      booking.copyWith(
        contactName: profile.fullName,
        contactPhone: profile.phone,
        address: profile.address,
      ),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();

    // Clear booking contact info
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final booking = ref.read(bookingFlowViewModelProvider).booking;
    notifier.updateBooking(
      booking.copyWith(contactName: null, contactPhone: null, address: null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final userProfileAsync = ref.watch(userProfileProvider);
    final isBookingForOther = flowState.isBookingForOther;

    // Initialize text fields from booking state on first build
    _initializeFromBookingState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Confirm your booking",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Radio options
        _buildRadioOption(
          title: "Book for myself",
          isSelected: !isBookingForOther,
          onTap: () {
            notifier.toggleBookingForOther(false);
            userProfileAsync.whenData((profile) => _fillUserProfile(profile));
          },
        ),
        const SizedBox(height: 8),
        _buildRadioOption(
          title: "Book for others",
          isSelected: isBookingForOther,
          onTap: () {
            notifier.toggleBookingForOther(true);
            _clearFields();
          },
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: "Full Name",
          hint: "Enter your name...",
          controller: _nameController,
          enabled: isBookingForOther,
          onChanged: (val) {
            notifier.updateBooking(booking.copyWith(contactName: val));
          },
        ),

        _buildTextField(
          label: "Phone Number",
          hint: "Enter your phone...",
          controller: _phoneController,
          enabled: isBookingForOther,
          keyboardType: TextInputType.phone,
          onChanged: (val) {
            notifier.updateBooking(booking.copyWith(contactPhone: val));
          },
        ),

        _buildTextField(
          label: "Full Address",
          hint: "Enter your address...",
          controller: _addressController,
          enabled: isBookingForOther,
          icon: Icons.location_on,
          onChanged: (val) {
            notifier.updateBooking(booking.copyWith(address: val));
          },
        ),

        const SizedBox(height: 10),
        const Text(
          "Package Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            _buildPackageChip(
              "Standard",
              isSelected: booking.durationMinutes == (flowState.selectedService?.durationMinutes ?? 60),
              onTap: () {
                // Standard: use service's original price and duration from database
                final service = flowState.selectedService;
                final basePrice = service?.price ?? 0;
                final baseDuration = service?.durationMinutes ?? 60;
                notifier.updateBooking(
                  booking.copyWith(durationMinutes: baseDuration, totalPrice: basePrice),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildPackageChip(
              "Premium (2x)",
              isSelected: booking.durationMinutes == ((flowState.selectedService?.durationMinutes ?? 60) ~/ 2),
              onTap: () {
                // Premium: 2x price, half duration (faster service)
                final service = flowState.selectedService;
                final basePrice = service?.price ?? 0;
                final baseDuration = service?.durationMinutes ?? 60;
                notifier.updateBooking(
                  booking.copyWith(durationMinutes: baseDuration ~/ 2, totalPrice: basePrice * 2),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF008DDA).withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF008DDA) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF008DDA) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF008DDA) : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool enabled = true,
    IconData? icon,
    TextInputType? keyboardType,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              filled: !enabled,
              fillColor: enabled ? null : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF008DDA).withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF008DDA) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF008DDA) : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
