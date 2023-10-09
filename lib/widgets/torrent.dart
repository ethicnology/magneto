import 'package:flutter/material.dart';
import 'package:magnetic/widgets/datatile.dart';
import 'package:magnetic/widgets/edit_torrent.dart';
import 'package:transmission/transmission.dart';

class TorrentWidget extends StatefulWidget {
  final Transmission transmission;
  final Torrent torrent;

  const TorrentWidget(
      {Key? key, required this.torrent, required this.transmission})
      : super(key: key);

  @override
  State<TorrentWidget> createState() => _TorrentWidgetState();
}

class _TorrentWidgetState extends State<TorrentWidget> {
  bool isExpanded = false;
  bool isEdited = false;

  @override
  Widget build(BuildContext context) {
    const List<String> keys = [
      "activityDate",
      "addedDate",
      "availability",
      "bandwidthPriority",
      "comment",
      "corruptEver",
      "creator",
      "dateCreated",
      "desiredAvailable",
      "doneDate",
      "downloadDir",
      "downloadedEver",
      "downloadLimit",
      "downloadLimited",
      "editDate",
      "error",
      "errorString",
      "eta",
      "etaIdle",
      "file-count",
      "files",
      "fileStats",
      "group",
      "hashString",
      "haveUnchecked",
      "haveValid",
      "honorsSessionLimits",
      "id",
      "isFinished",
      "isPrivate",
      "isStalled",
      "labels",
      "leftUntilDone",
      "magnetLink",
      "manualAnnounceTime",
      "maxConnectedPeers",
      "metadataPercentComplete",
      "name",
      "peer-limit",
      "peers",
      "peersConnected",
      "peersFrom",
      "peersGettingFromUs",
      "peersSendingToUs",
      "percentComplete",
      "percentDone",
      "pieces",
      "pieceCount",
      "pieceSize",
      "priorities",
      "primary-mime-type",
      "queuePosition",
      "rateDownload (B/s)",
      "rateUpload (B/s)",
      "recheckProgress",
      "secondsDownloading",
      "secondsSeeding",
      "seedIdleLimit",
      "seedIdleMode",
      "seedRatioLimit",
      "seedRatioMode",
      "sequentialDownload",
      "sizeWhenDone",
      "startDate",
      "status",
      "trackers",
      "trackerList",
      "trackerStats",
      "totalSize",
      "torrentFile",
      "uploadedEver",
      "uploadLimit",
      "uploadLimited",
      "uploadRatio",
      "wanted",
      "webseeds",
      "webseedsSendingToUs",
    ];

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: InkWell(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Icon(isExpanded ? Icons.remove : Icons.add),
            ),
            title: Text(widget.torrent.name ?? ''),
            trailing: InkWell(
              onTap: () {
                showBottomSheet(
                    context: context,
                    builder: (context) => EditTorrent(
                          torrent: widget.torrent,
                          transmission: widget.transmission,
                        ));
              },
              child: Icon(isEdited ? Icons.cancel : Icons.edit),
            ),
          ),
          if (isExpanded)
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceAround,
              children: keys.map((key) {
                final value = widget.torrent[key];
                return DataTile(title: key, value: value);
              }).toList(),
            ),
        ],
      ),
    );
  }
}
