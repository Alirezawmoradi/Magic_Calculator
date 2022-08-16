import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:special_calculator/consts.dart';
import 'package:special_calculator/files_page.dart';
import 'package:special_calculator/hive_input.dart';
import 'package:special_calculator/history_page.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PrivateFilesAdapter());
  await Hive.openBox<PrivateFiles>('privateBox');
  Hive.registerAdapter(HistoryAdapter());
  await Hive.openBox<History>('historyBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'main'),
        home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  static Box<History> historyBox = Hive.box<History>('historyBox');
  static Box<PrivateFiles> privateBox = Hive.box<PrivateFiles>('privateBox');
  static List<History> histories = [];
  static double? width;

  static void getHistory() {
    MyHomePage.histories.clear();
    for (var value in historyBox.values) {
      MyHomePage.histories.add(value);
    }
  }

  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String preveiw = '';
  double result = 0;
  bool isDouble = false;
  String calculate = '';


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    MyHomePage.width = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'calculator',
          style: TextStyle(color: myOrange),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const HistoryPage()));
              },
              icon: const Icon(Icons.history, color: myOrange))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/grey_background.jpg'),
                fit: BoxFit.cover)),
        child: Column(children: [
          Expanded(
              flex: 3,
              child: Center(
                  child: Text(preveiw == '' ? '0' : preveiw,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'Calculate')))),
          Expanded(
              flex: 1,
              child: Center(
                  child: Text(result.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'Calculate',
                      )))),
          Expanded(
              flex: 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  rowInColumns(itemBox, rows[0]),
                  rowInColumns(itemBox, rows[1]),
                  rowInColumns(itemBox, rows[2]),
                  rowInColumns(itemBox, rows[3]),
                  rowInColumns(itemBox, rows[4]),
                ],
              )),
        ]),
      ),
    );
  }

  Widget rowInColumns(Function itemBox, List<String> items) {
    return Flexible(
      child: Row(
        children: [
          itemBox(items[0]),
          itemBox(items[1]),
          itemBox(items[2]),
          itemBox(items[3])
        ],
      ),
    );
  }

  Padding itemBox(String item) {
    return Padding(
      padding: EdgeInsets.all(MyHomePage.width! / 24),
      child: FutureBuilder(
          future: password(),
          builder: (context, snapshot) {
            return InkWell(
              onTap: () {
                ///clear
                if (item == 'C') {
                  preveiw = '';
                  result = 0;
                  item = '';
                }
                setState(() {
                  ///calculating
                  if (item == '=') {
                    item = '';
                    Parser parser = Parser();
                    calculate = preveiw.replaceAll('÷', '/');
                    calculate = calculate.replaceAll('×', '*');
                    calculate = calculate.replaceAll('%', '/100');
                    Expression expression = parser.parse(calculate);
                    ContextModel contextModel = ContextModel();
                    result =
                        expression.evaluate(EvaluationType.REAL, contextModel);
                    if (preveiw ==
                        (snapshot.data == null
                            ? '8585'
                            : snapshot.data.toString())) {
                      preveiw = '';
                      result = 0;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FilesPage()));
                    } else {
                      MyHomePage.historyBox.add(History(
                          calculations: preveiw, ans: result.toString()));
                      MyHomePage.getHistory();
                      preveiw = result.toString();
                    }
                  }

                  ///prevent of double operator
                  if (preveiw.isNotEmpty &&
                      operator.contains(item) &&
                      operator.contains(preveiw[preveiw.length - 1])) {
                    preveiw = preveiw.substring(0, preveiw.length - 1);
                  }

                  ///put number after .
                  if (preveiw.endsWith('.') && operator.contains(item)) {
                    item = '';
                  }
                  if (preveiw.isNotEmpty &&
                      preveiw[preveiw.length - 1] == '%') {
                    if (item == '.') {
                      item = '0.';
                    }
                    if (!operator.contains(item) && item != 'D') {
                      item = '×$item';
                    }
                  }
                  if (preveiw.isNotEmpty &&
                      operator.contains(preveiw[preveiw.length - 1]) &&
                      item == '.') {
                    item = '0.';
                  }
                  if (preveiw.isEmpty && item == '.') {
                    item = '0.';
                  }
                  if (preveiw.isEmpty) {
                    if (firstDelete.contains(item)) {
                      item = '';
                    }
                    isDouble = false;
                  }
                  //
                  preveiw += item;
                  ///delete
                  if (item == 'D') {
                    if (preveiw[preveiw.length - 2] == '.') {
                      isDouble = false;
                    }
                    ///is last number a double?
                    if (operator.contains(preveiw[preveiw.length - 2])) {
                      for (int i = preveiw.length - 2; i > 0; i--) {
                        if (!preveiw[i].isInt) {
                          if (preveiw[i] == '.') {
                            isDouble = true;
                          } else {
                            isDouble = false;
                          }
                        }
                      }
                    }
                    preveiw = preveiw.substring(0, preveiw.length - 2);
                  }
                  if (isDouble && item == '.') {
                    preveiw = preveiw.substring(0, preveiw.length - 1);
                  }
                });
                if (preveiw.endsWith('.') && item != 'D') {
                  isDouble = true;
                }
                if (preveiw.isNotEmpty &&
                    operator.contains(preveiw[preveiw.length - 1])) {
                  isDouble = false;
                }
              },
              child: Container(
                height: MyHomePage.width! / 6,
                width: MyHomePage.width! / 6,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorfulButtons.contains(item)
                        ? const Color(0xff032d00)
                        : const Color(0xff3B3B3B).withOpacity(0.8),
                    boxShadow: [
                      const BoxShadow(
                          color: Colors.white24,
                          blurRadius: 5,
                          offset: Offset(-2, -2)),
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(4, 4)),
                    ]),
                child: Center(
                  child: Text(
                    item,
                    style: TextStyle(
                        color: item == 'C'
                            ? Colors.green
                            : item == 'D'
                                ? Colors.red
                                : Colors.white,
                        fontSize: 26),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

Future<dynamic> password() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString('password');
  if (data == null) {
    return;
  }
  return int.parse(data);
}
