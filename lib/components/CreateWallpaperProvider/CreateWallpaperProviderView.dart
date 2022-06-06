import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_validator/form_validator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wallywiz/models/WallpaperSource.dart';
import 'package:wallywiz/providers/wallpaper-provider.dart';

const uuid = Uuid();

class CreateWallpaperProviderDialog extends HookConsumerWidget {
  final formKey = GlobalKey<FormState>();
  CreateWallpaperProviderDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final headerFields = useState([uuid.v4()]);
    final wp = ref.watch(wallpaperProvider);

    final nameController = useTextEditingController();
    final urlController = useTextEditingController();
    final jsonAccessorController = useTextEditingController();
    final headerControllers = useState({});

    final id = useMemoized(() => uuid.v4());
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
                onPressed: () {
                  headerFields.value = [
                    ...headerFields.value,
                    uuid.v4(),
                  ];
                },
              ),
              const SizedBox(height: 10),
              ...headerFields.value.map((id) {
                return HookBuilder(
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Flexible(child: TextFormField(
                            onChanged: (value) {
                              headerControllers.value = {
                                ...headerControllers.value,
                                id: {
                                  ...headerControllers.value[id],
                                  "key": value
                                }
                              };
                            },
                          )),
                          const SizedBox(width: 10),
                          Flexible(child: TextFormField(
                            onChanged: (value) {
                              headerControllers.value = {
                                ...headerControllers.value,
                                id: {
                                  ...headerControllers.value[id],
                                  "value": value
                                }
                              };
                            },
                          )),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                            color: Colors.red[300],
                            onPressed: () {
                              final prev = headerControllers.value;
                              prev.remove(id);
                              headerControllers.value = prev;
                              headerFields.value = headerFields.value
                                  .where((element) => element != id)
                                  .toList();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
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
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          wp.addWallpaperSource(WallpaperSource(
                            id: id,
                            jsonAccessor: jsonAccessorController.value.text,
                            name: nameController.value.text,
                            url: urlController.value.text,
                          ));
                          formKey.currentState?.reset();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                "Added ${nameController.value.text} as Service",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Add'),
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
