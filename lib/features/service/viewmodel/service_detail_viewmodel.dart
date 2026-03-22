import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/service.dart';
import '../../../core/models/worker.dart';
import '../../review/models/review_display_item.dart';
import '../../review/repositories/review_repository.dart';
import '../repository/service_repository.dart';
import '../../worker/repository/worker_repository.dart';

part 'service_detail_viewmodel.g.dart';

class ServiceDetailData {
  final Service service;
  final List<Worker> workers;
  final List<ReviewDisplayItem> reviews;

  ServiceDetailData({
    required this.service,
    required this.workers,
    required this.reviews,
  });
}

@riverpod
class ServiceDetailViewmodel extends _$ServiceDetailViewmodel {
  @override
  Future<ServiceDetailData> build(String serviceId) async {
    final serviceRepo = ref.read(serviceRepositoryProvider);
    final reviewRepo = ref.read(reviewRepositoryProvider);

    final service = await serviceRepo.getById(serviceId);
    if (service == null) {
      throw Exception('Service not found: $serviceId');
    }

    final workers = await serviceRepo.getWorkersForService(serviceId);
    final reviews = await reviewRepo.getServiceReviews(serviceId, limit: 10);

    return ServiceDetailData(
      service: service,
      workers: workers,
      reviews: reviews,
    );
  }
}
