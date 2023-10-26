import 'package:flutter/material.dart';
import 'package:magneto/models/global.dart';
import 'package:magneto/widgets/edit_torrent.dart';
import 'package:provider/provider.dart';
import 'package:transmission/transmission.dart';

class ActionsSolo extends StatefulWidget {
  final Torrent torrent;
  const ActionsSolo({super.key, required this.torrent});

  @override
  State<ActionsSolo> createState() => _ActionsSoloState();
}

class _ActionsSoloState extends State<ActionsSolo> {
  @override
  Widget build(BuildContext context) {
    var global = Provider.of<Global>(context, listen: true);

    return Card(
      color: Colors.black54,
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditTorrent(torrent: widget.torrent),
                );
                global.clearSelection();
              },
              icon: const Tooltip(
                message: 'Edit',
                child: Icon(Icons.edit_rounded),
              ),
              color: Colors.white),
        ],
      ),
    );
  }
}
