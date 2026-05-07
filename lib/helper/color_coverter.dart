import 'dart:ui';

class ColorConverter{
  static Color stringToColor(String? color){
    int value = 0xFFCB202D;
    if(color != null) {
      value = int.parse(color.replaceAll('#', '0xFF'));
    }
    return Color(value);
  }
}
