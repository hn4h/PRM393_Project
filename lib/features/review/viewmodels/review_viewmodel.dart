import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prm_project/core/models/booking.dart';
import 'package:prm_project/features/booking/repository/review_repository.dart'
    as booking_review;
import 'package:prm_project/features/home/viewmodels/home_viewmodel.dart';
import 'package:prm_project/features/review/models/review_display_item.dart';
import 'package:prm_project/features/review/repositories/review_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../service/viewmodel/service_detail_viewmodel.dart';
import '../../worker/viewmodel/worker_detail_viewmodel.dart';

part 'review_viewmodel.g.dart';

@riverpod
Future<List<ReviewDisplayItem>> latestReviews(LatestReviewsRef ref) {
  return ref.watch(reviewRepositoryProvider).getLatestReviews(limit: 10);
}

@riverpod
class CreateReviewController extends _$CreateReviewController {
  @override
  FutureOr<void> build() {}

  Future<void> submitReview({
    required Booking booking,
    required double rating,
    required String comment,
  }) async {
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    final workerId = booking.workerId;

    if (customerId == null || workerId == null) {
      throw Exception('Unable to submit review right now');
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(booking_review.reviewRepositoryProvider).createReview(
            bookingId: booking.id,
            workerId: workerId,
            customerId: customerId,
            rating: rating,
            comment: comment.trim(),
          );

      ref.invalidate(latestReviewsProvider);
      ref.invalidate(activeServicesProvider);
      ref.invalidate(topWorkersProvider);

      final serviceId = booking.serviceId;
      if (serviceId != null && serviceId.isNotEmpty) {
        ref.invalidate(serviceDetailViewmodelProvider(serviceId));
      }

      ref.invalidate(workerDetailViewModelProvider(workerId));
    });

    state.whenOrNull(error: (error, stackTrace) => throw error);
  }
}
