import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
import 'package:fireprevention/main/map/MapLocationPage.dart';
import 'package:fireprevention/model/CustomerModel.dart';
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/network/Api.dart';
import 'package:fireprevention/network/NetUtil.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:fireprevention/utils/PictureShow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class HiddenPerilsPage extends StatefulWidget {
  @override
  _HiddenPerilsPageState createState() => _HiddenPerilsPageState();
}

class _HiddenPerilsPageState extends State<HiddenPerilsPage> {
  TextEditingController resourceNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController perilsInfoController = TextEditingController();
  TextEditingController planInfoController = TextEditingController();
  List<File> images = [];
  List<String> imagesForPost = [];
  int imagePostTag = 0;
  String date;
  DateTime choosedDate;

  @override
  void initState() {
    super.initState();
    getAreaData();
  }
  @override
  void dispose() {
    super.dispose();
    EventBusUtil.getInstance().fire(VideoStatus(true));
  }

  ///?????????????????????????????????
  List provinceList = [];
  ///????????????
  List cityList = [];
  ///????????????
  List areaList = [];
  ///????????????????????????
  List currentCityList = [];
  ///????????????????????????
  List currentAreaList = [];
  String provinceStr = "????????????";
  String cityStr = "????????????";
  String areaStr = "????????????";
  FixedExtentScrollController scrollControllerP;
  int provinceIndex = 0;
  FixedExtentScrollController scrollControllerC;
  int cityIndex = 0;
  FixedExtentScrollController scrollControllerA;
  int areaIndex = 0;
  void getAreaData() {
    NetUtil.get(Api.AreaData, (data){
      print("AreaData --> data = $data");
      if(data!=null && data["code"] == 200){
        for(dynamic model in data["data"]){
          if(model["level"]==1){
            provinceList.add(model);
          }
          if(model["level"]==2){
            cityList.add(model);
          }
          if(model["level"]==3){
            areaList.add(model);
          }
        }
      }
    });
  }
  List leiBieList = [
    {
      "leiBie": "????????????",
      "leiXingList": [
        {
          "name": "??????",
          "id": 11,
        },
        {
          "name": "?????????",
          "id": 12,
        },
      ],
    },
    {
      "leiBie": "????????????",
      "leiXingList": [
        {
          "name": "??????",
          "id": 21,
        },
        {
          "name": "?????????",
          "id": 22,
        },
        {
          "name": "??????",
          "id": 23,
        },
      ],
    },
    {
      "leiBie": "????????????",
      "leiXingList": [
        {
          "name": "????????????",
          "id": 31,
        },
        {
          "name": "????????????",
          "id": 32,
        },
        {
          "name": "????????????",
          "id": 33,
        },
      ],
    },
    {
      "leiBie": "????????????",
      "leiXingList": [
        {
          "name": "????????????",
          "id": 41,
        },
        {
          "name": "????????????",
          "id": 42,
        },
        {
          "name": "????????????",
          "id": 43,
        },
      ],
    },
  ];
  FixedExtentScrollController scrollControllerL;
  FixedExtentScrollController scrollControllerR;
  int leiBieIndex = 0;
  String leiBieStr= "???????????????";
  int leiXingIndex = 0;
  String leiXingStr= "???????????????";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: BaseScaffold(
        title: "????????????",
        titleSize: 30.sp,
        backgtoundColor: CXColors.lineColor_f8,
        leftImage: "assets/images/common/ic_back.png",
        leftImageSize: 40.w,
        leftCallback: (){Navigator.pop(context);},
        body: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 130.w),
              child: ScrollConfiguration(
                behavior: YGSBehavior(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///????????????
                      Container(
                        margin: EdgeInsets.all(20.w),
                        child: Text("????????????",style: TextStyle(color: CXColors.titleColor_55,fontSize: 30.sp),),
                      ),
                      Wrap(
                        children: getWrapChildren(),
                      ),
                      SizedBox(height: 20.w,),
                      ///??????
                      Container(
                          color: CXColors.WhiteColor,
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              EditCell(resourceNameController,"???????????????"),
                              LineCell(margin: EdgeInsets.only(bottom: 18.w),),
                              //??????&&??????
                              Container(
                                height: 60.w,
                                child: Row(
                                  children: [
                                    InkWell(child: Text("$leiBieStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseTypeLeft,),
                                    Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                    InkWell(child: Text("$leiXingStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseTypeRight,),
                                    Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                  ],
                                ),
                              ),
                              LineCell(margin: EdgeInsets.fromLTRB(0, 18.w, 0, 18.w),),
                              //?????????
                              Container(
                                height: 60.w,
                                child: Row(
                                  children: [
                                    InkWell(child: Text("$provinceStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseProvince,),
                                    Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                    InkWell(child: Text("$cityStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseCity,),
                                    Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                    InkWell(child: Text("$areaStr",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),),onTap: chooseArea,),
                                    Container(margin: EdgeInsets.fromLTRB(5.w, 3.w, 10.w, 0),child: Image.asset("assets/images/main/app/ic_down.png",width: 20.w,height: 20.w,fit: BoxFit.fill,)),
                                    Expanded(child: Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(right: 20.w),
                                      child: InkWell(child: Container(
                                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                          child: Image.asset("assets/images/main/app/ic_tomap.png",width: 35.w,height: 45.w,fit: BoxFit.fill,)),onTap: mapLocation,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              LineCell(margin: EdgeInsets.only(top: 18.w),),
                              EditCell(addressController,"??????"),
                              LineCell(),
                              EditCell(longitudeController,"??????",inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]")),],keyboardType: TextInputType.number,),
                              LineCell(),
                              EditCell(latitudeController,"??????",inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]")),],keyboardType: TextInputType.number,),
                              LineCell(),
                              InkWell(child: Container(alignment: Alignment.centerLeft,height:90.w,child: Text("${date!=null?date.substring(0,16).replaceAll("T", " "):"??????"}",style: TextStyle(color: CXColors.titleColor_cc,fontSize: 28.sp),)),onTap: chooseDate,),
                              LineCell(),
                              EditCell(perilsInfoController,"?????????????????????"),
                              LineCell(),
                              EditCell(planInfoController,"?????????????????????"),
                            ],
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CommonButton(
                text: "??????",
                fontSize: 32.sp,
                backgroundColor: CXColors.maintab,
                margin: EdgeInsets.fromLTRB(20.w, 0, 20.w, 30.w),
                borderRadius: 60.w,
                onPressed: (){
                  EventBusUtil.getInstance().fire(FocusHide());
                  if(images==null || images.length==0){
                    Fluttertoast.showToast(msg: "??????????????????");
                    return;
                  }
                  if(leiBieStr.contains("?????????")||leiXingStr.contains("?????????")){
                    Fluttertoast.showToast(msg: "?????????????????????");
                    return;
                  }
                  if(provinceStr.contains("?????????")||cityStr.contains("?????????")||areaStr.contains("?????????")){
                    Fluttertoast.showToast(msg: "??????????????????");
                    return;
                  }
                  if(choosedDate==null){
                    Fluttertoast.showToast(msg: "???????????????");
                    return;
                  }
                  imagesForPost.clear();
                  imagePostTag = 0;
                  EventBusUtil.getInstance().fire(Toloading(title: "????????????..."));
                  for(File image in images){
                    commitPicture(image);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void chooseTypeLeft() {
    EventBusUtil.getInstance().fire(FocusHide());
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerL = FixedExtentScrollController(initialItem: leiBieIndex);
        int index = leiBieIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("???????????????",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerL,
                      itemExtent: 45,
                      children: getTypeLeft(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        leiBieIndex = index;
                        leiBieStr = leiBieList[leiBieIndex]["leiBie"];
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getTypeLeft() {
    List<Widget> list = [];
    for(int i = 0;i < leiBieList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(leiBieList[i]["leiBie"],style: TextStyle(color: CXColors.BlackColor,fontSize: leiBieList[i]["leiBie"].length>3?14:15),)),
          )
      );
    }
    return list;
  }
  void chooseTypeRight() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(leiBieStr.contains("?????????")){
      Fluttertoast.showToast(msg: "??????????????????");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerR = FixedExtentScrollController(initialItem: leiXingIndex);
        int index = leiXingIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("???????????????",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerR,
                      itemExtent: 45,
                      children: getTypeRight(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        leiXingIndex = index;
                        leiXingStr = leiBieList[leiBieIndex]["leiXingList"][leiXingIndex]["name"];
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getTypeRight() {
    List<Widget> list = [];
    for(int i = 0;i < leiBieList[leiBieIndex]["leiXingList"].length;i++){
      list.add(
          Container(
            child: Center(child: Text(leiBieList[leiBieIndex]["leiXingList"][i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: leiBieList[leiBieIndex]["leiXingList"][i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }
  void chooseProvince() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(provinceList==null || provinceList.isEmpty){
      Fluttertoast.showToast(msg: "?????????????????????,???????????????");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerP = FixedExtentScrollController(initialItem: provinceIndex);
        int index = provinceIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("????????????",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerP,
                      itemExtent: 45,
                      children: getProvince(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        provinceIndex = index;
                        provinceStr = provinceList[provinceIndex]["name"];
                      });
                      Navigator.pop(context);
                      ///???????????????
                      currentCityList.clear();
                      cityStr = "????????????";
                      currentAreaList.clear();
                      areaStr = "????????????";
                      for(dynamic model in cityList){
                        if(model["parentId"] == provinceList[provinceIndex]["id"]){
                          currentCityList.add(model);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getProvince() {
    List<Widget> list = [];
    for(int i = 0;i < provinceList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(provinceList[i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: provinceList[i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }
  void chooseCity() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(currentCityList.isEmpty){
      Fluttertoast.showToast(msg: "???????????????");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerC = FixedExtentScrollController(initialItem: cityIndex);
        int index = cityIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("????????????",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerC,
                      itemExtent: 45,
                      children: getCity(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        cityIndex = index;
                        cityStr = currentCityList[cityIndex]["name"];
                      });
                      Navigator.pop(context);
                      ///???????????????
                      currentAreaList.clear();
                      areaStr = "????????????";
                      for(dynamic model in areaList){
                        if(model["parentId"] == currentCityList[cityIndex]["id"]){
                          currentAreaList.add(model);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getCity() {
    List<Widget> list = [];
    for(int i = 0;i < currentCityList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(currentCityList[i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: provinceList[i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }
  void chooseArea() {
    EventBusUtil.getInstance().fire(FocusHide());
    if(currentAreaList.isEmpty){
      Fluttertoast.showToast(msg: "???????????????");
      return;
    }
    showModalBottomSheet(context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ), builder: (BuildContext context) {
        scrollControllerA = FixedExtentScrollController(initialItem: areaIndex);
        int index = areaIndex;
        return Container(
          height:200,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: Text("????????????",style: TextStyle(color: CXColors.BlackColor,fontSize: 16),)
                  )
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ScrollConfiguration(
                    behavior: YGSBehavior(),
                    child: CupertinoPicker(
                      scrollController: scrollControllerA,
                      itemExtent: 45,
                      children: getArea(),
                      onSelectedItemChanged: (int value) {
                        index = value;
                      },

                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(15,10,0,15),child: Icon(Icons.clear,color: CXColors.titleColor_99,)),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    child: Container(padding:EdgeInsets.fromLTRB(0,10,15,15),child: Icon(Icons.check,color: CXColors.titleColor_99,)),
                    onTap: (){
                      setState(() {
                        areaIndex = index;
                        areaStr = currentAreaList[areaIndex]["name"];
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },);
  }
  getArea() {
    List<Widget> list = [];
    for(int i = 0;i < currentAreaList.length;i++){
      list.add(
          Container(
            child: Center(child: Text(currentAreaList[i]["name"],style: TextStyle(color: CXColors.BlackColor,fontSize: provinceList[i]["name"].length>3?14:15),)),
          )
      );
    }
    return list;
  }

  void mapLocation() {
    EventBusUtil.getInstance().fire(FocusHide());
    EventBusUtil.getInstance().fire(VideoStatus(false));
    //????????????
    Navigator.push(
        context,
        CustomRoute(
            MapLocationPage(),timer: 200)).then((value) {
              print("location return -> $value");
              latitudeController.text = "${value["latitude"]??''}";
              longitudeController.text = "${value["longitude"]??''}";

              NetUtil.get("http://api.map.baidu.com/reverse_geocoding/v3/?ak=GTgjOvUP9u4GaIrszKeqqDF9zB8GK2Fr&mcode=4E:E0:54:19:7F:52:00:FA:9A:C6:54:C3:71:1E:EA:24:25:47:82:34;com.haohai.fireprevention&output=json&coordtype=wgs84ll&location=${value["latitude"]??''},${value["longitude"]??''}", (data){
                print("baiduApi --> data = $data");
                provinceStr = jsonDecode(data)["result"]["addressComponent"]["province"];
                cityStr = jsonDecode(data)["result"]["addressComponent"]["city"];
                areaStr = jsonDecode(data)["result"]["addressComponent"]["district"];
                addressController.text = jsonDecode(data)["result"]["formatted_address"];
                //???
                for(int i = 0;i < provinceList.length;i++){
                  if(provinceList[i]["name"] == provinceStr){
                    provinceIndex = i;
                  }
                }
                ///???????????????
                currentCityList.clear();
                currentAreaList.clear();
                for(dynamic model in cityList){
                  if(model["parentId"] == provinceList[provinceIndex]["id"]){
                    currentCityList.add(model);
                  }
                }
                //???
                for(int i = 0;i < currentCityList.length;i++){
                  if(currentCityList[i]["name"] == cityStr){
                    cityIndex = i;
                  }
                }
                ///???????????????
                currentAreaList.clear();
                for(dynamic model in areaList){
                  if(model["parentId"] == currentCityList[cityIndex]["id"]){
                    currentAreaList.add(model);
                  }
                }
                //???
                for(int i = 0;i < currentAreaList.length;i++){
                  if(currentAreaList[i]["name"] == areaStr){
                    areaIndex = i;
                  }
                }
                setState(() {
                });

              },errorCallBack: (e){
                print("e ==> $e");
                Fluttertoast.showToast(msg: "????????????");
              });
    });
  }

  void chooseDate() {
    DateTime now = DateTime.now();
    EventBusUtil.getInstance().fire(FocusHide());
    showDatePicker(context: context, initialDate: now, firstDate: now.subtract(Duration(days: 365)), lastDate: now.add(Duration(days: 365))).then((value) {
      DateTime dateTime = value;
      showTimePicker(context: context, initialTime: TimeOfDay(hour: now.hour, minute: now.minute)).then((value) {
        setState(() {
          choosedDate = DateTime(dateTime.year,dateTime.month,dateTime.day,value.hour,value.minute);
          date = choosedDate.toIso8601String();
        });
      });
    });
  }

  Future _getImageFromGallery(context,int num) async {
    List<Asset> resultList = <Asset>[];
    List<File> fileList = <File>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: num,
        enableCamera: true,
        selectedAssets: /*images*/[],
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          statusBarColor: "#212C64",
          actionBarColor: "#212C64",
          startInAllView: true,
          selectionLimitReachedText: "????????????$num?????????",
          actionBarTitle: "????????????",
          allViewTitle: "????????????",
          useDetailsView: true,
          selectCircleStrokeColor: "#000000",
        ),
      );
      if(resultList==null || resultList.length==0){
        return;
      }
      EventBusUtil.getInstance().fire(Toloading(title: "???????????????..."));
      for(Asset assetModel in resultList){
        Directory dir = await getApplicationDocumentsDirectory();
        var directory = Directory("${dir.path}/haohai");
        if(!directory.existsSync()){
          directory.createSync();
        }
        ByteData byteData = await assetModel.getByteData();
        File file = await File("${directory.path}/fileName${DateTime.now().microsecondsSinceEpoch+Random().nextInt(99)}.png").writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),flush: true);
        fileList.add(file);
      }
    } on Exception catch (e) {
    }

    if (!mounted) return;

    setState(() {
      images.addAll(fileList);
      EventBusUtil.getInstance().fire(Todismiss(delays: 300));
    });
  }

  getWrapChildren() {
    List<Widget> listW = [];
    for(File imageModel in images){
      listW.add(
        InkWell(
          child: Container(
            width: 170.w,
            margin: EdgeInsets.only(left: 26.w),
            child: Stack(
              children: [
                Image.file(imageModel,width: 170.w,height: 170.w,fit: BoxFit.fill,),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(child: Image.asset("assets/images/main/app/ic_delete.png",width: 30.w,height: 30.w,fit: BoxFit.fill,),onTap: (){
                    ///????????????
                    setState(() {
                      images.remove(imageModel);
                    });
                  },),
                ),
              ],
            ),
          ),
          onTap: (){
            EventBusUtil.getInstance().fire(FocusHide());
            ///????????????
            Navigator.push(context,
                MaterialPageRoute<void>(builder: (BuildContext context) {
                  return PictureShow(imageModel,null);
                }));
          },
        ),
      );
    }
    if(images.length < 2){
      listW.add(
        InkWell(
          child: Container(
            margin: EdgeInsets.only(left: 26.w),
            child: Image.asset("assets/images/main/app/ic_add_photo.png",width: 170.w,height: 170.w,fit: BoxFit.fill,),
          ),
          onTap: (){
            ///????????????
            EventBusUtil.getInstance().fire(FocusHide());
            _getImageFromGallery(context,2-images.length);
          },
        ),
      );
    }

    return listW;
  }

  Future<void> commitPicture(File image) async {
    NetUtil.postForm("http://api.ehaohai.com:10100/oa/api/workReport/fileUploadAnByNotToken", (data){
      print("FireUpload --> data = $data");
      if(data!=null && data["code"] == 200){
        for(String img in data["data"]["img"]){
          imagesForPost.add(img);
        }
        imagePostTag++;
        print("imagePostTag = $imagePostTag  images.length = ${images.length} ");
        if(imagePostTag == images.length){
          // - ????????????
          commit();
        }
      }else{
        EventBusUtil.getInstance().fire(Todismiss());
        if(data!=null && data["message"] != null){
          Fluttertoast.showToast(msg: "${data["message"]}");
        }
      }
    },params: FormData.fromMap({
      "file" : await MultipartFile.fromFile(image.path,filename: "fileName.png"),
    }),errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
      Fluttertoast.showToast(msg: "????????????");
    });
  }
  void commit() {
    NetUtil.post(Api.DangerCheck, (data){
      print("DangerCheck --> data = $data");
      EventBusUtil.getInstance().fire(Todismiss());
      if(data!=null && data["code"] == 200){
        Fluttertoast.showToast(msg: "????????????");
        if(mounted){
          Navigator.pop(context);
        }
      }else{
        if(data!=null && data["message"] != null){
          Fluttertoast.showToast(msg: "${data["message"]}");
        }
      }
    },params: commitParams(),errorCallBack: (e){
      EventBusUtil.getInstance().fire(Todismiss());
      Fluttertoast.showToast(msg: "????????????");
    });
  }

  commitParams() {
    dynamic params = {
      "cityCode" : currentCityList[cityIndex]["id"],
      "cityName" : currentCityList[cityIndex]["name"],
      "provinceCode" : provinceList[provinceIndex]["id"],
      "provinceName" : provinceList[provinceIndex]["name"],
      "address" : addressController.text,
      "resourceName" : resourceNameController.text,
      "dangerType" : leiBieList[leiBieIndex]["leiXingList"][leiXingIndex]["name"],
      "discoverTime" : "${choosedDate.toIso8601String()}",
      "dangerDescription" : perilsInfoController.text,
      "remark" : planInfoController.text,
      "position" : {
        "lat" : latitudeController.text,
        "lng" : longitudeController.text,
      },
    };
    for (int i = 0; i < imagesForPost.length; i++) {
      params["pic${i+1}"] = imagesForPost[i];
    }
    return params;
  }
}

class EditCell extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;

  EditCell(this.controller, this.hint,{this.inputFormatters,this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      cursorColor: CXColors.titleColor_99,
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding:
        EdgeInsets.fromLTRB(0.w, 0, 0, 3),
        border: InputBorder.none,
        hintText: '${hint??""}',
        hintStyle: TextStyle(
            color: CXColors.titleColor_cc,
            fontSize: 28.sp),
      ),
      style: TextStyle(
          color: CXColors.titleColor_77,
          fontSize: 28.sp),
    );
  }
}
class LineCell extends StatelessWidget {
  final EdgeInsets margin;

  LineCell({this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CXColors.lineColor_ec,
      height: 1.w,
      width: 1.sw,
      margin: margin,
    );
  }
}

