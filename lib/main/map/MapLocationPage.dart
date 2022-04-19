// import 'package:background_location/background_location.dart';
import 'dart:convert';

import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 地图类型示例
// ignore: must_be_immutable
class MapLocationPage extends StatefulWidget {
  BMFMapOptions customMapOptions;
  MapLocationPage({
    Key key,
    this.customMapOptions,
  }) : super(key: key);

  @override
  _MapLocationPageState createState() =>
      _MapLocationPageState();
}


class _MapLocationPageState extends State<MapLocationPage> {
  BMFMapType mapType = BMFMapType.Standard;
  BMFMapOptions customMapOptions;
  BMFMapController myMapController;

  double latitude;
  double longitude;
  String titleStr = "点击地图以获取经纬度和地图状态";
  String detailStr = "点击地图以获取经纬度和地图状态";

  /// 创建完成回调
  void onBMFMapCreated(BMFMapController controller) {
    myMapController = controller;

    /// 地图渲染每一帧画面过程中，以及每次需要重绘地图时（例如添加覆盖物）都会调用此接口
    myMapController?.setMapOnDrawMapFrameCallback(
        callback: (BMFMapStatus mapStatus) {
//       print('地图渲染每一帧\n mapStatus = ${mapStatus.toMap()}');
        });

    /// 地图区域即将改变时会调用此接口
    /// mapStatus 地图状态信息
    myMapController?.setMapRegionWillChangeCallback(
        callback: (BMFMapStatus mapStatus) {
          print('地图区域即将改变时会调用此接口1\n mapStatus = ${mapStatus.toMap()}');
        });

    /// 地图区域改变完成后会调用此接口
    /// mapStatus 地图状态信息
    myMapController?.setMapRegionDidChangeCallback(
        callback: (BMFMapStatus mapStatus) {
          print('地图区域改变完成后会调用此接口2\n mapStatus = ${mapStatus.toMap()}');
        });

    /// 地图区域即将改变时会调用此接口
    /// mapStatus 地图状态信息
    /// reason 地图改变原因
    myMapController?.setMapRegionWillChangeWithReasonCallback(callback:
        (BMFMapStatus mapStatus, BMFRegionChangeReason regionChangeReason) {
      print(
          '地图区域即将改变时会调用此接口3\n mapStatus = ${mapStatus.toMap()}\n reason = ${regionChangeReason.index}');
    });

    /// 地图区域改变完成后会调用此接口
    /// mapStatus 地图状态信息
    /// reason 地图改变原因
    myMapController?.setMapRegionDidChangeWithReasonCallback(callback:
        (BMFMapStatus mapStatus, BMFRegionChangeReason regionChangeReason) {
      print(
          '地图区域改变完成后会调用此接口4\n mapStatus = ${mapStatus.toMap()}\n reason = ${regionChangeReason.index}');
    });

    myMapController.setMapOnClickedMapBlankCallback(callback: (BMFCoordinate coordinate) {
      myMapController.cleanAllMarkers();

      latitude = coordinate.latitude;
      longitude = coordinate.longitude;
      print("点击 位置 ：latitude-$latitude longitude-$longitude");
      setLocationStr(latitude,longitude);

      /// 创建BMFMarker
      BMFMarker marker = BMFMarker(
          position: BMFCoordinate(coordinate.latitude,coordinate.longitude),
          enabled: false,
          visible: true,
          identifier: "location",
          icon: 'assets/images/main/map/icon_point.png');

      /// 添加Marker
      myMapController.addMarker(marker);
    });
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BaseScaffold(
          title: "地图",
            titleSize: 30.sp,
            backgtoundColor: CXColors.lineColor_f8,
            leftImage: "assets/images/common/ic_back.png",
            leftImageSize: 40.w,
            leftCallback: (){Navigator.pop(context);},
            body: Column(children: <Widget>[
              ///Map
              Expanded(
                child: Container(
                  width: 1.sw,
                  child: BMFMapWidget(
                    onBMFMapCreated: (controller) {
                      onBMFMapCreated(controller);
                    },
                    mapOptions: initMapOptions(),
                  ),
                ),
              ),
              ///选择
              Container(
                color: CXColors.WhiteColor,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                height: 200.w,
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 0),
                        child: Text(titleStr,style: TextStyle(color: CXColors.BlackColor,fontSize: 24.sp),)),
                    Container(
                        margin: EdgeInsets.fromLTRB(5.w, 5.w, 5.w, 0),
                        child: Text(detailStr,style: TextStyle(color: CXColors.titleColor_99,fontSize: 20.sp),)),
                    CommonButton(text: "确认选择", backgroundColor: CXColors.maintab,textColor: CXColors.WhiteColor,
                        borderRadius: 50.w,
                        height: 75.w,
                        fontSize: 26.sp,
                        margin: EdgeInsets.only(top: 10.w),
                        onPressed: chooseLocation),
                  ],
                ),
              ),
            ])
        ),
      ),
    );
  }

  /// 设置地图参数
  BMFMapOptions initMapOptions() {
    if (null != this.customMapOptions) {
      return this.customMapOptions;
    }

    BMFCoordinate center = BMFCoordinate(CustomerModel.latitude,CustomerModel.longitude);
    BMFMapOptions mapOptions = BMFMapOptions(
        mapType: BMFMapType.Standard,
        zoomLevel: 17,
        maxZoomLevel: 21,
        minZoomLevel: 4,
        compassEnabled: true,
        buildingsEnabled: true,
        gesturesEnabled: true,
        showMapPoi: true,
        showIndoorMapPoi: false,
        rotateEnabled: true,
        logoPosition: BMFLogoPosition.LeftBottom,
        mapPadding: BMFEdgeInsets(top: 0, left: 50, right: 50, bottom: 0),
        overlookEnabled: true,
        overlooking: -15,
        center: center);
    return mapOptions;
  }

  ///确认选择位置点
  chooseLocation() {
    print("chooseLocation  -> $latitude");
    if(latitude==null){
      Fluttertoast.showToast(msg: "请先选择位置");
      return;
    }
    Navigator.pop(context,{
      "latitude": latitude,
      "longitude": longitude,
      "province": "",
      "city": "",
      "area": "",
    });
  }

  void setLocationStr(double lat ,double lng) {
    NetUtil.get("http://api.map.baidu.com/reverse_geocoding/v3/?ak=GTgjOvUP9u4GaIrszKeqqDF9zB8GK2Fr&mcode=4E:E0:54:19:7F:52:00:FA:9A:C6:54:C3:71:1E:EA:24:25:47:82:34;com.haohai.fireprevention&output=json&coordtype=wgs84ll&location=$lat,$lng", (data)
    {
      print("baiduApi --> data = $data");
      detailStr = jsonDecode(data)["result"]["formatted_address"];
      titleStr = jsonDecode(data)["result"]["formatted_address"];
      setState(() {
      });
    });
  }
}
