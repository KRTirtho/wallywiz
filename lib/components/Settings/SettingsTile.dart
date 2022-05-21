import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  const SettingsTile({required this.title, required this.trailing, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: trailing,
    );
  }
}
