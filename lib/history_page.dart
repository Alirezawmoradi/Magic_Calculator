import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:special_calculator/consts.dart';
import 'main.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void didChangeDependencies() {
    MyHomePage.width = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    MyHomePage.getHistory();
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'History',
            style: TextStyle(color: myOrange),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new, color: myOrange)),
          actions: [myActionButton(context)],
        ),
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/grey_background.jpg'),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: animationMaker(),
          ),
        ));
  }

  AnimationLimiter animationMaker() {
    return AnimationLimiter(
      child: ListView.builder(
        padding: EdgeInsets.all(MyHomePage.width! / 30),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: MyHomePage.histories.length,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            delay: const Duration(milliseconds: 100),
            child: SlideAnimation(
              duration: const Duration(milliseconds: 2500),
              curve: Curves.fastLinearToSlowEaseIn,
              child: FadeInAnimation(
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(milliseconds: 2500),
                child: Container(
                  margin: EdgeInsets.only(bottom: MyHomePage.width! / 20),
                  height: MyHomePage.width! / 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: historyBoxes(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Container historyBoxes(int index) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xff3B3B3B).withOpacity(0.8),
            boxShadow: [
              const BoxShadow(
                  color: Colors.white24, blurRadius: 5, offset: Offset(-2, -2)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(4, 4)),
            ]),
        width: double.infinity * 0.8,
        height: 80,
        child: ListTile(
          title: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              MyHomePage.histories[index].calculations!,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 1,
                  fontFamily: 'Calculate'),
              textAlign: TextAlign.left,
            ),
          ),
          subtitle: Text(
            MyHomePage.histories[index].ans!,
            style: const TextStyle(fontSize: 20, fontFamily: 'Calculate'),
          ),
          trailing: IconButton(
              onPressed: () async {
                MyHomePage.historyBox.deleteAt(index);
                MyHomePage.getHistory();
                setState(() {});
              },
              icon: const Icon(Icons.delete, color: myOrange)),
        ));
  }

  IconButton myActionButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Clear History',
                      style: TextStyle(color: myOrange)),
                  content: const Text('Are you sure?',
                      style: TextStyle(color: myOrange)),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          MyHomePage.historyBox.clear();
                        });
                        MyHomePage.getHistory();
                      },
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(myOrange)),
                      child: const Text('Yes'),
                    ),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(myOrange)),
                        child: const Text('No')),
                  ],
                  actionsPadding: const EdgeInsets.all(15),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  backgroundColor: Colors.grey[900],
                  // buttonPadding: EdgeInsets.all(12),
                );
              });
        },
        icon: const Icon(Icons.delete_forever, color: myOrange),
        tooltip: 'Delete All');
  }
}
