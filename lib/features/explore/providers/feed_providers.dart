import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/models/submission_models.dart';
import '../../../shared/services/submission_service.dart';

/// Logger provider for explore feature
final _loggerProvider = Provider<Logger>((ref) => Logger());

/// Submission service provider
final submissionServiceProvider = Provider<SubmissionService>((ref) {
  final supabase = Supabase.instance.client;
  final logger = ref.watch(_loggerProvider);
  return SubmissionService(supabase: supabase, logger: logger);
});

/// Feed state for managing submissions list
class FeedState {
  final List<Submission> submissions;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final bool hasMore;

  const FeedState({
    this.submissions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.hasMore = true,
  });

  FeedState copyWith({
    List<Submission>? submissions,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool? hasMore,
  }) {
    return FeedState(
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Feed notifier for managing feed state
class FeedNotifier extends StateNotifier<FeedState> {
  final SubmissionService _submissionService;
  final Logger _logger;
  static const _pageSize = 20;

  FeedNotifier(this._submissionService, this._logger) : super(const FeedState()) {
    loadSubmissions();
  }

  /// Load initial submissions
  Future<void> loadSubmissions() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      _logger.d('Loading feed submissions...');
      final submissions = await _submissionService.getSubmissions(
        limit: _pageSize,
        offset: 0,
      );

      _logger.d('Loaded ${submissions.length} submissions');
      state = state.copyWith(
        submissions: submissions,
        isLoading: false,
        hasMore: submissions.length >= _pageSize,
      );
    } catch (e) {
      _logger.e('Failed to load submissions: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load feed: $e',
      );
    }
  }

  /// Refresh submissions (pull-to-refresh)
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      _logger.d('Refreshing feed...');
      final submissions = await _submissionService.getSubmissions(
        limit: _pageSize,
        offset: 0,
      );

      _logger.d('Refreshed with ${submissions.length} submissions');
      state = state.copyWith(
        submissions: submissions,
        isRefreshing: false,
        hasMore: submissions.length >= _pageSize,
      );
    } catch (e) {
      _logger.e('Failed to refresh feed: $e');
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to refresh: $e',
      );
    }
  }

  /// Load more submissions (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final offset = state.submissions.length;
      _logger.d('Loading more submissions from offset $offset...');

      final submissions = await _submissionService.getSubmissions(
        limit: _pageSize,
        offset: offset,
      );

      _logger.d('Loaded ${submissions.length} more submissions');
      state = state.copyWith(
        submissions: [...state.submissions, ...submissions],
        isLoading: false,
        hasMore: submissions.length >= _pageSize,
      );
    } catch (e) {
      _logger.e('Failed to load more: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more: $e',
      );
    }
  }
}

/// Feed provider
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final submissionService = ref.watch(submissionServiceProvider);
  final logger = ref.watch(_loggerProvider);
  return FeedNotifier(submissionService, logger);
});
