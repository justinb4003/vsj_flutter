class GameLookup {
  String gameUuid;

  GameLookup({this.gameUuid});

  GameLookup.fromJson(Map<String, dynamic> json) {
    gameUuid = json['game_uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['game_uuid'] = this.gameUuid;
    return data;
  }
}