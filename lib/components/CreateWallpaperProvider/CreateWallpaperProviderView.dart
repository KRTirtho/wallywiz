import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';
import 'package:path/path.dart' as path;

const uuid = Uuid();

class CreateWallpaperProviderView extends HookConsumerWidget {
  final formKey = GlobalKey<FormState>();
  final WallpaperSource? wallpaperSource;
  CreateWallpaperProviderView({
    Key? key,
    this.wallpaperSource,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final wp = ref.watch(wallpaperProvider);
    final imagePicker = useMemoized(() => ImagePicker(), []);

    final nameController =
        useTextEditingController(text: wallpaperSource?.name);
    final urlController = useTextEditingController(text: wallpaperSource?.url);
    final jsonAccessorController =
        useTextEditingController(text: wallpaperSource?.jsonAccessor);

    final id = useMemoized(
        () => wallpaperSource?.id ?? uuid.v4(), [wallpaperSource?.id]);

    final logo = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          )
        ],
        title: const Text("Add Wallpaper Provider"),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate),
                onPressed: () async {
                  final logoXFile = await imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (logoXFile == null) return;
                  final localPath = path.join(
                    (await getApplicationDocumentsDirectory()).path,
                    path.basename(logoXFile.path),
                  );
                  await logoXFile.saveTo(localPath);
                  logo.value = localPath;
                },
              ),
              TextFormField(
                controller: nameController,
                validator:
                    ValidationBuilder().required("URL is required").build(),
                decoration: const InputDecoration(
                  labelText: "Name of service",
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: urlController,
                validator: ValidationBuilder()
                    .url()
                    .required("URL is required")
                    .build(),
                decoration: const InputDecoration(
                  hintText:
                      "e.g. https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=en-US",
                  labelText: "API URL",
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text("New Header"),
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: jsonAccessorController,
                validator:
                    ValidationBuilder().required("URL is required").build(),
                decoration: const InputDecoration(
                  hintText: "e.g. data.photo",
                  labelText: "JSON property accessor",
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text(wallpaperSource != null ? "Update" : 'Add'),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final source = WallpaperSource(
                            id: id,
                            jsonAccessor: jsonAccessorController.value.text,
                            name: nameController.value.text,
                            url: urlController.value.text,
                            logoSource: logo.value,
                          );
                          if (wallpaperSource == null) {
                            wp.addWallpaperSource(source);
                          } else {
                            wp.updateWallpaperSource(id, source);
                          }
                          formKey.currentState?.reset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                "${wallpaperSource != null ? "Updated" : "Added"} ${nameController.value.text} as Service",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
