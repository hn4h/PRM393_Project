// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wk_chat_room_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wkChatRoomViewmodelHash() =>
    r'6da694a7a227a191fdcf3645b012a70119ccdbf7';

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

abstract class _$WkChatRoomViewmodel
    extends BuildlessAutoDisposeAsyncNotifier<WkChatRoomState> {
  late final String conversationId;

  FutureOr<WkChatRoomState> build(String conversationId);
}

/// See also [WkChatRoomViewmodel].
@ProviderFor(WkChatRoomViewmodel)
const wkChatRoomViewmodelProvider = WkChatRoomViewmodelFamily();

/// See also [WkChatRoomViewmodel].
class WkChatRoomViewmodelFamily extends Family<AsyncValue<WkChatRoomState>> {
  /// See also [WkChatRoomViewmodel].
  const WkChatRoomViewmodelFamily();

  /// See also [WkChatRoomViewmodel].
  WkChatRoomViewmodelProvider call(String conversationId) {
    return WkChatRoomViewmodelProvider(conversationId);
  }

  @override
  WkChatRoomViewmodelProvider getProviderOverride(
    covariant WkChatRoomViewmodelProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'wkChatRoomViewmodelProvider';
}

/// See also [WkChatRoomViewmodel].
class WkChatRoomViewmodelProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          WkChatRoomViewmodel,
          WkChatRoomState
        > {
  /// See also [WkChatRoomViewmodel].
  WkChatRoomViewmodelProvider(String conversationId)
    : this._internal(
        () => WkChatRoomViewmodel()..conversationId = conversationId,
        from: wkChatRoomViewmodelProvider,
        name: r'wkChatRoomViewmodelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$wkChatRoomViewmodelHash,
        dependencies: WkChatRoomViewmodelFamily._dependencies,
        allTransitiveDependencies:
            WkChatRoomViewmodelFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  WkChatRoomViewmodelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  FutureOr<WkChatRoomState> runNotifierBuild(
    covariant WkChatRoomViewmodel notifier,
  ) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(WkChatRoomViewmodel Function() create) {
    return ProviderOverride(
      origin: this,
      override: WkChatRoomViewmodelProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<WkChatRoomViewmodel, WkChatRoomState>
  createElement() {
    return _WkChatRoomViewmodelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WkChatRoomViewmodelProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WkChatRoomViewmodelRef
    on AutoDisposeAsyncNotifierProviderRef<WkChatRoomState> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _WkChatRoomViewmodelProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          WkChatRoomViewmodel,
          WkChatRoomState
        >
    with WkChatRoomViewmodelRef {
  _WkChatRoomViewmodelProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as WkChatRoomViewmodelProvider).conversationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
