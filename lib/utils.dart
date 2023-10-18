import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transmission/transmission.dart';

Widget getIcon(
  Status? torrentStatus, {
  double width = 25,
  double height = 25,
  bool tooltip = true,
  int badge = 0,
}) {
  Widget child;
  switch (torrentStatus) {
    case Status.stopped:
      child = const Icon(Icons.pause_circle, color: Colors.amber);
      break;
    case Status.verifyQueued:
      child = const Icon(Icons.pending, color: Colors.grey);
      break;
    case Status.verifying:
      child = SvgPicture.asset('assets/clock_loader_40.svg',
          colorFilter:
              const ColorFilter.mode(Colors.purpleAccent, BlendMode.srcIn));
      break;
    case Status.downloadQueued:
      child = const Icon(Icons.pending, color: Colors.grey);
      break;
    case Status.downloading:
      child = const Icon(Icons.downloading, color: Colors.blue);
      break;
    case Status.seedQueued:
      child = const Icon(Icons.pending, color: Colors.grey);
      break;
    case Status.seeding:
      child = SvgPicture.asset(
        'assets/communities.svg',
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      );
      break;
    default:
      child = const Icon(Icons.question_mark, color: Colors.red);
  }
  if (tooltip) {
    return SizedBox(
      width: width,
      height: height,
      child: Badge(
        isLabelVisible: badge > 0,
        label: Text(badge.toString()),
        child: Tooltip(message: torrentStatus?.meaning, child: child),
      ),
    );
  } else {
    return SizedBox(
      width: width,
      height: height,
      child: Badge(
        isLabelVisible: badge > 0,
        label: Text(badge.toString()),
        child: child,
      ),
    );
  }
}

Future<bool> testConnection(Transmission transmission) async {
  try {
    var session = await transmission.session.get();
    print(session);
    return true;
  } catch (e) {
    print('connection failed: $e');
    return false;
  }
}
