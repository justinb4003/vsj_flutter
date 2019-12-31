class GameNew {
  String gameUuid;
  String lookupCode;

  GameNew({this.gameUuid, this.lookupCode});

  GameNew.fromJson(Map<String, dynamic> json) {
    gameUuid = json['game_uuid'];
    lookupCode = json['lookup_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['game_uuid'] = this.gameUuid;
    data['lookup_code'] = this.lookupCode;
    return data;
  }
}