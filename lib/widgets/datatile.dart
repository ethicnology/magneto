import 'package:flutter/material.dart';

class DataTile extends StatelessWidget {
  final double? width;
  final double? height;
  final String title;
  final dynamic value;
  final Color backgroundColor;
  final String titleTooltip;
  final String valueTooltip;
  final IconData titleIconTooltip;
  final IconData valueIconTooltip;
  final bool format;

  const DataTile({
    super.key,
    required this.title,
    required this.value,
    this.titleTooltip = '',
    this.valueTooltip = '',
    this.backgroundColor = Colors.black,
    this.titleIconTooltip = Icons.help,
    this.valueIconTooltip = Icons.help,
    this.width,
    this.height,
    this.format = true,
  });

  @override
  Widget build(BuildContext context) {
    var boxWidth = width ?? (title.length * 11);
    var data = value.toString();

    // Truncate the data value and add a tooltip if it's longer than the width
    if (data.length > title.length) {
      data = '${data.substring(0, title.length - 3)}…';
    }

    return SizedBox(
      width: boxWidth,
      height: height,
      child: Column(
        children: [
          Row(
            children: [
              if (titleTooltip.isNotEmpty)
                Tooltip(
                  message: titleTooltip,
                  child: Icon(titleIconTooltip, size: 16, color: Colors.blue),
                ),
              const SizedBox(width: 4),
              Text(title),
            ],
          ),
          Row(
            children: [
              if (valueTooltip.isNotEmpty)
                Tooltip(
                  message: valueTooltip,
                  child: Icon(valueIconTooltip, size: 16, color: Colors.blue),
                ),
              const SizedBox(width: 4),
              Text(data),
            ],
          ),
        ],
      ),
    );
  }
}
