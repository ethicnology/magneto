import 'package:flutter/material.dart';
import 'package:magnetic/memory.dart';
import 'package:magnetic/utils.dart';
import 'package:magnetic/widgets/edit_torrent.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:transmission/transmission.dart';

class TorrentCompact extends StatefulWidget {
  final Transmission transmission;
  final Torrent torrent;
  const TorrentCompact(
      {super.key, required this.torrent, required this.transmission});

  @override
  State<TorrentCompact> createState() => _TorrentCompactState();
}

class _TorrentCompactState extends State<TorrentCompact> {
  var isVisible = false;
  var localData = false;

  @override
  Widget build(BuildContext context) {
    var progress = 0.0;
    var transmission = widget.transmission;
    var torrent = widget.torrent;
    var status = torrent.status;
    var ids = [torrent.hashString!];
    progress = torrent.percentComplete!;
    if (status == Status.verifying) progress = torrent.recheckProgress!;

    return InkWell(
      onTap: () => setState(() => isVisible = !isVisible),
      child: Card(
        child: Column(
          children: [
            InkWell(
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
            ),
            if (isVisible)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (torrent.status == Status.stopped)
                    IconButton(
                      onPressed: () => transmission.start(ids: ids),
                      icon: const Icon(Icons.play_circle),
                      color: Colors.green,
                    ),
                  if (torrent.status != Status.stopped)
                    IconButton(
                        onPressed: () => transmission.stop(ids: ids),
                        icon: getIcon(Status.stopped, tooltip: false),
                        color: Colors.amber),
                  IconButton(
                      onPressed: () => transmission.verify(ids: ids),
                      icon: const Icon(Icons.verified),
                      color: Colors.purpleAccent),
                  IconButton(
                      onPressed: () => transmission.reannounce(ids: ids),
                      icon: const Icon(Icons.campaign),
                      color: Colors.teal),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info),
                      color: Colors.blue),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => EditTorrent(
                            torrent: torrent,
                            directories: directories,
                            transmission: transmission,
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_square),
                      color: Colors.white),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: localData,
                                          onChanged: (bool? value) {
                                            setState(
                                                () => localData = !localData);
                                          },
                                        ),
                                        const Text('Delete Local Data'),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      transmission.remove(
                                        ids: ids,
                                        deleteLocalData: localData,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Remove'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.remove_circle),
                    color: Colors.redAccent,
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
