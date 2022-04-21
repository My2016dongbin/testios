import 'dart:developer';
import 'dart:io';
import 'package:amap_flutter_navi/amap_flutter_navi.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_mapapi_search/flutter_baidu_mapapi_search.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/AllUtils.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/PictureShow.dart';
import 'package:fireprevention/utils/VideoScreen.dart';
import 'package:fireprevention/utils/map/location/MapUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app/DispatcherTaskPage.dart';
import 'map/StatisticsPage.dart';

/// 地图类型示例
// ignore: must_be_immutable
class MapFragment extends StatefulWidget {
  BMFMapOptions customMapOptions;
  MapFragment({
    Key key,
    this.customMapOptions,
  }) : super(key: key);

  @override
  _MapFragmentState createState() =>
      _MapFragmentState();
}

class _MapFragmentState extends State<MapFragment> with AutomaticKeepAliveClientMixin{
  BMFMapType mapType = BMFMapType.Standard;
  BMFMapOptions customMapOptions;
  BMFMapController myMapController;

  String startStr = "请输入开始时间";
  String endStr = "请输入结束时间";


  StreamSubscription markerDetailSubscription;
  StreamSubscription locationSubscription;
  StreamSubscription guideSubscription;

  ///火警列表数据-时间分类
  List fireList = [
    /*{
      "date": "2021-07-08 10:50:00",
      "list": [
        {
          "title": "黑龙江省 佳木斯市 桦南县"
        }
      ],
    },*/
  ];
  ///编号分类
  List fireList2 = [
    /*{
      "no": "LJ4565664345678864",
      "list": [
        {
          "title": "黑龙江省 佳木斯市 桦南县"
        }
      ],
    },*/
  ];
  List fireAllList = [];
  List warningAllList = [];
  int firCount = 0;
  String startTime = DateTime.now().subtract(Duration(days: 5)).toIso8601String().substring(0,19);
  String endTime = DateTime.now().toIso8601String().substring(0,19);
  ///报警火情列表-未处理
  List warningList = [
    /*{
      "title": "曙光林区_热成像",
      "date": "2021-07-08 10:50:00",
      "longitude": 125.02749791999999,
      "latitude": 46.83124524,
      "address": "曙光林区_热成像",
    },*/
  ];
  ///报警火情列表-真实火点
  List warningList2 = [
    /*{
      "title": "曙光林区_热成像",
      "date": "2021-07-08 10:50:00",
      "longitude": 125.02749791999999,
      "latitude": 46.83124524,
      "address": "曙光林区_热成像",
    },*/
  ];

  @override
  bool get wantKeepAlive => true;

  ///可见光(资源监控点数据)
  String resourceCameraUrl1 = "";
  String resourceCameraId1 = "";
  ///热成像(资源监控点数据)
  String resourceCameraUrl2 = "";
  String resourceCameraId2 = "";

  /// 创建完成回调
  void onBMFMapCreated(BMFMapController controller) {
    //重置资源监控点数据
    resourceCameraUrl1 = "";
    resourceCameraId1 = "";
    resourceCameraUrl2 = "";
    resourceCameraId2 = "";
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

    /// 地图marker点击回调 (Android端SDK存在bug,现区分两端分别设置)
    myMapController?.setMapClickedMarkerCallback(
        callback: (BMFMarker marker) async {
          int currentZoom = await myMapController.getZoomLevel();
          if(Platform.isAndroid){
            myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
            for(int i = 0; i < fireMarkerList.length;i++){
              if(fireMarkerList[i].Id == marker.Id){
                //点击Marker详情
                showMarkerDetail(fireAllList[i]);
                myMapController?.setCenterCoordinate(
                  BMFCoordinate(fireAllList[i]["latitude"],fireAllList[i]["longitude"]), false,
                );
                return;
              }
            }
            for(int i = 0; i < warningMarkerList.length;i++){
              if(warningMarkerList[i].Id == marker.Id){
                // Fluttertoast.showToast(msg: "warning ==> ${warningAllList[i]["alarmLatitude"]} ${warningAllList[i]["alarmLongitude"]}");
                print("warning ==> ${warningAllList[i]["alarmLatitude"]} ${warningAllList[i]["alarmLongitude"]}");
                //点击Marker详情
                showWarningDetail(warningAllList[i]);
                myMapController?.setCenterCoordinate(
                  BMFCoordinate(warningAllList[i]["alarmLatitude"],warningAllList[i]["alarmLongitude"]), false,
                );
                return;
              }
            }
            for(int i = 0; i < resourceMarkerList.length;i++){
              for(int m = 0; m < resourceCameraList.length;m++){
                if(resourceMarkerList[i].Id == marker.Id && resourceCameraList[m]["outName"] == "视频监控点" &&resourceCameraList[m]["id"]==resourceAllList[i]["id"]){
                  ///资源视频监控点 弹窗
                  log("id? ==> ${resourceMarkerList[i].Id} - ${marker.Id}");
                  EventBusUtil.getInstance().fire(Toloading());
                  NetUtil.post(Api.MapResourceCameraDetail, (data){
                    EventBusUtil.getInstance().fire(Todismiss());
                    log("MapResourceCameraDetail --> data = $data");
                    if(data!=null && data["code"] == 200){
                      for(dynamic model in data["data"]){
                        if("${model["cameraType"]}" == "1"){
                          //可见光
                          resourceCameraUrl1 = model["id"];
                          resourceCameraId1 = model["monitorId"];
                        }else{
                          //热成像
                          resourceCameraUrl2 = model["id"];
                          resourceCameraId2 = model["monitorId"];
                        }
                      }

                      resourceCameraList[m]["resourceCameraUrl1"] = resourceCameraUrl1;
                      resourceCameraList[m]["resourceCameraId1"] = resourceCameraId1;
                      resourceCameraList[m]["resourceCameraUrl2"] = resourceCameraUrl2;
                      resourceCameraList[m]["resourceCameraId2"] = resourceCameraId2;
                      showResourceCameraDetail(resourceCameraList[m]);
                      //点击Marker详情
                      myMapController?.setCenterCoordinate(
                        BMFCoordinate(resourceCameraList[m]["position"]["lat"],resourceCameraList[i]["position"]["lng"]), false,
                      );
                      return;
                    }else{
                      Fluttertoast.showToast(msg: "${data["message"]}");
                    }
                  },params: {
                    "monitorId": resourceCameraList[m]["id"],
                  },errorCallBack: (e){
                    EventBusUtil.getInstance().fire(Todismiss());
                  });
                  return;
                }
              }
              if(resourceMarkerList[i].Id == marker.Id){
                ///其他资源点击
                Fluttertoast.showToast(msg: "${resourceAllList[i]["name"]}");
                myMapController?.setCenterCoordinate(
                  BMFCoordinate(resourceAllList[i]["position"]["lat"],resourceAllList[i]["position"]["lng"]), false,
                );
                return;
              }
            }

          }
          if(Platform.isIOS){
            myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
            dynamic selectedX = {};
            if(marker.identifier!=null && marker.identifier.contains("fire")){
              for(dynamic modelX in fireAllList){
                if(marker.identifier.contains(modelX["id"])){
                  selectedX = modelX;
                  //点击Marker详情
                  showMarkerDetail(selectedX);
                  break;
                }
              }
            }
            if(marker.identifier!=null && marker.identifier.contains("warning")){
              for(dynamic modelX in warningAllList){
                if(marker.identifier.contains(modelX["id"])){
                  selectedX = modelX;
                  //点击Marker详情
                  showWarningDetail(selectedX);
                  break;
                }
              }
            }
            if(marker.identifier!=null && marker.identifier.contains("resource") && marker.identifier.contains("视频监控点")){
              for(dynamic modelX in resourceCameraList){
                if(marker.identifier.contains(modelX["id"])){
                  selectedX = modelX;

                  EventBusUtil.getInstance().fire(Toloading());
                  NetUtil.post(Api.MapResourceCameraDetail, (data){
                    EventBusUtil.getInstance().fire(Todismiss());
                    print("MapResourceCameraDetail --> data = $data");
                    if(data!=null && data["code"] == 200){
                      for(dynamic model in data["data"]){
                        if("${model["cameraType"]}" == "1"){
                          //可见光
                          resourceCameraUrl1 = model["id"];
                          resourceCameraId1 = model["monitorId"];
                        }else{
                          //热成像
                          resourceCameraUrl2 = model["id"];
                          resourceCameraId2 = model["monitorId"];
                        }
                      }

                      selectedX["resourceCameraUrl1"] = resourceCameraUrl1;
                      selectedX["resourceCameraId1"] = resourceCameraId1;
                      selectedX["resourceCameraUrl2"] = resourceCameraUrl2;
                      selectedX["resourceCameraId2"] = resourceCameraId2;

                      //点击Marker详情
                      showResourceCameraDetail(selectedX);
                      myMapController?.setCenterCoordinate(
                        BMFCoordinate(selectedX["position"]["lat"],selectedX["position"]["lng"]), false,
                      );
                    }else{
                      Fluttertoast.showToast(msg: "${data["message"]}");
                    }
                  },params: {
                    "monitorId": selectedX["id"],
                  },errorCallBack: (e){
                    EventBusUtil.getInstance().fire(Todismiss());
                  });
                }
              }
            }
          }
        });

    ///地图边界
    drawAreaLines();
  }

  @override
  void initState() {
    super.initState();
    ///aMap_guide init
    initPlatformState();
    AmapFlutterNavi.init('a0dd5d284befa891b37a2ed4bd99c051');
    markerDetailSubscription = EventBusUtil.getInstance().on<MarkerDetail>().listen((event) async {
      int currentZoom = await myMapController.getZoomLevel();
      ///先跳到火点坐标
      myMapController.setZoomTo((currentZoom>13?currentZoom:13)*1.0);
      myMapController?.setCenterCoordinate(
          BMFCoordinate(event.data["latitude"],event.data["longitude"]), false,
          );
      if(event.pop){
        Navigator.pop(context);
      }
      ///再展示详细信息
      if(event.type == "fire"){
        showMarkerDetail(event.data);
      }else{
        showWarningDetail(event.data);
      }
    });
    locationSubscription = EventBusUtil.getInstance().on<LocationRefresh>().listen((event) async {
      /*int currentZoom = await myMapController.getZoomLevel();
      Future.delayed(Duration(milliseconds: 2000)).then((value) {
        setState(() {
          myMapController.setZoomTo(currentZoom + 1.0);
          myMapController.setZoomTo(currentZoom*1.0);
        });
      });*/
    });
    guideSubscription = EventBusUtil.getInstance().on<GuideModel>().listen((event) {

    });
    myMapController?.showUserLocation(true);
    updateUserLocation();

    //获取火情列表
    // getFireListDate();
    //获取报警列表
    getWarningListDate();
    //获取资源初始化信息
    getInitResourceData();
    ///获取行政区边界坐标数据
    getAreaPoints();
  }

  List<List> areaPointsList = new List();
  Future<void> getAreaPoints() async {
    areaPointsList.clear();
    // 构造检索参数
    BMFDistrictSearchOption districtSearchOption =
    BMFDistrictSearchOption(city: '青岛市', district: '即墨区');
    // 检索实例
    BMFDistrictSearch districtSearch = BMFDistrictSearch();
    // 检索回调
    districtSearch.onGetDistrictSearchResult(callback:
        (BMFDistrictSearchResult result, BMFSearchErrorCode errorCode) {
      print("bingo result.toMap() = ${result.toMap()}");
      List lists = result.toMap()["paths"];
      areaPointsList = lists;
      drawAreaLines();
    });
    // 发起检索
    bool flag = await districtSearch.districtSearch(districtSearchOption);
    print("bingo result.toMap() flag = $flag");
  }

  void drawAreaLines(){
    for(int i = 0; i < areaPointsList.length; i++){
      List areaModelList = areaPointsList[i];
      List<BMFCoordinate> areaModelPointsList = new List<BMFCoordinate>();
      for(int m = 0 ; m < areaModelList.length; m++){
        dynamic model = areaModelList[m];
        areaModelPointsList.add(BMFCoordinate(model["latitude"],model["longitude"]));
      }
      ///地图边界
      // 颜色索引,索引的值都是0,表示所有线段的颜色都取颜色集colors的第一个值
      List<int> indexs = new List();
      for(int i = 0; i < areaModelPointsList.length; i++){
        indexs.add(0);
      }

      // 颜色
      List<Color> colors = List(1);
      colors[0] = Colors.blueAccent;

      // 创建polyline
      BMFPolyline colorsPolyline = BMFPolyline(
        // id: polylineOptions.hashCode.toString(),
          coordinates: areaModelPointsList,
          indexs: indexs,
          colors: colors,
          width: 12,
          dottedLine: false,
          lineDashType: BMFLineDashType.LineDashTypeNone,
          lineCapType: BMFLineCapType.LineCapButt,
          lineJoinType: BMFLineJoinType.LineJoinRound);

      // 添加polyline
      myMapController?.addPolyline(colorsPolyline);
    }
  }

  String _platformVersion = 'Unknown';
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await AmapFlutterNavi.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  ///获取火情列表数据
  void getFireListDate({String openType}) {
    NetUtil.post(Api.MapFireList, (data){
      print("MapFireList --> data = $data");
      if(data!=null && data["code"] == 200){
        List allList = data["data"];
        fireAllList = allList;
        fireList.clear();
        fireList2.clear();
        firCount = allList.length;
        for(int i = 0;i < allList.length;i++){
          //·1.按时间分类
          if(fireList.isEmpty){
            //isEmpty一定添加-生成子单元并添加到新增子单元list中
            fireList.add({
              "date": allList[i]["observationDatetime"],
              "list": [allList[i]],
            });
          }else{
            //notEmpty 遍历fireList
            for(int m = 0;m < fireList.length;m++){
              if(allList[i]["observationDatetime"] == fireList[m]["date"]){
                //当前遍历单元的时间与子单元时间一致-则添加到子单元list中
                fireList[m]["list"].add(allList[i]);
                break;
              }else if(m == fireList.length-1){
                //不一致且为最后一个-则新增子单元并添加到新增子单元list中
                fireList.add({
                  "date": allList[i]["observationDatetime"],
                  "list": [allList[i]],
                });
                break;
              }
            }
          }
          //·2.按编号分类
          if(fireList2.isEmpty){
            //isEmpty一定添加-生成子单元并添加到新增子单元list中
            fireList2.add({
              "no": allList[i]["fireNo"],
              "list": [allList[i]],
            });
          }else{
            //notEmpty 遍历fireList
            for(int m = 0;m < fireList2.length;m++){
              if(allList[i]["fireNo"] == fireList2[m]["no"]){
                //当前遍历单元的时间与子单元时间一致-则添加到子单元list中
                fireList2[m]["list"].add(allList[i]);
                break;
              }else if(m == fireList2.length-1){
                //不一致且为最后一个-则新增子单元并添加到新增子单元list中
                fireList2.add({
                  "no": allList[i]["fireNo"],
                  "list": [allList[i]],
                });
                break;
              }
            }
          }
        }
        Future.delayed(Duration(milliseconds: 1000)).then((value) {
          //刷新Marker
          initMarker("fire");
        });
        //火情查询-查询完毕时调用
        if(openType == "fire"){
          openFireList();
        }
      }else{
        Fluttertoast.showToast(msg: "${data["message"]}");
      }
    },params: fireListDateParams());
  }
  ///获取报警列表数据
  void getWarningListDate() {
    NetUtil.post(Api.MapWarningList, (data){
      print("MapWarningList --> data = $data");
      if(data!=null && data["code"] == 200){
        List allList = data["data"];
        warningAllList.clear();
        //剔除所有疑似火情
        for(dynamic model in allList){
          if(model["isReal"] != null){
            if(model["isReal"] == 1){
              warningAllList.add(model);
            }
          }else{
            warningAllList.add(model);
          }
        }
        warningList.clear();
        warningList2.clear();
        //数据分类
        for(dynamic model in warningAllList){
          model["latitude"] = model["alarmLatitude"];
          model["longitude"] = model["alarmLongitude"];
          //未处理
          if(model["isReal"] == null){
            warningList.add(model);
          }
          //已处理
          if(model["isReal"] != null){
            warningList2.add(model);
          }
        }
        Future.delayed(Duration(milliseconds: 1000)).then((value) {
          //刷新Marker
          initMarker("warning");
        });
      }else{
        Fluttertoast.showToast(msg: "${data["message"]}");
      }
    },params: warningListDateParams());
  }
  fireListDateParams() {
    dynamic params = {
      "startTime": startTime,
      "endTime": endTime,
      "satellite": endTime,
      "landType": endTime,
    };
    if(CustomerModel.gridNo.contains("0000")){
      params["provinceCode"] = CustomerModel.gridNo;
    }else if(CustomerModel.gridNo.contains("00")){
      params["cityCode"] = CustomerModel.gridNo;
    }else{
      params["countyCode"] = CustomerModel.gridNo;
    }
    return params;
  }
  warningListDateParams() {
    // dynamic params = {
    //   "dto": {},
    //   "limit": 200,
    //   "page": 1,
    // };
    dynamic params = {
      "isReal": null,
      "groupId": CustomerModel.groupId,
      "isHandle": 0,
    };
    if(shijianType==0){
      params["type"] = null;
    }else{
      params["type"] = shijianType;
    }
    return params;
  }

  BMFUserLocation _userLocation;
  /// 更新位置
  void updateUserLocation() {
    BMFCoordinate coordinate = BMFCoordinate(36.302222,120.306666);
    BMFLocation location = BMFLocation(
        coordinate: coordinate,
        altitude: 0,
        horizontalAccuracy: 5,
        verticalAccuracy: -1.0,
        speed: -1.0,
        course: -1.0);
    BMFUserLocation userLocation = BMFUserLocation(
      location: location,
    );
    _userLocation = userLocation;
    myMapController?.updateLocationData(_userLocation);
  }
  @override
  void dispose() {
    markerDetailSubscription.cancel();
    locationSubscription.cancel();
    guideSubscription.cancel();
    super.dispose();
  }

  List<BMFMarker> fireMarkerList = [];
  List<BMFMarker> warningMarkerList = [];
  List<BMFMarker> resourceMarkerList = [];
  ///火警打点
  initMarker(String type,{String resourceName}) async {
    myMapController.cleanAllMarkers();
    fireMarkerList.clear();
    warningMarkerList.clear();
    resourceMarkerList.clear();
    resourceAllList.clear();
    ///1.卫星火警
    for(dynamic model in fireAllList){
      /// 创建BMFMarker
      BMFMarker marker = BMFMarker(
          position: BMFCoordinate(model["latitude"],model["longitude"]),
          title: '${model["formattedAddress"]}',
          enabled: true,
          visible: true,
          identifier: 'fire${model["id"]}',
          icon: 'assets/images/main/map/ic_fires.png');

      /// 添加Marker
      bool ys;
      ys = await myMapController.addMarker(marker);
      fireMarkerList.add(marker);
    }
    if(fireAllList.isNotEmpty && type == "fire"){
      ///跳到第一火点
      myMapController?.setCenterCoordinate(
        BMFCoordinate(fireAllList[0]["latitude"],fireAllList[0]["longitude"]), true,animateDurationMs: 200
      );
    }

    ///2.报警列表（一体机）
    for(dynamic model in warningList){
      /// 创建BMFMarker
      BMFMarker marker = BMFMarker(
          position: BMFCoordinate(model["latitude"],model["longitude"]),
          title: '${model["name"]}',
          enabled: true,
          visible: true,
          identifier: 'warning${model["id"]}',
          icon: parseMarkerImage("${model["type"]}"));

      /// 添加Marker
      bool ys;
      ys = await myMapController.addMarker(marker);
      warningMarkerList.add(marker);
    }
    if(warningList.isNotEmpty && type == "warning"){
      ///跳到第一报警点
      myMapController?.setCenterCoordinate(
          BMFCoordinate(warningList[0]["latitude"],warningList[0]["longitude"]), true,animateDurationMs: 200
      );
    }

    ///3.资源
    for(dynamic outer in resourceInitList??[]){
      for(dynamic inner in outer["list"]??{}){
        /// 创建BMFMarker
        BMFMarker marker = BMFMarker(
            position: BMFCoordinate(inner["position"]["lat"],inner["position"]["lng"]),
            title: '${inner["name"]}',
            enabled: true,
            visible: true,
            identifier: 'resource${inner["id"]}-${outer["name"]}',
            icon: parseResourceMarkerIcon(outer["name"]));

        log("markerId ==> ${marker.Id}");

        /// 添加Marker
        bool ys;
        ys = await myMapController.addMarker(marker);
        resourceMarkerList.add(marker);
        resourceAllList.add(inner);

        ///新添加资源点-跳到第一个点
        if(resourceName == outer["name"] && outer["list"][0] == inner){
          ///跳到第一资源点
          myMapController?.setCenterCoordinate(
              BMFCoordinate(inner["position"]["lat"],inner["position"]["lng"]), true,animateDurationMs: 200
          );
        }
      }
    }
  }

  ///资源Marker图标分类
  parseResourceMarkerIcon(String name) {
    String iconImage = "assets/images/main/map/ic_down.png";
    if(name == "消防专业队"){
      iconImage = "assets/images/main/map/team.png";
    }
    if(name == "危险源"){
      iconImage = "assets/images/main/map/dangerSource.png";
    }
    if(name == "物资储备库"){
      iconImage = "assets/images/main/map/foreastRoom.png";
    }
    if(name == "水源地"){
      iconImage = "assets/images/main/map/waterSource.png";
    }
    if(name == "墓地"){
      iconImage = "assets/images/main/map/cemetery.png";
    }
    if(name == "瞭望塔"){
      iconImage = "assets/images/main/map/watchTower.png";
    }
    if(name == "护林检查站"){
      iconImage = "assets/images/main/map/checkStation.png";
    }
    if(name == "视频监控点"){
      iconImage = "assets/images/main/map/monitor.png";
    }
    if(name == "森林防火监测中心"){
      iconImage = "assets/images/main/map/foreastCenter.png";
    }
    return iconImage;
  }

  ///卫星Tab展开
  bool starTag = false;
  double floatWidth = 85.w;
  double floatPadding = 5.w;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      home: Scaffold(
        body: BaseScaffold(
          title: "地图",
            titleSize: 30.sp,
            body: Stack(children: <Widget>[
              ///Map
              Container(
                height: 1.sh,
                width: 1.sw,
                child: BMFMapWidget(
                  onBMFMapCreated: (controller) {
                    onBMFMapCreated(controller);
                  },
                  mapOptions: initMapOptions(),
                ),
              ),
              ///菜单
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 60.w, 20.w, 0),
                  width: 100.w,
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ///卫星
                      /*InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(floatPadding, 23.w, floatPadding, starTag?0:23.w),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                              border: Border.all(color: CXColors.maintab),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(23.w),topRight: Radius.circular(23.w),bottomLeft: Radius.circular(starTag?0:23.w),bottomRight: Radius.circular(starTag?0:23.w))
                          ),
                          width: floatWidth,
                          child: Text(
                            "卫星",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                          ),
                        ),
                        onTap: (){
                          setState(() {
                            starTag = !starTag;
                          });
                        },
                      ),
                      starTag?InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(floatPadding, 20.w, floatPadding, 0),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                            border: Border.all(color: CXColors.maintab),
                          ),
                          width: floatWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "火情",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              ),Text(
                                "列表",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              )
                            ],
                          ),
                        ),
                        onTap: openFireList,
                      ):SizedBox(),
                      starTag?InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(floatPadding, 15.w, floatPadding, 0),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                            border: Border.all(color: CXColors.maintab),
                          ),
                          width: floatWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "火情",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              ),Text(
                                "查询",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              )
                            ],
                          ),
                        ),onTap: openFireSearch,
                      ):SizedBox(),
                      starTag?InkWell(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(floatPadding, 15.w, floatPadding, 10.w),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                              border: Border.all(color: CXColors.maintab),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.w),bottomRight: Radius.circular(16.w),)
                          ),
                          width: floatWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "卫星",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              ),Text(
                                "设置",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              )
                            ],
                          ),
                        ),
                        onTap: (){
                          //打开卫星设置
                          Navigator.push(
                              context,
                              CustomRoute(
                                  StarSettingPage(),timer: 200));
                        },
                      ):SizedBox(),*/
                      ///资源
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(top: 15.w),
                          padding: EdgeInsets.fromLTRB(floatPadding, 23.w, floatPadding, 23.w),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                              border: Border.all(color: CXColors.maintab),
                              borderRadius: BorderRadius.all(Radius.circular(23.w))
                          ),
                          width: floatWidth,
                          child: Text(
                            "资源",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                          ),
                        ),
                        onTap: (){
                          openFireResource();
                        },
                      ),
                      ///报警列表
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(top: 15.w),
                          padding: EdgeInsets.fromLTRB(floatPadding, 23.w, floatPadding, 23.w),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                              border: Border.all(color: CXColors.maintab),
                              borderRadius: BorderRadius.all(Radius.circular(23.w))
                          ),
                          width: floatWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "报警",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              ),
                            ],
                          ),
                        ),
                        onTap: (){
                          openWarningList();
                        },
                      ),
                      ///调度任务
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(top: 15.w),
                          padding: EdgeInsets.fromLTRB(floatPadding, 23.w, floatPadding, 23.w),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                              border: Border.all(color: CXColors.maintab),
                              borderRadius: BorderRadius.circular(23.w)
                          ),
                          width: floatWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text(
                                "任务",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              )
                            ],
                          ),
                        ),
                        onTap: (){
                          //打开任务列表
                          Navigator.push(
                              context,
                              CustomRoute(
                                  DispatcherTaskPage(),timer: 200));
                        },
                      ),
                      ///统计
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.only(top: 15.w),
                          padding: EdgeInsets.fromLTRB(floatPadding, 23.w, floatPadding, 23.w),
                          decoration: BoxDecoration(
                              color: CXColors.maintab,
                              border: Border.all(color: CXColors.maintab),
                              borderRadius: BorderRadius.circular(23.w)
                          ),
                          width: floatWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text(
                                "统计",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),
                              )
                            ],
                          ),
                        ),
                        onTap: (){
                          //打开任务列表
                          Navigator.push(
                              context,
                              CustomRoute(
                                  StatisticsPage(),timer: 200));
                        },
                      ),
                    ],
                  ),
                )
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

    BMFCoordinate center = BMFCoordinate(CustomerModel.latitude??36.302697,CustomerModel.longitude??120.306573);
    BMFMapOptions mapOptions = BMFMapOptions(
        mapType: BMFMapType.Satellite,
        zoomLevel: 11,
        maxZoomLevel: 21,
        minZoomLevel: 4,
        compassEnabled: true,
        buildingsEnabled: true,
        gesturesEnabled: true,
        rotateEnabled: true,
        logoPosition: BMFLogoPosition.LeftBottom,
        mapPadding: BMFEdgeInsets(top: 0, left: 50, right: 50, bottom: 0),
        overlookEnabled: true,
        overlooking: -15,
        center: center);
    return mapOptions;
  }

  ///报警列表分类条件 0 全部, 1 未处理, 2 已处理
  int warningType = 0;
  ///报警列表
  void openWarningList() {
    getWarningListDate();
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: 0.77.sh,
          color: CXColors.maintab,
          child: Stack(
            children: [
              //title&&筛选条件
              Container(
                color: CXColors.maintab_dark.withAlpha(100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(margin: EdgeInsets.fromLTRB(20.w, 18.w, 0, 20.w),child: Text("报警列表",style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(getShijianType(),style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),),
                                Icon(Icons.arrow_drop_down,color: CXColors.WhiteColor,size: 36.w,),
                                SizedBox(width: 10.w,),
                              ],
                            ),
                          ),
                          onTap: (){
                            showShijianListFilter(sheetState,context);
                          },
                        ),
                        SizedBox(width: 36.w,),
                        InkWell(
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(getWarningType(),style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),),
                                Icon(Icons.arrow_drop_down,color: CXColors.WhiteColor,size: 36.w,),
                                SizedBox(width: 10.w,),
                              ],
                            ),
                          ),
                          onTap: (){
                            showWarningListFilter(sheetState,context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //ListView
              Container(
                margin: EdgeInsets.only(top: 80.w),
                child: ListView.builder(itemCount: parseLength(),padding: EdgeInsets.zero,itemBuilder: (BuildContext context, int index) {
                  return WarningListCell(parseList(index),index,warningType!=1);
                },),
              ),

            ],
          ),
        );
      },);
    }, isScrollControlled: true,);
  }
  parseLength() {
    if(warningType == 0){
      return warningAllList.length;
    }
    if(warningType == 1){
      return warningList.length;
    }
    if(warningType == 2){
      return warningList2.length;
    }
  }
  parseList(int index) {
    if(warningType == 0){
      return warningAllList[index];
    }
    if(warningType == 1){
      return warningList[index];
    }
    if(warningType == 2){
      return warningList2[index];
    }
  }
  ///火情列表分类 true 时间分类 false 编号分类
  bool mapListIsTime = true;
  ///火情列表
  void openFireList() {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: 0.77.sh,
          color: CXColors.maintab,
          child: Stack(
            children: [
              //title&&筛选条件
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(margin: EdgeInsets.fromLTRB(20.w, 18.w, 0, 20.w),child: Text("报警信息列表",style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),)),
                  InkWell(
                    child: Container(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${mapListIsTime?'按时间分类':'按编号分类'}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),),
                          Icon(Icons.arrow_drop_down,color: CXColors.WhiteColor,size: 36.w,),
                          SizedBox(width: 10.w,),
                        ],
                      ),
                    ),
                    onTap: (){
                      showFireListFilter(sheetState,context);
                    },
                  ),
                ],
              ),
              //醒目提示
              Container(
                margin: EdgeInsets.only(top: 80.w),
                padding: EdgeInsets.fromLTRB(20.w, 25.w, 20.w, 25.w),
                decoration: BoxDecoration(
                  color: CXColors.job_red,
                ),
                  child: Row(
                    children: [
                      Text("查询完毕,查询时间内共 ",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp,height: 1.2),),
                      Text("$firCount",style: TextStyle(color: CXColors.gradient_yellow,fontSize: 28.sp,height: 1.2),),
                      Text(" 条报警数据",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp,height: 1.2),),
                    ],
                  ),
              ),
              //ListView
              Container(
                margin: EdgeInsets.only(top: 170.w),
                child: ListView.builder(itemCount: fireList.length,padding: EdgeInsets.zero,itemBuilder: (BuildContext context, int index) {
                  return mapListIsTime?FireListCell(fireList[index],index):FireList2Cell(fireList2[index],index);
                },),
              ),

            ],
          ),
        );
      },);
    }, isScrollControlled: true,);
  }

  ///报警信息列表筛选窗口-事件类型
  void showShijianListFilter(void Function(void Function()) sheetState ,BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      int tag = shijianType;
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) logState) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 0.75.sw,
                  height: 0.55.sw,
                  decoration: BoxDecoration(
                      color: CXColors.lineColor_ec,
                      borderRadius: BorderRadius.circular(16.w)
                  ),
                  child: Stack(
                    children: [
                      Container(
                          margin: EdgeInsets.fromLTRB(40.w, 30.w, 0, 0),
                          child: Row(
                            children: [
                              Image.asset("assets/images/common/ic_launcher.png",width: 60.w,height: 60.w,),
                              SizedBox(width: 10.w,),
                              Text("事件分类",style: TextStyle(color: CXColors.BlackColor,fontSize: 33.sp,height: 1.2),),
                            ],
                          )
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(20.w, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(tag==0?Icons.radio_button_checked:Icons.radio_button_off,color: tag==0?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("全部",style: TextStyle(color: tag==0?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 0;
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(20.w, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(tag==2?Icons.radio_button_checked:Icons.radio_button_off,color: (tag==2)?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("森林防火",style: TextStyle(color: (tag==2)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 2;
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(20.w, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(tag==5?Icons.radio_button_checked:Icons.radio_button_off,color: (tag==5)?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("砂石盗采",style: TextStyle(color: (tag==5)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 5;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CommonButton(
                          text: "确定",
                          width: 150.w,
                          height: 75.w,
                          margin: EdgeInsets.fromLTRB(0, 0, 20.w, 20.w),
                          solid: true,
                          elevation: 0,
                          fontSize: 28.sp,
                          textColor: CXColors.BlackColor,
                          backgroundColor: CXColors.lineColor_ec,
                          solidColor: CXColors.lineColor_ec,
                          onPressed: (){
                            Navigator.pop(context);
                            sheetState(() {
                              shijianType = tag;
                              getWarningListDate();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },barrierDismissible: true );
  }
  ///报警信息列表筛选窗口-状态
  void showWarningListFilter(void Function(void Function()) sheetState ,BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      int tag = warningType;
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) logState) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 0.75.sw,
                  height: 0.55.sw,
                  decoration: BoxDecoration(
                      color: CXColors.lineColor_ec,
                      borderRadius: BorderRadius.circular(16.w)
                  ),
                  child: Stack(
                    children: [
                      Container(
                          margin: EdgeInsets.fromLTRB(40.w, 30.w, 0, 0),
                          child: Row(
                            children: [
                              Image.asset("assets/images/common/ic_launcher.png",width: 60.w,height: 60.w,),
                              SizedBox(width: 10.w,),
                              Text("处置情况",style: TextStyle(color: CXColors.BlackColor,fontSize: 33.sp,height: 1.2),),
                            ],
                          )
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(20.w, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(tag==0?Icons.radio_button_checked:Icons.radio_button_off,color: tag==0?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("全部",style: TextStyle(color: tag==0?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 0;
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(20.w, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(tag==1?Icons.radio_button_checked:Icons.radio_button_off,color: (tag==1)?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("未处理",style: TextStyle(color: (tag==1)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 1;
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(20.w, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(tag==2?Icons.radio_button_checked:Icons.radio_button_off,color: (tag==2)?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("已处理",style: TextStyle(color: (tag==2)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 2;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CommonButton(
                          text: "确定",
                          width: 150.w,
                          height: 75.w,
                          margin: EdgeInsets.fromLTRB(0, 0, 20.w, 20.w),
                          solid: true,
                          elevation: 0,
                          fontSize: 28.sp,
                          textColor: CXColors.BlackColor,
                          backgroundColor: CXColors.lineColor_ec,
                          solidColor: CXColors.lineColor_ec,
                          onPressed: (){
                            Navigator.pop(context);
                            sheetState(() {
                              warningType = tag;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },barrierDismissible: true );
  }
  ///火情列表筛选窗口
  void showFireListFilter(void Function(void Function()) sheetState ,BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      bool isTIme = mapListIsTime;
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) logState) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 0.7.sw,
                  height: 0.4.sw,
                  decoration: BoxDecoration(
                      color: CXColors.lineColor_ec,
                      borderRadius: BorderRadius.circular(16.w)
                  ),
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(40.w, 30.w, 0, 0),
                          child: Text("选择分类",style: TextStyle(color: CXColors.BlackColor,fontSize: 32.sp,height: 1.2),)
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(0, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(isTIme?Icons.radio_button_checked:Icons.radio_button_off,color: isTIme?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("按时间分类",style: TextStyle(color: isTIme?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  isTIme = true;
                                });
                              },
                            ),
                            InkWell(
                              child: Container(
                                color: CXColors.trans,
                                padding: EdgeInsets.fromLTRB(0, 15.w, 0, 15.w),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    SizedBox(width: 30.w,),
                                    Icon(!isTIme?Icons.radio_button_checked:Icons.radio_button_off,color: !isTIme?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("按编号分类",style: TextStyle(color: !isTIme?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  isTIme = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CommonButton(
                          text: "确定",
                          width: 150.w,
                          height: 75.w,
                          margin: EdgeInsets.fromLTRB(0, 0, 20.w, 20.w),
                          solid: true,
                          elevation: 0,
                          fontSize: 28.sp,
                          textColor: CXColors.BlackColor,
                          backgroundColor: CXColors.lineColor_ec,
                          solidColor: CXColors.lineColor_ec,
                          onPressed: (){
                            Navigator.pop(context);
                            sheetState(() {
                              mapListIsTime = isTIme;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },barrierDismissible: true );
  }

  ///火情查询
  void openFireSearch() {
    showModalBottomSheet(context: context, backgroundColor: CXColors.trans,builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: 0.55.sh,
          decoration: BoxDecoration(
            color: CXColors.maintab,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.w),topRight: Radius.circular(16.w),)
          ),
          child: Column(
            children: getFilterChildren(),
          ),
        );
      },);
    }, isScrollControlled: true,);
  }

  ///资源点筛选
  void openFireResource() {
    showModalBottomSheet(context: context, backgroundColor: CXColors.trans,builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: 0.77.sh,
          decoration: BoxDecoration(
            color: CXColors.maintab,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16.w),topRight: Radius.circular(16.w),)
          ),
          child: Column(
            children: getResourceChildren(sheetState),
          ),
        );
      },);
    }, isScrollControlled: true,);
  }

  getMarkerDetailChildren(void Function(void Function()) sheetState,dynamic data) {
    List<Widget> listW = [];
    listW.add(
        Container(
          margin: EdgeInsets.fromLTRB(20.w, 20.w, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text("火点详情",style: TextStyle(color: CXColors.WhiteColor,fontSize: 30.sp),),
        ),
    );
    listW.add(
      MakerDetailCell("地址：","${data["formattedAddress"]??''}"),
    );
    listW.add(
      MakerDetailCell("观测时间：","${data["observationDatetime"].toString().substring(0,19).replaceAll("T", " ")??''}"),
    );
    listW.add(
      MakerDetailCell("经纬度：","${data["latitude"]??''} ${data["longitude"]??''}"),
    );
    listW.add(
      MakerDetailCell("可信度：","${data["credibility"]??''}"),
    );
    listW.add(
      MakerDetailCell("明火面积：","${data["area"]??''}"),
    );
    listW.add(
      MakerDetailCell("像元数：","${data["pixelNumber"]??''}"),
    );
    listW.add(
      MakerDetailCell("观测频次：","${data["observationFrequency"]??''}"),
    );
    listW.add(
      MakerDetailCell("土地类型：","林地(${data["woodland"]??0*100}%)草地(${data["grassland"]??0*100}%)农田(${data["farmland"]??0*100}%)其他(${data["otherland"]??0*100}%)"),
    );
    listW.add(
      MakerDetailCell("数据源：","${data["satellite"]??''}"),
    );
    listW.add(
      MakerDetailCell("火点编号：","${data["fireNo"]??''}"),
    );
    listW.add(
      Container(
        margin: EdgeInsets.all(20.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(child: FadeInImage.assetNetwork(placeholder:"assets/images/common/ic_no_pic.png",height: 200.w, image: data["lightImageAddress"]??" ",),onTap: (){
              ///查看图片
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                    return PictureShow(null,"http://web.ehaohai.com:2018"+data["lightImageAddress"]);
                  }));
            },),
            SizedBox(width: 50.w,),
            InkWell(child: FadeInImage.assetNetwork(placeholder:"assets/images/common/ic_no_pic.png",height: 200.w, image: data["irImageAddress"]??"",),onTap: (){
              ///查看图片
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                    return PictureShow(null,"http://web.ehaohai.com:2018"+data["irImageAddress"]);
                  }));
            },),
          ],
        ),
      ),
    );

    return listW;
  }
  getWarningDetailChildren(void Function(void Function()) sheetState,dynamic data) {
    List<Widget> listW = [];
    listW.add(
        Container(
          margin: EdgeInsets.fromLTRB(20.w, 20.w, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text("设备报警详情",style: TextStyle(color: CXColors.WhiteColor,fontSize: 30.sp),),
        ),
    );
    listW.add(
      MakerDetailCell("一体机名称：","${data["name"]??""}"),
    );
    listW.add(
      MakerDetailCell("地址：","${data["address"]??""}"),
    );
    listW.add(
      MakerDetailCell("报警时间：","${data["alarmDatetime"].toString().substring(0,19).replaceAll("T", " ")??""}"),
    );
    listW.add(
      MakerDetailCell("经纬度：","${data["longitude"]} ${data["latitude"]}"),
    );
    if(data["isReal"] == 1){
      ///已处理真实火警
      listW.add(
        MakerDetailCell("是否真实：","真实火情"),
      );
    }else{
      ///未处理
      listW.add(
        Container(
            margin: EdgeInsets.all(20.w),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("是否真实：",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),),
                  SizedBox(width: 10.w,),
                  InkWell(
                    child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                        color: CXColors.trans,
                        elevation: 2,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                                borderRadius: BorderRadius.circular(6.w)
                            ),
                            child: Text("真实",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)
                        )
                    ),
                    onTap: (){
                      showCommonDialog(context, "是否需要下发此条真实火情？", (){send(data,3);}, (){send(data,1);},leftStr: "不需要" ,rightStr: "下发");
                    },
                  ),
                  SizedBox(width: 10.w,),
                  InkWell(
                    child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                        color: CXColors.trans,
                        elevation: 2,
                        child: Container(
                            padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                                borderRadius: BorderRadius.circular(6.w)
                            ),
                            child: Text("疑似",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)
                        )
                    ),
                    onTap:(){
                      EventBusUtil.getInstance().fire(Toloading());
                      NetUtil.get(Api.REQUEST_BASE + parseRealParam(data), (dataNet){
                        EventBusUtil.getInstance().fire(Todismiss());
                        log("isReal --> dataNet = $dataNet");
                        if(dataNet!=null && dataNet["code"] == 200){
                          Fluttertoast.showToast(msg: "上报成功");
                          Navigator.pop(context);
                          getWarningListDate();
                          showWarningDetail(warningAllList[0]);
                        }else{
                          Fluttertoast.showToast(msg: "${dataNet["message"]}");
                        }
                      },params: {
                        "id": "${data["id"]}",
                        "type": false,
                        "isAndroid": 2,
                      },errorCallBack: (e){
                        EventBusUtil.getInstance().fire(Todismiss());
                        Fluttertoast.showToast(msg: "网络异常");
                      });
                    },
                  ),
                ])),
      );
    }
    listW.add(
      Container(
          margin: EdgeInsets.all(20.w),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("火情视频：",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),),
                SizedBox(width: 10.w,),
                InkWell(
                  child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                      color: CXColors.trans,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(6.w)
                          ),
                          child: Text("可见光",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)
                      )
                  ),
                  onTap: (){
                    log("---$data");
                    ///查看视频
                    if(Uri.tryParse(data["videoPath1"]??'') == null || Uri.tryParse(data["videoPath1"]??'').toString() == ""){
                      Fluttertoast.showToast(msg: "暂无可见光视频");
                      return;
                    }
                    Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) {
                          return VideoScreen(url: "${data["videoPath1"]??''}");
                        }));
                  },
                ),
                SizedBox(width: 10.w,),
                ((data["videoPath2"]??'') == "")?SizedBox():InkWell(
                  child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                      color: CXColors.trans,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(6.w)
                          ),
                          child: Text("热成像",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)
                      )
                  ),
                  onTap:(){
                    ///查看视频
                    if(Uri.tryParse(data["videoPath2"]??'') == null || Uri.tryParse(data["videoPath2"]??'').toString() == ""){
                      Fluttertoast.showToast(msg: "暂无热成像视频");
                      return;
                    }
                    Navigator.push(context,
                        MaterialPageRoute<void>(builder: (BuildContext context) {
                          return VideoScreen(url: "${data["videoPath2"]??''}");
                        }));
                  },
                ),
              ])),
    );
    listW.add(
      Container(
        margin: EdgeInsets.all(20.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InkWell(child: FadeInImage.assetNetwork(placeholder:"assets/images/common/ic_no_pic.png",height: 200.w, image: "${data["picPath1"]??''}",),onTap: (){
                ///查看图片
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                      return PictureShow(null,"${data["picPath1"]??''}");
                    }));
              },),
            ),
            SizedBox(width: 50.w,),
            Expanded(
              child: (data["picPath2"]??'')==""?SizedBox():InkWell(child: FadeInImage.assetNetwork(placeholder:"assets/images/common/ic_no_pic.png",height: 200.w, image: "${data["picPath2"]??''}",),onTap: (){
                ///查看图片
                Navigator.push(context,
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                      return PictureShow(null,"${data["picPath2"]??''}");
                    }));
              },),
            ),
          ],
        ),
      ),
    );

    return listW;
  }
  getResourceCameraDetailChildren(void Function(void Function()) sheetState,dynamic data) {
    List<Widget> listW = [];
    listW.add(
        Container(
          margin: EdgeInsets.fromLTRB(20.w, 20.w, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text("视频点详情",style: TextStyle(color: CXColors.WhiteColor,fontSize: 30.sp),),
        ),
    );
    listW.add(
      MakerDetailCell("视频点名称：","${data["name"]??""}"),
    );
    listW.add(
      MakerDetailCell("地址：","${data["address"]??""}"),
    );
    listW.add(
      MakerDetailCell("经纬度：","${data["position"]["lat"]} ${data["position"]["lng"]}"),
    );
    listW.add(
      Container(
          margin: EdgeInsets.all(20.w),
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("查看视频：",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),),
                SizedBox(width: 10.w,),
                InkWell(
                  child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                      color: CXColors.trans,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(6.w)
                          ),
                          child: Text("可见光",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)
                      )
                  ),
                  onTap: (){
                    ///查看视频
                    print("maping ==> $data");
                    if(data["resourceCameraUrl1"] == null || data["resourceCameraUrl1"] == ""){
                      Fluttertoast.showToast(msg: "暂无可见光摄像头");
                      return;
                    }
                    Navigator.pop(context);
                    EventBusUtil.getInstance().fire(MapResourceCamera(resourceCameraId1,resourceCameraUrl1));
                  },
                ),
                SizedBox(width: 10.w,),
                InkWell(
                  child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                      color: CXColors.trans,
                      elevation: 2,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                              borderRadius: BorderRadius.circular(6.w)
                          ),
                          child: Text("热成像",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)
                      )
                  ),
                  onTap:(){
                    ///查看视频
                    print("maping ==> $data");
                    if(data["resourceCameraUrl2"] == null || data["resourceCameraUrl2"].toString().trim() == ""){
                      Fluttertoast.showToast(msg: "暂无热成像摄像头");
                      return;
                    }
                    Navigator.pop(context);
                    EventBusUtil.getInstance().fire(MapResourceCamera(resourceCameraId2,resourceCameraUrl2,));
                  },
                ),
              ])),
    );

    return listW;
  }

  getResourceChildren(void Function(void Function()) sheetState) {
    List<Widget> listW = [];
    listW.add(
        Container(
          margin: EdgeInsets.fromLTRB(20.w, 20.w, 0, 0),
          alignment: Alignment.centerLeft,
          child: Text("资源点列表",style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),),
        ),
    );
    for(dynamic model in resourceInitList){
      listW.add(
        InkWell(
          child: Container(
            margin: EdgeInsets.fromLTRB(30.w, 30.w, 0, 0),
            child: Row(
              children: [
                Icon(model["state"]==true?Icons.check_box:Icons.check_box_outline_blank_rounded,color: CXColors.WhiteColor,size: 40.w,),
                SizedBox(width: 20.w,),
                Expanded(
                  child: InkWell(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text("${model["name"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 30.sp),),
                    ),
                    onTap: (){
                      sheetState((){
                        model["state"] = !model["state"];
                      });
                      Navigator.pop(context);
                      ///获取资源点数据
                      getResourceData(model);
                    },
                  ),
                ),
              ],
            ),
          ),
          onTap: (){
            sheetState((){
              model["state"] = !model["state"];
            });
            Navigator.pop(context);
            ///获取资源点数据
            getResourceData(model);
          },
        ),
      );
    }

    return listW;
  }

  ///资源视频监控点数据
  List resourceCameraList = [];
  ///获取资源数据
  void getResourceData(dynamic model) {
    //取消-去除marker数据
    if(model["state"] == false){
      for(dynamic x in resourceInitList){
        if(x["name"] == model["name"]){
          x["list"] = [];
          initMarker("resource");

          ///清除视频监控点数据(点击详情需要弹出)
          if(model["name"] == "视频监控点"){
            resourceCameraList = [];
          }
        }
      }
    }else{
      NetUtil.post(Api.REQUEST_BASE + "resource${model["apiUrl"]??''}/list", (data){
        log("MapResourceData 动态 --> data = $data");
        if(data!=null && data["code"] == 200){
          print("resourceInitList = ${resourceInitList.toString()}");
          for(dynamic x in resourceInitList){
            if(x["name"] == model["name"]){
              x["list"] = data["data"]??[];
              initMarker("resource",resourceName: "${x["name"]??''}",);

              ///取出视频监控点数据(点击详情需要弹出)
              if(model["name"] == "视频监控点"){
                resourceCameraList = data["data"]??[];
                for(int i = 0;i < resourceCameraList.length;i++){
                  resourceCameraList[i]["outName"] = "视频监控点";
                }
              }
            }
          }
        }else{
          Fluttertoast.showToast(msg: "${data["message"]}");
        }
      },params: {
        "placeholder": "",
      });
    }
  }

  List resourceInitList = [];
  List resourceAllList = [];
  ///获取初始化资源数据
  void getInitResourceData() {
    NetUtil.post(Api.MapInitResourceData, (data){
      print("MapInitResourceData --> data = $data");
      if(data!=null && data["code"] == 200){
        resourceInitList = data["data"];
        for(dynamic model in resourceInitList){
          model["state"] = false;
        }
      }else{
        Fluttertoast.showToast(msg: "${data["message"]}");
      }
    },params: {
      "isDisplay": "1",
    });
  }

  getFilterChildren() {
    List<Widget> listW = [];
    for(dynamic model in AllUtils.mapFireSearchFilterList){
      listW.add(
        Expanded(
          child: InkWell(
            child: Container(
              alignment: Alignment.center,
              child: Text("${model["title"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 30.sp),),
            ),
            onTap: (){
              ///详见AllUtils.mapFireSearchFilterList
              if(model["id"] ==  6){
                Navigator.pop(context);
                openSpecialFilter();
              }else if(model["id"] ==  0){
                startTime = DateTime.now().toIso8601String().substring(0,19);
                endTime = DateTime.now().toIso8601String().substring(0,19);
                Navigator.pop(context);
                getFireListDate(openType:"fire");
              }else if(model["id"] ==  1){
                startTime = DateTime.now().subtract(Duration(hours: 1)).toIso8601String().substring(0,19);
                endTime = DateTime.now().toIso8601String().substring(0,19);
                Navigator.pop(context);
                getFireListDate(openType:"fire");
              }else if(model["id"] ==  2){
                startTime = DateTime.now().subtract(Duration(hours: 3)).toIso8601String().substring(0,19);
                endTime = DateTime.now().toIso8601String().substring(0,19);
                Navigator.pop(context);
                getFireListDate(openType:"fire");
              }else if(model["id"] ==  3){
                startTime = DateTime.now().subtract(Duration(days: 1)).toIso8601String().substring(0,19);
                endTime = DateTime.now().toIso8601String().substring(0,19);
                Navigator.pop(context);
                getFireListDate(openType:"fire");
              }else if(model["id"] ==  4){
                startTime = DateTime.now().subtract(Duration(days: 3)).toIso8601String().substring(0,19);
                endTime = DateTime.now().toIso8601String().substring(0,19);
                Navigator.pop(context);
                getFireListDate(openType:"fire");
              }else if(model["id"] ==  5){
                startTime = DateTime.now().subtract(Duration(days: 5)).toIso8601String().substring(0,19);
                endTime = DateTime.now().toIso8601String().substring(0,19);
                Navigator.pop(context);
                getFireListDate(openType:"fire");
              }
            },
          ),
        ),
      );
      listW.add(
        BaseLine(margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),height: 0.5.w,color: CXColors.titleColor_66,),
      );
    }

    return listW;
  }

  DateTime startDateTime;
  TimeOfDay startTimeOfDay;
  ///火情查询-高级筛选
  void openSpecialFilter() {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: 0.77.sh,
          color: CXColors.WhiteColor,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(80.w, 80.w, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 60.w,
                        alignment: Alignment.centerLeft,
                        child: Text("时间段:",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),),
                    ),
                    SizedBox(width: 30.w,),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            child: Container(
                              height: 60.w,
                                alignment: Alignment.centerLeft,
                                child: Text("$startStr",style: TextStyle(color: CXColors.titleColor_99,fontSize: 26.sp),)
                            ),
                            onTap: (){
                              String s = "";
                              showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now().subtract(Duration(days: 365)), lastDate: DateTime.now().add(Duration(days: 365))).then((value) {
                                startDateTime = value;
                                s = "${value.year}-${AllUtils().parseZero(value.month)}-${AllUtils().parseZero(value.day)}";
                                showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) {
                                  startTimeOfDay = value;
                                  s += " ${AllUtils().parseZero(value.hour)}:${AllUtils().parseZero(value.minute)}:00";
                                  sheetState((){
                                    startStr = s;
                                  });
                                });
                              });
                            },
                          ),
                          InkWell(
                            child: Container(
                              height: 60.w,
                                alignment: Alignment.centerLeft,
                                child: Text("$endStr",style: TextStyle(color: CXColors.titleColor_99,fontSize: 26.sp),)
                            ),
                            onTap: (){
                              if(startDateTime == null || startTimeOfDay == null){
                                Fluttertoast.showToast(msg: "请先选择开始时间");
                                return ;
                              }
                              String e = "";
                              showDatePicker(context: context, initialDate: DateTime.now(), firstDate: startDateTime, lastDate: DateTime.now().add(Duration(days: 365))).then((value) {
                                e = "${value.year}-${AllUtils().parseZero(value.month)}-${AllUtils().parseZero(value.day)}";
                                showTimePicker(context: context, initialTime: TimeOfDay.now(),).then((value) {
                                  if(value.hour*60 + value.minute - startTimeOfDay.hour*60 - startTimeOfDay.minute < 0){
                                    Fluttertoast.showToast(msg: "结束时间不能早于开始时间");
                                    return;
                                  }
                                  e += " ${AllUtils().parseZero(value.hour)}:${AllUtils().parseZero(value.minute)}:00";
                                  sheetState((){
                                    endStr = e;
                                  });
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ///重置&&开始查询
              Container(
                margin: EdgeInsets.only(top: 50.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CommonButton(text: "重置",
                        height: 75.w,
                        width: 200.w,
                        fontSize: 28.sp,
                        margin: EdgeInsets.only(right: 50.w),
                        borderRadius: 0,
                        backgroundColor: CXColors.job_red.withAlpha(200),
                        textColor: CXColors.WhiteColor,
                        onPressed: (){reset(sheetState);}),
                    CommonButton(text: "开始查询",
                        height: 75.w,
                        width: 200.w,
                        fontSize: 28.sp,
                        margin: EdgeInsets.only(left: 50.w),
                        borderRadius: 0,
                        backgroundColor: CXColors.maintab.withAlpha(200),
                        textColor: CXColors.WhiteColor,
                        onPressed: search),
                  ],
                ),
              ),
            ],
          ),
        );
      },);
    }, isScrollControlled: true,);
  }

  void reset(void Function(void Function()) sheetState) {
    sheetState((){
      startStr = "请输入开始时间";
      endStr = "请输入结束时间";
    });
  }

  search() {
    if(startStr == "请输入开始时间" || endStr == "请输入结束时间"){
      Fluttertoast.showToast(msg: "请先选择开始结束时间");
      return;
    }
    startTime = startStr;
    endTime = endStr;
    Navigator.pop(context);
    getFireListDate(openType: "fire");
  }

  int shijianType = 0;//2 森林防火 5 砂石盗采 （4 海域监控）
  String getShijianType() {
    if(shijianType == 0){
      return "全部";
    }
    if(shijianType == 2){
      return "森林防火";
    }
    if(shijianType == 5){
      return "砂石盗采";
    }
    return "";
  }
  String getWarningType() {
    if(warningType == 0){
      return "全部";
    }
    if(warningType == 1){
      return "未处理";
    }
    if(warningType == 2){
      return "已处理";
    }
    return "";
  }

  ///Fire Marker详情
  void showMarkerDetail(dynamic data) {
    showModalBottomSheet(context: context, backgroundColor: CXColors.trans,builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: (0.6.sw + 0.6.sh)/2 + 250.w,
          decoration: BoxDecoration(
              color: CXColors.maintab,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getMarkerDetailChildren(sheetState,data),
            ),
          ),
        );
      },);
    }, isScrollControlled: true,);
  }
  ///Warning Marker详情
  void showWarningDetail(dynamic data) {
    showModalBottomSheet(context: context, backgroundColor: CXColors.trans,builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: (0.45.sw + 0.45.sh)/2 + 250.w,
          decoration: BoxDecoration(
              color: CXColors.maintab,
          ),
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getWarningDetailChildren(sheetState,data),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    child: Container(
                      height: 130.w,
                      width: 130.w,
                      alignment: Alignment.center,
                      margin: EdgeInsets.fromLTRB(0, 30.w, 50.w, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(65.w),
                        border: Border.all(color: CXColors.WhiteColor,style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/images/main/map/guide.png",height: 70.w,width: 70.w,),
                          Text("到这里",style: TextStyle(color: CXColors.WhiteColor,fontSize: 20.sp,height: 1.2),)
                        ],
                      ),
                    ),
                    onTap: (){
                      toGuide(data);
                      // toOutGuide(data);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },);
    }, isScrollControlled: true,);
  }
  ///资源监控点摄像头 Marker详情
  void showResourceCameraDetail(dynamic data) {
    showModalBottomSheet(context: context, backgroundColor: CXColors.trans,builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: (0.32.sh+0.32.sw)/2,
          decoration: BoxDecoration(
              color: CXColors.maintab,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: getResourceCameraDetailChildren(sheetState,data),
            ),
          ),
        );
      },);
    }, isScrollControlled: true,);
  }

  Future<bool> requestPermission() async {
    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      return true;
    } else {
      Fluttertoast.showToast(msg: '需要定位权限');
      return false;
    }
  }
  ///跳转内部导航
  Future<void> toGuide(dynamic dataS) async {
    LatLng toLatLng = LatLng(dataS["latitude"], dataS["longitude"]);
    AmapFlutterNavi.startNaviByEnd(toLatLng, "${dataS["name"]??''}");
  }

  ///跳转外部导航
  void toOutGuide(dynamic dataS) async{
    if(Platform.isIOS){
      bool hasApple = await MapUtil.gotoAppleMap(dataS["longitude"],dataS["latitude"],dataS["name"]);
      // if(!hasApple){
      //   ///跳转百度网页
      //   launch('http://api.map.baidu.com/direction?destination=name:${dataS["name"]}|latlng:${dataS["latitude"]},${dataS["longitude"]}&coord_type=bd09ll&mode=driving&output=html&src=webapp.companyName.appName');
      // }
    }else{
      bool hasBaidu = await MapUtil.gotoBaiduMap(dataS["longitude"],dataS["latitude"],dataS["name"]);
      if(!hasBaidu){
        ///跳转百度网页
        launch('http://api.map.baidu.com/direction?destination=name:${dataS["name"]}|latlng:${dataS["latitude"]},${dataS["longitude"]}&coord_type=bd09ll&mode=driving&output=html&src=webapp.companyName.appName');
      }
    }
  }

  String parseRealParam(dynamic data) {
    String param = "";
    if(data["type"] == 2){
      param = "fire/api/monitorFirealarm/realOrError";
    }
    if(data["type"] == 4){
      param = "fire/api/StealingFirealarm/realOrError";
    }
    if(data["type"] == 5){
      param = "fire/api/BuildingFirealarm/realOrError";
    }
    return param;
  }

  parseMarkerImage(String type) {
    String imageStr = 'assets/images/main/map/ic_fires.png';
    if(type == "2"){
      imageStr = "assets/images/main/map/ic_red_fire.png";
    }
    if(type == "4"){
      imageStr = "assets/images/main/map/ic_blue_fire.png";
    }
    if(type == "5"){
      imageStr = "assets/images/main/map/ic_yellow_fire.png";
    }
    return imageStr;
  }

  send(data,int type) {
    Navigator.pop(context);
    EventBusUtil.getInstance().fire(Toloading());
    NetUtil.get(Api.REQUEST_BASE + parseRealParam(data), (dataNet){
      EventBusUtil.getInstance().fire(Todismiss());
      log("isReal --> dataNet = $dataNet");
      if(dataNet!=null && dataNet["code"] == 200){
        Fluttertoast.showToast(msg: "上报成功");
        Navigator.pop(context);
        getWarningListDate();
        showWarningDetail(warningAllList[0]);
      }else{
        Fluttertoast.showToast(msg: "${dataNet["message"]}");
      }
    },params: {
      "id": "${data["id"]}",
      "type": type,
      "isAndroid": 2,
    },errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
      Fluttertoast.showToast(msg: "网络异常");
    });
  }
}


class WarningListCell extends StatelessWidget {
  final dynamic dataS;
  final int index;
  final bool showAddress;


  WarningListCell(this.dataS, this.index, this.showAddress);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Column(
          children: getChildren(),
        ),
      ),
      onTap: (){
        EventBusUtil.getInstance().fire(MarkerDetail("warning",dataS,pop: true));
      },
    );
  }
  getChildren(){
    List<Widget> listW = [];
    listW.add(
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.fromLTRB(3.w, 0, 3.w, 6.w),
        padding: EdgeInsets.fromLTRB(15.w, 30.w, 15.w, 30.w),
        decoration: BoxDecoration(
          color: CXColors.blue_button.withAlpha(290),
          borderRadius: BorderRadius.circular(3.w)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("监控点名称：${dataS["name"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp,height: 1.2),),
            SizedBox(height: 12.w,),
            Text("发现时间：${dataS["alarmDatetime"].toString().substring(0,19).replaceAll("T", " ")}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp,height: 1.2),),
            SizedBox(height: 12.w,),
            Text("经度、纬度：${dataS["latitude"]}、${dataS["longitude"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp,height: 1.2),),
            showAddress?SizedBox(height: 12.w,):SizedBox(),
            showAddress?Text("详细地址：${dataS["address"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp,height: 1.2),):SizedBox(),
          ],
        ),
      ),
    );
    return listW;
  }
}

class FireListCell extends StatefulWidget {
  final dynamic dataS;
  final int index;


  FireListCell(this.dataS, this.index);

  @override
  _FireListCellState createState() => _FireListCellState();
}

class _FireListCellState extends State<FireListCell> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: CXColors.trans,
        child: Column(
          children: getChildren(),
        ),
      ),
      onTap: (){
        EventBusUtil.getInstance().fire(MarkerDetail("fire",widget.dataS["list"][0],pop: true));
      },
    );
  }
  getChildren(){
    List<Widget> listW = [];
    listW.add(
        Container(
          height: 50.w,
          margin: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 0),
          child: Row(
            children: [
              Icon(Icons.access_time_rounded,color: CXColors.WhiteColor,size: 36.w,),
              SizedBox(width: 5.w,),
              Expanded(child: Text("${widget.dataS["date"].toString().substring(0,19).replaceAll("T", " ")}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp,height: 1.2),)),
            ],
          ),
        ),
    );
    for(dynamic model in widget.dataS["list"]){
      listW.add(
          InkWell(
            child: Container(
              margin: EdgeInsets.fromLTRB(36.w, 10.w, 0, 0),
              child: Row(
                children: [
                  Icon(Icons.location_on,color: CXColors.WhiteColor,size: 36.w,),
                  SizedBox(width: 5.w,),
                  Expanded(child: Text("${model["province"]} ${model["city"]} ${model["county"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp,height: 1.2),)),
                ],
              ),
            ),
            onTap: (){
              EventBusUtil.getInstance().fire(MarkerDetail("fire",model,pop: true));
            },
          ),
      );
    }
    listW.add(
      BaseLine(margin: EdgeInsets.only(top: 20.w),height: 0.5.w,color: CXColors.titleColor_77,),
    );
    return listW;
  }
}
class FireList2Cell extends StatefulWidget {
  final dynamic dataS;
  final int index;


  FireList2Cell(this.dataS, this.index);

  @override
  _FireList2CellState createState() => _FireList2CellState();
}

class _FireList2CellState extends State<FireList2Cell> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: CXColors.trans,
        child: Column(
          children: getChildren(),
        ),
      ),
      onTap: (){
        EventBusUtil.getInstance().fire(MarkerDetail("fire",widget.dataS["list"][0],pop: true));
      },
    );
  }
  getChildren(){
    List<Widget> listW = [];
    listW.add(
        Container(
          height: 50.w,
          margin: EdgeInsets.fromLTRB(20.w, 15.w, 20.w, 0),
          child: Row(
            children: [
              Icon(Icons.turned_in_not_rounded,color: CXColors.WhiteColor,size: 36.w,),
              SizedBox(width: 5.w,),
              Expanded(child: Text("${widget.dataS["no"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp,height: 1.2),)),
            ],
          ),
        ),
    );
    for(dynamic model in widget.dataS["list"]){
      listW.add(
          InkWell(
            child: Container(
              margin: EdgeInsets.fromLTRB(36.w, 10.w, 0, 0),
              child: Row(
                children: [
                  Icon(Icons.location_on,color: CXColors.WhiteColor,size: 36.w,),
                  SizedBox(width: 5.w,),
                  Expanded(child: Text("${model["province"]} ${model["city"]} ${model["county"]}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp,height: 1.2),)),
                ],
              ),
            ),
            onTap: (){
              EventBusUtil.getInstance().fire(MarkerDetail("fire",model,pop: true));
            },
          ),
      );
    }
    listW.add(
      BaseLine(margin: EdgeInsets.only(top: 20.w),height: 0.5.w,color: CXColors.titleColor_77,),
    );
    return listW;
  }
}

class MakerDetailCell extends StatelessWidget {
  final String title;
  final String content;

  MakerDetailCell(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
      child: Row(
        children: [
          Text("$title",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),),
          Expanded(child: Text("$content",style: TextStyle(color: CXColors.WhiteColor,fontSize: 25.sp),)),
        ],
      ),
    );
  }
}
