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
    if (event is OnListsUpdate) {
      // Inicializa los estados
      yield state.copyWith(
          psFeatureList: event.psFeatureList,
          psFeatureSuperList: event.psFeatureSuperList,
          psFeatureValueList: event.psFeatureValueList);
    } else if (event is OnFeatureDelete) {
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
    } else if (event is OnFeatureSearch) {
      yield state.copyWith(
          psFeatureListSearch: _searchFeature(event.textToSearch));
    } else if (event is OnFeatureValueSearch) {
      yield state.copyWith(
          psFeatureValueListSearch: _searchFeatureValue(event.textToSearch));
    }else if (event is OnFeatureValueSearch) {
      yield state.copyWith(
          psFeatureValueListSearch: _searchFeatureValue(event.textToSearch));
    }
  }

  List<PsFeature> _searchFeature(String value) {
    if (value.isNotEmpty) {
      List<PsFeature> list = [];
      for (var feature in state.psFeatureList) {
        if (feature.name.toLowerCase().contains(value.toLowerCase())) {
          list.add(feature);
        }
      }
      return list;
    } else
      return state.psFeatureList;
  }

  List<PsFeatureSuper> _searchFeatureSuper(String value) {
    if (value.isNotEmpty) {
      List<PsFeatureSuper> list = [];
      for (var feature in state.psFeatureSuperList) {
        if (feature.name.toLowerCase().contains(value.toLowerCase())) {
          list.add(feature);
        }
      }
      return list;
    } else
      return state.psFeatureSuperList;
  }

  List<PsFeatureValue> _searchFeatureValue(String value) {
    if (value.isNotEmpty) {
      List<PsFeatureValue> list = [];
      for (var feature in state.psFeatureValueList) {
        if (feature.name.toLowerCase().contains(value.toLowerCase())) {
          list.add(feature);
        }
      }
      return list;
    } else
      return state.psFeatureValueList;
  }
}
