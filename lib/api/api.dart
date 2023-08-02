import 'package:alfred/alfred.dart';
import 'package:window_manager/window_manager.dart';

const kDefaultPort = 42169;

Future<void> api([int port = kDefaultPort]) async {
  final app = Alfred();

  app.get(
    '/ping',
    (req, res) {
      res.json({'pong': true});
    },
  );

  app.get(
    '/show',
    (req, res) async {
      if (await windowManager.isVisible() && !await windowManager.isFocused()) {
        await windowManager.focus();
      } else {
        await windowManager.show();
        await windowManager.focus();
      }
      res.json({'visible': await windowManager.isVisible()});
    },
  );

  await app.listen(port);
}
