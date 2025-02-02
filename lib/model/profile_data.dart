class ProfileData {
  final int id;
  final String name;
  final int highScore;
  ProfileData({required this.id, required this.name, required this.highScore});

  ProfileData.fromMap(Map<String, dynamic> item)
      : id = item['id'],
        name = item["name"]!,
        highScore = item["highScore"]!;

  Map<String, dynamic> toMap(profileInfo) {
    return {'name': name, 'highScore': highScore};
  }
}
