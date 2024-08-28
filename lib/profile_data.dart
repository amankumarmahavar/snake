
class ProfileInfo {
  final int id;
  final String name;
  final int highScore;
  ProfileInfo({required this.id, required this.name, required this.highScore});

  ProfileInfo.fromMap(Map<String, dynamic> item)
      : id = item['id'], 
      name = item["name"]!,
        highScore = item["highScore"]!;

  Map<String, dynamic> toMap(profileInfo) {
    return {'name': name, 'highScore': highScore};
  }
}

// class Profiles extends ChangeNotifier {
//   List<ProfileInfo> _profiles = [];
//   List<ProfileInfo> get profiles => _profiles;

//   void addProfile(String name) {
//     _profiles.add(ProfileInfo(name: name, highScore: 0));
//     notifyListeners();
//   }

//   void removeProfile(ProfileInfo profileInfo) {
//     _profiles.removeAt(_profiles.indexOf(profileInfo));
//     notifyListeners();
//     print(_profiles.indexOf(profileInfo));
//   }
// }
