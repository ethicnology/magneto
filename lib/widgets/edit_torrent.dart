import 'package:flutter/material.dart';
import 'package:magneto/models/global.dart';
import 'package:provider/provider.dart';
import 'package:transmission/transmission.dart';

class EditTorrent extends StatefulWidget {
  final Torrent torrent;
  const EditTorrent({super.key, required this.torrent});

  @override
  State<EditTorrent> createState() => _EditTorrentState();
}

class _EditTorrentState extends State<EditTorrent> {
  String? location;

  @override
  void initState() {
    location = widget.torrent.downloadDir!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var global = Provider.of<Global>(context, listen: true);
    var transmission = global.transmission;
    var torrent = widget.torrent;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text('Edit torrents'),
          FloatingActionButton.small(
            onPressed: () async {
              var ids = [torrent.hash!];
              if (location != torrent.downloadDir) {
                transmission.torrent
                    .move(ids: ids, location: location!, move: true);
              }
              await transmission.torrent.set(
                ids: ids,
                trackerList: torrent.trackerList,
              );
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Icon(Icons.save_rounded),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: 200,
              child: DropdownButton<String>(
                value: location,
                isExpanded: true,
                onChanged: (value) => setState(() => location = value!),
                items:
                    global.directories.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: 200,
              child: Card(
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      onPressed: () {
                        setState(() => torrent.trackerList?.add(''));
                      },
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      height: torrent.trackerList!.length * 65,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: torrent.trackerList?.length,
                        itemBuilder: (context, index) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: torrent.trackerList?[index]),
                                    onChanged: (text) {
                                      setState(() => widget
                                          .torrent.trackerList?[index] = text);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_rounded),
                                  onPressed: () {
                                    setState(() =>
                                        torrent.trackerList?.removeAt(index));
                                  },
                                ),
                              ]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
