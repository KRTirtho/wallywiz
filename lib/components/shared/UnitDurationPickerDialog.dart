import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wallywiz/collections/min_max.dart';
import 'package:wallywiz/extensions/constrains.dart';

class UnitDurationPickerDialog extends HookWidget {
  final Duration initialDuration;
  const UnitDurationPickerDialog({
    Key? key,
    this.initialDuration = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = useState<Duration>(initialDuration);
    final baseUnit = useState<BaseUnit>(BaseUnit.hour);
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flex(
          direction: mediaQuery.smAndDown ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            DurationPicker(
              onChange: (value) {
                if (value > kMaximumDuration) return;
                duration.value = value;
              },
              duration: duration.value,
              baseUnit: baseUnit.value,
            ),
            const SizedBox.square(dimension: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Base Unit",
                      style: textTheme.labelLarge,
                    ),
                    const SizedBox(height: 5, width: 5),
                    ToggleButtons(
                      borderRadius: BorderRadius.circular(10),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Hour"),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Minute"),
                        ),
                      ],
                      isSelected: [
                        baseUnit.value == BaseUnit.hour,
                        baseUnit.value == BaseUnit.minute,
                      ],
                      onPressed: (index) {
                        baseUnit.value =
                            index == 0 ? BaseUnit.hour : BaseUnit.minute;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      child: const Text("Save"),
                      onPressed: !isValidDuration(duration.value)
                          ? null
                          : () {
                              Navigator.of(context).pop(duration.value);
                            },
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
