import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/main/app/DispatcherTaskPage.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/refresh/footer.dart';
import 'package:fireprevention/utils/refresh/header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatisticsPage extends StatefulWidget {

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int offset = 0; //第几页
  EasyRefreshController _controller;
  // 条目总数
  int _count = 200;
  List dataList = [];
  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    initData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScaffold(
        title: "统计列表",
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
      ),
    );
  }

  void initData() {
    EventBusUtil.getInstance().fire(Toloading());
    NetUtil.get(Api.Statistics, (data){
      EventBusUtil.getInstance().fire(Todismiss());
      print("DispatcherTask --> data = $data");
      if(data!=null && data["code"] == 200){
        setState(() {
          if(data["data"]!=null){
            for(dynamic modelM in data["data"]){
              dataList.add(modelM);
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
}

class ItemCell extends StatelessWidget {
  final dynamic dataS;
  final int index;

  ItemCell(this.dataS, this.index);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(10.w, 15.w, 10.w, 5.w),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
      color: CXColors.WhiteColor,
      elevation: 1.0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 10.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("街道名称: ${dataS["countyName"]??""}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp,height: 1.2),),
                  SizedBox(height: 10.w,),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            InkWell(onTap: (){Navigator.push(context, CustomRoute(DispatcherTaskPage(status: 3,)));},child: Text("任务总数: ${dataS["allTaskCount"]??"0"}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),)),
                            SizedBox(height: 10.w,),
                            InkWell(onTap: (){Navigator.push(context, CustomRoute(DispatcherTaskPage(status: 1,)));},child: Text("执行中数: ${dataS["executingCount"]??"0"}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),)),
                            SizedBox(height: 10.w,),
                            InkWell(onTap: (){Navigator.push(context, CustomRoute(DispatcherTaskPage(status: 2,)));},child: Text("已结束数: ${dataS["completeCount"]??"0"}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),)),
                            SizedBox(height: 10.w,),
                            InkWell(onTap: (){Navigator.push(context, CustomRoute(DispatcherTaskPage(status: 0,)));},child: Text("未处理数: ${dataS["notStartCount"]??"0"}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),)),
                          ],
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text("报警总数: ${dataS["handleCount"]+dataS["unHandleCount"]}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),),
                            SizedBox(height: 10.w,),
                            Text("已处理数: ${dataS["handleCount"]??""}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),),
                            SizedBox(height: 10.w,),
                            Text("未处理数: ${dataS["unHandleCount"]??""}",style: TextStyle(color: CXColors.titleColor_55,fontSize: 26.sp),),
                          ],
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
