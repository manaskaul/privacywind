import 'dart:convert';

AppModel appDetailsModelFromJson(String str) =>
    AppModel.fromJson(json.decode(str));

class AppModel {
  String title;
  String appId;
  String url;
  String icon;
  String developer;
  String developerId;
  String priceText;
  dynamic price;
  bool free;
  String summary;
  String scoreText;
  dynamic score;

  AppModel({
    this.title,
    this.appId,
    this.url,
    this.icon,
    this.developer,
    this.developerId,
    this.priceText,
    this.price,
    this.free,
    this.summary,
    this.scoreText,
    this.score,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
        title: json['title'],
        appId: json['appId'],
        url: json['url'],
        icon: json['icon'],
        developer: json['developer'],
        developerId: json['developerId'],
        priceText: json['priceText'],
        price: json['price'],
        free: json['free'],
        summary: json['summary'],
        scoreText: json['scoreText'],
        score: json['score']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['appId'] = this.appId;
    data['url'] = this.url;
    data['icon'] = this.icon;
    data['developer'] = this.developer;
    data['developerId'] = this.developerId;
    data['priceText'] = this.priceText;
    data['price'] = this.price;
    data['free'] = this.free;
    data['summary'] = this.summary;
    data['scoreText'] = this.scoreText;
    data['score'] = this.score;
    return data;
  }
}
