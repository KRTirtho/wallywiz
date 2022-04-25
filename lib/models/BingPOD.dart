class BingPOD {
  String startDate;
  String endDate;
  String url;
  String copyright;
  String copyrightLink;

  BingPOD({
    required this.startDate,
    required this.endDate,
    required this.url,
    required this.copyright,
    required this.copyrightLink,
  });

  factory BingPOD.fromJson(Map<String, dynamic> json) => BingPOD(
        startDate: json['start_date'],
        endDate: json['end_date'],
        url: json['url'],
        copyright: json['copyright'],
        copyrightLink: json['copyright_link'],
      );

  Map<String, dynamic> toJson() => {
        'start_date': startDate,
        'end_date': endDate,
        'url': url,
        'copyright': copyright,
        'copyright_link': copyrightLink,
      };
}
