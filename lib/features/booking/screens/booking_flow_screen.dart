import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/step_worker_info.dart';
import '../widgets/step_schedule.dart';
import '../widgets/step_summary.dart';
import '../widgets/step_personal_info.dart';
import '../widgets/step_payment.dart';
import '../widgets/step_notes.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class BookingFlowScreen extends ConsumerWidget {
  const BookingFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final notifier = ref.read(bookingFlowViewModelProvider.notifier);

    final int currentStep = flowState.currentStep;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (currentStep == 0) {
              context.pop();
            } else {
              notifier.previousStep();
            }
          },
        ),
        title: Text(
          "Step ${currentStep + 1} of 5",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF008DDA),
            minHeight: 2,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const StepWorkerInfo(),
                  const SizedBox(height: 10),
                  _buildStep(currentStep),
                ],
              ),
            ),
          ),
          _buildBottomButton(context, currentStep, notifier),
        ],
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const StepSchedule();
      case 1:
        return const StepPersonalInfo();
      case 2:
        return const StepNotes();
      case 3:
        return const StepSummary();
      case 4:
        return const StepPayment();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomButton(
    BuildContext context,
    int step,
    BookingFlowViewModel notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            if (step < 4) {
              notifier.nextStep();
            } else {
              await notifier.checkout();

              if (context.mounted) {
                context.pushReplacementNamed('booking-confirmed');
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008DDA),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            step == 4 ? "Complete Checkout" : "Continue",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
