import 'package:alicia/src/blocs/features_bloc/features_bloc.dart';
import 'package:alicia/src/datasources/http_handler.dart';
import 'package:alicia/src/models/product_details_model.dart';
import 'package:alicia/src/ui/components/error_dialog.dart';
import 'package:alicia/src/ui/components/my_textfield.dart';
import 'package:alicia/src/ui/components/show_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureSelectorPage extends StatefulWidget {
  final ProductDetailsMode productData;

  const FeatureSelectorPage({Key key, @required this.productData})
      : super(key: key);

  @override
  _FeatureSelectorPageState createState() => _FeatureSelectorPageState();
}

class _FeatureSelectorPageState extends State<FeatureSelectorPage> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController featureSuperController = TextEditingController();
  final TextEditingController featureController = TextEditingController();
  final TextEditingController featureValueController = TextEditingController();

  List<PsFeatureValue> psFeatureValueList;
  List<PsFeatureSuper> psFeatureSuperList;
  List<PsFeature> psFeatureList;

  PsFeatureSuper selectedSuper;

  PsFeature selectedFeature;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Center(
          child: Column(
            children: [
              mainSearch(),
              searchSection(),
              Expanded(child: featuresLists()),
            ],
          ),
        ),
      ),
    );
  }

  Container featuresLists() {
    psFeatureValueList =
        psFeatureValueList ?? widget.productData.psFeatureValue;
    psFeatureSuperList =
        psFeatureSuperList ?? widget.productData.psFeatureSuper;
    psFeatureList = psFeatureList ?? widget.productData.psFeature;
    final featuresBloc = BlocProvider.of<FeaturesBloc>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: psFeatureSuperList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      key: Key(
                          psFeatureSuperList[index].idFeatureSuper.toString()),
                      onDismissed: (direction) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            content: Container(
                              child: Text("texto"),
                            ),
                          ),
                        );
                      },
                      child: RadioListTile(
                        title: Text(psFeatureSuperList[index].name),
                        value: psFeatureSuperList[index],
                        groupValue: selectedSuper,
                        secondary: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              _editPsFeatureSuper(psFeatureSuperList[index]),
                        ),
                        onChanged: (value) {
                          _newFeatureSuperSelected(psFeatureSuperList[index]);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: psFeatureList.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(psFeatureList[index].idFeature.toString()),
                  child: RadioListTile(
                      title: Text(psFeatureList[index].name),
                      value: psFeatureList[index],
                      groupValue: selectedFeature,
                      secondary: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            // TODO: Agregar edicion
                            _editPsFeature(psFeatureList[index]),
                      ),
                      onChanged: (_) =>
                          _newFeatureSelected(psFeatureList[index])),
                );
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: psFeatureValueList.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(psFeatureValueList[index].idFeatureValue.toString()),
                  child: RadioListTile(
                    title: Text(psFeatureValueList[index].name),
                    value: psFeatureValueList[index],
                    secondary: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          // TODO: Agregar edicion
                          _editPsFeatureValue(psFeatureValueList[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _newFeatureSuperSelected(PsFeatureSuper featureSuper) {
    print("New Feature Super Clicked ");
    psFeatureValueList = [];
    psFeatureList = [];
    selectedSuper = featureSuper;

    for (var feature in widget.productData.psFeature) {
      if (feature.idFeatureSuper == featureSuper.idFeatureSuper) {
        psFeatureList.add(feature);
        for (var featureValue in widget.productData.psFeatureValue) {
          if (featureValue.idFeature == feature.idFeature) {
            print("adding");
            psFeatureValueList.add(featureValue);
          }
        }
      }
    }
    _cleanControllers();
    setState(() {});
  }

  _cleanControllers() {
    searchController.clear();
    featureSuperController.clear();
    featureController.clear();
    featureValueController.clear();
  }

  _newFeatureSelected(PsFeature feature) {
    print("New Feature Clicked ");
    psFeatureValueList = [];
    selectedFeature = feature;

    for (var featureValue in widget.productData.psFeatureValue) {
      if (featureValue.idFeature == feature.idFeature) {
        print("adding");
        psFeatureValueList.add(featureValue);
      }
    }
    _cleanControllers();
    setState(() {});
  }

  Container mainSearch() {
    return Container(
      // height: 120,
      child: MyTextField(
        controller: searchController,
        labelText: "Busqueda General",
        onChanged: (value) {
          _searchFeature(value);
          _searchFeatureSuper(value);
          _searchFeatureValue(value);
        },
      ),
    );
  }

  Container searchSection() {
    return Container(
      child: Row(
        // direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: featureSuperController,
                    labelText: "Busqueda en Feature Super",
                    onChanged: (value) => _searchFeatureSuper(value),
                  ),
                ),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveSuperFeature();
                    },
                    child: Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  height: 55,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: featureController,
                    labelText: "Busqueda en Feature",
                    onChanged: (value) => _searchFeature(value),
                  ),
                ),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveFeature();
                    },
                    child: Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  height: 55,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: featureValueController,
                    labelText: "Busqueda en Feature Value",
                    onChanged: (value) => _searchFeatureValue(value),
                  ),
                ),
                SizedBox(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      _saveFeatureValue();
                    },
                    child: Icon(Icons.add),
                  ),
                  height: 55,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editPsFeatureSuper(PsFeatureSuper psFeatureSuper) {
    TextEditingController textController = new TextEditingController();
    textController.value = TextEditingValue(text: psFeatureSuper.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 100,
            width: 200,
            child: Column(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: "Nuevo Nombre",
                    labelText: "Nuevo Nombre",
                  ),
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                          onPressed: () {
                            //TODO: solicitud de UPDATE ya se realiza hacia el servidor
                            //si resultado es 200 se cierra la ventana
                            //en otro caso muestra el mensaje de error enviado por el servidor
                            HttpHandler.instance.updateSuperFeature(
                                psFeatureSuper.copyWith(
                                    name: textController.value.text,
                                    idFeatureSuper:
                                        psFeatureSuper.idFeatureSuper,
                                    position: psFeatureSuper.position));
                          },
                          child: Text("Aceptar")),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _editPsFeature(PsFeature psFeature) {
    TextEditingController textController = new TextEditingController();
    textController.value = TextEditingValue(text: psFeature.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 100,
            width: 200,
            child: Column(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: "Nuevo Nombre",
                    labelText: "Nuevo Nombre",
                  ),
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                          onPressed: () {
                            //TODO: solicitud de UPDATE ya se realiza hacia el servidor
                            //si resultado es 200 se cierra la ventana
                            //en otro caso muestra el mensaje de error enviado por el servidor
                            HttpHandler.instance.updateFeature(
                                psFeature.copyWith(
                                    idFeatureSuper: psFeature.idFeatureSuper,
                                    name: textController.value.text,
                                    idFeature: psFeature.idFeature,
                                    position: psFeature.position));
                          },
                          child: Text("Aceptar")),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _editPsFeatureValue(PsFeatureValue psFeatureValue) {
    TextEditingController textController = new TextEditingController();
    textController.value = TextEditingValue(text: psFeatureValue.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 100,
            width: 200,
            child: Column(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: "Nuevo Nombre",
                    labelText: "Nuevo Nombre",
                  ),
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                          onPressed: () {
                            //TODO: solicitud de UPDATE ya se realiza hacia el servidor
                            //si resultado es 200 se cierra la ventana
                            //en otro caso muestra el mensaje de error enviado por el servidor
                            HttpHandler.instance.updateFeatureValue(
                                psFeatureValue.copyWith(
                                    idFeatureValue:
                                        psFeatureValue.idFeatureValue,
                                    name: textController.value.text,
                                    idFeature: psFeatureValue.idFeature,
                                    position: psFeatureValue.position));
                          },
                          child: Text("Aceptar")),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancelar"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
  // BUSQUEDAS

  _searchFeatureSuper(String value) {
    psFeatureSuperList = [];
    for (var featureSuper in widget.productData.psFeatureSuper) {
      if (featureSuper.name.toLowerCase().contains(value.toLowerCase())) {
        psFeatureSuperList.add(featureSuper);
      }
    }
    setState(() {});
  }

  _searchFeature(String value) {
    psFeatureList = [];
    for (var feature in widget.productData.psFeature) {
      if (feature.name.toLowerCase().contains(value.toLowerCase())) {
        psFeatureList.add(feature);
      }
    }
    setState(() {});
  }

  _searchFeatureValue(String value) {
    psFeatureValueList = [];
    for (var featureValue in widget.productData.psFeatureValue) {
      if (featureValue.name.toLowerCase().contains(value.toLowerCase())) {
        psFeatureValueList.add(featureValue);
      }
    }
    setState(() {});
  }

  // GUARDAR FEATURES

  Future _saveSuperFeature() async {
    final superValue = PsFeatureSuper(
        idFeatureSuper: null,
        name: this.featureSuperController.text,
        position: null);
    showLoading(context);
    final result = await HttpHandler.instance.saveSuperFeature(superValue);
    Navigator.pop(context);
    if (result != null) {
      widget.productData.psFeatureSuper.add(result);
      //featureSuperController.clear();
      _searchFeatureSuper(featureSuperController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Característica principal agregada"),
      ));
    } else {
      showError(context,
          "Ocurrió un error al intentar guardar, profavor intentelo nuevamente");
    }
  }

  Future _saveFeature() async {
    if (selectedSuper?.idFeatureSuper == null) {
      showError(
          context, "NO se ha seleccionado ninguna Característica principal");
      return;
    }
    final superValue = PsFeature(
        idFeatureSuper: selectedSuper?.idFeatureSuper,
        name: this.featureController.text,
        position: null);
    showLoading(context);
    final result = await HttpHandler.instance.saveFeature(superValue);
    Navigator.pop(context);
    if (result != null) {
      widget.productData.psFeature.add(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Característica agregada"),
        ),
      );
      _searchFeature(featureController.text);
    } else {
      showError(context,
          "Ocurrió un error al intentar guardar, profavor intentelo nuevamente");
    }
  }

  Future _saveFeatureValue() async {
    if (selectedFeature?.idFeature == null) {
      showError(context, "NO se ha seleccionado ninguna Característica");
      return;
    }
    final feaValue = PsFeatureValue(
        idFeature: selectedFeature?.idFeature,
        name: this.featureValueController.text,
        position: null);
    showLoading(context);
    final result = await HttpHandler.instance.saveFeatureValue(feaValue);
    Navigator.pop(context);
    if (result != null) {
      widget.productData.psFeatureValue.add(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Valor agregado"),
        ),
      );
      _searchFeatureValue(featureValueController.text);
    } else {
      showError(context,
          "Ocurrió un error al intentar guardar, profavor intentelo nuevamente");
    }
  }
}
