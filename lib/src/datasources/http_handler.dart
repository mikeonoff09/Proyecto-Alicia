import 'dart:convert';
import 'dart:io';

import 'package:alicia/src/models/caracteristicas_data.dart';
import 'package:alicia/src/models/initial_data.dart';
import 'package:alicia/src/models/product.dart';
import 'package:alicia/src/models/product_details_model.dart';
import "package:http/http.dart" as http;

const _baseUrl = "https://mueblesextraordinarios.com/app2/public/v1/";

class HttpHandler {
  // HttpHandler _link;
  static final HttpHandler instance = HttpHandler._();
  HttpHandler._();

  Future<InitalData> getGeneralData() async {
    final response =
        await http.post(Uri.parse(_baseUrl + "inicio_aplicacion/get"));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      print('=============================================');
      // print(body.toString());
      final data = body["data"];
      return InitalData.fromJson(data);
    }
    return null;
  }

  Future<ProductDetailsMode> getProductData(int idProduct) async {
    final body = {"id_product": idProduct};
    print('====================');
    print(json.encode(body));
    final response = await http.post(
      Uri.parse(_baseUrl + "productos/get"),
      body: json.encode(body),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body["data"];

      return ProductDetailsMode.fromMap(data);
    }
    return null;
  }

  Future<List<ProductModel>> getProductList({
    String name = "",
    int fabricante = 0,
    int category = 0,
    String referencia = "",
    int supplier = 0,
    int stateWeb = 2,
    int paso = 0,
    String orden = "",
    int pagina = 0,
    String idproduct = "0",
  }) async {
    final body = {
      "name": name,
      "fabricante": fabricante,
      "category": category,
      "referencia": referencia,
      "supplier": supplier,
      "stateWeb": stateWeb,
      "paso": paso,
      "orden": orden,
      "pagina": pagina,
      "idproduct": idproduct,
    };
    final response = await http.post(
        Uri.parse(
          _baseUrl + "listado_productos/get",
        ),
        body: json.encode(body),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        });
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body["data"] as List;

      return List<ProductModel>.from(
        data.map((e) => ProductModel.fromMap(e)).toList(),
      );
    } else {
      print(response.body);
    }
    return null;
  }

  // Método para guardar el producto
  //  Changed to named parameters
  Future<String> saveProduct({
    String idproduct,
    String idsupplier,
    String idmanufacturer,
    String idcategorydefault,
    String ean13,
    String quantity,
    String minimalquantity,
    String price,
    String reference,
    String supplierreference,
    String paso,
    String preciocoste,
    String cachedefaultattribute,
    String description,
    String descriptionshort,
    String linkrewrite,
    String metadescription,
    String metakeywords,
    String metatitle,
    String name,
    String deliveryinstock,
    String deliveryoutstock,
    String stateWeb,
  }) async {
    if (idproduct == "") {
      idproduct = "0";
    }
    final body = {
      "stateWeb": stateWeb,
      "id_product": idproduct,
      "id_supplier": idsupplier,
      "id_manufacturer": idmanufacturer,
      "id_category_default": idcategorydefault,
      "ean13": ean13,
      "quantity": quantity,
      "minimal_quantity": minimalquantity,
      "price": price,
      "preciocoste": preciocoste,
      "reference": reference,
      "supplier_reference": supplierreference,
      "cache_default_attribute": cachedefaultattribute,
      "paso": paso,
      "description": description,
      "description_short": descriptionshort,
      "link_rewrite": linkrewrite,
      "meta_description": metadescription,
      "meta_keywords": metakeywords,
      "meta_title": metatitle,
      "name": name,
      "delivery_in_stock": deliveryinstock,
      "delivery_out_stock": deliveryoutstock,
    };
    final response = await http.post(
        Uri.parse(
          _baseUrl + "productos/add_update",
        ),
        body: json.encode(body),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        });
    if (response.statusCode == 200) {
      // final body = json.decode(response.body);
      // final data = body["data"] as List;

      return response.body.toString();
    } else {
      print(response.body);
    }
    return null;
  }

  // Para cargar los datos iniciales de la aplicación
  Future<CaracteriscasData> getCaracteristicas() async {
    final body = {};
    final response = await http.post(
      Uri.parse(
        _baseUrl + "ps_feature/get_todos",
      ),
      body: json.encode(body),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final data = body["data"];

      return CaracteriscasData.fromMap(data);
    } else {
      print(response.body);
    }
    return null;
  }
}
