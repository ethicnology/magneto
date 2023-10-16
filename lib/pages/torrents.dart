import 'package:flutter/material.dart';
import 'package:magnetic/memory.dart';
import 'package:magnetic/utils.dart';
import 'package:magnetic/widgets/add_torrent.dart';
import 'package:magnetic/widgets/edit_torrent.dart';
import 'package:magnetic/widgets/torrent_compact.dart';
import 'package:transmission/transmission.dart';

class TorrentsPage extends StatefulWidget {
  const TorrentsPage({super.key});

  @override
  State<TorrentsPage> createState() => _TorrentsState();
}

class _TorrentsState extends State<TorrentsPage> {
  var torrents = <Torrent>[];
  var filtered = <Torrent>[];
  var selected = <String>[];
  var actions = false;
  var isSelecting = false;
  var selectAll = false;
  var localData = false;
  var name = '';
  Status? status;

  Future<void> getTorrents() async {
    torrents = await transmission.torrent.get();
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

  void select(Torrent torrent) {
    var hash = torrent.hashString!;
    if (selected.contains(hash)) {
      selected.remove(hash);
    } else {
      selected.add(hash);
    }
    setState(() {});
  }

  updateView() {
    isSelecting = selected.isNotEmpty;
    if (status == null) filtered = torrents;
    if (status != null) filtered = filter(status!);
    if (name.isNotEmpty) filtered = search(filtered, name);
    setState(() {});
  }

  @override
  void initState() {
    getTorrents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), getTorrents);
    directories = {for (var x in torrents) x.downloadDir!}.toList();
    selectAll = selected.length == filtered.length;
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
            if (isSelecting)
              Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 0.65,
                      child: Switch(
                        value: selectAll,
                        activeColor: Colors.redAccent,
                        onChanged: (bool value) {
                          selectAll = !selectAll;
                          if (selectAll) {
                            selected = [for (var t in filtered) t.hashString!];
                          } else {
                            selected = [];
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    const Text('All')
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (BuildContext ctx, int index) {
                  var torrent = filtered[index];
                  var isSelected = selected.contains(torrent.hashString);
                  return InkWell(
                    onLongPress: () {
                      isSelecting = !isSelecting;
                      selected.clear();
                      if (isSelecting) select(torrent);
                      setState(() {});
                    },
                    onDoubleTap: () => isSelecting ? select(torrent) : null,
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          if (isSelecting && isSelected)
                            Transform.scale(
                              scale: 0.65,
                              child: Switch(
                                  value: isSelected,
                                  onChanged: (v) => select(torrent)),
                            ),
                          Expanded(
                            child: TorrentCompact(torrent: torrent),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if ((isSelecting || actions) && selected.isNotEmpty)
              Card(
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () =>
                          transmission.torrent.start(ids: selected),
                      icon: const Icon(Icons.play_circle),
                      color: Colors.green,
                    ),
                    IconButton(
                        onPressed: () =>
                            transmission.torrent.stop(ids: selected),
                        icon: getIcon(Status.stopped, tooltip: false),
                        color: Colors.amber),
                    IconButton(
                        onPressed: () =>
                            transmission.torrent.verify(ids: selected),
                        icon: const Icon(Icons.verified),
                        color: Colors.purpleAccent),
                    IconButton(
                        onPressed: () =>
                            transmission.torrent.reannounce(ids: selected),
                        icon: const Icon(Icons.campaign),
                        color: Colors.teal),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: Text(
                                      'Remove ${selected.length} torrents'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: localData,
                                            onChanged: (v) {
                                              setState(
                                                  () => localData = !localData);
                                            },
                                          ),
                                          const Text('Delete Local Data'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        transmission.torrent.remove(
                                          ids: selected,
                                          deleteLocalData: localData,
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Remove ${selected.length}'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.remove_circle),
                      color: Colors.redAccent,
                    )
                  ],
                ),
              ),
            if (isSelecting && actions && selected.length == 1)
              Card(
                color: Colors.black54,
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => EditTorrent(
                              torrent: filtered.firstWhere((element) =>
                                  element.hashString == selected.first),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_square),
                        color: Colors.white),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.info),
                        color: Colors.blue),
                  ],
                ),
              ),
            if (actions && selected.isEmpty)
              Card(
                color: Colors.black54,
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => const AddTorrent(),
                          );
                        },
                        icon: const Icon(Icons.add_circle),
                        color: Colors.blue),
                  ],
                ),
              ),
            FloatingActionButton(
              onPressed: () => setState(() => actions = !actions),
              child: const Icon(Icons.attractions),
            ),
          ],
        ),
      );
    }
  }
}
