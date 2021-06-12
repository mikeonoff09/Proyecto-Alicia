import 'dart:async';

// import 'package:alicia/src/models/caracteristicas_data.dart';
import 'package:alicia/src/models/product_details_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial());

  @override
  Stream<ProductState> mapEventToState(
    ProductEvent event,
  ) async* {
    if (event is OnFeatureProductListChanged) {
      yield state.copyWith(featureProductlist: event.featuresProduct);
    }
    if (event is OnDeleteFeature) {
      List<PsFeatureProduct> newFeatureList =
          _deleteFeature(event.idFeatureToDelete);
      yield state.copyWith(featureProductlist: newFeatureList);
    }
  }

  List<PsFeatureProduct> _deleteFeature(int idFeatureToDelete) {
    List<PsFeatureProduct> newFeatureList = [];
    for (var item in this.state.psFeatureProductList) {
      if (item.idfeaturevalue != idFeatureToDelete) {
        newFeatureList.add(item);
      }
    }
    return newFeatureList;
  }
}
