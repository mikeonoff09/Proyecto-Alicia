import 'dart:convert';
import 'dart:io';

import 'package:alicia/src/models/product_details.dart';
import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';

@deprecated
class MysqlSeverDataSource {
  MySqlConnection _link;
  static final MysqlSeverDataSource instance = MysqlSeverDataSource._();
  MysqlSeverDataSource._();

  Future<MySqlConnection> _getLink() async {
    if (_link == null) {
      final result = await Process.run("cmd", ["/k", "hostname"]);
      String ip =
          "62.122.34.230"; //"127.0.0.1"; //"192.168.1.9"; //"62.122.34.230";
      int port = 33066;
      if (result.stdout.toString().contains("DESKTOP-P7Q1IQ8")) {
        ip = '62.122.34.230';
        //  port = 3306;
      }

      var settings = new ConnectionSettings(
        host: ip,
        port: port,
        user: 'muebleu569',
        password: 'NSg7mjFStnpH',
        db: 'muebleu569',
      );
      var conn = await MySqlConnection.connect(settings);
      _link = conn;
    }
    return null;
  }

  Future<int> getLastImageId() async {
    final link = await _getLink();
    String query =
        "SELECT id_image from ps_image ORDER BY id_image desc limit 1";
    final result = await link.query(query);
    final list = _getListFromIterator(result.iterator).toSet().toList();
    return list[0]["id_image"];
  }

  Future<int> getLastProductId() async {
    final link = await _getLink();
    String query =
        "SELECT id_product from ps_product ORDER BY id_product desc limit 1";
    final result = await link.query(query);
    final list = _getListFromIterator(result.iterator).toSet().toList();
    return list[0]["id_product"];
  }

  Future<bool> descartadarImage({int idImage, int descartada}) async {
    final link = await _getLink();
    String query =
        "UPDATE ps_image set descartada = $descartada where id_image = $idImage";
    await link.query(query);
    return true;
  }

  List<Map<String, dynamic>> _getListFromIterator(
      Iterator<ResultRow> original) {
    List<Map<String, dynamic>> result = [];
    while (original.moveNext()) {
      final current = original.current;
      final keysName = current.fields.keys.toList();
      final keys = current.asMap();
      Map<String, dynamic> map = {};
      keys.forEach((key, value) {
        String nName = key.toString();
        try {
          if (keysName.length > key) {
            nName = keysName[key];
            map[nName] = value;
            result.add(map);
          }
        } catch (e) {}
      });
    }
    return result;
  }

  String _removeDoubleSpaces(String str) {
    str = str.trim();
    do {
      str = str.replaceAll("  ", " ");
    } while (str.contains("  "));
    return str;
  }

  Future<List<Map<String, dynamic>>> getListadoPrincipal(
      {int idMin = 0,
      int idMax = 99999999999,
      String nombre = "%",
      int category = 0,
      String referencia = "%",
      int proveedor = 0,
      int supplier = 0,
      int state = 0,
      int interno = 0,
      DateTime startTime,
      DateTime endTime}) async {
    //final dateFormat = DateFormat.yMd('en_US');
    final start = (startTime ?? DateTime(2020, 01, 01)).toIso8601String();
    final end = (endTime ?? DateTime.now()).toIso8601String();
    final link = await _getLink();
    String query;
    //usar id_lang
    query = """
        SELECT ps_product.id_product as ID, '' as Portada, '' as Ambiente,ps_product_lang.name as Nombre_Producto, CONCAT(ps_product.reference,' || ',ps_product.supplier_reference) as Referencias,ps_category_lang.name as Categoría,
        ps_manufacturer.name as Fabricante,ps_supplier.name as Proveedor, round(price*(1+21/100),2) AS PVP,ps_product.active as Activo,
        ps_product.paso as Estado
        FROM ps_product INNER JOIN ps_product_lang ON ps_product.id_product = ps_product_lang.id_product 
        INNER JOIN ps_manufacturer ON ps_product.id_manufacturer = ps_manufacturer.id_manufacturer 
        INNER JOIN ps_category_lang ON ps_product.id_category_default = ps_category_lang.id_category 
        INNER JOIN ps_supplier on ps_product.id_supplier = ps_supplier.id_supplier 
        WHERE ps_product_lang.id_lang = 1 AND ps_category_lang.id_lang = 1
        and ps_product.date_upd between '$start' and '$end'  """;

    //ps_product.id_product
    String where = "";
    if (state != 0) {
      where = where + " and ps_product.state = '$state' ";
    }
    if (category != 0) {
      where = where + " and ps_product.id_category_default = '$category' ";
    }
    if (nombre != "%") {
      if (nombre != "%") {
        nombre = _removeDoubleSpaces(nombre);
        List<String> nombres = nombre.split(" ");
        int _i;
        for (_i = 0; _i < nombres.length; _i++)
          where =
              where + " and ps_product_lang.name like '%" + nombres[_i] + "%' ";
      }
    }
    if (supplier != 0) {
      where = where + " and ps_product.id_manufacturer= '$supplier' ";
    }
    if (supplier != 0) {
      where = where + " and ps_product.id_supplier= '$supplier' ";
    }
    if (referencia != "%") {
      where = where +
          " and (ps_product.reference like '%$referencia%' or ps_product.supplier_reference like '%$referencia%')";
    }

    query =
        query + " order by ps_product.id_product desc" + where + " limit 0,50";

    final result = await link.query(query);
    print(result.length);

    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator);

      String queryContar = "";
      if (result.length == 50) {
        queryContar =
            "SELECT count(*) FROM ps_product INNER JOIN ps_product_lang ON ps_product.id_product = ps_product_lang.id_product WHERE ps_product_lang.id_lang = 1 " +
                where;
        final resultContador = await link.query(queryContar);
        print(resultContador.length);
        //DEvolver_Numero_de_registros_es: result.length;
      } else {
        //DEvolver_Numero_de_registros_es: result.length;
      }
      //Creo un listado de Ids
      List list = result2.map((e) => e["ID"]).toSet().toList();

      //Convierto el listado de ID en json, luego cambio los [] por ()
      //hay que quitar duplicados de esta id, aparecen muchisimos
      final inList =
          json.encode(list).replaceAll("[", "(").replaceAll("]", ")");
      //String query2 ="SELECT ps_image.id_image,ps_image.id_product,ps_image.position,ps_image.cover,ps_image_lang.legend FROM ps_image inner JOIN ps_image_lang on ps_image.id_image=ps_image_lang.id_image where ps_image.id_product in $inList ps_image_lang.id_lang =1 order by ps_image.cover desc,ps_image.position";
      String query2 =
          "select ps_image.id_image,ps_image.id_product,ps_image.position,ps_image.cover,ps_image_lang.legend,ps_image.fechaanadida,ps_image.resolucionorigen,ps_image.descartada,ps_image.fechamodificacion,ps_image.resolucionrecorte,ps_image.padding FROM ps_image inner JOIN ps_image_lang on ps_image.id_image=ps_image_lang.id_image where ps_image.id_product in $inList and ps_image_lang.id_lang =1 order by ps_image.cover desc,ps_image.position";
      final imagesResult = await link.query(query2);

      final imageslist =
          _getListFromIterator(imagesResult.iterator).toSet().toList();

      for (var i = 0; i < result2.length; i++) {
        final item = result2[i];
        final id = item["ID"];
        item["Imagenes"] =
            imageslist.where((element) => element["id_product"] == id).toList();
        result2[i] = item;
      }
      return result2.toSet().toList();
    } else {
      //DEvolver_Numero_de_registros_es: result.length = 0;
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final link = await _getLink();

    //usar id_lang
    final query = "SELECT ps_category.* FROM ps_category";
    final result = await link.query(query);
    print(result.length);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategoriesWithName() async {
    final link = await _getLink();

    //usar id_lang
    final query =
        "SELECT ps_category.id_category,id_parent,level_depth,nleft,nright,position,is_root_category ,ps_category_lang.name FROM ps_category_lang inner join ps_category on ps_category.id_category=ps_category_lang.id_category where ps_category_lang.id_lang = 1 and ps_category.active = true order by ps_category_lang.name";
    final result = await link.query(query);
    print(result.length);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategoriesLang() async {
    final link = await _getLink();

    //usar id_lang
    final query = "SELECT ps_category_lang.* FROM ps_category_lang";
    final result = await link.query(query);
    print(result.length);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategoriesProduct() async {
    final link = await _getLink();

    //usar id_lang
    final query = "SELECT ps_category_product.* FROM ps_category_product";
    final result = await link.query(query);
    print(result.length);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getManufacturers() async {
    final link = await _getLink();
    final query =
        "SELECT ps_manufacturer.id_manufacturer, ps_manufacturer.name FROM ps_manufacturer order by ps_manufacturer.name";
    final result = await link.query(query);
    print(result);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSuppliers() async {
    final link = await _getLink();
    final query =
        "SELECT ps_supplier.id_supplier, ps_supplier.name FROM ps_supplier order by ps_supplier.name";
    final result = await link.query(query);
    print(result);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryProduct(int idProduct) async {
    final link = await _getLink();
    final query =
        "SELECT ps_category_product.* FROM ps_category_product WHERE id_product = $idProduct;";
    final result = await link.query(query);
    print(result);
    if (result.length > 0) {
      final result2 = _getListFromIterator(result.iterator).toSet().toList();

      return result2;
    } else {
      return [];
    }
  }

  Future<ProductDetails> getProductDetails(
      {@required int idProduct, @required int idLang}) async {
    final link = await _getLink();
    var result = await link.query(
        "select id_supplier,id_manufacturer,id_category_default,ean13,isbn,minimal_quantity,price,wholesale_price,reference,supplier_reference,active,redirect_type,id_type_redirected,date_add,date_upd,state from ps_product WHERE ps_product.id_product=$idProduct;");
    ProductDetails productDetails = ProductDetails();

    if (result.length > 0) {
      var result2 = _getListFromIterator(result.iterator).toSet().toList();
      productDetails.product = result2;
      /*    final data = result2[0].map((key, value) {
        dynamic nValue;
        if (value is DateTime) {
          nValue = value.toIso8601String();
        } else {
          nValue = value;
        }
        return MapEntry(key, nValue);
      });
      print(json.encode(data)); */
      productDetails.idProduct = idProduct;

      /*   try {
        result = await link.query(
            "SELECT ps_product_lang.* FROM `ps_product_lang` where id_lang=$idLang and id_product=$idProduct;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.product_lang = result2;
      } catch (e) {
        print(e);
      } */

      try {
        result = await link.query(
            "SELECT ps_feature_lang.`id_feature`,ps_feature_lang.`name`,ps_feature.position FROM `ps_feature_lang` INNER JOIN ps_feature on ps_feature.id_feature = ps_feature_lang.id_feature WHERE ps_feature_lang.id_lang=$idLang ORDER by ps_feature.position;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.features = result2;
      } catch (e) {
        print(e);
      }
      try {
        result = await link.query(
            "SELECT ps_feature_lang.* from ps_feature_lang join ps_feature on ps_feature.id_feature = ps_feature_lang.id_feature WHERE ps_feature_lang.id_lang=$idLang ORDER by ps_feature.position;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
      } catch (e) {
        print(e);
      }
      try {
        result = await link.query("SELECT ps_category.* FROM ps_category");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.categories = result2;
      } catch (e) {
        print(e);
      }

      try {
        result =
            await link.query("SELECT ps_feature_value.* FROM ps_feature_value");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.featuresValue = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT ps_feature_value_lang.* FROM `ps_feature_value_lang` WHERE ps_feature_value_lang.id_lang=$idLang");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT `id_feature`,`id_feature_value`, `id_product` FROM `ps_feature_product`");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.featuresProduct = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT id_category,position FROM ps_category_product WHERE id_product = $idProduct;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.categoriesProduct = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT id_attachment FROM ps_product_attachment WHERE id_product = $idProduct;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.product_attachment = result2;
      } catch (e) {
        print(e);
      }

      productDetails.manufactures = await getManufacturers();
      productDetails.suppliers = await getSuppliers();
      productDetails.categories = await getCategories();
      productDetails.categoriesWithName = await getCategoriesWithName();
      productDetails.categoriesProduct = await getCategoryProduct(idProduct);

      return productDetails;
    } else {
      return null;
    }
  }

  Future saveCategoryProduct(Map<String, dynamic> data) async {
    final link = await _getLink();
    final query = ProductDetails.generateInsertSql(
        map: data, table: "ps_category_product");
    try {
      await link.query(query);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future deleteCategoryProduct({int idProduct, int idCategory}) async {
    final link = await _getLink();
    final query =
        "DELETE FROM ps_category_product where id_category = $idCategory and id_product = $idProduct";
    print(query);
    try {
      final result = await link.query(query);
      print(result.affectedRows);

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> saveProductResult(ProductDetails productDetails) async {
    final updateSql = productDetails.updateSQL;
    final querys = updateSql.split(";");
    final link = await _getLink();
    for (var sql in querys) {
      if (sql.trim().isEmpty) continue;
      link.query(sql).then((value) {
        print("response save Product");
        print(value);
      }).catchError((error) {
        print(sql);
        print(error);
      });
    }
  }

  Future<ProductDetails> putProductDetails(
      {@required int idProduct, @required int idLang}) async {
    final link = await _getLink();
    if (idProduct != 0) {
      await link.query(
          "delete ps_product_attachment.* from ps_product_attachment WHERE id_product=$idProduct;");
      await link.query(
          "delete ps_image_lang.* from ps_image_lang inner join ps_image on ps_image.id_image = ps_image_lang.id_image WHERE ps_image.id_product=$idProduct;");
      await link.query(
          "delete ps_image.* from ps_image WHERE id_product=$idProduct;");
      await link.query(
          "delete ps_product_attribute_combination.* from ps_product_attribute_combination inner join ps_product_attribute on ps_product_attribute.id_product_attribute = ps_product_attribute_combination.id_product_attribute WHERE ps_product_attribute.id_product=$idProduct;");
      await link.query(
          "delete ps_product_attribute_image.* from ps_product_attribute_image inner join ps_product_attribute on ps_product_attribute.id_product_attribute = ps_product_attribute_image.id_product_attribute WHERE ps_product_attribute.id_product=$idProduct;");
      await link.query(
          "delete ps_product_attribute.* from ps_product_attribute WHERE ps_product_attribute.id_product=$idProduct;");
      //categorias habría que borrar solo las que no hacen falta

      await link.query(
          "delete ps_category_product.* FROM `ps_category_product` WHERE id_product =$idProduct;");
      await link.query(
          "delete ps_feature_product.* FROM `ps_feature_product` FROM `ps_feature_product` WHERE id_product =$idProduct;");
      await link.query(
          "delete ps_product_lang.* from ps_product_lang WHERE id_product=$idProduct;");

      await link.query(
          "delete ps_product.* from ps_product WHERE id_product=$idProduct;");
    }
    var result = await link.query(
        "select id_supplier,id_manufacturer,id_category_default,ean13,isbn,minimal_quantity,price,wholesale_price,reference,supplier_reference,active,redirect_type,id_type_redirected,date_add,date_upd,state from ps_product WHERE ps_product.id_product=$idProduct;");
    ProductDetails productDetails = ProductDetails();

    if (result.length > 0) {
      var result2 = _getListFromIterator(result.iterator).toSet().toList();
      productDetails.product = result2;

      try {
        result = await link.query(
            "SELECT ps_feature_lang.`id_feature`,ps_feature_lang.`name`,ps_feature.position FROM `ps_feature_lang` INNER JOIN ps_feature on ps_feature.id_feature = ps_feature_lang.id_feature WHERE ps_feature_lang.id_lang=$idLang ORDER by ps_feature.position;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.features = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT ps_feature_value.`id_feature`,ps_feature_value_lang.`id_feature_value`,ps_feature_value_lang.`value` FROM `ps_feature_value_lang` INNER JOIN ps_feature_value on ps_feature_value.id_feature_value = ps_feature_value_lang.id_feature_value WHERE ps_feature_value_lang.id_lang=$idLang");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.featuresValue = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT `id_feature`,`id_feature_value` FROM `ps_feature_product` WHERE id_product = $idProduct;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.featuresProduct = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT id_category,position,0 as borrar FROM ps_category_product WHERE id_product = $idProduct;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.categoriesProduct = result2;
      } catch (e) {
        print(e);
      }

      try {
        result = await link.query(
            "SELECT id_attachment FROM ps_product_attachment WHERE id_product = $idProduct;");
        result2 = _getListFromIterator(result.iterator).toSet().toList();
        productDetails.product_attachment = result2;
      } catch (e) {
        print(e);
      }

      return productDetails;
    } else {
      return null;
    }
  }

  Future updateImages(List<Map<String, dynamic>> list) async {
    final link = await _getLink();

    try {
      for (var item in list) {
        Map<String, dynamic> nItem = {};
        item.forEach((key, value) {
          if (key != "id" && value != 0) {
            nItem[key] = value;
          }
        });

        nItem["fechamodificacion"] = DateTime.now().toIso8601String();
        if (nItem["id"] == null) {
          nItem["fechaanadida"] = DateTime.now().toIso8601String();
        }
        nItem.remove("legend");

        try {
          final query =
              ProductDetails.generateInsertSql(map: nItem, table: "ps_image");
          final result = await link.query(query);

          final imageLangQuery = ProductDetails.generateInsertSql(map: {
            "id_image": nItem["id_image"],
            "id_lang": 1,
            "legend": "legend"
          }, table: "ps_image_lang");
          final result2 = await link.query(imageLangQuery);
        } catch (e) {
          print(e);
        }
      }

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future updateCaracteristica(Map<String, dynamic> item, int idLang) async {
    final link = await _getLink();
    item.remove("position");
    item["id_lang"] = idLang;
    final query =
        ProductDetails.generateInsertSql(map: item, table: "ps_feature_lang");
    try {
      final result = await link.query(query);
      return true;
    } catch (e) {
      print(e);
    }
  }

  Future updateCaracteristicaValue(
      {Map<String, dynamic> value,
      Map<String, dynamic> valueLang,
      Map<String, dynamic> valueProduct,
      int idLang}) async {
    final link = await _getLink();

    final query1 =
        ProductDetails.generateInsertSql(map: value, table: "ps_feature_value");
    final query2 = ProductDetails.generateInsertSql(
        map: valueLang, table: "ps_feature_value_lang");
    final query3 = ProductDetails.generateInsertSql(
        map: valueProduct, table: "ps_feature_product");
    final query4 =
        "DELETE FROM ps_feature_product WHERE id_product = ${valueProduct['id_product']} and id_feature = '${value['id_feature']}'";
    try {
      // final result4 = await link.query(query4);
      final result = await link.query(query1);
      final result2 = await link.query(query2);
      final result3 = await link.query(query3);

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future deleteValueProduct({int idFeatureValue, int idProduct}) async {
    final link = await _getLink();
    final query4 =
        "DELETE FROM ps_feature_product WHERE id_product = $idProduct and id_feature_value = '$idFeatureValue'";
    try {
      final result = await link.query(query4);

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future updateCaracteristicaLangMulti(
      {Map<String, dynamic> caracteristica,
      Map<String, dynamic> caracLang,
      int idLang}) async {
    final link = await _getLink();

    final query1 = ProductDetails.generateInsertSql(
        map: caracteristica, table: "ps_feature");
    final query2 = ProductDetails.generateInsertSql(
        map: caracLang, table: "ps_feature_lang");
    try {
      final result = await link.query(query1);
      final result2 = await link.query(query2);

      return true;
    } catch (e) {
      print(e);
    }
  }

  Future updateCaracteristicaLang(Map<String, dynamic> item, int idLang) async {
    final link = await _getLink();
    item.remove("position");
    item["id_lang"] = idLang;
    final query = ProductDetails.generateInsertSql(
        map: item, table: "ps_feature_value_lang");
    try {
      final result = await link.query(query);
      return true;
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> getImages(int idProduct) async {
    final link = await _getLink();
    String query2 =
        "select ps_image.id_image,ps_image.id_product,ps_image.position,ps_image.cover,ps_image_lang.legend,ps_image.fechaanadida,ps_image.resolucionorigen," +
            "ps_image.descartada,ps_image.fechamodificacion,ps_image.resolucionrecorte,ps_image.padding, ps_image.descartada FROM ps_image inner JOIN ps_image_lang " +
            "on ps_image.id_image=ps_image_lang.id_image where ps_image.id_product ='$idProduct' and ps_image_lang.id_lang =1 order by ps_image.cover desc,ps_image.position";
    final imagesResult = await link.query(query2);

    final imageslist =
        _getListFromIterator(imagesResult.iterator).toSet().toList();
    return imageslist;
  }

  Future updateCaracteristicaValueList(
      List<Map<String, dynamic>> featuresValue, int idProduct) async {
    final link = await _getLink();

    for (var value in featuresValue) {
      try {
        final query1 = ProductDetails.generateInsertSql(
            map: value, table: "ps_feature_value");
        print(query1);

        final query4 =
            "DELETE FROM ps_feature_value WHERE id_feature = ${value['id_feature']} and id_feature_value = '${value['id_feature_value']}'";
        final result = await link.query(query4);
        final result2 = await link.query(query1);
      } catch (e) {
        print(e);
      }
    }
  }
}
