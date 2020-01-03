import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'json_models/player_hand.dart';
import 'json_models/game_status.dart';
import 'json_models/message_winner.dart';
import 'vsj_data.dart';

class GamePlay extends StatefulWidget {
  @override
  _GamePlayState createState() => _GamePlayState();
}

class _GamePlayState extends State<GamePlay> {
  Future<PlayerHand> _playerHand;
  Future<GameStatus> _gameStatus;
  final _snackbarTooMany = SnackBar(content: Text('Too many selections...'));
  final _snackbarTooFew = SnackBar(content: Text('Not enough selections...'));
  MessageWinner _lastWinnerMessage;
  bool _isDecider = false;
  bool _isSubmitted = false;
  int _pickCount;
  List<String> _responseCardUuidList = List<String>();

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    _playerHand = getPlayerHand();
    _gameStatus = getGameStatus();
    // TODO: Reconnect websocket if something happens.
    final channel = IOWebSocketChannel.connect(
        "ws://192.168.1.128:5000/monitor/${VSGData.gameUuid}/${VSGData.playerUuid}");
    channel.stream.listen((message) {
      debugPrint("Websocket got message: $message");
      if (message == 'update_game_status') {
        _refreshGameStatus();
      } else {
        // Must be a 'winner' JSON message.
        // Yes, much more control is needed over this. Learning pains.
        final parsed = json.decode(message);
        setState(() {
          _lastWinnerMessage = MessageWinner.fromJson((parsed));
          _alertWinnerDialog(context);
        });
      }
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
      _isSubmitted = true;
      _pickCount = gameStatus.promptCard.pick;
      for (var p in gameStatus.waitingOn) {
        if (p.playerUuid == VSGData.playerUuid) {
          _isSubmitted = false;
        }
      }
      // debugPrint("New value of isDecider $_isDecider");
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
    Future gs = getGameStatus();
    setState(() {
      _gameStatus = gs;
    });
    return _gameStatus;
  }

  Widget buildLookupCode(BuildContext context, GameStatus gs) {
    bool debug = false;
    if (debug == false) {
      return Text("Use code ${VSGData.gameLookupCode} to join");
    } else {
      return Column(children: <Widget>[
        Text("Use code ${VSGData.gameLookupCode} to join"),
        Text("Player uuid ${VSGData.playerUuid}"),
        Text("Game uuid ${VSGData.gameUuid}")
      ]);
    }
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
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(children: <Widget>[
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: gs.promptCard.text,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "Pick $_pickCount",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal))),
        ]));
  }

  Future<int> _selectWinner(List<Cards> cards) async {
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
    return resp.statusCode;
  }

  Future<int> _submitResponse(List<String> uuids) async {
    Map<String, dynamic> jsonData = new Map<String, dynamic>();
    jsonData['cardlist'] = uuids;
    debugPrint(json.encode(jsonData));
    var resp = await VSGData.postVSJUrl(
        '/submitcards/${VSGData.gameUuid}/${VSGData.playerUuid}',
        json.encode(jsonData));
    return resp.statusCode;
  }

  String buildPromptResponseCombined(String origText, var cards) {
    String finalText = origText;
    if (finalText.contains("_")) {
      for (final c in cards) {
        // debugPrint(finalText);
        finalText = finalText.replaceFirst("_", c.text);
      }
    } else {
      // We have a prompt card without blanks.  Just display the text at the end.
      for (final c in cards) {
        // debugPrint(finalText);
        finalText = "$finalText ${c.text}";
      }
    }
    return finalText;
  }

  Widget buildSelectWinner(BuildContext context, GameStatus gs) {
    List<Widget> playerList = List<Widget>();
    PromptCard pc = gs.promptCard;
    if (gs.waitingOn.length > 0) {
      return LinearProgressIndicator();
    } else {
      for (final p in gs.submissions.players) {
        // debugPrint(p.playerName);
        String finalText = buildPromptResponseCombined(pc.text, p.cards);
        // Clear up duplicated puncutation
        // finalText = finalText.replaceAll("..", ".");
        Widget w = Card(
            child: Column(children: <Widget>[
          ListTile(
              onTap: () {
                debugPrint("selected winner ${p.playerName}");
                // The server should prevent this, but... for now I'm stopping it here but not disabling the tap.
                if (gs.deciderUuid == VSGData.playerUuid) {
                  _selectWinner(p.cards);
                }
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
                Scaffold.of(context).hideCurrentSnackBar();
                setState(() {
                  if (_responseCardUuidList.contains(pc.cardUuid)) {
                    _responseCardUuidList.remove(pc.cardUuid);
                  } else {
                    _responseCardUuidList.add(pc.cardUuid);
                  }

                  if (_responseCardUuidList.length > _pickCount) {
                    _alertTooManySelections(context);
                    _responseCardUuidList.removeLast();
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
            if (_isSubmitted) {
              return Column(children: <Widget>[
                LinearProgressIndicator(),
                Text('Waiting for decision...')
              ]);
            } else {
              return buildPlayerHand(context, snap.data);
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    }
  }

  void _alertWinnerDialog(BuildContext context) async {
    // Set up some text to display
    GameStatus gs = await _gameStatus;
    var winnerUuid = _lastWinnerMessage.winnerUuid;
    var winnerName = 'Error';
    var winnerPhrase = 'Error';
    for (var p in gs.playerList) {
      if (p.playerUuid == winnerUuid) {
        winnerName = p.playerName;
        winnerPhrase = buildPromptResponseCombined(
            _lastWinnerMessage.promptCard.text, _lastWinnerMessage.cardlist);
      }
    }
    debugPrint("$winnerName won");
    debugPrint("$winnerPhrase");

    showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$winnerName wins!'),
          content: Text(winnerPhrase),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _alertTooManySelections(BuildContext context) async {
    Scaffold.of(context).showSnackBar(_snackbarTooMany);
    /*
    showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Too many selections'),
          content: Text(''),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    */
  }

  Widget buildPlayerSubmitContainer(BuildContext context) {
    if (_isDecider || _isSubmitted) {
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
                onPressed: () async {
                  debugPrint("Submit responses");
                  if (_responseCardUuidList.length < _pickCount) {
                    Scaffold.of(context).showSnackBar(_snackbarTooFew);
                  } else if (_responseCardUuidList.length > _pickCount) {
                    Scaffold.of(context).showSnackBar(_snackbarTooMany);
                  } else {
                    int respCode = await _submitResponse(_responseCardUuidList);
                    if (respCode != 200) {
                      debugPrint("Error submitting responses: $respCode");
                    }
                    setState(() {
                      _responseCardUuidList.clear();
                      _refreshPlayerHand();
                    });
                  }
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
            Builder(builder: (context) { 
              return buildPlayerHandContainer(context, _isDecider);
            }),
            Builder(builder: (context) {
              return buildPlayerSubmitContainer(context);
            }),
          ],
        ),
      ),
    );
  }
}
