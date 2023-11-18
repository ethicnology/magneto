import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

var pubspec =
    'https://raw.githubusercontent.com/ethicnology/magneto/main/pubspec.yaml';
var url = 'https://github.com/ethicnology/magneto';

void showVersionOverlay(BuildContext context) {
  var overlay = OverlayEntry(
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (!await launchUrl(Uri.parse(url))) {
                    throw Exception('Launch $url');
                  }
                },
                child: const Text('New version'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlay);
  Future.delayed(const Duration(seconds: 10), () => overlay.remove());
}

Future<String> hasNewVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  print(packageInfo.data);

  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  final allInfo = deviceInfo.data;
  print(allInfo);

  var response = await get(Uri.parse(pubspec));

  var yaml = loadYaml(response.body);
  var yamlVersion = yaml['version'].toString().split('+');
  var remoteVersion = yamlVersion[0];
  // var remoteBuild = yamlVersion[1];

  var currentVersion = version.split('.');
  var currMajor = int.parse(currentVersion[0]);
  var currMinor = int.parse(currentVersion[1]);
  var currPatch = int.parse(currentVersion[2]);

  var originVersion = remoteVersion.split('.');
  var origMajor = int.parse(originVersion[0]);
  var origMinor = int.parse(originVersion[1]);
  var origPatch = int.parse(originVersion[2]);

  if (currentVersion.length != 3 || originVersion.length != 3) {
    print('A version number is three numbers separated by dots, like 1.2.43');
  }

  if (currMajor < origMajor) return 'major';
  if (currMinor < origMinor) return 'minor';
  if (currPatch < origPatch) return 'patch';

  return '';
}
