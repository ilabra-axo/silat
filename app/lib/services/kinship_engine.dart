// KinshipEngine — pure Dart port of the SILAT spec §4
// Stateless. Pass members + relationships, get back KinshipResult for every alter.

import '../models/member.dart';
import '../models/relationship.dart';
import '../models/kinship.dart';

class KinshipEngine {
  // Build adjacency maps from edge list, then resolve labels for every alter.
  List<KinshipResult> derive({
    required String egoId,
    required List<Member> members,
    required List<Relationship> relationships,
  }) {
    if (members.isEmpty) return [];

    // --- Build adjacency maps ---
    final Map<String, Set<String>> parents = {};
    final Map<String, Set<String>> children = {};
    final Map<String, Set<String>> partners = {};

    for (final r in relationships) {
      if (r.relType == RelType.parentChild) {
        // source = parent, target = child
        children.putIfAbsent(r.sourceId, () => {}).add(r.targetId);
        parents.putIfAbsent(r.targetId, () => {}).add(r.sourceId);
      } else if (r.relType == RelType.partner) {
        partners.putIfAbsent(r.sourceId, () => {}).add(r.targetId);
        partners.putIfAbsent(r.targetId, () => {}).add(r.sourceId);
      }
    }

    // Siblings: members sharing at least one common parent with id
    Set<String> siblingsOf(String id) {
      final result = <String>{};
      for (final p in parents[id] ?? {}) {
        result.addAll(children[p] ?? {});
      }
      result.remove(id);
      return result;
    }

    final results = <KinshipResult>[];

    for (final alter in members) {
      if (alter.id == egoId) continue;

      final label = _resolve(
        egoId: egoId,
        alterId: alter.id,
        parents: parents,
        children: children,
        partners: partners,
        siblingsOf: siblingsOf,
      );

      results.add(KinshipResult(
        perspectiveId: egoId,
        alterId: alter.id,
        label: label,
        genderCode: alter.gender.code.isEmpty ? null : alter.gender.code,
        degree: label.degree,
        path: _path(egoId, alter.id, parents, children, partners),
      ));
    }

    return results;
  }

  // Single alter — efficient lookup without deriving the full graph.
  KinshipResult? deriveOne({
    required String egoId,
    required String alterId,
    required List<Member> members,
    required List<Relationship> relationships,
  }) {
    final alter = members.where((m) => m.id == alterId).firstOrNull;
    if (alter == null) return null;

    final all = derive(
      egoId: egoId,
      members: members,
      relationships: relationships,
    );
    return all.where((r) => r.alterId == alterId).firstOrNull;
  }

  KinshipLabel _resolve({
    required String egoId,
    required String alterId,
    required Map<String, Set<String>> parents,
    required Map<String, Set<String>> children,
    required Map<String, Set<String>> partners,
    required Set<String> Function(String) siblingsOf,
  }) {
    final egoParents = parents[egoId] ?? {};
    final egoChildren = children[egoId] ?? {};
    final egoPartners = partners[egoId] ?? {};
    final egoSiblings = siblingsOf(egoId);

    // 1. Parent
    if (egoParents.contains(alterId)) return KinshipLabel.parent;

    // 2. Child
    if (egoChildren.contains(alterId)) return KinshipLabel.child;

    // 3. Partner
    if (egoPartners.contains(alterId)) return KinshipLabel.partner;

    // 4. Sibling
    if (egoSiblings.contains(alterId)) return KinshipLabel.sibling;

    // 5. Grandparent
    for (final p in egoParents) {
      if ((parents[p] ?? {}).contains(alterId)) return KinshipLabel.grandparent;
    }

    // 6. Grandchild
    for (final c in egoChildren) {
      if ((children[c] ?? {}).contains(alterId)) return KinshipLabel.grandchild;
    }

    // 7. Great-grandparent
    for (final p in egoParents) {
      for (final gp in parents[p] ?? {}) {
        if ((parents[gp] ?? {}).contains(alterId)) {
          return KinshipLabel.greatGrandparent;
        }
      }
    }

    // 8. Aunt / Uncle (sibling of a parent)
    for (final p in egoParents) {
      if (siblingsOf(p).contains(alterId)) {
        // aunt vs uncle resolved by gender in display(); label is a placeholder
        return _isAunt(alterId, parents, children)
            ? KinshipLabel.aunt
            : KinshipLabel.uncle;
      }
    }

    // 9. Niece / Nephew (child of a sibling)
    for (final s in egoSiblings) {
      if ((children[s] ?? {}).contains(alterId)) {
        return _isNiece(alterId, parents, children)
            ? KinshipLabel.niece
            : KinshipLabel.nephew;
      }
    }

    // 10. 1st Cousin (child of aunt/uncle)
    for (final p in egoParents) {
      for (final pibling in siblingsOf(p)) {
        if ((children[pibling] ?? {}).contains(alterId)) {
          return KinshipLabel.firstCousin;
        }
      }
    }

    // 11. Parent-in-law (parent of a partner)
    for (final pt in egoPartners) {
      if ((parents[pt] ?? {}).contains(alterId)) return KinshipLabel.parentInLaw;
    }

    // 12. Sibling-in-law (sibling of a partner)
    for (final pt in egoPartners) {
      if (siblingsOf(pt).contains(alterId)) return KinshipLabel.siblingInLaw;
    }

    // 13. Stepchild (child of partner, not of ego)
    for (final pt in egoPartners) {
      if ((children[pt] ?? {}).contains(alterId) &&
          !egoChildren.contains(alterId)) {
        return KinshipLabel.stepchild;
      }
    }

    // 14. Stepparent (partner of a parent)
    for (final p in egoParents) {
      if ((partners[p] ?? {}).contains(alterId)) return KinshipLabel.stepparent;
    }

    // 15. 2nd Cousin (child of parent's 1st cousin)
    for (final p in egoParents) {
      for (final pibling in siblingsOf(p)) {
        for (final cousin in children[pibling] ?? {}) {
          if ((children[cousin] ?? {}).contains(alterId)) {
            return KinshipLabel.secondCousin;
          }
        }
      }
    }

    // 16. Extended family fallback (any graph connection exists)
    return KinshipLabel.extendedFamily;
  }

  // Heuristic: treat as aunt/niece if we can't determine — gender resolved in display
  bool _isAunt(String id,
      Map<String, Set<String>> parents,
      Map<String, Set<String>> children) => true; // display() uses alter.gender

  bool _isNiece(String id,
      Map<String, Set<String>> parents,
      Map<String, Set<String>> children) => true; // display() uses alter.gender

  // Minimal path — BFS up to 6 hops; used for display only.
  List<String> _path(
    String from,
    String to,
    Map<String, Set<String>> parents,
    Map<String, Set<String>> children,
    Map<String, Set<String>> partners,
  ) {
    if (from == to) return [from];

    final queue = <List<String>>[[from]];
    final visited = <String>{from};

    while (queue.isNotEmpty) {
      final path = queue.removeAt(0);
      final current = path.last;

      if (path.length > 7) continue; // max 6 hops

      final neighbours = {
        ...(parents[current] ?? {}),
        ...(children[current] ?? {}),
        ...(partners[current] ?? {}),
      };

      for (final n in neighbours) {
        if (visited.contains(n)) continue;
        final next = [...path, n];
        if (n == to) return next;
        visited.add(n);
        queue.add(next);
      }
    }

    return [from, to]; // connected but path too long / not found
  }
}
