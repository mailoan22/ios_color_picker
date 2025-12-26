import 'package:flutter/material.dart';
import 'package:ios_color_picker/custom_picker/pickers/area_picker.dart';
import 'package:ios_color_picker/custom_picker/pickers/grid_picker.dart';
import 'package:ios_color_picker/custom_picker/pickers/slider_picker/slider_picker.dart';
import 'package:ios_color_picker/custom_picker/shared.dart';
import 'color_observer.dart';
import 'helpers/cache_helper.dart';

class PickersSelectorRow extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;

  const PickersSelectorRow({super.key, required this.onColorChanged});

  @override
  State<PickersSelectorRow> createState() => _PickersSelectorRowState();
}

class _PickersSelectorRowState extends State<PickersSelectorRow> {
  int typeIndex = 0;
  final List<String> typeText = ["Grid", "Spectrum", "Sliders"];

  @override
  void initState() {
    (CacheHelper().getData(key: "selector_index") as Future<dynamic>)
        .then((onValue) {
      if (onValue != null && onValue is int) {
        setState(() {
          typeIndex = onValue;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    CacheHelper().setData(value: typeIndex, key: "selector_index");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(2),
          width: double.infinity,
          decoration: BoxDecoration(
              color: sliderColor,
              borderRadius: const BorderRadius.all(Radius.circular(15))),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Spacer(),
                        if (index != 2)
                          Container(
                              height: 29, width: 1, color: Color(0xff999999))
                        else
                          const SizedBox(height: 29, width: 1),
                      ],
                    ),
                  );
                }),
              ),
              AnimatedAlign(
                alignment: typeIndex == 0
                    ? Alignment.centerLeft
                    : typeIndex == 1
                        ? Alignment.center
                        : Alignment.centerRight,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: ((maxWidth(context) - 32) / 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: selectedSliderColor,
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ]),
                ),
              ),
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                      child: InkWell(
                    onTap: () {
                      setState(() {
                        typeIndex = index;
                      });
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              typeText[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
                }),
              ),
            ],
          ),
        ),
        if (typeIndex == 0)
          ValueListenableBuilder<Color>(
            valueListenable: colorController,
            builder: (context, color, child) {
              return GridPicker(onColorChanged: (v) {
                colorController.updateColor(v);
                widget.onColorChanged(colorController.value);
              });
            },
          ),
        if (typeIndex == 1)
          ValueListenableBuilder<Color>(
            valueListenable: colorController,
            builder: (context, color, child) {
              return AreaColorPicker(
                pickerColor: colorController.value,
                onColorChanged: (v) {
                  colorController.updateColor(v);
                  widget.onColorChanged(colorController.value);
                },
                paletteType: ColorsType.hslWithSaturation,
              );
            },
          ),
        if (typeIndex == 2)
          Container(
            height: componentsHeight(context),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            alignment: Alignment.topCenter,
            margin:
                const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 17),
            width: double.infinity,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: ValueListenableBuilder<Color>(
              valueListenable: colorController,
              builder: (context, color, child) {
                return SlidePicker(
                  enableAlpha: false,
                  pickerColor: color,
                  onColorChanged: (Color value) {
                    colorController.updateColor(value);
                    widget.onColorChanged(colorController.value);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
