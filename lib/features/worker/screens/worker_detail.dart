import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/worker_detail_viewmodel.dart';
import '../widgets/header.dart';
import '../widgets/stats.dart';
import '../widgets/about.dart';
import '../widgets/gallery.dart';
import '../widgets/schedule_location_card.dart';
import '../widgets/reviews_preview.dart';
import '../widgets/bottom_bar.dart';

class WorkerDetailScreen extends ConsumerWidget {
  final String workerId;

  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workerDetailViewModelProvider(workerId));

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
        child: Builder(
          builder: (_) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text(state.error!));
            }

            final worker = state.worker;
            if (worker == null) {
              return const Center(child: Text("Worker not found"));
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(worker: worker),
                        const SizedBox(height: 16),
                        Stats(worker: worker),
                        const SizedBox(height: 20),
                        About(worker: worker),
                        const SizedBox(height: 20),
                        Gallery(images: worker.galleryImages),
                        const SizedBox(height: 20),
                        ScheduleLocationCard(worker: worker),
                        const SizedBox(height: 20),
                        ReviewsPreview(),
                      ],
                    ),
                  ),
                ),
                const BottomBar(),
              ],
            );
          },
        ),
      ),
    );
  }
}