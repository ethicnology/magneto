import 'package:flutter/material.dart';
import 'package:transmission/transmission.dart';

class DownloadStats extends StatelessWidget {
  final Torrent torrent;
  const DownloadStats({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (torrent.rateUpload != null && torrent.rateUpload! > 0)
          Row(
            children: [
              Text('${torrent.peersGettingFromUs}'),
              const Icon(Icons.arrow_circle_up),
              Text('${torrent.prettyRateUpload}'),
            ],
          ),
        if (torrent.rateDownload != null && torrent.rateDownload! > 0)
          Row(
            children: [
              Text('${torrent.peersSendingToUs}'),
              const Icon(Icons.arrow_circle_down),
              Text('${torrent.prettyRateDownload}'),
            ],
          ),
      ],
    );
  }
}
