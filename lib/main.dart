// Copyright 2021/05/27 purinnohito
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import 'package:flutter/material.dart';

import 'distance_between.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// 各距離の計算式を3000回繰り返して処理時間をしらべる
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firstLat = 57.05199495787603;
  final firstLon = -135.75878288496574;
  final secLat = 53.564439795047065;
  final secLon = -113.48588125746123;
  String _length = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$firstLat, $firstLon\n$secLat, $secLon\n1,459,355.069(m)',
            ),
            Text('$_length'),
          ],
        ),
      ),
      floatingActionButton: Container(
        child: PopupMenuButton<_CalcType>(
          onSelected: _calcTypeSelected,
          itemBuilder: _menuEntrys,
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          tooltip: 'select calc type',
        ),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
      ),
    );
  }

  List<PopupMenuEntry<_CalcType>> _menuEntrys(BuildContext context) {
    List<PopupMenuEntry<_CalcType>> retList = [];
    _CalcType.values.forEach((element) {
      retList.add(PopupMenuItem<_CalcType>(
        value: element,
        child: Text(element.name()),
      ));
    });
    return retList;
  }

  void _calcTypeSelected(_CalcType result) {
    final loopMax = 30000;
    final sw = Stopwatch();
    double tmpLen = 0;
    int tmpMicro = 0;
    switch (result) {
      case _CalcType.flat:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          flatDistance(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = flatDistance(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
      case _CalcType.simple:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          distanceBetween(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = distanceBetween(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
      case _CalcType.haversine:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          distanceHaversine(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = distanceHaversine(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
      case _CalcType.hubeny:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          distanceHubeny(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = distanceHubeny(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
      case _CalcType.lambertAndoyer:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          lambertAndoyerDegree(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = lambertAndoyerDegree(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
      case _CalcType.ono:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          onoDegree(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = onoDegree(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
      case _CalcType.jordanInverse:
        sw.start();
        for (int i = 0; i < loopMax; ++i) {
          jordanInverseDegree(firstLat, firstLon, secLat, secLon);
        }
        sw.stop();
        tmpLen = jordanInverseDegree(firstLat, firstLon, secLat, secLon);
        tmpMicro = sw.elapsedMicroseconds;
        break;
    }
    setState(() {
      _length = '${result.name()}\n$tmpLen(m)\n$tmpMicro(µs/$loopMax)';
    });
  }
}

enum _CalcType {
  flat,
  simple,
  haversine,
  hubeny,
  lambertAndoyer,
  ono,
  jordanInverse,
}

extension _CalcTypeEx on _CalcType {
  String name() {
    switch (this) {
      case _CalcType.simple:
        return 'simple';
      default:
        break;
    }
    return this.toString();
  }
}
