import 'package:fireprevention/base/BaseCustomerLayout.dart';
import 'package:fireprevention/base/YGSBehavior.dart';
import 'package:fireprevention/main/app/HiddenPerilsPage.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomRoute.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/DispatcherTaskPage.dart';
import 'app/FireUploadPage.dart';

class AppFragment extends StatefulWidget {
  @override
  _AppFragmentState createState() => _AppFragmentState();
}

class _AppFragmentState extends State<AppFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseScaffold(
        title: "应用中心",
        titleSize: 30.sp,
        backgtoundColor: CXColors.lineColor_f0,
        body: ScrollConfiguration(
          behavior: YGSBehavior(),
          child: ListView(
            padding: EdgeInsets.only(top: 0),
            children: [
              Container(
                color: CXColors.WhiteColor,
                margin: EdgeInsets.only(top: 20.w),
                padding: EdgeInsets.all(20.w),
                child: Text("火情管理",style: TextStyle(color: CXColors.BlackColor,fontSize: 30.sp),),
              ),
              Container(
                color: CXColors.WhiteColor,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    ModelCell("火情上报","assets/images/main/ic_hq.png",(){
                      Navigator.push(
                          context,
                          CustomRoute(
                              FireUploadPage(),timer: 200));
                    }),
                    ModelCell("隐患排查","assets/images/main/ic_yhpc.png",(){
                      Navigator.push(
                          context,
                          CustomRoute(
                              HiddenPerilsPage(),timer: 200));
                    }),
                    ModelCell("调度任务","assets/images/main/ic_rw.png",(){
                      Navigator.push(
                          context,
                          CustomRoute(
                              DispatcherTaskPage(),timer: 200));
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class ModelCell extends StatelessWidget {
  final String title;
  final String image;
  final Function clickCallBack;

  ModelCell(this.title, this.image, this.clickCallBack);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.fromLTRB(60.w, 0, 10.w, 20.w),
        color: CXColors.WhiteColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("${image??"assets/images/main/ic_hq.png"}",width: 70.w,height: 70.w,fit: BoxFit.fill,),
            SizedBox(height: 5.w,),
            Text("${title??""}",style: TextStyle(color: CXColors.BlackColor,fontSize: 28.sp),)
          ],
        ),
      ),
      onTap: clickCallBack,
    );
  }
}

