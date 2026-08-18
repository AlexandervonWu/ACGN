package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Immutable complete state image captured at one successful transition boundary. */
public final class CertificateTraceSnapshot {
    private final long revision;
    private final GraphStatus status;
    private final Map<EClassId, TypedEClassRecord> classes;
    private final Map<EClassId, ParentAssignment> parents;
    private final Map<CanonicalShape, EClassId> hashCons;
    private final Map<ParentRecordKey, TypedEqualityCertificate> shapeCertificates;
    private final Map<EClassId, Set<ParentRecordKey>> parentUses;
    private final Set<ParentRecordKey> dirtyParents;
    private final Map<EClassId, List<InterfaceRestrictionCertificate>> restrictions;
    private final Map<EClassId, CertifiedInsertionResult> insertions;
    private final StructuralKey stateKey;

    CertificateTraceSnapshot(
            long revision,
            GraphStatus status,
            Map<EClassId, TypedEClassRecord> classes,
            Map<EClassId, ParentAssignment> parents,
            Map<CanonicalShape, EClassId> hashCons,
            Map<ParentRecordKey, TypedEqualityCertificate> shapeCertificates,
            Map<EClassId, ? extends Set<ParentRecordKey>> parentUses,
            Set<ParentRecordKey> dirtyParents,
            Map<EClassId, ? extends List<InterfaceRestrictionCertificate>> restrictions,
            Map<EClassId, CertifiedInsertionResult> insertions,
            StructuralKey stateKey) {
        this.revision = revision;
        this.status = status;
        this.classes = Collections.unmodifiableMap(new LinkedHashMap<>(classes));
        this.parents = Collections.unmodifiableMap(new LinkedHashMap<>(parents));
        this.hashCons = Collections.unmodifiableMap(new LinkedHashMap<>(hashCons));
        this.shapeCertificates = Collections.unmodifiableMap(
                new LinkedHashMap<>(shapeCertificates));
        Map<EClassId, Set<ParentRecordKey>> useCopies = new LinkedHashMap<>();
        for (Map.Entry<EClassId, ? extends Set<ParentRecordKey>> entry
                : parentUses.entrySet()) {
            useCopies.put(entry.getKey(), Collections.unmodifiableSet(
                    new LinkedHashSet<>(entry.getValue())));
        }
        this.parentUses = Collections.unmodifiableMap(useCopies);
        this.dirtyParents = Collections.unmodifiableSet(
                new LinkedHashSet<>(dirtyParents));
        Map<EClassId, List<InterfaceRestrictionCertificate>> restrictionCopies =
                new LinkedHashMap<>();
        for (Map.Entry<EClassId, ? extends List<InterfaceRestrictionCertificate>> entry
                : restrictions.entrySet()) {
            restrictionCopies.put(entry.getKey(), Collections.unmodifiableList(
                    new ArrayList<>(entry.getValue())));
        }
        this.restrictions = Collections.unmodifiableMap(restrictionCopies);
        this.insertions = Collections.unmodifiableMap(new LinkedHashMap<>(insertions));
        this.stateKey = stateKey;
    }

    public long revision() {
        return revision;
    }

    public GraphStatus status() {
        return status;
    }

    public Map<EClassId, TypedEClassRecord> classes() {
        return classes;
    }

    public Map<EClassId, ParentAssignment> parents() {
        return parents;
    }

    public Map<CanonicalShape, EClassId> hashCons() {
        return hashCons;
    }

    public Map<ParentRecordKey, TypedEqualityCertificate> shapeCertificates() {
        return shapeCertificates;
    }

    public Map<EClassId, Set<ParentRecordKey>> parentUses() {
        return parentUses;
    }

    public Set<ParentRecordKey> dirtyParents() {
        return dirtyParents;
    }

    public Map<EClassId, List<InterfaceRestrictionCertificate>> restrictions() {
        return restrictions;
    }

    public Map<EClassId, CertifiedInsertionResult> insertions() {
        return insertions;
    }

    public StructuralKey stateKey() {
        return stateKey;
    }
}
