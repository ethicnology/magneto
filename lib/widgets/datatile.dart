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

    return SizedBox(
      width: boxWidth,
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}
