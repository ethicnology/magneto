import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:freeleech/freeleech.dart';
import 'package:magneto/models/global.dart';
import 'package:provider/provider.dart';

class AddTorrent extends StatefulWidget {
  const AddTorrent({super.key});

  @override
  State<AddTorrent> createState() => _EditTorrentState();
}

class _EditTorrentState extends State<AddTorrent> {
  var filename = TextEditingController();
  var metainfo = TextEditingController();
  final _dialogTitleController = TextEditingController();
  final _initialDirectoryController = TextEditingController();
  var addedTorrents = <(String, String)>[];
  List<PlatformFile>? _paths;
  bool _isLoading = false;
  bool _userAborted = false;
  bool isLeech = false;
  String? downloadDir;

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
    var global = Provider.of<Global>(context, listen: true);

    return AlertDialog(
      title: const Text('Add torrents'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            // TODO: renable freeleeching using private repository in Github Actions
            // InkWell(
            //   onTap: () => setState(() => isLeech = !isLeech),
            //   child: SizedBox(
            //     width: 150,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         Transform.scale(
            //           scale: 0.6,
            //           child: Switch(
            //               value: isLeech,
            //               onChanged: (a) => setState(() => isLeech = !isLeech)),
            //         ),
            //         const Text('Freeleech',
            //             overflow: TextOverflow.ellipsis, maxLines: 1),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(
              width: 200,
              child: DropdownButton<String>(
                isExpanded: true,
                value: downloadDir,
                onChanged: (value) => setState(() => downloadDir = value),
                items:
                    global.directories.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.folder_rounded),
                        const SizedBox(width: 8),
                        SizedBox(
                            width: 135,
                            child:
                                Text(value, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Magnet Link',
                  prefixIcon: Icon(Icons.bolt_rounded),
                ),
                onChanged: (value) async {
                  RegExp magnetRegex =
                      RegExp(r'magnet:\?xt=urn:btih:[a-fA-F0-9]+&dn=([^&]+)');

                  Match? match = magnetRegex.firstMatch(value);
                  if (match != null) {
                    var magnetDn = match.group(1)!;
                    String magnetName = Uri.decodeComponent(magnetDn);
                    print('The magnet name is: $magnetName');
                    try {
                      var added = await global.transmission.torrent.add(
                        filename: value,
                        downloadDir: downloadDir,
                      );
                      addedTorrents.add((magnetName, added.hash!));
                    } catch (e) {
                      addedTorrents.add((magnetName, ''));
                      print(e);
                    }
                  } else {
                    print('No match found for the pattern.');
                  }
                  setState(() {});
                },
              ),
            ),
            ElevatedButton.icon(
                onPressed: () async {
                  await _pickFiles();
                  if (_paths != null) {
                    for (var file in _paths!) {
                      try {
                        var added = await global.transmission.torrent.add(
                          metainfo: base64.encode(file.bytes!),
                          downloadDir: downloadDir,
                        );
                        addedTorrents.add((file.name, added.hash!));
                      } catch (e) {
                        addedTorrents.add((file.name, ''));
                        print(e);
                      }
                    }
                    // var ids = [
                    //   for (var t in addedTorrents)
                    //     if (t.$2.isNotEmpty) t.$2
                    // ];
                    // if (isLeech) freeleech(global.transmission, ids);
                    setState(() {});
                  }
                },
                label: const Text('Torrents files'),
                icon: const Icon(Icons.file_upload_rounded)),
            if (addedTorrents.isNotEmpty)
              SizedBox(
                width: 200,
                height: 100,
                child: ListView.builder(
                  itemCount: addedTorrents.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    var item = addedTorrents[index];

                    return SizedBox(
                      width: 190,
                      height: 40,
                      child: Card(
                        child: Row(
                          children: [
                            if (item.$2.isEmpty)
                              const Icon(Icons.cancel_rounded,
                                  color: Colors.red),
                            if (item.$2.isNotEmpty)
                              const Icon(Icons.check_rounded,
                                  color: Colors.green),
                            SizedBox(
                              width: 140,
                              child: Text(
                                item.$1,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
