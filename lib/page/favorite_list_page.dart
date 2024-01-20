import 'package:flutter/material.dart';

class FavoriteListPage extends StatelessWidget {
  final void Function(Widget) invokeTap;
  final int type;
  const FavoriteListPage({this.type, Key key, this.invokeTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('收藏列表'),
    );
  }
}
