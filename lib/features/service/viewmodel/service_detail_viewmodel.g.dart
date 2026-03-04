// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_detail_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceDetailViewmodelHash() =>
    r'4f873d64db07f199b6088c254edcaa8f8144368c';

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

abstract class _$ServiceDetailViewmodel
    extends BuildlessAutoDisposeAsyncNotifier<ServiceDetailData> {
  late final String serviceId;

  FutureOr<ServiceDetailData> build(String serviceId);
}

/// See also [ServiceDetailViewmodel].
@ProviderFor(ServiceDetailViewmodel)
const serviceDetailViewmodelProvider = ServiceDetailViewmodelFamily();

/// See also [ServiceDetailViewmodel].
class ServiceDetailViewmodelFamily
    extends Family<AsyncValue<ServiceDetailData>> {
  /// See also [ServiceDetailViewmodel].
  const ServiceDetailViewmodelFamily();

  /// See also [ServiceDetailViewmodel].
  ServiceDetailViewmodelProvider call(String serviceId) {
    return ServiceDetailViewmodelProvider(serviceId);
  }

  @override
  ServiceDetailViewmodelProvider getProviderOverride(
    covariant ServiceDetailViewmodelProvider provider,
  ) {
    return call(provider.serviceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'serviceDetailViewmodelProvider';
}

/// See also [ServiceDetailViewmodel].
class ServiceDetailViewmodelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ServiceDetailViewmodel,
          ServiceDetailData
        > {
  /// See also [ServiceDetailViewmodel].
  ServiceDetailViewmodelProvider(String serviceId)
    : this._internal(
        () => ServiceDetailViewmodel()..serviceId = serviceId,
        from: serviceDetailViewmodelProvider,
        name: r'serviceDetailViewmodelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$serviceDetailViewmodelHash,
        dependencies: ServiceDetailViewmodelFamily._dependencies,
        allTransitiveDependencies:
            ServiceDetailViewmodelFamily._allTransitiveDependencies,
        serviceId: serviceId,
      );

  ServiceDetailViewmodelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.serviceId,
  }) : super.internal();

  final String serviceId;

  @override
  FutureOr<ServiceDetailData> runNotifierBuild(
    covariant ServiceDetailViewmodel notifier,
  ) {
    return notifier.build(serviceId);
  }

  @override
  Override overrideWith(ServiceDetailViewmodel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ServiceDetailViewmodelProvider._internal(
        () => create()..serviceId = serviceId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        serviceId: serviceId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ServiceDetailViewmodel,
    ServiceDetailData
  >
  createElement() {
    return _ServiceDetailViewmodelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceDetailViewmodelProvider &&
        other.serviceId == serviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, serviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ServiceDetailViewmodelRef
    on AutoDisposeAsyncNotifierProviderRef<ServiceDetailData> {
  /// The parameter `serviceId` of this provider.
  String get serviceId;
}

class _ServiceDetailViewmodelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ServiceDetailViewmodel,
          ServiceDetailData
        >
    with ServiceDetailViewmodelRef {
  _ServiceDetailViewmodelProviderElement(super.provider);

  @override
  String get serviceId => (origin as ServiceDetailViewmodelProvider).serviceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
