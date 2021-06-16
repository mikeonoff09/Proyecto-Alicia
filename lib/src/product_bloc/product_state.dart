part of 'product_bloc.dart';

@immutable
class ProductState extends Equatable {
  final List<PsFeatureProduct> psFeatureProductList;

  const ProductState({this.psFeatureProductList});

  ProductState copyWith({
    List<PsFeatureProduct> featureProductlist,
  }) =>
      new ProductState(
        psFeatureProductList: featureProductlist ?? this.psFeatureProductList,
      );

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}
