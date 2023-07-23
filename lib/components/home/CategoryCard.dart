import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/collections/ad_ids.dart';
import 'package:wallywiz/hooks/useInterStitialAd.dart';
import 'package:wallywiz/models/category.dart';
import 'package:wallywiz/utils/clean-title.dart';

class CategoryCard extends HookConsumerWidget {
  final Category category;
  final Future<void> Function()? onTap;
  const CategoryCard({
    Key? key,
    required this.category,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cleanedTitle = useMemoized(
      () => cleanTitle(category.title),
      [category.title],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () async {
        await GoRouter.of(context).push(
          '/categories/${category.title}/wallpapers',
          extra: category,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            // 2x2 grid of thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: category.thumbnails.first,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              cleanedTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
