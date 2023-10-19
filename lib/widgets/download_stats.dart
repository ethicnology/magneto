import 'package:flutter/material.dart';
import 'package:transmission/transmission.dart';

class DownloadStats extends StatelessWidget {
  final Torrent torrent;
  const DownloadStats({super.key, required this.torrent});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        if (torrent.rateUpload != null && torrent.peersGettingFromUs! > 0)
          SizedBox(
            width: 250,
            child: Card(
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.arrow_circle_up_rounded,
                      color: Colors.green),
                  Text('${torrent.peersGettingFromUs}'),
                  const Text(' | '),
                  if (torrent.rateUpload! > 0)
                    Text('${torrent.prettyRateUpload}'),
                  if (torrent.rateUpload! == 0) const Text('0'),
                ],
              ),
            ),
          ),
        if (torrent.rateDownload != null && torrent.peersSendingToUs! > 0)
          SizedBox(
            width: 250,
            child: Card(
              color: Colors.black87,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.arrow_circle_down_rounded,
                      color: Colors.blue),
                  Text('${torrent.peersSendingToUs}'),
                  const Text(' | '),
                  if (torrent.rateDownload! > 0)
                    Text('${torrent.prettyRateDownload}'),
                  if (torrent.rateDownload! == 0) const Text('0'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
