import 'package:flutter/material.dart';
import 'package:snake/constant.dart';
import 'package:snake/profile_data.dart';
import 'package:snake/snake_gui.dart';
import 'package:snake/sqlite_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

List<ProfileInfo> profiles = [];

class _ProfilePageState extends State<ProfilePage> {
  @override
  late SqliteService _sqliteService;
  _loadDB() async {
    _sqliteService = SqliteService();
    final db = await _sqliteService.initializeDB();

    _loadProfiles();
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDB();
  }

  _loadProfiles() async {
    final data = await _sqliteService.getItems();
    setState(() {
      profiles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadProfiles();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Text(
              'Profiles',
              style: TextStyle(
                shadows: [Shadow(color: kFoodColor, offset: Offset(0, -7))],
                color: Colors.transparent,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ProfieBadges(
              onRemove: (int id) {
                _sqliteService.deleteItem(id);
                _loadProfiles();
              },
            ),
            SizedBox(
              height: 30,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: CreateNewProfile(
                  onCreate: (String name) {
                    _sqliteService.insertItem(
                        ProfileInfo(id: 0, name: name, highScore: 0));
                    _loadProfiles();
                  },
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
  final Function(String) onCreate;
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
  final Function(int) onRemove;
  const ProfieBadges({
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: profiles
            .map((e) => GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => SnakeGUI(
                            profileInfo: e,
                          )));
                },
                onLongPress: () {
                  onRemove(e.id);
                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.only(
                      bottom: 8.0, top: 8.0, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'high score: ${e.highScore.toString()}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                )))
            .toList(),
      ),
    );
  }
}
