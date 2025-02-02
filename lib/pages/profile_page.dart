import 'package:flutter/material.dart';
import 'package:snake/constant.dart';
import 'package:snake/model/profile_data.dart';
import 'package:snake/pages/snake_gui.dart';
import 'package:snake/services/sqlite_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ProfileData> _profiles = [];
  bool _isloading = false;
  late SqliteService _sqliteService;

  @override
  void initState() {
    _sqliteService = SqliteService();
    _loadProfiles();
    super.initState();
  }

  void _loadProfiles() async {
    setState(() {
      _isloading = true;
    });
    final data = await _sqliteService.getItems();
    if (data != null) {
      setState(() {
        _profiles = data;
        _isloading = false;
      });
    }
  }

  void onRemove(int id) async {
    int? count = await _sqliteService.deleteItem(id);
    if (count != null) {
      _loadProfiles();
    }
  }

  void onCreate(String name) async {
    int? id = await _sqliteService
        .insertItem(ProfileData(id: 0, name: name, highScore: 0));
    if (id != null) {
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Text(
                    'Profiles',
                    style: TextStyle(
                      shadows: [
                        Shadow(color: kFoodColor, offset: Offset(0, -7))
                      ],
                      color: Colors.transparent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _profiles.isEmpty
                      ? Center(
                          child: Text('Create a profile to begin the game'),
                        )
                      : Column(
                          children: _profiles
                              .map((profileData) => ProfieBadges(
                                  profileData: profileData, onRemove: onRemove))
                              .toList(),
                        ),
                  SizedBox(
                    height: 30,
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: CreateNewProfile(
                        onCreate: onCreate,
                      )),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          'Long press to delete profile',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 177, 49, 40)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class CreateNewProfile extends StatelessWidget {
  final void Function(String) onCreate;
  const CreateNewProfile({
    required this.onCreate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        TextEditingController textEditingController = TextEditingController();
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text('Create new profile'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Name',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancle',
                        style: TextStyle(color: Colors.blueGrey),
                      )),
                  TextButton(
                    onPressed: () {
                      onCreate(textEditingController.text);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(255, 20, 20, 20)),
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            });
      },
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 20, 20, 20),
              borderRadius: BorderRadius.circular(10)),
          child: Text(
            'Add Profile',
            style: TextStyle(color: Colors.white, fontSize: 16),
          )),
    );
  }
}

class ProfieBadges extends StatelessWidget {
  final void Function(int) onRemove;
  final ProfileData profileData;
  const ProfieBadges({
    required this.onRemove,
    required this.profileData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (builder) => SnakeGUI(
                    profileInfo: profileData,
                  )));
        },
        onLongPress: () => onRemove(profileData.id),
        child: Container(
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: 20),
          margin: EdgeInsets.only(bottom: 8.0, top: 8.0, left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                profileData.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'high score: ${profileData.highScore.toString()}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          decoration: BoxDecoration(
              border: Border.all(width: 0.2),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(255, 238, 237, 235),
                    spreadRadius: 2,
                    blurRadius: 10)
              ]
              //     : null,
              ),
        ));
  }
}
