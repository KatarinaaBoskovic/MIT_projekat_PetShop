import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petshop/view/shipping_address/models/address.dart'
    as my_address;

class StripeService {
  static String secretKey =
      "";

  // Funkcija za proračun iznosa na osnovu valute
  static int calculateAmount(double amount, String currency) {
    return (amount * 100).toInt();
  }

  static Future<void> initPayment({
    required my_address.Address address,
    required double amount,
    required String currency,
    required String userName,
  }) async {
    try {
      final paymentIntent = await _createPaymentIntent(
        calculateAmount(amount, currency).toString(),
        currency.toLowerCase(),
      );

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'PetShop',
          billingDetails: stripe.BillingDetails(
            name: userName,
            address: stripe.Address(
              city: address.city,
              country: 'RS',
              line1: address.fullAddress,
              line2: "",
              postalCode: address.zipCode,
              state: address.state,
            ),
          ),
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();
    } on stripe.StripeException catch (e) {
      if (e.error.localizedMessage?.toLowerCase().contains('cancelled') ??
          false) {
        debugPrint("Korisnik je zatvorio Stripe prozor.");
        throw 'Payment Cancelled';
      }
      throw 'Stripe Error: ${e.error.localizedMessage}';
    } catch (e) {
      debugPrint("General Error: $e");
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': amount,
        'currency': currency,
        'automatic_payment_methods[enabled]': 'true',
      },
    );

    var responseJson = jsonDecode(response.body);

    if (responseJson['error'] != null) {
      throw responseJson['error']['message'];
    }

    return responseJson;
  }
}
