import 'package:equatable/equatable.dart';

class CaracteriscasData {
  CaracteriscasData({
    this.psFeatureSuper,
    this.psFeature,
    this.psFeatureValue,
  });

  List<CarDataPsFeatureSuper> psFeatureSuper;
  List<CardDataPsFeature> psFeature;
  List<CardDataPsFeatureValue> psFeatureValue;

  factory CaracteriscasData.fromMap(Map<String, dynamic> json) =>
      CaracteriscasData(
        psFeatureSuper: List<CarDataPsFeatureSuper>.from(
            json["ps_feature_super"]
                .map((x) => CarDataPsFeatureSuper.fromMap(x))),
        psFeature: List<CardDataPsFeature>.from(
            json["ps_feature"].map((x) => CardDataPsFeature.fromMap(x))),
        psFeatureValue: List<CardDataPsFeatureValue>.from(
            json["ps_feature_value"]
                .map((x) => CardDataPsFeatureValue.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "ps_feature_super":
            List<dynamic>.from(psFeatureSuper.map((x) => x.toMap())),
        "ps_feature": List<dynamic>.from(psFeature.map((x) => x.toMap())),
        "ps_feature_value":
            List<dynamic>.from(psFeatureValue.map((x) => x.toMap())),
      };

  @override
  String toString() {
    return this.toMap().toString();
  }
}

class CarDataPsFeatureSuper extends Equatable {
  CarDataPsFeatureSuper({
    this.idFeatureSuper,
    this.position,
    this.name,
  });

  int idFeatureSuper;
  int position;
  String name;

  factory CarDataPsFeatureSuper.fromMap(Map<String, dynamic> json) =>
      CarDataPsFeatureSuper(
        idFeatureSuper:
            json["id_feature_super"] == null ? null : json["id_feature_super"],
        position: json["position"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id_feature_super": idFeatureSuper == null ? null : idFeatureSuper,
        "position": position,
        "name": name,
      };

  @override
  List<Object> get props => [idFeatureSuper];

  @override
  String toString() {
    return this.toMap().toString();
  }
}

class CardDataPsFeature extends Equatable {
  CardDataPsFeature({
    this.idFeature,
    this.idFeatureSuper,
    this.position,
    this.name,
  });

  int idFeature;
  int idFeatureSuper;
  int position;
  String name;

  factory CardDataPsFeature.fromMap(Map<String, dynamic> json) =>
      CardDataPsFeature(
        idFeature: json["id_feature"] == null ? null : json["id_feature"],
        idFeatureSuper: json["id_feature_super"],
        position: json["position"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id_feature": idFeature == null ? null : idFeature,
        "id_feature_super": idFeatureSuper,
        "position": position,
        "name": name,
      };

  @override
  List<Object> get props => [idFeature];

  @override
  String toString() {
    return toMap().toString();
  }
}

class CardDataPsFeatureValue extends Equatable {
  CardDataPsFeatureValue({
    this.idFeatureValue,
    this.idFeature,
    this.position,
    this.name,
  });

  int idFeatureValue;
  int idFeature;
  int position;
  String name;

  factory CardDataPsFeatureValue.fromMap(Map<String, dynamic> json) =>
      CardDataPsFeatureValue(
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
  List<Object> get props => [idFeatureValue, idFeature];

  @override
  String toString() {
    return this.toMap().toString();
  }
}
