class NasaPod {
  String date;
  String explanation;
  String hdurl;
  String mediaType;
  String serviceVersion;
  String title;
  String url;

  NasaPod({
    required this.date,
    required this.explanation,
    required this.hdurl,
    required this.mediaType,
    required this.serviceVersion,
    required this.title,
    required this.url,
  });

  factory NasaPod.fromJson(Map<String, dynamic> json) => NasaPod(
        date: json['date'],
        explanation: json['explanation'],
        hdurl: json['hdurl'],
        mediaType: json['media_type'],
        serviceVersion: json['service_version'],
        title: json['title'],
        url: json['url'],
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'explanation': explanation,
        'hdurl': hdurl,
        'media_type': mediaType,
        'service_version': serviceVersion,
        'title': title,
        'url': url,
      };
}
