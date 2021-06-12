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
    List<PsFeatureValue> psFeatureValueList = widget.productData.psFeatureValue;
    List<PsFeatureSuper> psFeatureSuperlist = widget.productData.psFeatureSuper;
    List<PsFeature> psFeatureList = widget.productData.psFeature;
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
              itemCount: psFeatureSuperlist.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(psFeatureSuperlist[index].name),
                  onTap: () {
                    // TODO: cambiar los datos de las listas
                  },
                );
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
                  onTap: (){
                    // TODO: Cambiar los datos de las listas
                  },
                );
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
                  onTap: (){
                    // TODO: Marcar la propiedad como seleccionada
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Container mainSearch() {
    return Container(
      // height: 120,
      child: MyTextField(
        controller: searchController,
        labelText: "Busqueda",
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
            child: MyTextField(
              controller: featureSuperController,
              labelText: "Busqueda en Feature Super",
            ),
          ),
          Expanded(
            flex: 1,
            child: MyTextField(
              controller: featureController,
              labelText: "Busqueda en Feature",
            ),
          ),
          Expanded(
            flex: 1,
            child: MyTextField(
              controller: featureValueController,
              labelText: "Busqueda en Feature Value",
            ),
          ),
        ],
      ),
    );
  }
}
