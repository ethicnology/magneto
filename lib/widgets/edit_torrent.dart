import 'package:flutter/material.dart';
import 'package:transmission/transmission.dart';

class EditTorrent extends StatefulWidget {
  final Transmission transmission;
  final Torrent torrent;
  const EditTorrent(
      {super.key, required this.torrent, required this.transmission});

  @override
  State<EditTorrent> createState() => _EditTorrentState();
}

class _EditTorrentState extends State<EditTorrent> {
  final _formKey = GlobalKey<FormState>();
  late Torrent torrent;
  var trackers = TextEditingController();

  @override
  void initState() {
    torrent = widget.torrent;
    trackers.text = torrent.trackerList?.join('\n') ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: trackers,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(label: Text('trackers')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.transmission.set(
              ids: [torrent.hashString!],
              trackerList: trackers.text.split('\n'));
          if (!mounted) return;
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
