import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/features_models.dart';

class FeaturesProvider {
  String _baseUrl = "https://mueblesextraordinarios.com/app2/public/v1/";

  Future<Features> _getItem(Uri url) async {
    final resp = await http.post(url);
    final output = utf8.decode(latin1.encode(resp.body), allowMalformed: true);
    final decodedData = json.decode(output);
    final empresa = new Features.fromJson(decodedData);
    return empresa;
  }

  Future<Features> getAllFeatures() async {
    final url = Uri.http(_baseUrl, 'ps_feature_todas/get');
    print('====================================');
    print(url.toString());
    Features features = await _getItem(url);
    return features;
  }
}
