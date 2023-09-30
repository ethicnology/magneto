import 'package:flutter/material.dart';
import 'package:magnetic/widgets/datatile.dart';
import 'package:transmission/transmission.dart';

class TorrentWidget extends StatefulWidget {
  final Torrent torrent;

  const TorrentWidget({super.key, required this.torrent});

  @override
  State<TorrentWidget> createState() => _TorrentWidgetState();
}

class _TorrentWidgetState extends State<TorrentWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(widget.torrent.name ?? ''),
            trailing: InkWell(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Icon(isExpanded ? Icons.remove : Icons.add),
            ),
          ),
          if (isExpanded)
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceAround,
              children: [
                DataTile(title: 'id', value: widget.torrent.id),
                DataTile(title: 'status', value: widget.torrent.status),
                DataTile(
                    title: 'downloadDir', value: widget.torrent.downloadDir),
                DataTile(title: 'error', value: widget.torrent.error),
                DataTile(
                    title: 'errorString', value: widget.torrent.errorString),
                DataTile(title: 'eta', value: widget.torrent.eta),
                DataTile(title: 'isFinished', value: widget.torrent.isFinished),
                DataTile(title: 'isStalled', value: widget.torrent.isStalled),
                DataTile(
                    title: 'leftUntilDone',
                    value: widget.torrent.leftUntilDone),
                DataTile(
                    title: 'metadataPercentComplete',
                    value: widget.torrent.metadataPercentComplete),
                DataTile(
                    title: 'peersConnected',
                    value: widget.torrent.peersConnected),
                DataTile(
                    title: 'peersGettingFromUs',
                    value: widget.torrent.peersGettingFromUs),
                DataTile(
                    title: 'peersSendingToUs',
                    value: widget.torrent.peersSendingToUs),
                DataTile(
                    title: 'percentDone', value: widget.torrent.percentDone),
                DataTile(
                    title: 'queuePosition',
                    value: widget.torrent.queuePosition),
                DataTile(
                    title: 'rateDownload', value: widget.torrent.rateDownload),
                DataTile(title: 'rateUpload', value: widget.torrent.rateUpload),
                DataTile(
                    title: 'sizeWhenDone', value: widget.torrent.sizeWhenDone),
                DataTile(title: 'totalSize', value: widget.torrent.totalSize),
              ],
            )
        ],
      ),
    );
  }
}
