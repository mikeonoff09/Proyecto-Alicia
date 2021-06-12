import 'package:alicia/src/ui/components/my_textfield.dart';
import 'package:flutter/material.dart';

class FeatureSelectorPage extends StatefulWidget {
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
    return Container(
      child: Row(
        // direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return Container();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return;
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return;
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
