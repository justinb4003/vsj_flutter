class PlayerJoin {
  String friendlyMessage;
  String playerUuid;

  PlayerJoin({this.friendlyMessage, this.playerUuid});

  PlayerJoin.fromJson(Map<String, dynamic> json) {
    friendlyMessage = json['friendly_message'];
    playerUuid = json['player_uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['friendly_message'] = this.friendlyMessage;
    data['player_uuid'] = this.playerUuid;
    return data;
  }
}