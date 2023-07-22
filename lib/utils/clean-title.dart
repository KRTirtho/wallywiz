String cleanTitle(String title) {
  final cleaned = title
      .split(RegExp(r"[-_]"))
      .map(
        (e) => e.trim()[0].toUpperCase() + e.trim().substring(1),
      )
      .join(" ");
  return cleaned[0].toUpperCase() + cleaned.substring(1);
}
