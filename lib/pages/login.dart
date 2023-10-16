import 'package:flutter/material.dart';
import 'package:magnetic/memory.dart';
import 'package:magnetic/pages/torrents.dart';
import 'package:magnetic/models/preferences.dart';
import 'package:transmission/transmission.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var host = TextEditingController();
  var username = TextEditingController();
  var password = TextEditingController();
  var isSaveInSharedPreferences = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Login'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: host,
              decoration: const InputDecoration(labelText: 'Host URI'),
            ),
            TextFormField(
              controller: username,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Remember me ?'),
                Checkbox(
                  value: isSaveInSharedPreferences,
                  onChanged: (newValue) {
                    setState(() => isSaveInSharedPreferences = newValue!);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                transmission = Transmission(
                  url: host.text,
                  username: username.text,
                  password: password.text,
                );

                if (isSaveInSharedPreferences) {
                  Preferences.save({
                    'host': host.text,
                    'username': username.text,
                    'password': password.text,
                  });
                }

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const TorrentsPage())));
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
