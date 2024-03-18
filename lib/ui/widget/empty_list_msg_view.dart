import 'package:flutter/material.dart';
import 'package:wos/page/fonticons_icons.dart';
import 'package:wos/utils.dart';
import 'package:wos/wos_theme.dart';

class EmptyListMsgView extends StatelessWidget {
  final Widget text;
  final IconData icon;
  final double iconSize;
  const EmptyListMsgView({Key key, this.text, this.icon, this.iconSize = 128})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon ?? FIcons.frown,
                  size: iconSize,
                  color: Theme.of(context).primaryColorDark.withOpacity(0.08)),
              SizedBox(height: 12),
              DefaultTextStyle(
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .color
                        .withAlpha(50),
                    fontFamily: WOSTheme.staticFontFamily),
                child: text,
              ),
            ],
          ),
        ),
        onTap: () => Utils.unFocus(context));
  }
}
