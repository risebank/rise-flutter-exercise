// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$whoAmIHash() => r'3a8781b7a0af807de1bd87c82ed8a000b60b167b';

/// See also [whoAmI].
@ProviderFor(whoAmI)
final whoAmIProvider = AutoDisposeFutureProvider<WhoAmIModel?>.internal(
  whoAmI,
  name: r'whoAmIProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$whoAmIHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WhoAmIRef = AutoDisposeFutureProviderRef<WhoAmIModel?>;
String _$authHash() => r'3b9b4bbf0581d31d066a21fafc36bf8a0884d967';

/// See also [Auth].
@ProviderFor(Auth)
final authProvider = AutoDisposeAsyncNotifierProvider<Auth, AuthUser?>.internal(
  Auth.new,
  name: r'authProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Auth = AutoDisposeAsyncNotifier<AuthUser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
