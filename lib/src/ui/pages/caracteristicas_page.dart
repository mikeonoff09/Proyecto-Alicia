import 'package:alicia/src/datasources/mysql_server.dart';
import 'package:alicia/src/ui/components/filtros.dart';
import 'package:alicia/src/ui/components/my_textfield.dart';
import 'package:flutter/material.dart';

import 'package:alicia/src/models/product_details.dart' as product_details;

class CaracteristicasDialog extends StatefulWidget {
  final product_details.ProductDetails productDetails;
  CaracteristicasDialog({
    Key key,
    @required this.productDetails,
  }) : super(key: key);

  @override
  _CaracteristicasDialogState createState() => _CaracteristicasDialogState();
}

class _CaracteristicasDialogState extends State<CaracteristicasDialog> {
  final featureNameController = TextEditingController();
  final featureValueController = TextEditingController();
  final nameValue = ValueNotifier<String>("");
  final valueValue = ValueNotifier<String>("");
  int selectedFeatureId;
  int selectedValue;

  @override
  void initState() {
    featureValueController.addListener(() {
      valueValue.value = featureValueController.text;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text("Caracteristicas del producto")),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              _save(context);
            },
            child: Text("Guardar cambios")),
      ],
      content: SizedBox(
        width: size.width * 0.8,
        height: size.height * 0.6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.39,
              child: Column(
                children: [
                  MyTextField(
                    controller: featureNameController,
                    labelText: "Nombre de las característica" +
                        (selectedFeatureId == null ? " - Nuevo valor" : ""),
                    onChanged: (text) {
                      nameValue.value = text;
                    },
                    suffixWidget: IconButton(
                        onPressed: () {
                          nameValue.value = "";
                          featureNameController.clear();
                          this.selectedFeatureId = null;
                          setState(() {});
                        },
                        icon: Icon(Icons.close_sharp)),
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: nameValue,
                        builder: (context, value, _) {
                          final filteredCaracteristicas = constructorSQLselect(
                              campofiltro: "name",
                              originalList: widget.productDetails.features,
                              textofiltro: featureNameController.text);
                          return ListView.builder(
                              itemBuilder: (context, index) {
                                final item = filteredCaracteristicas[index];
                                return RadioListTile(
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(item["name"] ?? "")),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        color: Theme.of(context).accentColor,
                                        onPressed: () {
                                          editFeature(context, item)
                                              .then((value) {
                                            value.forEach((key, value) {
                                              item[key] = value;
                                            });
                                            setState(() {});
                                            Future.microtask(() =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Actualizado correctamente"),
                                                  ),
                                                ));
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  // selected: item["checked"]??false,
                                  groupValue: selectedFeatureId,
                                  value: item["id_feature"],

                                  onChanged: (value) {
                                    //featureNameController.text = item["name"];
                                    final featureValue = widget.productDetails
                                        .getFeatureValue(item["id_feature"],
                                            widget.productDetails.idProduct);
                                    setState(() {
                                      selectedFeatureId = value;
                                      if (featureValue != null) {
                                        selectedValue =
                                            featureValue["id_feature_value"];
                                      }
                                    });
                                  },
                                );
                              },
                              itemCount: filteredCaracteristicas.length);
                        }),
                  ),
                ],
              ),
            ),
            Container(
              height: double.infinity,
              width: size.width * 0.0005,
              color: Colors.black45,
            ),
            SizedBox(
                width: size.width * 0.40,
                child: Column(
                  children: [
                    MyTextField(
                      controller: featureValueController,
                      labelText: "Valor de las característica" +
                          (selectedValue == null ? " - Nuevo valor" : ""),
                      onChanged: (text) {
                        print(text);
                        valueValue.value = text;
                      },
                      suffixWidget: IconButton(
                          onPressed: () {
                            valueValue.value = "";

                            this.selectedValue = null;
                            featureValueController.clear();
                            setState(() {});
                          },
                          icon: Icon(Icons.close_sharp)),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<String>(
                          valueListenable: valueValue,
                          builder: (context, value, _) {
                            final filteredValues = widget
                                .productDetails.featuresValue
                                .where((element) => (element["id_feature"] ==
                                    selectedFeatureId))
                                .toList();

                            if (filteredValues.isEmpty)
                              return Center(
                                child: Text("No se encontraron elementos"),
                              );

                            final idsList = filteredValues
                                .map((e) => e["id_feature_value"])
                                .toList();

                            /*final filteredValuesLang = constructorSQLselect(
                                campofiltro: "name",
                                originalList: widget
                                    .productDetails.featuresValueLang
                                    .where((element) {
                                  return (idsList.contains(
                                          element["id_feature_value"])) &&
                                      (element["name"] as String)
                                          .toUpperCase()
                                          .contains(value.toUpperCase());
                                }).toList(),
                                textofiltro: featureValueController.text);*/
                            return ListView.builder(
                                itemBuilder: (context, index) {
                                  final item = filteredValues[index];
                                  return RadioListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                            child: Text(item["name"] ?? "")),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          color: Theme.of(context).accentColor,
                                          onPressed: () {
                                            editFeatureValue(context, item)
                                                .then((value) {
                                              value.forEach((key, value) {
                                                item[key] = value;
                                              });
                                              setState(() {});
                                              Future.microtask(
                                                () => ScaffoldMessenger.of(
                                                        context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Actualizado correctamente",
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                    // selected: item["checked"]??false,
                                    groupValue: selectedValue,
                                    value: item["id_feature_value"],
                                    onChanged: (value) {
                                      /*    featureNameController.text =
                                                                                              item["name"]; */
                                      setState(() {
                                        selectedValue = value;
                                      });
                                    },
                                  );
                                },
                                itemCount: filteredValues.length);
                          }),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Future _save(BuildContext context) async {
    if (selectedFeatureId == null) {
      final r = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Pregunta"),
                content: Text("¿Desea agregaruna nueva característica?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text("Si"),
                  ),
                ],
              ));
      final result = r ?? false;
      if (!result) return;
      final lastFeatureId = widget.productDetails.lastFeatureId() + 1;
      selectedFeatureId = lastFeatureId;
      final feature = {
        "position": 0,
        "id_feature": lastFeatureId,
      };
      final featurelang = {
        "name": featureNameController.text,
        "id_feature": lastFeatureId,
      };

      await MysqlSeverDataSource.instance.updateCaracteristicaLangMulti(
          caracLang: featurelang, caracteristica: feature);
    }
    if (selectedValue == null) {
      final r = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Pregunta"),
                content: Text("¿Desea agregar un nuevo valor?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text("No"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text("Si"),
                  ),
                ],
              ));
      final result = r ?? false;
      if (!result) return;
      final lastValueLang = widget.productDetails.lastFeatureValueId() + 1;
      final featureValue = {
        "id_feature_value": lastValueLang,
        "id_feature": selectedFeatureId,
        "custom": 0,
        "position": 0,
      };
      final featureValueLang = {
        "id_feature_value": lastValueLang,
        "name": featureValueController.text,
      };
      final featureValueProduct = {
        "id_feature_value": lastValueLang,
        "id_product": widget.productDetails.idProduct,
        "id_feature": selectedFeatureId,
      };
      widget.productDetails.featuresValue.add(featureValue);

      MysqlSeverDataSource.instance
          .updateCaracteristicaValue(
              value: featureValue,
              valueLang: featureValueLang,
              valueProduct: featureValueProduct)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("actualizado"),
        ));
        Navigator.pop(context);
      });
    } else {
      final Map<String, dynamic> featureValue = {
        "id_feature_value": selectedValue,
        "id_feature": selectedFeatureId,
        "custom": 1,
      };
      final Map<String, dynamic> featureValueLang = {
        "id_feature_value": selectedValue,
        // "name": featureValueController.text,
      };
      final Map<String, dynamic> featureValueProduct = {
        "id_feature_value": selectedValue,
        "id_product": widget.productDetails.idProduct,
        "id_feature": selectedFeatureId,
      };

      widget.productDetails.featuresValue.forEach((element) {
        if (element["id_feature_value"] == selectedValue) {
          element.forEach((key, value) {
            if (featureValue[key] == null) {
              featureValue[key] = value;
            } else {
              element[key] = value;
            }
          });
        }
      });

      widget.productDetails.featuresValue.forEach((element) {
        if (element["id_feature_value"] == selectedValue) {
          element.forEach((key, value) {
            if (featureValueLang[key] == null) {
              featureValueLang[key] = value?.toString();
            } else {
              element[key] = value;
            }
          });
        }
      });

      widget.productDetails.featuresValue.forEach((element) {
        if (element["id_feature_value"] == selectedValue &&
            element["id_product"] == widget.productDetails.idProduct &&
            element["id_feature"] == selectedFeatureId) {
          element.forEach((key, value) {
            if (featureValueProduct[key] == null) {
              featureValueProduct[key] = value;
            } else {
              element[key] = value;
            }
          });
        }
      });

      MysqlSeverDataSource.instance
          .updateCaracteristicaValue(
              value: featureValue,
              valueLang: featureValueLang,
              valueProduct: featureValueProduct)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("actualizado"),
        ));
        Navigator.pop(context);
      });
    }
  }
}

Future<Map<String, dynamic>> editFeature(
    BuildContext context, Map<String, dynamic> item) async {
  final valueController = TextEditingController(text: item["name"]);
  final size = MediaQuery.of(context).size;
  final save = () {
    item["name"] = valueController.text;
    Navigator.pop(context, item);
    final result = MysqlSeverDataSource.instance.updateCaracteristica(item, 1);
    print("update result $result");
  };
  final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(left: 16, bottom: 16),
          title: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Text("Modificar nombre de la característica"),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  save();
                },
                child: Text("Guardar")),
          ],
          content: SizedBox(
            width: size.width * 0.4,
            child: MyTextField(
              controller: valueController,
              labelText: "Indica en nuevo texto",
              autoFocus: true,
              onEditingComplete: () {
                save();
              },
            ),
          ),
        );
      });

  if (result != null) {
    return result;
  }
  return null;
}

Future<Map<String, dynamic>> editFeatureValue(
    BuildContext context, Map<String, dynamic> item) async {
  final valueController = TextEditingController(text: item["name"]);
  final size = MediaQuery.of(context).size;
  final save = () {
    item["name"] = valueController.text;
    Navigator.pop(context, item);
    final result =
        MysqlSeverDataSource.instance.updateCaracteristicaLang(item, 1);
    print("update result $result");
  };
  final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.only(left: 16, bottom: 16),
          title: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 16),
                  child: Text("Valor de característica"),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  save();
                },
                child: Text("Guardar")),
          ],
          content: SizedBox(
            width: size.width * 0.4,
            child: MyTextField(
              controller: valueController,
              labelText: "Valor",
              autoFocus: true,
              onEditingComplete: () {
                save();
              },
            ),
          ),
        );
      });

  if (result != null) {
    return result;
  }
  return null;
}
