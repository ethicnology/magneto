import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magneto/memory.dart';
import 'package:magneto/models/preferences.dart';
import 'package:magneto/utils.dart';
import 'package:magneto/widgets/actions_many.dart';
import 'package:magneto/widgets/actions_none.dart';
import 'package:magneto/widgets/actions_solo.dart';
import 'package:magneto/widgets/torrent_compact.dart';
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
  var seeding = 0, stopped = 0, queued = 0, verifying = 0, downloading = 0;
  var actions = false;
  var isSelecting = false;
  var recentlyActive = false;
  var selectAll = false;
  var localData = false;
  var name = '';
  Status? status;

  Future<void> refreshTorrents() async {
    var connected = await testConnection(transmission);

    if (!mounted) return;
    if (connected == false) Navigator.pop(context);

    torrents = await transmission.torrent.get(recentlyActive: recentlyActive);
    if (torrents.isEmpty) {
      torrents = await transmission.torrent.get();
      recentlyActive = false;
    }

    filtered = torrents;
    setState(() {});
  }

  void select(Torrent torrent) {
    var hash = torrent.hash!;
    if (selected.contains(hash)) {
      selected.remove(hash);
    } else {
      selected.add(hash);
    }
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
    isSelecting = selected.isNotEmpty;
    if (status == null) filtered = torrents;
    if (status != null) filtered = filter(status!);
    if (name.isNotEmpty) filtered = search(filtered, name);
    directories = {for (var x in torrents) x.downloadDir!}.toList();
    selectAll = selected.length == filtered.length;
  }

  countTorrentPerStatus() {
    seeding = 0;
    stopped = 0;
    queued = 0;
    verifying = 0;
    downloading = 0;
    for (var t in torrents) {
      if (t.status! == Status.seeding) seeding++;
      if (t.status! == Status.stopped) stopped++;
      if (t.status! == Status.downloading) downloading++;
      if (t.status! == Status.verifying) verifying++;
      if (t.status! == Status.seedQueued) queued++;
      if (t.status! == Status.verifyQueued) queued++;
      if (t.status! == Status.downloadQueued) queued++;
    }
  }

  @override
  void initState() {
    refreshTorrents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updateView();
    countTorrentPerStatus();

    if (torrents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Torrents'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                Preferences.clear();
                SystemNavigator.pop(animated: true);
              },
              icon: const Icon(Icons.logout),
              color: Colors.red,
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: refreshTorrents,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    onPressed: () => setState(() => status = null),
                    icon: Tooltip(
                      message: 'All',
                      child: Badge(
                        isLabelVisible: torrents.isNotEmpty,
                        label: Text(torrents.length.toString()),
                        child: const Icon(Icons.filter_list),
                      ),
                    )),
                IconButton(
                  onPressed: () => setState(() => status = Status.seeding),
                  icon: getIcon(Status.seeding, badge: seeding),
                ),
                IconButton(
                  onPressed: () => setState(() => status = Status.stopped),
                  icon: getIcon(Status.stopped, badge: stopped),
                ),
                IconButton(
                  onPressed: () => setState(() => status = Status.downloading),
                  icon: getIcon(Status.downloading, badge: downloading),
                ),
                IconButton(
                  onPressed: () => setState(() => status = Status.verifying),
                  icon: getIcon(Status.verifying, badge: verifying),
                ),
                IconButton(
                  onPressed: () => setState(() => status = Status.seedQueued),
                  icon:
                      getIcon(Status.seedQueued, badge: queued, tooltip: false),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => name = value),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ListTile(
                    dense: true,
                    title: const Text('Active'),
                    leading: Transform.scale(
                      scale: 0.65,
                      child: Switch(
                          value: recentlyActive,
                          onChanged: (a) => setState(() => recentlyActive = a)),
                    ),
                  ),
                ),
              ],
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
                            selected = [for (var t in filtered) t.hash!];
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
                  var isSelected = selected.contains(torrent.hash);
                  return InkWell(
                    onDoubleTap: () {
                      actions = true;
                      select(torrent);
                    },
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          if (isSelecting && isSelected)
                            Transform.scale(
                              scale: 0.65,
                              child: Switch(
                                value: isSelected,
                                onChanged: (v) => select(torrent),
                              ),
                            ),
                          TorrentCompact(torrent: torrent),
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
            AnimatedOpacity(
              opacity: actions ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: actions
                  ? Column(
                      children: [
                        if ((isSelecting && actions) && selected.isNotEmpty)
                          ActionsMany(ids: selected),
                        if (isSelecting && actions && selected.length == 1)
                          ActionsSolo(
                            torrent: torrents
                                .firstWhere((t) => t.hash == selected.first),
                          ),
                        if (actions && selected.isEmpty) const ActionsNone(),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            FloatingActionButton(
              onPressed: () => setState(() => actions = !actions),
              child: const Icon(Icons.apps),
            ),
          ],
        ),
      );
    }
  }
}
