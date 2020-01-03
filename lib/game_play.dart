import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'json_models/player_hand.dart';
import 'json_models/game_status.dart';
import 'vsj_data.dart';

class GamePlay extends StatefulWidget {
  @override
  _GamePlayState createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  Future<PlayerHand> _playerHand;
  Future<GameStatus> _gameStatus;
  bool _isDecider = false;
  List<String> _responseCardUuidList = List<String>();

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    _playerHand = getPlayerHand();
    _gameStatus = getGameStatus();
    final channel = await IOWebSocketChannel.connect(
        "ws://192.168.1.128:5000/monitor/${VSGData.gameUuid}/${VSGData.playerUuid}");
    channel.stream.listen((message) {
      debugPrint("Received $message");
      _refreshGameStatus();
    });
  }

  Future<PlayerHand> getPlayerHand() async {
    PlayerHand playerHand = new PlayerHand();
    String url = '/get/hand/${VSGData.gameUuid}/${VSGData.playerUuid}';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    playerHand = PlayerHand.fromJson(parsed);
    return playerHand;
  }

  Future<GameStatus> getGameStatus() async {
    GameStatus gameStatus = new GameStatus();
    String url = '/get/gamestatus/${VSGData.gameUuid}';
    var resp = await VSGData.getVSJUrl(url);
    final parsed = json.decode(resp.body);
    gameStatus = GameStatus.fromJson(parsed);
    // Every time we rebuild the game status are redo the low so we can toggle decider status on/off
    setState(() {
      _isDecider = gameStatus.deciderUuid == VSGData.playerUuid;
      debugPrint("New value of isDecider $_isDecider");
    });
    return gameStatus;
  }

  bool isDecider(GameStatus gs) {
    // Is the curent player the decider?
    return gs.deciderUuid == VSGData.playerUuid;
  }

  Future<PlayerHand> _refreshPlayerHand() async {
    setState(() {
      _playerHand = getPlayerHand();
    });
    return _playerHand;
  }

  Future<GameStatus> _refreshGameStatus() async {
    setState(() {
      _gameStatus = getGameStatus();
    });
    return _gameStatus;
  }

  Widget buildLookupCode(BuildContext context, GameStatus gs) {
    return Text("Use code ${VSGData.gameLookupCode} to join");
  }

  Widget buildPlayerList(BuildContext context, GameStatus gs) {
    return Wrap(children: List<Widget>.from(gs.playerList.map(
      (pl) {
        if (pl.playerUuid == gs.deciderUuid) {
          return Padding(
              padding: EdgeInsets.all(5),
              child: RaisedButton.icon(
                  icon: Icon(Icons.arrow_right),
                  label: Text(pl.playerName),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  onPressed: () {
                    _refreshGameStatus();
                  }));
        } else {
          MaterialColor backColor = Colors.lightGreen;
          for (var p in gs.waitingOn) {
            if (p.playerUuid == pl.playerUuid) {
              backColor = Colors.red;
            }
          }
          return Padding(
              padding: EdgeInsets.all(5),
              child: RaisedButton(
                  child: Text(pl.playerName),
                  color: backColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  onPressed: () {
                    _refreshGameStatus();
                  }));
        }
      },
    )));
  }

  Widget buildPromptCardDisplay(BuildContext context, GameStatus gs) {
    return Text(gs.promptCard.text);
  }

  void _selectWinner(List<Cards> cards) async {
    Map<String, dynamic> jsonData = new Map<String, dynamic>();
    List<String> cardUuids = List<String>();
    for (final c in cards) {
      cardUuids.add(c.cardUuid);
    }
    jsonData['cardlist'] = cardUuids;
    debugPrint(json.encode(jsonData));
    var resp = await VSGData.postVSJUrl(
        '/selectwinner/${VSGData.gameUuid}/${VSGData.playerUuid}',
        json.encode(jsonData));
  }

  void _submitResponse(List<String> uuids) async {
    Map<String, dynamic> jsonData = new Map<String, dynamic>();
    jsonData['cardlist'] = uuids;
    debugPrint(json.encode(jsonData));
    var resp = await VSGData.postVSJUrl(
        '/submitcards/${VSGData.gameUuid}/${VSGData.playerUuid}',
        json.encode(jsonData));
  }

  Widget buildSelectWinner(BuildContext context, GameStatus gs) {
    List<Widget> playerList = List<Widget>();
    PromptCard pc = gs.promptCard;
    if (gs.waitingOn.length > 0) {
      return CircularProgressIndicator();
    } else {
      for (final p in gs.submissions.players) {
        // debugPrint(p.playerName);
        String finalText = pc.text;
        if (finalText.contains("_")) {
          for (final c in p.cards) {
            // debugPrint(finalText);
            finalText = finalText.replaceFirst("_", c.text);
          }
        } else {
          // We have a prompt card without blanks.  Just display the text at the end.
          for (final c in p.cards) {
            // debugPrint(finalText);
            finalText = "$finalText ${c.text}";
          }
        }
        // Clear up duplicated puncutation
        // finalText = finalText.replaceAll("..", ".");
        Widget w = Card(
            child: Column(children: <Widget>[
          ListTile(
              onTap: () {
                debugPrint("selected winner ${p.playerName}");
                _selectWinner(p.cards);
              },
              contentPadding: EdgeInsets.all(10),
              leading: Icon(Icons.person),
              title: Text(p.playerName),
              subtitle: RichText(
                  text: TextSpan(
                      text: finalText,
                      style: TextStyle(color: Colors.black, fontSize: 20))))
        ]));
        playerList.add(w);
      }

      return Column(
        children: playerList.toList(),
      );

    }
  }

  Widget buildGameStatus(BuildContext context, GameStatus gs) {
    return Column(
      children: <Widget>[
        buildLookupCode(context, gs),
        buildPlayerList(context, gs),
        buildPromptCardDisplay(context, gs),
        buildSelectWinner(context, gs),
      ],
    );
  }

  Widget buildPlayerHand(BuildContext context, PlayerHand ph) {
    return Flexible(
      child: ListView(
        children: List<Widget>.from(ph.cardlist.map((pc) => Card(
                child: ListTile(
              onTap: () {
                debugPrint(pc.cardUuid);
                setState(() {
                  if (_responseCardUuidList.contains(pc.cardUuid)) {
                    _responseCardUuidList.remove(pc.cardUuid);
                  } else {
                    _responseCardUuidList.add(pc.cardUuid);
                  }
                });
              },
              title: Text("${pc.text}"),
              trailing: _responseCardUuidList.contains(pc.cardUuid)
                  ? Text((_responseCardUuidList.indexOf(pc.cardUuid) + 1)
                      .toString())
                  : null,
            )))),
      ),
    );
  }

  Widget buildPlayerHandContainer(BuildContext context, bool isDecider) {
    if (_isDecider) {
      return Text("You are the decider!");
    } else {
      return FutureBuilder(
        future: _playerHand,
        builder: (context, snap) {
          if (snap.hasData == true) {
            return buildPlayerHand(context, snap.data);
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    }
  }

  Widget buildPlayerSubmitContainer(BuildContext context) {
    if (_isDecider) {
      return SizedBox(height: 10);
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                onPressed: () {
                  debugPrint("Reset responses");
                  _refreshPlayerHand();
                  setState(() {
                    _responseCardUuidList.clear();
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Text('Clear selection')),
            RaisedButton(
                onPressed: () {
                  debugPrint("Submit responses");
                  _submitResponse(_responseCardUuidList);
                  _refreshPlayerHand();
                  setState(() {
                    _responseCardUuidList.clear();
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: Text('Send it in!'))
          ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Play'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder(
              future: _gameStatus,
              builder: (context, snap) {
                if (snap.hasData == true) {
                  return buildGameStatus(context, snap.data);
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            buildPlayerHandContainer(context, _isDecider),
            buildPlayerSubmitContainer(context),
          ],
        ),
      ),
    );
  }
}
