import 'package:flutter/material.dart';
import 'package:magneto/models/global.dart';
import 'package:magneto/utils.dart';
import 'package:provider/provider.dart';
import 'package:transmission/transmission.dart';

class ActionsMany extends StatefulWidget {
  final List<Torrent> torrents;
  const ActionsMany({super.key, required this.torrents});

  @override
  State<ActionsMany> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ActionsMany> {
  bool localData = false;

  @override
  Widget build(BuildContext context) {
    var global = Provider.of<Global>(context, listen: true);
    var transmission = global.transmission;
    var torrents = widget.torrents;
    var ids = [for (var t in torrents) t.hash!];
    var names = [for (var t in torrents) t.name!];

    void onPressed(Future<void> function) {
      function;
      global.clearSelection();
    }

    return Card(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => onPressed(transmission.torrent.start(ids: ids)),
            icon: const Tooltip(
              message: 'Start',
              child: Icon(Icons.play_circle_rounded),
            ),
            color: Colors.green,
          ),
          IconButton(
              onPressed: () => onPressed(transmission.torrent.stop(ids: ids)),
              icon: Tooltip(
                message: 'Stop',
                child: getIcon(Status.stopped, tooltip: false),
              ),
              color: Colors.amber),
          IconButton(
              onPressed: () => onPressed(transmission.torrent.verify(ids: ids)),
              icon: const Tooltip(
                message: 'Verify',
                child: Icon(Icons.verified_rounded),
              ),
              color: Colors.purpleAccent),
          IconButton(
              onPressed: () =>
                  onPressed(transmission.torrent.reannounce(ids: ids)),
              icon: const Tooltip(
                message: 'Announce',
                child: Icon(Icons.campaign_rounded),
              ),
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
                            InkWell(
                              onTap: () =>
                                  setState(() => localData = !localData),
                              child: Row(
                                children: <Widget>[
                                  Transform.scale(
                                    scale: 0.6,
                                    child: Switch(
                                      value: localData,
                                      onChanged: (v) => setState(
                                          () => localData = !localData),
                                    ),
                                  ),
                                  const Text('Delete Local Data'),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 100,
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
                              onPressed(transmission.torrent.remove(
                                  ids: ids, deleteLocalData: localData));
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
            icon: const Tooltip(
              message: 'Remove',
              child: Icon(Icons.remove_circle_rounded),
            ),
            color: Colors.redAccent,
          )
        ],
      ),
    );
  }
}
