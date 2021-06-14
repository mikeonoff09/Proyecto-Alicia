part of 'product_bloc.dart';

@immutable
class ProductEvent {}

class OnFeatureProductListChanged extends ProductEvent {
  final List<PsFeatureProduct> featuresProduct;

  OnFeatureProductListChanged({@required this.featuresProduct});
}

class OnDeleteFeature extends ProductEvent {
  final int idFeatureToDelete;

  OnDeleteFeature({@required this.idFeatureToDelete});
}
class OnAddFeature extends ProductEvent {
  final int idFeatureValueToAdd;

  OnAddFeature({@required this.idFeatureValueToAdd});
}
