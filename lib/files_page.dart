import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:special_calculator/consts.dart';
import 'package:special_calculator/empty_page.dart';
import 'package:special_calculator/hive_input.dart';
import 'package:special_calculator/main.dart';

enum MenuItem { changePass }

class FilesPage extends StatefulWidget {
  const FilesPage({Key? key}) : super(key: key);

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  List<PrivateFiles> privateList = [];
  final passwordController = TextEditingController();

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.black,
            elevation: 0.0,
            title: const Text(
              'Change Password',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              cursorColor: Colors.white,
              keyboardType: TextInputType.number,
              controller: passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(12)),
                  hintText: 'New Password',
                  hintStyle: const TextStyle(color: Colors.white)),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: buildButtonStyle(),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                style: buildButtonStyle(),
                onPressed: () {
                  if (passwordController.text.trim().isDigit()) {
                    setState(() async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString('password',
                          passwordController.text.trim().toString());
                      Navigator.pop(context);
                    });
                  } else {
                    toasty(context, "Use Natural Number As Your Password",
                        bgColor: Colors.redAccent,
                        textColor: whiteColor,
                        gravity: ToastGravity.BOTTOM);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Hidden Files'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new)),
          actions: [
            PopupMenuButton<MenuItem>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.lock_reset, color: Colors.white),
              color: Colors.black,
              onSelected: (value) async {
                _displayTextInputDialog(context);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: MenuItem.changePass,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                            width: 10,
                            child: Center(
                                child:
                                    Icon(Icons.password, color: Colors.white)))
                      ],
                    )),
              ],
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/Hidden_background.jpg'),
                  fit: BoxFit.cover)),
          child: privateList.isEmpty
              ? const SafeArea(child: EmptyPage())
              : SafeArea(
                  // child: Image.file(File(privateList[0].path!)),
                  child: animationLimiter(),
                ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
                type: FileType.any,
              );
              if (result == null) return;
              for (int i = 0; i < result.files.length; i++) {
                await MyHomePage.privateBox.add(PrivateFiles(
                    path: result.files[i].path,
                    size: result.files[i].size,
                    name: result.files[i].name,
                    extension: result.files[i].extension));
              }
              setState(() {
                getData();
              });
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.add, color: Colors.black)),
      );

  AnimationLimiter animationLimiter() {
    return AnimationLimiter(
      child: GridView.count(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(10),
        crossAxisCount: 2,
        children: List.generate(
          privateList.length,
          (int index) {
            final file = privateList[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 500),
              columnCount: 2,
              child: ScaleAnimation(
                duration: const Duration(milliseconds: 900),
                curve: Curves.fastLinearToSlowEaseIn,
                scale: 1.5,
                child: FadeInAnimation(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: buildFile(file, index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildFile(PrivateFiles file, int index) {
    final kb = file.size! / 1024;
    final mb = kb / 1024;
    final fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)}MB' : '${kb.toStringAsFixed(2)}KB';
    // final extension = file.extension ?? 'none';
    final color = getColor(file.extension);
    return GestureDetector(
      onTap: () => openFile(file.path!),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.black,
            title: Image.asset('assets/deleting-deleted.gif'),
            content: const Text(
              'Delete this file?',
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                      const Text('No', style: TextStyle(color: Colors.white))),
              TextButton(
                  onPressed: () {
                    setState(() {
                      MyHomePage.privateBox.deleteAt(index);
                      getData();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  file.extension!,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(file.name!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
                overflow: TextOverflow.ellipsis),
            Text(fileSize,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void openFile(String path) {
    OpenFile.open(path);
  }

  Color getColor(String? extension) {
    switch (extension) {
      case 'mp3':
        {
          return myOrange;
        }
      case 'jpg':
        {
          return myPurple;
        }
      case 'pdf':
        {
          return myRed;
        }
      case 'mp4':
        {
          return myGreen;
        }
      default:
        {
          return myBlue;
        }
    }
  }

  Future<File> saveFilePermanently(PlatformFile file) async {
    Directory appStorage = await getApplicationDocumentsDirectory();
    final newFile = File('${appStorage.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  void getData() {
    privateList.clear();
    for (var value in MyHomePage.privateBox.values) {
      privateList.add(PrivateFiles(
          path: value.path,
          size: value.size,
          name: value.name,
          extension: value.extension));
    }
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 30, vertical: 7)),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(7))),
      overlayColor: MaterialStateProperty.all(Colors.purple),
      backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
    );
  }
}
