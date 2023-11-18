import 'package:flutter/material.dart';

import '../../my_theme.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Language'),
          const SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: MyTheme.whiteColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('English'),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text('Theme'),
          const SizedBox(
            height: 15,
          ),
          InkWell(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: MyTheme.whiteColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Light'),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
