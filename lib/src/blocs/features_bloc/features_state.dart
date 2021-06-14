part of 'features_bloc.dart';

@immutable
class FeaturesState extends Equatable {
  final List<PsFeatureSuper> psFeatureSuperList;
  final List<PsFeature> psFeatureList;
  final List<PsFeatureValue> psFeatureValueList;

  const FeaturesState({
    this.psFeatureSuperList,
    this.psFeatureList,
    this.psFeatureValueList,
  });

  FeaturesState copyWith({
    List<PsFeatureSuper> psFeatureSuperList,
    List<PsFeature> psFeatureList,
    List<PsFeatureValue> psFeatureValueList,
  }) =>
      new FeaturesState(
        psFeatureSuperList: psFeatureSuperList ?? this.psFeatureSuperList,
        psFeatureList: psFeatureList ?? this.psFeatureList,
        psFeatureValueList: psFeatureValueList ?? this.psFeatureValueList,
      );

  @override
  List<Object> get props => [];
}
