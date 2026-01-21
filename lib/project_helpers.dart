import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api_client.dart';
import 'core/constants/api_constants.dart';

extension NumberExtensions on num {
  Widget get width => SizedBox(width: toDouble());
  
  Widget height(BuildContext context) => SizedBox(height: toDouble());
  
  Widget get space => SizedBox(width: toDouble(), height: toDouble());

  Widget box(Widget child) => SizedBox(width: toDouble(), height: toDouble(), child: child);
  
  BorderRadius get radius => BorderRadius.circular(toDouble());

  RoundedRectangleBorder get roundBorder => RoundedRectangleBorder(borderRadius: radius);

  String get commaFormat => NumberFormat('#,##0.00').format(this);
}

extension WidgetExtensions on Widget {
  Widget paddingAll(BuildContext context, double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  Widget paddingHorizontal(BuildContext context, double value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
        child: this,
      );

  Widget paddingVertical(BuildContext context, double value) => Padding(
        padding: EdgeInsets.symmetric(vertical: value),
        child: this,
      );

  Widget get centerAlign => Center(child: this);

  Widget get topLeft => Align(alignment: Alignment.topLeft, child: this);

  Widget get expanded => Expanded(child: this);

  Widget rounded(BuildContext context, double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  Widget onClick(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: this,
      );

  Widget onLongClick(VoidCallback onLongPress) => GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: this,
      );
}

extension StringExtensions on String {
  String get upper => toUpperCase();
  String get lower => toLowerCase();
  int get parseInt => int.tryParse(this) ?? 0;
  String get firstChar => isNotEmpty ? this[0] : '';
  
  String get fixImageUrl {
    if (isEmpty) return this;
    const String base = ApiConstants.baseUrl;
    
    if (startsWith('http')) {
      if (contains('localhost')) {
        return replaceAll(RegExp(r'http://localhost:\d+'), base);
      }
      return this;
    }
    
    // Handle relative paths
    final cleanPath = startsWith('/') ? this : '/$this';
    return '$base$cleanPath';
  }
}

extension ContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1200;
  String get screenType {
    if (isMobile) return 'Mobile';
    if (isTablet) return 'Tablet';
    return 'Desktop';
  }
}
