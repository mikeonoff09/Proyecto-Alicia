import 'dart:async';

import 'package:alicia/src/models/product_details_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'features_event.dart';
part 'features_state.dart';

class FeaturesBloc extends Bloc<FeaturesEvent, FeaturesState> {
  FeaturesBloc() : super(FeaturesState());


  @override
  Stream<FeaturesState> mapEventToState(
    FeaturesEvent event,
  ) async* {
    if (event is OnFeatureDelete) {
      List<PsFeature> newList = state.psFeatureList;
      if (newList.remove(event.psFeatureDelete)) {
        yield state.copyWith(psFeatureList: newList);
      }
      state.psFeatureList.remove(event.psFeatureDelete);
    } else if (event is OnFeatureValueDelete) {
      List<PsFeatureValue> newList = state.psFeatureValueList;
      if (newList.remove(event.psFeatureValueDelete)) {
        yield state.copyWith(psFeatureValueList: newList);
      }
      state.psFeatureList.remove(event.psFeatureValueDelete);
    } else if (event is OnFeatureSuperDelete) {
      List<PsFeatureSuper> newList = state.psFeatureSuperList;
      if (newList.remove(event.psFeatureSuperDelete)) {
        yield state.copyWith(psFeatureSuperList: newList);
      }
    }
  }
}
