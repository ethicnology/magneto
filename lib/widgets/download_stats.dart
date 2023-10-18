import 'package:flutter/material.dart';
import 'package:transmission/transmission.dart';

class DownloadStats extends StatelessWidget {
  final Torrent torrent;
  const DownloadStats({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (torrent.rateUpload != null && torrent.rateUpload! > 0)
          Card(
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.arrow_circle_up, color: Colors.green),
                Text('${torrent.peersGettingFromUs}'),
                Text('${torrent.prettyRateUpload}'),
              ],
            ),
          ),
        if (torrent.rateDownload != null && torrent.rateDownload! > 0)
          Row(
            children: [
              const Icon(Icons.arrow_circle_down, color: Colors.blue),
              Text('${torrent.peersSendingToUs}'),
              const Text(' | '),
              Text('${torrent.prettyRateDownload}'),
            ],
          ),
      ],
    );
  }
}
