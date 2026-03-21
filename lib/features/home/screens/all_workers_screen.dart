import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_project/core/models/worker.dart';
import 'package:prm_project/features/worker/repository/worker_repository.dart';

import '../widgets/worker_card.dart';

class AllWorkersScreen extends ConsumerStatefulWidget {
  const AllWorkersScreen({super.key});

  @override
  ConsumerState<AllWorkersScreen> createState() => _AllWorkersScreenState();
}

class _AllWorkersScreenState extends ConsumerState<AllWorkersScreen> {
  static const _pageSize = 10;

  final _scrollController = ScrollController();
  final _workers = <Worker>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(workerRepositoryProvider);
      final workers = await repo.getPage(limit: _pageSize, offset: 0);

      if (!mounted) return;
      setState(() {
        _workers
          ..clear()
          ..addAll(workers);
        _isLoading = false;
        _hasMore = workers.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repo = ref.read(workerRepositoryProvider);
      final nextWorkers = await repo.getPage(
        limit: _pageSize,
        offset: _workers.length,
      );

      if (!mounted) return;
      setState(() {
        _workers.addAll(nextWorkers);
        _isLoadingMore = false;
        _hasMore = nextWorkers.length == _pageSize;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _error = e.toString();
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final workers = _workers;

    return Scaffold(
      appBar: AppBar(title: const Text('All Workers')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && workers.isEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: workers.length +
                      (_isLoadingMore ? 1 : 0) +
                      (!_hasMore && workers.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= workers.length) {
                      if (_isLoadingMore && index == workers.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Center(
                          child: Text(
                            'No more workers',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: SizedBox(
                        height: 280,
                        child: WorkerCard(worker: workers[index]),
                      ),
                    );
                  },
                ),
    );
  }
}
