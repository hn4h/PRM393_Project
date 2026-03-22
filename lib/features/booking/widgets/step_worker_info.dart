import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/booking_flow_viewmodel.dart';

class StepWorkerInfo extends ConsumerWidget {
  const StepWorkerInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowState = ref.watch(bookingFlowViewModelProvider);
    final worker = flowState.selectedWorker;
    final service = flowState.selectedService;

    // If no worker/service selected yet, show placeholder
    if (worker == null && service == null) {
      return const SizedBox();
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: worker != null
                  ? NetworkImage(worker.image)
                  : null,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: worker == null
                  ? Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        worker?.name ?? "Worker",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (worker?.isVerified == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF008DDA),
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (service != null)
                    Text(
                      service.name,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (worker != null) ...[
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        Text(
                          " ${worker.rating.toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      if (service != null) ...[
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: Color(0xFF008DDA),
                          size: 16,
                        ),
                        Text(
                          " \$${service.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Color(0xFF008DDA),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(thickness: 1, color: Colors.grey.shade200),
        const SizedBox(height: 10),
      ],
    );
  }
}
