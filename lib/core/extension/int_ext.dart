extension IntExt on int {
  int roundToNearest(int nearest) {
    int rounded = (this + nearest / 2) ~/ nearest * nearest;
    return rounded % 60;
  }
}
