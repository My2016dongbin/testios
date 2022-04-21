import 'dart:developer';
import 'dart:io';

import 'package:fireprevention/LoginPage.dart';
import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/AllUtils.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/switch/lite_rolling_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_upgrade/flutter_app_upgrade.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

class MyFragment extends StatefulWidget {
  @override
  _MyFragmentState createState() => _MyFragmentState();
}

class _MyFragmentState extends State<MyFragment> {
  TextEditingController newPassWordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScaffold(
        title: "我的",
        titleSize: 30.sp,
        backgtoundColor: CXColors.lineColor_f0,
        body: ScrollConfiguration(
          behavior: YGSBehavior(),
          child: ListView(
            padding: EdgeInsets.only(top: 0),
            children: [
              ///头像&&昵称
              Container(
                margin: EdgeInsets.only(top: 20.w),
                padding: EdgeInsets.all(36.w),
                color: CXColors.WhiteColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      child: FadeInImage.assetNetwork(placeholder: "assets/images/main/user_header.png", image: "${CustomerModel.headUrl??""}",height: 160.w,width: 160.w,fit: BoxFit.fill,),
                      borderRadius: BorderRadius.circular(26.w),
                    ),
                    SizedBox(width: 15.w,),
                    Expanded(child: Text("${CustomerModel.fullName??""}",style: TextStyle(color: CXColors.BlackColor,fontSize: 30.sp),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                  ],
                ),
              ),
              ///其它
              MyRowCell("版本更新","assets/images/main/ic_update.png",(){checkVersion();}),
              MyRowCell("关于","assets/images/common/ic_about.png",(){Fluttertoast.showToast(msg: "青岛浩海网络科技股份有限公司技术支持");}),
              // MyRowCell("修改密码","assets/images/main/ic_password_my.png",(){changePassWord();}),
              audioWarning(),
              locationUpload(),
              CommonButton(text: "退出登录",
                  backgroundColor: CXColors.WhiteColor,
                  textColor: CXColors.job_red,
                  margin: EdgeInsets.only(top: 80.w),
                  borderRadius: 0,
                  height: 100.w,
                  onPressed: (){
                showCommonDialog(context, "确定退出登录吗?", (){Navigator.pop(context);}, (){
                  EventBusUtil.getInstance().fire(VideoStatus(false));
                  saveToCache("token", "");
                  CustomerModel.token = "";
                  XgFlutterPlugin().cleanTags();
                  CustomerModel.isLogin = false;
                  Fluttertoast.showToast(msg: "账号已退出");
                  Navigator.pushAndRemoveUntil(
                      context,
                      CustomRoute(
                          LoginPage(),timer: 1000),
                          (route) => route == null);
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  checkVersion() async {
    EventBusUtil.getInstance().fire(Toloading(title: '版本检测中...'));
    NetUtil.get(Api.VersionInfo, (data) async {
      EventBusUtil.getInstance().fire(Todismiss());
      log("checkVersion --> $data");
      if(data!=null && data["code"] == 200){
        String newVersion = Platform.isAndroid?data["data"][0]["versionNameIOS"]??"v1.0.1".trim():data["data"][0]["versionNameIOS"]??"v1.0.1".trim();
        PackageInfo packageInfo = await PackageInfo.fromPlatform();

        String version = packageInfo.version;
        String latestVersion = newVersion.substring(1,newVersion.length);
        CustomerModel.shareUrl  = "${data["data"][0]["apkUrl"]??""}";
        if(AllUtils().judgeVersion(version,latestVersion) == "yes") {
          bool mask = false;
//          mask = "${data["data"][0]["isForce"]}" == "1";//TODO 暂时放开
          AppUpgrade.appUpgrade(
            context,
            _checkAppInfo(data["data"][0],latestVersion,mask),
            iosAppId: 'id1599669524',
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
          Fluttertoast.showToast(msg: "已经是最新版本了");
        }
      }

    }, params: {}, errorCallBack: (e) {
      EventBusUtil.getInstance().fire(Todismiss());
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

  void changePassWord() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.fromLTRB(0, 30.w, 0, 50.w),
          titlePadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(50.w, 5, 15, 0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "新密码",
                        style: TextStyle(
                          color: CXColors.titleColor_66,
                          fontSize: 26.sp,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(width: 20.w,),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              maxLines: 1,
                              cursorColor:
                              CXColors.titleColor_99,
                              controller: newPassWordController,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(8)
                                //限制长度
                              ],
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                contentPadding:
                                EdgeInsets.fromLTRB(
                                    5.w, 0, 20, 0),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                  color: CXColors.titleColor_66,
                                  fontSize: 26.sp,height: 1.7),
                            ),
                            Container(
                              color: CXColors.titleColor_99,
                              height: 0.5,
                              margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                            ),
                          ],
                        ),
                        flex: 6,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.w),
                  child: Text("*请输入6到8位密码",style: TextStyle(color: CXColors.titleColor_77, fontSize: 24.sp,height: 1.2),),
                ),
                CommonButton(
                  margin: EdgeInsets.fromLTRB(10, 15.w, 10, 5),
                  height: 70.w,
                  textColor: CXColors.BlackColor,
                  backgroundColor: CXColors.lineColor_cc,
                  borderRadius: 6.w,
                  widthPercent: 0.25,
                  fontSize: 28.sp,
                  text: "确认",
                  onPressed: () {
                    //关闭软键盘
                    EventBusUtil.getInstance().fire(FocusHide());
                    if(newPassWordController.text.length<6){
                      Fluttertoast.showToast(msg: "密码不得低于6位");
                      return;
                    }
                    setState(() {
                      Navigator.pop(context);
                      EventBusUtil.getInstance().fire(Toloading());
                      NetUtil.put(Api.ChangePassWord, (data){
                        log("ChangePassWord --> $data");
                        EventBusUtil.getInstance().fire(Todismiss());
                        if(data!=null && data["code"] == 200){
                          Fluttertoast.showToast(msg: "密码修改成功");
                          CustomerModel.passWord = newPassWordController.text;
                          saveToCache("passWord",
                              newPassWordController.text.toString());
                          newPassWordController.clear();
                        }else{
                          Fluttertoast.showToast(msg: "密码修改失败");
                        }
                      },params: {
                        "oldPasswd":CustomerModel.passWord,
                        "newPasswd":newPassWordController.text,
                      });
                    });
                  },
                )
              ],
            )
          ],
        );
      },
    );
  }

  locationUpload() {
    return Container(
      height: 100.w,
      margin: EdgeInsets.only(top: 10.w),
      color: CXColors.WhiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(margin: EdgeInsets.only(left: 60.w),child: Text("实时位置上传",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),)),
          Container(
            height: 60.w,
            padding: EdgeInsets.fromLTRB(10.w, 2, 30.w, 2),
            child: LiteRollingSwitch(
              value: CustomerModel.appSettingBtnPosition??false,
              textOn: '开',
              textOff: '关',
              textSize: 22.sp,
              colorOff: CXColors.titleColor_99.withAlpha(200),
               colorOn: CXColors.maintab.withAlpha(200),
              iconOn: Icons.check,
              iconOff: Icons.power_settings_new,
              animationDuration: Duration(milliseconds: 600),
              onChanged: (bool state) {
                changeSwitch(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  void next() {
    ///暂无操作
  }

  void changeAudio(state) {
    Future.delayed(Duration()).then((value){
      setState(() {
        CustomerModel.isYuYin = state;
        saveBoolToCache("isYuYin", CustomerModel.isYuYin);
      });
    });
  }

  void changeSwitch(state) {
    Future.delayed(Duration()).then((value){
      setState(() {
        CustomerModel.appSettingBtnPosition = state;
        saveBoolToCache("appSettingBtnPosition", CustomerModel.appSettingBtnPosition);
      });
    });
  }

  audioWarning() {
    return Container(
      height: 100.w,
      margin: EdgeInsets.only(top: 10.w),
      color: CXColors.WhiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(margin: EdgeInsets.only(left: 60.w),child: Text("语音报警",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),)),
          Container(
            height: 60.w,
            padding: EdgeInsets.fromLTRB(10.w, 2, 30.w, 2),
            child: LiteRollingSwitch(
              value: CustomerModel.appSettingBtnPosition??false,
              textOn: '开',
              textOff: '关',
              textSize: 22.sp,
              colorOff: CXColors.titleColor_99.withAlpha(200),
              colorOn: CXColors.maintab.withAlpha(200),
              iconOn: Icons.check,
              iconOff: Icons.power_settings_new,
              animationDuration: Duration(milliseconds: 600),
              onChanged: (bool state) {
                changeAudio(state);
              },
            ),
          ),
        ],
      ),
    );
  }
}
class MyRowCell extends StatelessWidget {
  final String title;
  final String image;
  final Function clickCallBack;

  MyRowCell(this.title, this.image, this.clickCallBack);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 100.w,
        margin: EdgeInsets.only(top: 10.w),
        color: CXColors.WhiteColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 30.w,),
            Image.asset("$image",height: 30.w,width: 28.w,fit: BoxFit.fill,),
            SizedBox(width: 15.w,),
            Expanded(child: Text("$title",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),)),
          ],
        ),
      ),
      onTap: clickCallBack,
    );
  }
}
