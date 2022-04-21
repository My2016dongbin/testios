import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'CXColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/*
* 通用Button
*/
class CommonButton extends StatelessWidget{
  String text;
  double width;
  double height;
  double widthPercent;
  EdgeInsets margin;
  EdgeInsets padding;
  double fontSize;
  bool solid;
  Color backgroundColor;
  Color solidColor;
  Color textColor;
  double borderRadius;
  double elevation;
  Function onPressed;
  Alignment textAlign;
  Function onPointerDown;
  Function onPointerUp;
  LinearGradient gradient;
  String image;

  CommonButton({@required this.text, @required this.onPressed, this.width, this.textAlign,  this.height,  this.image,  this.gradient, this.widthPercent,  this.margin,this.onPointerDown,  this.onPointerUp,    this.padding,  this.fontSize,  this.solid, this.backgroundColor, this.solidColor, this.textColor,
    this.borderRadius,this.elevation});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Listener(
      onPointerDown: onPointerDown,
      onPointerUp: onPointerUp,
      child:
      Container(
        height: height??85.w,
        width: width!=null?width:widthPercent!=null?screenWidth*widthPercent:screenWidth,
        margin: margin??EdgeInsets.fromLTRB(15, 0, 15, 0),
        decoration: (solid!=null&&solid)||solidColor!=null?BoxDecoration(
          border: Border.all(color: solidColor??CXColors.gradient_yellow,width: 1),
          borderRadius: BorderRadius.circular(borderRadius??10.w),
        ):null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius??10.w),
          child: Material(elevation: elevation??0.6,
            color: gradient!=null?null: ( backgroundColor??((solid!=null&&solid)||solidColor!=null?CXColors.WhiteColor:CXColors.gradient_yellow) ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius??10.w))),
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                    gradient: gradient
                ),
                  alignment: textAlign??Alignment.center,padding:padding,child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  image==null?SizedBox():Container(
                    margin: EdgeInsets.fromLTRB(0, 5.w, 10.w, 0),
                      child: Image.asset("${image??""}",width: 36.w,height: 36.w,)
                  ),
                  Text(text,style: TextStyle(color: textColor??CXColors.WhiteColor,fontSize: fontSize??16),maxLines: 1,textAlign: TextAlign.center,),
                ],
              )
              ),
              onTap: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}


/*
* 带提示的输入框
* */
typedef CallbackT = Function(String Str);
class CommonTextField extends StatefulWidget {
  int maxLines;
  int minLines;
  int maxLength;
  TextAlign textAlign;
  bool moreLines;
  bool hide;
  double starMarginTop;
  TextInputType keyboardType;
  bool maxLengthEnforced;
  bool enabled;
  bool forceBlur;
  Color cursorColor;
  CallbackT onChanged;
  TextEditingController controller = TextEditingController();
  List<TextInputFormatter> inputFormatters;
  InputDecoration decoration;
  TextStyle style;
  double cursorWidth;
  bool right;

  CommonTextField({this.keyboardType, this.maxLength,this.minLines,this.cursorWidth,this.right,this.textAlign,this.moreLines,this.hide,this.forceBlur,this.starMarginTop, this.maxLengthEnforced,this.maxLines, this.enabled, this.cursorColor, this.onChanged,
    this.controller, this.inputFormatters, this.decoration, this.style});

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

final double forceOpc = 0.4;
class _CommonTextFieldState extends State<CommonTextField> {
  @override
  void initState() {
    super.initState();
    if(mounted && widget.controller!=null && widget.onChanged!=null){
      widget.controller.addListener(() {
        widget.onChanged(widget.controller.text??"");
        setState(() {
        });
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.forceBlur==true?forceOpc:1,
      child: Row(
        crossAxisAlignment: widget.moreLines==true?CrossAxisAlignment.start:CrossAxisAlignment.center,
        children: [
          widget.right==true?SizedBox():Offstage(
            offstage: widget.controller.text.isNotEmpty||widget.hide==true || widget.forceBlur==true,
            child: Container(margin: EdgeInsets.fromLTRB(20.w, widget.starMarginTop??0, 0, 0),child: Text("*",style: TextStyle(color: CXColors.job_red,fontSize: 26.w,height: 1.7),)),
          ),
          Expanded(
            child: TextField(
              textAlign:widget.textAlign??TextAlign.start,
              maxLength:widget.maxLength,
              maxLengthEnforced:widget.maxLengthEnforced??false,
              keyboardType:widget.keyboardType,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              enabled: widget.enabled,
              cursorWidth: widget.cursorWidth??3.w,
              onChanged: (str){
                widget.onChanged(str);
                setState(() {
                });
              },
              cursorColor: widget.cursorColor,
              controller: widget.controller,
              inputFormatters: widget.inputFormatters,
              decoration: widget.decoration,
              style: widget.style,
            ),
          ),
          widget.right==true?Offstage(
            offstage: widget.controller.text.isNotEmpty||widget.hide==true || widget.forceBlur==true,
            child: Container(margin: EdgeInsets.fromLTRB(20.w, widget.starMarginTop??0, 0, 0),child: Text("*",style: TextStyle(color: CXColors.job_red,fontSize: 26.w,height: 1.7),)),
          ):SizedBox(),
        ],
      ),
    );
  }
}

/*
* Text数字分割（单行）
* */
class TextSingleSplit extends StatefulWidget {
  final String title;
  final int split;//大于次位数以后合并为一个Expanded
  final int minLimit;//title最小分割数
  final TextStyle textStyle;

  TextSingleSplit(this.title,this.split,{this.minLimit,this.textStyle});

  @override
  _TextSingleSplitState createState() => _TextSingleSplitState();
}

class _TextSingleSplitState extends State<TextSingleSplit> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: clipTexts(),
    );
  }

  List<Widget> clipTexts() {
    List<Widget> listW = [];
    if(widget.title.length <= (widget.minLimit??10)){
      //小于最小分割起点 不分割
      listW.add(Text("${widget.title}",style: widget.textStyle??childStyle,));
    }else{
      //大于最小分割起点 分割
      for(int i = 0; i < widget.title.length; i++){
        if(i==widget.split-1){
          //最后一段
          listW.add(Expanded(child: Text("${widget.title.substring(i,widget.title.length)}",style: widget.textStyle??childStyle,maxLines: 1,overflow: TextOverflow.ellipsis,)));
          return listW;
        }else{
          listW.add(Text("${widget.title.substring(i,i+1)}",style: widget.textStyle??childStyle,maxLines: 1,));
        }
      }
    }
    return listW;
  }
}

/*
* Text数字分割（多行）
* */
class TextMultiSplit extends StatefulWidget {
  final String title;
  final TextStyle textStyle;

  TextMultiSplit(this.title,{this.textStyle});

  @override
  _TextMultiSplitState createState() => _TextMultiSplitState();
}

class _TextMultiSplitState extends State<TextMultiSplit> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: clipTexts(),
    );
  }

  List<Widget> clipTexts() {
    List<Widget> listW = [];
    //分割
    for(int i = 0; i < widget.title.length; i++){
      listW.add(Text("${widget.title.substring(i,i+1)}",style: widget.textStyle??childStyle,));
    }
    return listW;
  }
}

/*
* 通用Dialog（取消/确认）
* */
showCommonDialog(context,title,leftClick,rightClick,{String leftStr,String rightStr,String hint,bool dismiss}){
  showCupertinoDialog(context: context, barrierDismissible: dismiss??true, builder: (BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          height: hint==null?240.w:270.w,
          margin: EdgeInsets.fromLTRB(0.15.sw, 0, 0.15.sw, 0),
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14.w))),
            color: CXColors.WhiteColor,
            shadowColor: CXColors.lineColor_f8,
            elevation: 5,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment:Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 60.w),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(color: CXColors.WhiteColor,child: Text("$title",style: TextStyle(color: CXColors.titleColor_99,fontSize: 26.sp),maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,)),
                        Offstage(offstage: hint==null,child: SizedBox(height: 20.h,)),
                        Offstage(offstage: hint==null,child: Material(color: CXColors.WhiteColor,child: Text("$hint",style: TextStyle(color: CXColors.titleColor_33,fontSize: 26.sp),maxLines: 1,overflow: TextOverflow.ellipsis,))),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment:Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15.w),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CommonButton(
                            height: 65.w,
                            fontSize: 26.sp,
                            backgroundColor: CXColors.WhiteColor,
                            margin: EdgeInsets.fromLTRB(30.w, 0, 20.w, 0),
                            solid:true,
                            borderRadius: 35.w,
                            solidColor: CXColors.lineColor_ed,
                            textColor: CXColors.titleColor_99,
                            text: leftStr??"取消", onPressed: leftClick,
                          ),
                        ),
                        Expanded(
                          child: CommonButton(
                            height: 65.w,
                            fontSize: 26.sp,
                            backgroundColor: CXColors.blue_button,
                            margin: EdgeInsets.fromLTRB(20.w, 0, 30.w, 0),
                            borderRadius: 35.w,
                            textColor: CXColors.WhiteColor,
                            text: rightStr??"确定", onPressed: rightClick,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }, );
}



final childStyle = TextStyle(color: CXColors.BlackColor,fontSize: 26.sp,height: 1.2);