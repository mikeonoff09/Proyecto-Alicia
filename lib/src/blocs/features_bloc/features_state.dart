part of 'features_bloc.dart';

@immutable
class FeaturesState extends Equatable {
  final List<PsFeatureSuper> psFeatureSuperList;
  final List<PsFeature> psFeatureList;
  final List<PsFeatureValue> psFeatureValueList;
  final List<PsFeatureSuper> psFeatureSuperListSearch;
  final List<PsFeature> psFeatureListSearch;
  final List<PsFeatureValue> psFeatureValueListSearch;

  const FeaturesState({
    this.psFeatureSuperList,
    this.psFeatureList,
    this.psFeatureValueList,
    this.psFeatureSuperListSearch,
    this.psFeatureListSearch,
    this.psFeatureValueListSearch,
  });

  FeaturesState copyWith({
    List<PsFeatureSuper> psFeatureSuperList,
    List<PsFeature> psFeatureList,
    List<PsFeatureValue> psFeatureValueList,
    List<PsFeatureSuper> psFeatureSuperListSearch,
    List<PsFeature> psFeatureListSearch,
    List<PsFeatureValue> psFeatureValueListSearch,
  }) =>
      new FeaturesState(
        psFeatureSuperList: psFeatureSuperList ?? this.psFeatureSuperList,
        psFeatureList: psFeatureList ?? this.psFeatureList,
        psFeatureValueList: psFeatureValueList ?? this.psFeatureValueList,
        psFeatureSuperListSearch: psFeatureSuperList ?? this.psFeatureSuperList,
        psFeatureListSearch: psFeatureList ?? this.psFeatureList,
        psFeatureValueListSearch: psFeatureValueList ?? this.psFeatureValueList,
      );

  @override
  List<Object> get props => [];
}
