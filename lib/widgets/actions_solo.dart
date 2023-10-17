import 'package:flutter/material.dart';
import 'package:magnetic/widgets/edit_torrent.dart';
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
    return Card(
      color: Colors.black54,
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => EditTorrent(torrent: widget.torrent),
                );
              },
              icon: const Icon(Icons.edit_square),
              color: Colors.white),
        ],
      ),
    );
  }
}
