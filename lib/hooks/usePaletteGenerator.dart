import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:palette_generator/palette_generator.dart';

PaletteGenerator usePaletteGenerator(String imageUrl) {
  final palette = useState<PaletteGenerator>(PaletteGenerator.fromColors(
    [PaletteColor(Colors.white, 0)],
  ));

  useEffect(() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      palette.value = await PaletteGenerator.fromImageProvider(
        CachedNetworkImageProvider(
          imageUrl,
          cacheKey: imageUrl,
          maxHeight: 50,
          maxWidth: 50,
        ),
      );
    });
    return null;
  }, [imageUrl]);

  return palette.value;
}
