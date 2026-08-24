import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tracking_models.dart';

class BarcodeLookupException implements Exception {
  final String message;
  BarcodeLookupException(this.message);
  @override
  String toString() => message;
}

/// Looks up packaged food by barcode via Open Food Facts — no AI needed,
/// since the barcode maps directly to known nutrition data. Values
/// returned are per 100g/100ml; the confirm sheet scales them by serving.
class BarcodeFoodService {
  static const _base = 'https://world.openfoodfacts.org/api/v2/product';

  Future<FoodEntry> lookup(String barcode) async {
    final uri = Uri.parse('$_base/$barcode.json');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw BarcodeLookupException('Lookup failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 1) {
      throw BarcodeLookupException(
          'No product found for this barcode — try a clearer scan or add manually.');
    }

    final product = data['product'] as Map<String, dynamic>;
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    final name = (product['product_name'] as String?)?.trim();
    if (name == null || name.isEmpty) {
      throw BarcodeLookupException('Product has no name on record');
    }

    return FoodEntry(
      name: name,
      calories: _numOrZero(nutriments['energy-kcal_100g']).toDouble(),
      protein: _numOrZero(nutriments['proteins_100g']).toDouble(),
      carbs: _numOrZero(nutriments['carbohydrates_100g']).toDouble(),
      fat: _numOrZero(nutriments['fat_100g']).toDouble(),
      fiber: nutriments['fiber_100g'] != null
          ? _numOrZero(nutriments['fiber_100g']).toDouble()
          : null,
      mealType: 'snack',
      servingSize: 100,
    );
  }

  num _numOrZero(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }
}
