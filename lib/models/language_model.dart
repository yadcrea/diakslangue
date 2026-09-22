import 'package:flutter/material.dart';

enum ExerciseType { text, imageChoice, vocabulary }

class ImageChoice {
  final String label;
  final IconData? icon;
  final Color color;
  final String? imagePath;
  final String? audioPath;

  const ImageChoice({
    required this.label,
    this.icon,
    required this.color,
    this.imagePath,
    this.audioPath,
  });
}

class LanguageModel {
  final String id;
  final String name;
  final String flag;
  final String countryCode;
  final String country;
  final Color color;
  final List<CourseModel> courses;

  const LanguageModel({
    required this.id,
    required this.name,
    required this.flag,
    required this.countryCode,
    required this.country,
    required this.color,
    required this.courses,
  });
}

class CourseModel {
  final String id;
  final String title;
  final String description;
  final bool isFree;
  final List<LessonModel> lessons;
  final int level; // 1=Débutant, 2=Intermédiaire, 3=Avancé

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isFree,
    required this.lessons,
    this.level = 1,
  });
}

class LessonModel {
  final String id;
  final String title;
  final List<ExerciseModel> exercises;

  const LessonModel({
    required this.id,
    required this.title,
    required this.exercises,
  });
}

class ExerciseModel {
  final String question;
  final String? subtitle;
  final String? translation;
  final String? translationEn;
  final String correctAnswer;
  final List<String> choices;
  final String? audioFileName;
  final IconData? icon;
  final Color? iconColor;
  final ExerciseType type;
  final List<ImageChoice>? imageChoices;
  final String? imagePath;

  const ExerciseModel({
    required this.question,
    this.subtitle,
    this.translation,
    this.translationEn,
    required this.correctAnswer,
    required this.choices,
    this.audioFileName,
    this.icon,
    this.iconColor,
    this.type = ExerciseType.text,
    this.imageChoices,
    this.imagePath,
  });
}
