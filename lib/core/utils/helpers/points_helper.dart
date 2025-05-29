class PointsHelper {
  static const double pointToDollarRate = 0.1; // 1 point = $0.1

  /// Returns how many points are needed for a given amount in dollars.
  static int pointsNeeded(double amount) => (amount / pointToDollarRate).ceil();

  /// Returns how many dollars a given number of points is worth.
  static double dollarsFromPoints(int points) => points * pointToDollarRate;
}
