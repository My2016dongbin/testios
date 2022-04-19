import 'dart:async';
import 'dart:math';

import 'package:flutter_bmflocation/bdmap_location_flutter_plugin.dart';

import 'package:flutter_bmflocation/flutter_baidu_location_android_option.dart';

class LocationUtils {

   static LocationFlutterPlugin locationPlugin = LocationFlutterPlugin();

   static StreamSubscription<Map<String, Object>> locationListener; // 事件监听

   // 启动定位

   static void handleStartLocation({Function callback}) {

    if (null != locationPlugin) {

     _setupListener(callback);

     _setLocOption();

     locationPlugin.startLocation();

    }

   }

   static dynamic parseLocation(double latitude,double longitude){

     return {
       "province": "",
       "city": "",
       "area": "",
     };
   }

   static _setLocOption() async {

    BaiduLocationAndroidOption androidOption = new BaiduLocationAndroidOption();

     androidOption.setCoorType("bd09ll");

    /// 可选，设置返回经纬度坐标类型，默认gcj02

    /// gcj02：国测局坐标；

    /// bd09ll：百度经纬度坐标；

    /// bd09：百度墨卡托坐标；

    /// 海外地区定位，无需设置坐标类型，统一返回wgs84类型坐标

    androidOption.setIsNeedAltitude(true);

    /// 可选，设置是否需要返回海拔高度信息，true为需要返回

    androidOption.setIsNeedAddres(true);

    /// 可选，设置是否需要返回地址信息，true为需要返回

    androidOption.setIsNeedLocationPoiList(true);

    /// 可选，设置是否需要返回周边poi信息，true为需要返回

    androidOption.setIsNeedNewVersionRgc(true);

    /// 可选，设置是否需要返回新版本rgc信息，true为需要返回

    androidOption.setIsNeedLocationDescribe(true);

    /// 可选，设置是否需要返回位置描述信息，true为需要返回

    androidOption.setOpenGps(true);

    /// 可选，设置是否需要使用gps，true为需要使用

    androidOption.setLocationMode(LocationMode.Hight_Accuracy);

    /// 可选，设置定位模式，可选的模式有高精度、低功耗、仅设备，默认为高精度模式，可选值如下：

    /// 高精度模式: LocationMode.Hight_Accuracy

    /// 低功耗模式：LocationMode.Battery_Saving

    /// 仅设备(Gps)模式：LocationMode.Device_Sensors

    androidOption.setScanspan(1000);

    /// 可选，设置发起定位请求的间隔，int类型，单位ms

    /// 如果设置为0，则代表单次定位，即仅定位一次，默认为0

    /// 如果设置非0，需设置1000ms以上才有效

    androidOption.setLocationPurpose(BDLocationPurpose.SignIn);

    /// 可选，设置场景定位参数，包括签到场景、运动场景、出行场景，可选值如下：

    /// 签到场景: BDLocationPurpose.SignIn

    /// 运动场景: BDLocationPurpose.Transport

    /// 出行场景: BDLocationPurpose.Sport

    Map androidMap = androidOption.getMap();

    locationPlugin.prepareLoc(androidMap, null);

   }

// 返回定位信息

   static void _setupListener(callback) {

   /* if (_locationListener != null) {

     return;

    }*/

    locationListener =

      locationPlugin.onResultCallback().listen((Map<String, Object> result) {

     callback(result);

    });

   }

   static void cancel() {

    // 取消监听

    if (null != locationListener) {

     locationListener.cancel();

    }

   }

  /// 根据两点经纬度 使用math 算出之间距离
  getDistance(double lat1, double lng1, double lat2, double lng2) {
    /// 单位：米
    /// def ：地球半径
    double def = 6378137.0;
    double radLat1 = _rad(lat1);
    double radLat2 = _rad(lat2);
    double a = radLat1 - radLat2;
    double b = _rad(lng1) - _rad(lng2);
    double s = 2 * asin(sqrt(pow(sin(a / 2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2)));
    return (s * def ).roundToDouble();
  }

  double _rad(double d) {
    return d * pi / 180.0;
  }
}