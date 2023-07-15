import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/HeaderDialog.dart';
import 'package:wallywiz/components/CreateWallpaperProvider/JsonPropertyPicker.dart';
import 'package:wallywiz/components/shared/MarqueeText.dart';
import 'package:wallywiz/components/shared/page_window_title_bar.dart';
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
    final urlController = useTextEditingController(
      text: wallpaperSource?.isOfficial == true ? null : wallpaperSource?.url,
    );
    final jsonAccessorController =
        useTextEditingController(text: wallpaperSource?.jsonAccessor);

    final id = useMemoized(
        () => wallpaperSource?.id ?? uuid.v4(), [wallpaperSource?.id]);

    final logo = useState<String?>(null);
    final headers = useState<List<Map<String, String>>>(
      wallpaperSource?.headers.entries.map((e) {
            return Map.castFrom<String, dynamic, String, String>({
              "id": uuid.v4(),
              "name": e.key,
              "value": wallpaperSource?.isOfficial == true ? "" : e.value,
            });
          }).toList() ??
          [],
    );

    saveIcon() async {
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
    }

    return Scaffold(
      appBar: PageWindowTitleBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          )
        ],
        title: SizedBox(
          height: 25,
          child: MarqueeText(
            text: wallpaperSource != null
                ? "Update configuration of ${wallpaperSource?.name}"
                : "Add Wallpaper Provider",
            staticLimit: 23,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              if (wallpaperSource?.isOfficial != true)
                Center(
                  child: Column(
                    children: [
                      IconButton(
                        icon: wallpaperSource?.logoSource == null &&
                                logo.value == null
                            ? const Icon(Icons.add_photo_alternate)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: wallpaperSource!.logoSource
                                        .startsWith("http")
                                    ? Image.network(
                                        wallpaperSource!.logoSource,
                                      )
                                    : Image.file(
                                        File(
                                          logo.value ??
                                              wallpaperSource!.logoSource,
                                        ),
                                      ),
                              ),
                        iconSize:
                            wallpaperSource?.logoSource == null ? 70 : 100,
                        onPressed: saveIcon,
                      ),
                      Text(
                        "Logo",
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      const SizedBox(height: 20)
                    ],
                  ),
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
                onPressed: () async {
                  headers.value = [
                    ...headers.value,
                    await showDialog(
                        context: context,
                        builder: (context) => const HeaderDialog())
                  ];
                },
              ),
              ...headers.value.map((header) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("key: ${header["name"]}"),
                      Text("value: ${header["value"]}"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final updatedData = await showDialog(
                                context: context,
                                builder: (context) => HeaderDialog(
                                  id: header["id"],
                                  name: header["name"],
                                  value: header["value"],
                                ),
                              ) as Map<String, String>?;
                              if (updatedData == null) return;
                              headers.value = headers.value.map((h) {
                                if (h["id"] == header["id"]) {
                                  return updatedData;
                                }
                                return h;
                              }).toList();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              headers.value = headers.value
                                  .where(
                                    (h) => h["id"] != header["id"],
                                  )
                                  .toList();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: jsonAccessorController,
                      validator: ValidationBuilder()
                          .required("URL is required")
                          .build(),
                      decoration: const InputDecoration(
                        hintText: "e.g. data.photo",
                        labelText: "JSON property accessor",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.padding_outlined),
                    onPressed: () async {
                      final url = wallpaperSource?.isOfficial == true
                          ? wallpaperSource!.url
                          : urlController.value.text;
                      if (url.isNotEmpty &&
                          Uri.tryParse(url)?.hasAbsolutePath == true) {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => JsonPropertyPicker(
                            url: url,
                            headers: wallpaperSource?.isOfficial == true
                                ? wallpaperSource!.headers
                                : headers.value.fold(
                                    {},
                                    (acc, val) {
                                      acc[val["name"] as String] = val["value"];
                                      return acc;
                                    },
                                  ),
                          ),
                        );
                        if (result == null) return;
                        jsonAccessorController.text = result;
                      } else {
                        formKey.currentState?.validate();
                      }
                    },
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      child: Text(wallpaperSource != null ? "Update" : 'Add'),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final source = WallpaperSource(
                            isOfficial: false,
                            id: id,
                            jsonAccessor: jsonAccessorController.value.text,
                            name: nameController.value.text,
                            url: urlController.value.text,
                            logoSource: logo.value,
                            headers: headers.value.fold(
                              {},
                              (acc, val) {
                                acc[val["name"] as String] = val["value"];
                                return acc;
                              },
                            ),
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
