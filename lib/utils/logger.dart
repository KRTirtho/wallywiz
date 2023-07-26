import 'package:logging/logging.dart';

void initLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final loggerName =
        record.loggerName.isNotEmpty ? '[${record.loggerName}]' : '';

    final dateTime = record.time.toString().split(".").first;

    print(
      '[${record.level.name}] $loggerName $dateTime: ${record.message}',
    );
  });
}
