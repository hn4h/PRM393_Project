import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prm_project/core/providers/settings_provider.dart';
import 'package:prm_project/features/settings/repositories/settings_repository.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum SettingsAction { none, clearCache, deleteAccount }

class SettingsState {
  final bool isLoading;
  final SettingsAction activeAction;
  final String? errorMessage;
  final bool cacheCleared;
  final bool accountDeleted;

  const SettingsState({
    this.isLoading = false,
    this.activeAction = SettingsAction.none,
    this.errorMessage,
    this.cacheCleared = false,
    this.accountDeleted = false,
  });

  SettingsState copyWith({
    bool? isLoading,
    SettingsAction? activeAction,
    String? errorMessage,
    bool clearError = false,
    bool? cacheCleared,
    bool? accountDeleted,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      activeAction: activeAction ?? this.activeAction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      cacheCleared: cacheCleared ?? this.cacheCleared,
      accountDeleted: accountDeleted ?? this.accountDeleted,
    );
  }
}

// ── ViewModel ──────────────────────────────────────────────────────────────────

class SettingsViewModel extends Notifier<SettingsState> {
  late SettingsRepository _repo;

  @override
  SettingsState build() {
    _repo = ref.read(settingsRepositoryProvider);
    return const SettingsState();
  }

  // ── Clear Cache ──────────────────────────────────────────────────────────

  Future<void> clearCache() async {
    state = state.copyWith(
      isLoading: true,
      activeAction: SettingsAction.clearCache,
      clearError: true,
    );

    try {
      await _repo.clearCache();
      state = state.copyWith(
        isLoading: false,
        activeAction: SettingsAction.none,
        cacheCleared: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        activeAction: SettingsAction.none,
        errorMessage: 'Failed to clear cache. Please try again.',
      );
    }
  }

  // ── Delete Account ────────────────────────────────────────────────────────

  Future<String?> deleteAccount() async {
    state = state.copyWith(
      isLoading: true,
      activeAction: SettingsAction.deleteAccount,
      clearError: true,
    );

    final error = await _repo.deleteAccount();

    if (error != null) {
      state = state.copyWith(
        isLoading: false,
        activeAction: SettingsAction.none,
        errorMessage: error,
      );
      return error;
    }

    // Sign out locally after successful deletion
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignore sign-out errors — user data is already deleted server-side
    }

    state = state.copyWith(
      isLoading: false,
      activeAction: SettingsAction.none,
      accountDeleted: true,
    );
    return null;
  }

  // ── Reset Flags ───────────────────────────────────────────────────────────

  void resetCacheCleared() {
    state = state.copyWith(cacheCleared: false);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ── Providers ──────────────────────────────────────────────────────────────────

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return SettingsRepository(Supabase.instance.client, prefs);
});

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(() {
  return SettingsViewModel();
});
