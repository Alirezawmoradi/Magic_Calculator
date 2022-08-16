import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          SvgPicture.asset(
            'assets/Svg_pic.svg',
            height: 200,
            width: 200,
            color: Colors.white,
          ),
          const SizedBox(
            height: 30,
          ),
          const Text('No file available yet!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white)),
          const Spacer(),
        ],
      ),
    );
  }
}
