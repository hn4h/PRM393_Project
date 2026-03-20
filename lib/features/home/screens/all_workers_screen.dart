import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/home_viewmodel.dart';
import '../widgets/worker_card.dart';

class AllWorkersScreen extends ConsumerWidget {
  const AllWorkersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(topWorkersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Workers')),
      body: workersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (workers) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workers.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 280,
              child: WorkerCard(worker: workers[index]),
            ),
          ),
        ),
      ),
    );
  }
}
