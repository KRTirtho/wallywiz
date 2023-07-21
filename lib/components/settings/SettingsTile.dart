import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final Widget trailing;
  final Widget? leading;
  const SettingsTile({
    required this.title,
    required this.trailing,
    Key? key,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      trailing: trailing,
    );
  }
}
