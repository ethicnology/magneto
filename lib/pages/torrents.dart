import 'package:flutter/material.dart';
import 'package:magnetic/utils.dart';
import 'package:magnetic/widgets/add_torrent.dart';
import 'package:magnetic/widgets/torrent_compact.dart';
import 'package:transmission/transmission.dart';

class TorrentsPage extends StatefulWidget {
  final Transmission transmission;

  const TorrentsPage({super.key, required this.transmission});

  @override
  State<TorrentsPage> createState() => _TorrentsState();
}

class _TorrentsState extends State<TorrentsPage> {
  var torrents = <Torrent>[];
  var filtered = <Torrent>[];
  var name = '';
  Status? status;

  Future<void> getTorrents() async {
    torrents = await widget.transmission.get();
    filtered = torrents;
    setState(() {});
  }

  bool isQueued(Status? status) =>
      status == Status.seedQueued ||
      status == Status.verifyQueued ||
      status == Status.downloadQueued;

  List<Torrent> filter(Status status) {
    var result = <Torrent>[];
    var queued = false;
    if (isQueued(status)) queued = true;
    for (var torrent in torrents) {
      if (queued && isQueued(torrent.status)) result.add(torrent);
      if (torrent.status == status && !queued) result.add(torrent);
    }
    return result;
  }

  List<Torrent> search(List<Torrent> torrents, String search) {
    var result = <Torrent>[];
    for (var torrent in torrents) {
      var name = torrent.name!.toLowerCase();
      if (name.contains(search.toLowerCase())) result.add(torrent);
    }
    return result;
  }

  updateView() {
    if (status == null) filtered = torrents;
    if (status != null) filtered = filter(status!);
    if (name.isNotEmpty) filtered = search(filtered, name);
  }

  @override
  void initState() {
    getTorrents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), getTorrents);
    updateView();

    if (torrents.isEmpty) {
      return const CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(
            title: const Text('Torrents'), automaticallyImplyLeading: false),
        body: RefreshIndicator(
          onRefresh: getTorrents,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () => setState(() => status = null),
                    icon: const Tooltip(
                        message: 'All',
                        child: Icon(Icons.filter_list, color: Colors.blue))),
                IconButton(
                    onPressed: () => setState(() => status = Status.seeding),
                    icon: getIcon(Status.seeding)),
                IconButton(
                    onPressed: () => setState(() => status = Status.stopped),
                    icon: getIcon(Status.stopped)),
                IconButton(
                    onPressed: () =>
                        setState(() => status = Status.downloading),
                    icon: getIcon(Status.downloading)),
                IconButton(
                    onPressed: () => setState(() => status = Status.verifying),
                    icon: getIcon(Status.verifying)),
                IconButton(
                    onPressed: () => setState(() => status = Status.seedQueued),
                    icon: getIcon(Status.seedQueued)),
              ],
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => name = value),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (BuildContext ctx, int index) {
                  var torrent = filtered[index];
                  return TorrentCompact(
                    torrent: torrent,
                    transmission: widget.transmission,
                  );
                },
              ),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      AddTorrent(transmission: widget.transmission),
                ),
              );
            },
            child: const Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }
  }
}
