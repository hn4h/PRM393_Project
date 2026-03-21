// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$latestReviewsHash() => r'9fea9cf144fb726442b8de96bb7cc8f6cddb82d5';

/// See also [latestReviews].
@ProviderFor(latestReviews)
final latestReviewsProvider =
    AutoDisposeFutureProvider<List<ReviewDisplayItem>>.internal(
      latestReviews,
      name: r'latestReviewsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$latestReviewsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LatestReviewsRef =
    AutoDisposeFutureProviderRef<List<ReviewDisplayItem>>;
String _$createReviewControllerHash() =>
    r'3ccb1658d38a144b2941f9e108aed44d10a74820';

/// See also [CreateReviewController].
@ProviderFor(CreateReviewController)
final createReviewControllerProvider =
    AutoDisposeAsyncNotifierProvider<CreateReviewController, void>.internal(
      CreateReviewController.new,
      name: r'createReviewControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$createReviewControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CreateReviewController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
