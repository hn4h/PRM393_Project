import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/worker.dart';
import '../repository/booking_repository.dart';

part 'booking_flow_viewmodel.g.dart';

class BookingFlowState {
  final int currentStep;
  final Booking booking;

  BookingFlowState({required this.currentStep, required this.booking});

  BookingFlowState copyWith({int? currentStep, Booking? booking}) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      booking: booking ?? this.booking,
    );
  }
}

@riverpod
class BookingFlowViewModel extends _$BookingFlowViewModel {
  @override
  BookingFlowState build() {
    final defaultWorker = demoWorkers[0];

    return BookingFlowState(
      currentStep: 0,
      booking: Booking(
        id: DateTime.now().toString(),
        worker: defaultWorker,
        services: [],
        status: BookingStatus.upcoming,
        scheduledAt: DateTime.now(),
        duration: "Standard",
        totalPrice: 0.0,
      ),
    );
  }

  void updateBooking(Booking updated) {
    state = state.copyWith(booking: updated);
  }

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void previousStep() =>
      state = state.copyWith(currentStep: state.currentStep - 1);

  Future<void> checkout() async {
    await ref.read(bookingRepositoryProvider).add(state.booking);
  }
}
