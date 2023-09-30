import 'package:flutter/material.dart';
import 'package:magnetic/pages/login.dart';
import 'package:magnetic/pages/torrents.dart';
import 'package:magnetic/models/preferences.dart';
import 'package:transmission/transmission.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String host = '';
  String username = '';
  String password = '';

  loadSharedPreferences() async {
    var map = await Preferences.load();
    if (map.containsKey('username') &&
        map.containsKey('password') &&
        map.containsKey('host')) {
      host = Uri.parse(map['host']!).toString();
      username = map['username']!;
      password = map['password']!;
    }

    if (host.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TorrentsPage(
            transmission: Transmission(
              baseUrl: host,
              username: username,
              password: password,
            ),
          ),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  void initState() {
    loadSharedPreferences();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
