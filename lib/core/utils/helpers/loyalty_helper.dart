enum LoyaltyTier { bronze, silver, gold, platinum }

class LoyaltyHelper {
  static LoyaltyTier getTier(int points) {
    if (points >= 800) return LoyaltyTier.platinum;
    if (points >= 400) return LoyaltyTier.gold;
    if (points >= 200) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  static String tierName(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return "Bronze";
      case LoyaltyTier.silver:
        return "Silver";
      case LoyaltyTier.gold:
        return "Gold";
      case LoyaltyTier.platinum:
        return "Platinum";
    }
  }

  static int nextTierThreshold(int points) {
    if (points < 200) return 200;
    if (points < 400) return 400;
    if (points < 800) return 800;
    return 800; // Max tier
  }

  static int prevTierThreshold(int points) {
    if (points < 200) return 0;
    if (points < 400) return 200;
    if (points < 800) return 400;
    return 800;
  }

  static double progressToNextTier(int points) {
    final prev = prevTierThreshold(points);
    final next = nextTierThreshold(points);
    return ((points - prev) / (next - prev)).clamp(0.0, 1.0);
  }

  static int daysUntilExpiration(DateTime? expirationDate) {
    if (expirationDate == null) return -1;
    return expirationDate.difference(DateTime.now()).inDays;
  }
}
