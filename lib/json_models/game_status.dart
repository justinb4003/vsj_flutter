/*
JJB: If there's one thing I'm not happy about with Dart it's having to write
boilerplate code fro JSON object deserialization.
*/

class GameStatus {
    String deciderUuid;
    List<PlayerList> playerList;
    PromptCard promptCard;
    List<RoundResults> roundResults;
    List<Scores> scores;
    List<WaitingOn> waitingOn;
    Submissions submissions;
  
    GameStatus(
        {this.deciderUuid,
        this.playerList,
        this.promptCard,
        this.roundResults,
        this.scores,
        this.waitingOn,
        this.submissions});
  
    GameStatus.fromJson(Map<String, dynamic> json) {
      deciderUuid = json['decider_uuid'];
      if (json['player_list'] != null) {
        playerList = new List<PlayerList>();
        json['player_list'].forEach((v) {
          playerList.add(new PlayerList.fromJson(v));
        });
      }
      promptCard = json['prompt_card'] != null
          ? new PromptCard.fromJson(json['prompt_card'])
          : null;
      if (json['round_results'] != null) {
        roundResults = new List<RoundResults>();
        json['round_results'].forEach((v) {
          roundResults.add(new RoundResults.fromJson(v));
        });
      }
      if (json['scores'] != null) {
        scores = new List<Scores>();
        json['scores'].forEach((v) {
          scores.add(new Scores.fromJson(v));
        });
      }
      if (json['waiting_on'] != null) {
        waitingOn = new List<WaitingOn>();
        json['waiting_on'].forEach((v) {
          waitingOn.add(new WaitingOn.fromJson(v));
        });
      }
      submissions = json['submissions'] != null
          ? new Submissions.fromJson(json['submissions'])
          : null;
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['decider_uuid'] = this.deciderUuid;
      if (this.playerList != null) {
        data['player_list'] = this.playerList.map((v) => v.toJson()).toList();
      }
      if (this.promptCard != null) {
        data['prompt_card'] = this.promptCard.toJson();
      }
      if (this.submissions != null) {
        data['submissions'] = this.submissions.toJson();
      }
      if (this.roundResults != null) {
        data['round_results'] = this.roundResults.map((v) => v.toJson()).toList();
      }
      if (this.scores != null) {
        data['scores'] = this.scores.map((v) => v.toJson()).toList();
      }
      if (this.waitingOn != null) {
        data['waiting_on'] = this.waitingOn.map((v) => v.toJson()).toList();
      }
      return data;
    }
  }
  
  class PlayerList {
    String playerName;
    String playerUuid;
  
    PlayerList({this.playerName, this.playerUuid});
  
    PlayerList.fromJson(Map<String, dynamic> json) {
      playerName = json['player_name'];
      playerUuid = json['player_uuid'];
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['player_name'] = this.playerName;
      data['player_uuid'] = this.playerUuid;
      return data;
    }
  }
  
  class PromptCard {
    String cardUuid;
    int pick;
    String text;
  
    PromptCard({this.cardUuid, this.pick, this.text});
  
    PromptCard.fromJson(Map<String, dynamic> json) {
      cardUuid = json['card_uuid'];
      pick = json['pick'];
      text = json['text'];
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['card_uuid'] = this.cardUuid;
      data['pick'] = this.pick;
      data['text'] = this.text;
      return data;
    }
  }
  
  class RoundResults {
    PromptCard promptCard;
    String winnerUuid;
    List<WinningCards> winningCards;
  
    RoundResults({this.promptCard, this.winnerUuid, this.winningCards});
  
    RoundResults.fromJson(Map<String, dynamic> json) {
      promptCard = json['prompt_card'] != null
          ? new PromptCard.fromJson(json['prompt_card'])
          : null;
      winnerUuid = json['winner_uuid'];
      if (json['winning_cards'] != null) {
        winningCards = new List<WinningCards>();
        json['winning_cards'].forEach((v) {
          winningCards.add(new WinningCards.fromJson(v));
        });
      }
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      if (this.promptCard != null) {
        data['prompt_card'] = this.promptCard.toJson();
      }
      data['winner_uuid'] = this.winnerUuid;
      if (this.winningCards != null) {
        data['winning_cards'] = this.winningCards.map((v) => v.toJson()).toList();
      }
      return data;
    }
  }
  
  class WinningCards {
    String cardUuid;
    String text;
  
    WinningCards({this.cardUuid, this.text});
  
    WinningCards.fromJson(Map<String, dynamic> json) {
      cardUuid = json['card_uuid'];
      text = json['text'];
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['card_uuid'] = this.cardUuid;
      data['text'] = this.text;
      return data;
    }
  }
  
  class Scores {
    String playerUuid;
    int score;
  
    Scores({this.playerUuid, this.score});
  
    Scores.fromJson(Map<String, dynamic> json) {
      playerUuid = json['player_uuid'];
      score = json['score'];
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['player_uuid'] = this.playerUuid;
      data['score'] = this.score;
      return data;
    }
  }
  
  class WaitingOn {
    String playerUuid;
  
    WaitingOn({this.playerUuid});
  
    WaitingOn.fromJson(Map<String, dynamic> json) {
      playerUuid = json['player_uuid'];
    }
  
    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['player_uuid'] = this.playerUuid;
      return data;
    }
  }

 class Submissions {
  List<Players> players;

  Submissions({this.players});

  Submissions.fromJson(Map<String, dynamic> json) {
    if (json['players'] != null) {
      players = new List<Players>();
      json['players'].forEach((v) {
        players.add(new Players.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.players != null) {
      data['players'] = this.players.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Players {
  List<Cards> cards;
  String playerName;
  String playerUuid;

  Players({this.cards, this.playerName, this.playerUuid});

  Players.fromJson(Map<String, dynamic> json) {
    if (json['cards'] != null) {
      cards = new List<Cards>();
      json['cards'].forEach((v) {
        cards.add(new Cards.fromJson(v));
      });
    }
    playerName = json['player_name'];
    playerUuid = json['player_uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cards != null) {
      data['cards'] = this.cards.map((v) => v.toJson()).toList();
    }
    data['player_name'] = this.playerName;
    data['player_uuid'] = this.playerUuid;
    return data;
  }
}

class Cards {
  String cardUuid;
  String text;

  Cards({this.cardUuid, this.text});

  Cards.fromJson(Map<String, dynamic> json) {
    cardUuid = json['card_uuid'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_uuid'] = this.cardUuid;
    data['text'] = this.text;
    return data;
  }
} 