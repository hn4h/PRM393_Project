import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/home/widgets/worker_card.dart';
import 'package:prm_project/features/review/models/review_display_item.dart';
import 'package:prm_project/features/review/models/review_list_args.dart';
import '../viewmodel/service_detail_viewmodel.dart';
import 'package:prm_project/features/service/widgets//bottom_bar.dart';
import 'package:prm_project/features/service/widgets//details_card.dart';
import 'package:prm_project/features/service/widgets//header.dart';
import 'package:prm_project/features/service/widgets/info_section.dart';
import 'package:prm_project/features/service/widgets/review_section.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serviceDetailViewmodelProvider(serviceId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final Service service = data.service;
          final List<Worker> workers = data.workers;
          final List<ReviewDisplayItem> reviews = data.reviews;

          return Stack(
            children: [
              _buildMainContent(context, service, workers, reviews),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomBar(serviceId: service.id),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    Service service,
    List<Worker> workers,
    List<ReviewDisplayItem> reviews,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(service: service),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoSection(service: service),
                const SizedBox(height: 24),
                DetailsCard(service: service),
                const SizedBox(height: 24),
                if (workers.isNotEmpty) ...[
                  const Text(
                    'Top Workers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 290,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: workers.length,
                      itemBuilder: (context, index) =>
                          WorkerCard(worker: workers[index]),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ReviewSection(
                  reviews: reviews,
                  onSeeAll: () {
                    context.pushNamed(
                      'reviews',
                      extra: ReviewListArgs(
                        title: 'Service Reviews',
                        reviews: reviews,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
