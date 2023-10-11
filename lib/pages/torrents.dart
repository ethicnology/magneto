import 'package:flutter/material.dart';
import 'package:magnetic/widgets/add_torrent.dart';
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

  Future<void> getTorrents() async {
    torrents = [];
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
        title: const Text('Torrents'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: getTorrents,
        child: ListView.builder(
          itemCount: torrents.length,
          itemBuilder: (context, index) {
            return TorrentWidget(
              torrent: torrents[index],
              transmission: widget.transmission,
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              onPressed: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) =>
                        AddTorrent(transmission: widget.transmission),
                  ),
                );
              },
              child: const Icon(Icons.add)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
