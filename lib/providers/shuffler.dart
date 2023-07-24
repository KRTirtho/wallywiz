import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/main.dart';
import 'package:wallywiz/models/wallpaper.dart';
import 'package:wallywiz/services/periodic_task.dart';
import 'package:wallywiz/utils/persisted_state_notifier.dart';
import 'package:wallywiz/utils/platform.dart';
import 'package:workmanager/workmanager.dart';

enum ShufflerSourceType {
  wallpaper,
  category,
}

class ShufflerSource {
  final Duration interval;
  final Set<Wallpaper> sources;

  const ShufflerSource({
    required this.interval,
    required this.sources,
  });

  factory ShufflerSource.fromJson(Map<String, dynamic> json) {
    return ShufflerSource(
      interval: Duration(seconds: json["interval"]),
      sources: ((json["sources"] ?? []) as List<dynamic>)
          .map((json) => Wallpaper.fromJson(json))
          .toSet()
          .cast<Wallpaper>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "interval": interval.inSeconds,
      "sources": sources.map((s) => s.toJson()).toList(),
    };
  }

  ShufflerSource copyWith({
    Duration? interval,
    Set<Wallpaper>? sources,
  }) {
    return ShufflerSource(
      interval: interval ?? this.interval,
      sources: sources ?? this.sources,
    );
  }
}

class ShufflerProvider extends PersistedStateNotifier<ShufflerSource> {
  ShufflerProvider()
      : super(
          const ShufflerSource(
            interval: Duration.zero,
            sources: {},
          ),
          "shuffler",
        );

  Timer? _jobTimer;

  @override
  FutureOr<ShufflerSource> fromJson(Map<String, dynamic> json) {
    return ShufflerSource.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return state.toJson();
  }

  @override
  set state(ShufflerSource value) {
    if (state == value) return;
    super.state = value;
    if (state.interval < const Duration(minutes: 15) || state.sources.isEmpty) {
      return;
    }
    if (kIsMobile) {
      final data = jsonEncode(
        state.sources
            .map(
              (source) => {
                "id": source.id,
                "remoteId": source.remoteId,
                "url": source.url,
              },
            )
            .toList(),
      );
      Workmanager().cancelByUniqueName(WALLPAPER_TASK_UNIQUE_NAME).then((_) {
        Workmanager().registerPeriodicTask(
          WALLPAPER_TASK_UNIQUE_NAME,
          WALLPAPER_TASK_NAME,
          frequency: state.interval,
          constraints: Constraints(networkType: NetworkType.connected),
          inputData: {"data": data},
        );
      });
    } else {
      _jobTimer?.cancel();
      final data = state.sources
          .map(
            (source) => (
              remoteId: source.remoteId,
              id: source.id,
              url: source.url,
            ),
          )
          .toList();
      periodicTasksService.periodicTaskJob(data);
      _jobTimer = Timer.periodic(state.interval, (timer) {
        periodicTasksService.periodicTaskJob(data);
      });
    }
  }

  void setInterval(Duration interval) {
    state = state.copyWith(interval: interval);
  }

  void addShuffleSource(Wallpaper source) {
    state = state.copyWith(
      sources: {...state.sources, source},
    );
  }

  void removeShuffleSource(Wallpaper source) {
    state = state.copyWith(
      sources:
          state.sources.where((wallpaper) => source.id != wallpaper.id).toSet(),
    );
  }

  void setShuffleSource(ShufflerSource source) {
    state = source;
  }

  void clearShuffleSources() {
    state = state.copyWith(sources: {});
  }
}

final shufflerProvider =
    StateNotifierProvider<ShufflerProvider, ShufflerSource>((ref) {
  return ShufflerProvider();
});
