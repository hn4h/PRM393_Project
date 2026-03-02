import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/step_worker_info.dart';
import '../widgets/step_schedule.dart';
import '../widgets/step_summary.dart';
import '../widgets/step_personal_info.dart';
import '../widgets/step_payment.dart';
import '../widgets/step_notes.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int currentStep = 0;

  void nextStep() {
    if (currentStep < 4) {
      setState(() => currentStep++);
    } else {
      // buoc cuoi payment, bam checkout se sang man hinh confirm
      context.pushReplacementNamed('booking-confirmed');
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    } else {
      context.pop(); // back ve service detail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: previousStep,
        ),
        title: const Text("Booking", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const StepWorkerInfo(),
                  const SizedBox(height: 20),
                  _buildCurrentStepWidget(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (currentStep) {
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

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          currentStep == 4 ? "Checkout" : "Continue",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
