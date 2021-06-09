import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool isPassword;
  final Widget prefixIcon;
  final Color color;
  final bool estextoPrestashop;
  final bool codigoEan;
  final bool soloentero;
  final Color fillColor;
  final bool autoFocus;
  final TextInputAction textInputAction;
  final Color borderColor;
  final FocusNode focusNode;
  final FocusNode nextFocus;
  final EdgeInsets padding;
  final VoidCallback onEditingComplete;
  final double radius;
  final bool square;
  final bool enabled;
  final bool readOnly;
  final Widget suffixWidget;
  final bool requiredField;
  final int maxLines;
  final GestureTapCallback onTap;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextStyle style;
  final FormFieldSetter<String> onSaved;
  final String strHintText;
  final int maxLength;
  final bool esPedidoMinimo;
  final double elevation;
  final TextAlign textAlign;
  final bool esUrl;
  ValueNotifier<bool> showPassword;
  FormFieldValidator<String> validator;

  MyTextField(
      {this.controller,
      this.onTap,
      this.initialValue,
      this.suffixWidget,
      this.onChanged,
      this.radius = 5,
      this.autoFocus = false,
      this.square = false,
      this.elevation = 5,
      this.textInputAction,
      this.enabled,
      this.readOnly = false,
      this.padding,
      this.style,
      this.estextoPrestashop = false,
      this.codigoEan = false,
      this.esUrl = false,
      this.esPedidoMinimo = false,
      this.soloentero = false,
      this.borderColor,
      this.maxLines = 1,
      this.onEditingComplete,
      this.labelText,
      this.keyboardType,
      this.nextFocus,
      this.focusNode,
      this.onSaved,
      this.requiredField = false,
      this.hintText,
      this.prefixIcon,
      this.showPassword,
      this.validator,
      this.isPassword = false,
      this.color,
      this.fillColor,
      this.strHintText,
      this.maxLength,
      Key key,
      this.textAlign = TextAlign.left})
      : super(key: key) {
    if (showPassword == null) {
      showPassword = ValueNotifier<bool>(false);
    }
  }

  String _validator(
    String value,
  ) {
    if (value.isEmpty) {
      return "Campo obligatorio";
    }
    return null;
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return "Correo inválido";
    else
      return null;
  }

  String validateTelephone(String value) {
    Pattern pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return "Teléfono inválido";
    } else if (!regex.hasMatch(value)) {
      return "Teléfono inválido";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    String name = "";

    if (validator == null) {
      if (esPedidoMinimo) {
        validator = (String value) {
          if (double.tryParse(value) == null) {
            return "Indica el pedido mínimo";
          } else {
            double codigonumero = double.tryParse(value);
            if (codigonumero != codigonumero.roundToDouble()) {
              return "El pedido minimo no tiene decimales";
            }
          }

          return null;
        };
      }
      if (esUrl) {
        validator = (String value) {
          Pattern pattern = r'^([a-zA-Z0-9\-\_])+$';
          RegExp regex = new RegExp(pattern);
          if (!regex.hasMatch(value))
            return "Solo se admiten letras, numeros, - y _";
          else
            return null;
        };
      }
      if (estextoPrestashop) {
        bool _haycaracteres = false;
        validator = (String _value) {
          List<String> listaa = ['<', '>', ';', '=', '#', '{', '}'];
          listaa.forEach((item) {
            if (_value.contains(item)) {
              _haycaracteres = true;
            }
          });
          if (_haycaracteres) {
            return "No se admiten < > ; = # { }";
          }
          return null;
        };
      }
      if (soloentero) {
        validator = (String value) {
          if (value == "") {
            return "No puede estar en blanco";
          } else {
            if (double.tryParse(value) == null) {
              return "Solo se admiten numeros enteros";
            } else {
              double codigonumero = double.tryParse(value);
              if (codigonumero != codigonumero.roundToDouble()) {
                return "No se admiten decimales";
              }
            }
          }
          return null;
        };
      }
      if (codigoEan) {
        validator = (String value) {
          if (value == "") {
            return null;
          } else {
            if (value.length != 13) {
              return "Código de barras incompleto";
            } else {
              if (double.tryParse(value) == null) {
                return "Codigo de barra son 13 digitos";
              } else {
                double codigonumero = double.tryParse(value);
                if (codigonumero != codigonumero.roundToDouble()) {
                  return "Codigo de barras no tiene decimales";
                }
              }
            }
          }
          return null;
        };
      }
      if (keyboardType != null) {
        name = keyboardType?.toJson()["name"];
      }
      if (keyboardType == TextInputType.emailAddress) {
        validator = validateEmail;
      } else if (keyboardType == TextInputType.phone) {
        //validator = validateTelephone;
      } else if (name == "TextInputType.number") {
        validator = (String value) {
          final result = double.tryParse(value);
          if (result != null ||
              result == double.nan ||
              result == double.infinity) {
            if (result < 0 && !keyboardType.signed) {
              return "Número inválido";
            }
            return null;
          }
          return "Número inválido";
        };
      }
    }

    InputBorder border = radius != null
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: borderColor ?? Theme.of(context).primaryColor,
            ))
        : null;
    border = square
        ? OutlineInputBorder(
            borderSide: BorderSide(
            color: borderColor ?? Theme.of(context).primaryColor,
          ))
        : border;
    final child = ValueListenableBuilder(
        valueListenable: this.showPassword,
        builder: (context, value, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onTap: onTap,
              textAlign: textAlign,
              autofocus: autoFocus,
              obscureText: (isPassword) ? (!value) : false,
              keyboardType: keyboardType,
              onChanged: onChanged,
              controller: controller,
              focusNode: focusNode,
              maxLength: maxLength,
              initialValue: initialValue,
              validator: requiredField
                  ? validator != null
                      ? (value) {
                          value = value.trim();
                          controller?.text = value;
                          return validator(value);
                        }
                      : (value) {
                          value = value.trim();
                          controller?.text = value;
                          return _validator(
                            value,
                          );
                        }
                  : null,
              onEditingComplete: nextFocus != null
                  ? () {
                      FocusScope.of(context).requestFocus(nextFocus);
                    }
                  : () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      onEditingComplete();
                    },
              textInputAction:
                  nextFocus != null ? TextInputAction.next : textInputAction,
              enabled: enabled,
              readOnly: readOnly,
              onSaved: (value) {
                onSaved(value);
              },
              maxLines: maxLines,
              style: style,
              decoration: InputDecoration(
                  fillColor: fillColor,
                  filled: fillColor != null,
                  suffixIcon: suffixWidget,
                  border: border,
                  disabledBorder: border,
                  enabledBorder: border,
                  errorBorder: border,
                  focusedErrorBorder: border,
                  focusedBorder: border,
                  hintText: hintText != null ? hintText : strHintText,
                  labelText: labelText != null ? labelText : null,
                  prefixIcon: prefixIcon,
                  suffix: (isPassword)
                      ? GestureDetector(
                          child: Icon(
                              value ? Icons.visibility_off : Icons.visibility),
                          onTap: () {
                            showPassword.value = !showPassword.value;
                          })
                      : null,
                  labelStyle: TextStyle(
                    fontSize: 18,
                    backgroundColor: Colors.white,
                  )),
            ),
          );
        });

    return (padding != null)
        ? Padding(
            child: elevation > 0
                ? Card(
                    child: child,
                    elevation: elevation,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius)),
                  )
                : child,
            padding: padding,
          )
        : child;
  }
}
