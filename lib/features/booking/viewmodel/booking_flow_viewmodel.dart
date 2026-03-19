import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/booking.dart';
import '../../../core/enums/booking_status.dart';
import '../repository/booking_repository.dart';

part 'booking_flow_viewmodel.g.dart';

/// State for the multi-step booking flow.
class BookingFlowState {
  final int currentStep;
  final Booking booking;
  final bool isSubmitting;
  final String? error;
  final bool isBookingForOther;
  final String? selectedPaymentMethod;

  BookingFlowState({
    required this.currentStep,
    required this.booking,
    this.isSubmitting = false,
    this.error,
    this.isBookingForOther = false,
    this.selectedPaymentMethod,
  });

  BookingFlowState copyWith({
    int? currentStep,
    Booking? booking,
    bool? isSubmitting,
    String? error,
    bool? isBookingForOther,
    String? selectedPaymentMethod,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      booking: booking ?? this.booking,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isBookingForOther: isBookingForOther ?? this.isBookingForOther,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

@riverpod
class BookingFlowViewModel extends _$BookingFlowViewModel {
  @override
  BookingFlowState build() {
    return BookingFlowState(
      currentStep: 0,
      booking: Booking(
        id: '',
        customerId: '',
        status: BookingStatus.pending,
        totalPrice: 0.0,
        paymentMethod: 'cash',
        durationMinutes: 60,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Initialize the flow with context from the selected worker/service.
  void init({
    required String customerId,
    String? serviceId,
    String? workerId,
    double? servicePrice,
    String? serviceName,
    String? workerName,
  }) {
    state = state.copyWith(
      booking: state.booking.copyWith(
        customerId: customerId,
        serviceId: serviceId,
        workerId: workerId,
        totalPrice: servicePrice ?? state.booking.totalPrice,
        serviceName: serviceName,
        workerName: workerName,
      ),
    );
  }

  void updateBooking(Booking updated) {
    state = state.copyWith(booking: updated);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(
      selectedPaymentMethod: method,
      booking: state.booking.copyWith(paymentMethod: method),
    );
  }

  void toggleBookingForOther(bool value) {
    state = state.copyWith(isBookingForOther: value);
    if (!value) {
      state = state.copyWith(
        booking: state.booking.copyWith(
          contactName: null,
          contactPhone: null,
        ),
      );
    }
  }

  void nextStep() =>
      state = state.copyWith(currentStep: state.currentStep + 1);

  void previousStep() =>
      state = state.copyWith(currentStep: state.currentStep - 1);

  /// Submit booking to Supabase.
  Future<Booking?> checkout() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final created = await ref
          .read(bookingRepositoryProvider)
          .createBooking(state.booking);
      state = state.copyWith(isSubmitting: false, booking: created);
      return created;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return null;
    }
  }
}
