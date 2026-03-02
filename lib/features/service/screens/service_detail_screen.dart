import 'package:flutter/material.dart';

import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/home/widgets/worker_card.dart';

import '../widgets/header.dart';
import '../widgets/info_section.dart';
import '../widgets/details_card.dart';
import '../widgets/review_section.dart';
import 'package:prm_project/features/service/widgets/bottom_bar.dart';

class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          _buildMainContent(context),
          const Align(alignment: Alignment.bottomCenter, child: BottomBar()),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InfoSection(),
                const SizedBox(height: 24),
                const DetailsCard(),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Top Workers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text("See All")),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 290,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: demoWorkers.length,
                    itemBuilder: (context, index) {
                      return WorkerCard(worker: demoWorkers[index]);
                    },
                  ),
                ),

                const SizedBox(height: 24),
                const ReviewSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
