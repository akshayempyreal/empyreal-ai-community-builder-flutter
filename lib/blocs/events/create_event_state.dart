import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CreateEventStatus { initial, loading, success, failure }

class CreateEventState extends Equatable {
  final int currentStep;
  final String name;
  final String location;
  final String description;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final String duration;
  final String audienceSize;
  final String planningMode;
  final double? latitude;
  final double? longitude;
  final CreateEventStatus status;
  final String? errorMessage;

  const CreateEventState({
    this.currentStep = 0,
    this.name = '',
    this.location = '',
    this.description = '',
    this.type = '',
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.duration = '',
    this.audienceSize = '',
    this.planningMode = 'automated',
    this.latitude,
    this.longitude,
    this.status = CreateEventStatus.initial,
    this.errorMessage,
  });

  CreateEventState copyWith({
    int? currentStep,
    String? name,
    String? location,
    String? description,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime, // Changed to TimeOfDay?
    TimeOfDay? endTime,   // Changed to TimeOfDay?
    String? duration,
    String? audienceSize,
    String? planningMode,
    double? latitude,
    double? longitude,
    CreateEventStatus? status,
    String? errorMessage,
  }) {
    return CreateEventState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      audienceSize: audienceSize ?? this.audienceSize,
      planningMode: planningMode ?? this.planningMode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentStep, name, location, description, type, 
    startDate, endDate, startTime, endTime, duration, audienceSize, 
    planningMode, latitude, longitude, status, errorMessage
  ];
}
