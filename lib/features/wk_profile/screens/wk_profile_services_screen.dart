import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/theme/app_colors.dart';
import 'package:prm_project/core/theme/app_text_styles.dart';

import '../viewmodels/wk_profile_viewmodel.dart';

class WkProfileServicesScreen extends ConsumerStatefulWidget {
  const WkProfileServicesScreen({super.key});

  @override
  ConsumerState<WkProfileServicesScreen> createState() =>
      _WkProfileServicesScreenState();
}

class _WkProfileServicesScreenState
    extends ConsumerState<WkProfileServicesScreen> {
  final Set<String> _selected = <String>{};
  bool _initialized = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(wkProfileViewmodelProvider);
    final scheme = Theme.of(context).colorScheme;
    final divider = Theme.of(context).dividerColor;

    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      body: asyncData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          onRetry: () =>
              ref.read(wkProfileViewmodelProvider.notifier).refresh(),
        ),
        data: (data) {
          if (!_initialized) {
            _selected
              ..clear()
              ..addAll(data.selectedServices.map((e) => e.id));
            _initialized = true;
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.home_repair_service_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Select services you want to offer to customers.',
                              style: AppTextStyles.body2.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_selected.length}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...data.allServices.map(
                      (service) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selected.contains(service.id)
                                ? AppColors.primary.withValues(alpha: 0.45)
                                : divider,
                          ),
                        ),
                        child: CheckboxListTile(
                          value: _selected.contains(service.id),
                          title: Text(service.name),
                          secondary: const Icon(
                            Icons.build_circle_outlined,
                            color: AppColors.primary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selected.add(service.id);
                              } else {
                                _selected.remove(service.id);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              try {
                                await ref
                                    .read(wkProfileViewmodelProvider.notifier)
                                    .saveServices(
                                      _selected.toList(growable: false),
                                    );
                                if (!context.mounted) return;
                                Navigator.of(context).pop(true);
                              } catch (e) {
                                if (!context.mounted) return;
                                final raw = e.toString();
                                final message = raw.startsWith('Exception: ')
                                    ? raw.substring('Exception: '.length)
                                    : raw;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      message.trim().isEmpty
                                          ? 'Unable to save services.'
                                          : message,
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            },
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Services'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 42, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            'Unable to load services.',
            style: AppTextStyles.body2.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
