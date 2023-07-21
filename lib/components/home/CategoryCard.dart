import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallywiz/models/category.dart';

class CategoryCard extends HookConsumerWidget {
  final Category category;
  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final cleanTitle = useMemoized(
      () {
        final cleaned = category.title
            .split(RegExp(r"[-_]"))
            .map(
              (e) => e.trim()[0].toUpperCase() + e.trim().substring(1),
            )
            .join(" ");

        return cleaned[0].toUpperCase() + cleaned.substring(1);
      },
      [category.title],
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        GoRouter.of(context).go(
          '/category/${category.title}',
          extra: category,
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            // 2x2 grid of thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: category.thumbnails.first,
                fit: BoxFit.cover,
                height: 180,
                width: 150,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              cleanTitle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
