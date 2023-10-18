import 'package:flutter/material.dart';
import 'package:magneto/memory.dart';
import 'package:magneto/pages/login.dart';
import 'package:magneto/pages/torrents.dart';
import 'package:magneto/models/preferences.dart';
import 'package:magneto/utils.dart';
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
      transmission = Transmission(
        url: host,
        username: username,
        password: password,
      );

      var connection = await testConnection(transmission);
      if (connection) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TorrentsPage(),
          ),
        );
      } else {
        Preferences.clear();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
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
