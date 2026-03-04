import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/models/service.dart';
import '../../../core/models/worker.dart';
import '../repository/service_repository.dart';

part 'service_detail_viewmodel.g.dart';

class ServiceDetailData {
  final Service service;
  final List<Worker> workers;

  ServiceDetailData({required this.service, required this.workers});
}

@riverpod
class ServiceDetailViewmodel extends _$ServiceDetailViewmodel {
  @override
  Future<ServiceDetailData> build(String serviceId) async {
    final serviceRepo = ref.read(serviceRepositoryProvider);

    final service = await serviceRepo.getById(serviceId);
    if (service == null) {
      throw Exception('Service not found: $serviceId');
    }

    // get list demoWorkers in Worker model
    return ServiceDetailData(service: service, workers: demoWorkers);
  }
}