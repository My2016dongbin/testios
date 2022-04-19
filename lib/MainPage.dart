import 'dart:developer';
import 'dart:io';

import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/map/location/LocationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_upgrade/flutter_app_upgrade.dart';
import 'package:flutter_bmflocation/bdmap_location_flutter_plugin.dart';
import 'package:flutter_bmflocation/flutter_baidu_location.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';

import 'cells/YGSTab.dart';
import 'main/AppFragment.dart';
import 'main/MapFragment.dart';
import 'main/MyFragment.dart';
import 'main/VideoControlFragment.dart';
import 'main/app/DispatcherTaskPage.dart';
import 'model/CustomerModel.dart';
import 'model/EventBusModel.dart';
import 'network/Api.dart';
import 'network/NetUtil.dart';
import 'utils/AllUtils.dart';
import 'utils/CXColors.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>  with TickerProviderStateMixin{
  int timeForExit = 0;
  int tabCount = 4;
  //Tab页的控制器，可以用来定义Tab标签和内容页的坐标
  TabController tabController;
  List<YGSTab> tabBarList = [];
  List<Widget> pageList = [];
  var iconList = [];
  double iconWidth = 20;
  double iconHeight = 20;

  void initTabList(){
    tabBarList = [
      YGSTab(
        fontsize: 11,
        text: "地图",
        icon: Image(
          image: AssetImage(iconList[0]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
      YGSTab(
        fontsize: 11,
        text: "视频监控",
        icon: Image(
          image: AssetImage(iconList[1]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
      YGSTab(
        fontsize: 11,
        text: "应用",
        icon: Image(
          image: AssetImage(iconList[2]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
      YGSTab(
        fontsize: 11,
        text: "我的",
        icon: Image(
          image: AssetImage(iconList[3]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),];
    setState(() {
    });
  }
  StreamSubscription toastSubscription;
  StreamSubscription focusSubscription;
  StreamSubscription dismissSubscription;
  StreamSubscription showLoadingSubscription;
  StreamSubscription pushTouchSubscription;
  StreamSubscription mapResourceCameraSubscription;

  @override
  void initState() {
    super.initState();

    //开始定位
    startLocation();

    checkVersion();
    iconList = [
      "assets/images/main/nav_1_selected.png",
      "assets/images/main/nav_2.png",
      "assets/images/main/nav_3.png",
      "assets/images/main/nav_4.png"
    ];
    tabBarList = [
      YGSTab(
        fontsize: 11,
        text: "地图",
        icon: Image(
          image: AssetImage(iconList[0]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
      YGSTab(
        fontsize: 11,
        text: "视频监控",
        icon: Image(
          image: AssetImage(iconList[1]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
      YGSTab(
        fontsize: 11,
        text: "应用",
        icon: Image(
          image: AssetImage(iconList[2]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
      YGSTab(
        fontsize: 11,
        text: "我的",
        icon: Image(
          image: AssetImage(iconList[3]),
          width: iconWidth,
          height: iconHeight,
        ),
        alignment: Alignment.center,
      ),
    ];
    pageList = [
      MapFragment(),
      VideoControlFragment(),
      AppFragment(),
      MyFragment()
    ];

    tabController = new TabController(
        length: tabCount,
        vsync: this
    );

    toastSubscription =
        EventBusUtil.getInstance().on<ShowToast>().listen((event) {
          Fluttertoast.showToast(msg: event.msg);
        });
    focusSubscription =
        EventBusUtil.getInstance().on<FocusHide>().listen((event) {
          FocusScope.of(context).requestFocus(FocusNode());
        });

    dismissSubscription = EventBusUtil.getInstance()
        .on<Todismiss>()
        .listen((event) {
      Future.delayed(Duration(milliseconds: event.delays??200),(){
        ///hideLoading
        EasyLoading.dismiss();
      });
    });
    showLoadingSubscription = EventBusUtil.getInstance()
        .on<Toloading>()
        .listen((event) {
      Future.delayed(Duration.zero, () => setState(() {
        ///showLoading
        EasyLoading.show(status: '${event.title??""}');
      }));
    });
    pushTouchSubscription = EventBusUtil.getInstance()
        .on<PushTouch>()
        .listen((event) {
      Navigator.push(
          context,
          CustomRoute(
              DispatcherTaskPage(),timer: 200));
    });
    mapResourceCameraSubscription =
        EventBusUtil.getInstance().on<MapResourceCamera>().listen((event) {
          if(event.force == true){
            return;
          }
          tabController.index = 1;
          tabSeleted(tabController.index);
          Future.delayed(Duration(milliseconds: 200)).then((value) {
            EventBusUtil.getInstance().fire(MapResourceCamera(event.monitorId,event.channelId,force: true));
          });
        });
  }
  @override
  void dispose() {
    super.dispose();

    toastSubscription.cancel();
    focusSubscription.cancel();
    dismissSubscription.cancel();
    showLoadingSubscription.cancel();
    pushTouchSubscription.cancel();
    mapResourceCameraSubscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: CXColors.WhiteColor,
          body: YGSTabBarView(children: pageList,controller: tabController,physics: NeverScrollableScrollPhysics(),),
          bottomNavigationBar: SafeArea(
            child: Material(
              elevation: 20,
              //底部栏整体的颜色
              color: CXColors.WhiteColor,
              child: Container(
                height: 55,
                child: YGSTabBar(
                  labelStyle: TextStyle(fontSize: 12),
                  controller: tabController,
                  labelPadding: EdgeInsets.all(2),
                  tabs: tabBarList,
                  //tab被选中时的颜色，设置之后选中的时候，icon和text都会变色
                  labelColor: CXColors.tab_blue,
                  //tab未被选中时的颜色，设置之后选中的时候，icon和text都会变色
                  unselectedLabelColor: CXColors.maintab_un,
                  indicatorWeight: 0.01,
                  onTap: tabSeleted,
                ),
              ),
            ),
          )), onWillPop: onBackPressed,
    );
  }


  checkVersion() async {

    NetUtil.get(Api.VersionInfo, (data) async {
      log("checkVersion --> $data");
      if(data!=null && data["code"] == 200){
        String newVersion = Platform.isAndroid?data["data"][0]["versionName"]??"1.0.1".trim():data["data"][0]["versionName"]??"1.0.1".trim();
        PackageInfo packageInfo = await PackageInfo.fromPlatform();

        String version = packageInfo.version;
        String latestVersion = newVersion.substring(1,newVersion.length);
        CustomerModel.shareUrl  = "${data["data"][0]["apkUrl"]??""}";
        if(AllUtils().judgeVersion(version,latestVersion) == "yes") {
          bool mask = false;
         // mask = "${data["data"][0]["isForce"]}" == "1";//TODO 暂时放开
          AppUpgrade.appUpgrade(
            context,
            _checkAppInfo(data["data"][0],latestVersion,mask),
            iosAppId: 'id1578841078',
            okBackgroundColors: [CXColors.gradient_green1,CXColors.gradient_green2],
            appMarketInfo: AppMarket.xiaoMi,
            onCancel: () {
              ///以后再说
              next();

            },
            onOk: () async {

            },
            downloadProgress: (count, total) async {
              //下载完成后返回再次检测
              if(count == total){
                PackageInfo packageInfo = await PackageInfo.fromPlatform();
                String versionNow = packageInfo.version;
                if(versionNow == latestVersion || (!mask)){
                  ///完成
                  next();
                }else{
                  //再次弹窗
                  Fluttertoast.showToast(msg:"请安装最新版本");
                }
              }
            },
            downloadStatusChange: (DownloadStatus status, {dynamic error}) async {

            },
          );
        }else{

        }
      }

    }, params: {}, errorCallBack: (e) {
      Fluttertoast.showToast(msg:"系统异常，请稍后重试");
    });

  }

  Future<AppUpgradeInfo> _checkAppInfo(dynamic dataM,String latestVersion,bool mask) {
    List infoListDynamic = Platform.isAndroid?[dataM["versionDescription"]]:[dataM["versionDescription"]];
    List<String> infoListStr = [];
    for(int i = 0 ; i < infoListDynamic.length; i++){
      infoListStr.add("${infoListDynamic[i]}");
    }
    return Future.delayed(Duration(seconds: 1), () {
      return AppUpgradeInfo(
        title: '新版本V$latestVersion',
        contents: infoListStr,
        apkDownloadUrl: "${dataM["apkUrl"]??""}",
        force: mask,
      );
    });
  }

  void next() {
    ///暂无操作
  }
  //复写返回监听
  Future<bool> onBackPressed() {
    bool exit = false;
    int time_ = DateTime.now().millisecondsSinceEpoch;
    if (time_ - timeForExit > 2000) {
      EventBusUtil.getInstance().fire(ShowToast("再按一次退出程序"));
      timeForExit = time_;
      exit = false;
    } else {
      exit = true;
    }
    return new Future.value(exit);}

  void tabSeleted(int index) {
    if(index == 0){
      EventBusUtil.getInstance().fire(VideoStatus(false));
    }
    if(index == 1){
      EventBusUtil.getInstance().fire(VideoStatus(true));
    }

    setState(() {
      iconList = [
        "assets/images/main/nav_1.png",
        "assets/images/main/nav_2.png",
        "assets/images/main/nav_3.png",
        "assets/images/main/nav_4.png"
      ];
      if(tabCount == 3){
        if (index == 0) {
          iconList[0] = "assets/images/main/nav_1_selected.png";
        } else if (index == 1) {
          iconList[1] = "assets/images/main/nav_2_selected.png";
        } else if (index == 2) {
          iconList[3] = "assets/images/main/nav_4_selected.png";
        }
      }else if (tabCount == 2){
        if (index == 0) {
          iconList[1] = "assets/images/main/nav_2_selected.png";
        } else if (index == 1) {
          iconList[3] = "assets/images/main/nav_4_selected.png";
        }
      }
      else{
        if (index == 0) {
          iconList[0] = "assets/images/main/nav_1_selected.png";
        } else if (index == 1) {
          iconList[1] = "assets/images/main/nav_2_selected.png";
        } else if (index == 2) {
          iconList[2] = "assets/images/main/nav_3_selected.png";
        } else if (index == 3) {
          iconList[3] = "assets/images/main/nav_4_selected.png";
        }}
      initTabList();
    });
  }

  bool zoom = false;
  void startLocation() {
    LocationFlutterPlugin().requestPermission();

    ///启动定位
    LocationUtils.handleStartLocation(callback: (Map<String, Object> result){
      BaiduLocation baiDuLocation = BaiduLocation.fromMap(result);
      CustomerModel.latitude = baiDuLocation.latitude??CustomerModel.latitude;
      CustomerModel.longitude = baiDuLocation.longitude??CustomerModel.longitude;
      postUserLocation();
      print("位置已更新：latitude:${baiDuLocation.latitude} longitude:${baiDuLocation.longitude}");
      EventBusUtil.getInstance().fire(LocationRefresh(baiDuLocation.latitude,baiDuLocation.longitude,zoom: zoom,));
      zoom = !zoom;
      LocationUtils.cancel();
      ///循环定位
      Future.delayed(Duration(milliseconds: 10000)).then((value) {
        startLocation();
      });
    });
  }

  void postUserLocation() {
    NetUtil.post(Api.UploadUserLocation, (data) async {
      log("UploadUserLocation --> $data");
      if(data!=null && data["code"] == 200){
        log("用户位置更新成功");
      }
    },params: {
      "userId": CustomerModel.id,
      "position": {
        "lat": CustomerModel.latitude,
        "lng": CustomerModel.longitude,
      },
    });
  }
}