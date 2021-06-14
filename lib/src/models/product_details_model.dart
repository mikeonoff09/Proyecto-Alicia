import 'package:alicia/src/helpers/json_smart_parser.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ProductDetailsMode extends Equatable {
  ProductDetailsMode({
    this.psProduct,
    this.psImage,
    this.psCategoryProduct,
    this.psFeatureProduct,
    this.psFeatureSuper,
    this.psFeature,
    this.psFeatureValue,
  });

  List<PsProduct> psProduct;
  List<PsImage> psImage;
  List<PsCategoryProduct> psCategoryProduct;
  List<PsFeatureProduct> psFeatureProduct;
  List<PsFeatureSuper> psFeatureSuper;
  List<PsFeature> psFeature;
  List<PsFeatureValue> psFeatureValue;

  factory ProductDetailsMode.fromMap(Map<String, dynamic> json) =>
      ProductDetailsMode(
        psProduct: List<PsProduct>.from(
            json["ps_product"].map((x) => PsProduct.fromMap(x))),
        psCategoryProduct: List<PsCategoryProduct>.from(
            json["ps_category_product"]
                .map((x) => PsCategoryProduct.fromMap(x))),
        psImage:
            List<PsImage>.from(json["ps_image"].map((x) => PsImage.fromMap(x))),
        psFeatureProduct: List<PsFeatureProduct>.from(
            json["ps_feature_product"].map((x) => PsFeatureProduct.fromMap(x))),
        psFeatureSuper: List<PsFeatureSuper>.from(
            json["ps_feature_super"].map((x) => PsFeatureSuper.fromMap(x))),
        psFeature: List<PsFeature>.from(
            json["ps_feature"].map((x) => PsFeature.fromMap(x))),
        psFeatureValue: List<PsFeatureValue>.from(
            json["ps_feature_value"].map((x) => PsFeatureValue.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "ps_product": List<dynamic>.from(psProduct.map((x) => x.toMap())),
        "ps_image": List<dynamic>.from(psImage.map((x) => x.toMap())),
        "ps_category_product":
            List<dynamic>.from(psCategoryProduct.map((x) => x.toMap())),
        "ps_feature_product":
            List<dynamic>.from(psFeatureProduct.map((x) => x.toMap())),
        "ps_feature_super":
            List<dynamic>.from(psFeatureSuper.map((x) => x.toMap())),
        "ps_feature": List<dynamic>.from(psFeature.map((x) => x.toMap())),
        "ps_feature_value":
            List<dynamic>.from(psFeatureValue.map((x) => x.toMap())),
      };

  @override
  List<Object> get props => [
        psProduct,
        psImage,
        psCategoryProduct,
        psFeatureProduct,
        psFeatureSuper,
        psFeature,
        psFeatureValue,
      ];
}

// ignore: must_be_immutable
class PsCategoryProduct extends Equatable {
  PsCategoryProduct({
    this.idCategory,
  });

  int idCategory;

  factory PsCategoryProduct.fromMap(Map<String, dynamic> json) =>
      PsCategoryProduct(
        idCategory: json["id_category"],
      );

  Map<String, dynamic> toMap() => {
        "id_category": idCategory,
      };

  @override
  List<Object> get props => [idCategory];
}

class PsFeatureSuper extends Equatable {
  PsFeatureSuper({
    this.idFeatureSuper,
    this.position,
    this.name,
  });

  int idFeatureSuper;
  int position;
  String name;

  PsFeatureSuper copyWith({int idFeatureSuper, int position, String name}) =>
      new PsFeatureSuper(
          name: name ?? this.name,
          position: position ?? this.position,
          idFeatureSuper: idFeatureSuper ?? this.idFeatureSuper);

  factory PsFeatureSuper.fromMap(Map<String, dynamic> json) {
    return PsFeatureSuper(
      idFeatureSuper: json["id_feature_super"],
      position: json["position"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toMap() => {
        "id_feature_super": idFeatureSuper,
        "position": position,
        "name": name,
      };

  @override
  List<Object> get props => [
        idFeatureSuper,
        position,
        name,
      ];
}

class PsFeature extends Equatable {
  PsFeature({
    this.idFeature,
    this.idFeatureSuper,
    this.position,
    this.name,
  });

  int idFeature;
  int idFeatureSuper;
  int position;
  String name;

  factory PsFeature.fromMap(Map<String, dynamic> json) => PsFeature(
        idFeature: json["id_feature"],
        idFeatureSuper: json["id_feature_super"],
        position: json["position"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id_feature": idFeature,
        "id_feature_super": idFeatureSuper,
        "position": position,
        "name": name,
      };

  @override
  List<Object> get props => [
        idFeature,
        idFeatureSuper,
        position,
        name,
      ];
}

class PsFeatureValue extends Equatable {
  PsFeatureValue({
    this.idFeatureValue,
    this.idFeature,
    this.position,
    this.name,
  });

  int idFeatureValue;
  int idFeature;
  int position;
  String name;

  factory PsFeatureValue.fromMap(Map<String, dynamic> json) => PsFeatureValue(
        idFeatureValue: json["id_feature_value"],
        idFeature: json["id_feature"],
        position: json["position"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id_feature_value": idFeatureValue,
        "id_feature": idFeature,
        "position": position,
        "name": name,
      };

  @override
  List<Object> get props => [
        idFeatureValue,
        idFeature,
        position,
        name,
      ];
}

// ignore: must_be_immutable
class PsImage extends Equatable {
  PsImage({
    this.idImage,
    this.idProduct,
    this.position,
    this.cover,
    this.legend,
    this.fechaanadida,
    this.resolucionorigen,
    this.descartada,
    this.fechamodificacion,
    this.resolucionrecorte,
    this.padding,
    this.nuevo,
    this.actualizar,
  });

  int idImage;
  int idProduct;
  int position;
  int cover;
  dynamic legend;
  DateTime fechaanadida;
  String resolucionorigen;
  int descartada;
  DateTime fechamodificacion;
  String resolucionrecorte;
  int padding;
  bool nuevo;
  bool actualizar;

  factory PsImage.fromMap(Map<String, dynamic> json) => PsImage(
        idImage: json["id_image"],
        idProduct: json["id_product"],
        position: json["position"],
        cover: json["cover"] == null ? null : json["cover"],
        legend: json["legend"],
        fechaanadida: DateTime.parse(json["fechaanadida"]),
        resolucionorigen: json["resolucionorigen"],
        descartada: json["descartada"],
        fechamodificacion: DateTime.parse(json["fechamodificacion"]),
        resolucionrecorte: json["resolucionrecorte"],
        padding: json["padding"],
        nuevo: json["nuevo"],
        actualizar: json["actualizar"],
      );

  Map<String, dynamic> toMap() => {
        "id_image": idImage,
        "id_product": idProduct,
        "position": position,
        "cover": cover == null ? null : cover,
        "legend": legend,
        "fechaanadida": fechaanadida.toIso8601String(),
        "resolucionorigen": resolucionorigen,
        "descartada": descartada,
        "fechamodificacion": fechamodificacion.toIso8601String(),
        "resolucionrecorte": resolucionrecorte,
        "nuevo": nuevo,
        "actualizar": actualizar,
      };

  @override
  List<Object> get props => [
        idImage,
        idProduct,
      ];
}

class PsFeatureProduct extends Equatable {
  PsFeatureProduct({
    this.idfeaturevalue,
    this.ordenfeaturesuper,
    this.ordenfeature,
    this.orderfeaturevalue,
    this.nombrefeaturesuper,
    this.nombrefeature,
    this.nombrefeacturevalue,
  });

  int idfeaturevalue;
  int ordenfeaturesuper;
  int ordenfeature;
  int orderfeaturevalue;
  String nombrefeaturesuper;
  String nombrefeature;
  String nombrefeacturevalue;

  factory PsFeatureProduct.fromMap(Map<String, dynamic> json) =>
      PsFeatureProduct(
        idfeaturevalue: json["id_feature_value"],
      );

  Map<String, dynamic> toMap() => {
        "id_feature_value": idfeaturevalue,
      };

  @override
  List<Object> get props => [
        idfeaturevalue,
      ];
}

// ignore: must_be_immutable
class PsProduct extends Equatable {
  PsProduct({
    this.idProduct,
    this.idSupplier,
    this.idManufacturer,
    this.idCategoryDefault,
    this.ean13,
    this.quantity,
    this.minimalQuantity,
    this.price,
    this.preciocoste,
    this.reference,
    this.supplierReference,
    this.cacheDefaultAttribute,
    this.dateAdd,
    this.dateUpd,
    this.stateWeb,
    this.paso,
    this.description,
    this.descriptionShort,
    this.linkRewrite,
    this.metaDescription,
    this.metaKeywords,
    this.metaTitle,
    this.name,
    this.deliveryInStock,
    this.deliveryOutStock,
  });

  int idProduct;
  int idSupplier;
  int idManufacturer;
  int idCategoryDefault;
  String ean13;
  int quantity;
  int minimalQuantity;
  double price;
  double preciocoste;
  String reference;
  String supplierReference;
  int cacheHasAttachments;
  int cacheDefaultAttribute;
  DateTime dateAdd;
  DateTime dateUpd;
  int stateWeb;
  int paso;
  String description;
  String descriptionShort;
  String linkRewrite;
  String metaDescription;
  String metaKeywords;
  String metaTitle;
  String name;
  String deliveryInStock;
  String deliveryOutStock;

  factory PsProduct.fromMap(Map<String, dynamic> map) {
    final json = JsonObject(map);
    return PsProduct(
      idProduct: json["id_product"],
      idSupplier: json["id_supplier"],
      idManufacturer: json["id_manufacturer"],
      idCategoryDefault: json["id_category_default"],
      ean13: json.getString("ean13"),
      quantity: json["quantity"],
      minimalQuantity: json["minimal_quantity"],
      price: json.getDouble("price"),
      preciocoste: json.getDouble("preciocoste"),
      reference: json["reference"],
      supplierReference: json["supplier_reference"],
      cacheDefaultAttribute: json["cache_default_attribute"],
      dateAdd: DateTime.parse(json["date_add"]),
      dateUpd: DateTime.parse(json["date_upd"]),
      stateWeb: json.getInt("stateWeb"),
      paso: json.getInt("paso"),
      description: json["description"],
      descriptionShort: json["description_short"],
      linkRewrite: json["link_rewrite"],
      metaDescription: json["meta_description"],
      metaKeywords: json["meta_keywords"],
      metaTitle: json["meta_title"],
      name: json["name"],
      deliveryInStock: json["delivery_in_stock"],
      deliveryOutStock: json["delivery_out_stock"],
    );
  }

  Map<String, dynamic> toMap() => {
        "id_product": idProduct,
        "id_supplier": idSupplier,
        "id_manufacturer": idManufacturer,
        "id_category_default": idCategoryDefault,
        "ean13": ean13,
        "quantity": quantity,
        "minimal_quantity": minimalQuantity,
        "price": price,
        "reference": reference,
        "supplier_reference": supplierReference,
        "cache_default_attribute": cacheDefaultAttribute,
        "date_add": dateAdd.toIso8601String(),
        "date_upd": dateUpd.toIso8601String(),
        "stateWeb": stateWeb,
        "paso": paso,
        "description": description,
        "description_short": descriptionShort,
        "link_rewrite": linkRewrite,
        "meta_description": metaDescription,
        "meta_keywords": metaKeywords,
        "meta_title": metaTitle,
        "name": name,
        "delivery_in_stock": deliveryInStock,
        "delivery_out_stock": deliveryOutStock,
      };

  @override
  List<Object> get props => [
        idProduct,
      ];
}
