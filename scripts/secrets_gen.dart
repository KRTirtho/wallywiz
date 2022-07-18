import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (Directory.current.path.endsWith('scripts')) {
    Directory.current = Directory.current.parent;
  }
  final Map secretsMap = jsonDecode(utf8.decode(base64Decode(args.first)));

  final String secrets = secretsMap.entries.fold("", (acc, entry) {
    acc = "$acc\nconst ${entry.key}=\"${entry.value}\";";
    return acc;
  });
  if (secrets == null) throw "No secrets found";
  File(Directory.current.path + "/lib/secrets.dart").writeAsStringSync(secrets);
}
