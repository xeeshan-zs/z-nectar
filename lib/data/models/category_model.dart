import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final Color bgColor;
  final Color borderColor;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bgColor,
    required this.borderColor,
  });
}
