import 'package:flutter/material.dart';
import 'package:magneto/widgets/add_torrent.dart';

class ActionsNone extends StatefulWidget {
  const ActionsNone({super.key});

  @override
  State<ActionsNone> createState() => _ActionsNoneState();
}

class _ActionsNoneState extends State<ActionsNone> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddTorrent(),
                );
              },
              icon: const Icon(Icons.add_circle_rounded),
              color: Colors.blue),
        ],
      ),
    );
  }
}
