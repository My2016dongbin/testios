import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'ParseLocation.dart';

class MapUtil {

  /// 高德地图
  static Future<bool> gotoAMap(longitude, latitude,name) async {
    List point = ParseLocation.bd09_To_Gcj02(latitude,longitude);
    var url = '${Platform.isAndroid ? 'android' : 'ios'}amap://navi?sourceApplication=amap&lat=${point[0]}&lon=${point[1]}&dname=$name&dev=0&style=2';

    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
//      EventBusUtil.getInstance().fire(ShowToast("未检测到高德地图"));
      return false;
    }

    await launch(url);

    return true;
  }

  /// 腾讯地图
  static Future<bool> gotoTencentMap(longitude, latitude,name) async {
    List point = ParseLocation.bd09_To_Gcj02(latitude,longitude);
    var url = 'qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&to=$name&tocoord=${point[0]},${point[1]}&referer=IXHBZ-QIZE4-ZQ6UP-DJYEO-HC2K2-EZBXJ';
    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
//      EventBusUtil.getInstance().fire(ShowToast("未检测到腾讯地图"));
      return false;
    }

    await launch(url);

    return canLaunchUrl;
  }

  /// 百度地图
  static Future<bool> gotoBaiduMap(longitude, latitude,name) async {
    var url = 'baidumap://map/direction?destination=name:$name|latlng:$latitude,$longitude';

    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
//      EventBusUtil.getInstance().fire(ShowToast("未检测到百度地图"));
      return false;
    }

    await launch(url);

    return canLaunchUrl;
  }

  /// 苹果地图
  static Future<bool> gotoAppleMap(longitude, latitude,name) async {
    var url = 'http://maps.apple.com/?&daddr=$latitude,$longitude';

    bool canLaunchUrl = await canLaunch(url);

    if (!canLaunchUrl) {
//      EventBusUtil.getInstance().fire(ShowToast("地图打开失败"));
      return false;
    }

    await launch(url);
  }
}