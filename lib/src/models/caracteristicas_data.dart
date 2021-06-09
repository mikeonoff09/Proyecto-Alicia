import 'package:equatable/equatable.dart';

class CaracteriscasData {
  CaracteriscasData({
    this.psFeatureSuper,
    this.psFeature,
    this.psFeatureValue,
  });

  List<PsFeatureSuper> psFeatureSuper;
  List<PsFeature> psFeature;
  List<PsFeatureValue> psFeatureValue;

  factory CaracteriscasData.fromMap(Map<String, dynamic> json) =>
      CaracteriscasData(
        psFeatureSuper: List<PsFeatureSuper>.from(
            json["ps_feature_super"].map((x) => PsFeatureSuper.fromMap(x))),
        psFeature: List<PsFeature>.from(
            json["ps_feature"].map((x) => PsFeature.fromMap(x))),
        psFeatureValue: List<PsFeatureValue>.from(
            json["ps_feature_value"].map((x) => PsFeatureValue.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "ps_feature_super":
            List<dynamic>.from(psFeatureSuper.map((x) => x.toMap())),
        "ps_feature": List<dynamic>.from(psFeature.map((x) => x.toMap())),
        "ps_feature_value":
            List<dynamic>.from(psFeatureValue.map((x) => x.toMap())),
      };
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

  factory PsFeatureSuper.fromMap(Map<String, dynamic> json) => PsFeatureSuper(
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
}

class PsFeatureValue extends Equatable {
  PsFeatureValue({
    this.idFeatureValue,
    this.idFeature,
    this.position,
    this.value,
  });

  int idFeatureValue;
  int idFeature;
  int position;
  String value;

  factory PsFeatureValue.fromMap(Map<String, dynamic> json) => PsFeatureValue(
        idFeatureValue: json["id_feature_value"],
        idFeature: json["id_feature"],
        position: json["position"],
        value: json["value"],
      );

  Map<String, dynamic> toMap() => {
        "id_feature_value": idFeatureValue,
        "id_feature": idFeature,
        "position": position,
        "value": value,
      };

  @override
  List<Object> get props => [idFeatureValue, idFeature];
}
