import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:transmission/transmission.dart';

class AddTorrent extends StatefulWidget {
  final Transmission transmission;
  const AddTorrent({super.key, required this.transmission});

  @override
  State<AddTorrent> createState() => _EditTorrentState();
}

class _EditTorrentState extends State<AddTorrent> {
  final _formKey = GlobalKey<FormState>();
  var filename = TextEditingController();
  var metainfo = TextEditingController();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  var addedTorrents = <(String, String)>[];
  List<PlatformFile>? _paths;
  bool _isLoading = false;
  bool _userAborted = false;

  Future<void> _pickFiles() async {
    try {
      setState(() => _isLoading = true);
      _paths = (await FilePicker.platform.pickFiles(
        withData: true,
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['torrent'],
        dialogTitle: _dialogTitleController.text,
        initialDirectory: _initialDirectoryController.text,
        lockParentWindow: false,
      ))
          ?.files;
    } on PlatformException catch (e) {
      Exception('Unsupported operation$e');
    } catch (e) {
      Exception(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _userAborted = _paths == null;
      print(_userAborted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add torrents')),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                    onPressed: () async {
                      await _pickFiles();
                      if (_paths != null) {
                        for (var file in _paths!) {
                          try {
                            var added = await widget.transmission.add(
                              metaInfo: base64.encode(file.bytes!),
                            );
                            addedTorrents.add((file.name, added.hash!));
                          } catch (e) {
                            addedTorrents.add((file.name, ''));
                            print(e);
                          }
                        }
                        setState(() {});
                      }
                    },
                    label: const Text('torrents'),
                    icon: const Icon(Icons.description)),
              ],
            ),
            if (addedTorrents.isNotEmpty)
              ...List.generate(addedTorrents.length, (index) {
                var item = addedTorrents[index];
                return Card(
                  child: Row(
                    children: [
                      if (item.$2.isEmpty)
                        const Icon(Icons.cancel, color: Colors.red),
                      if (item.$2.isNotEmpty)
                        const Icon(Icons.check, color: Colors.green),
                      Text(item.$1)
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
