extension DurationSingleValues on Duration {
  String _twoDigits(int n) => n.toString().padLeft(2, "0");

  String get minute => _twoDigits(inMinutes.remainder(60));
  String get second => _twoDigits(inSeconds.remainder(60));
  String get hour => _twoDigits(inHours);
}
