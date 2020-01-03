import 'dart:convert';
import 'package:flutter/material.dart';
import 'vsj_data.dart';
import 'game_play.dart';
import 'json_models/game_new.dart';
import 'json_models/player_join.dart';

void main() => runApp(VSGApp());

class VSGApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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
  TextEditingController _playerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playerNameController.addListener(_playerNameChange);
  }

  void _playerNameChange() {
    VSGData.playerName = _playerNameController.text;
    debugPrint("Player now known as ${VSGData.playerName}");
  }

  void _createNewGame(BuildContext context) async {
    String url = '/creategame';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    GameNew gamenew = GameNew.fromJson(parsed);
    VSGData.gameUuid = gamenew.gameUuid;
    VSGData.gameLookupCode = gamenew.lookupCode;
    debugPrint("${gamenew.gameUuid}");
    debugPrint("${gamenew.lookupCode}");
    _joinGame(context);
  }

  void _joinGame(BuildContext context) async {
    // TODO: Needs to handle lookup code and getting the game uuid

    String url = '/addplayer/${VSGData.gameUuid}/${VSGData.playerName}';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    PlayerJoin playerJoin = PlayerJoin.fromJson(parsed);
    VSGData.playerUuid = playerJoin.playerUuid;
    Navigator.push(context, MaterialPageRoute(builder: (context) => GamePlay()));
  }

  Widget buildPlayerNameEntry(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
        controller: _playerNameController,
        decoration: InputDecoration(labelText: 'Identify yourself'),
        enabled: true,
        style: Theme.of(context).textTheme.display1,
        textAlign: TextAlign.center),

    ]
    );

  }

  @override
  Widget build(BuildContext context) {
    Widget playerNameEntry = buildPlayerNameEntry(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Yes, I know the interface is lacking."),
            playerNameEntry,
            SizedBox(height: 20),
            RaisedButton(
                onPressed: () {
                  debugPrint("Create new game");
                  _createNewGame(context);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Text('Create new game')),
            SizedBox(height: 20),
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
