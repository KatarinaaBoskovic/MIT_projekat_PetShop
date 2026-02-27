import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CurrencyController extends GetxController {
  final _box = GetStorage();

  // rates are based on EUR (1 EUR = rates[currency])
  final RxMap<String, double> eurRates = <String, double>{}.obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<DateTime?> lastUpdated = Rx<DateTime?>(null);

  static const _cacheRatesKey = 'currency_eur_rates';
  static const _cacheUpdatedKey = 'currency_rates_updated_at';
  static const _cacheSelectedKey = 'currency_selected';

  final RxString selectedCurrency = 'RSD'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedCurrency();
    _loadFromCache();
    refreshRatesIfNeeded();
  }

  void _loadSelectedCurrency() {
    final saved = _box.read(_cacheSelectedKey);
    if (saved is String && saved.trim().isNotEmpty) {
      selectedCurrency.value = saved.toUpperCase();
    }
  }

  void setCurrency(String currency) {
    selectedCurrency.value = currency.toUpperCase();
    _box.write(_cacheSelectedKey, selectedCurrency.value);
  }

  void _loadFromCache() {
    try {
      final raw = _box.read(_cacheRatesKey);
      final updatedRaw = _box.read(_cacheUpdatedKey);

      if (raw is Map) {
        eurRates.assignAll(
          raw.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
        );
      }

      if (updatedRaw is int) {
        lastUpdated.value = DateTime.fromMillisecondsSinceEpoch(updatedRaw);
      }
    } catch (_) {
      // ignore cache errors
    }
  }

  Future<void> refreshRatesIfNeeded() async {
    // refresh if  no rates, or if older than 12h
    final lu = lastUpdated.value;
    final stale = lu == null || DateTime.now().difference(lu).inHours >= 12;
    if (eurRates.isEmpty || stale) {
      await fetchLatestRates();
    }
  }

  Future<void> fetchLatestRates() async {
    isLoading.value = true;
    error.value = '';

    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/EUR');

      final res = await http.get(url);
      if (res.statusCode != 200) {
        throw Exception(
          'Failed to fetch currency rates (HTTP ${res.statusCode})',
        );
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (data['result'] != 'success') {
        throw Exception(
          'Failed to fetch currency rates (result=${data['result']})',
        );
      }

      final ratesJson = (data['rates'] as Map).cast<String, dynamic>();
      final parsed = <String, double>{};

      ratesJson.forEach((k, v) {
        if (v is num) parsed[k.toUpperCase()] = v.toDouble();
      });

      parsed['EUR'] = 1.0;

      eurRates.assignAll(parsed);
      lastUpdated.value = DateTime.now();

      // cache
      _box.write(_cacheRatesKey, parsed);
      _box.write(_cacheUpdatedKey, lastUpdated.value!.millisecondsSinceEpoch);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Convert a price stored in RSD to selected currency
  double convertFromRsd(double priceRsd, String targetCurrency) {
    final target = targetCurrency.toUpperCase();

    if (target == 'RSD') return priceRsd;

    final eurToRsd = eurRates['RSD'];
    if (eurToRsd == null || eurToRsd == 0) {
      // no RSD rate available -> fallback: return original
      return priceRsd;
    }

    // price in EUR
    final priceEur = priceRsd / eurToRsd;

    if (target == 'EUR') return priceEur;

    final eurToTarget = eurRates[target];
    if (eurToTarget == null) return priceRsd;

    return priceEur * eurToTarget;
  }

  String format(double amount, String currency) {
    final c = currency.toUpperCase();
    final symbol = switch (c) {
      'RSD' => 'RSD',
      'EUR' => '€',
      'USD' => r'$',
      _ => c,
    };

    // simple formatting
    if (c == 'RSD') {
      return '$symbol ${amount.toStringAsFixed(0)}';
    }
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}
