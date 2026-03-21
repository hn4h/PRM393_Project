import 'package:flutter_riverpod/flutter_riverpod.dart';

final serviceFavoritesProvider =
    StateNotifierProvider<ServiceFavoritesNotifier, Set<String>>((ref) {
  return ServiceFavoritesNotifier();
});

class ServiceFavoritesNotifier extends StateNotifier<Set<String>> {
  ServiceFavoritesNotifier() : super(<String>{});

  bool isFavorite(String serviceId) => state.contains(serviceId);

  void toggle(String serviceId) {
    final next = <String>{...state};
    if (!next.add(serviceId)) {
      next.remove(serviceId);
    }
    state = next;
  }
}
