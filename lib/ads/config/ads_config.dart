import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdConfig {
  AdConfig._();

  static String get rewardedAdUnitId {
    final id = dotenv.env['ADMOB_REWARDED_AD_UNIT_ID'];
    if (id == null || id.isEmpty) {
      throw StateError(
        'ADMOB_REWARDED_AD_UNIT_ID is missing from .env — add it before '
        'requesting a rewarded ad.',
      );
    }
    return id;
  }
}
