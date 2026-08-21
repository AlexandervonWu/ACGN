package is.fivefivefive.CanDis;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InvalidObjectException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicReference;

import edu.mit.csail.sdg.parser.CompModule;
import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.ast.Type;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.CanonicalDistance;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.QuantiVar;
import is.fivefivefive.CanDis.metric.QuotientRepairDistance;
import is.fivefivefive.CanDis.metric.RepairProjection;
import is.fivefivefive.CanDis.metric.RepairView;
import is.fivefivefive.CanDis.theory.ContainerLawCertificate;
import is.fivefivefive.CanDis.theory.AlloyTypeBridge;
import is.fivefivefive.CanDis.theory.ContainerConstructionCertificate;
import is.fivefivefive.CanDis.theory.CertifiedSemanticArtifact;
import is.fivefivefive.CanDis.theory.DependentChainCertificate;
import is.fivefivefive.CanDis.theory.DependentChainKind;
import is.fivefivefive.CanDis.theory.FlatConstructionCertificate;
import is.fivefivefive.CanDis.theory.GraphType;
import is.fivefivefive.CanDis.theory.SemanticProfile;
import is.fivefivefive.CanDis.theory.SeqPort;
import is.fivefivefive.CanDis.theory.TheoryAlloyAdapter;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Fast Alloy-to-exact-engine Phase I conformance checks. */
public final class CanonicalAlloyPipelineTest {
    private static int checks;

    private CanonicalAlloyPipelineTest() {
    }

    public static void main(String[] args) throws Exception {
        Path directory = Files.createTempDirectory("candis-phase-i-");
        Path modelPath = directory.resolve("phase_i.als");
        try {
            Files.writeString(modelPath, source(), StandardCharsets.UTF_8);
            CompModule module = AlloyUtil.compileAlloyModule(modelPath.toString());
            check(module != null, "self-contained Alloy fixture must parse");
            checkEmptyRelationArity(module);
            ModelUnit model = new ModelUnit(null, module);
            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);

            CanonicalAlloyPipeline.Prepared alphaLeft = prepare(visitor, "alphaLeft");
            CanonicalAlloyPipeline.Prepared alphaRight = prepare(visitor, "alphaRight");
            CanonicalAlloyPipeline.Prepared aciLeft = prepare(visitor, "aciLeft");
            CanonicalAlloyPipeline.Prepared aciRight = prepare(visitor, "aciRight");
            CanonicalAlloyPipeline.Prepared andDuplicate =
                    prepare(visitor, "andDuplicate");
            CanonicalAlloyPipeline.Prepared andBare = prepare(visitor, "andBare");
            CanonicalAlloyPipeline.Prepared orDuplicate =
                    prepare(visitor, "orDuplicate");
            CanonicalAlloyPipeline.Prepared orBare = prepare(visitor, "orBare");
            CanonicalAlloyPipeline.Prepared unionDuplicate =
                    prepare(visitor, "unionDuplicate");
            CanonicalAlloyPipeline.Prepared unionBare = prepare(visitor, "unionBare");
            CanonicalAlloyPipeline.Prepared intersectDuplicate =
                    prepare(visitor, "intersectDuplicate");
            CanonicalAlloyPipeline.Prepared intersectBare =
                    prepare(visitor, "intersectBare");
            CanonicalAlloyPipeline.Prepared positive = prepare(visitor, "positive");
            CanonicalAlloyPipeline.Prepared negative = prepare(visitor, "negative");
            CanonicalAlloyPipeline.Prepared shadowLeft = prepare(visitor, "shadowLeft");
            CanonicalAlloyPipeline.Prepared shadowRight = prepare(visitor, "shadowRight");
            CanonicalAlloyPipeline.Prepared disjoint = prepare(visitor, "disjointPred");
            CanonicalAlloyPipeline.Prepared nondisjoint = prepare(visitor, "nondisjoint");
            CanonicalAlloyPipeline.Prepared temporalLeft = prepare(visitor, "temporalLeft");
            CanonicalAlloyPipeline.Prepared temporalRight = prepare(visitor, "temporalRight");
            CanonicalAlloyPipeline.Prepared mixedCarrierLeft = prepare(visitor, "mixedCarrierLeft");
            CanonicalAlloyPipeline.Prepared mixedCarrierRight = prepare(visitor, "mixedCarrierRight");
            CanonicalAlloyPipeline.Prepared heterogeneousOrderLeft =
                    prepare(visitor, "heterogeneousOrderLeft");
            CanonicalAlloyPipeline.Prepared heterogeneousOrderRight =
                    prepare(visitor, "heterogeneousOrderRight");
            CanonicalAlloyPipeline.Prepared domainAciLeft = prepare(visitor, "domainAciLeft");
            CanonicalAlloyPipeline.Prepared domainAciRight = prepare(visitor, "domainAciRight");
            CanonicalAlloyPipeline.Prepared nestedUnionLeft =
                    prepare(visitor, "nestedUnionLeft");
            CanonicalAlloyPipeline.Prepared nestedUnionRight =
                    prepare(visitor, "nestedUnionRight");
            CanonicalAlloyPipeline.Prepared equalityOrderLeft =
                    prepare(visitor, "equalityOrderLeft");
            CanonicalAlloyPipeline.Prepared equalityOrderRight =
                    prepare(visitor, "equalityOrderRight");
            CanonicalAlloyPipeline.Prepared duplicateDisjoint =
                    prepare(visitor, "duplicateDisjoint");
            CanonicalAlloyPipeline.Prepared heterogeneousDisjoint =
                    prepare(visitor, "heterogeneousDisjoint");
            CanonicalAlloyPipeline.Prepared binaryArrowType =
                    prepare(visitor, "binaryArrowType");
            CanonicalAlloyPipeline.Prepared reversedArrowType =
                    prepare(visitor, "reversedArrowType");
            CanonicalAlloyPipeline.Prepared binaryJoinType =
                    prepare(visitor, "binaryJoinType");
            CanonicalAlloyPipeline.Prepared arrowAssocLeft =
                    prepare(visitor, "arrowAssocLeft");
            CanonicalAlloyPipeline.Prepared arrowAssocRight =
                    prepare(visitor, "arrowAssocRight");
            CanonicalAlloyPipeline.Prepared joinAssocLeft =
                    prepare(visitor, "joinAssocLeft");
            CanonicalAlloyPipeline.Prepared joinAssocRight =
                    prepare(visitor, "joinAssocRight");
            CanonicalAlloyPipeline.Prepared localGroupingLeft =
                    prepare(visitor, "localGroupingLeft");
            CanonicalAlloyPipeline.Prepared localGroupingRight =
                    prepare(visitor, "localGroupingRight");
            CanonicalAlloyPipeline.Prepared alphaNearLeft = prepare(visitor, "alphaNearLeft");
            CanonicalAlloyPipeline.Prepared alphaNearRight = prepare(visitor, "alphaNearRight");
            CanonicalAlloyPipeline.Prepared aciNearLeft = prepare(visitor, "aciNearLeft");
            CanonicalAlloyPipeline.Prepared aciNearRight = prepare(visitor, "aciNearRight");
            CanonicalAlloyPipeline.Prepared binderAll = prepare(visitor, "binderAll");
            CanonicalAlloyPipeline.Prepared binderSome = prepare(visitor, "binderSome");
            CanonicalAlloyPipeline.Prepared nestedSubtypeLeft =
                    prepare(visitor, "nestedSubtypeLeft");
            CanonicalAlloyPipeline.Prepared nestedSubtypeRight =
                    prepare(visitor, "nestedSubtypeRight");
            CanonicalAlloyPipeline.Prepared redundantDomainGuardLeft =
                    prepare(visitor, "redundantDomainGuardLeft");
            CanonicalAlloyPipeline.Prepared redundantDomainGuardRight =
                    prepare(visitor, "redundantDomainGuardRight");
            CanonicalAlloyPipeline.Prepared witnessedCarrierLeft =
                    prepare(visitor, "witnessedCarrierLeft");
            CanonicalAlloyPipeline.Prepared witnessedCarrierRight =
                    prepare(visitor, "witnessedCarrierRight");
            CanonicalAlloyPipeline.Prepared commutativeBinderLeft =
                    prepare(visitor, "commutativeBinderLeft");
            CanonicalAlloyPipeline.Prepared commutativeBinderRight =
                    prepare(visitor, "commutativeBinderRight");
            CanonicalAlloyPipeline.Prepared localComprehensionLeft =
                    prepare(visitor, "localComprehensionLeft");
            CanonicalAlloyPipeline.Prepared localComprehensionRight =
                    prepare(visitor, "localComprehensionRight");
            CanonicalAlloyPipeline.Prepared localPermutationLeft =
                    prepare(visitor, "localPermutationLeft");
            CanonicalAlloyPipeline.Prepared localPermutationRight =
                    prepare(visitor, "localPermutationRight");
            CanonicalAlloyPipeline.Prepared namedRefFirst =
                    prepare(visitor, "namedRefFirst");
            CanonicalAlloyPipeline.Prepared namedRefLast =
                    prepare(visitor, "namedRefLast");
            CanonicalAlloyPipeline.Prepared temporalBinderTarget =
                    prepare(visitor, "temporalBinderTarget");
            CanonicalAlloyPipeline.Prepared temporalBinderWrongTarget =
                    prepare(visitor, "temporalBinderWrongTarget");
            CanonicalAlloyPipeline.Prepared temporalBinderRenamed =
                    prepare(visitor, "temporalBinderRenamed");
            CanonicalAlloyPipeline.Prepared parameterJoinLeft =
                    prepare(visitor, "parameterJoinLeft");
            CanonicalAlloyPipeline.Prepared parameterJoinRight =
                    prepare(visitor, "parameterJoinRight");
            CanonicalAlloyPipeline.Prepared parameterTypeS =
                    prepare(visitor, "parameterTypeS");
            CanonicalAlloyPipeline.Prepared parameterTypeT =
                    prepare(visitor, "parameterTypeT");
            CanonicalAlloyPipeline.Prepared parameterTypeTNo =
                    prepare(visitor, "parameterTypeTNo");

            SemanticProfile modularProfile = SemanticProfile.alloyModular();
            CanonicalAlloyPipeline.Prepared modularAlpha =
                    prepare(visitor, "alphaLeft", modularProfile);
            check(modularAlpha.semanticArtifact().semanticProfile().equals(modularProfile),
                    "Explicit production profile reaches the certified artifact");
            modularAlpha.semanticArtifact().containerLaws().forEach((operator, declarations) ->
                    declarations.forEach(declaration ->
                            declaration.certificates().values().forEach(certificate -> {
                                check(certificate.authority()
                                                == ContainerLawCertificate.Authority
                                                        .ALLOY_PROFILE_THEORY,
                                        "Production artifacts reject fixture law authority");
                                check(certificate.semanticProfile().equals(modularProfile),
                                        "Every production law is indexed by the selected profile");
                                check(certificate.operatorIdentity().equals(operator),
                                        "Every production law is indexed by its exact operator");
                            })));

            CanonicalAlloyPipeline.Prepared compactPositive =
                    positive.compactForComparison();
            CanonicalAlloyPipeline.Prepared compactNegative =
                    negative.compactForComparison();
            check(positive.retainsSemanticArtifact(),
                    "ordinary preparation must retain its certified construction artifact");
            check(!compactPositive.retainsSemanticArtifact(),
                    "comparison compaction must release the proof-heavy construction artifact");
            check(compactPositive.digest().equals(positive.digest()),
                    "comparison compaction must preserve the canonical digest");
            check(compactPositive.repairObservationSize() == positive.repairObservationSize(),
                    "comparison compaction must preserve the repair observation size");
            check(compactPositive.semanticProfile().equals(positive.semanticProfile()),
                    "comparison compaction must preserve the semantic profile");
            check(CanonicalAlloyPipeline.distance(compactPositive, compactNegative)
                            == CanonicalAlloyPipeline.distance(positive, negative),
                    "comparison compaction must preserve repair distance");
            CanonicalAlloyPipeline.Prepared compactModularAlpha =
                    modularAlpha.compactForComparison();
            expectThrows(IllegalArgumentException.class, () ->
                    CanonicalAlloyPipeline.distance(alphaLeft, modularAlpha));
            expectThrows(IllegalArgumentException.class, () ->
                    CanonicalAlloyPipeline.distance(
                            alphaLeft.compactForComparison(), compactModularAlpha));
            expectThrows(IllegalArgumentException.class, () ->
                    CanonicalAlloyPipeline.canonicalRepresentativeTreeDistance(
                            alphaLeft, modularAlpha));
            expectThrows(IllegalArgumentException.class, () ->
                    alphaLeft.equivalentTo(modularAlpha));
            boolean compactArtifactRejected = false;
            try {
                compactPositive.semanticArtifact();
            } catch (IllegalStateException expected) {
                compactArtifactRejected = true;
            }
            check(compactArtifactRejected,
                    "compact comparison values must fail closed for certificate replay");

            check(alphaLeft.equivalentTo(alphaRight),
                    "same-descriptor binder permutation must be alpha-equivalent");
            check(CanonicalAlloyPipeline.distance(alphaLeft, alphaRight) == 0,
                    "alpha-equivalent binders must have exact distance zero");
            check(aciLeft.equivalentTo(aciRight),
                    "ACI boolean operands must share the exact canonical key");
            check(CanonicalAlloyPipeline.distance(aciLeft, aciRight) == 0,
                    "ACI-equivalent matrices must have exact distance zero");
            List<CanonicalAlloyPipeline.Prepared> duplicateAci = Arrays.asList(
                    andDuplicate, orDuplicate, unionDuplicate, intersectDuplicate);
            List<CanonicalAlloyPipeline.Prepared> bareAci = Arrays.asList(
                    andBare, orBare, unionBare, intersectBare);
            for (int index = 0; index < duplicateAci.size(); index++) {
                CanonicalAlloyPipeline.Prepared duplicate = duplicateAci.get(index);
                CanonicalAlloyPipeline.Prepared bare = bareAci.get(index);
                check(duplicate.equivalentTo(bare)
                                && CanonicalAlloyPipeline.distance(duplicate, bare) == 0,
                        "ACI duplicate source must smart-construct its bare operand");
                check(duplicate.semanticArtifact().flatConstructions().stream()
                                .anyMatch(FlatConstructionCertificate::collapsedToSingleton),
                        "ACI singleton collapse must retain exact idempotency evidence");
            }
            List<FlatConstructionCertificate> missingSingleton = new ArrayList<>(
                    andDuplicate.semanticArtifact().flatConstructions());
            missingSingleton.removeIf(
                    certificate -> !certificate.collapsedToSingleton());
            check(!missingSingleton.isEmpty(),
                    "duplicate AND must retain a singleton source occurrence");
            missingSingleton.remove(0);
            expectThrows(IllegalArgumentException.class, () ->
                    copyWithFlatConstructions(
                            andDuplicate.semanticArtifact(), missingSingleton));
            List<FlatConstructionCertificate> crossArtifactSingleton = new ArrayList<>(
                    andDuplicate.semanticArtifact().flatConstructions());
            FlatConstructionCertificate unrelatedOrSingleton =
                    orDuplicate.semanticArtifact().flatConstructions().stream()
                            .filter(FlatConstructionCertificate::collapsedToSingleton)
                            .findFirst()
                            .orElseThrow(() -> new AssertionError(
                                    "duplicate OR must retain singleton evidence"));
            crossArtifactSingleton.add(unrelatedOrSingleton);
            expectThrows(IllegalArgumentException.class, () ->
                    copyWithFlatConstructions(
                            andDuplicate.semanticArtifact(), crossArtifactSingleton));
            List<FlatConstructionCertificate> duplicatedSingleton = new ArrayList<>(
                    andDuplicate.semanticArtifact().flatConstructions());
            duplicatedSingleton.add(duplicatedSingleton.stream()
                    .filter(FlatConstructionCertificate::collapsedToSingleton)
                    .findFirst()
                    .orElseThrow(() -> new AssertionError(
                            "duplicate AND must retain singleton evidence")));
            expectThrows(IllegalArgumentException.class, () ->
                    copyWithFlatConstructions(
                            andDuplicate.semanticArtifact(), duplicatedSingleton));
            check(CanonicalAlloyPipeline.distance(positive, negative) > 0,
                    "semantically opposed atoms must remain distinguishable");
            check(shadowLeft.equivalentTo(shadowRight),
                    "shadowed binders must remain alpha-equivalent without alias capture");
            check(CanonicalAlloyPipeline.distance(disjoint, nondisjoint) > 0,
                    "disjointness classes must remain part of the binder descriptor");
            check(CanonicalAlloyPipeline.distance(temporalLeft, temporalRight) > 0,
                    "different temporal-phase matrices must remain distinguishable");
            check(mixedCarrierLeft.equivalentTo(mixedCarrierRight),
                    "alpha-equivalence must preserve distinct primitive carrier blocks");
            check(heterogeneousOrderLeft.equivalentTo(heterogeneousOrderRight),
                    "independent heterogeneous binder order must not affect semantic equality");
            check(CanonicalAlloyPipeline.distance(
                            heterogeneousOrderLeft, heterogeneousOrderRight) == 0,
                    "independent heterogeneous binder reordering must retain distance zero");
            check(domainAciLeft.equivalentTo(domainAciRight),
                    "ACI-equivalent guarded binder domains must have certified equality: "
                            + domainAciLeft.digest() + " != " + domainAciRight.digest());
            check(CanonicalAlloyPipeline.distance(domainAciLeft, domainAciRight) == 0,
                    "ACI-equivalent guarded binder domains must retain distance zero");
            check(localGroupingLeft.equivalentTo(localGroupingRight),
                    "equivalent local declaration groupings must have certified equality");
            QuotientRepairDistance.Result localGroupingRepair =
                    QuotientRepairDistance.evaluate(
                            localGroupingLeft.repairView(), localGroupingRight.repairView());
            int localGroupingLegacy = legacyDistance(
                    visitor, "localGroupingLeft", "localGroupingRight");
            check(localGroupingLegacy > 0,
                    "the local-grouping fixture must expose the documented Fast Rewrite ambiguity");
            check(localGroupingRepair.distance() == 0,
                    "equivalent local declaration grouping must lie in the repair zero kernel");
            check(CanonicalAlloyPipeline.distance(alphaNearLeft, alphaNearRight) == 1,
                    "pairwise binder-orbit alignment must retain one-edit alpha locality");
            check(CanonicalAlloyPipeline.canonicalRepresentativeTreeDistance(
                            alphaNearLeft, alphaNearRight)
                            > CanonicalAlloyPipeline.distance(alphaNearLeft, alphaNearRight),
                    "independent canonical alpha representatives must expose their discontinuity baseline");
            check(CanonicalAlloyPipeline.distance(aciNearLeft, aciNearRight) == 1,
                    "ACI assignment must find the single changed operand");
            check(CanonicalAlloyPipeline.canonicalRepresentativeTreeDistance(
                            aciNearLeft, aciNearRight)
                            > CanonicalAlloyPipeline.distance(aciNearLeft, aciNearRight),
                    "independently sorted ACI representatives must not define repair geometry");
            check(CanonicalAlloyPipeline.distance(binderAll, binderSome) == 1,
                    "one quantifier declaration change must cost one repair");
            QuotientRepairDistance.Result parameterTypeRepair =
                    CanonicalAlloyPipeline.distanceEvaluation(
                            parameterTypeS, parameterTypeT);
            check(parameterTypeRepair.quantifierDistance() == 1
                            && parameterTypeRepair.matrixDistance() == 0
                            && parameterTypeRepair.distance() == 1,
                    "a positional parameter-type edit is explicit and preserves body identity");
            QuotientRepairDistance.Result parameterAndBodyRepair =
                    CanonicalAlloyPipeline.distanceEvaluation(
                            parameterTypeS, parameterTypeTNo);
            check(parameterAndBodyRepair.quantifierDistance() == 1
                            && parameterAndBodyRepair.matrixDistance() == 1
                            && parameterAndBodyRepair.distance() == 2,
                    "a parameter-type edit cannot hide an independent body repair");
            check(nestedSubtypeLeft.equivalentTo(nestedSubtypeRight),
                    "binder permutations must re-normalize ACI operands after acting");
            check(CanonicalAlloyPipeline.distance(
                            nestedSubtypeLeft, nestedSubtypeRight) == 0,
                    "nested and grouped subtype binders must retain distance zero");
            check(redundantDomainGuardLeft.equivalentTo(redundantDomainGuardRight),
                    "ACI projection must preserve certified idempotence of a repeated domain guard");
            check(CanonicalAlloyPipeline.distance(
                            redundantDomainGuardLeft, redundantDomainGuardRight) == 0,
                    "a repeated domain guard under implication rewriting must remain in the zero kernel");
            check(nestedUnionLeft.equivalentTo(nestedUnionRight),
                    "relational union reassociation must remain certified");
            check(nestedUnionLeft.semanticArtifact().flatConstructions().stream()
                            .flatMap(certificate -> certificate.splices().stream())
                            .anyMatch(splice -> splice.outerArity() == 2
                                    && splice.nestedArity() == 2
                                    && (splice.position() == 0 || splice.position() == 1)),
                    "parsed nested union must retain its exact associative splice witness");
            CertifiedSemanticArtifact nestedUnionArtifact =
                    nestedUnionLeft.semanticArtifact();
            List<FlatConstructionCertificate> missingFlat = new ArrayList<>(
                    nestedUnionArtifact.flatConstructions());
            check(!missingFlat.isEmpty(),
                    "nested union fixture must contain concrete flat evidence");
            FlatConstructionCertificate firstFlat = missingFlat.remove(0);
            expectThrows(IllegalArgumentException.class, () ->
                    copyWithFlatConstructions(nestedUnionArtifact, missingFlat));
            List<FlatConstructionCertificate> extraneousFlat = new ArrayList<>(
                    nestedUnionArtifact.flatConstructions());
            extraneousFlat.add(firstFlat);
            expectThrows(IllegalArgumentException.class, () ->
                    copyWithFlatConstructions(nestedUnionArtifact, extraneousFlat));
            check(equalityOrderLeft.equivalentTo(equalityOrderRight),
                    "fixed equality commutativity must remain certified");
            check(equalityOrderLeft.semanticArtifact().containerConstructions().stream()
                            .filter(certificate -> certificate.target().operator().operator()
                                    .equals("ALLOY/EQUALS"))
                            .anyMatch(certificate -> certificate.premises().stream()
                                    .filter(ContainerLawCertificate.class::isInstance)
                                    .map(ContainerLawCertificate.class::cast)
                                    .anyMatch(law -> law.law()
                                            == ContainerLawCertificate.Law.COMMUTATIVITY)),
                    "parsed equality must retain its exact two-occurrence C quotient proof");
            ContainerConstructionCertificate disjointConstruction =
                    duplicateDisjoint.semanticArtifact().containerConstructions().stream()
                            .filter(certificate -> certificate.target().operator().operator()
                                    .equals("ALLOY/DISJOINT"))
                            .findFirst()
                            .orElseThrow(() -> new AssertionError(
                                    "parsed disjoint has no concrete container certificate"));
            check(disjointConstruction.containerTrace().inputOccurrences().size() == 3,
                    "disjoint source trace must retain every duplicate occurrence");
            check(disjointConstruction.containerTrace().outputOccurrences().size() == 3,
                    "disjoint bag normalization must not deduplicate operands");
            check(!disjointConstruction.containerTrace().deduplicated(),
                    "disjoint arguments have C but no I evidence");
            check(heterogeneousDisjoint.semanticArtifact().containerConstructions().stream()
                            .anyMatch(certificate -> certificate.operator().operator()
                                    .equals("ALLOY/DISJOINT")),
                    "valid heterogeneous disjoint operands retain concrete C evidence");
            List<ContainerConstructionCertificate> duplicateContainerEvidence =
                    new ArrayList<>(
                            duplicateDisjoint.semanticArtifact().containerConstructions());
            duplicateContainerEvidence.add(disjointConstruction);
            expectThrows(IllegalArgumentException.class, () ->
                    copyWithContainerConstructions(
                            duplicateDisjoint.semanticArtifact(),
                            duplicateContainerEvidence));
            GraphType sigS = GraphType.constructor("AlloySig:S");
            GraphType sigT = GraphType.constructor("AlloySig:T");
            GraphType sigState = GraphType.constructor("AlloySig:State");
            GraphType sigEvent = GraphType.constructor("AlloySig:Event");
            DependentChainCertificate binaryArrow = dependentChain(
                    binaryArrowType, DependentChainKind.ARROW);
            check(binaryArrow.target().outputType().equals(
                            GraphType.relation(Arrays.asList(sigS, sigT))),
                    "dependent ARROW preserves exact binary relation columns");
            check(binaryArrow.operandTypes().equals(List.of(
                            GraphType.relation(sigS), GraphType.relation(sigT))),
                    "dependent ARROW retains independently checked source columns");
            check(binaryArrow.source().leaves().size() == 2
                            && ((SeqPort) binaryArrow.target().ports().get(0))
                                    .schema().isDependent(),
                    "dependent ARROW uses one ordered positional Seq");
            check(binaryArrow.target().operator().containerLaws().values().stream()
                            .noneMatch(laws -> laws.associative()
                                    || laws.commutative()
                                    || laws.idempotent()
                                    || laws.hasUnit()),
                    "dependent ARROW Seq carries no A/C/I/unit quotient license");
            check(hasOutputType(
                            binaryJoinType,
                            GraphType.relation(Arrays.asList(sigEvent, sigState))),
                    "JOIN preserves the exact Event->State result columns");
            check(hasOutputType(
                            binaryJoinType,
                            GraphType.relation(Arrays.asList(sigState, sigEvent, sigState))),
                    "field leaves preserve their exact ternary owner-prefixed type");
            check(!binaryArrowType.equivalentTo(reversedArrowType),
                    "relation column order participates in certified identity");
            check(arrowAssocLeft.equivalentTo(arrowAssocRight)
                            && CanonicalAlloyPipeline.distance(
                                    arrowAssocLeft, arrowAssocRight) == 0,
                    "ARROW reassociation must share one certified ordered-chain target");
            assertReassociatedChain(
                    arrowAssocLeft, arrowAssocRight, DependentChainKind.ARROW);
            check(joinAssocLeft.equivalentTo(joinAssocRight)
                            && CanonicalAlloyPipeline.distance(
                                    joinAssocLeft, joinAssocRight) == 0,
                    "JOIN reassociation must share one certified ordered-chain target");
            assertReassociatedChain(
                    joinAssocLeft, joinAssocRight, DependentChainKind.JOIN);
            check(parameterJoinLeft.equivalentTo(parameterJoinRight),
                    "bound-parameter JOIN reassociation must receive symmetric evidence");
            check(CanonicalAlloyPipeline.distance(
                            parameterJoinLeft, parameterJoinRight) == 0,
                    "bound-parameter JOIN reassociation must remain in the zero kernel");
            assertReassociatedChain(
                    parameterJoinLeft,
                    parameterJoinRight,
                    DependentChainKind.JOIN);
            check(binderAll.semanticArtifact().dependentChainConstructions().stream()
                            .noneMatch(certificate -> certificate.source().kind()
                                    == DependentChainKind.JOIN),
                    "an unresolved polymorphic univ JOIN must remain unflattened");
            check(witnessedCarrierLeft.equivalentTo(witnessedCarrierRight),
                    "a preceding primitive binder must discharge an unnecessary relativized carrier: "
                            + witnessedCarrierLeft.digest() + " != "
                            + witnessedCarrierRight.digest());
            check(CanonicalAlloyPipeline.distance(
                            witnessedCarrierLeft, witnessedCarrierRight) == 0,
                    "equivalent implication-prenex forms must remain in the certified zero kernel");
            check(matrixBinderCount(
                            visitor, "witnessedCarrierLeft", QuantiVar.Quantifier.SOME, "Person")
                            == 1,
                    "the witnessed existential must retain its primitive Person repair type");
            check(commutativeBinderLeft.equivalentTo(commutativeBinderRight),
                    "binary inequality commutativity must survive a certified binder permutation: "
                            + commutativeBinderLeft.digest() + " != "
                            + commutativeBinderRight.digest());
            check(CanonicalAlloyPipeline.distance(
                            commutativeBinderLeft, commutativeBinderRight) == 0,
                    "commutative inequality and alpha alignment must share the zero kernel");
            check(localComprehensionLeft.equivalentTo(localComprehensionRight),
                    "beta-expanded repeated comprehensions must retain certified equality");
            check(CanonicalAlloyPipeline.distance(
                            localComprehensionLeft, localComprehensionRight) == 0,
                    "certified local comprehension alpha names must not cost matrix edits");
            check(!localPermutationLeft.equivalentTo(localPermutationRight),
                    "comprehension result columns must retain their positional identities");
            check(CanonicalAlloyPipeline.distance(
                            localPermutationLeft, localPermutationRight) > 0,
                    "swapping comprehension columns must remain outside the zero kernel");
            check(!namedRefFirst.equivalentTo(namedRefLast),
                    "distinct non-temporal reference symbols must not share a certified observation");
            check(CanonicalAlloyPipeline.distance(namedRefFirst, namedRefLast) == 1,
                    "changing ordering/first to ordering/last must cost one matrix edit");
            check(CanonicalAlloyPipeline.distance(
                            temporalBinderTarget, temporalBinderWrongTarget) > 0,
                    "an inherited temporal variable must reuse its owner's alpha mapping");
            check(temporalBinderTarget.equivalentTo(temporalBinderRenamed),
                    "a consistent binder permutation across temporal phases must remain certified");
            check(CanonicalAlloyPipeline.distance(
                            temporalBinderTarget, temporalBinderRenamed) == 0,
                    "consistent temporal alpha-renaming must retain repair distance zero");
            checkDuplicateIdDependentChainTransfer();
            checkDependentSourceOccurrenceBinding(Opcode.ARROW);
            checkDependentSourceOccurrenceBinding(Opcode.JOIN);
            checkFrozenProjectionOwnership();
            checkConcurrentProjectionFreeze();
            checkUnaryInteriorJoinDoesNotFlatten();
            checkUncertifiedSourceUnionRejected();
            checkConcreteDependentMismatchRejected();
            check(CanonicalAlloyPipeline.distance(alphaLeft, positive)
                            == CanonicalAlloyPipeline.distance(alphaRight, positive),
                    "repair distance must be invariant under certified alpha equivalence");
            check(CanonicalAlloyPipeline.distance(aciLeft, negative)
                            == CanonicalAlloyPipeline.distance(aciRight, negative),
                    "repair distance must be invariant under certified ACI equivalence");
            checkMetricParity(visitor, "alphaNearLeft", "alphaNearRight");
            checkMetricParity(visitor, "aciNearLeft", "aciNearRight");
            checkMetricParity(visitor, "binderAll", "binderSome");
            checkMetricParity(visitor, "temporalLeft", "temporalRight");
            checkMetricParity(visitor, "unequalAlphaLeft", "unequalAlphaRight");
            checkMetricParity(
                    visitor, "heterogeneousOrderLeft", "heterogeneousOrderRight");
            checkMetricParity(visitor, "domainAciLeft", "domainAciRight");
            checkMetricParity(
                    visitor, "redundantDomainGuardLeft", "redundantDomainGuardRight");
            long scopedMaximumS = matrixBinderCount(
                    visitor, "scopedMaximum", QuantiVar.Quantifier.ALL, "S");
            check(scopedMaximumS == 3,
                    "five sibling universal scopes need only three S coordinates; found "
                            + scopedMaximumS);
            check(matrixBinderCount(visitor, "scopedMaximum", QuantiVar.Quantifier.ALL, "T") == 0
                            && hasLocalQuantifierCarrier(
                                    visitor, "scopedMaximum", Opcode.FORALL, "T"),
                    "the nested differently typed coordinate must remain local and live");
            check(matrixBinderCount(visitor, "nestedAll", QuantiVar.Quantifier.ALL, "S") == 2,
                    "continuously nested universal declarations must not reuse a live coordinate");
            check(matrixBinderCount(visitor, "allUnderOr", QuantiVar.Quantifier.ALL, "S") == 2,
                    "universal scopes in disjunction branches are not reusable lanes");
            check(matrixBinderCount(visitor, "someUnderOr", QuantiVar.Quantifier.SOME, "S") == 1,
                    "existential scopes in disjunction branches must reuse their lane");
            check(matrixBinderCount(visitor, "nestedSomeUnderOr", QuantiVar.Quantifier.SOME, "S") == 2,
                    "nested existential chains in sibling disjunctions use maximum live arity");
            check(matrixBinderCount(visitor, "someUnderAnd", QuantiVar.Quantifier.SOME, "S") == 2,
                    "existential scopes in conjunction branches are not reusable lanes");
            check(matrixBinderCount(visitor, "quantifierBarrier", QuantiVar.Quantifier.ALL, "S") == 1,
                    "a safely lifted outer quantifier must expose the reusable universal frontier");
            check(hasInheritedAlias(visitor, "scopedTemporal", "b"),
                    "a reused slot must retain aliases needed by a temporal child");
            check(alphaLeft.eclassCount() > 0 && alphaLeft.enodeCount() > 0,
                    "exact graph statistics must be populated");
            check(alphaLeft.digest().length() == 64,
                    "canonical digest must be a SHA-256 hex string");
            check(alphaLeft.digest().equals(prepare(visitor, "alphaLeft").digest()),
                    "repeated adaptation must be deterministic");
            NormalForm missingExactType = new NormalForm();
            EGraphNode untypedRelation = new EGraphNode(
                    1_000_001,
                    Opcode.GLOBALBINDING,
                    List.of(),
                    false,
                    0,
                    false,
                    Metatype.SET);
            untypedRelation.setSourceName("S");
            untypedRelation.setSourceType("S");
            missingExactType.addEClass(untypedRelation);
            expectThrows(IllegalStateException.class, () ->
                    TheoryAlloyAdapter.adapt(List.of(missingExactType)));

            NormalForm missingBindingType = new NormalForm();
            missingBindingType.addParam(new QuantiVar(
                    1_000_002, "_q_missing", "missing", null));
            EGraphNode typedBoolean = new EGraphNode(
                    1_000_003,
                    Opcode.CONSTANT,
                    List.of(),
                    false,
                    0,
                    false,
                    Metatype.BOOLEAN);
            typedBoolean.setSourceName("true");
            typedBoolean.setSourceType("bool");
            typedBoolean.setExactAlloyType(ExactAlloyType.boolType());
            missingBindingType.addEClass(typedBoolean);
            expectThrows(IllegalStateException.class, () ->
                    TheoryAlloyAdapter.adapt(List.of(missingBindingType)));

            System.out.println("CanonicalAlloyPipelineTest passed: " + checks + " checks");
        } finally {
            Files.deleteIfExists(modelPath);
            Files.deleteIfExists(directory);
        }
    }

    private static CanonicalAlloyPipeline.Prepared prepare(
            MASGVisitor visitor,
            String predicate) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        return CanonicalAlloyPipeline.prepare(graph);
    }

    private static CanonicalAlloyPipeline.Prepared prepare(
            MASGVisitor visitor,
            String predicate,
            SemanticProfile semanticProfile) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        return CanonicalAlloyPipeline.prepare(graph, semanticProfile);
    }

    private static boolean hasOperatorOutput(
            CanonicalAlloyPipeline.Prepared prepared,
            String operator,
            GraphType outputType) {
        return prepared.semanticArtifact().classes().values().stream()
                .flatMap(record -> record.shapeWitnesses().keySet().stream())
                .map(shape -> shape.node())
                .anyMatch(node -> operator.equals(node.operator().operator())
                        && outputType.equals(node.outputType()));
    }

    private static boolean hasOutputType(
            CanonicalAlloyPipeline.Prepared prepared,
            GraphType outputType) {
        return prepared.semanticArtifact().classes().values().stream()
                .flatMap(record -> record.shapeWitnesses().keySet().stream())
                .map(shape -> shape.node())
                .anyMatch(node -> outputType.equals(node.outputType()));
    }

    private static DependentChainCertificate dependentChain(
            CanonicalAlloyPipeline.Prepared prepared,
            DependentChainKind kind) {
        return prepared.semanticArtifact().dependentChainConstructions().stream()
                .filter(certificate -> certificate.source().kind() == kind)
                .findFirst()
                .orElseThrow(() -> new AssertionError(
                        "missing dependent " + kind + " construction"));
    }

    private static void assertReassociatedChain(
            CanonicalAlloyPipeline.Prepared left,
            CanonicalAlloyPipeline.Prepared right,
            DependentChainKind kind) {
        DependentChainCertificate leftCertificate = dependentChain(left, kind);
        DependentChainCertificate rightCertificate = dependentChain(right, kind);
        check(!leftCertificate.source().structuralKey().equals(
                        rightCertificate.source().structuralKey()),
                kind + " fixtures must expose distinct binary source associations");
        check(leftCertificate.target().structuralKey().equals(
                        rightCertificate.target().structuralKey()),
                kind + " reassociation must preserve one ordered dependent Seq target");
        check(leftCertificate.operandTypes().equals(rightCertificate.operandTypes()),
                kind + " reassociation must preserve every positional type proof");
    }

    private static void checkDuplicateIdDependentChainTransfer() {
        SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
        EGraphNode first = binaryNode(
                701,
                Opcode.ARROW,
                relationalLeaf(710, "zA", "A"),
                relationalLeaf(711, "zBC", "B", "C"),
                ExactAlloyType.relation(List.of("A", "B", "C")),
                Metatype.SET,
                profile);
        EGraphNode second = binaryNode(
                701,
                Opcode.ARROW,
                relationalLeaf(712, "aAB", "A", "B"),
                relationalLeaf(713, "aC", "C"),
                ExactAlloyType.relation(List.of("A", "B", "C")),
                Metatype.SET,
                profile);
        EGraphNode root = new EGraphNode(
                700, Opcode.AND, new ArrayList<>(), true, -1, true,
                Metatype.BOOLEAN, profile);
        root.setExactAlloyType(ExactAlloyType.boolType());
        root.addChild(unaryFormula(720, Opcode.SOME, first, profile));
        root.addChild(unaryFormula(721, Opcode.SOME, second, profile));

        NormalForm form = new NormalForm();
        form.addEClass(root);
        form.normalize();
        TheoryAlloyAdapter.Result result = TheoryAlloyAdapter.adapt(
                List.of(form), profile);
        check(result.dependentChainSourceCertificates().size() == 2,
                "duplicate parser IDs must retain two dependent source occurrences");
        long distinctLineages = result.dependentChainSourceCertificates().keySet().stream()
                .map(EGraphNode::getSourceOccurrenceLineage)
                .distinct()
                .count();
        check(distinctLineages == 2,
                "dependent source occurrences must transfer through distinct lineages");
        RepairProjection.project(
                result,
                List.of(form));
        check(true,
                "duplicate-ID dependent certificates attach to their positional type proofs");
    }

    private static void checkFrozenProjectionOwnership() {
        SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
        EGraphNode source = new EGraphNode(
                680, Opcode.CONSTANT, new ArrayList<>(), false, 0, false,
                Metatype.BOOLEAN, profile);
        source.setSourceName("true");
        source.setExactAlloyType(ExactAlloyType.boolType());
        NormalForm form = new NormalForm();
        form.addEClass(source);

        TheoryAlloyAdapter.Result result = TheoryAlloyAdapter.adapt(
                List.of(form), profile);
        check(form.isFrozenForCertification()
                        && source.isFrozenForCertification(),
                "adaptation must freeze its complete repair projection source");
        expectThrows(IllegalStateException.class,
                () -> source.setSourceName("false"));
        expectThrows(UnsupportedOperationException.class,
                () -> form.getTemporalChildren().add(new NormalForm()));

        NormalForm foreign = new NormalForm();
        EGraphNode foreignSource = new EGraphNode(
                681, Opcode.CONSTANT, new ArrayList<>(), false, 0, false,
                Metatype.BOOLEAN, profile);
        foreignSource.setSourceName("true");
        foreignSource.setExactAlloyType(ExactAlloyType.boolType());
        foreign.addEClass(foreignSource);
        expectThrows(IllegalArgumentException.class,
                () -> RepairProjection.project(result, List.of(foreign)));
        check(java.util.Arrays.stream(RepairProjection.class.getMethods())
                        .noneMatch(method -> method.getName().equals("project")
                                && method.getParameterCount() == 3),
                "repair projection must expose no caller-supplied authority field");

        RepairView view = RepairProjection.project(result, List.of(form));
        check("true".equals(view.phases().get(0).matrix().payload()),
                "projection must retain the frozen certified source payload");
    }

    private static void checkEmptyRelationArity(CompModule module) throws Exception {
        ExactAlloyType unary = ExactAlloyType.from(
                CompUtil.parseOneExpression_fromString(module, "none").type());
        ExactAlloyType binary = ExactAlloyType.from(
                CompUtil.parseOneExpression_fromString(module, "none -> none").type());
        ExactAlloyType ternary = ExactAlloyType.from(
                CompUtil.parseOneExpression_fromString(
                        module, "(none -> none) -> none").type());
        check(unary.kind() == ExactAlloyType.Kind.EMPTY_RELATION
                        && unary.relationArity() == 1,
                "unary empty relation must retain parser-proved arity");
        check(binary.kind() == ExactAlloyType.Kind.EMPTY_RELATION
                        && binary.relationArity() == 2,
                "binary empty relation must retain parser-proved arity");
        check(ternary.kind() == ExactAlloyType.Kind.EMPTY_RELATION
                        && ternary.relationArity() == 3,
                "ternary empty relation must retain parser-proved arity");
        check(unary.alternatives().isEmpty()
                        && binary.alternatives().isEmpty()
                        && ternary.alternatives().isEmpty(),
                "empty relation conversion must not invent erased signature columns");

        GraphType unaryGraph = AlloyTypeBridge.graphType(unary);
        GraphType binaryGraph = AlloyTypeBridge.graphType(binary);
        GraphType ternaryGraph = AlloyTypeBridge.graphType(ternary);
        check(!unaryGraph.equals(binaryGraph)
                        && !binaryGraph.equals(ternaryGraph)
                        && !unaryGraph.equals(ternaryGraph),
                "empty relation graph identity must distinguish arity");
        check(AlloyTypeBridge.isCommutativeRelationCarrier(binaryGraph),
                "an arity-bearing empty relation remains a relation carrier");
        check(!AlloyTypeBridge.isCommutativeRelationCarrier(
                        GraphType.constructor("AlloyEmptyRelation$arity=02")),
                "noncanonical empty relation arity must reject");

        ExactAlloyType arityless = ExactAlloyType.from(Type.EMPTY);
        check(arityless.kind() == ExactAlloyType.Kind.UNKNOWN,
                "arityless empty parser type must fail closed");
        expectThrows(IllegalStateException.class,
                () -> AlloyTypeBridge.graphType(arityless));

        byte[] serialized = serialize(binary);
        check(binary.equals(deserialize(serialized)),
                "valid exact empty relation must survive serialization");
        byte[] marker = binary.stableString().getBytes(StandardCharsets.UTF_8);
        int markerOffset = indexOf(serialized, marker);
        check(markerOffset >= 0,
                "serialized exact type must contain its stable-key commitment");
        byte[] forged = serialized.clone();
        forged[markerOffset + marker.length - 2] = '3';
        expectThrows(InvalidObjectException.class,
                () -> deserialize(forged));

        EGraphNode.beginGraph();
        try {
            SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
            NormalForm unaryForm = emptyRelationForm(760, 1, profile);
            NormalForm binaryForm = emptyRelationForm(761, 2, profile);
            TheoryAlloyAdapter.Result unaryResult = TheoryAlloyAdapter.adapt(
                    List.of(unaryForm), profile);
            TheoryAlloyAdapter.Result binaryResult = TheoryAlloyAdapter.adapt(
                    List.of(binaryForm), profile);
            RepairView unaryView = RepairProjection.project(
                    unaryResult, List.of(unaryForm));
            RepairView binaryView = RepairProjection.project(
                    binaryResult, List.of(binaryForm));
            check(QuotientRepairDistance.distance(unaryView, binaryView) > 0,
                    "repair metric must distinguish cross-arity empty relations");
        } finally {
            EGraphNode.endGraph();
        }
    }

    private static NormalForm emptyRelationForm(
            int id,
            int arity,
            SemanticProfile profile) {
        EGraphNode node = new EGraphNode(
                id, Opcode.CONSTANT, new ArrayList<>(), false, 0, false,
                Metatype.SET, profile);
        node.setSourceName("none");
        node.setExactAlloyType(ExactAlloyType.emptyRelation(arity));
        NormalForm form = new NormalForm();
        form.addEClass(node);
        return form;
    }

    private static byte[] serialize(Object value) throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (ObjectOutputStream output = new ObjectOutputStream(bytes)) {
            output.writeObject(value);
        }
        return bytes.toByteArray();
    }

    private static Object deserialize(byte[] bytes) throws Exception {
        try (ObjectInputStream input = new ObjectInputStream(
                new ByteArrayInputStream(bytes))) {
            return input.readObject();
        }
    }

    private static int indexOf(byte[] haystack, byte[] needle) {
        outer:
        for (int offset = 0; offset <= haystack.length - needle.length; offset++) {
            for (int index = 0; index < needle.length; index++) {
                if (haystack[offset + index] != needle[index]) {
                    continue outer;
                }
            }
            return offset;
        }
        return -1;
    }

    private static void checkConcurrentProjectionFreeze() throws Exception {
        for (int iteration = 0; iteration < 32; iteration++) {
            EGraphNode.beginGraph();
            try {
                SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
                EGraphNode source = new EGraphNode(
                        690 + iteration, Opcode.CONSTANT, new ArrayList<>(),
                        false, 0, false, Metatype.BOOLEAN, profile);
                source.setSourceName("true");
                source.setExactAlloyType(ExactAlloyType.boolType());
                NormalForm form = new NormalForm();
                form.addEClass(source);

                CountDownLatch start = new CountDownLatch(1);
                AtomicReference<TheoryAlloyAdapter.Result> result =
                        new AtomicReference<>();
                AtomicReference<Throwable> adaptationFailure = new AtomicReference<>();
                AtomicReference<Throwable> mutationFailure = new AtomicReference<>();
                Thread adapter = new Thread(() -> {
                    await(start);
                    try {
                        result.set(TheoryAlloyAdapter.adapt(List.of(form), profile));
                    } catch (Throwable failure) {
                        adaptationFailure.set(failure);
                    }
                }, "projection-freeze-adapter");
                Thread mutator = new Thread(() -> {
                    await(start);
                    try {
                        source.setSourceName("false");
                    } catch (Throwable failure) {
                        mutationFailure.set(failure);
                    }
                }, "projection-freeze-mutator");
                adapter.start();
                mutator.start();
                start.countDown();
                adapter.join();
                mutator.join();

                check(adaptationFailure.get() == null && result.get() != null,
                        "concurrent certification must complete without a mixed source");
                Throwable rejectedMutation = mutationFailure.get();
                check(rejectedMutation == null
                                || rejectedMutation instanceof IllegalStateException,
                        "a mutation losing the certification race must fail closed");
                RepairView view = RepairProjection.project(result.get(), List.of(form));
                check(source.getSourceName().equals(
                                view.phases().get(0).matrix().payload()),
                        "concurrent certification and projection must observe one source state");
                check(result.get().canonicalKey().equals(
                                TheoryAlloyAdapter.adapt(List.of(form), profile).canonicalKey()),
                        "a frozen source must reproduce the same certified key");
            } finally {
                EGraphNode.endGraph();
            }
        }
    }

    private static void await(CountDownLatch latch) {
        try {
            latch.await();
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("Projection race probe was interrupted", exception);
        }
    }

    private static void checkDependentSourceOccurrenceBinding(Opcode opcode) {
        SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
        EGraphNode first;
        EGraphNode second;
        if (opcode == Opcode.ARROW) {
            first = binaryNode(
                    750, opcode,
                    relationalLeaf(751, "firstA", "A"),
                    relationalLeaf(752, "firstB", "B"),
                    ExactAlloyType.relation(List.of("A", "B")),
                    Metatype.SET, profile);
            second = binaryNode(
                    750, opcode,
                    relationalLeaf(753, "secondA", "A"),
                    relationalLeaf(754, "secondB", "B"),
                    ExactAlloyType.relation(List.of("A", "B")),
                    Metatype.SET, profile);
        } else {
            first = binaryNode(
                    760, opcode,
                    relationalLeaf(761, "firstAB", "A", "B"),
                    relationalLeaf(762, "firstBC", "B", "C"),
                    ExactAlloyType.relation(List.of("A", "C")),
                    Metatype.SET, profile);
            second = binaryNode(
                    760, opcode,
                    relationalLeaf(763, "secondAB", "A", "B"),
                    relationalLeaf(764, "secondBC", "B", "C"),
                    ExactAlloyType.relation(List.of("A", "C")),
                    Metatype.SET, profile);
        }
        EGraphNode root = new EGraphNode(
                770, Opcode.AND, new ArrayList<>(), true, -1, true,
                Metatype.BOOLEAN, profile);
        root.setExactAlloyType(ExactAlloyType.boolType());
        root.addChild(unaryFormula(771, Opcode.SOME, first, profile));
        root.addChild(unaryFormula(772, Opcode.SOME, second, profile));

        NormalForm form = new NormalForm();
        form.addEClass(root);
        form.normalize();
        TheoryAlloyAdapter.Result result = TheoryAlloyAdapter.adapt(
                List.of(form), profile);
        List<Map.Entry<EGraphNode, TheoryAlloyAdapter.DependentChainSourceBinding>>
                bindings = new ArrayList<>(
                        result.dependentChainSourceBindings().entrySet());
        check(bindings.size() == 2,
                opcode + " same-typed fixture must retain two occurrence bindings");
        check(!bindings.get(0).getValue().sourceOccurrencePath().equals(
                        bindings.get(1).getValue().sourceOccurrencePath()),
                opcode + " same-typed occurrences need distinct stable paths");
        check(!bindings.get(0).getValue().sourceOccurrenceCommitment().equals(
                        bindings.get(1).getValue().sourceOccurrenceCommitment()),
                opcode + " same-typed occurrences need distinct source commitments");
        expectDependentBindingRejectsCertificateSwap(
                bindings.get(0).getKey(), bindings.get(1).getValue());

        EGraphNode mutatedRoot = bindings.get(0).getKey();
        expectThrows(IllegalStateException.class, () ->
                mutatedRoot.getChildren().get(0).setSourceName(
                        "postCertificationReplacement"));
        RepairProjection.project(result, List.of(form));
    }

    private static void expectDependentBindingRejectsCertificateSwap(
            EGraphNode source,
            TheoryAlloyAdapter.DependentChainSourceBinding wrongBinding) {
        checks++;
        try {
            java.lang.reflect.Constructor<
                    TheoryAlloyAdapter.DependentChainSourceBinding> constructor =
                    TheoryAlloyAdapter.DependentChainSourceBinding.class
                            .getDeclaredConstructor(
                                    EGraphNode.class,
                                    String.class,
                                    DependentChainCertificate.class);
            constructor.setAccessible(true);
            constructor.newInstance(
                    source,
                    wrongBinding.sourceOccurrencePath(),
                    wrongBinding.certificate());
        } catch (java.lang.reflect.InvocationTargetException exception) {
            if (exception.getCause() instanceof IllegalArgumentException
                    || exception.getCause() instanceof IllegalStateException) {
                return;
            }
            throw new AssertionError(
                    "Dependent binding failed for an unrelated reason",
                    exception.getCause());
        } catch (ReflectiveOperationException exception) {
            throw new AssertionError(
                    "Could not exercise dependent binding constructor", exception);
        }
        throw new AssertionError(
                "A same-typed dependent certificate was accepted for another occurrence");
    }

    private static void checkUnaryInteriorJoinDoesNotFlatten() {
        SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
        EGraphNode leftR = relationalLeaf(780, "R", "X", "X");
        EGraphNode leftS = relationalLeaf(781, "S", "X");
        EGraphNode leftT = relationalLeaf(782, "T", "X", "X");
        EGraphNode left = binaryNode(
                783,
                Opcode.JOIN,
                binaryNode(
                        784,
                        Opcode.JOIN,
                        leftR,
                        leftS,
                        ExactAlloyType.unaryRelation("X"),
                        Metatype.SET,
                        profile),
                leftT,
                ExactAlloyType.unaryRelation("X"),
                Metatype.SET,
                profile);

        EGraphNode rightR = relationalLeaf(785, "R", "X", "X");
        EGraphNode rightS = relationalLeaf(786, "S", "X");
        EGraphNode rightT = relationalLeaf(787, "T", "X", "X");
        EGraphNode right = binaryNode(
                788,
                Opcode.JOIN,
                rightR,
                binaryNode(
                        789,
                        Opcode.JOIN,
                        rightS,
                        rightT,
                        ExactAlloyType.unaryRelation("X"),
                        Metatype.SET,
                        profile),
                ExactAlloyType.unaryRelation("X"),
                Metatype.SET,
                profile);

        NormalForm leftForm = new NormalForm();
        leftForm.addEClass(left);
        leftForm.normalize();
        NormalForm rightForm = new NormalForm();
        rightForm.addEClass(right);
        rightForm.normalize();
        TheoryAlloyAdapter.Result leftResult = TheoryAlloyAdapter.adapt(
                List.of(leftForm), profile);
        TheoryAlloyAdapter.Result rightResult = TheoryAlloyAdapter.adapt(
                List.of(rightForm), profile);
        check(!leftResult.canonicalKey().equals(rightResult.canonicalKey()),
                "JOIN with a unary interior operand must retain source association");
        RepairView leftView = RepairProjection.project(
                leftResult, List.of(leftForm));
        RepairView rightView = RepairProjection.project(
                rightResult, List.of(rightForm));
        check(QuotientRepairDistance.distance(leftView, rightView) > 0,
                "the unary-interior JOIN counterexample must not enter the zero kernel");
    }

    private static EGraphNode relationalLeaf(
            int id,
            String name,
            String... columns) {
        EGraphNode leaf = new EGraphNode(
                id, Opcode.GLOBALBINDING, new ArrayList<>(), false, 0, false,
                Metatype.SET);
        leaf.setSourceName(name);
        leaf.setSourceType(name);
        leaf.setExactAlloyType(ExactAlloyType.relation(Arrays.asList(columns)));
        return leaf;
    }

    private static EGraphNode binaryNode(
            int id,
            Opcode opcode,
            EGraphNode left,
            EGraphNode right,
            ExactAlloyType type,
            Metatype metatype,
            SemanticProfile profile) {
        EGraphNode node = new EGraphNode(
                id, opcode, new ArrayList<>(), false, 2, false, metatype, profile);
        node.setExactAlloyType(type);
        node.addChild(left);
        node.addChild(right);
        return node;
    }

    private static EGraphNode unaryFormula(
            int id,
            Opcode opcode,
            EGraphNode child,
            SemanticProfile profile) {
        EGraphNode node = new EGraphNode(
                id, opcode, new ArrayList<>(), false, 1, false,
                Metatype.BOOLEAN, profile);
        node.setExactAlloyType(ExactAlloyType.boolType());
        node.addChild(child);
        return node;
    }

    private static void checkUncertifiedSourceUnionRejected() {
        EGraphNode.beginGraph();
        try {
            EGraphNode left = relationalLeaf(730, "left", "S");
            EGraphNode right = relationalLeaf(731, "right", "S");
            EGraphNode.union(left.getEClassRef(), right.getEClassRef());
            NormalForm poisoned = new NormalForm();
            poisoned.addEClass(right);
            expectThrows(IllegalStateException.class, () ->
                    TheoryAlloyAdapter.adapt(
                            List.of(poisoned),
                            SemanticProfile.alloyOverflowForbidding()));
        } finally {
            EGraphNode.endGraph();
        }
    }

    private static void checkConcreteDependentMismatchRejected() {
        SemanticProfile profile = SemanticProfile.alloyOverflowForbidding();
        EGraphNode malformed = binaryNode(
                740,
                Opcode.ARROW,
                relationalLeaf(741, "leftA", "A"),
                relationalLeaf(742, "rightB", "B"),
                ExactAlloyType.unaryRelation("X"),
                Metatype.SET,
                profile);
        NormalForm form = new NormalForm();
        form.addEClass(malformed);
        expectThrows(IllegalStateException.class, () ->
                TheoryAlloyAdapter.adapt(List.of(form), profile));
    }

    private static void checkMetricParity(
            MASGVisitor visitor,
            String leftName,
            String rightName) {
        Multigraph leftGraph = visitor.getForest().get(visitor.getForestId(leftName));
        Multigraph rightGraph = visitor.getForest().get(visitor.getForestId(rightName));
        Canonical.Prepared left = Canonical.prepare(leftGraph);
        Canonical.Prepared right = Canonical.prepare(rightGraph);
        CanonicalDistance.DistanceBreakdown expected =
                Canonical.distanceBreakdown(left, right);
        QuotientRepairDistance.Result actual = CanonicalAlloyPipeline.distanceEvaluation(
                CanonicalAlloyPipeline.prepare(left),
                CanonicalAlloyPipeline.prepare(right));
        check(actual.distance() == expected.distance()
                        && actual.temporalDistance() == expected.temporalDistance()
                        && actual.quantifierDistance() == expected.quantifierDistance()
                        && actual.matrixDistance() == expected.matrixDistance(),
                "faithful metric port must preserve every reference metric component for "
                        + leftName + " versus " + rightName
                        + ": expected total/temporal/quantifier/matrix="
                        + expected.distance() + "/" + expected.temporalDistance() + "/"
                        + expected.quantifierDistance() + "/" + expected.matrixDistance()
                        + ", actual=" + actual.distance() + "/" + actual.temporalDistance()
                        + "/" + actual.quantifierDistance() + "/" + actual.matrixDistance()
                        + ", leftIR=" + Canonical.irTemporalFol(left)
                        + ", rightIR=" + Canonical.irTemporalFol(right));
    }

    private static int legacyDistance(
            MASGVisitor visitor,
            String leftName,
            String rightName) {
        Multigraph leftGraph = visitor.getForest().get(visitor.getForestId(leftName));
        Multigraph rightGraph = visitor.getForest().get(visitor.getForestId(rightName));
        return Canonical.distance(
                Canonical.prepare(leftGraph), Canonical.prepare(rightGraph));
    }

    private static long matrixBinderCount(
            MASGVisitor visitor,
            String predicate,
            QuantiVar.Quantifier quantifier,
            String type) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        Canonical.Prepared prepared = Canonical.prepare(graph);
        check(!prepared.normalizedForms().isEmpty(),
                "missing normalized form for " + predicate);
        NormalForm root = prepared.normalizedForms().get(0);
        return root.getMatrixQuantiVars().stream()
                .filter(variable -> variable.getQuantifier() == quantifier)
                .filter(variable -> type.equals(variable.getTypeName()))
                .count();
    }

    private static boolean hasLocalQuantifierCarrier(
            MASGVisitor visitor,
            String predicate,
            Opcode quantifier,
            String carrier) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        Canonical.Prepared prepared = Canonical.prepare(graph);
        check(!prepared.normalizedForms().isEmpty(),
                "missing normalized form for " + predicate);
        return hasLocalQuantifierCarrier(
                prepared.normalizedForms().get(0).getMatrixEGraph(), quantifier, carrier);
    }

    private static boolean hasLocalQuantifierCarrier(
            EGraphNode node,
            Opcode quantifier,
            String carrier) {
        if (node.getOpcode() == quantifier) {
            for (EGraphNode declaration : node.getChildren()) {
                if ((declaration.getOpcode() == Opcode.GENERICRELDECL
                                || declaration.getOpcode() == Opcode.DISJ
                                || declaration.getOpcode() == Opcode.VAR
                                || declaration.getOpcode() == Opcode.DISJVAR)
                        && !declaration.getChildren().isEmpty()
                        && containsSourceName(declaration.getChildren().get(0), carrier)) {
                    return true;
                }
            }
        }
        for (EGraphNode child : node.getChildren()) {
            if (hasLocalQuantifierCarrier(child, quantifier, carrier)) {
                return true;
            }
        }
        return false;
    }

    private static boolean containsSourceName(EGraphNode node, String sourceName) {
        if (sourceName.equals(node.getSourceName())) {
            return true;
        }
        for (EGraphNode child : node.getChildren()) {
            if (containsSourceName(child, sourceName)) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasInheritedAlias(
            MASGVisitor visitor,
            String predicate,
            String alias) {
        Integer id = visitor.getForestId(predicate);
        check(id != null, "missing MASG predicate " + predicate);
        Multigraph graph = visitor.getForest().get(id);
        check(graph != null, "missing MASG graph " + predicate);
        Canonical.Prepared prepared = Canonical.prepare(graph);
        for (NormalForm form : prepared.normalizedForms()) {
            for (QuantiVar variable : form.getInheritedQuantiVars()) {
                if (variable.getOriginalNames().contains(alias)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static void check(boolean condition, String message) {
        checks++;
        if (!condition) {
            throw new AssertionError(message);
        }
    }

    private static CertifiedSemanticArtifact copyWithFlatConstructions(
            CertifiedSemanticArtifact source,
            List<? extends FlatConstructionCertificate> flatConstructions) {
        return source.withFlatConstructions(flatConstructions);
    }

    private static CertifiedSemanticArtifact copyWithContainerConstructions(
            CertifiedSemanticArtifact source,
            List<? extends ContainerConstructionCertificate> containerConstructions) {
        return source.withContainerConstructions(containerConstructions);
    }

    private static void expectThrows(
            Class<? extends Throwable> expected, ThrowingRunnable operation) {
        checks++;
        try {
            operation.run();
        } catch (Throwable throwable) {
            if (expected.isInstance(throwable)) {
                return;
            }
            throw new AssertionError(
                    "Expected " + expected.getSimpleName() + " but got " + throwable,
                    throwable);
        }
        throw new AssertionError("Expected " + expected.getSimpleName());
    }

    @FunctionalInterface
    private interface ThrowingRunnable {
        void run() throws Exception;
    }

    private static String source() {
        return "module phase_i\n"
                + "open util/ordering[S] as orderingS\n"
                + "sig S { r: set S }\n"
                + "sig T {}\n"
                + "sig Protected, Trash in S {}\n"
                + "sig State { trans: Event -> State }\n"
                + "sig Init in State {}\n"
                + "sig Event {}\n"
                + "sig Person { Teaches: set Class }\n"
                + "sig Group {}\n"
                + "sig Class { Groups: Person -> Group }\n"
                + "sig Teacher in Person {}\n"
                + "sig Student in Person {}\n"
                + "pred alphaLeft { all x, y: S | y in x.r }\n"
                + "pred alphaRight { all a, b: S | a in b.r }\n"
                + "pred aciLeft { (some S and lone S) and one S }\n"
                + "pred aciRight { one S and (lone S and some S) }\n"
                + "pred andDuplicate { (some S) and (some S) }\n"
                + "pred andBare { some S }\n"
                + "pred orDuplicate { (some S) or (some S) }\n"
                + "pred orBare { some S }\n"
                + "pred unionDuplicate { some (S + S) }\n"
                + "pred unionBare { some S }\n"
                + "pred intersectDuplicate { some (S & S) }\n"
                + "pred intersectBare { some S }\n"
                + "pred positive { some S }\n"
                + "pred negative { no S }\n"
                + "pred shadowLeft { all x: S | some x: S | x in S }\n"
                + "pred shadowRight { all a: S | some b: S | b in S }\n"
                + "pred disjointPred { all disj x, y: S | y in x.r }\n"
                + "pred nondisjoint { all x, y: S | y in x.r }\n"
                + "pred temporalLeft { after some S }\n"
                + "pred temporalRight { after no S }\n"
                + "pred mixedCarrierLeft { all x: S, y: T | x in S and y in T }\n"
                + "pred mixedCarrierRight { all a: S, b: T | a in S and b in T }\n"
                + "pred heterogeneousOrderLeft { all s: S, t: T | s in S and t in T }\n"
                + "pred heterogeneousOrderRight { all t: T, s: S | s in S and t in T }\n"
                + "pred domainAciLeft { always all x: Protected & Trash | x in S }\n"
                + "pred domainAciRight { always all x: Trash & Protected | x in S }\n"
                + "pred nestedUnionLeft { some ((S + Protected) + Trash) }\n"
                + "pred nestedUnionRight { some (S + (Protected + Trash)) }\n"
                + "pred equalityOrderLeft { S = Protected }\n"
                + "pred equalityOrderRight { Protected = S }\n"
                + "pred duplicateDisjoint { disj[S, S, Protected] }\n"
                + "pred heterogeneousDisjoint { disj[S, T] }\n"
                + "pred binaryArrowType { some (S -> T) }\n"
                + "pred reversedArrowType { some (T -> S) }\n"
                + "pred binaryJoinType { some (State.trans) }\n"
                + "pred arrowAssocLeft { some ((S -> T) -> Protected) }\n"
                + "pred arrowAssocRight { some (S -> (T -> Protected)) }\n"
                + "pred joinAssocLeft { some ((State.trans).State) }\n"
                + "pred joinAssocRight { some (State.(trans.State)) }\n"
                + "pred parameterJoinLeft[x:S] { some ((x.r).r) }\n"
                + "pred parameterJoinRight[x:S] { some (x.(r.r)) }\n"
                + "pred parameterTypeS[x:S] { some x }\n"
                + "pred parameterTypeT[x:T] { some x }\n"
                + "pred parameterTypeTNo[x:T] { no x }\n"
                + "pred localGroupingLeft {\n"
                + "  let t = { x: State, y: State | some e: Event | x->e->y in trans } |\n"
                + "  all s: State | some i: Init | s in i.^t\n"
                + "}\n"
                + "pred localGroupingRight {\n"
                + "  let t = { x, y: State | some e: Event | x->e->y in trans } |\n"
                + "  all s: State | some i: Init | s in i.^t\n"
                + "}\n"
                + "pred alphaNearLeft { all x,y:S | x in y.r and some x.r and no y.r.r }\n"
                + "pred alphaNearRight { all x,y:S | x in y.r and no x.r and no y.r.r }\n"
                + "pred aciNearLeft { some S and no S.r and one S.r.r and lone S.r.r.r }\n"
                + "pred aciNearRight { some S and no S.r and one S.r.r and some S.r.r.r }\n"
                + "pred binderAll { all x:S | x in x.*r }\n"
                + "pred binderSome { some x:S | x in x.*r }\n"
                + "pred nestedSubtypeLeft {\n"
                + "  all p: Protected | all t: Trash | p in t.*r\n"
                + "}\n"
                + "pred nestedSubtypeRight {\n"
                + "  all t: Trash, p: Protected | p in t.*r\n"
                + "}\n"
                + "pred redundantDomainGuardLeft {\n"
                + "  always all p: Protected |\n"
                + "    p in Protected implies historically p in Protected\n"
                + "}\n"
                + "pred redundantDomainGuardRight {\n"
                + "  always all p: Protected | historically p in Protected\n"
                + "}\n"
                + "pred witnessedCarrierLeft {\n"
                + "  all c: Class |\n"
                + "    (some s: Person, g: Group | c->s->g in Groups)\n"
                + "    implies (some t: Teacher | t->c in Teaches)\n"
                + "}\n"
                + "pred witnessedCarrierRight {\n"
                + "  all c: Class, s: Person, g: Group | some t: Person |\n"
                + "    c->s->g in Groups implies t->c in Teaches and t in Teacher\n"
                + "}\n"
                + "pred commutativeBinderLeft {\n"
                + "  all p, q: Person | p in Teacher and q in Student implies p != q\n"
                + "}\n"
                + "pred commutativeBinderRight {\n"
                + "  no p: Student, q: Teacher | p = q\n"
                + "}\n"
                + "pred localComprehensionLeft {\n"
                + "  all s: State |\n"
                + "    s in Init.^{s1, s2: State | some s1.trans.s2}\n"
                + "    implies some (Init & s.^{s1, s2: State | some s1.trans.s2})\n"
                + "}\n"
                + "pred localComprehensionRight {\n"
                + "  let t = {x: State, y: State | some (x.trans).y} |\n"
                + "  all s: Init.^t | some s.^t & Init\n"
                + "}\n"
                + "pred localPermutationLeft {\n"
                + "  some {x, y: S | x in y.r}\n"
                + "}\n"
                + "pred localPermutationRight {\n"
                + "  some {a, b: S | b in a.r}\n"
                + "}\n"
                + "pred namedRefFirst { orderingS/first in S }\n"
                + "pred namedRefLast { orderingS/last in S }\n"
                + "pred temporalBinderTarget {\n"
                + "  always all x, y: S | x->y in r implies eventually y in S\n"
                + "}\n"
                + "pred temporalBinderWrongTarget {\n"
                + "  always all x, y: S | x->y in r implies eventually x in S\n"
                + "}\n"
                + "pred temporalBinderRenamed {\n"
                + "  always all a, b: S | b->a in r implies eventually a in S\n"
                + "}\n"
                + "pred unequalAlphaLeft {\n"
                + "  all x0, x1, x2: S | some x0.r and no x1.r and one x2.r\n"
                + "}\n"
                + "pred unequalAlphaRight { all y: S | no y.r }\n"
                + "pred scopedMaximum {\n"
                + "  all a, b, c: S | a in S and b in S and c in S\n"
                + "  all d: S | d in S\n"
                + "  all e, f: S | e in S and f in S\n"
                + "  all g: S | g in S\n"
                + "  all h: S | all i: T | h in S and i in T\n"
                + "}\n"
                + "pred nestedAll { all a: S | all b: S | a in S and b in S }\n"
                + "pred allUnderOr { (all a: S | a in S) or (all b: S | b in S) }\n"
                + "pred someUnderOr { (some a: S | a in S) or (some b: S | b in S) }\n"
                + "pred nestedSomeUnderOr {\n"
                + "  (some a: S | some b: S | a in S and b in S)\n"
                + "  or (some c: S | some d: S | c in S and d in S)\n"
                + "}\n"
                + "pred someUnderAnd { (some a: S | a in S) and (some b: S | b in S) }\n"
                + "pred quantifierBarrier {\n"
                + "  (all x: S | x in S)\n"
                + "  and (some y: T | all z: S | y in T and z in S)\n"
                + "}\n"
                + "pred scopedTemporal {\n"
                + "  all a: S | a in S\n"
                + "  all b: S | after b in S\n"
                + "}\n";
    }
}
