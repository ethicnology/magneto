import 'package:flutter/material.dart';
import 'package:transmission/transmission.dart';

class EditTorrent extends StatefulWidget {
  final Transmission transmission;
  final Torrent torrent;
  final List<String> directories;
  const EditTorrent({
    super.key,
    required this.torrent,
    required this.transmission,
    required this.directories,
  });

  @override
  State<EditTorrent> createState() => _EditTorrentState();
}

class _EditTorrentState extends State<EditTorrent> {
  final _formKey = GlobalKey<FormState>();
  String? location;

  @override
  void initState() {
    location = widget.torrent.downloadDir!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var torrent = widget.torrent;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton<String>(
                  value: location,
                  onChanged: (value) => setState(() => location = value!),
                  items: widget.directories
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Card(
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() => widget.torrent.trackerList?.add(''));
                        },
                      ),
                      SizedBox(
                        height: widget.torrent.trackerList!.length * 65,
                        width: 300,
                        child: ListView.builder(
                          itemCount: widget.torrent.trackerList?.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: TextField(
                                controller: TextEditingController(
                                    text: widget.torrent.trackerList?[index]),
                                onChanged: (text) {
                                  setState(() => widget
                                      .torrent.trackerList?[index] = text);
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() => widget.torrent.trackerList
                                      ?.removeAt(index));
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var ids = [torrent.hashString!];
          if (location != torrent.downloadDir) {
            widget.transmission.move(ids: ids, location: location!, move: true);
          }
          await widget.transmission.set(
            ids: ids,
            trackerList: widget.torrent.trackerList,
          );
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
