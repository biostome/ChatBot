import 'package:flutter/material.dart';
import 'chat_screen.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Wrap(
          runSpacing: 20.0,
        ),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.only(top: 25.0),
        child: Wrap(
          runSpacing: 10.0,
          children: [
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Chat with me'),
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
            const Divider(color: Colors.black54),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Log out'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      );
}
