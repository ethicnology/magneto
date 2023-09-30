import 'package:flutter/material.dart';
import 'package:magnetic/widgets/torrent.dart';
import 'package:transmission/transmission.dart';

class TorrentsPage extends StatefulWidget {
  final Transmission transmission;

  const TorrentsPage({super.key, required this.transmission});

  @override
  State<TorrentsPage> createState() => _TorrentsState();
}

class _TorrentsState extends State<TorrentsPage> {
  var torrents = <Torrent>[];

  getTorrents() async {
    torrents = await widget.transmission.getTorrents();
    setState(() {});
  }

  @override
  void initState() {
    getTorrents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Torrents'), automaticallyImplyLeading: false),
      body: ListView.builder(
        itemCount: torrents.length,
        itemBuilder: (context, index) {
          return TorrentWidget(torrent: torrents[index]);
        },
      ),
    );
  }
}
