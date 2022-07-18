import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/CreateWallpaperProviderView.dart';

class HeaderDialog extends HookWidget {
  final String? name;
  final String? value;
  final String? id;
  const HeaderDialog({
    this.name,
    this.value,
    this.id,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController(text: name);
    final valueController = useTextEditingController(text: value);

    return AlertDialog(
      title: Text(
        "${name != null || value != null ? "Edit" : "Add"} a Header",
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Header Name",
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(
                    hintText: "Header Value",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop({
                "id": id ?? uuid.v4(),
                "name": nameController.value.text,
                "value": valueController.value.text,
              });
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
