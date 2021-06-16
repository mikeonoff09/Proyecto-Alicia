import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:alicia/src/models/product_details_model.dart';
import 'package:alicia/src/ui/pages/home_products_page.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;

import '../components/result_canvas_image.dart';

class PhotoEditorPage extends StatefulWidget {
  final int product;
  final List<PsImage> images;
  final int selectedImage;
  const PhotoEditorPage(
    this.selectedImage, {
    Key key,
    @required this.product,
    @required this.images,
  }) : super(key: key);

  @override
  _PhotoEditorPageState createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  final leftController = ScrollController();
  int selectedImage;
  File downloadedImage;
  File resultImage;
  File resultImage2;
  File resultImageJpg;
  File resultImageJpg2;
  File resultOriginalCropImage;

  bool loading = false;
  CropController _controller = CropController();
  Uint8List _imageData;
  double aspectRatio;
  double topMargin = 0;
  final resultFocus = FocusNode();
  Size originalSize;
  int addingImage;
  bool isNewImage = false;

  final imageResult = ValueNotifier<Uint8List>(null);
  Rect lastRect;
  final resultKey = GlobalKey<ResultCanvasImageState>();
  double paddingValue = 1;

  ValueNotifier<Rect> areaValue = new ValueNotifier<Rect>(
    Rect.fromLTWH(240, 212, 800, 600),
  );
  Size get getImageSize {
    //final w = areaValue.value.right - areaValue.value.left;
    //final h = areaValue.value.bottom - areaValue.value.top;
    //final bottom = areaValue.value.bottom;
    final bottom = areaValue.value.size;
    //return Size(w, h);
    return bottom; // devuelve un size (Ancho, Alto)
  }

  String get getImageSizeText {
    final size = getImageSize;
    double width = size.width;
    double heigth = size.height;

    return "${width.toStringAsFixed(0)}px * ${heigth.toStringAsFixed(0)}px";
  }

  @override
  void initState() {
    Timer.periodic(Duration(milliseconds: 350), (_) {
      if (mounted) {
        if (lastRect != areaValue.value) {
          try {
            lastRect = areaValue.value;
            _controller.crop();
          } catch (e) {}
        }
      }
    });
    for (var i = 0; i < widget.images.length; i++) {
      if (/* element["cover"] == 1 || */ i == widget.selectedImage) {
        Future.microtask(() => openImage(widget.images[i].idImage, i, context));
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Imagenes de "),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                saveResults(context);
              })
        ],
        toolbarHeight: 40,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          print("New Image");
          _addImage(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          style: TextStyle(color: Colors.black),
          child: Row(
            children: [
              Scrollbar(
                controller: leftController,
                child: SizedBox(
                  width: 130,
                  child: ReorderableListView.builder(
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final item = widget.images.removeAt(oldIndex);
                        widget.images.insert(newIndex, item);
                        for (var i = 0; i < widget.images.length; i++) {
                          final itemValue = widget.images[i];
                          if (i == 0) {
                            itemValue.cover = 1;
                          } else {
                            itemValue.cover = null;
                          }
                          itemValue.position = (i + 1);
                        }
                      });
                      // TODO: reordenar y guardar
/*
                      MysqlSeverDataSource.instance
                          .updateImages(widget.images)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Imágenes actualizadas correctamente"),
                        ));
                      });*/
                    },
                    scrollController: leftController,
                    itemBuilder: (context, index) {
                      final imageData = widget.images[index];
                      final url = calcImageUrl(
                        imageData.idImage,
                      );

                      return Container(
                        key: Key(imageData.idImage.toString()),
                        child: InkWell(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: <Widget>[
                              if (imageData.idImage != addingImage)
                                new Image.network(url),
                              if (imageData.idImage == addingImage)
                                Image.file(downloadedImage),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                    color: Colors.black.withOpacity(0.65),
                                    width: 130,
                                    child: Text(
                                      imageData.resolucionorigen ?? "",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    )),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: aspectRatio == 1
                                      ? null
                                      : () {
                                          setState(() {
                                            aspectRatio = 1;
                                          });
                                        },
                                ),
                              ),
                              if (imageData.descartada == 1)
                                Positioned(
                                  top: 10,
                                  left: 0,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          onTap: selectedImage == index || loading
                              ? null
                              : () {
                                  isNewImage = false;
                                  openImage(imageData.idImage, index, context);
                                },
                        ),
                        height: 130,
                        decoration: BoxDecoration(
                            color: selectedImage == index
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5)
                                : null,
                            border: Border(
                                bottom: BorderSide(color: Colors.black))),
                      );
                    },
                    itemCount: widget.images?.length ?? 0,
                  ),
                ),
              ),
              Container(
                height: double.infinity,
                width: 4,
                color: Colors.red,
                margin: EdgeInsets.symmetric(horizontal: 5),
              ),
              if (loading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Descargando archivo"),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!loading && _imageData != null)
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.grid_on_outlined),
                              onPressed: aspectRatio == 1
                                  ? null
                                  : () {
                                      setState(() {
                                        aspectRatio = 1;
                                      });
                                    },
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              icon: Icon(Icons.grid_off),
                              onPressed: aspectRatio == null
                                  ? null
                                  : () {
                                      setState(() {
                                        aspectRatio = null;
                                      });
                                    },
                            ),
                            ValueListenableBuilder<Rect>(
                                valueListenable: areaValue,
                                builder: (context, value, child) {
                                  return Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      children: [
                                        Text("Size: "),
                                        Text(
                                          getImageSizeText,
                                        )
                                      ],
                                    ),
                                  );
                                }),
                            ElevatedButton(
                                child: Text("80%"),
                                onPressed: paddingValue == 0.8
                                    ? null
                                    : () {
                                        setState(() {
                                          paddingValue = 0.8;
                                        });
                                      }),
                            ElevatedButton(
                                child: Text("87%"),
                                onPressed: paddingValue == 0.87
                                    ? null
                                    : () {
                                        setState(() {
                                          paddingValue = 0.87;
                                        });
                                      }),
                            ElevatedButton(
                                child: Text("95%"),
                                onPressed: paddingValue == 0.95
                                    ? null
                                    : () {
                                        setState(() {
                                          paddingValue = 0.95;
                                        });
                                      }),
                            ElevatedButton(
                                child: Text("100%"),
                                onPressed: paddingValue == 1
                                    ? null
                                    : () {
                                        setState(() {
                                          paddingValue = 1;
                                        });
                                      }),
                            SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.black),
                              onPressed: () {
                                _descartadarImage(selectedImage);
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: 800,
                                    width: 800,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black)),
                                      child: Crop(
                                        key: Key((aspectRatio?.toString() ??
                                                "null") +
                                            widget.product.toString()),
                                        image: _imageData,
                                        cornerDotBuilder: (size, index) =>
                                            const DotControl(
                                          color: Colors.blue,
                                        ),
                                        //maskColor: Colors.amber,
                                        controller: _controller,
                                        baseColor: Colors.black38,
                                        initialSize: 1.0,
                                        aspectRatio: aspectRatio,
                                        onCropped: (imageData) async {
                                          imageResult.value = imageData;
                                        },

                                        onMoved: (rect) {
                                          areaValue.value = rect;
                                        },
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: InkWell(
                                        child: Image.asset("assets/photo.png"),
                                        onTap: () async {
                                          final result = await Process.run(
                                              "C:\\program files\\adobe\\adobe photoshop 2021\\photoshop.exe",
                                              [
                                                this
                                                    .downloadedImage
                                                    .absolute
                                                    .path
                                                    .replaceAll("/", "\\")
                                              ]);

                                          print(result);
                                        },
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: ValueListenableBuilder<Uint8List>(
                                  valueListenable: imageResult,
                                  builder: (context, value, child) {
                                    Widget child = Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text("Esperando..."),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(),
                                          )
                                        ],
                                      ),
                                    );
                                    if (value != null) {
                                      child = ResultCanvasImage(
                                          //key: resultKey,
                                          padding: EdgeInsets.all(
                                              800 - (800 * paddingValue)),
                                          imageData: value,
                                          top: topMargin);
                                    }
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 800,
                                          width: 800,
                                          child: child,
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: InkWell(
                                              child: Image.asset(
                                                  "assets/photo.png"),
                                              onTap: () async {
                                                await saveResults(context,
                                                    openResultDialog: false);
                                                final result = await Process.run(
                                                    "C:\\windows\\system32\\mspaint.exe",
                                                    [
                                                      this
                                                          .resultImageJpg
                                                          .absolute
                                                          .path
                                                          .replaceAll("/", "\\")
                                                    ]);

                                                print(result);
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Future openImage(int imageData, int index, BuildContext context) async {
    setState(() {
      loading = true;
      topMargin = 0;
      selectedImage = index;
      imageResult.value = null;
      downloadedImage = null;
    });
    areaValue.value = Rect.fromLTWH(240, 212, 800, 600);
    final url = calcImageUrl(imageData, quality: ".jpg");
    final response = await http.get(Uri.parse(url));
    /////////////////////////////////////////////////////////////////
    final productDir = Directory("./products/${widget.product}/images");
    final resultDir = Directory("./products/${widget.product}/result");
    productDir.createSync(recursive: true);
    resultDir.createSync(recursive: true);
    print(productDir.absolute);
    resultImage = File(resultDir.path + "/${imageData}.png");
    resultImage2 = File(resultDir.path + "/${imageData}-cart_default.png");
    resultImageJpg = File(resultDir.path + "/${imageData}.jpg");
    resultImageJpg2 = File(resultDir.path + "/${imageData}-cart_default.jpg");
    resultOriginalCropImage = File(resultDir.path + "/${imageData}-crop.jpg");

    downloadedImage = File(productDir.path + "/${imageData}.jpg");
    downloadedImage.writeAsBytesSync(response.bodyBytes);
    this._imageData = response.bodyBytes;

    ui.Codec codec = await ui.instantiateImageCodec(_imageData);
    ui.FrameInfo fi = await codec.getNextFrame();
    final uiImage = fi.image;
    originalSize = Size(uiImage.width.toDouble(), uiImage.height.toDouble());

    setState(() {
      loading = false;
    });
  }

  Future saveResults(BuildContext context,
      {bool openResultDialog = true}) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Row(
                children: [
                  Expanded(child: Text("Procesando")),
                  CircularProgressIndicator(),
                ],
              ),
            ),
            content: ResultCanvasImage(
              key: resultKey,
              padding: EdgeInsets.all(800 - (800 * paddingValue)),
              imageData: this.imageResult.value,
              top: topMargin,
            ),
          );
        });
    await Future.delayed(Duration(milliseconds: 500));
    final resultImage = await resultKey.currentState.getImage(Size(800, 800));
    final resultImage2 = await resultKey.currentState.getImage(Size(150, 150));
    this.resultImage.writeAsBytesSync(resultImage);
    this.resultImage2.writeAsBytesSync(resultImage2);

    final rImage1 = image.decodeImage(resultImage);
    final rImage2 = (image.decodeImage(resultImage2));
    final rImageOriginalCrop = image.decodeImage(this.imageResult.value);

    try {
      final result = await Process.run("cmd", ["/k", "hostname"]);
      final temp = result.stdout.toString().split("\n");
      String equipo = temp[0].replaceAll("\\r", "");
      final jpg1 = (image.encodeJpg(rImage1));
      final jpgOriginalCrop = image.encodeJpg(rImageOriginalCrop);
      this.resultImageJpg.writeAsBytesSync(jpg1);
      this.resultImageJpg2.writeAsBytesSync(image.encodeJpg(rImage2));

      this.resultOriginalCropImage.writeAsBytesSync(jpgOriginalCrop);
      final imgbase64 = base64Encode(_imageData);
      final orignalCrop64 = base64Encode(jpgOriginalCrop);
      final _targetImage = _fromByteData(_imageData);
      // final calculator = new _HorizontalCalculator();

      double _scala = 0;
      if (originalSize.width > originalSize.height) {
        _scala = originalSize.width / 800;
      } else {
        _scala = originalSize.height / 800;
      }
      // final body = {
      //   "imgbase64": imgbase64,
      //   "id_product": widget.product.toString(),
      //   "id_image": widget.images[selectedImage].idImage.toString(),
      //   "original_crop": orignalCrop64,
      //   "equipo": equipo,
      //   "derecha": areaValue.value.right.toString(),
      //   "izquierda": areaValue.value.left.toString(),
      //   "abajo": areaValue.value.bottom.toString(),
      //   "arriba": areaValue.value.top.toString(),
      //   "targetImage_width": _targetImage.width.toString(),
      //   "targetImage_height": _targetImage.height.toString(),
      //   "originalSize_width":
      //       originalSize.width.toString(), //igual que  targetImage_width
      //   "originalSize_height":
      //       originalSize.height.toString(), //igual que  targetImage_height
      //   "scala": _scala.toString(),
      //   "padding": paddingValue.toString()
      // };
      final bodyNew = {
        "imgbase64": imgbase64,
        "id_product": widget.product.toString(),
        "padding": paddingValue.toString(),
        "original_crop": orignalCrop64,
        "idImage": isNewImage
            ? "new"
            : widget.images[selectedImage].idImage.toString(),
        "position": isNewImage ? widget.images.length : selectedImage,
        "cover": 1 // TODO: revisar que valor debe mandarse en esta variable
      };
      print("ejecutando post");
      var endpoint = isNewImage? "/imagenes/add":"/imagenes/update";

      var response = await http.post(
        Uri.parse(
            "https://mueblesextraordinarios.com/app2/public/v1" + endpoint),
        body: json.encode(bodyNew),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      // ).then((response) {
      //   print("=================response===================");
      //   print(response.body);
      // }).catchError((error) {
      //   print(error.toString());
      // });
      print(response.body);
    } catch (e) {
      print(e.toString());
    }

    //resultKey.currentState.resetSize();

    if (openResultDialog) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text("Imágenes guardadas exitosamente"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Aceptar"),
                  )
                ],
              )).then(
        (value) => Navigator.pop(context),
      );
      return true;
    } else {
      Navigator.pop(context);
      return true;
    }
  }

  image.Image _fromByteData(Uint8List data) {
    final tempImage = image.decodeImage(data);
    assert(tempImage != null);

    // check orientation
    switch (tempImage?.exif.data[0x0112] ?? -1) {
      case 3:
        return image.copyRotate(tempImage, 180);
      case 6:
        return image.copyRotate(tempImage, 90);
      case 8:
        return image.copyRotate(tempImage, -90);
    }
    return tempImage;
  }

  void _descartadarImage(int index) async {
    final image = widget.images[index];
    image.descartada = image.descartada == 1 ? 0 : 1;
    setState(() {});
    // await MysqlSeverDataSource.instance
    //     .descartadarImage(idImage: image.idImage, descartada: image.descartada);
  }

  Future _addImage(BuildContext context) async {
    final file = OpenFilePicker()
      ..filterSpecification = {
        'Images (*.jpg; *.jpeg; *.png)': '*.jpg;*.jpeg;*.png',
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'jpg'
      ..title = 'Select a document';

    final result = file.getFile();

    if (result != null) {
      isNewImage = true;
      _imageData = result.readAsBytesSync();

      ui.Codec codec = await ui.instantiateImageCodec(_imageData);
      ui.FrameInfo fi = await codec.getNextFrame();
      final uiImage = fi.image;
      originalSize = Size(uiImage.width.toDouble(), uiImage.height.toDouble());

      // TODO:pendiente
      final id =
          1; //(await MysqlSeverDataSource.instance.getLastImageId()) + 1;

      addingImage = id;
      PsImage psImage = PsImage(
        idImage: id,
        idProduct: widget.product,
        position: widget.images.length,
        cover: null,
        padding: 0,
        descartada: 0,
        resolucionorigen:
            "${originalSize.width.toInt()}x${originalSize.height.toInt()}",
        resolucionrecorte: "0x0",
      );
      widget.images.add(psImage);
      selectedImage = widget.images.length - 1;
      final toUpdate = [widget.images.last];
      /*
      MysqlSeverDataSource.instance.updateImages(toUpdate).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Imágenes actualizadas correctamente"),
        ));
      });*/
      setState(() {
        downloadedImage = result;
        aspectRatio = null;
      });
      Future.microtask(() => setState(() {
            aspectRatio = 1;
          }));
      print(result.path);
    }
    isNewImage = false;
  }
}

class _HorizontalCalculator {
  const _HorizontalCalculator();

  Rect imageRect(Size screenSize, double imageRatio) {
    final imageScreenHeight = screenSize.width / imageRatio;
    final top = (screenSize.height - imageScreenHeight) / 2;
    final bottom = top + imageScreenHeight;
    return Rect.fromLTWH(0, top, screenSize.width, bottom - top);
  }

  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio) {
    final imageRatio = imageRect.width / imageRect.height;
    final imageScreenHeight = screenSize.width / imageRatio;

    final initialSize = imageRatio > aspectRatio
        ? Size((imageScreenHeight * aspectRatio) * sizeRatio,
            imageScreenHeight * sizeRatio)
        : Size(screenSize.width * sizeRatio,
            (screenSize.width / aspectRatio) * sizeRatio);

    return Rect.fromLTWH(
      (screenSize.width - initialSize.width) / 2,
      (screenSize.height - initialSize.height) / 2,
      initialSize.width,
      initialSize.height,
    );
  }

  double screenSizeRatio(image.Image targetImage, Size screenSize) {
    return targetImage.width / screenSize.width;
  }
}
