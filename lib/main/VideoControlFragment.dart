import 'dart:math';

import 'package:fijkplayer/fijkplayer.dart';
import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/AllUtils.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VideoControlFragment extends StatefulWidget {
  @override
  _VideoControlFragmentState createState() => _VideoControlFragmentState();
}

class _VideoControlFragmentState extends State<VideoControlFragment> with AutomaticKeepAliveClientMixin{
  List menuList = [];
  double videoLayoutHeight = 0.53.sh;
  double layoutControllerSize = 40.h;
  double videoWidth = 0;
  double videoHeight = 0;
  int layoutTag = 1;//1 4 9 视频布局
  int currentSelected = 0;//当前选中的视频
  List<FijkPlayer> playerList = [];
  List videoList = [];
  List modelList = [];
  StreamSubscription playerSubscription;
  StreamSubscription mapResourceCameraSubscription;
  StreamSubscription controlSubscription;
  StreamSubscription videoStatusSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initData();
    videoStatusSubscription =
        EventBusUtil.getInstance().on<VideoStatus>().listen((event) {
          if(event.show==true){
            if(playerList.isNotEmpty){
              return;
            }
            ///重新展示
            EventBusUtil.getInstance().fire(Toloading());
            Future.delayed(Duration(milliseconds: 1000)).then((value) {
              EventBusUtil.getInstance().fire(Todismiss());
            });
            for(int i = 0;i < modelList.length;i++){
              EventBusUtil.getInstance().fire(PlayerInit(modelList[i]["url"], modelList[i]["monitorId"],modelList[i]["channelId"],true));
            }
          }else{
            ///全部释放
            for(int i = 0;i < playerList.length;i++){
              playerList[i].stop();
              playerList[i].release();
            }
            playerList.clear();
            videoList.clear();
            setState(() {
            });
          }
        });
    mapResourceCameraSubscription =
        EventBusUtil.getInstance().on<MapResourceCamera>().listen((event) {
          if(event.force!=true){
            return;
          }
          if(videoList.length >=9){
            Fluttertoast.showToast(msg: "最多同时监控9台设备");
            return;
          }
          NetUtil.get(Api.VideoLeftMenuVideoHaohai, (data) {
            print("VideoLeftMenuPoint --> data = $data");
            if (data != null && data["code"] == 200) {
              print("url ==> ${data["data"][0]["url"]}");
              EventBusUtil.getInstance().fire(PlayerInit(data["data"][0]["url"], event.monitorId, event.channelId,false));
            }else{
              Fluttertoast.showToast(msg: AllUtils().cameraError);
            }
          },params: {
            "cameraId": event.channelId,
            "protocol":"RTMP",
            "streamType": "2",
            // "streamModel": "2",
            // "local": "1",
            "manufacturer": "2",
          });

        });
    playerSubscription =
        EventBusUtil.getInstance().on<PlayerInit>().listen((event) {
          if(videoList.length >=9){
            Fluttertoast.showToast(msg: "最多同时监控9台设备");
            return;
          }
          addVideo(event.url,event.monitorId,event.channelId,event.isState);
        });
    controlSubscription =
        EventBusUtil.getInstance().on<LiveController>().listen((event) {
          if(currentSelected == -1){
            Fluttertoast.showToast(msg: "请先选择一个视频");
            return;
          }
          if(currentSelected >= videoList.length){
            Fluttertoast.showToast(msg: "当前选择的未添加视频");
            return;
          }
          ///移除视频
          if(event.type == "remove"){
            EventBusUtil.getInstance().fire(Toloading());
            Future.delayed(Duration(milliseconds: 1000)).then((value) {
              EventBusUtil.getInstance().fire(Todismiss());
            });
            print("remove -- $currentSelected");
            /*//移除
            playerList[currentSelected].stop();
            playerList[currentSelected].release();
            playerList.removeAt(currentSelected);
            modelList.removeAt(currentSelected);
            videoList.removeAt(currentSelected);
            setState(() {
            });*/
            ///全部释放
            modelList.removeAt(currentSelected);
            for(int i = 0;i < playerList.length;i++){
              playerList[i].stop();
              playerList[i].release();
            }
            playerList.clear();
            videoList.clear();
            setState(() {
            });
            ///重新展示
            for(int i = 0;i < modelList.length;i++){
              EventBusUtil.getInstance().fire(PlayerInit(modelList[i]["url"], modelList[i]["monitorId"],modelList[i]["channelId"],true));
            }
          }
          print("-- ${modelList[currentSelected]}");
          ///控制视频
          if(event.type == "control"){
            print("control -- $currentSelected ${event.value} ${event.clickType}");
            /*NetUtil.post(Api.VideoControl, (data) {
              print("VideoControl --> data = $data");
              if (data != null && data["code"] == 200) {
                setState(() {

                });
              }
            },params: event.function=="distance"?{
              "id": modelList[currentSelected]["monitorId"],
              "enumCode": 11001,
              "stop": event.clickType,
              "step": event.value,//拉远拉进
            }:{
              "id": modelList[currentSelected]["monitorId"],
              "enumCode": 11001,
              "stop": event.clickType,
              "direction": event.value,//移动
            });*/

            NetUtil.get(Api.VideoControlHaoHai, (data) {
              print("VideoControlHaoHai --> data = $data");
              if (data != null && data["code"] == 200) {
                setState(() {

                });
              }
            },params: {
              // "token": aqsToken,
              "groupId": CustomerModel.groupId,
              "monitorId": modelList[currentSelected]["monitorId"],
              "channelId": modelList[currentSelected]["channelId"],//4f
              "controlType": "${event.value}",
              "stop": event.clickType?"0":"1",
              "step": "5",
              "speed": "1",
            });

          }
        });
  }
  @override
  void dispose() {
    super.dispose();
    playerSubscription.cancel();
    mapResourceCameraSubscription.cancel();
    controlSubscription.cancel();
    videoStatusSubscription.cancel();
    // for(FijkPlayer player in playerList){
    //   player.release();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: menuDrawer(),
      drawerEnableOpenDragGesture: false,
      drawerEdgeDragWidth: 0.8.sw,
      body: Builder(
        builder: (BuildContext context) {
          return BaseScaffold(
            title: "视频监控",
            titleSize: 30.sp,
            leftImage: "assets/images/main/ic_list_button.png",
            leftImageSize: 20,
            leftCallback: () {
              ///视频菜单
              leftMenu(context);
            },
            body: Column(
              children: [
                ///Videos
                Container(
                  height: videoLayoutHeight,
                  color: CXColors.BlackColor,
                  child: Stack(
                    children: [
                      Wrap(
                        children: getVideoChildren(context),
                      ),
                    ],
                  ),
                ),
                ///Controllers
                Expanded(
                  child: Container(
                    color: CXColors.main_video_bottom_background,
                    child: Column(
                      children: [
                        //layoutController
                        Container(
                          height: 80.h,
                          color: CXColors.maintab,
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              InkWell(
                                child: Container(
                                  margin: EdgeInsets.only(right: 20.w),
                                    child: Image.asset(layoutTag==9?"assets/images/main/video/ic_sixteen_selected.png":"assets/images/main/video/ic_sixteen.png",width: layoutControllerSize,height: layoutControllerSize,fit: BoxFit.fill,)
                                ),
                                onTap: (){
                                  setState(() {
                                    layoutTag = 9;
                                    mesureVideoSize();
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  margin: EdgeInsets.only(right: 50.w),
                                    child: Image.asset(layoutTag==4?"assets/images/main/video/ic_four_selected.png":"assets/images/main/video/ic_four.png",width: layoutControllerSize,height: layoutControllerSize,fit: BoxFit.fill,)
                                ),
                                onTap: (){
                                  setState(() {
                                    layoutTag = 4;
                                    mesureVideoSize();
                                  });
                                },
                              ),
                              InkWell(
                                child: Container(
                                  margin: EdgeInsets.only(right: 50.w),
                                    child: Image.asset(layoutTag==1?"assets/images/main/video/ic_one_selected.png":"assets/images/main/video/ic_one.png",width: layoutControllerSize,height: layoutControllerSize,fit: BoxFit.fill,)
                                ),
                                onTap: (){
                                  setState(() {
                                    layoutTag = 1;
                                    mesureVideoSize();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        //Others
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ControllerButton("assets/images/main/video/ic_zoom_in.png","拉近",background: "assets/images/main/video/ic_button2.png",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 11,clickType: true,function: "distance"));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 11,clickType: false,function: "distance"));
                                },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_left_top.png","左上",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 25,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 25,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_top.png","上",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 21,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 21,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_right_top.png","右上",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 26,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 26,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 3,
                                child: ControllerButton("assets/images/main/video/ic_zoom_out.png","拉远",background: "assets/images/main/video/ic_button2.png",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 12,clickType: true,function: "distance"));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 12,clickType: false,function: "distance"));
                                },),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ControllerButton("","",background: "assets/images/main/video/ic_button2.png"),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_left.png","左",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 23,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 23,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("",""),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_right_jiantou.png","右",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 24,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 24,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 3,
                                child: ControllerButton("","",background: "assets/images/main/video/ic_button2.png"),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ControllerButton("assets/images/main/video/ic_jujiao.png","聚焦",background: "assets/images/main/video/ic_button2.png",onPointerDown: (){
                                  Fluttertoast.showToast(msg: "暂无控制权限");
                          // EventBusUtil.getInstance().fire(LiveController(type: "control",function: "focus",clickType: false,));
                          },onPointerUp: (){
                            // EventBusUtil.getInstance().fire(LiveController(type: "control",function: "focus",clickType: true,));
                          },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_left_bottom.png","左下",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 27,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 27,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_bottom.png","下",onPointerDown: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 22,clickType: true,));
                                },onPointerUp: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "control",value: 22,clickType: false,));
                                },),
                              ),
                              Expanded(
                                flex: 2,
                                child: ControllerButton("assets/images/main/video/ic_right_bottom.png","右下",onPointerDown: (){
                              EventBusUtil.getInstance().fire(LiveController(type: "control",value: 28,clickType: true,));
                              },onPointerUp: (){
                                EventBusUtil.getInstance().fire(LiveController(type: "control",value: 28,clickType: false,));
                              },),
                              ),
                              Expanded(
                                flex: 3,
                                child: ControllerButton("assets/images/main/video/ic_yichu.png","移除视频",background: "assets/images/main/video/ic_button2.png",onPressed: (){
                                  EventBusUtil.getInstance().fire(LiveController(type: "remove"));
                                },),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void leftMenu(context) {
    Scaffold.of(context).openDrawer();
  }

  menuDrawer() {
    return Container(
      decoration: BoxDecoration(
          color: CXColors.maintab_dark,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10.w))),
      width: 0.8.sw,
      height: 1.sh,
      child: Stack(
        children: [
          ///Title
          Container(
            margin: EdgeInsets.fromLTRB(30.w, 80.w, 25.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(mainAxisSize: MainAxisSize.min,children: [Image.asset("assets/images/main/video/ic_jiankong.png",width: 36.w,height: 32.w,fit: BoxFit.fill,),Text("  摄像机列表",style: TextStyle(color: CXColors.blue_button,fontSize: 27.sp),)],),
                InkWell(child: Image.asset("assets/images/main/ic_list_button.png",width: 36.w,height: 24.w,fit: BoxFit.fill,),onTap: (){Navigator.pop(context);},),
              ],
            ),
          ),
          ///菜单
          Container(
            margin: EdgeInsets.only(top: 140.w),
            child: ScrollConfiguration(
              behavior: YGSBehavior(),
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child:  MenuCell(menuList,key: GlobalKey(),),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // String aqsToken = "";
  void initData() {
    NetUtil.get(Api.VideoLeftMenu, (data) {
      print("VideoLeftMenu --> data = $data");
      if (data != null && data["code"] == 200) {
        setState(() {
          menuList = data["data"];
        });
      }
    });
    /*///获取阿启视token
    NetUtil.get(Api.GetAQSToken, (data) {
      print("GetAQSToken --> data = $data");
      if (data != null && data["code"] == 200) {
        aqsToken = data["data"][0]["data"];
      }
    });*/
  }

  getVideoChildren(context) {
    List<Widget> listW = [];
    mesureVideoSize();
    for(int i = 0;i < layoutTag; i++){
      listW.add(
        InkWell(
          child: Container(
            width: videoWidth,
            height: videoHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: currentSelected == i ? CXColors.blue_button:CXColors.titleColor_55,width: currentSelected == i ? 2.w:0.5.w)
            ),
            child: videoList.length > i ? /*已添加视频*/videoList[i]:/*未添加视频*/InkWell(
                child: Image.asset("assets/images/main/video/ic_add_video.png",width: 40.w,height: 40.w,fit: BoxFit.fill,),
              onTap: (){
                  if(i == currentSelected){
                    Scaffold.of(context).openDrawer();
                  }else{
                    selectVideo(i,context);
                  }
              },
            ),
          ),
          onTap: (){
            selectVideo(i,context);
          },
        ),
      );
    }
    return listW;
  }

  void selectVideo(int i ,context) {
    if(i == currentSelected){
      if(videoList.length <= currentSelected){
        Scaffold.of(context).openDrawer();
      }
    }else{
      setState(() {
        currentSelected = i;
      });
    }
  }

  Future<void> addVideo(String url,String monitorId,String channelId,bool isState) async {
    final FijkPlayer player = FijkPlayer();
    await player.setOption(FijkOption.hostCategory, "request-screen-on", 1);
    await player.setOption(FijkOption.hostCategory, "request-audio-focus", 0);
    await player.setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    player.setDataSource(url,autoPlay: true);
    playerList.add(player);
    videoList.add(
      PlayerView(videoWidth,videoHeight,player),
    );
    if(isState!=true){
      modelList.add(
          {
            "url": url,
            "monitorId": monitorId,
            "channelId": channelId,
          }
      );
    }
    setState(() {
    });
  }

  void mesureVideoSize() {
    if(layoutTag == 1){
      videoWidth = 1.sw;
      videoHeight = videoLayoutHeight;
    }
    if(layoutTag == 4){
      videoWidth = 1.sw/2;
      videoHeight = videoLayoutHeight/2;
    }
    if(layoutTag == 9){
      videoWidth = 1.sw/3;
      videoHeight = videoLayoutHeight/3;
    }
    EventBusUtil.getInstance().fire(MesurePlayer(videoWidth,videoHeight));
  }
}

class PlayerView extends StatefulWidget {
  double videoWidth;
  double videoHeight;
  final FijkPlayer player;

  PlayerView(this.videoWidth, this.videoHeight, this.player);

  @override
  _PlayerViewState createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  StreamSubscription mesureSubscription;
  @override
  void initState() {
    super.initState();
    mesureSubscription =
        EventBusUtil.getInstance().on<MesurePlayer>().listen((event) {
          setState(() {
            widget.videoWidth = event.width;
            widget.videoHeight = event.height;
          });
        });
  }
  @override
  void dispose() {
    super.dispose();
    mesureSubscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return FijkView(width: widget.videoWidth,height: widget.videoHeight,fit: FijkFit.fill,fsFit: FijkFit.fill,
      panelBuilder: (FijkPlayer player, FijkData data, BuildContext context, Size viewSize, Rect texturePos) {
        return CustomFijkPanel(
            player: player,
            buildContext: context,
            viewSize: viewSize,
            texturePos: texturePos);
      },
      color: CXColors.BlackColor,
      player: widget.player,
    );
  }
}


class MenuCell extends StatefulWidget {
  final List list;

  MenuCell(this.list,{Key key}):super(key:key);

  @override
  _MenuCellState createState() => _MenuCellState();
}

class _MenuCellState extends State<MenuCell> {
  List<bool> isCheckList = [];
  @override
  void initState() {
    super.initState();
    for(dynamic model in widget.list){
      isCheckList.add(false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CXColors.maintab,
      child: ListView.builder(padding: EdgeInsets.zero,shrinkWrap: true,physics: NeverScrollableScrollPhysics(),itemCount: widget.list.length,itemBuilder: (BuildContext context, int index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///title
            InkWell(
              child: Container(
                height: 80.w,
                color: CXColors.maintab,
                padding: EdgeInsets.fromLTRB(25.w, 0, 15.w, 0),
                child: Row(
                  children: [
                    Image.asset(isCheckList[index]?"assets/images/main/video/ic_close.png":"assets/images/main/video/ic_open.png",width: 16.w,height: 8.w,fit: BoxFit.fill,),
                    SizedBox(width: 10.w,),
                    Expanded(child: Text("${widget.list[index]["name"]??""}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 24.sp),)),
                  ],
                ),
              ),
              onTap: (){
                //点击选择
                setState(() {
                  isCheckList[index] = !isCheckList[index];
                });
              },
            ),
            ///递归 (widget.list[index]["children"] 有内容)
            isCheckList[index]?Container(
              color: CXColors.maintab,
                padding: EdgeInsets.only(left: 20.w),child: MenuCell(widget.list[index]["children"],key: GlobalKey(),)
            ):SizedBox(),
            ///监控点 (没有children说明为最后一级  并且title被点击时  获取监控点)
            isCheckList[index]&&(widget.list[index]["children"]==null||widget.list[index]["children"].length==0)?PointCell(widget.list[index]["id"]):SizedBox(),
          ],
        );
      },),
    );
  }
}

class PointCell extends StatefulWidget {
  final String id;

  PointCell(this.id);

  @override
  _PointCellState createState() => _PointCellState();
}

class _PointCellState extends State<PointCell> {
  List pointList = [];
  List<bool> isCheckList = [];
  @override
  void initState() {
    super.initState();
    getPoints();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(50.w, 0, 15.w, 0),
      child: ListView.builder(padding: EdgeInsets.zero,itemCount: pointList.length,shrinkWrap: true,physics: NeverScrollableScrollPhysics(),itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            ///监控点内区域
            InkWell(
              child: Container(
                height: 70.w,
                color: CXColors.maintab,
              child: Row(
                children: [
                  Image.asset(isCheckList[index]?"assets/images/main/video/ic_close.png":"assets/images/main/video/ic_open.png",width: 16.w,height: 8.w,fit: BoxFit.fill,),
                  SizedBox(width: 10.w,),
                  Expanded(child: Text("${pointList[index]["monitor"]["name"]??""}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 24.sp),)),
                ],
              ),
              ),
              onTap: (){
                //点击选择
                setState(() {
                  isCheckList[index] = !isCheckList[index];
                });
              },
            ),
            ///监控点
            if (isCheckList[index]) ListView.builder(padding: EdgeInsets.zero,itemCount: pointList[index]["cameraList"].length,shrinkWrap: true,physics: NeverScrollableScrollPhysics(),itemBuilder: (BuildContext context, int i) {
              return InkWell(
                child: Container(
                  height: 70.w,
                  color: CXColors.maintab,
                  margin: EdgeInsets.only(left: 30.w),
                  child: Row(
                    children: [
                      Image.asset("assets/images/main/video/ic_player.png",width: 30.w,height: 30.w,fit: BoxFit.fill,),
                      SizedBox(width: 10.w,),
                      Expanded(child: Text("${pointList[index]["cameraList"][i]["name"]??""}",style: TextStyle(color: CXColors.WhiteColor,fontSize: 24.sp,height: 1.4),)),
                    ],
                  ),
                ),
                onTap: (){
                  ///视频选择
                  print("xuanze ==> ${pointList[index]["cameraList"]}");
                  chooseVideo(pointList[index]["cameraList"][i]["id"],pointList[index]["cameraList"][i]["monitorId"],);
                },
              );
            },) else SizedBox(),
          ],
        );
      },),
    );
  }

  void getPoints() {
    NetUtil.get(Api.VideoLeftMenuPoint, (data) {
      print("VideoLeftMenuPoint --> data = $data");
      if (data != null && data["code"] == 200) {
        setState(() {
          pointList = data["data"];
          isCheckList.clear();
          for(dynamic model in pointList){
            isCheckList.add(false);
          }
        });
      }
    },params: {
      "gridId": widget.id,
    });
  }

  void chooseVideo(String channelId,String monitorId) {
    /*NetUtil.post(Api.VideoLeftMenuVideoOld, (data) {
      print("VideoLeftMenuPoint --> data = $data");
     if (data != null && data["code"] == 200) {
       if(data["data"]==null || data["data"].length==0){
         Fluttertoast.showToast(msg: AllUtils().cameraError);
         return;
       }
       print("url = ${data["data"][0]["data"]["url"]}");
        EventBusUtil.getInstance().fire(PlayerInit(data["data"][0]["data"]["url"], id));
        Navigator.pop(context);
     }else{
       Fluttertoast.showToast(msg: AllUtils().cameraError);
     }
    },params: {
      "id": id,
      "enumCode": 10002,
      "isAndroid": "1",
      "monitoringStreamType": "101"//获取rtsp流
    });*/

    /*NetUtil.post(Api.VideoLeftMenuVideo, (data) {
      print("VideoLeftMenuPoint --> data = $data");
      if (data != null && data["code"] == 200) {
        EventBusUtil.getInstance().fire(PlayerInit(data["url"], id));
        Navigator.pop(context);
            }else{
            Fluttertoast.showToast(msg: AllUtils().cameraError);
            }
    },params: {
      "cameraId": id,
      "local": 1,
      "protocol": "hls",
      "streamModel": "3",
      "streamType": "1"
    });*/

    NetUtil.get(Api.VideoLeftMenuVideoHaohai, (data) {
      print("VideoLeftMenuPoint~~~ --> data = $data");
      if (data != null && data["code"] == 200) {
        print("url ==> ${data["data"][0]["url"]}");
        EventBusUtil.getInstance().fire(PlayerInit(data["data"][0]["url"], monitorId,channelId, false));
        // EventBusUtil.getInstance().fire(PlayerInit(AllUtils().playRtmp, id));
        Navigator.pop(context);
            }else{
            Fluttertoast.showToast(msg: AllUtils().cameraError);
            }
    },params: {
      "cameraId": channelId,
      "protocol":"RTMP",
      "streamType": "2",
      // "streamModel": "2",
      // "local": "1",
      "manufacturer": "2",
    });
  }
}

class ControllerButton extends StatelessWidget {
  final String image;
  final String background;
  final String title;
  final double borderRadius;
  final Function onPressed;
  final Function onPointerDown;
  final Function onPointerUp;

  ControllerButton(this.image, this.title,{this.background,this.borderRadius,this.onPressed,this.onPointerUp,this.onPointerDown,});

  @override
  Widget build(BuildContext context) {
    Function nullFunction = (){};
    return Listener(
      onPointerDown: (details){onPointerDown!=null?onPointerDown():nullFunction();},
      onPointerUp: (details){onPointerUp!=null?onPointerUp():nullFunction();},
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(background??"assets/images/main/video/ic_button.png",height: 200.w,fit: BoxFit.fill,),
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius??10.w),
            child: Material(
              color: CXColors.trans,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius??10.w))),
              child: InkWell(
                child: Container(
                  height: 200.w,
                  alignment: Alignment.center,
                  color: CXColors.trans,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(image,width: 40.h,height: 40.h,fit: BoxFit.fill,),
                      Text(title,style: TextStyle(color: CXColors.WhiteColor,fontSize: 24.sp),)
                    ],
                  ),
                ),
                onTap: onPressed??(){},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFijkPanel extends StatefulWidget {
  final FijkPlayer player;
  final BuildContext buildContext;
  final Size viewSize;
  final Rect texturePos;

  const CustomFijkPanel({
    @required this.player,
    this.buildContext,
    this.viewSize,
    this.texturePos,
  });

  @override
  _CustomFijkPanelState createState() => _CustomFijkPanelState();
}

class _CustomFijkPanelState extends State<CustomFijkPanel> {

  FijkPlayer get player => widget.player;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    widget.player.addListener(_playerValueChanged);
  }

  void _playerValueChanged() {
    FijkValue value = player.value;

    bool playing = (value.state == FijkState.started);
    if (playing != _playing) {
      setState(() {
        _playing = playing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _playerValueChanged();
    Rect rect = Rect.fromLTRB(
        max(0.0, widget.texturePos.left),
        max(0.0, widget.texturePos.top),
        min(widget.viewSize.width, widget.texturePos.right),
        min(widget.viewSize.height, widget.texturePos.bottom));

    return Positioned.fromRect(
      rect: rect,
      child: Container(
        alignment: Alignment.bottomLeft,
        child: Row(
          children: [
            InkWell(
              child: Container(
                margin: EdgeInsets.fromLTRB(20.w, 0, 0, 20.w),
                child: Icon(
                  _playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onTap: () {
                _playing ? widget.player.pause() : widget.player.start();
              },
            ),
            InkWell(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20.w, 0, 0, 20.w),
                  child: Icon(
                  player.value.fullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                    size: 24,
              ),
                ),
                onTap: () {
                player.value.fullScreen
                    ? player.exitFullScreen()
                    : player.enterFullScreen();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    player.removeListener(_playerValueChanged);
  }
}
