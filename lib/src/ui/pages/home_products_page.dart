import 'package:alicia/src/datasources/http_handler.dart';
import 'package:alicia/src/models/initial_data.dart';
import 'package:alicia/src/models/product.dart';
import 'package:alicia/src/ui/components/table_widget.dart';
import 'package:alicia/src/ui/pages/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class HomeProductsPage extends StatefulWidget {
  HomeProductsPage({Key key}) : super(key: key);

  @override
  _HomeProductsPageState createState() => _HomeProductsPageState();
}

class _HomeProductsPageState extends State<HomeProductsPage> {
  int totalPage = 1;
  int page = 1;
  List<ProductModel> productList;
  Map<String, Map<String, dynamic>> selecteds = {};
  List<Categoria> categories = [];
  List<Fabricante> manufactures = [];
  List<Distribuidor> suppliers = [];
  List<Map<String, dynamic>> stateWebs = [
    {"name": "Todos:", "id": 2},
    {"name": "Oculto", "id": 0},
    {"name": "Público", "id": 1},
  ];
  List<Map<String, dynamic>> pasos = [
    {"name": "Todos:", "id": 0},
    {"name": "Importado", "id": 1},
    {"name": "Img:sí Text:no", "id": 3},
    {"name": "Img:no Text:sí", "id": 4},
    {"name": "Img:sí Text:sí", "id": 5},
    {"name": "Revisar", "id": 6},
    {"name": "Publicado", "id": 7},
  ];
  Categoria categorySelected = Categoria(name: "Categorías", idCategory: 0);
  Fabricante manufacturSelected =
      Fabricante(name: "Fabricantes:", idManufacturer: 0);
  Distribuidor supplierSelected =
      Distribuidor(name: "Distribuidores:", idSupplier: 0);

  Map<String, dynamic> stateWebSelected = {"name": "Todos:", "id": 2};
  Map<String, dynamic> pasoSelected = {"name": "Todos:", "id": 0};
  ScrollController _controller;
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final referenceController = TextEditingController();

  InitalData generalData;
  @override
  void initState() {
    _controller = ScrollController();
    loadPrimaryData();
    //loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<List<dynamic>> data = getListData();
    return Scaffold(
      // drawer: getDrawer(context),
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        key: Key("addproduct"),
        child: Icon(Icons.add),
        onPressed: () {
          // createNewProduct(context);
        },
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _filtros(),
                Divider(),
                SizedBox(height: 20),
                productList == null
                    ? Center(child: CircularProgressIndicator())
                    : _tablaProductos(context, data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _filtros() {
    return Container(
      padding: EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //     border: Border.all(color: Colors.blueAccent)),
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.start,
        alignment: WrapAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: Center(
              child: Text(
                "Filtros",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: TextFormField(
              decoration: InputDecoration(labelText: "Id Producto"),
              controller: idController,
              onChanged: (value) {
                loadData();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: TextFormField(
              decoration: InputDecoration(labelText: "Nombre"),
              controller: nameController,
              onChanged: (value) {
                loadData();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 84,
            width: 200,
            child: Transform.translate(
              offset: Offset(0, 0),
              child: SearchableDropdown<Categoria>.single(
                value: categorySelected,
                onChanged: (value) {
                  setState(() {
                    categorySelected = value;
                  });
                  loadData();
                },
                items: categories
                    .map(
                      (e) => DropdownMenuItem<Categoria>(
                        child: Text("${e.name}"),
                        value: e,
                      ),
                    )
                    .toList(),
                isExpanded: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: TextFormField(
              decoration: InputDecoration(labelText: "Referencia"),
              controller: referenceController,
              onChanged: (value) {
                loadData();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: Transform.translate(
              offset: Offset(0, 0),
              child: SearchableDropdown<Fabricante>.single(
                value: manufacturSelected,
                onChanged: (value) {
                  setState(() {
                    manufacturSelected = value;
                  });
                  loadData();
                },
                items: manufactures
                    .map(
                      (e) => DropdownMenuItem<Fabricante>(
                        child: Text("${e.name}"),
                        value: e,
                      ),
                    )
                    .toList(),
                isExpanded: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: Transform.translate(
              offset: Offset(0, 0),
              child: SearchableDropdown<Map<String, dynamic>>.single(
                value: stateWebSelected,
                onChanged: (value) {
                  setState(() {
                    stateWebSelected = value;
                  });
                  loadData();
                },
                items: stateWebs
                    .map(
                      (e) => DropdownMenuItem<Map<String, dynamic>>(
                        child: Text("${e["name"]} (${e["id"]})"),
                        value: e,
                      ),
                    )
                    .toList(),
                isExpanded: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 84,
            width: 200,
            child: Transform.translate(
              offset: Offset(0, 0),
              child: SearchableDropdown<Map<String, dynamic>>.single(
                // menuConstraints: BoxConstraints.loose(Size(
                //     MediaQuery.of(context).size.width * 0.5,
                //     MediaQuery.of(context).size.height * 0.9)),
                // dialogBox: false,
                value: pasoSelected,
                onChanged: (value) {
                  setState(() {
                    pasoSelected = value;
                  });
                  loadData();
                },
                items: pasos
                    .map(
                      (e) => DropdownMenuItem<Map<String, dynamic>>(
                        child: Text("${e["name"]} (${e["id"]})"),
                        value: e,
                      ),
                    )
                    .toList(),
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded _tablaProductos(BuildContext context, List<List<dynamic>> data) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableWidget(
          centerHorizontal: true,
          countToDisplay: 5,
          onRowTap: (index) {
            try {
              print(index);
              final product = productList[index];
              final route = MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                  product: product,
                  generalData: this.generalData,
                ),
              );
              Navigator.push(context, route);
            } catch (e) {
              print(e);
            }
          },
          page: page,
          totalPage: totalPage,
          data: data,
          rowHeight: 115,
          cellTextAlign: TextAlign.center,
          widthSizes: {
            0: 0.05,
            1: 0.08,
            2: 0.08,
            3: 0.2,
            4: 0.15,
            5: 0.08,
            6: 0.07,
            7: 0.07,
            8: 0.1,
            9: 0.045,
            // 10: 0.06,
          },
          headerTextColor: Colors.black54,
          paginationButtonColor: Theme.of(context).accentColor,
          headerColor: Theme.of(context).primaryColor,
          selecteds: getSelectedsList(),
          values: List<String>.from(
              (productList?.map((e) => e?.toString()) ?? []).toList()),
          onRowSelectedChange: onRowSelectedChange,
          actions: [
            // TableAction(
            //   onPressed: (index) {
            //     print("ejecutando el onPressed de edit");
            //   },
            //   icon: Icon(Icons.edit),
            // ),
            // TableAction(
            //   onPressed: (index) {
            //     print("ejecutando el onPressed de remove red eye");
            //   },
            //   icon: Icon(Icons.remove_red_eye),
            // ),
          ],
          headers: getHeaders(context),
          onPageChanged: (int page) {
            setState(() {
              this.page = page;
              productList = null;
            });
            Future.microtask(() => loadData());
          },
        ),
      ),
    );
  }

  List<List<dynamic>> getListData() {
    if (productList == null) return [];
    List<List<dynamic>> result = [];
    for (var i = 0; i < this.productList.length; i++) {
      result.add(getRow(i));
    }
    return result;
  }

  List<String> getSelectedsList() {
    var result = selecteds.keys.toList();

    return result;
  }

  String getManufacturerName(int id) {
    for (var item in generalData.fabricantes) {
      if (item.idManufacturer == id) return item.name;
    }
    return "No encontrado";
  }

  String getCategoryName(int id) {
    for (var item in generalData.categorias) {
      if (item.idCategory == id) return item.name;
    }
    return "No encontrado";
  }

  String getSupplierName(int id) {
    for (var item in generalData.distribuidores) {
      if (item.idSupplier == id) return item.name;
    }
    return "No encontrado";
  }

  Future onRowSelectedChange(int index, bool selected) async {}

  List<dynamic> getRow(int index) {
    final data = productList[index];

    List<dynamic> values = List<dynamic>.from(
        data.toMap().values.map((e) => e.toString()).toList());

    values[1] = new Image.network(calcImageUrlFromId(int.tryParse(values[1])));
    values[2] = new Image.network(calcImageUrlFromId(int.tryParse(values[2])));
    values[5] = getCategoryName(int.tryParse(values[5]));
    values[6] = getManufacturerName(int.tryParse(values[6]));
    values[7] = getSupplierName(int.tryParse(values[7]));
    values.removeLast();
    return values;
  }

  Future loadPrimaryData() async {
    generalData = await HttpHandler.instance.getGeneralData();

    productList = await HttpHandler.instance.getProductList();
    this.categories = generalData.categorias;
    this.categories.add(categorySelected);
    this.manufactures = generalData.fabricantes;
    this.manufactures.add(manufacturSelected);
    this.suppliers = generalData.distribuidores;
    this.suppliers = this.suppliers.toSet().toList();
    this.suppliers.add(supplierSelected);
    this.pasos.add(pasoSelected);
    this.stateWebs.add(stateWebSelected);

    Future.microtask(() => setState(() {}));
  }

//  Mejorar
  Future loadData() async {
    Future.microtask(() => this.productList = null);
    String name = nameController.text;
    String referencia = referenceController.text;
    int category = 0;
    int manu = 0;
    int supli = 0;
    int stateWeb = 2;
    int paso = 0;
    String idproduct = idController.text;

    categorySelected == null
        ? category = 0
        : category = categorySelected?.idCategory;

    if (idproduct == null) {
      idproduct = "0";
    } else {
      if (double.tryParse(idproduct) == null) {
        idproduct = "0";
      }
    }

    manufacturSelected == null
        ? manu = 0
        : manu = manufacturSelected.idManufacturer;

    supplierSelected == null ? supli = 0 : supli = supplierSelected.idSupplier;

    //TODO: try catch parser
    stateWebSelected == null
        ? stateWeb = 2
        : stateWeb = stateWebSelected["id"] as int;

    pasoSelected == null ? paso = 0 : paso = pasoSelected["id"] as int;

    print(
        "idproduct = $idproduct, paso =$paso, stateWeb=$stateWeb, name = $name, referencia = $referencia, category = $category, fabricante = $manu , supplier = $supli");

    name.trim() == "" ? name = "" : null;

    referencia.trim() == "" ? referencia = "" : null;

    productList = await HttpHandler.instance.getProductList(
        referencia: referencia,
        category: category,
        supplier: supli,
        stateWeb: stateWeb,
        paso: paso,
        fabricante: manu,
        name: name,
        idproduct: idproduct);
    print(productList);
    setState(() {});
  }

  List<String> getHeaders(BuildContext context) {
    if (productList?.isEmpty ?? true) return [];
    final result = productList[0].toMap().keys.toList();
    result.removeLast();
    return result;
  }

  // Widget getDrawer(BuildContext context) {
  //   return Drawer(
  //     child: ListView(
  //       children: [
  //         MenuItem(
  //           title: Text("Inicio"),
  //           icon: Icon(Icons.home),
  //           onPressed: () {},
  //         ),
  //         MenuItem(
  //           title: Text("Filtrar Productos"),
  //           icon: Icon(Icons.list),
  //           onPressed: () {},
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

// Future createNewProduct(BuildContext context) async {
//   int lastId = (await MysqlSeverDataSource.instance.getLastProductId()) + 1;

//   final product = {
//     "id_supplier": 0,
//     "id_manufacturer": 0,
//     "id_category_default": 0,
//     "ean13": "",
//     "minimal_quantity": 1,
//     "price": 0.0,
//     "id_product": lastId,
//     "wholesale_price": 0.0,
//     "reference": "",
//     "supplier_reference": "",
//     "redirect_type": "",
//     "id_type_redirected": 0,
//     "date_add": DateTime.now(),
//     "date_upd": DateTime.now(),
//     "stateWeb": 1,
//     "paso": 0
//   };
//   final images = <Map<String, dynamic>>[];

//   /*  final route = MaterialPageRoute(
//     builder: (context) => ProductDetailsPage(
//       images: images,
//       product: product,
//     ),
//   );
//   Navigator.push(
//     context,
//     route,
//   ); */
// }

String calcImageUrl(Map<String, dynamic> imagenData,
    {String quality = "-cart_default.jpg"}) {
  final id = imagenData["id_image"];
  List<String> list = [];
  id.toString().runes.forEach((element) {
    var character = new String.fromCharCode(element);
    list.add(character);
  });
  String base = "http://www.mueblesextraordinarios.com/img/p";
  list.forEach((element) {
    base += "/$element";
  });
  return base + "/$id" + quality;
}

String calcImageUrlFromId(int idImage, {String quality = "-cart_default.jpg"}) {
  if (idImage == null)
    return "https://www.mueblesextraordinarios.com/img/placeholder.png";
  List<String> list = [];
  idImage.toString().runes.forEach((element) {
    var character = new String.fromCharCode(element);
    list.add(character);
  });
  String base = "http://www.mueblesextraordinarios.com/img/p";
  list.forEach((element) {
    base += "/$element";
  });
  return base + "/$idImage" + quality;
}
