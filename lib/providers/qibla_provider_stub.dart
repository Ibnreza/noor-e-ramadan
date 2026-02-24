/// Flutter Qiblah Stub for Web
/// Mock implementation that provides empty streams on web platform

class FlutterQiblah {
  static Stream<QiblaDirection> qiblahStream() {
    return Stream.empty();
  }
}

class QiblaDirection {
  final double qibla;
  final double direction;
  final double offset;

  QiblaDirection({
    required this.qibla,
    required this.direction,
    required this.offset,
  });
}
