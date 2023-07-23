import 'dart:io';

import 'package:flutter/foundation.dart';

final kIsMacos = kIsWeb ? false : Platform.isMacOS;
final kIsWindows = kIsWeb ? false : Platform.isWindows;
final kIsLinux = kIsWeb ? false : Platform.isLinux;
final kIsAndroid = kIsWeb ? false : Platform.isAndroid;
final kIsIos = kIsWeb ? false : Platform.isIOS;

final kIsDesktop = kIsMacos || kIsWindows || kIsLinux;
final kIsMobile = kIsAndroid || kIsIos;

final kAdPlatform = kIsAndroid || kIsIos;
