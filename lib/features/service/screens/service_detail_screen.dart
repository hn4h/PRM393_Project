import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/models/service.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/service/widgets/workers_horizontal_list.dart';



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

          return Stack(
            children: [
              _buildMainContent(context, service, workers),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomBar(),
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
                WorkersHorizontalList(workers: demoWorkers),
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
