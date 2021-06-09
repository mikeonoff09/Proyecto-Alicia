typedef DataMethod = Future<List<Map<String, dynamic>>> Function();

class ListHelper {
  DataMethod dataMethod;

  final Function({
    bool done,
    String message,
    List<Map<String, dynamic>> list,
  }) onFinish;

  ListHelper({
    this.dataMethod,
    this.onFinish,
  });

  Future execute() async {
    dataMethod().then((response) {
      onFinish(
        done: true,
        list: response,
      );
    }).catchError((error) {
      print(error);
      onFinish(
          done: false,
          message: "Ocurrió un error interno, favor intentelo nuevamente");
    });
  }
}
