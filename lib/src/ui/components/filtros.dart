List<Map<String, dynamic>> constructorSQLselect(
    {String campofiltro,
    String textofiltro,
    List<Map<String, dynamic>> originalList}) {
  if (campofiltro.isEmpty) {
    //throw Exception("Error Campo obligatorio");
    //Si no se encuentra filtros, se devuelve el listado original
    return originalList;
  }

  textofiltro = textofiltro.trim();
  do {
    textofiltro = textofiltro.replaceAll("  ", " ");
  } while (textofiltro.contains("  "));

  if (textofiltro != "") {
    List<String> textosToSearch = textofiltro.split(" ");
    return originalList.where((element) {
      dynamic val = element[campofiltro];
      String textToSearch = "";
      if (val == null) return false;

      textToSearch = val.toString();
      var found = true;
      for (var text in textosToSearch) {
        if (!(textToSearch.toUpperCase().contains(text.toUpperCase()))) {
          found = false;
          break;
        }
      }
      return found;
    }).toList();
  }
  return originalList;
}
