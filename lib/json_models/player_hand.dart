import 'package:html_unescape/html_unescape.dart';

class PlayerHand {
  List<Cardlist> cardlist;

  PlayerHand({this.cardlist});

  PlayerHand.fromJson(Map<String, dynamic> json) {
    if (json['cardlist'] != null) {
      cardlist = new List<Cardlist>();
      json['cardlist'].forEach((v) {
        cardlist.add(new Cardlist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cardlist != null) {
      data['cardlist'] = this.cardlist.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cardlist {
  String cardUuid;
  String text;

  Cardlist({this.cardUuid, this.text});

  Cardlist.fromJson(Map<String, dynamic> json) {
    var unescape = new HtmlUnescape();
    cardUuid = json['card_uuid'];
    text = unescape.convert(json['text']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_uuid'] = this.cardUuid;
    data['text'] = this.text;
    return data;
  }
}