import 'dart:developer';

import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/settings/CommonConfig.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

import 'MainPage.dart';
import 'model/EventBusModel.dart';
import 'utils/CustomRoute.dart';
import 'utils/EventBusUtils.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int timeForExit = 0;
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();
  StreamSubscription toastSubscription;
  StreamSubscription focusSubscription;
  StreamSubscription dismissSubscription;
  StreamSubscription showLoadingSubscription;
  bool keepLogin = false;


  ///Vpn
  // var state = FlutterVpnState.disconnected;
  // CharonErrorState charonState = CharonErrorState.NO_ERROR;
  @override
  initState() {
    ///Vpn
    // FlutterVpn.prepare();
    // FlutterVpn.onStateChanged.listen((s) => setState(() => state = s));
    super.initState();
    // ///Connect //222.173.76.34:443
    // FlutterVpn.simpleConnect(
    //   "222.173.76.34:443",
    //   "admin20G",
    //   "Hh123456@",
    // );
    /*

    ///Connect
    FlutterVpn.simpleConnect(
      "address",
      "username",
      "password",
    );
    ///Disconnect
    FlutterVpn.disconnect();
    ///Update State
    var newState = await FlutterVpn.currentState;
    setState(() => state = newState);
    ///Update Charon State
    var newCState = await FlutterVpn.charonErrorState;
    setState(() => charonState = newCState);

    * */

    keepLogin = CustomerModel.keepLogin;

    userController.text = CustomerModel.account;
    passController.text = CustomerModel.passWord;
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
  }
  @override
  void dispose() {
    super.dispose();
    toastSubscription.cancel();
    focusSubscription.cancel();
    dismissSubscription.cancel();
    showLoadingSubscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(width: 1.sw,height: 0.2.sh,color: Color(0xFF4A90E2),),
              Container(
                margin: EdgeInsets.only(top: 0.05.sh),
                  child: Image.asset("assets/images/common/ic_head_bg.png",fit: BoxFit.fill,width: 1.sw,height: 0.3.sh,)
              ),
              Container(
                width: 1.sw,
                height: 0.28.sh,
                padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                child: Center(
                  child: Text(
                    "${CommonConfig.appName}",style: TextStyle(
                    color: CXColors.WhiteColor,
                    fontSize: 44.sp,
                  ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.only(top: 0.2.sh),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                color: CXColors.WhiteColor,
                elevation: 2,
                child: Container(
                  width: 0.8.sw,
                  padding: EdgeInsets.all(30.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.w,),
                      Text("请输入您的用户名和密码:",style: TextStyle(color: CXColors.titleColor_99,fontSize: 26.sp),),
                      IconTextField(userController,"assets/images/common/ic_user_name.png",false,null),
                      IconTextField(passController,"assets/images/common/ic_password1.png",true,TextInputType.visiblePassword),
                      SizedBox(height: 40.w,),
                      InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 10.w, 6.w, 10.w),
                                child: Icon(keepLogin?Icons.check_box:Icons.check_box_outline_blank,size: 34.w,color: keepLogin?Color(0xFF4A90E2).withAlpha(200):CXColors.titleColor_cc,)
                            ),
                            Text("保持登录状态",style: TextStyle(color: CXColors.titleColor_99,fontSize: 23.sp,height: 1.1),),
                          ],
                        ),
                        onTap: (){
                          setState(() {
                            keepLogin = !keepLogin;
                            CustomerModel.keepLogin = keepLogin;
                          });
                        },
                        splashColor: CXColors.trans,
                      ),
                      CommonButton(text: "登录",
                          backgroundColor: Color(0xFF4A90E2),
                          margin: EdgeInsets.fromLTRB(0, 26.w, 0, 10.w),
                          onPressed: (){
                        loginPost();
                      }),
                      SizedBox(height: 10.w,),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: onBackPressed,
    );
  }

  void loginPost() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(userController.text.isEmpty){
      Fluttertoast.showToast(msg: "请输入用户名");
      return;
    }
    if(passController.text.isEmpty){
      Fluttertoast.showToast(msg: "请输入密码");
      return;
    }
    ///获取token
    EventBusUtil.getInstance().fire(Toloading(title: '正在登录...'));
    NetUtil.get(Api.Login, (data){
      if(data!=null){
        log("login-- --> $data");
        if(data!=null && data["access_token"]!=null){
          saveToCache("token", data["access_token"]);
          CustomerModel.token = data["access_token"];
          getUserInfo();
          log("getInfo");
        }
      }
    },params: {
      "username":userController.text,
      "password":passController.text,
      "grant_type":"password",
      "client_id":"client_password",
      "client_secret":"123456",
    },errorCallBack: (e){
      print("error --> $e");
      if(e.toString().contains("400")){
        Fluttertoast.showToast(msg: "密码错误");
      }else if(e.toString().contains("401")){
        Fluttertoast.showToast(msg: "账号不存在");
      }else{
        Fluttertoast.showToast(msg: "网络异常");
      }
    });
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

  void getUserInfo() {
    ///获取用户信息
    NetUtil.get(Api.UserInfo, (data){
      if(data!=null && data["code"] == 200){
        dynamic userInfo = data["data"][0];
        CustomerModel.id = userInfo["id"];
        CustomerModel.userCode = userInfo["userCode"];
        CustomerModel.fullName = userInfo["fullName"];
        CustomerModel.email = userInfo["email"];
        CustomerModel.phone = userInfo["phone"];
        CustomerModel.sex = userInfo["sex"];
        CustomerModel.entryTime = userInfo["entryTime"];
        CustomerModel.birthday = userInfo["birthday"];
        CustomerModel.type = userInfo["type"];
        CustomerModel.isSuperAdmin = userInfo["isSuperAdmin"];
        CustomerModel.comment = userInfo["comment"];
        CustomerModel.groupId = userInfo["groupId"];
        CustomerModel.gridNo = userInfo["gridNo"];
        CustomerModel.bkchar2 = userInfo["bkchar2"];
        CustomerModel.money = userInfo["money"];
        CustomerModel.lockMoney = userInfo["lockMoney"];
        CustomerModel.groupName = userInfo["groupName"];
        CustomerModel.headUrl = userInfo["headUrl"];
        CustomerModel.state = userInfo["state"];

        // getUserMainMenu();//TODO 暂时去除权限相关


        saveToCache("account",
            userController.text.toString());
        saveToCache("passWord",
            passController.text.toString());
        saveToCache("fullName", CustomerModel.fullName);
        saveToCache("headUrl", CustomerModel.headUrl);
        saveToCache("groupId", CustomerModel.groupId);
        saveToCache("gridNo", CustomerModel.gridNo);
        saveToCache("id", CustomerModel.id);
        saveBoolToCache("keepLogin", CustomerModel.keepLogin);
        CustomerModel.account = userController.text;
        CustomerModel.passWord = passController.text;
        CustomerModel.isLogin = true;
        EventBusUtil.getInstance().fire(Todismiss());
        Fluttertoast.showToast(msg: "登录成功!");
        print("gridId ==> ${CustomerModel.gridNo}");
        XgFlutterPlugin().setTags(["${CustomerModel.gridNo}"]);
        XgFlutterPlugin().addTags(["${CustomerModel.gridNo}"]);
        Navigator.pushAndRemoveUntil(
            context,
            CustomRoute(
                MainPage(),timer: 1000),
                (route) => route == null);
      }
    });
  }

  void getUserMainMenu() {
    ///获取用户主页菜单
    NetUtil.get(Api.UserMainMenu, (data){
      if(data!=null && data["code"] == 200){
        List menuInfoList = data["data"];
        for( dynamic userMenu in menuInfoList ){
          if (userMenu["menuCode"] == ("app-map")) {
            CustomerModel.appmap = true;
          }
          if (userMenu["menuCode"] == ("app-video")) {
            CustomerModel.appvideo = true;
          }
          if (userMenu["menuCode"] == ("app-application")) {
            CustomerModel.appapplication = true;
          }
          if (userMenu["menuCode"] == ("app-setting")) {
            CustomerModel.appsetting = true;
          }
        }
        getUserMenu();
      }
    });
  }

  void getUserMenu() {
    ///获取用户菜单
    NetUtil.get(Api.UserMenu, (data){
      if(data!=null && data["code"] == 200){
        List menuList = data["data"];
        for( dynamic userMenu in menuList ){
          if (userMenu["menuCode"] == "app-map") {
            CustomerModel.appmap = true;
          }
          if (userMenu["menuCode"] == "app-video") {
            CustomerModel.appvideo = true;
          }
          if (userMenu["menuCode"] == "app-application") {
            CustomerModel.appapplication = true;
          }
          if (userMenu["menuCode"] == "app-setting") {
            CustomerModel.appsetting = true;
          }

          if (userMenu["elementCode"] == "app-map-btn-satelliteFirealarm") {
            CustomerModel.appMapBtnSatelliteFirealarm = true;
          }
          if (userMenu["elementCode"] == "app-satelliteFirealarm-btn-list") {
            CustomerModel.appSatelliteFirealarmBtnList = true;
          }
          if (userMenu["elementCode"] == "app-satelliteFirealarm-btn-query") {
            CustomerModel.satelliteFirealarmBtnQuery = true;
          }
          if (userMenu["elementCode"] == "app-satelliteFirealarm-btn-setting") {
            CustomerModel.appSatelliteFirealarmBtnSetting = true;
          }
          if (userMenu["elementCode"] == "app-map-btn-resource") {
            CustomerModel.appMapBtnResource = true;
          }
          if (userMenu["elementCode"] == "app-map-btn-firealarm") {
            CustomerModel.appMapBtnFirealarm = true;
          }
          if (userMenu["elementCode"] == "app-map-btn-task") {
            CustomerModel.appMapBtnTask = true;
          }
          if (userMenu["elementCode"] == "app-video-btn-directionControl") {
            CustomerModel.appVideoBtnDirectionControl = true;
          }
          if (userMenu["elementCode"] == "app-video-btn-zoomControl") {
            CustomerModel.appVideoBtnZoomControl = true;
          }
          if (userMenu["elementCode"] == "app-application-btn-report") {
            CustomerModel.appApplicationBtnReport = true;
          }
          if (userMenu["elementCode"] == "app-report-btn-add") {
            CustomerModel.appReportBtnAdd = true;
          }
          if (userMenu["elementCode"] == "app-application-btn-dangerCheck") {
            CustomerModel.appApplicationBtnDangerCheck = true;
          }
          if (userMenu["elementCode"] == "app-dangerCheck-btn-add") {
            CustomerModel.appDangerCheckBtnAdd = true;
          }
          if (userMenu["elementCode"] == "app-application-btn-task") {
            CustomerModel.appApplicationBtnTask = true;
          }
          if (userMenu["elementCode"] == "app-setting-btn-position") {
            CustomerModel.appSettingBtnPosition = true;
            saveBoolToCache("appSettingBtnPosition", true);
          }
        }
        saveToCache("account",
            userController.text.toString());
        saveToCache("passWord",
            passController.text.toString());
        saveToCache("fullName", CustomerModel.fullName);
        saveToCache("headUrl", CustomerModel.headUrl);
        saveToCache("groupId", CustomerModel.groupId);
        CustomerModel.account = userController.text;
        CustomerModel.passWord = passController.text;
        CustomerModel.isLogin = true;
        EventBusUtil.getInstance().fire(Todismiss());
        Fluttertoast.showToast(msg: "登录成功!");
        XgFlutterPlugin().setTags(["${CustomerModel.groupId}"]);
        Navigator.pushAndRemoveUntil(
            context,
            CustomRoute(
                MainPage(),timer: 1000),
                (route) => route == null);
      }
    });
  }
}

class IconTextField extends StatelessWidget {
  final TextEditingController controller;
  final String iconPath;
  final bool obscureText;
  final TextInputType keyboardType;

  IconTextField(this.controller,this.iconPath,this.obscureText,this.keyboardType);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.w,
      margin: EdgeInsets.only(top: 50.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(color: CXColors.lineColor_cc,width: 1.w)
      ),
      child: Row(
        children: [
          SizedBox(width: 20.w,),
          Image.asset("${iconPath??"assets/images/common/ic_user_name.png"}",width: 26.w,height: 26.w,),
          keyboardType==null?Expanded(
            child: TextField(
              maxLines: 1,
              cursorColor: CXColors.titleColor_cc,
              cursorWidth: 2.w,
              controller: controller,
              obscureText: obscureText,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(16)
                //限制长度
              ],
              decoration: InputDecoration(
                contentPadding:
                EdgeInsets.fromLTRB(26.w, 0, 0, 3),
                border: InputBorder.none,
              ),
              style: TextStyle(
                  color: CXColors.titleColor_99,
                  fontSize: 26.sp,height: 1.2),
              onChanged: (val){
              },
            ),
          ):Expanded(
            child: TextField(
              maxLines: 1,
              cursorColor: CXColors.titleColor_cc,
              cursorWidth: 2.w,
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(16)
                //限制长度
              ],
              decoration: InputDecoration(
                contentPadding:
                EdgeInsets.fromLTRB(26.w, 0, 0, 3),
                border: InputBorder.none,
              ),
              style: TextStyle(
                  color: CXColors.titleColor_99,
                  fontSize: 26.sp,height: 1.2),
              onChanged: (val){
              },
            ),
          ),
        ],
      ),
    );
  }
}

