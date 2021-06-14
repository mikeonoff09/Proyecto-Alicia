import 'package:alicia/src/blocs/features_bloc/features_bloc.dart';
import 'package:alicia/src/datasources/http_handler.dart';
// import 'package:alicia/src/models/caracteristicas_data.dart';
import 'package:alicia/src/models/initial_data.dart';
import 'package:alicia/src/models/product.dart';
import 'package:alicia/src/models/product_details.dart' as product_details;
import 'package:alicia/src/models/product_details_model.dart';
import 'package:alicia/src/ui/components/my_textfield.dart';
import 'package:alicia/src/ui/components/table_filter_dialog.dart';
import 'package:alicia/src/ui/pages/feature_selector_page.dart';
import 'package:alicia/src/ui/pages/photo_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_products_page.dart';
import 'html_editor_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  final InitalData generalData;
  const ProductDetailsPage({
    Key key,
    @required this.product,
    @required this.generalData,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool loading = true;

  List<product_details.Feature> features;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final pricewithouttaxController = TextEditingController();
  final pricecostwithouttaxController = TextEditingController();
  final descriptionController = TextEditingController();
  final descriptionShortController = TextEditingController();

  final idproductController = TextEditingController();
  final deliveryinstockController = TextEditingController();
  final deliveryoutstockController = TextEditingController();
  final idsupplierController = TextEditingController();
  final idmanufacturerController = TextEditingController();
  final idcategoryController = TextEditingController();

  final metatitleController = TextEditingController();
  final metadescriptionController = TextEditingController();
  final metakeywordsController = TextEditingController();
  final linkrewriteController = TextEditingController();
  final referenceController = TextEditingController(); //maximo 64 caracteres
  final supplierreferenceController =
      TextEditingController(); //maximo 64 caracteres
  final ean13Controller = TextEditingController(); //maximo 13 caracteres
  final minimalquantityController = TextEditingController();
  final quantityController = TextEditingController();
  final stateController =
      TextEditingController(); //debiera ser un switch on/off

  ScrollController _controller;
  ScrollController _controller2 = ScrollController();
  final formKey = GlobalKey<FormState>();

  int selectedImage = 0;
  final _iva = 0.21;

  ProductDetailsMode productData;

  // CaracteriscasData caracteristicas;

  List<PsImage> images;
  List<PsFeatureProduct> caracteristicasProducto;
  List<PsFeatureSuper> psFeatureSuper;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Editando producto"),
        actions: [
          TextButton(
            onPressed: () {
              // openCategories(context);
            },
            child: Text(
              "Categorías",
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          TextButton(
            onPressed: () {
              saveChanges(context);
            },
            child: Text(
              "Guardar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: productData == null
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DefaultTextStyle(
                  style: TextStyle(color: Colors.black),
                  child: MediaQuery.of(context).size.width > 1400
                      ? bigScreenWidgets(size, context)
                      : bigScreenWidgets(size, context),
                ),
              ),
            ),
    );
  }

  Row bigScreenWidgets(Size size, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [imagesSection(size, context), dataSection(size, context)],
    );
  }

  Widget smallScreenWidgets(Size size, BuildContext context) {
    return Column(
      // mainAxisAlignment: CrossAxisAlignment.start,
      children: [
        imagesSection(size, context),
        dataSection(size, context),
      ],
    );
  }

  Widget dataSection(Size size, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      width: size.width * 0.46,
      child: Scrollbar(
        controller: _controller2,
        child: ListView(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 40),
          controller: _controller2,
          children: [
            Text(
              "Datos generales del producto",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            MyTextField(
              labelText: "Nombre",
              controller: nameController,
              estextoPrestashop: true,
              requiredField: true,
              maxLength: 128,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Century Gothic",
              ),
            ),
            Row(
              children: [
                fabricanteTextEditor(context),
                proveedorTextEditor(context),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: MyTextField(
                    labelText: "Precio Coste",
                    controller: pricecostwithouttaxController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    requiredField: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: "Century Gothic",
                    ),
                  ),
                ),
                Expanded(
                  child: MyTextField(
                    labelText: "Precio Sin IVA",
                    controller: pricewithouttaxController,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    requiredField: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: "Century Gothic",
                    ),
                    onChanged: (value) {
                      final sinIva = double.tryParse(value) ?? 0;
                      final nValue = sinIva * (1 + _iva);
                      priceController.text = nValue.toStringAsFixed(2);
                    },
                  ),
                ),
                Expanded(
                  child: MyTextField(
                    labelText: "PVP con IVA ",
                    controller: priceController,
                    requiredField: true,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: "Century Gothic",
                    ),
                    onChanged: (value) {
                      final conIva = double.tryParse(value) ?? 0;
                      final nValue = (conIva / (1 + _iva));
                      pricewithouttaxController.text =
                          nValue.toStringAsFixed(3);
                    },
                  ),
                ),
                Expanded(
                  child: MyTextField(
                    labelText: "ID",
                    readOnly: true,
                    controller: idproductController,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    requiredField: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: "Century Gothic",
                    ),
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Online"),
                    value: stateController.text == "1",
                    onChanged: (value) {
                      if (value) {
                        stateController.text = "1";
                      } else {
                        stateController.text = "0";
                      }
                      setState(() {});
                    },
                  ),
                )
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: MyTextField(
                    labelText: "Envio sin stock",
                    controller: deliveryoutstockController,
                    estextoPrestashop: true,
                    requiredField: true,
                    maxLines: 1,
                    maxLength: 255,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: "Century Gothic",
                    ),
                  ),
                ),
                Expanded(
                  child: MyTextField(
                    labelText: "Envio con stock",
                    estextoPrestashop: true,
                    requiredField: true,
                    controller: deliveryinstockController,
                    maxLines: 1,
                    maxLength: 255,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: "Century Gothic",
                    ),
                  ),
                ),
              ],
            ),
            MyTextField(
              labelText: "Descripción corta",
              controller: descriptionShortController,
              maxLines: 3,
              maxLength: 900,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: "Century Gothic",
              ),
              suffixWidget: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      this.openHtmlEditor(descriptionShortController, context)),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextField(
                        labelText: "Categoría",
                        controller: idcategoryController,
                        readOnly: true,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: "Century Gothic",
                        ),
                        suffixWidget: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => TableFilterDialog(
                                campoId: "id_category",
                                campoToShow: "name",
                                campofiltro: "name",
                                title: "Busqueda de Categoría",
                                widgetBuilder: (int index) {
                                  return Image.network(
                                      "https://www.mueblesextraordinarios.com/img/c/$index-thumb.jpg");
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      customTextField1(
                          controller: metadescriptionController,
                          textLabel: "Meta Descripción"),
                      customTextField1(
                          controller: metatitleController,
                          textLabel: "Meta Título"),
                      customTextField1(
                          controller: metakeywordsController,
                          textLabel: "Key Words"),
                      customTextField1(
                          controller: linkrewriteController,
                          textLabel: "URL Enlace"),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextField(
                        labelText: "EAN",
                        codigoEan: true,
                        controller: ean13Controller,
                        requiredField: true,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: "Century Gothic",
                        ),
                      ),
                      MyTextField(
                        labelText: "Refrencia", //admite -_#.
                        controller: referenceController,
                        estextoPrestashop: true,
                        requiredField: true,
                        maxLines: 1,
                        maxLength: 64,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: "Century Gothic",
                        ),
                      ),
                      MyTextField(
                        labelText: "Referencia Proveedor",
                        estextoPrestashop: true,
                        requiredField: true,
                        maxLength: 64,
                        controller: supplierreferenceController,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: "Century Gothic",
                        ),
                      ),
                      MyTextField(
                        labelText: "Stock",
                        soloentero: true,
                        requiredField: true,
                        controller: quantityController,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                      MyTextField(
                        labelText: "Pedido Mínimo",
                        soloentero: true,
                        requiredField: true,
                        controller: minimalquantityController,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  MyTextField customTextField1(
      {TextEditingController controller, String textLabel}) {
    return MyTextField(
      labelText: textLabel,
      controller: linkrewriteController,
      maxLines: 1,
      maxLength: 128,
      esUrl: true,
      requiredField: true,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        fontFamily: "Century Gothic",
      ),
    );
  }

  Expanded proveedorTextEditor(BuildContext context) {
    return Expanded(
      child: MyTextField(
        labelText: "Proveedor",
        controller: idsupplierController,
        readOnly: true,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: "Century Gothic",
        ),
        suffixWidget: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => TableFilterDialog(
                campoId: "id_supplier",
                //TODO   aqui hay que enviar (y despues recoger el id elegido) el listado de distribuidores
                originalList: widget.generalData.distribuidores,
                campoToShow: "name",
                campofiltro: "name",
                title: "Busqueda de proveedor",
                widgetBuilder: (int index) {
                  return Image.network(
                      "https://www.mueblesextraordinarios.com/img/s/$index-small_default.jpg");
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget fabricanteTextEditor(BuildContext context) {
    return Expanded(
      child: MyTextField(
        labelText: "Fabricante",
        controller: idmanufacturerController,
        readOnly: true,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: "Century Gothic",
        ),
        suffixWidget: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => TableFilterDialog(
                campoId: "id_manufacturer",
                campoToShow: "name",
                campofiltro: "name",
                title: "Búsqueda de fabricante",
                widgetBuilder: (int index) {
                  return Image.network(
                      "https://www.mueblesextraordinarios.com/img/m/$index-small_default.jpg");
                },
              ),
            );
          },
        ),
      ),
    );
  }

  SizedBox imagesSection(Size size, BuildContext context) {
    return SizedBox(
      height: size.height,
      width: size.width * 0.52, // 55% de la pantalla para imagenes
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.8,
              child: Row(
                children: [
                  Scrollbar(
                    controller: _controller,
                    child: SizedBox(
                      width: 132, //La miniatura es de 128 Pixels
                      child: ListView.builder(
                        controller: _controller,
                        itemBuilder: (context, index) {
                          final imageData = images[index];
                          if (imageData == null) {
                            return Container(
                              height: 132,
                              child: Text("Nueva imágen"),
                            );
                          }
                          final url = calcImageUrlFromId(
                            imageData.idImage,
                          );

                          return Container(
                            child: InkWell(
                              child: Stack(
                                children: [
                                  Center(child: Image.network(url)),
                                ],
                              ),
                              onTap: () {
                                setState(() {
                                  selectedImage = index;
                                });
                              },
                            ),
                            height: 132, //La miniatura es de 128 Pixels
                            decoration: BoxDecoration(
                              color: selectedImage == index
                                  ? Colors.red.withOpacity(0.8)
                                  : null,
                              border: Border(
                                bottom: BorderSide(color: Colors.black),
                              ),
                            ),
                          );
                        },
                        itemCount: images?.length ?? 0,
                      ),
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    width: 4,
                    color: Colors.black,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                  ),
                  Container(
                    height: double.infinity,
                    width: size.height * 0.8,
                    color: Colors.black.withOpacity(0.6),
                    child: Stack(
                      children: [
                        if (images.isNotEmpty)
                          Center(
                            child: Image.network(
                              calcImageUrlFromId(images[selectedImage].idImage,
                                  quality: ".jpg"),
                              height: double.infinity,
                              width: size.height * 0.785,
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            iconSize: 50,
                            icon: Icon(Icons.keyboard_arrow_right),
                            onPressed: selectedImage >= (images.length - 1)
                                ? null
                                : () {
                                    setState(() {
                                      selectedImage++;
                                    });
                                  },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            iconSize: 50,
                            icon: Icon(Icons.keyboard_arrow_left),
                            onPressed: selectedImage == 0
                                ? null
                                : () {
                                    setState(() {
                                      selectedImage--;
                                    });
                                  },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(17))),
                            child: IconButton(
                              color: Colors.white,
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                final imageData = images[selectedImage];
                                openImage(imageData, selectedImage, context);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: size.width * 0.065),
              width: double.infinity,
              child: MyTextField(
                labelText: "Descripción",
                controller: descriptionController,
                maxLines: 5,
                suffixWidget: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () =>
                        this.openHtmlEditor(descriptionController, context)),
              ),
            ),
            SizedBox(height: 25),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: featuresWidget(context),
                  ),
                ),
                // =======================================================================
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            FeatureSelectorPage(productData: productData));
                  },
                  icon: Icon(Icons.edit),
                )
              ],
            ),
            SizedBox(
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView(
        children: [],
      );
    }
  }

  @override
  void initState() {
    loadData();
    _controller = ScrollController();
    super.initState();
  }

  String getManufacturerName(int id) {
    for (var item in widget.generalData.fabricantes) {
      if (item.idManufacturer == id) return item.name;
    }
    return "No encontrado";
  }

  String getCategoryName(int id) {
    for (var item in widget.generalData.categorias) {
      if (item.idCategory == id) return item.name;
    }
    return "No encontrado";
  }

  String getSupplierName(int id) {
    for (var item in widget.generalData.distribuidores) {
      if (item.idSupplier == id) return item.name;
    }
    return "No encontrado";
  }

  Future loadData() async {
    final featuresBloc = BlocProvider.of<FeaturesBloc>(context);

    productData =
        await HttpHandler.instance.getProductData(widget.product.id_product);

    featuresBloc.add(OnListsUpdate(
      psFeatureSuperList: productData.psFeatureSuper,
      psFeatureList: productData.psFeature,
      psFeatureValueList: productData.psFeatureValue,
    ));

    print('==============================================================');

    print(productData.psFeatureProduct.toString());
    // caracteristicas = await HttpHandler.instance.getCaracteristicas();
    images = productData.psImage;

    nameController.text = productData.psProduct.first.name;
    priceController.text =
        (productData.psProduct.first.price * (1 + _iva)).toStringAsFixed(2);
    pricewithouttaxController.text =
        productData.psProduct.first.price.toStringAsFixed(3);
    pricecostwithouttaxController.text =
        productData.psProduct.first.preciocoste.toStringAsFixed(2);
    descriptionController.text = productData.psProduct.first.description;
    descriptionShortController.text =
        productData.psProduct.first.descriptionShort;

    idproductController.text = productData.psProduct.first.idProduct.toString();
    deliveryinstockController.text =
        productData.psProduct.first.deliveryInStock;
    deliveryoutstockController.text =
        productData.psProduct.first.deliveryOutStock;
    idsupplierController.text =
        getSupplierName(productData.psProduct.first.idSupplier);
    idmanufacturerController.text =
        getManufacturerName(productData.psProduct.first.idManufacturer);
    idcategoryController.text =
        getCategoryName(productData.psProduct.first.idCategoryDefault);

    metatitleController.text = productData.psProduct.first.metaTitle;
    metakeywordsController.text = productData.psProduct.first.metaKeywords;
    metadescriptionController.text =
        productData.psProduct.first.metaDescription;
    linkrewriteController.text = productData.psProduct.first.linkRewrite;
    referenceController.text = productData.psProduct.first.reference;
    supplierreferenceController.text =
        productData.psProduct.first.supplierReference;
    ean13Controller.text = productData.psProduct.first.ean13;
    minimalquantityController.text =
        productData.psProduct.first.minimalQuantity.toString();
    quantityController.text = productData.psProduct.first.quantity.toString();

    setState(() {
      loading = false;
    });
  }

  Future saveChanges(BuildContext context) async {
    if (!formKey.currentState.validate()) return;
    if (idmanufacturerController.text == "") {}
    if (idcategoryController.text == "") {}
    if (idsupplierController.text == "") {}
    try {
      String resultado;
      resultado = await HttpHandler.instance.saveProduct(
        idproduct: idproductController.text,
        idsupplier: "3",
        idmanufacturer: "3",
        idcategorydefault: "32",
        ean13: ean13Controller.text,
        quantity: quantityController.text,
        minimalquantity: minimalquantityController.text,
        price: priceController.text,
        reference: referenceController.text,
        supplierreference: supplierreferenceController.text,
        paso: "0",
        preciocoste: pricecostwithouttaxController.text,
        cachedefaultattribute: "0",
        description: descriptionController.text,
        descriptionshort: descriptionShortController.text,
        linkrewrite: linkrewriteController.text,
        metadescription: metadescriptionController.text,
        metakeywords:
            metakeywordsController.text, //metametakeywordsController.text,
        metatitle: metatitleController.text,
        name: nameController.text,
        deliveryinstock: deliveryinstockController.text,
        deliveryoutstock: deliveryoutstockController.text,
        stateWeb: stateController.text,
      );
    } catch (e) {}
  }

  void openImage(PsImage imageData, int index, BuildContext context) {
    final route = MaterialPageRoute(
      builder: (context) => PhotoEditorPage(
        index,
        images: productData.psImage,
        product: productData.psProduct[0].idProduct,
      ),
    );
    Navigator.push(
      context,
      route,
    );
  }

  void openHtmlEditor(TextEditingController controller, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HtmlEditorPage(
          originalValue: controller,
        ),
      ),
    );
  }

  PsFeatureSuper getfeatureSuperbyID(int id) {
    final _resultado = productData.psFeatureSuper.firstWhere(
      (psFeatureSuper) => psFeatureSuper.idFeatureSuper == id,
      orElse: () => null,
    );

    if (_resultado == null) {
      return _resultado;
    } else {
      return _resultado;
    }
  }

  PsFeature getfeaturebyID(int id) {
    final _resultado = productData.psFeature.firstWhere(
      (psFeature) => psFeature.idFeature == id,
      orElse: () => null,
    );

    if (_resultado == null) {
      return _resultado;
    } else {
      return _resultado;
    }
  }

  PsFeatureValue getfeatureValuebyID(int id) {
    final _resultado = productData.psFeatureValue.firstWhere(
      (psFeatureValue) => psFeatureValue.idFeatureValue == id,
      orElse: () => null,
    );

    if (_resultado == null) {
      return _resultado;
    } else {
      return _resultado;
    }
  }

  Widget featuresWidget(BuildContext context) {
    List<PsFeatureProduct> psFeatureProduct = productData.psFeatureProduct;
    List<PsFeatureSuper> psFeatureSuperlist = productData.psFeatureSuper;
    List<PsFeature> psFeatureList = productData.psFeature;
    List<PsFeatureValue> psFeatureValueList = productData.psFeatureValue;

    print("PsFeatureProduct: " + psFeatureProduct.toString());

    if (psFeatureList.length == 0) return SizedBox();

    List<PsFeatureValue> features = [];

    for (var featureProduct in psFeatureProduct) {
      PsFeatureValue unfeaturevalue =
          getfeatureValuebyID(featureProduct.idfeaturevalue);
      if (unfeaturevalue == null) {
        print("Value no encontrado");
      } else {
        PsFeature unfeature = getfeaturebyID(unfeaturevalue.idFeature);
        if (unfeature == null) {
          print("Feature no encontrado");
        } else {
          PsFeatureSuper unfeaturesuper =
              getfeatureSuperbyID(unfeature.idFeatureSuper);
          if (unfeaturesuper == null) {
            print("Super no encontrado");
          } else {
            print("Super  id:" +
                unfeaturesuper.idFeatureSuper.toString() +
                " orden:" +
                unfeaturesuper.position.toString() +
                " valor:" +
                unfeaturesuper.name +
                " Feature  id:" +
                unfeature.idFeature.toString() +
                " orden:" +
                unfeature.position.toString() +
                " name:" +
                unfeature.name +
                " Value  id:" +
                unfeaturevalue.idFeatureValue.toString() +
                " orden:" +
                unfeaturevalue.position.toString() +
                " name:" +
                unfeaturevalue.name);
          }
        }
      }
      for (var featureValue in psFeatureValueList) {
        if (featureProduct.idfeaturevalue == featureValue.idFeatureValue) {
          features.add(featureValue);
        }
      }
    }

    print(features.length);
    print(features);

    return features.isEmpty
        ? Container(
            child: Center(
              child: Text('No hay Caracteristicas'),
            ),
          )
        : ListView.builder(
            itemCount: features.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                child: ListTile(
                  title: Text(features[index].name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: null,
                  ),
                ),
                key: Key(features[index].idFeatureValue.toString()),
                background: Container(
                  color: Colors.red,
                ),
              );
            },
          );

    // productData.

    // Map<int, Widget> result = {};
    // final size = MediaQuery.of(context).size;
    // final idProduct = widget.product.id;
    // final features = this.productDetails?.features;
/*
    if (features == null) return SizedBox();
    for (var fea in features) {
      final hasValue = productDetails.productHasFeature(
          idProduct: widget.product.id, idFeature: fea["id_feature"]);
      final feaLang = productDetails.getFeatureLang(fea["id_feature"]);
      if (feaLang != null) {
        if (hasValue != null) {
          final values =
              productDetails.getFeatureValues(fea["id_feature"], idProduct);
          if (values != null) {
            for (var value in values) {
              final valueLang =
                  productDetails.getFeatureValueLang(value["id_feature_value"]);
              if (valueLang != null) {
                final key =
                    Key('${fea["id_feature"]} ${value["id_feature_value"]}');
                result[value["id_feature_value"]] = Padding(
                  key: key,
                  padding: EdgeInsets.only(left: size.width * 0.068, top: 10),
                  child: Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            (feaLang["name"] ?? "Sin nombre") + ": ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            valueLang["name"] ?? "Sin valor",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          MysqlSeverDataSource.instance.deleteValueProduct(
                              idFeatureValue: value["id_feature_value"],
                              idProduct: idProduct);
                          setState(() {
                            productDetails.featuresProduct = productDetails
                                .featuresProduct
                                .where((element) =>
                                    element["id_feature_value"] !=
                                    value["id_feature_value"])
                                .toList();
                          });
                        },
                        icon: Icon(Icons.delete),
                      )
                    ],
                  ),
                );
              }
            }
          }
        }
      } */
  }
/* 
    List<Map<String, dynamic>> resultListData = [];

    List<Map<String, dynamic>> resultListData = [];

    this.productDetails.featuresValue.forEach((element) {
      int id = element["id_feature_value"];

      final item = result[id];
      if (item != null) {
        resultListData.add(element);
      }
    });
    resultListData.sort((a, b) {
      final aValue = a["position"] as int;
      final bValue = b["position"] as int;
      return aValue.compareTo(bValue);
    });
    List<Widget> resultList = <Widget>[];
    resultListData.forEach((element) {
      int id = element["id_feature_value"];

      final item = result[id];
      if (item != null) {
        resultList.add(item);
      }
    });
    final leftController = ScrollController();
    if (features == null) return SizedBox();
    return Scrollbar(
      controller: leftController,
      child: ReorderableListView.builder(
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = resultListData.removeAt(oldIndex);
            resultListData.insert(newIndex, item);
            for (var i = 0; i < resultListData.length; i++) {
              final itemValue = resultListData[i];

          MysqlSeverDataSource.instance
              .updateCaracteristicaValueList(
                  this
                      .productDetails
                      .featuresValue
                      .where((element) =>
                          result[element["id_feature_value"]] != null)
                      .toList(),
                  productDetails.idProduct)
              .then((value) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Características actualizadas correctamente"),
            ));
          });
        },
        scrollController: leftController,
        itemBuilder: (context, index) {
          return resultList[index];
        },
        itemCount: resultList.length ?? 0,
      ),
    );
  }
 */

  // Future<void> _showDatos() async {
  //   FeaturesProvider featuresProvider = new FeaturesProvider();
  //   featuresProvider.getAllFeatures().then((value) => print(value.toString()));
  // }

  void _showFeaturesDialog(BuildContext context) {
    // showDialog(
    //   context: context,
    //   builder: (context) => CaracteristicasDialog(
    //     productDetails: this.productDetails.features,
    //   ),
    // ).then((value) {
    //   loadData();
    // });
  }

  //         MysqlSeverDataSource.instance
  //             .updateCaracteristicaValueList(
  //                 this
  //                     .productDetails
  //                     .featuresValue
  //                     .where((element) =>
  //                         result[element["id_feature_value"]] != null)
  //                     .toList(),
  //                 productDetails.idProduct)
  //             .then((value) {
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             content: Text("Características actualizadas correctamente"),
  //           ));
  //         });
  //       },
  //       scrollController: leftController,
  //       itemBuilder: (context, index) {
  //         return resultList[index];
  //       },
  //       itemCount: resultList.length ?? 0,
  //     ),
  //   );
  // }

  //  void _showFeaturesDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => CaracteristicasDialog(
  //       productDetails: this.productDetails,
  //     ),
  //   ).then((value) {
  //     loadData();
  //   });
  //  }

  Future openCategories(BuildContext context) async {
    // showDialog(
    //   context: context,
    //   builder: (context) => CategoriesPage(
    //     productDetails: this.productDetails,
    //   ),
    // ).then((value) {
    //   loadData();
    // });
  }
}
