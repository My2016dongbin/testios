import 'dart:io';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'CXColors.dart';

class VideoScreen extends StatefulWidget {
  final String url;

  VideoScreen({@required this.url});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FijkPlayer player = FijkPlayer();
  bool playError = false;

  _VideoScreenState();

  @override
  void initState() {
    super.initState();
    print("Uri.tryParse(widget.url) ==> ${Uri.tryParse(widget.url)}");
    if(Uri.tryParse(widget.url) == null || Uri.tryParse(widget.url).toString() == ""){
      Fluttertoast.showToast(msg: "视频状态异常无法播放");
      playError = true;
      return;
    }
    player.setDataSource(widget.url, autoPlay: true,showCover: false);
    EventBusUtil.getInstance().fire(Toloading());
    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      EventBusUtil.getInstance().fire(Todismiss());
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          body: BaseScaffold(
            title: "视频详情",
            leftImage: "assets/images/common/ic_back.png",
            leftImageSize: 40.w,
            titleSize: 30.sp,
            backgtoundColor: CXColors.titleColor_77,
            leftCallback: (){
              if(Platform.isIOS){
                player.stop();
                player.release();
              }
              Navigator.pop(context);
            },
            body: playError?Center(
              child: Container(
                width: 1.sw,
                height: 0.6.sw,
                color: CXColors.BlackColor,
                alignment: Alignment.center,
                child: Text("视频状态异常无法播放",style: TextStyle(color: CXColors.WhiteColor,fontSize: 28.sp),),
              ),
            )
                :Container(
              alignment: Alignment.center,
              color: CXColors.BlackColor,
              padding: EdgeInsets.only(bottom: 0.2.sw),
              child: FijkView(
                color: CXColors.BlackColor,
                player: player,
              ),
            ),
          )),
      onWillPop: onBackPressed,
    );
  }

  //复写返回监听
  Future<bool> onBackPressed() {
    if(Platform.isIOS){
      player.stop();
      player.release();
    }
    Navigator.pop(context);}

  @override
  void dispose() {
    super.dispose();
    if(Platform.isAndroid){
      player.stop();
      player.release();
    }
  }

}