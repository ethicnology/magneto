import 'package:flutter/material.dart';
import 'package:magneto/memory.dart';
import 'package:magneto/utils.dart';
import 'package:transmission/transmission.dart';

class ActionsMany extends StatefulWidget {
  final List<Torrent> torrents;
  const ActionsMany({super.key, required this.torrents});

  @override
  State<ActionsMany> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ActionsMany> {
  bool removeLocalData = false;

  @override
  Widget build(BuildContext context) {
    var torrents = widget.torrents;
    var ids = [for (var t in torrents) t.hash!];
    var names = [for (var t in torrents) t.name!];

    return Card(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => transmission.torrent.start(ids: ids),
            icon: const Icon(Icons.play_circle_rounded),
            color: Colors.green,
          ),
          IconButton(
              onPressed: () => transmission.torrent.stop(ids: ids),
              icon: getIcon(Status.stopped, tooltip: false),
              color: Colors.amber),
          IconButton(
              onPressed: () => transmission.torrent.verify(ids: ids),
              icon: const Icon(Icons.verified_rounded),
              color: Colors.purpleAccent),
          IconButton(
              onPressed: () => transmission.torrent.reannounce(ids: ids),
              icon: const Icon(Icons.campaign_rounded),
              color: Colors.teal),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        title: Text('Remove ${ids.length} torrents'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Checkbox(
                                  value: removeLocalData,
                                  onChanged: (v) {
                                    setState(() =>
                                        removeLocalData = !removeLocalData);
                                  },
                                ),
                                const Text('Delete Local Data'),
                              ],
                            ),
                            SingleChildScrollView(
                              child: ListView.separated(
                                  separatorBuilder: (ctx, i) => const Divider(),
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: names.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Text(names[index]);
                                  }),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              transmission.torrent.remove(
                                ids: ids,
                                deleteLocalData: removeLocalData,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text('Remove ${ids.length}'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.remove_circle_rounded),
            color: Colors.redAccent,
          )
        ],
      ),
    );
  }
}
