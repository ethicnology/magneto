import 'package:flutter/foundation.dart';
import 'package:transmission/transmission.dart';

class Global with ChangeNotifier {
  var transmission = Transmission();
  var torrents = <Torrent>[];
  var selection = <String>[];
  var directories = <String>[];

  void notify() => notifyListeners();

  Future<bool> test() async {
    try {
      var session = await transmission.session.get();
      print(session);
      return true;
    } catch (e) {
      print('connection failed: $e');
      return false;
    }
  }

  Future<void> refresh({bool recentlyActive = false}) async {
    print('refresh: ${DateTime.now().toUtc().toIso8601String()}');
    torrents = await transmission.torrent.get(recentlyActive: recentlyActive);
    if (torrents.isEmpty) torrents = await transmission.torrent.get();
    notify();
  }

  void selectOrRemove(Torrent torrent) {
    var hash = torrent.hash!;
    if (selection.contains(hash)) {
      selection.remove(hash);
    } else {
      selection.add(hash);
    }
    notify();
  }

  void clearSelection() {
    selection = [];
    notify();
  }

  List<Torrent> filterTorrents(List<String> ids) {
    return [
      for (var torrent in torrents)
        if (selection.contains(torrent.hash)) torrent
    ];
  }
}
