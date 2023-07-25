const kMinimumDuration = Duration(minutes: 15);
const kMaximumDuration = Duration(hours: 23);

bool isValidDuration(Duration duration) {
  return duration >= kMinimumDuration && duration <= kMaximumDuration;
}
