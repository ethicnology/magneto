import 'package:flutter/material.dart';
import 'package:magneto/models/global.dart';
import 'package:magneto/pages/torrents.dart';
import 'package:magneto/models/preferences.dart';
import 'package:provider/provider.dart';
import 'package:transmission/transmission.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var host = TextEditingController(text: 'http://localhost:9091');
  var username = TextEditingController();
  var password = TextEditingController();
  var isSaveInSharedPreferences = false;

  @override
  Widget build(BuildContext context) {
    var global = Provider.of<Global>(context, listen: true);

    return Scaffold(
      appBar:
          AppBar(title: const Text('Login'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              width: 180,
              child: TextFormField(
                controller: host,
                decoration: const InputDecoration(labelText: 'Host'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    controller: username,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    controller: password,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                global.transmission = Transmission(
                  url: host.text,
                  username: username.text,
                  password: password.text,
                );

                var isConnected = await global.test();
                if (isConnected) {
                  if (isSaveInSharedPreferences) {
                    Preferences.save({
                      'host': host.text,
                      'username': username.text,
                      'password': password.text,
                    });
                  }

                  if (!mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const TorrentsPage())));
                } else {
                  print('connection failed');
                }
              },
              child: const Text('Login'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 0.60,
                  child: Switch(
                    value: isSaveInSharedPreferences,
                    onChanged: (newValue) {
                      setState(() => isSaveInSharedPreferences = newValue);
                    },
                  ),
                ),
                const Text('Remember')
              ],
            ),
          ],
        ),
      ),
    );
  }
}
