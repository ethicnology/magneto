import 'package:flutter/material.dart';
import 'package:magneto/memory.dart';
import 'package:magneto/utils.dart';
import 'package:transmission/transmission.dart';

class ActionsMany extends StatefulWidget {
  final List<String> ids;
  const ActionsMany({super.key, required this.ids});

  @override
  State<ActionsMany> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ActionsMany> {
  bool removeLocalData = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () => transmission.torrent.start(ids: widget.ids),
            icon: const Icon(Icons.play_circle),
            color: Colors.green,
          ),
          IconButton(
              onPressed: () => transmission.torrent.stop(ids: widget.ids),
              icon: getIcon(Status.stopped, tooltip: false),
              color: Colors.amber),
          IconButton(
              onPressed: () => transmission.torrent.verify(ids: widget.ids),
              icon: const Icon(Icons.verified),
              color: Colors.purpleAccent),
          IconButton(
              onPressed: () => transmission.torrent.reannounce(ids: widget.ids),
              icon: const Icon(Icons.campaign),
              color: Colors.teal),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return AlertDialog(
                        title: Text('Remove ${widget.ids.length} torrents'),
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
                                ids: widget.ids,
                                deleteLocalData: removeLocalData,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Text('Remove ${widget.ids.length}'),
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
      ),
    );
  }
}
