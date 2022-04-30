import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final _loggerFactory = _WallyWizLogger();

_WallyWizLogger getLogger<T>(T owner) {
  _loggerFactory.owner = owner is String ? owner : owner.toString();
  return _loggerFactory;
}

class _WallyWizLogger extends Logger {
  String? owner;
  _WallyWizLogger([this.owner]) : super(filter: _WallyWizLogFilter());

  @override
  void log(Level level, message, [error, StackTrace? stackTrace]) {
    getApplicationDocumentsDirectory().then((dir) async {
      final file = File(path.join(dir.path, ".wallywiz_logs"));
      if (level == Level.error) {
        await file.writeAsString("[${DateTime.now()}]\n$message\n$stackTrace",
            mode: FileMode.writeOnlyAppend);
      }
    });
    super.log(level, "[$owner] $message", error, stackTrace);
  }
}

class _WallyWizLogFilter extends DevelopmentFilter {
  @override
  bool shouldLog(LogEvent event) {
    final env = Platform.environment;
    if ((env["DEBUG"] == "true" && event.level == Level.debug) ||
        (env["VERBOSE"] == "true" && event.level == Level.verbose) ||
        (env["ERROR"] == "true" && event.level == Level.error)) {
      return true;
    }
    return super.shouldLog(event);
  }
}
