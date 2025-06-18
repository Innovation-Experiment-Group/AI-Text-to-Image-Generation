class Style {
  final String styleId;
  final String name;
  final String description;
  final String previewUrl;

  Style({
    required this.styleId,
    required this.name,
    required this.description,
    required this.previewUrl,
  });

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      styleId: json['styleId'],
      name: json['name'],
      description: json['description'],
      previewUrl: json['previewUrl'],
    );
  }
}
