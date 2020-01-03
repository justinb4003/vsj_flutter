import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vsj_data.dart';
import 'game_play.dart';
import 'json_models/game_new.dart';
import 'json_models/player_join.dart';

//void main() => runApp(VSGApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VSGData.loadPrefs();
  VSGApp app = VSGApp();
  runApp(app);
}

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

  void _playerNameChange() async {
    VSGData.playerName = _playerNameController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('playerName', VSGData.playerName);
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

  Future<String> _getLookupCode(BuildContext context, String lookupCode) async {
    String url = '/lookupgame/$lookupCode';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    String uuid = parsed['game_uuid'];
    // debugPrint(uuid);
    return uuid;
  }

  void _joinGame(BuildContext context) async {
    String url = '/addplayer/${VSGData.gameUuid}/${VSGData.playerName}';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    PlayerJoin playerJoin = PlayerJoin.fromJson(parsed);
    VSGData.playerUuid = playerJoin.playerUuid;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GamePlay()));
  }

  Future<String> _asyncInputLookupCode(BuildContext context) async {
    String lookupCode = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter game code'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Game code'),
                onChanged: (value) {
                  lookupCode = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(lookupCode);
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildPlayerNameEntry(BuildContext context) {
    return Column(children: <Widget>[
      TextField(
          controller: _playerNameController,
          decoration: InputDecoration(labelText: 'Your name'),
          enabled: true,
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center),
    ]);
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
                onPressed: () async {
                  final String lookupCode = await _asyncInputLookupCode(context);
                  VSGData.gameLookupCode = lookupCode;
                  debugPrint("Join game $lookupCode");
                  String gameUuid = await _getLookupCode(context, lookupCode);
                  debugPrint("Join game with UUID $gameUuid");
                  VSGData.gameUuid = gameUuid;
                  _joinGame(context);
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
