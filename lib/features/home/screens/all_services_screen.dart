import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/service_title.dart';

class AllServicesScreen extends ConsumerWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(activeServicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Services')),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (services) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (context, index) =>
              OtherServiceTile(service: services[index]),
        ),
      ),
    );
  }
}
