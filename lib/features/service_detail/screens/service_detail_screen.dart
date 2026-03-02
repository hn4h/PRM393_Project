import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/service_header_image.dart';
import '../widgets/service_info_section.dart';
import '../widgets/service_details_card.dart';
import '../widgets/top_workers_list.dart';
import '../widgets/review_section.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [_buildMainContent(), _buildBottomBookingButton(context)],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ServiceHeaderImage(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceInfoSection(),
                SizedBox(height: 24),
                ServiceDetailsCard(),
                SizedBox(height: 24),
                TopWorkersList(),
                SizedBox(height: 24),
                ReviewSection(),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
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
        child: ElevatedButton(
          onPressed: () {
            context.pushNamed('booking-flow');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008DDA),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Book Service",
            style: TextStyle(
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
