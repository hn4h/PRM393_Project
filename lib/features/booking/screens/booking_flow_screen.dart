import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/step_worker_service.dart';
import '../widgets/step_worker_info.dart';
import '../widgets/step_schedule.dart';
import '../widgets/step_summary.dart';
import '../widgets/step_personal_info.dart';
import '../widgets/step_payment.dart';
import '../widgets/step_notes.dart';
import '../viewmodel/booking_flow_viewmodel.dart';
import '../../booking_history/viewmodel/booking_history_viewmodel.dart';

class BookingFlowScreen extends ConsumerStatefulWidget {
  final String? serviceId;
  final String? workerId;

  const BookingFlowScreen({super.key, this.serviceId, this.workerId});

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initBookingFlow();
    });
  }

  Future<void> _initBookingFlow() async {
    if (_initialized) return;
    _initialized = true;

    final user = Supabase.instance.client.auth.currentUser;
    final customerId = user?.id ?? '';

    await ref
        .read(bookingFlowViewModelProvider.notifier)
        .init(
          customerId: customerId,
          serviceId: widget.serviceId,
          workerId: widget.workerId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);

    final int currentStep = flowState.currentStep;
    const int totalSteps = 6;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () {
            if (currentStep == 0) {
              context.pop();
            } else {
              notifier.previousStep();
            }
          },
        ),
        title: Text(
          "Step ${currentStep + 1} of $totalSteps",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: const Color(0xFF008DDA),
            minHeight: 2,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Show worker info card only from step 1 onwards (after selection)
                  if (currentStep > 0) ...[
                    const StepWorkerInfo(),
                    const SizedBox(height: 10),
                  ],
                  _buildStep(currentStep),
                ],
              ),
            ),
          ),
          _buildBottomButton(context, currentStep, notifier, flowState),
        ],
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const StepWorkerService();
      case 1:
        return const StepSchedule();
      case 2:
        return const StepPersonalInfo();
      case 3:
        return const StepNotes();
      case 4:
        return const StepPayment(); // Payment first
      case 5:
        return const StepSummary(); // Summary last (after payment selection)
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomButton(
    BuildContext context,
    int step,
    BookingFlowViewModel notifier,
    BookingFlowState flowState,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Disable button on step 0 if worker/service not selected
    final bool canProceed = step == 0 ? notifier.canProceedFromStep1() : true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canProceed
              ? () async {
                  if (step < 5) {
                    notifier.nextStep();
                  } else {
                    final booking = await notifier.checkout();
                    if (booking != null && context.mounted) {
                      await ref
                          .read(bookingHistoryViewModelProvider.notifier)
                          .refresh();
                      context.pushReplacementNamed('booking-confirmed');
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canProceed
                ? const Color(0xFF008DDA)
                : colorScheme.surfaceContainerHighest,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            step == 5 ? "Confirm Booking" : "Continue",
            style: TextStyle(
              color: canProceed ? Colors.white : colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
