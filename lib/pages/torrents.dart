import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magneto/models/preferences.dart';
import 'package:magneto/models/global.dart';
import 'package:magneto/utils.dart';
import 'package:magneto/widgets/actions_many.dart';
import 'package:magneto/widgets/actions_none.dart';
import 'package:magneto/widgets/actions_solo.dart';
import 'package:magneto/widgets/torrent_compact.dart';
import 'package:provider/provider.dart';
import 'package:transmission/transmission.dart';

class TorrentsPage extends StatefulWidget {
  const TorrentsPage({super.key});

  @override
  State<TorrentsPage> createState() => _TorrentsState();
}

class _TorrentsState extends State<TorrentsPage>
    with SingleTickerProviderStateMixin {
  var filtered = <Torrent>[];
  var seeding = 0, stopped = 0, queued = 0, verifying = 0, downloading = 0;
  var actions = false;
  var isSelecting = false;
  var recentlyActive = false;
  var selectAll = false;
  var localData = false;
  var name = '';
  Status? status;
  Timer? timer;
  int? seconds;
  final periods = [null, 1, 3, 5, 10, 15, 30, 50];
  var isRefreshing = false;
  late AnimationController _controller;

  Future<void> refreshTorrents() async {
    isRefreshing = !isRefreshing;
    _controller.forward(from: 0.0);
    setState(() {});

    var global = Provider.of<Global>(context, listen: false);
    var isConnected = await global.test();

    if (!mounted) return;
    if (isConnected == false) Navigator.pop(context);

    global.refresh();
    filtered = global.torrents;

    setState(() {});
  }

  bool isQueued(Status? status) =>
      status == Status.seedQueued ||
      status == Status.verifyQueued ||
      status == Status.downloadQueued;

  selectionAll() {
    var global = Provider.of<Global>(context, listen: false);
    selectAll = !selectAll;
    if (selectAll) {
      global.selection = [for (var t in filtered) t.hash!];
    } else {
      global.selection = [];
    }
    setState(() {});
  }

  updateView(List<Torrent> torrents, List<String> selection) {
    isSelecting = selection.isNotEmpty;
    if (status == null) filtered = torrents;
    if (status != null) filtered = filter(torrents, status!);
    if (name.isNotEmpty) filtered = search(filtered, name);
    selectAll = selection.length == filtered.length;
  }

  List<Torrent> filter(List<Torrent> torrents, Status status) {
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

  countTorrentPerStatus(List<Torrent> torrents) {
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    refreshTorrents();
    super.initState();
  }

  void setTimer(int? value) {
    seconds = value;
    timer?.cancel(); // disable previous timer
    if (value != null) {
      timer = Timer.periodic(Duration(seconds: value), (timer) async {
        await refreshTorrents();
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var global = Provider.of<Global>(context, listen: true);
    global.directories =
        {for (var x in global.torrents) x.downloadDir!}.toList();
    updateView(global.torrents, global.selection);
    countTorrentPerStatus(global.torrents);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Torrents'),
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: Row(
          children: [
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
              child: IconButton(
                onPressed: refreshTorrents,
                icon: const Tooltip(
                    message: 'Refresh', child: Icon(Icons.refresh_rounded)),
              ),
            ),
            DropdownButton<int?>(
              icon: const Icon(Icons.arrow_downward_rounded),
              value: seconds,
              items: periods.map((int? value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value != null ? '$value s' : 'null'),
                );
              }).toList(),
              onChanged: (value) => setTimer(value),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Preferences.clear();
              SystemNavigator.pop(animated: true);
            },
            icon: const Tooltip(
              message: 'Logout',
              child: Icon(Icons.logout_rounded),
            ),
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
                      isLabelVisible: global.torrents.isNotEmpty,
                      label: Text(global.torrents.length.toString()),
                      child: const Icon(Icons.filter_list_rounded),
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
                icon: getIcon(Status.seedQueued, badge: queued, tooltip: false),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => setState(() => name = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 25, top: 10),
                child: InkWell(
                  onTap: () => setState(() => recentlyActive = !recentlyActive),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 0.65,
                        child: Switch(
                            value: recentlyActive,
                            onChanged: (a) =>
                                setState(() => recentlyActive = a)),
                      ),
                      const Text('Active'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isSelecting)
            InkWell(
              onTap: () => selectionAll(),
              child: SizedBox(
                width: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 0.65,
                      child: Switch(
                        value: selectAll,
                        activeColor: Colors.redAccent,
                        onChanged: (v) => selectionAll(),
                      ),
                    ),
                    const Text('All')
                  ],
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Wrap(
                // spacing: 16, // Adjust spacing as needed
                // runSpacing: 16, // Adjust run spacing as needed
                children: filtered.map((torrent) {
                  var isSelected = global.selection.contains(torrent.hash);
                  return SizedBox(
                    width: 500,
                    child: InkWell(
                      onDoubleTap: () {
                        actions = true;
                        global.selectOrRemove(torrent);
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
                                  onChanged: (v) =>
                                      global.selectOrRemove(torrent),
                                ),
                              ),
                            TorrentCompact(torrent: torrent),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                      if ((isSelecting && actions) &&
                          global.selection.isNotEmpty)
                        ActionsMany(
                          torrents: global.torrents
                              .where((t) => global.selection.contains(t.hash!))
                              .toList(),
                        ),
                      if (isSelecting &&
                          actions &&
                          global.selection.length == 1)
                        ActionsSolo(
                          torrent: global.torrents.firstWhere(
                              (t) => t.hash == global.selection.first),
                        ),
                      if (actions && global.selection.isEmpty)
                        const ActionsNone(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          FloatingActionButton.small(
            onPressed: () => setState(() => actions = !actions),
            child: const Icon(Icons.apps_rounded),
          ),
        ],
      ),
    );
  }
}
