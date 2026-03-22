import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/service.dart';
import '../../../core/models/worker.dart';
import '../../../core/enums/booking_status.dart';
import '../repository/booking_repository.dart';
import '../../service/repository/service_repository.dart';
import '../../worker/repository/worker_repository.dart';
import '../utils/booking_validators.dart';

part 'booking_flow_viewmodel.g.dart';

/// Entry mode for booking flow
enum BookingEntryMode {
  fromService, // User selected a service first → pick worker
  fromWorker, // User selected a worker first → pick service
  manual, // User navigated directly → pick both
}

/// State for the multi-step booking flow.
class BookingFlowState {
  final int currentStep;
  final Booking booking;
  final bool isSubmitting;
  final String? error;
  final bool isBookingForOther;
  final String? selectedPaymentMethod;

  // New fields for step 1 (worker/service selection)
  final BookingEntryMode entryMode;
  final Service? preselectedService;
  final Worker? preselectedWorker;
  final List<Worker> availableWorkers;
  final List<Service> availableServices;
  final Worker? selectedWorker;
  final Service? selectedService;

  BookingFlowState({
    required this.currentStep,
    required this.booking,
    this.isSubmitting = false,
    this.error,
    this.isBookingForOther = false,
    this.selectedPaymentMethod,
    this.entryMode = BookingEntryMode.manual,
    this.preselectedService,
    this.preselectedWorker,
    this.availableWorkers = const [],
    this.availableServices = const [],
    this.selectedWorker,
    this.selectedService,
  });

  BookingFlowState copyWith({
    int? currentStep,
    Booking? booking,
    bool? isSubmitting,
    String? error,
    bool? isBookingForOther,
    String? selectedPaymentMethod,
    BookingEntryMode? entryMode,
    Service? preselectedService,
    Worker? preselectedWorker,
    List<Worker>? availableWorkers,
    List<Service>? availableServices,
    Worker? selectedWorker,
    Service? selectedService,
  }) {
    return BookingFlowState(
      currentStep: currentStep ?? this.currentStep,
      booking: booking ?? this.booking,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isBookingForOther: isBookingForOther ?? this.isBookingForOther,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      entryMode: entryMode ?? this.entryMode,
      preselectedService: preselectedService ?? this.preselectedService,
      preselectedWorker: preselectedWorker ?? this.preselectedWorker,
      availableWorkers: availableWorkers ?? this.availableWorkers,
      availableServices: availableServices ?? this.availableServices,
      selectedWorker: selectedWorker ?? this.selectedWorker,
      selectedService: selectedService ?? this.selectedService,
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
  Future<void> init({
    required String customerId,
    String? serviceId,
    String? workerId,
  }) async {
    final serviceRepo = ref.read(serviceRepositoryProvider);
    final workerRepo = ref.read(workerRepositoryProvider);

    Service? preselectedService;
    Worker? preselectedWorker;
    List<Worker> availableWorkers = [];
    List<Service> availableServices = [];
    BookingEntryMode entryMode = BookingEntryMode.manual;

    // Determine entry mode based on what was pre-selected
    if (serviceId != null && workerId == null) {
      // Coming from service selection - need to pick worker
      entryMode = BookingEntryMode.fromService;
      preselectedService = await serviceRepo.getById(serviceId);

      // Get workers who offer this service using worker_services table
      availableWorkers = await workerRepo.getWorkersByServiceId(serviceId);
    } else if (workerId != null && serviceId == null) {
      // Coming from worker selection - need to pick service
      entryMode = BookingEntryMode.fromWorker;
      preselectedWorker = await workerRepo.getById(workerId);

      // Get services this worker offers using worker_services table
      availableServices = await serviceRepo.getServicesByWorkerId(workerId);
    } else {
      // Manual mode - get all workers and services
      entryMode = BookingEntryMode.manual;
      availableWorkers = await workerRepo.getAll();
      availableServices = await serviceRepo.getAll();
    }

    state = state.copyWith(
      entryMode: entryMode,
      preselectedService: preselectedService,
      preselectedWorker: preselectedWorker,
      availableWorkers: availableWorkers,
      availableServices: availableServices,
      selectedService: preselectedService,
      selectedWorker: preselectedWorker,
      booking: state.booking.copyWith(
        customerId: customerId,
        serviceId: preselectedService?.id,
        workerId: preselectedWorker?.id,
        totalPrice: preselectedService?.price ?? state.booking.totalPrice,
        durationMinutes:
            preselectedService?.durationMinutes ??
            state.booking.durationMinutes,
        serviceName: preselectedService?.name,
        workerName: preselectedWorker?.name,
      ),
    );
  }

  /// Select a worker (when entry mode is fromService)
  void selectWorker(Worker worker) {
    state = state.copyWith(
      selectedWorker: worker,
      booking: state.booking.copyWith(
        workerId: worker.id,
        workerName: worker.name,
      ),
    );
  }

  /// Select a service (when entry mode is fromWorker)
  void selectService(Service service) {
    state = state.copyWith(
      selectedService: service,
      booking: state.booking.copyWith(
        serviceId: service.id,
        serviceName: service.name,
        totalPrice: service.price,
        durationMinutes: service.durationMinutes,
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
        booking: state.booking.copyWith(contactName: null, contactPhone: null),
      );
    }
  }

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);

  void previousStep() =>
      state = state.copyWith(currentStep: state.currentStep - 1);

  /// Check if step 1 (worker/service selection) is valid
  bool canProceedFromStep1() {
    return state.selectedWorker != null && state.selectedService != null;
  }

  /// Validate Step 1: Worker/Service Selection
  String? validateStep1() {
    if (state.selectedWorker == null) {
      return "Please select a worker";
    }
    if (state.selectedService == null) {
      return "Please select a service";
    }
    return null;
  }

  /// Validate Step 2: Schedule (Date/Time)
  String? validateStep2() {
    return BookingValidators.validateScheduledTime(state.booking.scheduledAt);
  }

  /// Validate Step 3: Personal Info (Name, Phone, Address when booking for others)
  String? validateStep3() {
    final booking = state.booking;

    // If booking for myself, personal info is auto-filled from user profile
    // No validation needed since data comes from the system
    if (!state.isBookingForOther) {
      return null;
    }

    // Booking for others - validate all fields
    String? nameError = BookingValidators.validateName(booking.contactName);
    if (nameError != null) return nameError;

    String? phoneError = BookingValidators.validatePhone(booking.contactPhone);
    if (phoneError != null) return phoneError;

    String? addressError = BookingValidators.validateAddress(booking.address);
    if (addressError != null) return addressError;

    return null;
  }

  /// Validate Step 4: Notes (Optional - no validation needed)
  /// Returns null always since notes are optional
  String? validateStep4() {
    return null; // Notes are optional
  }

  /// Validate Step 5: Payment Method
  String? validateStep5() {
    final paymentMethod = state.booking.paymentMethod;
    return BookingValidators.validatePaymentMethod(paymentMethod);
  }

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
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}
