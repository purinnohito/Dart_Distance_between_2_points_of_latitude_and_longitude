// Copyright 2021/05/27 purinnohito
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import 'dart:math';
import 'dart:core';

/**
 * 以下参考にしたサイト、ソースコード
 * 
 * - flutter-geolocator
 * https://github.com/Baseflow/flutter-geolocator
 * - 2つの座標間の距離を求める
 * https://qiita.com/chiyoyo/items/b10bd3864f3ce5c56291
 * - 緯度経度から2点間の距離を求める
 * https://petit-noise.net/blog/%E7%B7%AF%E5%BA%A6%E7%B5%8C%E5%BA%A6%E3%81%8B%E3%82%892%E7%82%B9%E9%96%93%E3%81%AE%E8%B7%9D%E9%9B%A2%E3%82%92%E6%B1%82%E3%82%81%E3%82%8B/
 * - 師匠の散歩
 * http://tancro.e-central.tv/grandmaster/excel/jordan_etc.html
 * - 2地点間の距離の計算
 * https://www.trail-note.net/tech/calc_distance/
 * - 地球上の2地点間の距離を取得するアルゴリズム(ヒュベニ or 球面三角法)比較【JavaScript】
 * https://tech-blog.s-yoshiki.com/entry/8
 * - hubeny-distance.js
 * https://gist.github.com/hirohitokato/03e98332b10a9ff211e2d9b8d9c3d4fe
 * - geokit
 * https://github.com/geokit/geokit
 * - Railsで緯度経度の距離計算を実装した話
 * https://tech.raksul.com/2020/07/31/rails_distance_calculation/
 * - 緯度・経度の 1度はどれくらいの長さがあるのか
 * https://www.wingfield.gr.jp/archives/9721
 * - 緯度経度から距離を計算する
 * https://qiita.com/tfukumori/items/0792904fecdbef4c2ed1
 * - 座標系とは｜座標系の種類・平面直角座標系について解説
 * https://club.informatix.co.jp/?p=708
 * - 座標系と測地系
 * https://www.cadjapan.com/topics/cim/useful/words/171017_02.html
 * - 地球上の2点間の距離の求め方
 * https://qiita.com/port-development/items/eea3a0a225be47db0fd4
 * - 2点の座標の距離を求める方法
 * https://lab.syncer.jp/Web/JavaScript/Snippet/34/
 * - 2点間の距離と角度と座標の求め方
 * https://qiita.com/Hoshi_7/items/d04936883ff3eb1eed2d
 * - 距離と方位角の計算
 * https://vldb.gsi.go.jp/sokuchi/surveycalc/surveycalc/bl2stf.html
 * - 2点間の距離計算 (C, Clojure, Go, Haskell, Java, LOGO, OCaml, Ruby, Rust, Scratch, Swift)
 * https://qiita.com/niwasawa/items/5128101ef93a56e8a6af
 */

// -----平面三角法-----

/// ２点間の直線距離を求める
/// 緯度1[lat1]始点緯度(十進度)
/// と
/// 経度1[lon1]始点緯度(十進度)
/// からなる1点と、
/// 緯度2[lat2]始点緯度(十進度)
/// と
/// 経度2[lon2]始点緯度(十進度)
/// からなる1点との距離を
/// 単純な平面として計算する(平面三角法)
/// 計算結果は[double]型(単位:m)で返す
double flatDistance(double lat1, double lon1, double lat2, double lon2) {
  // 緯度の差分をmに変換
  final latLength = per_latitude_degree * (lat1 - lat2);
  // 経度の差分をmに変換
  final lngLength = _perLongitudeDegree(lat1) * (lon1 - lon2);
  // 平方根で距離を割り出す
  return sqrt(pow(latLength, 2) + pow(lngLength, 2));
}

// -----簡易式 - 球面三角法-----

/// ２点間の直線距離を求める
/// 緯度1[lat1]と経度1[lon1]からなる1点と、
/// 緯度2[lat2]と経度2[lon2]からなる1点との距離を
/// 簡易式(球面三角法)で球体と仮定して計算する
/// 計算結果は[double]型(単位:m)で返す
double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
  // 緯度経度をラジアンに変換
  final radLat1 = _toRadians(lat1); // 緯度１
  final radLon1 = _toRadians(lon1); // 経度１
  final radLat2 = _toRadians(lat2); // 緯度２
  final radLon2 = _toRadians(lon2); // 経度２

  final averageLat = (radLat1 - radLat2) / 2;
  final averageLon = (radLon1 - radLon2) / 2;
  return equatorialRadius *
      2 *
      asin(sqrt(pow(sin(averageLat), 2) +
          cos(radLat1) * cos(radLat2) * pow(sin(averageLon), 2)));
}

/// この関数はラジアンで引数を渡す
/// 原典は地点2から見た地点1の方位角です
/// 地点2と地点1の経緯度を入れ替えて地点1から見た地点2の方位角とした 二点間の向きを返す
/// 緯度1[t1]と経度1[g1]からなる1点と、
/// 緯度2[t2]と経度2[g2]からなる1点との距離を
/// 簡易式(球面三角法)で球体と仮定して計算する
/// 計算結果は[double]型(度)で返す
double simpleAngle(double t1, double g1, double t2, double g2) {
  final t1d = atan((1 - henpei) * tan(t1));
  final t2d = atan((1 - henpei) * tan(t2));
  final dL = g1 - g2;
  var zc = atan(sin(dL) / (cos(t1d) * tan(t2d) - sin(t1d) * cos(dL)));
  if (dL < 0) {
    zc = (zc > 0) ? (pi - zc) : -zc;
  } else {
    zc = (zc > 0) ? (2 * pi - zc) : (pi - zc);
  }
  if (zc > 2 * pi) {
    zc = zc - 2 * pi;
  }
  return _toDegree(zc);
}

// -----Haversineの公式-----

/// ２点間の直線距離を求める（Haversineの公式）
/// 緯度1[lat1]と経度1[lon1]からなる1点と、
/// 緯度2[lat2]と経度2[lon2]からなる1点との距離を
/// Haversineの公式をつかい計算する
/// 計算結果は[double]型(単位:m)で返す
double distanceHaversine(double lat1, double lon1, double lat2, double lon2) {
  final x1 = lat2 - lat1;
  final dLatH = _toRadians(x1) / 2;
  final x2 = lon2 - lon1;
  final dLonH = _toRadians(x2) / 2;
  final a = sin(dLatH) * sin(dLatH) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLonH) * sin(dLonH);
  return easyradius * (2 * atan2(sqrt(a), sqrt(1 - a)));
}

// -----Hubenyの公式-----

/// ２点間の直線距離を求める（Hubenyの公式）
/// 緯度1[lat1]と経度1[lon1]からなる1点と、
/// 緯度2[lat2]と経度2[lon2]からなる1点との距離を
/// Hubenyの公式を使い計算する
/// 計算結果は[double]型(単位:m)で返す
double distanceHubeny(double lat1, double lon1, double lat2, double lon2) {
  // 緯度経度をラジアンに変換
  final radLat1 = _toRadians(lat1); // 緯度１
  final radLon1 = _toRadians(lon1); // 経度１
  final radLat2 = _toRadians(lat2); // 緯度２
  final radLon2 = _toRadians(lon2); // 経度２
  // 緯度差
  final radLatDiff = radLat1 - radLat2;
  // 経度差算
  final radLonDiff = radLon1 - radLon2;
  // 平均緯度
  final radLatAve = (radLat1 + radLat2) / 2.0;
  // 測地系による値の違い
  // final b = 6356752.314140356; // 極半径
  //$e2 = ($a*$a - $b*$b) / ($a*$a);
  //$a1e2 = $a * (1 - $e2);
  final a = equatorialRadius; // 赤道半径
  final sinLat = sin(radLatAve);
  final w2 = 1.0 - e2 * (sinLat * sinLat);
  final m = a1e2 / (sqrt(w2) * w2); // 子午線曲率半径M
  final n = a / sqrt(w2); // 卯酉線曲率半径
  final t1 = m * radLatDiff;
  final t2 = n * cos(radLatAve) * radLonDiff;
  final dist = sqrt((t1 * t1) + (t2 * t2));
  return dist;
}

// -----測地線航海算法バージョン-----

/// ２点間の直線距離を求める(ラジアンバージョン)
/// 測地線航海算法バージョン
/// 緯度1[t1]と経度1[g1]からなる1点と、
/// 緯度2[t2]と経度2[g2]からなる1点との距離を
/// 測地線航海算法を使って計算する
/// 計算結果は[double]型(単位:m)で返す
double lambertAndoyer(double t1, double g1, double t2, double g2) {
  final u1 = atan((1 - henpei) * tan(t1));
  final u2 = atan((1 - henpei) * tan(t2));
  final x = acos(sin(u1) * sin(u2) + cos(u1) * cos(u2) * cos(g1 - g2));
  final dP = henpei /
      8 *
      ((sin(x) - x) * pow(sin(u1) + sin(u2), 2) / pow(cos(x / 2), 2) -
          (sin(x) + x) * pow(sin(u1) - sin(u2), 2) / pow(sin(x / 2), 2));
  return equatorialRadius * (x + dP);
}

/// Lambert-Andoyer(度数法->Radians)
/// ２点間の直線距離を求める
/// 測地線航海算法バージョン
/// 緯度1[lat1]と経度1[lon1]からなる1点と、
/// 緯度2[lat2]と経度2[lon2]からなる1点との距離を
/// 測地線航海算法を使って計算する
/// 計算結果は[double]型(単位:m)で返す
double lambertAndoyerDegree(
    double lat1, double lon1, double lat2, double lon2) {
  return lambertAndoyer(
      _toRadians(lat1), _toRadians(lon1), _toRadians(lat2), _toRadians(lon2));
}

// -----小野の式バージョン-----

/// 小野の式(Radians)
/// ２点間の直線距離を求める
/// 小野の式バージョン
/// 緯度1[t1]と経度1[g1]からなる1点と、
/// 緯度2[t2]と経度2[g2]からなる1点との距離を
/// 小野の式を使い計算する
/// 計算結果は[double]型(単位:m)で返す
double ono(double t1, double g1, double t2, double g2) {
  final u1 = atan((1 - henpei) * tan(t1));
  final u2 = atan((1 - henpei) * tan(t2));
  final su1 = sin(u1);
  final su2 = sin(u2);
  final x = acos(su1 * su2 + cos(u1) * cos(u2) * cos(g1 - g2));
  final sx = sin(x);
  final cx = cos(x);
  final c = pow((su1 + su2), 2);
  final d = pow((su1 - su2), 2);
  final af = equatorialRadius * henpei;
  final p = af * (x - sx) / (4 * (1 + cx));
  final q = af * (x + sx) / (4 * (1 - cx));
  return equatorialRadius * x - c * p - d * q;
}

/// 小野の式(度数法->Radians)
/// ２点間の直線距離を求める
/// 小野の式バージョン
/// 緯度1[lat1]と経度1[lon1]からなる1点と、
/// 緯度2[lat2]と経度2[lon2]からなる1点との距離を
/// 小野の式を使い計算する
/// 計算結果は[double]型(単位:m)で返す
double onoDegree(double lat1, double lon1, double lat2, double lon2) {
  return ono(
      _toRadians(lat1), _toRadians(lon1), _toRadians(lat2), _toRadians(lon2));
}

/// この関数はラジアンで引数を渡す
/// 原典は地点2から見た地点1の方位角です
/// 地点2と地点1の経緯度を入れ替えて地点1から見た地点2の方位角とした 二点間の向きを返す
/// 緯度1[t1]と経度1[g1]からなる1点と、
/// 緯度2[t2]と経度2[g2]からなる1点との距離を
/// 簡易式(球面三角法)で球体と仮定して計算する
/// 計算結果は[double]型(度)で返す
double onoAzimus(double t1, double g1, double t2, double g2) {
  final u1 = atan(radius_short / equatorialRadius * tan(t1));
  final u2 = atan(radius_short / equatorialRadius * tan(t2));
  final x = acos(sin(u1) * sin(u2) + cos(u1) * cos(u2) * cos(g1 - g2));
  final cta = acos((sin(u2) - sin(u1) * cos(x)) / (sin(x) * cos(u1)));
  if (sin(g1 - g2) < 0) {
    return cta;
  } //else
  return 2 * pi - cta;
}

// コードの移植のみ、以下元のコメント
// ' ==========================================================================
// ' https://www.jstage.jst.go.jp/article/jinnavi/133/0/133_KJ00005001277/_pdf
// ' 大圏航海算法　平成9年9月　河合雅司　富山高専（旧富山商船高等）
// ' 文献に記載の　赤道半径　6377399.155　扁平率　1/299.152813　から
// ' 本文献は　日本測地系で計算を行っていることがわかる
// ' 他の測地系の赤道半径・扁平率でこの関数が使えるかどうかは文献には記載が無い
// ' 本プログラムでは、赤道半径・扁平率を世界測地系(GRS80)で計算をおこなっている
// ' 以下の内容を、前後の法則性・精度の確認、で誤植と判断し変更を行った
// ' 　3章式(9)の「B3=... -e^4/32*cosm^4」を「-e^6/32*cosm^4」とした
// ' ==========================================================================
double jordanDirect(
    double t1, double g1, double houikaku, double length, String key) {
  // final u1 = atan((1 - henpei) * tan(t1));
  final e2 = henpei * (2 - henpei); //第一離心率の2乗
  final e4 = e2 * e2;
  final e6 = e4 * e2;
  final e8 = e6 * e2;
  final e_2 = e2 / (1 - e2); // 第二離心率の2乗
  final sinm = cos(t1) * sin(houikaku);
  final cos2m = 1 - pow(sinm, 2);
  final cos4m = cos2m * cos2m;
  final cos6m = cos4m * cos2m;
  final e4cos2m = e4 * cos2m;
  final e6cos4m = e6 * cos4m;
  final e8cos6m = e8 * cos6m;
  final m = atan(tan(t1) / cos(houikaku));
  final k2 = e_2 * cos2m;
  final k4 = k2 * k2;
  final k6 = k4 * k2;
  final k8 = k6 * k2;
  final k10 = k8 * k2;
  final a1 = 1 +
      k2 / 4 -
      3 / 64 * k4 +
      5 / 256 * k6 -
      175 / 16384 * k8 +
      441 / 65536 * k10;
  final a3 = 1 / a1;
  final b3 =
      (k2 / 4 - k4 / 16 + 15 / 512 * k6 - 35 / 2048 * k8 + 735 / 65536 * k10) /
          a1;
  final c3 =
      (k4 / 128 - 3 / 512 * k6 + 35 / 8192 * k8 - 105 / 32768 * k10) / a1;
  final d3 = (k6 / 1536 - 5 / 6144 * k8 + 105 / 131072 * k10) / a1;
  final e3 = (5 / 65536 * k8 - 35 / 262144 * k10) / a1;
  final f3 = (7 / 655360 * k10) / a1;
  var sigma = a3 * length / radius_short;
  var count = 0;
  do {
    final dS = sigma;
    sigma = a3 * length / radius_short +
        b3 * sin(dS) * cos(2 * m + dS) +
        c3 * sin(2 * dS) * cos(4 * m + 2 * dS) +
        d3 * sin(3 * dS) * cos(6 * m + 3 * dS) +
        e3 * sin(4 * dS) * cos(8 * m + 4 * dS) +
        f3 * sin(5 * dS) * cos(10 * m + 5 * dS);
    if (((sigma - dS) / sigma).abs() < 0.000000000000001) {
      break;
    }
    count++;
  } while (count < 12);
  final u2 = asin(sin(t1) * cos(sigma) + cos(t1) * sin(sigma) * cos(houikaku));
  if (key == "lat") {
    final t2 = atan(equatorialRadius / radius_short * tan(u2));
    return _toDegree(t2);
  } else if (key == "count") {
    return (count as double);
  }
  final a5 = e2 / 2 * (1 + e2 / 4 + e4 / 8 + 5 / 64 * e6) -
      e4cos2m / 16 * (1 + e2 + 15 / 16 * e4) +
      3 / 128 * e6cos4m * (1 + 15 / 8 * e2) -
      25 / 2048 * e8cos6m;
  final b5 = e4cos2m / 16 * (1 + e2 + 15 / 16 * e4) -
      e6cos4m / 32 * (1 + 15 / 8 * e2) +
      75 / 4096 * e8cos6m;
  final c5 = e6cos4m / 256 * (1 + 15 / 8 * e2) - 15 / 4096 * e8cos6m;
  final d5 = 5 / 12288 * e8cos6m;
  final dL = atan2(
      (sin(sigma) * sin(houikaku) * cos(t1)), (cos(sigma) - sin(t1) * sin(u2)));
  // If Cos(Sigma) - Sin(t1) * Sin(u2) < 0 Then dL = dL + PI
  // 実際に計算してみると、この条件文をコメントアウトしたほうが良い結果となった
  final x = a5 * sigma +
      b5 * sin(sigma) * cos(2 * m + sigma) +
      c5 * sin(2 * sigma) * cos(4 * m + 2 * sigma) +
      d5 * sin(3 * sigma) * cos(6 * m + 3 * sigma);
  final dLamda = dL - sinm * x;
  var g2 = g1 + dLamda;
  if (g2 > 2 * pi) {
    g2 = g2 - 2 * pi;
  }
  return _toDegree(g2);
}

enum JordanInverseType {
  sokuchisencyo,
  houikaku,
}

// ---------------------------------------------------
// https://www.jstage.jst.go.jp/article/jinnavi/133/0/133_KJ00005001277/_pdf
// 大圏航海算法　平成9年9月　河合雅司　富山高専（旧富山商船高等）
// 回転楕円体の2点から、測地線距離と方位角を求める
/// Jordan Direct/Inverse Method / ヨルダンの式(度数法)
/// ２点間の直線距離を求める
/// ヨルダンの式バージョン
/// 緯度1[lat1]と経度1[lon1]からなる1点と、
/// 緯度2[lat2]と経度2[lon2]からなる1点との距離を
/// ヨルダンの式を使い計算する。
/// 引数[kry]に[JordanInverseType.sokuchisencyo]を渡すと距離計算になる。(デフォルト)
/// 計算結果は[double]型(単位:m)で返す
/// [houikaku]キーを渡すと方位角を返す
/// 計算結果は[double]型(単位:度)で返す
double jordanInverse(double td1, double g1, double td2, double g2,
    {JordanInverseType key = JordanInverseType.sokuchisencyo}) {
  final f = henpei;
  final tant1 = (1 - f) * tan(td1);
  final t1 = atan(tant1);
  final t2 = atan((1 - f) * tan(td2));
  final e2 = f * (2 - f); // 第一離心率の2乗
  final e4 = e2 * e2;
  final e6 = e4 * e2;
  final e8 = e4 * e4;
  final e_2 = e2 / (1 - e2); // 第二離心率の2乗
  // final phi = (t1 + t2) / 2; // 2点の平均緯度
  // final dPhi = t2 - t1; // 2点の緯度差
  final dL = g2 - g1;
  final sint1 = sin(t1);
  final cost1 = cos(t1);
  final sint2 = sin(t2);
  final cost2 = cos(t2);
  var lamda = dL;
  var count = 0;
  double cos2m = 0.0;
  double sigma = 0.0;
  double m = 0.0;
  do {
    final lamda0 = lamda;
    final sinL = sin(lamda);
    final cosS = sint1 * sint2 + cost1 * cost2 * cos(lamda);
    sigma = acos(cosS);
    final sinS = sin(sigma);
    final sinZ = sinL * cost2 / sinS;
    final cosZ = (sint2 - sint1 * cosS) / (cost1 * sinS);
    final sinm = cost1 * sinZ;
    cos2m = 1 - pow(sinm, 2);
    final cos4m = cos2m * cos2m;
    final cos6m = cos2m * cos4m;
    m = atan2(tant1, cosZ);
    final a3 = e2 / 2 * (1 + e2 / 4 + e4 / 8 + 5 / 64 * e6) -
        e4 * cos2m / 16 * (1 + e2 + 15 / 16 * e4) +
        3 / 128 * e6 * cos4m * (1 + 15 / 8 * e2) -
        25 / 2048 * e8 * cos6m;
    final b3 = e4 / 16 * cos2m * (1 + e2 + 15 / 16 * e4) -
        e6 / 32 * cos4m * (1 + 15 / 8 * e2) +
        75 / 4096 * e8 * cos6m;
    final c3 = e6 / 256 * cos4m * (1 + 15 / 8 * e2) - 15 / 4096 * e8 * cos6m;
    final d3 = 5 / 12288 * e8 * cos6m;
    lamda = a3 * sigma +
        b3 * sinS * cos(2 * m + sigma) +
        c3 * sin(2 * sigma) * cos(4 * m + 2 * sigma) +
        d3 * sin(3 * sigma) * cos(6 * m + 3 * sigma);
    lamda = dL + sinm * lamda;
    if (((lamda - lamda0) / lamda).abs() < 0.000000000000001) {
      break;
    }
    count++;
  } while (count < 8);
  if (key == JordanInverseType.sokuchisencyo) {
    final k2 = e_2 * cos2m;
    final k4 = k2 * k2;
    final k6 = k4 * k2;
    final k8 = k6 * k2;
    final k10 = k8 * k2;
    final a1 = 1 +
        k2 / 4 -
        3 / 64 * k4 +
        5 / 256 * k6 -
        175 / 16384 * k8 +
        441 / 65536 * k10;
    final b1 =
        k2 / 4 - k4 / 16 + 15 / 512 * k6 - 35 / 2048 * k8 + 735 / 65536 * k10;
    final c1 = k4 / 128 - 3 / 512 * k6 + 35 / 8192 * k8 - 105 / 32768 * k10;
    final d1 = k6 / 1536 - 5 / 6144 * k8 + 105 / 131072 * k10;
    final e1 = 5 / 65536 * k8 - 35 / 262144 * k10;
    final f1 = 7 / 655360 * k10;
    final x = a1 * sigma -
        b1 * sin(sigma) * cos(2 * m + sigma) -
        c1 * sin(2 * sigma) * cos(4 * m + 2 * sigma) -
        d1 * sin(3 * sigma) * cos(6 * m * 3 * sigma) -
        e1 * sin(4 * sigma) * cos(8 * m + 4 * sigma) -
        f1 * sin(5 * sigma) * cos(10 * m + 5 * sigma);
    return radius_short * x;
  } else if (key == JordanInverseType.houikaku) {
    final x = acos((sint2 - sint1 * cos(sigma)) / (cost1 * sin(sigma)));
    final sinx = sin(dL) * cost2 / sin(sigma);
    if (sinx < 0) {
      return 360 - _toDegree(x);
    } else {
      return _toDegree(x);
    }
  }
  throw new Error();
}

// Lambert-Andoyer(度数法->Radians)
double jordanInverseDegree(double lat1, double lon1, double lat2, double lon2) {
  return jordanInverse(
      _toRadians(lat1), _toRadians(lon1), _toRadians(lat2), _toRadians(lon2));
}

const fhenpei = 298.257222101; // 扁平率の逆数
const henpei = 1 / fhenpei; // 扁平率
const equatorialRadius = 6378137.0; // 赤道半径(a)
const radius_short = equatorialRadius * (1 - henpei); // 短半径
const a1e2 = 6335439.32708317; // 赤道上の子午線曲率半径
const e2 = 0.00669438002301188; // 第一離心率^2
const per_latitude_degree = 111181.9; // 緯度1度あたりのm
const easyradius = 6371009.0;

// 度-> ラジアン
double _toRadians(double degree) {
  return degree * pi / 180;
}

// ラジアン-> 度
double _toDegree(double rad) {
  return rad * 180 / pi;
}

double _perLongitudeDegree(lat) =>
    _toRadians(easyradius) * cos(_toRadians(lat));
