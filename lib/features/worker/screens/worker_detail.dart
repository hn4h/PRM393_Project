import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/header.dart';
import '../widgets/stats.dart';
import '../widgets/about.dart';
import '../widgets/gallery.dart';
import '../widgets/schedule_location_card.dart';
import '../widgets/reviews_preview.dart';
import '../widgets/bottom_bar.dart';

class WorkerDetailScreen extends StatelessWidget {
  const WorkerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Header(),
                    SizedBox(height: 16),
                    Stats(),
                    SizedBox(height: 20),
                    About(),
                    SizedBox(height: 20),
                    Gallery(),
                    SizedBox(height: 20),
                    ScheduleLocationCard(),
                    SizedBox(height: 20),
                    ReviewsPreview(),
                  ],
                ),
              ),
            ),

            // Footer
            BottomBar(),
          ],
        ),
      ),
    );
  }
}