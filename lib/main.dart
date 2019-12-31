import 'dart:convert';
import 'package:flutter/material.dart';
import 'vsj_data.dart';
import 'game_play.dart';
import 'json_models/game_lookup.dart';
import 'json_models/game_new.dart';

void main() => runApp(VSGApp());

class VSGApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
      ),
      home: VSGHomePage(title: 'VSJ / Cards Against Humanity'),
    );
  }
}

class VSGHomePage extends StatefulWidget {
  VSGHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _VSGHomePageState createState() => _VSGHomePageState();
}

class _VSGHomePageState extends State<VSGHomePage> {
  int _counter = 0;

  void _createNewGame(BuildContext context) async {
    String url = '/creategame';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    GameNew gamenew = GameNew.fromJson(parsed);
    VSGData.game_uuid = gamenew.gameUuid;
    VSGData.game_lookup_code = gamenew.lookupCode;
    debugPrint("${gamenew.gameUuid}");
    debugPrint("${gamenew.lookupCode}");
    _joinGame(context);
  }

  void _joinGame(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GamePlay()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                onPressed: () {
                  debugPrint("Create new game");
                  _createNewGame(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Text('Create new game')),
            RaisedButton(
                onPressed: () {
                  debugPrint("Join game");
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Text('Join existing game')),
          ],
        ),
      ),
    );
  }
}
