import 'dart:convert';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:responsive/flex_builder.dart';
import 'package:responsive/flex_personalizable_widget.dart';
import 'package:responsive/responsive.dart';

class TableWidget<T> extends StatefulWidget {
  final List<List<dynamic>> data;
  final List<String> headers;
  final List<FlexPersonalizableWidget> columnsWidths;
  final List<T> selecteds;
  final int page;
  final int totalPage;
  final int countToDisplay;

  final Color headerColor;
  final Color headerTextColor;
  final ValueChanged<int> onPageChanged;
  final double keyboardScrollVelocity;
  final Duration keyboardScrollDuration;
  final Color paginationButtonColor;

  final Function(int index, bool selected) onRowSelectedChange;
  final List<TableAction> actions;
  final List<T> values;
  final bool centerHorizontal;
  final int maxStringLength;
  final TextAlign cellTextAlign;
  final Map<int, double> widthSizes;
  final double rowHeight;
  final Function(int index) onRowTap;

  const TableWidget(
      {Key key,
      @required this.data,
      @required this.values,
      @required this.headers,
      @required this.onPageChanged,
      @required this.countToDisplay,
      @required this.totalPage,
      @required this.onRowSelectedChange,
      @required this.selecteds,
      @required this.onRowTap,
      this.rowHeight = 60.0,
      this.widthSizes,
      this.maxStringLength,
      this.headerColor = Colors.black,
      this.headerTextColor = Colors.white,
      this.paginationButtonColor = Colors.grey,
      this.actions,
      this.cellTextAlign = TextAlign.left,
      this.centerHorizontal = false,
      this.keyboardScrollVelocity = 0.25,
      this.keyboardScrollDuration = const Duration(milliseconds: 50),
      @required this.page,
      this.columnsWidths})
      : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  ScrollController _controller;
  ScrollController _controllerHor;
  TransformationController transformationController;
  int page;

  int rowCount = 0;

  FocusNode _textNode;
  @override
  Widget build(BuildContext context) {
    if (widget.data == null)
      return Center(
        child: CircularProgressIndicator(),
      );
    return twoListView(context);
  }

  double getColumnSize(int index, BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    Size cellSize = Size(
        (((screenSize.width - 255)) / widget.headers.length), widget.rowHeight);

    if (widget.widthSizes != null) {
      return widget.widthSizes[index] * screenSize.width;
    }
    return cellSize.width;
  }

  Widget twoListView(BuildContext context) {
    List<Widget> headers = [];
    for (var i = 0; i < widget.headers.length; i++) {
      final element = widget.headers[i];
      headers.add(
        Container(
          height: 60,
          width: getColumnSize(i, context),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.white),
              color: Colors.black),
          child: Center(
            child: Text(
              element.toString().toUpperCase(),
              textAlign: widget.cellTextAlign,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      );
    }
    return FlexWidgetSettings(
      size: MediaQuery.of(context).size,
      child: FlexBuilderWidget(builder: (context, width, offset, size) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: headers,
              ),
            ),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      itemCount: widget.data.length,
                      itemBuilder: (context, index) => dataTableBuilder(
                        context,
                        index,
                      ),
                    )))
          ],
        );
      }),
    );
  }

  Widget dataTableBuilder(
    context,
    index,
  ) {
    List<Widget> children = [];
    final list = widget.data[index];
    for (var i = 0; i < list.length; i++) {
      final e = list[i];
      if (e is Widget) {
        children.add(Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
          child: e,
          height: widget.rowHeight,
          width: getColumnSize(i, context),
        ));
      } else {
        /*   children.add(Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
          child: Center(
            child: SelectableText(
              e,
              textAlign: widget.cellTextAlign,
            ),
          ),
          height: widget.rowHeight,
          width: getColumnSize(i, context),
        )); */

        children.add(Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration:
              BoxDecoration(border: Border.all(width: 1, color: Colors.black)),
          child: Center(
            child: Text(
              e,
              textAlign: widget.cellTextAlign,
            ),
          ),
          height: widget.rowHeight,
          width: getColumnSize(i, context),
        ));
      }
    }
    return InkWell(
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.2),
      onTap: () {
        widget.onRowTap(index);
      },
      child: Container(
        height: widget.rowHeight,
        child: Row(
          children: children,
        ),
      ),
    );
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controllerHor = ScrollController();

    transformationController = TransformationController();

    rowCount = widget.data.length;
    _textNode = FocusNode();
    //document.onContextMenu.listen((event) => event.preventDefault());

    super.initState();
  }

  bool getIsRowSelected(int index) {
    final value = widget.values[index];
    return widget.selecteds.contains(value);
  }

  double get calcVelociy => widget.keyboardScrollVelocity * 300;

  void onKeyPress(RawKeyEvent value) {
    //print(value);
    if (value is RawKeyDownEvent) {
      if (value.logicalKey.keyId == 0x100070051) {
        // transformationController.value.translate(20, 20);
        _controller.animateTo(_controller.offset + calcVelociy,
            duration: Duration(
                milliseconds: widget.keyboardScrollDuration.inMilliseconds),
            curve: Curves.linear);
      } else if (value.logicalKey.keyId == 0x100070052) {
        _controller.animateTo(_controller.offset - calcVelociy,
            duration: Duration(
                milliseconds: widget.keyboardScrollDuration.inMilliseconds),
            curve: Curves.linear);
      } else if (value.logicalKey.keyId == 0x10007004f) {
        _controllerHor.animateTo(_controllerHor.offset + calcVelociy,
            duration: Duration(
                milliseconds: widget.keyboardScrollDuration.inMilliseconds),
            curve: Curves.linear);
      } else if (value.logicalKey.keyId == 0x100070050) {
        _controllerHor.animateTo(_controllerHor.offset - calcVelociy,
            duration: Duration(
                milliseconds: widget.keyboardScrollDuration.inMilliseconds),
            curve: Curves.linear);
      }
    }
  }

  Future showCellValue(BuildContext context, String column) async {
    String jsonValue;
    try {
      jsonValue = (json.decode(column)).toString().replaceAll(",", ",\n");
    } catch (ex) {}
    final size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Vista"),
              content: Container(
                child: SingleChildScrollView(child: Text(jsonValue ?? column)),
                width: size.width * .60,
                height: size.height / 0.8,
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Aceptar"))
              ],
            ));
  }
}

class TableAction extends StatelessWidget {
  final Function(int index) onPressed;
  final Icon icon;
  final int index;
  TableAction({Key key, this.onPressed, this.icon, this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: icon,
        onPressed: () {
          onPressed(index);
        });
  }

  TableAction copyWidth(int index) {
    return TableAction(
      icon: icon,
      index: index,
      onPressed: this.onPressed,
    );
  }
}
