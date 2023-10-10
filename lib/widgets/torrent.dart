import 'package:flutter/material.dart';
import 'package:magnetic/widgets/datatile.dart';
import 'package:magnetic/widgets/edit_torrent.dart';
import 'package:transmission/transmission.dart';

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

class TorrentWidget extends StatefulWidget {
  final Transmission transmission;
  final Torrent torrent;

  const TorrentWidget(
      {Key? key, required this.transmission, required this.torrent})
      : super(key: key);

  @override
  State<TorrentWidget> createState() => _TorrentWidgetState();
}

class _TorrentWidgetState extends State<TorrentWidget> {
  bool isLoading = false;
  bool isExpanded = false;
  bool isEdited = false;
  late Torrent torrent;

  reloadTorrent() async {
    setState(() => isLoading = true);
    var torrents =
        await widget.transmission.getTorrents(ids: [widget.torrent.hash!]);
    torrent = torrents.first;
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    torrent = widget.torrent;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    } else {
      return Card(
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: ListTile(
                leading: InkWell(
                  onTap: () => reloadTorrent(),
                  child: const Icon(Icons.autorenew),
                ),
                title: Text(torrent.name!),
                trailing: InkWell(
                  onTap: () {
                    showBottomSheet(
                        context: context,
                        builder: (context) => EditTorrent(
                              torrent: torrent,
                              transmission: widget.transmission,
                            ));
                  },
                  child: Icon(isEdited ? Icons.cancel : Icons.edit),
                ),
              ),
            ),
            if (isExpanded)
              Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceEvenly,
                children: keys.map((key) {
                  final value = torrent[key];
                  return Card(
                    color: Colors.deepPurple[800],
                    child: SizedBox(
                      width: 150,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTile(title: key, value: value),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    }
  }
}
