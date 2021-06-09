import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final VoidCallback onPressed;
  const MenuItem(
      {Key key,
      @required this.icon,
      @required this.onPressed,
      @required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: icon,
                  ),
                  Expanded(child: title)
                ],
              ),
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
