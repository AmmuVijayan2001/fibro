import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'office_adding_bloc_event.dart';
part 'office_adding_bloc_state.dart';

class OfficeAddingBlocBloc extends Bloc<OfficeAddingBlocEvent, OfficeAddingBlocState> {
  OfficeAddingBlocBloc() : super(OfficeAddingBlocInitial()) {
    on<OfficeAddingBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
