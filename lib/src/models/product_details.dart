import 'dart:convert';

import 'package:mysql1/mysql1.dart';

class ProductDetails {
  int idProduct;
  List<Map<String, dynamic>> product;

  List<Map<String, dynamic>> features;
  List<Map<String, dynamic>> featuresValue;
  List<Map<String, dynamic>> featuresSuper;

  List<Map<String, dynamic>> featuresProduct;

  List<Map<String, dynamic>> categories;

  List<Map<String, dynamic>> categoriesProduct;

  List<Map<String, dynamic>> imagenes;

  List<Map<String, dynamic>> product_attachment;
  List<Map<String, dynamic>> attribute_combinaciones;
  List<Map<String, dynamic>> product_attribute;
  List<Map<String, dynamic>> product_attribute_image;

  List<Map<String, dynamic>> manufactures;
  List<Map<String, dynamic>> suppliers;

  List<Map<String, dynamic>> categoriesWithName;

  ProductDetails(
      {this.idProduct,
      this.product,
      this.features,
      this.featuresValue,
      this.featuresSuper,
      this.featuresProduct,
      this.categories,
      this.categoriesProduct,
      this.imagenes,
      this.product_attachment,
      this.attribute_combinaciones,
      this.product_attribute,
      this.product_attribute_image});

  List<Map<String, dynamic>> getFeatures() {
    return features;
  }

  int lastFeatureId() {
    return _lastOfList(
      list: features,
      campo: "id_feature",
    );
  }

  int lastFeatureValueId() {
    return _lastOfList(
      list: featuresValue,
      campo: "id_feature_value",
    );
  }

  int _lastOfList({
    List<Map<String, dynamic>> list,
    String campo,
  }) {
    var last = 0;
    list.forEach((element) {
      if (element[campo] > last) {
        last = element[campo];
      }
    });
    return last;
  }

  Map<String, dynamic> productHasFeature({int idProduct, int idFeature}) {
    for (var item in featuresProduct) {
      if (item["id_product"] == idProduct && item["id_feature"] == idFeature) {
        return item;
      }
    }
    return null;
  }

  Map<String, dynamic> getFeatureValue(int idFeature, int idProduct) {
    final result = featuresValue
        .where((element) =>
            element["id_feature"] == idFeature &&
            productHaveValue(idProduct, element["id_feature_value"]) != null)
        .toList();
    if (result.isEmpty) return null;
    return result.first;
  }

  List<Map<String, dynamic>> getFeatureValues(int idFeature, int idProduct) {
    final result = featuresValue
        .where((element) =>
            element["id_feature"] == idFeature &&
            productHaveValue(idProduct, element["id_feature_value"]) != null)
        .toList();

    return result;
  }

  Map<String, dynamic> productHaveValue(int idProduct, int id_feature_value) {
    final result = featuresProduct
        .where((element) =>
            element["id_feature_value"] == id_feature_value &&
            element["id_product"] == idProduct)
        .toList();
    if (result.isEmpty) return null;
    return result.first;
  }

  /* List<Map<String, dynamic>> getFeaturesByIdProduct(int idProduct) {
    final filtered = features.where((element) {
      final result = _productHasFeature(
          idFeature: element["id_feature"], idProduct: idProduct);
      return result != null;
    }).toList();

    return filtered;
  } */

  int get lastFeature {
    var nList = List<Map<String, dynamic>>.from(
        json.decode(json.encode(features)) as List);

    nList.sort((a, b) {
      return (a["id_feature"] as int).compareTo(b["id_feature"]);
    });
    return nList.last["id_feature"];
  }

  bool updateValues(List<Feature> values) {
    //  featuresInserts = [];
    for (var value in values) {
      final fea = _feature(value.id_feature);

      if (fea == null) {
        //Si se esta agregando, se agrega un nuevo ID
        final lastId = lastFeature;
        value.id_feature = lastId + 1;
        // featuresInserts.add(value.id_feature);
      }

      final valueMap = featureValue(value.id_feature);
    }
  }

  void cleanList() {
    for (var item in product) {
      item.remove("date_upd");
      item.remove("supplier_reference ");
      item.remove("date_add");
      item.remove("borrar");

      item["date_upd"] = DateTime.now().toIso8601String();
      item["date_add"] = DateTime.now().toIso8601String();
    }
  }

  String get updateSQL {
    cleanList();
    String result = "";

    for (var item in product) {
      result += generateInsertSql(table: "ps_product", map: item);
    }

    return result;
  }

  static String generateInsertSql({String table, Map<String, dynamic> map}) {
    final keys = json
        .encode(map.keys.toList())
        .replaceAll("\"", "`")
        .replaceAll("[", "(")
        .replaceAll("]", ")");
    final values = json
        .encode(map.values.map((e) {
          if (e is DateTime) {
            return e.toIso8601String();
          } else if (e is Blob) {
            return e.toString().replaceAll("'", "\'");
          }
          return e;
        }).toList())
        .replaceAll("\"", "'")
        .replaceAll("[", "(")
        .replaceAll("]", ")");

    var query = "REPLACE INTO `$table`$keys values$values ;";
    print(query);
    return query;
  }

  Map<String, dynamic> _feature(
    int idFeature,
  ) {
    final result = features.where((element) {
      return element["id_feature"] == idFeature;
    }).toList();
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Map<String, dynamic> featureValue(
    int idFeature,
  ) {
    final result = featuresValue.where((element) {
      return element["id_feature"] == idFeature;
    }).toList();
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Map<String, dynamic> _featureProductValue(
      int idFeature, int id_feature_value) {
    final result = featuresProduct.where((element) {
      return element["id_feature"] == idFeature &&
          element["id_feature_value"] == id_feature_value;
    }).toList();
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Map<String, dynamic> getCategory(int idCategory) {
    final result = categories.where((element) {
      return element["id_category"] == idCategory;
    }).toList();
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Map<String, dynamic> getCategoryProduct({int idCategory, int idProduct}) {
    final result = categoriesProduct.where((element) {
      return element["id_category"] == idCategory &&
          element["id_product"] == idProduct;
    }).toList();
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }
}

class Product {
  // ps_product
  int get id_product => values["id_product"];
  set id_product(value) => {values["id_product"] = value};
  int get id_supplier => values["id_supplier"];
  set id_supplier(value) => values["id_supplier"] = value;
  int get id_manufacturer => values["id_manufacturer"];
  set id_manufacturer(value) => values["id_manufacturer"] = value;
  int get id_category_default => values["id_category_default"];
  set id_category_default(value) => values["id_category_default"] = value;
  String get ean13 => values["ean13"];
  set ean13(value) => values["ean13"] = value;
  int get quantity => values["quantity"];
  set quantity(value) => values["quantity"] = value;
  int get minimal_quantity => values["minimal_quantity"];
  set minimal_quantity(value) => values["minimal_quantity"] = value;
  double get price => values["price"];
  set price(value) => values["price"] = value;
  double get wholesale_price => values["wholesale_price"];
  set wholesale_price(value) => values["wholesale_price"] = value;
  String get reference => values["reference"];
  set reference(value) => values["reference"] = value;
  String get supplier_reference => values["supplier_reference"];
  set supplier_reference(value) => values["supplier_reference"] = value;
  int get cache_default_attribute => values["cache_default_attribute"];
  set cache_default_attribute(value) =>
      values["cache_default_attribute"] = value;
  String get date_add => values["date_add"];
  set date_add(value) => values["date_add"] = value;
  String get date_upd => values["date_upd"];
  set date_upd(value) => values["date_upd"] = value;
  bool get stateWeb => values["stateWeb"];
  set stateWeb(value) => values["stateWeb"] = value;
  String get paso => values["paso"];
  set paso(value) => values["paso"] = value;

  String get description => values["date_add"];
  set description(value) => values["description"] = value;
  String get description_short => values["description_short"];
  set description_short(value) => values["description_short"] = value;
  String get link_rewrite => values["link_rewrite"];
  set link_rewrite(value) => values["link_rewrite"] = value;
  String get meta_description => values["meta_description"];
  set meta_description(value) => values["meta_description"] = value;
  String get meta_keywords => values["meta_keywords"];
  set meta_keywords(value) => values["meta_keywords"] = value;
  String get meta_title => values["meta_title"];
  set meta_title(value) => values["meta_title"] = value;
  String get name => values["name"];
  set name(value) => values["name"] = value;
  String get delivery_in_stock => values["delivery_in_stock"];
  set delivery_in_stock(value) => values["delivery_in_stock"] = value;
  String get delivery_out_stock => values["delivery_out_stock"];
  set delivery_out_stock(value) => values["delivery_out_stock"] = value;

  Map<String, dynamic> values = {
    "id_product": 0,
    "id_supplier": 0,
    "id_manufacturer": 0,
    "id_category_default": 0,
    "ean13": "",
    "quantity": 0,
    "minimal_quantity": 0,
    "price": 0,
    "wholesale_price": 0,
    "reference": "",
    "supplier_reference": "",
    "date_add": 0,
    "date_upd": 0,
    "stateWeb": 0,
    "paso": 0,
    "description": "",
    "description_short": "",
    "link_rewrite": "",
    "meta_description": "",
    "meta_keywords": "",
    "meta_title": "",
    "name": "",
    "delivery_in_stock": "",
    "delivery_out_stock": "",
  };
  Product();
}

class Feature_Super {
  // Catacteristica
  int get id_feature_super => values["id_feature_super"];
  set id_feature_super(value) => {values["id_feature_super"] = value};
  int get position => values["position"];
  set position(value) => values["position"] = value;
  String get name => values["name"];
  set name(value) => values["name"] = value;
  bool get nuevo => values["nuevo"];
  set nuevo(value) => values["nuevo"] = value;
  bool get borrar => values["borrar"];
  set borrar(value) => values["borrar"] = value;

  Map<String, dynamic> values = {
    "id_feature": 0,
    "position": 0,
    "name": "",
    "borrar": 0,
    "nuevo": false,
  };
  Feature_Super();
}

class Feature {
  // Catacteristica
  int get id_feature => values["id_feature"];
  set id_feature(value) => {values["id_feature"] = value};
  int get id_feature_super => values["id_feature_super"];
  set id_feature_super(value) => {values["id_feature_super"] = value};
  int get position => values["position"];
  set position(value) => values["position"] = value;
  String get name => values["name"];
  set name(value) => values["name"] = value;
  bool get nuevo => values["nuevo"];
  set nuevo(value) => values["nuevo"] = value;
  bool get borrar => values["borrar"];
  set borrar(value) => values["borrar"] = value;
  Map<String, dynamic> values = {
    "id_feature": 0,
    "id_feature_super": 0,
    "position": 0,
    "name": "",
    "borrar": 0,
    "nuevo": false,
  };
  Feature();
}

class Feature_Value {
  //Valores
  int get id_feature => values["id_feature"];
  set id_feature(value) => values["id_feature"] = value;
  int get id_feature_value => values["id_feature_value"];
  set id_feature_value(value) => values["id_feature_value"] = value;
  String get value => values["name"];
  set value(val) => values["name"] = val;
  int get position => values["position"];
  set position(value) => values["position"] = value;
  bool get nuevo => values["nuevo"];
  set nuevo(value) => values["nuevo"] = value;
  bool get borrar => values["borrar"];
  set borrar(value) => values["borrar"] = value;

  Map<String, dynamic> values = {
    "id_feature": 0,
    "id_feature_value": 0,
    "name": "",
    "position": 0,
    "borrar": 0,
    "nuevo": false,
  };

  Feature_Value();
}

class Cattegory {
  //Valores
  int get id_category => values["id_category"];
  set id_category(value) => values["id_category"] = value;
  int get id_parent => values["id_parent"];
  set id_parent(value) => values["id_parent"] = value;
  String get position => values["position"];
  set position(value) => values["position"] = value;
  String get is_root_category => values["is_root_category"];
  set is_root_category(value) => values["is_root_category"] = value;
  String get name => values["name"];
  set name(value) => values["name"] = value;
  String get level_depth => values["level_depth"];
  set level_depth(value) => values["level_depth"] = value;
  String get nleft => values["nleft"];
  set nleft(value) => values["nleft"] = value;
  String get nright => values["nright"];
  set nright(value) => values["nright"] = value;

  Map<String, dynamic> values = {
    "id_category": 0,
    "id_parent": 0,
    "level_depth": 0,
    "nleft": 0,
    "nright": 0,
    "position": 0,
    "is_root_category": false,
    "name": "",
  };

  Cattegory();
}

class Category_product {
  //Valores
  int get id_category => values["id_category"];
  set id_category(value) => values["id_category"] = value;
  int get position => values["position"];
  set position(value) => values["position"] = value;
  bool get borrar => values["borrar"];
  set borrar(value) => values["borrar"] = value;
  bool get nuevo => values["nuevo"];
  set nuevo(value) => values["nuevo"] = value;
  Map<String, dynamic> values = {
    "id_category": 0,
    "position": 0,
    "borrar": 0,
    "nuevo": false,
  };

  Category_product();
}

class ProductImage {
  //Ps_image   imagenes del producto
  int get id_image => values["id_image"];
  set id_image(value) => values["id_image"] = value;
  int get position => values["position"];
  set position(value) => values["position"] = value;
  int get cover => values["cover"];
  set cover(value) => values["cover"] = value;
  int get legend => values["legend"];
  set legend(value) => values["legend"] = value;
  int get fechaanadida => values["fechaanadida"];
  set fechaanadida(value) => values["fechaanadida"] = value;
  int get resolucionorigen => values["resolucionorigen"];
  set resolucionorigen(value) => values["resolucionorigen"] = value;
  int get descartada => values["descartada"];
  set descartada(value) => values["descartada"] = value;
  int get fechamodificacion => values["fechamodificacion"];
  set fechamodificacion(value) => values["fechamodificacion"] = value;
  int get resolucionrecorte => values["resolucionrecorte"];
  set resolucionrecorte(value) => values["resolucionrecorte"] = value;
  int get padding => values["padding"];
  set padding(value) => values["padding"] = value;
  Map<String, dynamic> values = {
    "id_image": 0,
    "position": 0,
    "cover": false,
    "legend": "",
    "fechaanadida": "2021-07-01",
    "resolucionorigen": "0x0",
    "descartada": 0,
    "fechamodificacion": "2021-07-01",
    "resolucionrecorte": "0x0",
    "padding": 0
  };

  ProductImage();
}

class Attachment {
  //archivos adjuntos para un producto
  int get id_attachment => values["id_attachment"];
  set id_attachment(value) => values["id_attachment"] = value;

  Map<String, dynamic> values = {
    "id_attachment": 0,
  };

  Attachment();
}
