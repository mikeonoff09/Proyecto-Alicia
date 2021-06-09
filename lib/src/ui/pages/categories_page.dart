import 'package:alicia/src/datasources/mysql_server.dart';
import 'package:alicia/src/ui/components/filtros.dart';
import 'package:alicia/src/ui/components/my_textfield.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'package:alicia/src/models/product_details.dart' as product_details;
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatefulWidget {
  final product_details.ProductDetails productDetails;
  final int idLang;
  CategoriesPage({
    Key key,
    @required this.productDetails,
    this.idLang = 1,
  }) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final featureNameController = TextEditingController();
  final featureValueController = TextEditingController();
  final nameValue = ValueNotifier<String>("");
  final valueValue = ValueNotifier<String>("");
  int selectedFeatureId;
  int selectedValue;
  final textController = TextEditingController();

  List<int> expandedList = [];
  ValueNotifier<String> searchValue = ValueNotifier<String>("");
  List<TreeNode> categoriesList;
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
          Expanded(child: Text("Categorías del producto")),
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
            child: Text("Cerrar")),
      ],
      content: FutureBuilder(
        future: prepareNodes(),
        builder: (context, snap) {
          if (snap.hasData) {
            return SizedBox(
              width: size.width * 0.4,
              height: size.height * 0.6,
              child: Column(
                children: [
                  MyTextField(
                    controller: textController,
                    labelText: "Buscar",
                    onChanged: (value) {
                      searchValue.value = value;
                    },
                  ),
                  Expanded(
                    child: ValueListenableBuilder(
                        valueListenable: this.searchValue,
                        builder: (context, value, child) {
                          return ListView(
                            children: getCategoryList(),
                          );
                        }),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  List<Widget> getCategoryList() {
    final textoFiltro = searchValue.value;

    List<Widget> espansionChildren = this
        .categoriesList
        .map((e) => TreeNodeWidget(
              textoFiltro: textoFiltro,
              treeNode: e,
              productDetails: widget.productDetails,
              setState: () => setState(() {}),
            ))
        .toList();

    return espansionChildren;
  }

  bool isExpandedItem(int idCategory) {
    return expandedList.contains(idCategory);
  }

  Future processItem(
      {@required int idParent,
      @required List<TreeNode> children,
      @required TreeNode treeNode,
      @required int deepLevel}) async {
    print("process item");
    print(children);
    if (idParent == 0) {
      children.add(treeNode);
    }
    for (var item in children) {
      if (item.id == idParent) {
        treeNode.deepLevel = deepLevel;
        treeNode.collapse = deepLevel <= 1;
        item.children.add(treeNode);
      }
      if (item.children.isNotEmpty) {
        Future.delayed(Duration(milliseconds: 500));
        treeNode.deepLevel = deepLevel;
        treeNode.collapse = deepLevel <= 1;
        await processItem(
            idParent: idParent,
            children: item.children,
            treeNode: treeNode,
            deepLevel: deepLevel + 1);
      }
    }
  }

  Future sortItem(List<TreeNode> children) async {
    for (var item in children) {
      item.children.sort((a, b) {
        final aPos = a.data["position"] as int;
        final bPos = b.data["position"] as int;
        return aPos.compareTo(bPos);
      });
      if (item.children.isNotEmpty) {
        sortItem(item.children);
      }
    }
  }

  Future<List<TreeNode>> prepareNodes() async {
    if (categoriesList != null) return categoriesList;
    categoriesList = [];

    widget.productDetails.categories.sort((a, b) {
      final parentA = a["id_parent"] as int;
      final parentB = b["id_parent"] as int;
      return parentA.compareTo(parentB);
    });

    final addItem = (
        {@required Map<String, dynamic> data,
        @required int idCategory,
        @required int idParent}) async {
      TreeNode node = TreeNode(
        data: data,
        id: idCategory,
        deepLevel: 0,
        children: [],
      );
      if (idParent > 0) {
        await processItem(
            children: categoriesList,
            idParent: idParent,
            treeNode: node,
            deepLevel: 1);
      } else {
        categoriesList.add(node);
      }
    };
    for (var element in widget.productDetails.categories) {
      final id = element["id_category"] as int;
      final idParent = element["id_parent"];
      await addItem(idCategory: id, idParent: idParent, data: element);
    }
    sortItem(categoriesList);
    print(categoriesList);
    return categoriesList;
  }

  Future _save(BuildContext context) async {
    if (selectedFeatureId == null) {
      final lastFeatureId = widget.productDetails.lastFeatureId() + 1;
      selectedFeatureId = lastFeatureId;
      final feature = {
        "position": 0,
        "id_feature": lastFeatureId,
      };
      final featurelang = {
        "name": featureNameController.text,
        "id_lang": widget.idLang,
        "id_feature": lastFeatureId,
      };

      await MysqlSeverDataSource.instance.updateCaracteristicaLangMulti(
          caracLang: featurelang,
          caracteristica: feature,
          idLang: widget.idLang);
    }
    if (selectedValue == null) {
      final lastValueLang = widget.productDetails.lastFeatureValueId() + 1;
      final featureValue = {
        "id_feature_value": lastValueLang,
        "id_feature": selectedFeatureId,
        "custom": 0,
        "position": 0,
      };
      final featureValueProduct = {
        "id_feature_value": lastValueLang,
        "id_product": widget.productDetails.idProduct,
        "id_feature": selectedFeatureId,
      };
      widget.productDetails.featuresValue.add(featureValue);

      /*MysqlSeverDataSource.instance
          .updateCaracteristicaValue(
              value: featureValue,
              valueLang: featureValueLang,
              valueProduct: featureValueProduct)
          .then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("actualizado"),
        ));
        Navigator.pop(context);
      });   */
    } else {
      final Map<String, dynamic> featureValue = {
        "id_feature_value": selectedValue,
        "id_feature": selectedFeatureId,
        "value": 1,
      };
      final Map<String, dynamic> featureValueLang = {
        "id_feature_value": selectedValue,
        // "value": featureValueController.text,
        "id_lang": widget.idLang,
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

      /*widget.productDetails.featuresValueLang.forEach((element) {
        if (element["id_feature_value"] == selectedValue &&
            element["id_lang"] == widget.idLang) {
          element.forEach((key, value) {
            if (featureValueLang[key] == null) {
              featureValueLang[key] = value?.toString();
            } else {
              element[key] = value;
            }
          });
        }
      }); */

      /*widget.productDetails.featuresValueLang.forEach((element) {
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
      });*/

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
  final valueController = TextEditingController(text: item["value"]);
  final size = MediaQuery.of(context).size;
  final save = () {
    item["value"] = valueController.text;
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

class TreeNode {
  final Map<String, dynamic> data;
  final int id;
  bool checked;
  bool collapse = false;
  List<TreeNode> children;
  int deepLevel;
  Widget widget;
  List<Widget> childrenWidget;

  TreeNode(
      {@required this.data,
      @required this.id,
      this.checked = false,
      this.deepLevel,
      this.children}) {}
}

class TreeNodeWidget extends StatelessWidget {
  final TreeNode treeNode;
  final String textoFiltro;
  final product_details.ProductDetails productDetails;
  final VoidCallback setState;
  const TreeNodeWidget(
      {Key key,
      @required this.textoFiltro,
      @required this.treeNode,
      this.productDetails,
      this.setState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child;
    final productCat = productDetails.getCategoryProduct(
        idCategory: treeNode.data["id_category"],
        idProduct: productDetails.idProduct);
    /*final productLang =
        productDetails.getCategoryLang(treeNode.data["id_category"]);
    
    child = CheckboxListTile(
        value: productCat != null,
        title: Text(productLang["name"]),
        onChanged: (value) {
          if (value) {
            final data = {
              "position": 0,
              "id_product": productDetails.idProduct,
              "id_category": treeNode.data["id_category"]
            };
            productDetails.categoriesProduct.add(data);
            MysqlSeverDataSource.instance.saveCategoryProduct(data);
          } else {
            productDetails.categoriesProduct =
                productDetails.categoriesProduct.where((item2) {
              return item2["id_category"] != treeNode.data["id_category"];
            }).toList();

            MysqlSeverDataSource.instance.deleteCategoryProduct(
                idCategory: treeNode.data["id_category"],
                idProduct: productDetails.idProduct);
          }
          setState();
        });
      */
    //  if (child == null) return SizedBox();
    if (treeNode.children.isEmpty) {
      return Row(
        children: [
          Expanded(
              child: Container(
            margin: EdgeInsets.only(left: treeNode.deepLevel * 10.0),
            child: child,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                ),
              ),
            ),
          )),
          IconButton(
            onPressed: null,
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          )
        ],
      );
    } else {
      if (treeNode.deepLevel <= 0) {
        return Column(
          children: getChildren(context),
        );
      }
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Se revisa si se muestra

          Container(
            child: Row(
              children: [
                Expanded(
                  child: child,
                ),
                IconButton(
                    onPressed: () {
                      treeNode.collapse = !isCollapse;
                      setState();
                    },
                    icon: Icon(!isCollapse
                        ? Icons.keyboard_arrow_right
                        : Icons.keyboard_arrow_down))
              ],
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black12, width: 2),
              ),
            ),
          ),
        ]..addAll(getChildren(context)),
      );
    }

    return Container(
      child: child,
      margin: EdgeInsets.only(left: treeNode.deepLevel * 10.0),
    );
  }

  bool get isCollapse {
    if (treeNode.deepLevel <= 1) {
      return true;
    }
    print("treeNode.collapse");
    print(treeNode.collapse);
    return treeNode.collapse;
  }

  List<Widget> getChildren(BuildContext context) {
    if (!isCollapse) {
      return [];
    }
    var list = treeNode.children
        .where((element) {
          String name = element.data["name"];
          var found = true;
          if (textoFiltro != "") {
            List<String> textosToSearch = textoFiltro.split(" ");

            String textToSearch = "";

            textToSearch = name.toString();

            for (var text in textosToSearch) {
              if (!(textToSearch.toUpperCase().contains(text.toUpperCase()))) {
                found = false;
                break;
              }
            }
          }
          return found;
        })
        .map((e) => TreeNodeWidget(
              textoFiltro: textoFiltro,
              treeNode: e,
              productDetails: productDetails,
              setState: setState,
            ))
        .toList();

    return list;
  }
}
