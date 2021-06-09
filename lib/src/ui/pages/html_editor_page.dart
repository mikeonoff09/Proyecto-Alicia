import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
/* import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart'; */

class HtmlEditorPage extends StatefulWidget {
  final TextEditingController originalValue;
  HtmlEditorPage({Key key, this.originalValue}) : super(key: key);

  @override
  _HtmlEditorPageState createState() => _HtmlEditorPageState();
}

class _HtmlEditorPageState extends State<HtmlEditorPage> {
  // QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final child = ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text("Peview"),
        Flexible(
          child: HtmlWidget(
            widget.originalValue.text,
          ),
        ),
        /*  QuillToolbar.basic(controller: _controller),
        Expanded(
          child: Container(
            child: QuillEditor.basic(
              controller: _controller,
              readOnly: false, // true for view only mode
            ),
          ),
        ) */
      ],
    );
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              //widget.originalValue.text = _controller.document.toPlainText();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: child,
    );
  }
}
