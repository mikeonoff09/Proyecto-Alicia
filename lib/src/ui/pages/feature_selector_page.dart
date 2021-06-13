import 'package:alicia/src/models/product_details_model.dart';
import 'package:alicia/src/product_bloc/product_bloc.dart';
import 'package:alicia/src/ui/components/my_textfield.dart';
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

  @override
  Widget build(BuildContext context) {
    final featureProductBloc = BlocProvider.of<ProductBloc>(context);
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
    final featureProductBloc = BlocProvider.of<ProductBloc>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Row(
        // direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: psFeatureSuperList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: Text(psFeatureSuperList[index].name),
                    onTap: () => _newFeatureSuperSelected(
                        psFeatureSuperList[index].idFeatureSuper));
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: psFeatureList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: Text(psFeatureList[index].name),
                    onTap: () =>
                        _newFeatureSelected(psFeatureList[index].idFeature));
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: psFeatureValueList.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(psFeatureValueList[index].name),
                  onTap: () {
                    // TODO: Marcar la propiedad como seleccionada
                  },
                  trailing:
                      IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _newFeatureSuperSelected(int idFeatureSuper) {
    print("New Feature Super Clicked ");
    psFeatureValueList = [];
    psFeatureList = [];

    for (var feature in widget.productData.psFeature) {
      if (feature.idFeatureSuper == idFeatureSuper) {
        psFeatureList.add(feature);
        for (var featureValue in widget.productData.psFeatureValue) {
          if (featureValue.idFeature == feature.idFeature) {
            print("adding");
            psFeatureValueList.add(featureValue);
          }
        }
      }
    }
    setState(() {});
  }

  _newFeatureSelected(int idFeature) {
    print("New Feature Clicked ");
    psFeatureValueList = [];

    for (var featureValue in widget.productData.psFeatureValue) {
      if (featureValue.idFeature == idFeature) {
        print("adding");
        psFeatureValueList.add(featureValue);
      }
    }
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
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
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
                IconButton(onPressed: () {}, icon: Icon(Icons.add)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
}
