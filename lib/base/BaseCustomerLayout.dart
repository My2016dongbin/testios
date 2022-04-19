
import 'package:fireprevention/model/EventBusModel.dart';
import 'package:fireprevention/utils/CXColors.dart';
import 'package:fireprevention/utils/CustomerLayout.dart';
import 'package:fireprevention/utils/EventBusUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseScaffold extends StatefulWidget {
  Widget body;
  String backgroundImage;
  Color barBackgtoundColor;
  Color backgtoundColor;
  double bodyMargintop;
  double barHeight;
  Color barTitleColor;
  bool trans;
  String leftImage;
  String rightImage;
  double leftImageSize;
  double rightImageSize;
  String title;
  double titleSize;
  String centerImage;
  String leftTitle;
  String rightTitle;
  Function leftCallback;
  Function rightCallback;

  BaseScaffold({this.body,this.backgroundImage,this.barBackgtoundColor,this.backgtoundColor,this.leftImageSize,this.rightImageSize,this.barTitleColor,this.bodyMargintop,this.barHeight,this.trans,this.title,this.titleSize,this.centerImage,this.leftImage,this.leftTitle,this.rightImage,this.rightTitle,this.leftCallback,this.rightCallback});

  @override
  State<StatefulWidget> createState() {
    return BaseScaffoidState();
  }


}

class BaseScaffoidState extends State<BaseScaffold> {

  @override
  void dispose() {
    //关闭无响应的loading
    EventBusUtil.getInstance().fire(Todismiss());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        /* 背景图/色 */
        Container(
            constraints: BoxConstraints(
                minHeight: screenHeight
            ),
            child: widget.backgroundImage==null?Container(
              constraints: BoxConstraints(
                  minHeight: screenHeight
              ),width: screenWidth,
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft,end: Alignment.bottomRight,colors: [widget.backgtoundColor??CXColors.BackColor_Screen,widget.backgtoundColor??CXColors.BackColor_Screen])
              ),)
                : Image.asset(widget.backgroundImage,fit: BoxFit.fill,height: screenHeight,width: screenWidth,)
        ),
        /* body */
        Container(
          margin: EdgeInsets.only(top: (widget.trans!=null&&widget.trans?0.0:widget.barHeight??((75.w+75.h)/2+statusBarHeight)) /*+ (widget.bodyMargintop??0.0)*/),
          child: widget.body,
        ),
        /* TabBar */
        Container(
          padding: EdgeInsets.only(top: statusBarHeight),
          color: widget.barBackgtoundColor??CXColors.maintab,
          height: widget.barHeight??((75.w+75.h)/2+statusBarHeight),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              widget.leftImage==null?Container():Align(
                alignment:Alignment.centerLeft,
                child: GestureDetector(
                  child: Container(
                      color: CXColors.trans,
                      padding: EdgeInsets.fromLTRB(0, 10, 20, 10),
                      margin: EdgeInsets.only(left: 15),
                      child: Image.asset(widget.leftImage,height: widget.leftImageSize??26,width:widget.leftImageSize??26,)
                  ),
                  onTap: widget.leftCallback,
                ),
              ),
              widget.leftTitle==null?Container():Align(
                alignment:Alignment.centerLeft,
                child: GestureDetector(
                  child: Container(
                      margin: EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Text(widget.leftTitle,style:TextStyle(color: CXColors.maintab_text_un,fontSize: 14))
                  ),
                  onTap: widget.leftCallback,
                ),
              ),
              Align(
                alignment:Alignment.center,
                child: Container(
                  margin: EdgeInsets.fromLTRB(screenWidth/6, 0, screenWidth/6, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      widget.centerImage==null?Container():Container(
                          margin: EdgeInsets.only(top: 2),
                          child: Image.asset(widget.centerImage,height: 20,width:20)
                      ),
                      widget.title==null?Container():Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth/2,
                          ),
                          margin: EdgeInsets.only(left: 5),
                          child: TextSingleSplit(widget.title,8,textStyle: TextStyle(color: widget.barTitleColor??CXColors.lineColor_f8,fontSize: widget.titleSize??20),minLimit: 5,),
                      ),
                    ],
                  ),
                ),
              ),
              widget.rightImage==null?Container():Align(
                alignment:Alignment.centerRight,
                child: GestureDetector(
                  child: Container(
                      color: CXColors.trans,
                      padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                      margin: EdgeInsets.only(right: 15),
                      child: Image.asset(widget.rightImage,height: widget.rightImageSize??26,width:widget.rightImageSize??26,fit: BoxFit.fill,)
                  ),
                  onTap: widget.rightCallback,
                ),
              ),
              widget.rightTitle==null?Container():Align(
                alignment:Alignment.centerRight,
                child: GestureDetector(
                  child: Container(
                      width: screenWidth/4,
                      alignment: Alignment.centerRight,
                      margin: EdgeInsets.fromLTRB(0, 0, widget.rightImage==null?15:35, 0),
                      child: Text(widget.rightTitle,style:TextStyle(color: CXColors.maintab_text_un,fontSize: 14,),maxLines: 1,overflow: TextOverflow.ellipsis,)
                  ),
                  onTap: widget.rightCallback,
                ),
              ),
            ],
          ),
        ),
/*        Offstage(
          offstage: widget.trans!=null&&widget.trans,
          child: Container(
            margin: EdgeInsets.only(top: 50 + statusBarHeight),
            color: CXColors.lineColor_ec,
            height: 0.5,
            width: CustomerModel.screenWidth,
          ),
        ),*/
      ],
    );
  }
}


class BaseLine extends StatelessWidget {
  Color color;
  double height;
  double width;
  EdgeInsets margin;


  BaseLine({this.color, this.height, this.width, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height??1.w,
      width: width??1.sw,
      color: color??CXColors.lineColor_ec,
      margin: margin,
    );
  }
}
