import 'package:alicia/src/helpers/json_smart_parser.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ProductModel extends Equatable {
  ProductModel({
    this.id_product,
    this.portada,
    this.ambiente,
    this.nombreProducto,
    this.referencias,
    this.categora,
    this.fabricante,
    this.proveedor,
    this.pvp,
    this.stateWeb,
    this.paso,
  });

  int id_product;
  int portada;
  int ambiente;
  String nombreProducto;
  String referencias;
  String categora;
  String fabricante;
  String proveedor;
  double pvp;
  int stateWeb;
  int paso;

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final json = JsonObject(map);
    return ProductModel(
      id_product: json.getInt("id_product"),
      portada: json.getInt("Portada"),
      ambiente: json.getInt("Ambiente"),
      nombreProducto: json.getString("Nombre_Producto"),
      referencias: json.getString("Referencias"),
      categora: json.getString("Categoría"),
      fabricante: json.getString("Fabricante"),
      proveedor: json.getString("Proveedor"),
      pvp: json.getDouble("PVP"),
      stateWeb: json.getInt("stateWeb"),
      paso: json.getInt("Paso"),
    );
  }

  Map<String, dynamic> toMap() => {
        "ID": id_product,
        "Portada": portada,
        "Ambiente": ambiente,
        "Nombre_Producto": nombreProducto,
        "Referencias": referencias,
        "Categoría": categora,
        "Fabricante": fabricante,
        "Proveedor": proveedor,
        "PVP": pvp,
        "Estado": stateWeb,
        "Paso": paso,
      };

  @override
  List<Object> get props => [
        id_product,
        nombreProducto,
      ];
}
