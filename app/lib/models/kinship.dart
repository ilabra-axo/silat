// Derived kinship result — computed, never persisted.
// Produced by KinshipEngine from any ego-node perspective.

enum KinshipLabel {
  self,
  parent,
  child,
  partner,
  sibling,
  grandparent,
  grandchild,
  greatGrandparent,
  aunt,
  uncle,
  niece,
  nephew,
  firstCousin,
  parentInLaw,
  siblingInLaw,
  stepchild,
  stepparent,
  secondCousin,
  extendedFamily,
  unrelated,
}

extension KinshipLabelDisplay on KinshipLabel {
  // Gender-aware display — call with alter's gender
  String display(String? genderCode) {
    final g = genderCode?.toUpperCase();
    return switch (this) {
      KinshipLabel.self => 'You',
      KinshipLabel.parent => g == 'M' ? 'Father' : g == 'F' ? 'Mother' : 'Parent',
      KinshipLabel.child => g == 'M' ? 'Son' : g == 'F' ? 'Daughter' : 'Child',
      KinshipLabel.partner => 'Partner',
      KinshipLabel.sibling => g == 'M' ? 'Brother' : g == 'F' ? 'Sister' : 'Sibling',
      KinshipLabel.grandparent => g == 'M' ? 'Grandfather' : g == 'F' ? 'Grandmother' : 'Grandparent',
      KinshipLabel.grandchild => g == 'M' ? 'Grandson' : g == 'F' ? 'Granddaughter' : 'Grandchild',
      KinshipLabel.greatGrandparent => g == 'M' ? 'Great-grandfather' : g == 'F' ? 'Great-grandmother' : 'Great-grandparent',
      KinshipLabel.aunt => 'Aunt',
      KinshipLabel.uncle => 'Uncle',
      KinshipLabel.niece => 'Niece',
      KinshipLabel.nephew => 'Nephew',
      KinshipLabel.firstCousin => '1st Cousin',
      KinshipLabel.parentInLaw => g == 'M' ? 'Father-in-law' : g == 'F' ? 'Mother-in-law' : 'Parent-in-law',
      KinshipLabel.siblingInLaw => g == 'M' ? 'Brother-in-law' : g == 'F' ? 'Sister-in-law' : 'Sibling-in-law',
      KinshipLabel.stepchild => g == 'M' ? 'Stepson' : g == 'F' ? 'Stepdaughter' : 'Stepchild',
      KinshipLabel.stepparent => g == 'M' ? 'Stepfather' : g == 'F' ? 'Stepmother' : 'Stepparent',
      KinshipLabel.secondCousin => '2nd Cousin',
      KinshipLabel.extendedFamily => 'Extended Family',
      KinshipLabel.unrelated => 'Unrelated',
    };
  }

  int get degree => switch (this) {
        KinshipLabel.self => 0,
        KinshipLabel.parent => 1,
        KinshipLabel.child => 1,
        KinshipLabel.partner => 1,
        KinshipLabel.sibling => 2,
        KinshipLabel.grandparent => 2,
        KinshipLabel.grandchild => 2,
        KinshipLabel.greatGrandparent => 3,
        KinshipLabel.aunt => 3,
        KinshipLabel.uncle => 3,
        KinshipLabel.niece => 3,
        KinshipLabel.nephew => 3,
        KinshipLabel.firstCousin => 4,
        KinshipLabel.parentInLaw => 2,
        KinshipLabel.siblingInLaw => 2,
        KinshipLabel.stepchild => 2,
        KinshipLabel.stepparent => 2,
        KinshipLabel.secondCousin => 6,
        KinshipLabel.extendedFamily => 99,
        KinshipLabel.unrelated => 999,
      };
}

class KinshipResult {
  const KinshipResult({
    required this.perspectiveId,
    required this.alterId,
    required this.label,
    required this.genderCode,
    required this.degree,
    required this.path,
  });

  final String perspectiveId;
  final String alterId;
  final KinshipLabel label;
  final String? genderCode;
  final int degree;
  final List<String> path; // member id chain

  String get displayLabel => label.display(genderCode);
}
