import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_profile_provider.dart';
import '../viewmodel/booking_flow_viewmodel.dart';
import '../utils/booking_validators.dart';

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

  // Track validation state
  String? _nameError;
  String? _phoneError;
  String? _addressError;

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
    setState(() {
      _nameError = null;
      _phoneError = null;
      _addressError = null;
    });

    // Clear booking contact info
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final booking = ref.read(bookingFlowViewModelProvider).booking;
    notifier.updateBooking(
      booking.copyWith(contactName: null, contactPhone: null, address: null),
    );
  }

  void _validateName(String value) {
    setState(() {
      _nameError = BookingValidators.validateName(value);
    });
  }

  void _validatePhone(String value) {
    setState(() {
      _phoneError = BookingValidators.validatePhone(value);
    });
  }

  void _validateAddress(String value) {
    setState(() {
      _addressError = BookingValidators.validateAddress(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final booking = flowState.booking;
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);
    final userProfileAsync = ref.watch(userProfileProvider);
    final isBookingForOther = flowState.isBookingForOther;
    final colorScheme = Theme.of(context).colorScheme;

    // Initialize text fields from booking state on first build
    _initializeFromBookingState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm your booking",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
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
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 8),
        _buildRadioOption(
          title: "Book for others",
          isSelected: isBookingForOther,
          onTap: () {
            notifier.toggleBookingForOther(true);
            _clearFields();
          },
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),

        _buildTextField(
          label: "Full Name *",
          hint: "Enter your name...",
          controller: _nameController,
          enabled: isBookingForOther,
          onChanged: (val) {
            _validateName(val);
            notifier.updateBooking(booking.copyWith(contactName: val));
          },
          error: isBookingForOther ? _nameError : null,
          colorScheme: colorScheme,
        ),

        _buildTextField(
          label: "Phone Number *",
          hint: "Enter your phone...",
          controller: _phoneController,
          enabled: isBookingForOther,
          keyboardType: TextInputType.phone,
          onChanged: (val) {
            _validatePhone(val);
            notifier.updateBooking(booking.copyWith(contactPhone: val));
          },
          error: isBookingForOther ? _phoneError : null,
          colorScheme: colorScheme,
        ),

        _buildTextField(
          label: "Full Address *",
          hint: "Enter your address...",
          controller: _addressController,
          enabled: isBookingForOther,
          icon: Icons.location_on,
          onChanged: (val) {
            _validateAddress(val);
            notifier.updateBooking(booking.copyWith(address: val));
          },
          error: isBookingForOther ? _addressError : null,
          colorScheme: colorScheme,
        ),

        const SizedBox(height: 10),
        Text(
          "Package Type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            _buildPackageChip(
              "Standard",
              isSelected:
                  booking.durationMinutes ==
                  (flowState.selectedService?.durationMinutes ?? 60),
              onTap: () {
                // Standard: use service's original price and duration from database
                final service = flowState.selectedService;
                final basePrice = service?.price ?? 0;
                final baseDuration = service?.durationMinutes ?? 60;
                notifier.updateBooking(
                  booking.copyWith(
                    durationMinutes: baseDuration,
                    totalPrice: basePrice,
                  ),
                );
              },
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 12),
            _buildPackageChip(
              "Premium (2x)",
              isSelected:
                  booking.durationMinutes ==
                  ((flowState.selectedService?.durationMinutes ?? 60) ~/ 2),
              onTap: () {
                // Premium: 2x price, half duration (faster service)
                final service = flowState.selectedService;
                final basePrice = service?.price ?? 0;
                final baseDuration = service?.durationMinutes ?? 60;
                notifier.updateBooking(
                  booking.copyWith(
                    durationMinutes: baseDuration ~/ 2,
                    totalPrice: basePrice * 2,
                  ),
                );
              },
              colorScheme: colorScheme,
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
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF008DDA).withOpacity(0.1)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF008DDA)
                : colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFF008DDA)
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF008DDA)
                    : colorScheme.onSurface,
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
    String? error,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              prefixIcon: icon != null ? Icon(icon, size: 20) : null,
              filled: !enabled,
              fillColor: enabled ? null : colorScheme.surfaceContainerHighest,
              errorText: error,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFF008DDA),
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
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
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF008DDA).withOpacity(0.1)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF008DDA)
                : colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF008DDA) : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
