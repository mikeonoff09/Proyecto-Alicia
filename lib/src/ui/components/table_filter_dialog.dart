import 'package:alicia/src/ui/components/my_textfield.dart';
import 'package:flutter/material.dart';

import 'filtros.dart';

typedef OnResult = Function(ResultData result);
typedef WidgetBuilder = Widget Function(int id);

class TableFilterDialog extends StatefulWidget {
  final List<dynamic> originalList;
  final String title;
  final String campoToShow;
  final String campoId;
  final OnResult onResult;
  final WidgetBuilder widgetBuilder;

  final String campofiltro;
  const TableFilterDialog(
      {Key key,
      @required this.originalList,
      @required this.campofiltro,
      @required this.title,
      @required this.widgetBuilder,
      @required this.campoToShow,
      @required this.campoId,
      @required this.onResult})
      : super(key: key);

  @override
  _TableFilterDialogState createState() => _TableFilterDialogState();
}

class _TableFilterDialogState extends State<TableFilterDialog> {
  final TextEditingController controller = TextEditingController();
  final _scroollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            SizedBox(height: 20),
            MyTextField(
              controller: controller,
              labelText: "Búsqueda en ${widget.campofiltro}",
            ),
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.6,
                child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    final filtered = constructorSQLselect(
                        campofiltro: widget.campofiltro,
                        originalList: widget.originalList,
                        textofiltro: controller.text);
                    return Scrollbar(
                      controller: _scroollController,
                      child: ListView.builder(
                        controller: _scroollController,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            title: Text(item[widget.campoToShow]),
                            leading: widget.widgetBuilder != null
                                ? SizedBox(
                                    child: widget.widgetBuilder(
                                        item[widget.campoId] as int),
                                    width: 120,
                                    height: 60,
                                  )
                                : Text(item[widget.campoId].toString()),
                            onTap: () {
                              widget.onResult(
                                ResultData(
                                  id: item[widget.campoId],
                                  label: item[widget.campoToShow],
                                ),
                              );
                              Navigator.pop(context);
                            },
                          );
                        },
                        itemCount: filtered.length,
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Aceptar"))
      ],
    );
  }
}

class ResultData {
  final int id;
  final String label;

  ResultData({@required this.id, @required this.label});
}
