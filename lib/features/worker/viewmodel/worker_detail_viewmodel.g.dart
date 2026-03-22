// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workerDetailViewModelHash() =>
    r'65b2887558b7b04531e89d17e2af2d2bc71ad521';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$WorkerDetailViewModel
    extends BuildlessAutoDisposeNotifier<WorkerDetailState> {
  late final String workerId;

  WorkerDetailState build(String workerId);
}

/// See also [WorkerDetailViewModel].
@ProviderFor(WorkerDetailViewModel)
const workerDetailViewModelProvider = WorkerDetailViewModelFamily();

/// See also [WorkerDetailViewModel].
class WorkerDetailViewModelFamily extends Family<WorkerDetailState> {
  /// See also [WorkerDetailViewModel].
  const WorkerDetailViewModelFamily();

  /// See also [WorkerDetailViewModel].
  WorkerDetailViewModelProvider call(String workerId) {
    return WorkerDetailViewModelProvider(workerId);
  }

  @override
  WorkerDetailViewModelProvider getProviderOverride(
    covariant WorkerDetailViewModelProvider provider,
  ) {
    return call(provider.workerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'workerDetailViewModelProvider';
}

/// See also [WorkerDetailViewModel].
class WorkerDetailViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          WorkerDetailViewModel,
          WorkerDetailState
        > {
  /// See also [WorkerDetailViewModel].
  WorkerDetailViewModelProvider(String workerId)
    : this._internal(
        () => WorkerDetailViewModel()..workerId = workerId,
        from: workerDetailViewModelProvider,
        name: r'workerDetailViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$workerDetailViewModelHash,
        dependencies: WorkerDetailViewModelFamily._dependencies,
        allTransitiveDependencies:
            WorkerDetailViewModelFamily._allTransitiveDependencies,
        workerId: workerId,
      );

  WorkerDetailViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.workerId,
  }) : super.internal();

  final String workerId;

  @override
  WorkerDetailState runNotifierBuild(covariant WorkerDetailViewModel notifier) {
    return notifier.build(workerId);
  }

  @override
  Override overrideWith(WorkerDetailViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: WorkerDetailViewModelProvider._internal(
        () => create()..workerId = workerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        workerId: workerId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<WorkerDetailViewModel, WorkerDetailState>
  createElement() {
    return _WorkerDetailViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WorkerDetailViewModelProvider && other.workerId == workerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, workerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WorkerDetailViewModelRef
    on AutoDisposeNotifierProviderRef<WorkerDetailState> {
  /// The parameter `workerId` of this provider.
  String get workerId;
}

class _WorkerDetailViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          WorkerDetailViewModel,
          WorkerDetailState
        >
    with WorkerDetailViewModelRef {
  _WorkerDetailViewModelProviderElement(super.provider);

  @override
  String get workerId => (origin as WorkerDetailViewModelProvider).workerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
