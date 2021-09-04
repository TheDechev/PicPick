import 'dart:async';

import 'package:bloc/bloc.dart';

part 'counter_event.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(
    CounterEvent event,
  ) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.reset:
        print("reset is called");
        yield state - state;
        break;
      default:
        throw Exception("unknown event for CounterBloc: ${event.toString()}");
    }
  }
}
