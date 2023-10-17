import 'package:flutter/material.dart';
import 'package:magnetic/utils.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:transmission/transmission.dart';

class TorrentCompact extends StatefulWidget {
  final Torrent torrent;
  final bool isSelected;
  const TorrentCompact(
      {super.key, required this.torrent, this.isSelected = false});

  @override
  State<TorrentCompact> createState() => _TorrentCompactState();
}

class _TorrentCompactState extends State<TorrentCompact> {
  var isVisible = false;
  var localData = false;

  @override
  Widget build(BuildContext context) {
    var progress = 0.0;
    var torrent = widget.torrent;
    var status = torrent.status;
    progress = torrent.percentComplete!;
    if (status == Status.verifying) progress = torrent.recheckProgress!;

    return Expanded(
      child: ListTile(
        leading: getIcon(torrent.status),
        title: Text(torrent.name!),
        trailing: SizedBox(
          width: 25,
          child: CircularPercentIndicator(
            radius: 13.0,
            lineWidth: 2,
            percent: progress,
            center: Text(
              '${(progress * 100).toInt()}',
              style: const TextStyle(fontSize: 10),
            ),
            progressColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
