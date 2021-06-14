part of 'features_bloc.dart';

@immutable
class FeaturesEvent {}

class OnListsUpdate extends FeaturesEvent {
  final List<PsFeatureSuper> psFeatureSuperList;
  final List<PsFeature> psFeatureList;
  final List<PsFeatureValue> psFeatureValueList;

  OnListsUpdate({
    @required this.psFeatureSuperList,
    @required this.psFeatureList,
    @required this.psFeatureValueList,
  });
}

// Update

class OnFeaturesListUpdate extends FeaturesEvent {
  final PsFeature psFeatureUpdated;

  OnFeaturesListUpdate({@required this.psFeatureUpdated});
}

class OnFeatureSuperUpdate extends FeaturesEvent {
  final PsFeatureSuper psFeatureSuperUpdated;

  OnFeatureSuperUpdate({@required this.psFeatureSuperUpdated});
}

class OnFeatureValueUpdate extends FeaturesEvent {
  final PsFeatureSuper psFeatureValueUpdated;

  OnFeatureValueUpdate({@required this.psFeatureValueUpdated});
}

// Search
class OnFeatureSearch extends FeaturesEvent {
  String textToSearch;

  OnFeatureSearch({@required this.textToSearch});
}

class OnFeatureSuperSearch extends FeaturesEvent {
  String textToSearch;

  OnFeatureSuperSearch({@required this.textToSearch});
}

class OnFeatureValueSearch extends FeaturesEvent {
  String textToSearch;

  OnFeatureValueSearch({@required this.textToSearch});
}

// Delete

class OnFeatureDelete extends FeaturesEvent {
  final PsFeature psFeatureDelete;

  OnFeatureDelete({@required this.psFeatureDelete});
}

class OnFeatureSuperDelete extends FeaturesEvent {
  final PsFeatureSuper psFeatureSuperDelete;

  OnFeatureSuperDelete({@required this.psFeatureSuperDelete});
}

class OnFeatureValueDelete extends FeaturesEvent {
  final PsFeatureSuper psFeatureValueDelete;

  OnFeatureValueDelete({@required this.psFeatureValueDelete});
}

// Add

class OnFeatureAdd extends FeaturesEvent {
  final PsFeature psFeatureAdd;

  OnFeatureAdd({@required this.psFeatureAdd});
}

class OnFeatureSuperAdd extends FeaturesEvent {
  final PsFeatureSuper psFeatureSuperAdd;

  OnFeatureSuperAdd({@required this.psFeatureSuperAdd});
}

class OnFeatureValueAdd extends FeaturesEvent {
  final PsFeatureSuper psFeatureValueAdd;

  OnFeatureValueAdd({@required this.psFeatureValueAdd});
}
