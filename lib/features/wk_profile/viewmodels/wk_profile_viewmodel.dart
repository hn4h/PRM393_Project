import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/wk_profile_models.dart';
import '../repository/wk_profile_repository.dart';

part 'wk_profile_viewmodel.g.dart';

@riverpod
class WkProfileViewmodel extends _$WkProfileViewmodel {
  @override
  Future<WkProfileData> build() {
    return ref.read(wkProfileRepositoryProvider).loadProfileData();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(wkProfileRepositoryProvider).loadProfileData(),
    );
  }

  Future<void> saveBio(String bio) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref.read(wkProfileRepositoryProvider).updateBio(current.userId, bio);
    state = AsyncData(current.copyWith(bio: bio));
  }

  Future<void> saveServices(List<String> serviceIds) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(wkProfileRepositoryProvider)
        .updateWorkerServices(current.userId, serviceIds);

    final selected = current.allServices
        .where((s) => serviceIds.contains(s.id))
        .toList(growable: false);

    state = AsyncData(current.copyWith(selectedServices: selected));
  }

  Future<void> saveNotificationPrefs({
    required bool sound,
    required bool vibration,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(wkProfileRepositoryProvider)
        .saveNotificationSettings(
          current.userId,
          sound: sound,
          vibration: vibration,
        );

    state = AsyncData(
      current.copyWith(
        notificationSound: sound,
        notificationVibration: vibration,
      ),
    );
  }

  Future<void> saveWeeklyAvailability(List<WkDayAvailability> weekly) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(wkProfileRepositoryProvider)
        .saveAvailability(current.userId, weekly);
    state = AsyncData(current.copyWith(weeklyAvailability: weekly));
  }

  Future<void> saveTimeOffDates(List<DateTime> dates) async {
    final current = state.valueOrNull;
    if (current == null) return;

    await ref
        .read(wkProfileRepositoryProvider)
        .saveTimeOffDates(current.userId, dates);
    state = AsyncData(current.copyWith(timeOffDates: dates));
  }
}
