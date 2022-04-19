import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/switch/lite_rolling_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StarSettingPage extends StatefulWidget {
  const StarSettingPage({Key key}) : super(key: key);

  @override
  _StarSettingPageState createState() => _StarSettingPageState();
}

class _StarSettingPageState extends State<StarSettingPage> {
  List starList = [
    {
      "title": "全部",
      "id": -1,
      "state": true,
    },
    {
      "title": "NPP",
      "id": 1,
      "state": true,
    },
    {
      "title": "FY-4",
      "id": 2,
      "state": true,
    },
    {
      "title": "FY-3",
      "id": 3,
      "state": true,
    },
    {
      "title": "Himawari-8",
      "id": 4,
      "state": true,
    },
    {
      "title": "NOAA-18",
      "id": 5,
      "state": true,
    },
    {
      "title": "NOAA-19",
      "id": 6,
      "state": true,
    },
  ];
  List typeList = [
  {
  "title": "全部",
  "id": -1,
  "state": true,
  },
  {
  "title": "林地",
  "id": 1,
  "state": true,
  },
  {
  "title": "草地",
  "id": 2,
  "state": true,
  },
  {
  "title": "农田",
  "id": 3,
  "state": true,
  },
  {
  "title": "其他",
  "id": 4,
  "state": true,
  },
];
  List numList = [
  {
  "title": "100",
  "id": 1,
  "state": true,
  },
  {
  "title": "500",
  "id": 2,
  "state": false,
  },
  {
  "title": "1000",
  "id": 3,
  "state": false,
  },
  {
  "title": "2000",
  "id": 4,
  "state": false,
  },
  {
  "title": "5000",
  "id": 5,
  "state": false,
  },
];
List otherList = [
  {
  "title": "查询境外热源",
  "id": 1,
  "state": false,
  },
  {
  "title": "包含缓冲区",
  "id": 2,
  "hint": "（含权限外10公里分为数据，会延长查询时间）",
  "state": false,
  },
  {
  "title": "持续报警",
  "id": 3,
  "state": false,
  },
];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScaffold(
        title: "设置",
        titleSize: 30.sp,
        backgtoundColor: CXColors.lineColor_f8,
        leftImage: "assets/images/common/ic_back.png",
        leftImageSize: 40.w,
        leftCallback: (){Navigator.pop(context);},
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ///语音播报
            Container(
              margin: EdgeInsets.fromLTRB(30.w, 25.w, 0, 0),
              child: Row(
                children: [
                  Expanded(child: Text("语音播报",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),)),
                  Container(
                    margin: EdgeInsets.only(right: 10.w),
                    height: 60.w,
                    padding: EdgeInsets.fromLTRB(10.w, 2, 30.w, 2),
                    child: LiteRollingSwitch(
                      value: CustomerModel.isYuYin??false,
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
            ),
            BaseLine(margin: EdgeInsets.fromLTRB(30.w, 20.w, 0, 0),height: 2.w,),
            ///报警设置
            InkWell(
              child: Container(
                margin: EdgeInsets.fromLTRB(30.w, 30.w, 0, 0),
                alignment: Alignment.centerLeft,
                child: Text("报警设置",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),),
              ),
              onTap: openFilter,
            ),
            BaseLine(margin: EdgeInsets.fromLTRB(30.w, 25.w, 0, 0),height: 2.w,),
          ],
        ),
      ),
    );
  }
  void changeSwitch(state) {
    Future.delayed(Duration()).then((value){
      setState(() {
        CustomerModel.isYuYin = state;
        saveBoolToCache("isYuYin", CustomerModel.isYuYin);
      });
    });
  }

  ///筛选栏
  void openFilter() {
    showModalBottomSheet(context: context, builder: (BuildContext context) {
      return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) sheetState) {
        return Container(
          height: 0.77.sh,
          color: CXColors.WhiteColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///卫星监测
              Container(
                width: 1.sw,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35.w, 35.w, 0, 0),
                      child: Text("卫星监测:",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(180.w, 31.w, 100.w, 0),
                      child: Wrap(
                        children: getStarListW(sheetState),
                      ),
                    ),
                  ],
                ),
              ),
              ///地貌类型
              Container(
                width: 1.sw,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35.w, 35.w, 0, 0),
                      child: Text("地貌类型:",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(180.w, 31.w, 100.w, 0),
                      child: Wrap(
                        children: getTypeListW(sheetState),
                      ),
                    ),
                  ],
                ),
              ),
              ///火警数量
              Container(
                width: 1.sw,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35.w, 35.w, 0, 0),
                      child: Text("火警数量:",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(180.w, 31.w, 100.w, 0),
                      child: Wrap(
                        children: getNumListW(sheetState),
                      ),
                    ),
                  ],
                ),
              ),
              ///其他选项
              Container(
                width: 1.sw,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35.w, 35.w, 0, 0),
                      child: Text("其他选项:",style: TextStyle(color: CXColors.BlackColor,fontSize: 26.sp),),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(180.w, 31.w, 100.w, 0),
                      child: Wrap(
                        direction: Axis.vertical,
                        children: getOtherListW(sheetState),
                      ),
                    ),
                  ],
                ),
              ),
              ///重置&&确定
              Container(
                margin: EdgeInsets.only(top: 30.w),
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
                    CommonButton(text: "确定",
                        height: 75.w,
                        width: 200.w,
                        fontSize: 28.sp,
                        margin: EdgeInsets.only(left: 50.w),
                        borderRadius: 0,
                        backgroundColor: CXColors.maintab.withAlpha(200),
                        textColor: CXColors.WhiteColor,
                        onPressed: confirm),
                  ],
                ),
              ),
            ],
          ),
        );
      },);
    }, isScrollControlled: true,);
  }

  getStarListW(void Function(void Function()) sheetState) {
    List<Widget> list = [];
    for(dynamic model in starList){
      list.add(
        InkWell(
          child: Container(
            height: 48.w,
            margin: EdgeInsets.fromLTRB(0, 0, 20.w, 20.w),
            padding: EdgeInsets.fromLTRB(20.w, 3.w, 20.w, 3.w),
            decoration: BoxDecoration(
                color: model["state"]?CXColors.maintab:CXColors.lineColor_ec,
                borderRadius: BorderRadius.circular(30.w)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${model["title"]}",style: TextStyle(color: model["state"]?CXColors.WhiteColor:CXColors.titleColor_88,fontSize: 24.sp,height: 1.2),textAlign: TextAlign.center,),
              ],
            ),
          ),
          onTap: (){
            sheetState(() {
              if(model["title"] == "全部"){
                //'全部'
                if(model["state"] == false){
                  // 原来未选  ==》 所有都选择
                  for(dynamic change in starList){
                    change["state"] = true;
                  }
                }else{
                  // model["state"] = !model["state"];
                  for(dynamic change in starList){
                    change["state"] = false;
                  }
                }
              }else{
                //非'全部'
                if(model["state"] == true){
                  //原已被选
                  if(starList[0]["state"]==true){
                    //并且'全部'已选 ==》此项反选&&全部未选
                    starList[0]["state"] = false;
                    model["state"] = !model["state"];
                  }else{
                    model["state"] = !model["state"];
                  }
                }else{
                  //原未被选
                  model["state"] = !model["state"];
                  for(dynamic change in starList){
                    if(change["title"] == "全部"){
                      continue;
                    }
                    if(change["state"] == false){
                      return;
                    }
                    if(change == starList[starList.length-1]){
                      starList[0]["state"] = true;
                    }
                  }
                }
              }

            });
          },
        ),
      );
    }
    return list;
  }
  getTypeListW(void Function(void Function()) sheetState) {
    List<Widget> list = [];
    for(dynamic model in typeList){
      list.add(
        InkWell(
          child: Container(
            height: 48.w,
            margin: EdgeInsets.fromLTRB(0, 0, 20.w, 20.w),
            padding: EdgeInsets.fromLTRB(20.w, 3.w, 20.w, 3.w),
            decoration: BoxDecoration(
                color: model["state"]?CXColors.maintab:CXColors.lineColor_ec,
                borderRadius: BorderRadius.circular(30.w)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${model["title"]}",style: TextStyle(color: model["state"]?CXColors.WhiteColor:CXColors.titleColor_88,fontSize: 24.sp,height: 1.2),textAlign: TextAlign.center,),
              ],
            ),
          ),
          onTap: (){sheetState(() {
            if(model["title"] == "全部"){
              //'全部'
              if(model["state"] == false){
                // 原来未选  ==》 所有都选择
                for(dynamic change in typeList){
                  change["state"] = true;
                }
              }else{
                // model["state"] = !model["state"];
                for(dynamic change in typeList){
                  change["state"] = false;
                }
              }
            }else{
              //非'全部'
              if(model["state"] == true){
                //原已被选
                if(typeList[0]["state"]==true){
                  //并且'全部'已选 ==》此项反选&&全部未选
                  typeList[0]["state"] = false;
                  model["state"] = !model["state"];
                }else{
                  model["state"] = !model["state"];
                }
              }else{
                //原未被选
                model["state"] = !model["state"];
                for(dynamic change in typeList){
                  if(change["title"] == "全部"){
                    continue;
                  }
                  if(change["state"] == false){
                    return;
                  }
                  if(change == typeList[typeList.length-1]){
                    typeList[0]["state"] = true;
                  }
                }
              }
            }

          });
          },
        ),
      );
    }
    return list;
  }
  getNumListW(void Function(void Function()) sheetState) {
    List<Widget> list = [];
    for(dynamic model in numList){
      list.add(
        InkWell(
          child: Container(
            height: 48.w,
            margin: EdgeInsets.fromLTRB(0, 0, 20.w, 20.w),
            padding: EdgeInsets.fromLTRB(40.w, 3.w, 40.w, 3.w),
            decoration: BoxDecoration(
                color: model["state"]?CXColors.maintab:CXColors.lineColor_ec,
                borderRadius: BorderRadius.circular(30.w)
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${model["title"]}",style: TextStyle(color: model["state"]?CXColors.WhiteColor:CXColors.titleColor_88,fontSize: 24.sp,height: 1.2),textAlign: TextAlign.center,),
              ],
            ),
          ),
          onTap: (){
            sheetState(() {
              if(model["state"] == false){
                for(dynamic change in numList){
                  change["state"] = false;
                }
              }
              model["state"] = !model["state"];
            });
          },
        ),
      );
    }
    return list;
  }
  getOtherListW(void Function(void Function()) sheetState) {
    List<Widget> list = [];
    for(dynamic model in otherList){
      list.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///标题
            InkWell(
              child: Container(
                height: 48.w,
                margin: EdgeInsets.fromLTRB(0, 0, 20.w, model["hint"]!=null?10.w:20.w),
                padding: EdgeInsets.fromLTRB(40.w, 3.w, 40.w, 3.w),
                decoration: BoxDecoration(
                    color: model["state"]?CXColors.maintab:CXColors.lineColor_ec,
                    borderRadius: BorderRadius.circular(30.w)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${model["title"]}",style: TextStyle(color: model["state"]?CXColors.WhiteColor:CXColors.titleColor_88,fontSize: 24.sp,height: 1.2),textAlign: TextAlign.center,),
                  ],
                ),
              ),
              onTap: (){
                sheetState(() {
                  model["state"] = !model["state"];
                });
              },
            ),
            ///提示
            model["hint"]!=null?Container(margin: EdgeInsets.only(bottom: 20.w),child: Text("${model["hint"]}",style: TextStyle(color: CXColors.titleColor_99,fontSize: 18.sp,height: 1.2),textAlign: TextAlign.center,)):SizedBox(),
          ],
        ),
      );
    }
    return list;
  }

  ///重置
  reset(void Function(void Function()) sheetState) {
    for(dynamic model in starList){
      model["state"] = false;
    }
    for(dynamic model in typeList){
      model["state"] = false;
    }
    for(dynamic model in numList){
      model["state"] = false;
    }
    for(dynamic model in otherList){
      model["state"] = false;
    }
    sheetState(() {
    });
  }

  confirm() {
    for(dynamic model in starList){
      if(model["state"] == true){
        break;
      }
      if(model == starList[starList.length-1]){
        Fluttertoast.showToast(msg: "请至少选择一个卫星监控类型");
        return;
      }
    }
    for(dynamic model in typeList){
      if(model["state"] == true){
        break;
      }
      if(model == typeList[typeList.length-1]){
        Fluttertoast.showToast(msg: "请至少选择一个地貌类型");
        return;
      }
    }
    for(dynamic model in numList){
      if(model["state"] == true){
        break;
      }
      if(model == numList[numList.length-1]){
        Fluttertoast.showToast(msg: "请选择火警数量");
        return;
      }
    }
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "设置成功");
  }
}
