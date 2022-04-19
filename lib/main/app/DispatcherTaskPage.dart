import 'dart:developer';

import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/refresh/footer.dart';
import 'package:fireprevention/utils/refresh/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'DispatcherTaskDetail.dart';

class DispatcherTaskPage extends StatefulWidget {
  @override
  _DispatcherTaskPageState createState() => _DispatcherTaskPageState();
}

class _DispatcherTaskPageState extends State<DispatcherTaskPage> {
  int offset = 0; //第几页
  StreamSubscription subscription;
  EasyRefreshController _controller;
  // 条目总数
  int _count = 200;
  List dataList = [];
  List forFilterList = [];
  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    subscription =
        EventBusUtil.getInstance().on<DispatchTaskList>().listen((event) {
          initData();
        });
    initData();
  }
  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: BaseScaffold(
        title: "任务列表",
        titleSize: 30.sp,
        backgtoundColor: CXColors.lineColor_f8,
        leftImage: "assets/images/common/ic_back.png",
        leftImageSize: 40.w,
        leftCallback: (){Navigator.pop(context);},
        body: EasyRefresh.custom(
          enableControlFinishRefresh: false,
          enableControlFinishLoad: true,
          controller: _controller,
          header: HhHeader(),
          footer: HhFooter(),
          onRefresh: () async {
            dataList.clear();
            initData();
            await Future.delayed(Duration(seconds: 1), () {
              _controller.resetLoadState();
            });
          },
          onLoad: () async {
            await Future.delayed(Duration(seconds: 1), () {
              _controller.finishLoad(noMore: dataList.length >= _count);
            });
          },
          slivers: <Widget>[
            SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return InkWell(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(10.w, 10.w, 10.w, 0),
                    padding: EdgeInsets.fromLTRB(0, 12.w, 0, 12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: CXColors.titleColor_cc,width: 0.6.w),
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("任务单状态：",style: TextStyle(color: CXColors.titleColor_33,fontSize: 26.sp),),
                        Text(getFilterType(),style: TextStyle(color: CXColors.titleColor_33,fontSize: 26.sp),),
                        Icon(Icons.arrow_drop_down,color: CXColors.titleColor_99,size: 36.w,),
                      ],
                    ),
                  ),
                  onTap: (){
                    showFilter(context);
                  },
                );
              },
              childCount: 1,
            ),),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return ItemCell(dataList[index],index);
                },
                childCount: dataList.length,
              ),
            ),
          ],
        ),

          /*Column(
            children: [
              CXRefreshing(
                canLoadMore: true,
                //下拉刷新
                listWidget: ListView.builder(padding: EdgeInsets.zero,itemCount: dataList.length,itemBuilder: (BuildContext context, int index) {
                  return ItemCell(dataList[index],index);
                },),
                Refreshkeys: [_easyRefreshKey, _headerKey, _footerKey],
                //加载提示
                refresh: () async {
                  //下拉刷新时间
                  offset = 0;
                  dataList.clear();
                  initData();
                },
                loadMore: () async {
                  //上拉加载事件
//                offset++;
                },
              ),
            ],
          )*/
      ),
    );
  }

  void initData() {
    EventBusUtil.getInstance().fire(Toloading());
    NetUtil.post(Api.DispatcherTask, (data){
      EventBusUtil.getInstance().fire(Todismiss());
      print("DispatcherTask --> data = $data");
      if(data!=null && data["code"] == 200){
        setState(() {
          if(data["data"]!=null){
            for(dynamic modelM in data["data"]){
              dataList.add(modelM);
              forFilterList.add(modelM);
            }
          }
          _count = data["count"];
        });
      }
    },params: {
      "groupId":CustomerModel.groupId
    },errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
    });
  }

  ///筛选类别 0 全部, 1 未开始, 2 进行中, 3 已结束
  int filterType = 0;
  ///筛选窗口
  void showFilter(BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      int tag = filterType;
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) logState) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 0.75.sw,
                  height: 0.65.sw,
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
                              Image.asset("assets/images/common/ic_icon.png",width: 60.w,height: 60.w,),
                              SizedBox(width: 10.w,),
                              Text("任务单类别",style: TextStyle(color: CXColors.BlackColor,fontSize: 33.sp,height: 1.2),),
                            ],
                          )
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.w,),
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
                                    Text("未开始",style: TextStyle(color: (tag==1)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
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
                                    Text("进行中",style: TextStyle(color: (tag==2)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
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
                                    Icon(tag==3?Icons.radio_button_checked:Icons.radio_button_off,color: (tag==3)?CXColors.BlackColor:CXColors.titleColor_88,size: 40.w,),
                                    SizedBox(width: 20.w,),
                                    Text("已结束",style: TextStyle(color: (tag==3)?CXColors.BlackColor:CXColors.titleColor_88,fontSize: 28.sp,height: 1.2),)
                                  ],
                                ),
                              ),
                              onTap: (){
                                logState(() {
                                  tag = 3;
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
                            setState(() {
                              filterType = tag;
                              parseFilterList();
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

  String getFilterType() {
    if(filterType == 0){
      return "全部";
    }
    if(filterType == 1){
      return "未开始";
    }
    if(filterType == 2){
      return "进行中";
    }
    if(filterType == 3){
      return "已结束";
    }
    return "";
  }

  void parseFilterList() {
    log("parseFilterList ==> $filterType");
    if(filterType == 0){
      //全部
      dataList.clear();
      for(dynamic model in forFilterList){
        dataList.add(model);
      }
    }
    if(filterType == 1){
      //未开始
      dataList.clear();
      for(dynamic model in forFilterList){
        if(model["status"] == 0){
          dataList.add(model);
        }
      }
    }
    if(filterType == 2){
      //进行中
      dataList.clear();
      for(dynamic model in forFilterList){
        if(model["status"] == 1){
          dataList.add(model);
        }
      }
    }
    if(filterType == 3){
      //已结束
      dataList.clear();
      for(dynamic model in forFilterList){
        if(model["status"] == 2){
          dataList.add(model);
        }
      }
    }
    setState(() {
    });
  }

}

class ItemCell extends StatelessWidget {
  final dynamic dataS;
  final int index;

  ItemCell(this.dataS, this.index);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
            context,
            CustomRoute(
                DispatcherTaskDetail({"id":dataS["id"]}),timer: 200)).then((value) {
                  EventBusUtil.getInstance().fire(DispatchTaskList());
        });
      },
      child: Card(
        margin: EdgeInsets.fromLTRB(10.w, 15.w, 10.w, 5.w),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
        color: CXColors.WhiteColor,
        elevation: 1.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 40.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("任务内容: ${dataS["taskContent"]??""}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp,height: 1.2),),
                    SizedBox(height: 10.w,),
                    Text("开始时间: ${dataS["taskStartTime"]??""}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),),
                    SizedBox(height: 10.w,),
                    Text("截止时间: ${dataS["taskEndTime"]??""}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),),
                  ],
                ),
              ),
              CommonButton(text: parseStatus(dataS["status"]??0),
                  width: 130.w,
                  height: 55.w,
                  fontSize: 28.sp,
                  backgroundColor: CXColors.blue_button,
                  margin: EdgeInsets.fromLTRB(10.w, 0, 15.w, 0),
                  onPressed: (){

              }),
            ],
          ),
        ),
      ),
    );
  }

  parseStatus(status) {
    String str = "";
    if(status == 0){
      str = "未开始";
    }else if(status == 1){
      str = "执行中";
    }else{
      str = "已结束";
    }
    return str;
  }
}
