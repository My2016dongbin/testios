import 'dart:io';

import 'package:amap_flutter_navi/amap_flutter_navi.dart';
import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

import 'LiveUploadPage.dart';

class DispatcherTaskDetail extends StatefulWidget {
  final dynamic arguments;

  DispatcherTaskDetail(this.arguments);

  @override
  _DispatcherTaskDetailState createState() => _DispatcherTaskDetailState();
}

class _DispatcherTaskDetailState extends State<DispatcherTaskDetail> {
  String id = "";
  dynamic dataS = {"position":{}};
  dynamic dataDialog = {};
  StreamSubscription endSubscription;
  @override
  void initState() {
    super.initState();
    if(widget.arguments!=null){
      id = widget.arguments["id"]??"";
    }
    endSubscription =
        EventBusUtil.getInstance().on<EndUpload>().listen((event) {
          changeStatus(end: true);
        });
    initData();
  }
  @override
  void dispose() {
    super.dispose();
    endSubscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScaffold(
        title: "任务详情",
        titleSize: 30.sp,
        backgtoundColor: CXColors.WhiteColor,
        leftImage: "assets/images/common/ic_back.png",
        leftImageSize: 40.w,
        leftCallback: (){Navigator.pop(context);},
        body: ScrollConfiguration(
          behavior: YGSBehavior(),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ///功能栏
              Container(
                margin: EdgeInsets.only(top: 20.w),
                child: Row(
                  children: [
                    CommonButton(text: parseStatus(dataS["status"]??0),
                        width: (1.sw-24.w)/3,
                        height: 80.w,
                        margin: EdgeInsets.fromLTRB(2.w, 0, 8.w, 0),
                        backgroundColor: CXColors.blue_button,
                        onPressed: (){
                      if(dataS["status"]!=2){
                        changeStatus();
                      }else{
                        Fluttertoast.showToast(msg: "任务已完成");
                      }
                    }),
                    CommonButton(text: "到这里",
                        width: (1.sw-24.w)/3,
                        height: 80.w,
                        margin: EdgeInsets.fromLTRB(2.w, 0, 8.w, 0),
                        backgroundColor: CXColors.blue_button,
                        onPressed: (){
                      print("dataS ==> $dataS");
                      toGuide(dataS);
                    }),
                    CommonButton(text: "现场上报",
                        width: (1.sw-24.w)/3,
                        height: 80.w,
                        margin: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
                        backgroundColor: CXColors.blue_button,
                        onPressed: () {
                          Navigator.push(
                              context,
                              CustomRoute(
                                  LiveUploadPage({"taskId": id}), timer: 200)).then((value) {
                                    initData();
                          });
                        })
                  ],
                ),
              ),
              ///其它
              SizedBox(height: 26.w,),
              RowDetail("开始时间","${dataS["taskStartTime"]??""}"),
              RowDetail("结束时间","${dataS["taskEndTime"]??""}"),
              // RowDetail("执行人","${dataS["operatorName"]??""}"),
              RowDetail("任务内容","${dataS["taskContent"]??""}"),
              RowDetail("地址","${dataS["address"]??""}"),
              dataS["position"]!=null?RowDetail("经度","${dataS["position"]["lng"]??""}"):SizedBox(),
              dataS["position"]!=null?RowDetail("纬度","${dataS["position"]["lat"]??""}"):SizedBox(),
              ///报警详情
              Container(
                margin: EdgeInsets.fromLTRB(26.w, 14.w, 26.w, 0),
                child: Row(
                  children: [
                    Container(width: 160.w,alignment: Alignment.centerLeft,child: Text("报警详情：",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),)),
                    InkWell(
                      child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2.w))),
                          color: CXColors.trans,
                          elevation: 2,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(23.w, 14.w, 23.w, 14.w),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [CXColors.maintab_dark,CXColors.maintab],begin: Alignment.topCenter,end: Alignment.bottomCenter),
                                  borderRadius: BorderRadius.circular(6.w)
                              ),
                              child: Text("查看详情",style: TextStyle(color: CXColors.WhiteColor,fontSize: 26.sp),)
                          )
                      ),
                      onTap: (){
                        if(dataDialog["isReal"]!=null){
                          showWarningDetail(dataDialog);
                        }else{
                          Fluttertoast.showToast(msg: "未查询到该报警设备数据");
                        }
                      },
                    ),
                  ],
                ),
              ),
              ///附带图片
              Container(margin: EdgeInsets.fromLTRB(26.w, 14.w, 26.w, 10.w),alignment: Alignment.centerLeft,child: Text("附带图片:",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),)),
              Wrap(
                alignment: WrapAlignment.center,
                children: getWrapChildren(),
              ),
              uploadList.length==0?SizedBox():Container(
                margin: EdgeInsets.fromLTRB(26.w, 14.w, 26.w, 0),
                alignment: Alignment.centerLeft,
                child: Text("现场上报数据",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),),
              ),
              ListView.builder(itemBuilder: (BuildContext context, int index) {
                return UploadView(uploadList[index],index);
              },physics: NeverScrollableScrollPhysics(),shrinkWrap: true,itemCount: uploadList.length,padding: EdgeInsets.zero,),
            ],
          ),
        ),
      ),
    );
  }

  List uploadList = new List();
  void initData() {
    EventBusUtil.getInstance().fire(Toloading());
    NetUtil.get(Api.DispatcherTaskDetail, (data){
      print("DispatcherTaskDetail --> data = $data");
      if(data!=null && data["code"] == 200){
        setState(() {
          dataS = data["data"];
          EventBusUtil.getInstance().fire(Todismiss());
          ///查看详情数据
          String infoStr = "";
          if("${dataS["taskType"]}" == "2"){
            infoStr = "fire/api/monitorFirealarm";
          }else if("${dataS["taskType"]}" == "5"){
            infoStr = "fire/api/BuildingFirealarm";
          }
          EventBusUtil.getInstance().fire(Toloading());
          ///获取dialog详情
          NetUtil.get(Api.REQUEST_BASE + infoStr, (data){
            print("DispatcherTaskDetail --> data = $data");
            if(data!=null && data["code"] == 200){
              setState(() {
                dataDialog = data["data"][0];
                EventBusUtil.getInstance().fire(Todismiss());
              });
            }
          },params: {
            "id": dataS["fireId"]
          });
          ///获取现场上报详情
          uploadList.clear();
          NetUtil.post(Api.REQUEST_BASE + "oa/api/taskDetail/list", (data){
            print("DispatcherTaskDetail --> upload = $data");
            if(data!=null && data["code"] == 200){
              setState(() {
                uploadList = data["data"];
                EventBusUtil.getInstance().fire(Todismiss());
              });
            }
          },params: {
            "taskId": dataS["id"]
          });
        });
      }
    },params: {
      "id": id
    });
  }

  parseStatus(status) {
    String str = "";
    if(status == 0){
      str = "未开始";
    }else if(status == 1){
      str = "执行中";
    }else if(status == 2){
      str = "已结束";
    }
    return str;
  }

  getWrapChildren() {
    List<Widget> listW = [];
    double picWidth = 1.sw - 50.w;
    if(dataS["taskImg"]!=null && dataS["taskImg"].toString().isNotEmpty){
      List imageList = dataS["taskImg"].toString().split(",");
      for(String image in imageList){
        listW.add(
          InkWell(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10.w, 0, 10.w),
                child: FadeInImage.assetNetwork(placeholder: "assets/images/common/ic_jaizai.png", image: image,width: picWidth,height: picWidth/16*9,fit: BoxFit.fill,imageErrorBuilder: (buildContext,obj,stackTrance){
                  return Image.asset("assets/images/common/ic_no_pic.png",width: picWidth,height: picWidth/16*9,fit: BoxFit.fill,);
                },)),
            onTap: (){
              ///查看图片
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                    return PictureShow(null,"${image??''}");
                  }));
            },
          ),
        );
      }
    }
    return listW;
  }

  void changeStatus({bool end}) {
    EventBusUtil.getInstance().fire(Toloading());
    NetUtil.put(Api.DispatcherTaskDetail, (data){
      print("DispatcherTaskDetail --> data = $data");
      if(data!=null && data["code"] == 200){
        initData();
      }
    },params: changeStatusParams(end: end));
  }

  changeStatusParams({bool end}) {
    if(end){
      return {
        "status": 2,
        "id": id
      };
    }
    if(dataS["status"]==null || dataS["status"]==0){
      return {
        "status": 1,
        "id": id
      };
    }
    if(dataS["status"]==1){
      return {
        "status": 2,
        "id": id
      };
    }
    return {
      "id": id
    };
  }

  ///跳转内部导航
  void toGuide(dynamic dataS) async {
    LatLng toLatLng = LatLng(dataS["position"]["lat"], dataS["position"]["lng"]);
    AmapFlutterNavi.startNaviByEnd(toLatLng, "${dataS["name"]??''}");
  }

  ///跳转外部导航
  void toOutGuide(dynamic dataS) async{
    if(Platform.isIOS){
      bool hasApple = await MapUtil.gotoAppleMap(dataS["position"]["lng"],dataS["position"]["lat"],dataS["operatorName"]);
      // if(!hasApple){
      //   ///跳转百度网页
      //   launch('http://api.map.baidu.com/direction?destination=name:${dataS["name"]}|latlng:${dataS["latitude"]},${dataS["longitude"]}&coord_type=bd09ll&mode=driving&output=html&src=webapp.companyName.appName');
      // }
    }else{
      bool hasBaidu = await MapUtil.gotoBaiduMap(dataS["position"]["lng"],dataS["position"]["lat"],dataS["operatorName"]);
      if(!hasBaidu){
        ///跳转百度网页
        launch('http://api.map.baidu.com/direction?destination=name:${dataS["operatorName"]}|latlng:${dataS["position"]["lat"]},${dataS["position"]["lng"]}&coord_type=bd09ll&mode=driving&output=html&src=webapp.companyName.appName');
      }
    }
  }

  ///Warning Marker详情
  void showWarningDetail(dynamic data) {
    showModalBottomSheet(context: context, backgroundColor: CXColors.trans,builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: (0.35.sw + 0.35.sh)/2 + 250.w,
          decoration: BoxDecoration(
            color: CXColors.maintab,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: getWarningDetailChildren(sheetState,data),
            ),
          ),
        );
      },);
    }, isScrollControlled: true,);
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
      MakerDetailCell("经纬度：","${data["alarmLongitude"]} ${data["alarmLatitude"]}"),
    );
    listW.add(
      MakerDetailCell("是否真实：","${data["isReal"]}"=="0"?"疑似火情":"真实火情"),
    );
    listW.add(
      Container(
        margin: EdgeInsets.all(20.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(child: FadeInImage.assetNetwork(placeholder:"assets/images/common/ic_no_pic.png",height: 200.w, image: "${data["picPath1"]??''}",),onTap: (){
              ///查看图片
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                    return PictureShow(null,"${data["picPath1"]??''}");
                  }));
            },),
            InkWell(child: FadeInImage.assetNetwork(placeholder:"assets/images/common/ic_no_pic.png",height: 200.w, image: "${data["picPath2"]??''}",),onTap: (){
              ///查看图片
              Navigator.push(context,
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                    return PictureShow(null,"${data["picPath2"]??''}");
                  }));
            },),
          ],
        ),
      ),
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

class RowDetail extends StatelessWidget {
  final String title;
  final String content;

  RowDetail(this.title, this.content);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(26.w, 14.w, 26.w, 0),
        child: Row(
          children: [
            Container(width: 160.w,alignment: Alignment.centerLeft,child: Text("${title??""}:",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),)),
            Expanded(child: Text("${content??""}",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),)),
          ],
        ),
      );
  }
}

class RowInDetail extends StatelessWidget {
  final String title;
  final String content;

  RowInDetail(this.title, this.content);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(26.w, 14.w, 26.w, 0),
        child: Row(
          children: [
            Container(width: 160.w,alignment: Alignment.centerLeft,child: Text("${title??""}:",style: TextStyle(color: CXColors.BlackColor.withAlpha(150),fontSize: 26.sp),)),
            Expanded(child: Text("${content??""}",style: TextStyle(color: CXColors.BlackColor.withAlpha(150),fontSize: 26.sp),)),
          ],
        ),
      );
  }
}
class UploadView extends StatelessWidget {
  final dynamic data;
  final int index;

  UploadView(this.data,this.index);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RowInDetail("上报时间", AllUtils().parseDate(data["createTime"]??"")),
        RowInDetail("经度", "${data["longitude"]??""}"),
        RowInDetail("纬度", "${data["latitude"]??""}"),
        RowInDetail("现场情况", data["siteConditions"]??""),
        RowInDetail("其他信息", data["otherConditions"]??""),
        (data["videoUrl"]==null||data["videoUrl"]=="")?SizedBox():Container(
          margin: EdgeInsets.fromLTRB(26.w, 14.w, 26.w, 0),
          child: Row(
            children: [
              Container(width: 160.w,alignment: Alignment.centerLeft,child: Text("上传视频:",style: TextStyle(color: CXColors.BlackColor.withAlpha(150),fontSize: 26.sp),)),
              CommonButton(text: "查看视频", onPressed: (){
                Navigator.push(context, CustomRoute(VideoScreen(url: data["videoUrl"]??"",)));
              },width: 150.w,height: 70.w,margin: EdgeInsets.zero,backgroundColor: CXColors.maintab,fontSize: 27.sp,)
            ],
          ),
        ),
        Wrap(
          children: getImages(data,context),
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.start,
        ),
        SizedBox(height: 20.w,),
      ],
    );
  }

  getImages(data,context) {
    List<Widget> imageList = new List();
    String str = data["imgUrl"]??"";
    List list = str.split(",");
    for(String imageStr in list){
      imageList.add(
          imageStr==""?SizedBox():
          InkWell(
            child: Container(
                child: FadeInImage.assetNetwork(placeholder: "", image: imageStr,width: 300.w,height: 200.w,fit: BoxFit.cover,),
                margin:EdgeInsets.fromLTRB(25.w, 15.w, 25.w, 15.w),
            ),
            onTap: (){
              Navigator.push(context, CustomRoute(PictureShow(null,imageStr)));
            },
          ),);
    }
    return imageList;
  }
}
