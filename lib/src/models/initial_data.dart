import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class InitalData extends Equatable {
  InitalData({
    this.categorias,
    this.fabricantes,
    this.distribuidores,
  });

  List<Categoria> categorias;
  List<Fabricante> fabricantes;
  List<Distribuidor> distribuidores;

  factory InitalData.fromJson(Map<String, dynamic> json) => InitalData(
        categorias: List<Categoria>.from(
            json["categorias"].map((x) => Categoria.fromJson(x))),
        fabricantes: List<Fabricante>.from(
            json["fabricantes"].map((x) => Fabricante.fromJson(x))),
        distribuidores: List<Distribuidor>.from(
            json["distribuidores"].map((x) => Distribuidor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categorias": List<dynamic>.from(categorias.map((x) => x.toJson())),
        "fabricantes": List<dynamic>.from(fabricantes.map((x) => x.toJson())),
        "distribuidores":
            List<dynamic>.from(distribuidores.map((x) => x.toJson())),
      };

  @override
  List<Object> get props => [
        categorias,
        fabricantes,
        distribuidores,
      ];
}

// ignore: must_be_immutable
class Categoria extends Equatable {
  Categoria({
    this.idCategory,
    this.name,
    this.idParent,
    this.idShopDefault,
    this.levelDepth,
    this.nleft,
    this.nright,
    this.active,
    this.position,
    this.isRootCategory,
  });

  int idCategory;
  String name;
  int idParent;
  int idShopDefault;
  int levelDepth;
  int nleft;
  int nright;
  int active;
  int position;
  int isRootCategory;

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idCategory: json["id_category"],
        name: json["name"],
        idParent: json["id_parent"],
        levelDepth: json["level_depth"],
        nleft: json["nleft"],
        nright: json["nright"],
        active: json["active"],
        position: json["position"],
        isRootCategory: json["is_root_category"],
      );

  Map<String, dynamic> toJson() => {
        "id_category": idCategory,
        "name": name,
        "id_parent": idParent,
        "level_depth": levelDepth,
        "nleft": nleft,
        "nright": nright,
        "active": active,
        "position": position,
        "is_root_category": isRootCategory,
      };

  @override
  List<Object> get props => [
        idCategory,
        name,
        idParent,
        idShopDefault,
        levelDepth,
        nleft,
        nright,
        active,
        position,
        isRootCategory,
      ];
}

// ignore: must_be_immutable
class Distribuidor extends Equatable {
  Distribuidor({
    this.idSupplier,
    this.name,
    this.description,
  });

  int idSupplier;
  String name;
  String description;

  factory Distribuidor.fromJson(Map<String, dynamic> json) => Distribuidor(
        idSupplier: json["id_supplier"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id_supplier": idSupplier,
        "name": name,
        "description": description,
      };

  @override
  List<Object> get props => [
        idSupplier,
        name,
        description,
      ];
}

// ignore: must_be_immutable
class Fabricante extends Equatable {
  Fabricante({
    this.idManufacturer,
    this.name,
    this.description,
  });

  int idManufacturer;
  String name;
  String description;

  factory Fabricante.fromJson(Map<String, dynamic> json) => Fabricante(
        idManufacturer: json["id_manufacturer"],
        name: json["name"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id_manufacturer": idManufacturer,
        "name": name,
        "description": description,
      };

  @override
  List<Object> get props => [
        idManufacturer,
        name,
        description,
      ];
}
