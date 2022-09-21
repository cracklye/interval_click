import 'package:flutter_bloc/flutter_bloc.dart';

class IntervalBloc extends Bloc<IntervalEvent, IntervalState> {
  IntervalBloc() : super(IntervalStateLoading()) {
    on<IntervalEventStart>(_onIntervalEventStart);
  }
  Future<void> _onIntervalEventStart(
      IntervalEventStart event, Emitter<IntervalState> emit) async {}



      
}

abstract class IntervalEvent {}

abstract class IntervalState {}

class IntervalEventInit extends IntervalEvent {}

class IntervalEventStart extends IntervalEvent {}

class IntervalEventStop extends IntervalEvent {}

class IntervalEventPause extends IntervalEvent {}

class IntervalEventSettings extends IntervalEvent {}

class IntervalStateLoaded extends IntervalState {}

class IntervalStateLoading extends IntervalState {}

class IntervalStateFirstTime extends IntervalState {}
