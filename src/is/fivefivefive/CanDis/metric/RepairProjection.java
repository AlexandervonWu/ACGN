package is.fivefivefive.CanDis.metric;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.FlexibleArityKind;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.NormalForm.TemporalOp;
import is.fivefivefive.CanDis.core.QuantiVar;
import is.fivefivefive.CanDis.metric.RepairView.Binding;
import is.fivefivefive.CanDis.metric.RepairView.BindingRole;
import is.fivefivefive.CanDis.metric.RepairView.ContainerKind;
import is.fivefivefive.CanDis.metric.RepairView.Declaration;
import is.fivefivefive.CanDis.metric.RepairView.Node;
import is.fivefivefive.CanDis.metric.RepairView.Phase;
import is.fivefivefive.CanDis.metric.RepairView.TemporalNode;
import is.fivefivefive.CanDis.theory.BinderBlockDescriptor;
import is.fivefivefive.CanDis.theory.BinderCoordinateDescriptor;
import is.fivefivefive.CanDis.theory.CertifiedSemanticArtifact;
import is.fivefivefive.CanDis.theory.ContainerLawDeclaration;
import is.fivefivefive.CanDis.theory.TypedPermutation;
import is.fivefivefive.CanDis.theory.TypedSlot;

/**
 * Re-expresses the established repaired-NormalForm metric domain and attaches
 * scope/container legality obtained from the faithful certified artifact.
 */
public final class RepairProjection {
    public static final String VERSION = "faithful-legacy-repair-projection-v6";

    private RepairProjection() {
    }

    public static RepairView project(
            CertifiedSemanticArtifact artifact,
            List<NormalForm> normalForms,
            List<BinderBlockDescriptor> phaseDescriptors,
            List<? extends List<Integer>> phaseSourceCoordinates,
            Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors,
            Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates,
            String certifiedDigest) {
        Objects.requireNonNull(artifact, "artifact");
        Objects.requireNonNull(normalForms, "normalForms");
        Objects.requireNonNull(phaseDescriptors, "phaseDescriptors");
        Objects.requireNonNull(phaseSourceCoordinates, "phaseSourceCoordinates");
        Objects.requireNonNull(localBinderDescriptors, "localBinderDescriptors");
        Objects.requireNonNull(
                localBinderSourceCoordinates, "localBinderSourceCoordinates");
        if (normalForms.size() != phaseDescriptors.size()
                || normalForms.size() != phaseSourceCoordinates.size()) {
            throw new IllegalArgumentException(
                    "Every repaired normal-form phase requires one certified binder plan");
        }

        CertifiedContainers containers = CertifiedContainers.from(artifact);
        OriginIndex origins = new OriginIndex(
                normalForms, phaseDescriptors, phaseSourceCoordinates);
        List<Phase> phases = new ArrayList<>(normalForms.size());
        for (int phaseIndex = 0; phaseIndex < normalForms.size(); phaseIndex++) {
            phases.add(projectPhase(
                    normalForms.get(phaseIndex),
                    phaseIndex,
                    phaseDescriptors,
                    phaseSourceCoordinates,
                    localBinderDescriptors,
                    localBinderSourceCoordinates,
                    origins,
                    containers));
        }
        return new RepairView(
                temporalTree(normalForms), phases, certifiedDigest);
    }

    private static Phase projectPhase(
            NormalForm normalForm,
            int phaseIndex,
            List<BinderBlockDescriptor> descriptors,
            List<? extends List<Integer>> sourceCoordinates,
            Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors,
            Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates,
            OriginIndex origins,
            CertifiedContainers containers) {
        List<Binding> bindings = new ArrayList<>();
        Map<String, Integer> aliases = new LinkedHashMap<>();

        List<QuantiVar> parameters = normalForm.getParams();
        for (int index = 0; index < parameters.size(); index++) {
            QuantiVar variable = parameters.get(index);
            Declaration declaration = sourceDeclaration(
                    variable,
                    "parameter:" + normalizeType(variable.getCarrierTypeName()),
                    -1,
                    Collections.emptyList());
            addBinding(
                    bindings,
                    aliases,
                    variable,
                    new Binding(
                            BindingRole.PARAMETER,
                            index,
                            -1,
                            -1,
                            declaration,
                            variable.getBindingPath(),
                            Collections.emptyList()));
        }

        BinderBlockDescriptor descriptor = descriptors.get(phaseIndex);
        List<Integer> coordinateMap = sourceCoordinates.get(phaseIndex);
        List<QuantiVar> quantified = normalForm.getMatrixQuantiVars();
        requireDescriptorMatches(quantified, descriptor, coordinateMap, phaseIndex);
        List<Declaration> quantifiers = new ArrayList<>(quantified.size());
        for (int index = 0; index < quantified.size(); index++) {
            QuantiVar variable = quantified.get(index);
            int coordinate = coordinateMap.get(index);
            Declaration declaration = certifiedDeclaration(
                    variable, descriptor, coordinate);
            quantifiers.add(declaration);
            addBinding(
                    bindings,
                    aliases,
                    variable,
                    new Binding(
                            BindingRole.MATRIX,
                            index,
                            phaseIndex,
                            coordinate,
                            declaration,
                            variable.getBindingPath(),
                            certifiedOrbit(descriptor, coordinate)));
        }

        List<QuantiVar> inherited = normalForm.getInheritedQuantiVars();
        for (int index = 0; index < inherited.size(); index++) {
            QuantiVar variable = inherited.get(index);
            Origin origin = origins.find(variable);
            Declaration declaration = certifiedDeclaration(
                    variable, descriptors.get(origin.phase), origin.coordinate);
            addBinding(
                    bindings,
                    aliases,
                    variable,
                    new Binding(
                            BindingRole.INHERITED,
                            index,
                            origin.phase,
                            origin.coordinate,
                            declaration,
                            variable.getBindingPath(),
                            certifiedOrbit(descriptors.get(origin.phase), origin.coordinate)));
        }

        Node matrix = projectNode(
                normalForm.getMatrixEGraph(),
                aliases,
                Collections.emptyMap(),
                0,
                localBinderDescriptors,
                localBinderSourceCoordinates,
                containers);
        return new Phase(quantifiers, bindings, matrix);
    }

    private static void addBinding(
            List<Binding> bindings,
            Map<String, Integer> aliases,
            QuantiVar variable,
            Binding binding) {
        int index = bindings.size();
        bindings.add(binding);
        putAlias(aliases, variable.getName(), index);
        for (String alias : variable.getOriginalNames()) {
            putAlias(aliases, alias, index);
        }
        putAlias(aliases, variable.getDeBruijnKey(), index);
    }

    private static void putAlias(Map<String, Integer> aliases, String name, int index) {
        if (name != null && !name.isEmpty()) {
            aliases.put(name, index);
        }
    }

    private static Node projectNode(
            EGraphNode source,
            Map<String, Integer> aliases,
            Map<String, String> localAliases,
            int localDepth,
            Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors,
            Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates,
            CertifiedContainers containers) {
        if (source == null) {
            return null;
        }
        if (isLocalBinder(source)) {
            return projectLocalBinder(
                    source,
                    aliases,
                    localAliases,
                    localDepth,
                    localBinderDescriptors,
                    localBinderSourceCoordinates,
                    containers);
        }
        return projectOrdinaryNode(
                source,
                aliases,
                localAliases,
                localDepth,
                localBinderDescriptors,
                localBinderSourceCoordinates,
                containers,
                false);
    }

    private static Node projectLocalBinder(
            EGraphNode source,
            Map<String, Integer> aliases,
            Map<String, String> localAliases,
            int localDepth,
            Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors,
            Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates,
            CertifiedContainers containers) {
        BinderBlockDescriptor descriptor = localBinderDescriptors.get(source);
        Map<String, Integer> sourceCoordinates = localBinderSourceCoordinates.get(source);
        if (descriptor == null || sourceCoordinates == null) {
            throw new IllegalStateException(
                    "A projected local binder lacks its certified coordinate plan");
        }
        if (!descriptor.hasCertifiedAutomorphisms()) {
            throw new IllegalStateException(
                    "A projected local binder has uncertified automorphisms");
        }

        List<Node> alternatives = new ArrayList<>();
        for (TypedPermutation permutation : descriptor.automorphisms().elements()) {
            Map<String, String> scopedAliases = new LinkedHashMap<>(localAliases);
            for (Map.Entry<String, Integer> entry : sourceCoordinates.entrySet()) {
                int target = permutedCoordinate(
                        descriptor, permutation, entry.getValue());
                scopedAliases.put(
                        entry.getKey(),
                        "@local[" + localDepth + ":" + target + "]");
            }
            Node alternative = projectOrdinaryNode(
                    source,
                    aliases,
                    scopedAliases,
                    localDepth + 1,
                    localBinderDescriptors,
                    localBinderSourceCoordinates,
                    containers,
                    true);
            boolean duplicate = false;
            for (Node retained : alternatives) {
                if (sameProjectedNode(retained, alternative)) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                alternatives.add(alternative);
            }
        }
        if (alternatives.isEmpty()) {
            throw new IllegalStateException(
                    "A certified local binder has no automorphism alternatives");
        }
        Node primary = alternatives.get(0);
        if (alternatives.size() == 1) {
            return primary;
        }
        return new Node(
                primary.operator(),
                primary.payload(),
                primary.lexicalVariable(),
                primary.bindingIndex(),
                primary.containerKind(),
                primary.orderInsensitive(),
                primary.children(),
                alternatives);
    }

    private static int permutedCoordinate(
            BinderBlockDescriptor descriptor,
            TypedPermutation permutation,
            int sourceCoordinate) {
        if (sourceCoordinate < 0 || sourceCoordinate >= descriptor.coordinates().size()) {
            throw new IllegalStateException(
                    "A local source coordinate is outside its certified descriptor");
        }
        TypedSlot target = permutation.apply(
                descriptor.coordinates().get(sourceCoordinate).canonicalSlot());
        for (int index = 0; index < descriptor.coordinates().size(); index++) {
            if (descriptor.coordinates().get(index).canonicalSlot().equals(target)) {
                return index;
            }
        }
        throw new IllegalStateException(
                "A local automorphism maps outside its certified descriptor");
    }

    private static Node projectOrdinaryNode(
            EGraphNode source,
            Map<String, Integer> aliases,
            Map<String, String> localAliases,
            int localDepth,
            Map<EGraphNode, BinderBlockDescriptor> localBinderDescriptors,
            Map<EGraphNode, Map<String, Integer>> localBinderSourceCoordinates,
            CertifiedContainers containers,
            boolean mergeLocalDeclarations) {
        ContainerKind containerKind = containerKind(source);
        if (!source.isFlexibleArity() && source.isOrderInsensitive()
                && !isCertifiedFixedCommutative(source.getOpcode())) {
            throw new IllegalStateException(
                    "No Alloy signature certificate for fixed commutativity of "
                            + source.getOpcode());
        }
        if (containerKind == ContainerKind.BAG
                || containerKind == ContainerKind.SET) {
            containers.require(sourceSymbol(source), containerKind);
        }
        List<Node> children = new ArrayList<>(source.getChildren().size());
        for (EGraphNode child : source.getChildren()) {
            Node projected = projectNode(
                    child,
                    aliases,
                    localAliases,
                    localDepth,
                    localBinderDescriptors,
                    localBinderSourceCoordinates,
                    containers);
            if (mergeLocalDeclarations
                    && isMergeableLocalDeclaration(child.getOpcode())
                    && !children.isEmpty()
                    && canMergeLocalDeclarations(
                            children.get(children.size() - 1), projected)) {
                children.set(
                        children.size() - 1,
                        mergeLocalDeclarations(children.get(children.size() - 1), projected));
            } else {
                children.add(projected);
            }
        }
        if (containerKind == ContainerKind.SET && children.size() > 1) {
            children = deduplicateSetChildren(children);
        }

        String operator = source.getOpcode().name();
        String payload = repairPayload(source);
        if (source.getOpcode() != Opcode.VARIABLE) {
            return new Node(
                    operator, payload, null, -1, containerKind,
                    source.isOrderInsensitive(), children);
        }

        String variable = firstNonempty(source.getAlphaName(), source.getSourceName());
        String localVariable = localAliases.get(variable);
        if (localVariable == null && source.getSourceName() != null) {
            localVariable = localAliases.get(source.getSourceName());
        }
        if (localVariable != null) {
            return new Node(operator, null, localVariable, -1, containerKind,
                    source.isOrderInsensitive(), children);
        }
        Integer bindingIndex = aliases.get(variable);
        if (bindingIndex == null && source.getSourceName() != null) {
            bindingIndex = aliases.get(source.getSourceName());
        }
        return bindingIndex == null
                ? new Node(operator, null, variable, -1, containerKind,
                        source.isOrderInsensitive(), children)
                : new Node(operator, null, variable, bindingIndex, containerKind,
                        source.isOrderInsensitive(), children);
    }

    private static boolean isLocalBinder(EGraphNode node) {
        switch (node.getOpcode()) {
            case SUM:
            case COMPREHENSION:
            case FORALL:
            case EXISTS:
            case NO:
            case ONE:
            case LONE:
                for (EGraphNode child : node.getChildren()) {
                    if (isRelDecl(child.getOpcode())) {
                        return true;
                    }
                }
                return false;
            default:
                return false;
        }
    }

    private static boolean isRelDecl(Opcode opcode) {
        return opcode == Opcode.GENERICRELDECL || opcode == Opcode.DISJ
                || opcode == Opcode.VAR || opcode == Opcode.DISJVAR;
    }

    private static boolean isMergeableLocalDeclaration(Opcode opcode) {
        return opcode == Opcode.GENERICRELDECL || opcode == Opcode.VAR;
    }

    private static boolean canMergeLocalDeclarations(Node left, Node right) {
        return left != null
                && right != null
                && left.operator().equals(right.operator())
                && ("GENERICRELDECL".equals(left.operator())
                        || "VAR".equals(left.operator()))
                && !left.children().isEmpty()
                && !right.children().isEmpty()
                && sameProjectedNode(left.children().get(0), right.children().get(0));
    }

    private static Node mergeLocalDeclarations(Node left, Node right) {
        List<Node> children = new ArrayList<>(left.children());
        children.addAll(right.children().subList(1, right.children().size()));
        return new Node(
                left.operator(),
                left.payload(),
                left.lexicalVariable(),
                left.bindingIndex(),
                left.containerKind(),
                left.orderInsensitive(),
                children);
    }

    private static boolean sameProjectedNode(Node left, Node right) {
        if (!left.alphaAlternatives().isEmpty()
                || !right.alphaAlternatives().isEmpty()) {
            List<Node> leftAlternatives = left.alphaAlternatives().isEmpty()
                    ? List.of(left)
                    : left.alphaAlternatives();
            List<Node> rightAlternatives = right.alphaAlternatives().isEmpty()
                    ? List.of(right)
                    : right.alphaAlternatives();
            for (Node leftAlternative : leftAlternatives) {
                for (Node rightAlternative : rightAlternatives) {
                    if (sameProjectedNode(leftAlternative, rightAlternative)) {
                        return true;
                    }
                }
            }
            return false;
        }
        if (!left.operator().equals(right.operator())
                || !Objects.equals(left.payload(), right.payload())
                || !Objects.equals(left.lexicalVariable(), right.lexicalVariable())
                || left.bindingIndex() != right.bindingIndex()
                || left.containerKind() != right.containerKind()
                || left.orderInsensitive() != right.orderInsensitive()
                || left.children().size() != right.children().size()) {
            return false;
        }
        for (int index = 0; index < left.children().size(); index++) {
            if (!sameProjectedNode(
                    left.children().get(index), right.children().get(index))) {
                return false;
            }
        }
        return true;
    }

    private static List<Node> deduplicateSetChildren(List<Node> children) {
        List<Node> result = new ArrayList<>(children.size());
        for (Node candidate : children) {
            boolean duplicate = false;
            for (Node retained : result) {
                if (sameProjectedNode(retained, candidate)) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                result.add(candidate);
            }
        }
        return result;
    }

    private static ContainerKind containerKind(EGraphNode node) {
        if (!node.isFlexibleArity()) {
            return node.getChildren().size() == 1
                    ? ContainerKind.ONE
                    : ContainerKind.SEQUENCE;
        }
        FlexibleArityKind kind = node.getFlexibleArityKind();
        switch (kind) {
            case SET:
                return ContainerKind.SET;
            case BAG:
                return ContainerKind.BAG;
            case SEQUENCE:
                return ContainerKind.SEQUENCE;
            default:
                throw new IllegalStateException("FIXED node was marked flexible");
        }
    }

    private static boolean isCertifiedFixedCommutative(Opcode opcode) {
        return opcode == Opcode.IFF
                || opcode == Opcode.EQUALS
                || opcode == Opcode.NOT_EQUALS;
    }

    private static String repairPayload(EGraphNode node) {
        switch (node.getOpcode()) {
            case GLOBALBINDING:
            case CONSTANT:
            case REF:
                return node.getSourceName();
            default:
                return null;
        }
    }

    private static Declaration sourceDeclaration(
            QuantiVar variable,
            String domain,
            int exchangeClass,
            List<Integer> dependencies) {
        return new Declaration(
                variable.getQuantifier().name(),
                normalizeType(variable.getTypeName()),
                variable.getCardinality().name(),
                variable.getDisjointnessClass(),
                domain,
                exchangeClass,
                dependencies);
    }

    private static Declaration certifiedDeclaration(
            QuantiVar variable,
            BinderBlockDescriptor descriptor,
            int coordinateIndex) {
        BinderCoordinateDescriptor coordinate = descriptor.coordinates().get(coordinateIndex);
        Map<TypedSlot, Integer> indices = coordinateIndices(descriptor);
        List<Integer> dependencies = new ArrayList<>(coordinate.dependencies().size());
        for (TypedSlot dependency : coordinate.dependencies()) {
            Integer index = indices.get(dependency);
            if (index == null) {
                throw new IllegalStateException(
                        "A certified binder dependency escaped its descriptor");
            }
            dependencies.add(index);
        }
        return sourceDeclaration(
                variable,
                coordinate.domain().stableString(),
                coordinate.exchangeClass(),
                dependencies);
    }

    private static Map<TypedSlot, Integer> coordinateIndices(
            BinderBlockDescriptor descriptor) {
        Map<TypedSlot, Integer> result = new HashMap<>();
        for (int index = 0; index < descriptor.coordinates().size(); index++) {
            result.put(descriptor.coordinates().get(index).canonicalSlot(), index);
        }
        return result;
    }

    private static List<Integer> certifiedOrbit(
            BinderBlockDescriptor descriptor,
            int coordinateIndex) {
        TypedSlot coordinate = descriptor.coordinates().get(coordinateIndex).canonicalSlot();
        Map<TypedSlot, Integer> indices = coordinateIndices(descriptor);
        Set<Integer> orbit = new LinkedHashSet<>();
        for (TypedPermutation action : descriptor.automorphisms().elements()) {
            Integer image = indices.get(action.apply(coordinate));
            if (image == null) {
                throw new IllegalStateException(
                        "A certified binder automorphism escaped its descriptor");
            }
            orbit.add(image);
        }
        List<Integer> result = new ArrayList<>(orbit);
        Collections.sort(result);
        return result;
    }

    private static void requireDescriptorMatches(
            List<QuantiVar> variables,
            BinderBlockDescriptor descriptor,
            List<Integer> sourceCoordinates,
            int phaseIndex) {
        if (variables.size() != descriptor.coordinates().size()
                || variables.size() != sourceCoordinates.size()) {
            throw new IllegalStateException(
                    "Certified binder arity differs from repaired phase " + phaseIndex);
        }
        boolean[] seenCoordinates = new boolean[variables.size()];
        Map<Integer, Integer> disjointnessClasses = new LinkedHashMap<>();
        for (int index = 0; index < variables.size(); index++) {
            QuantiVar variable = variables.get(index);
            int coordinateIndex = sourceCoordinates.get(index);
            if (coordinateIndex < 0 || coordinateIndex >= variables.size()
                    || seenCoordinates[coordinateIndex]) {
                throw new IllegalStateException(
                        "Certified source-coordinate map is not a permutation in phase "
                                + phaseIndex);
            }
            seenCoordinates[coordinateIndex] = true;
            BinderCoordinateDescriptor coordinate = descriptor.coordinates().get(
                    coordinateIndex);
            int sourceDisjointness = variable.getDisjointnessClass();
            int certifiedDisjointness = coordinate.disjointnessClass();
            boolean matchingDisjointness;
            if (sourceDisjointness <= 0) {
                matchingDisjointness = certifiedDisjointness
                        == BinderCoordinateDescriptor.NO_DISJOINTNESS_CLASS;
            } else {
                Integer prior = disjointnessClasses.putIfAbsent(
                        sourceDisjointness, certifiedDisjointness);
                matchingDisjointness = certifiedDisjointness >= 0
                        && (prior == null || prior == certifiedDisjointness);
            }
            if (!variable.getQuantifier().name().equals(coordinate.quantifier())
                    || !variable.getCardinality().name().equals(coordinate.multiplicity())
                    || !matchingDisjointness) {
                throw new IllegalStateException(
                        "Certified binder payload differs from repaired phase "
                                + phaseIndex + " coordinate " + index);
            }
        }
        requireLegacyAlignmentSpaceCertified(descriptor, phaseIndex);
    }

    /**
     * The established metric permits every permutation inside one compatible
     * declaration class. Prove that this entire space is present in Aut(beta)
     * before exposing it to the pairwise alpha search.
     */
    private static void requireLegacyAlignmentSpaceCertified(
            BinderBlockDescriptor descriptor,
            int phaseIndex) {
        if (!descriptor.hasCertifiedAutomorphisms()) {
            throw new IllegalStateException(
                    "Repair phase " + phaseIndex
                            + " has uncertified binder automorphisms");
        }
        List<BinderCoordinateDescriptor> coordinates = descriptor.coordinates();
        List<List<Integer>> classes = new ArrayList<>();
        for (int index = 0; index < coordinates.size(); index++) {
            boolean placed = false;
            for (List<Integer> group : classes) {
                if (sameAlignmentPayload(
                        coordinates.get(group.get(0)), coordinates.get(index))) {
                    group.add(index);
                    placed = true;
                    break;
                }
            }
            if (!placed) {
                List<Integer> group = new ArrayList<>();
                group.add(index);
                classes.add(group);
            }
        }
        for (List<Integer> group : classes) {
            for (int index = 1; index < group.size(); index++) {
                TypedPermutation adjacentSwap = coordinateSwap(
                        descriptor, group.get(index - 1), group.get(index));
                if (!descriptor.automorphisms().contains(adjacentSwap)) {
                    throw new IllegalStateException(
                            "Certified binder group for repair phase " + phaseIndex
                                    + " is narrower than the established metric's "
                                    + "declaration-permutation space");
                }
            }
        }
    }

    private static boolean sameAlignmentPayload(
            BinderCoordinateDescriptor left,
            BinderCoordinateDescriptor right) {
        return left.type().equals(right.type())
                && left.domain().equals(right.domain())
                && left.quantifier().equals(right.quantifier())
                && left.multiplicity().equals(right.multiplicity())
                && left.disjointnessClass() == right.disjointnessClass()
                && left.exchangeClass() == right.exchangeClass()
                && left.dependencies().equals(right.dependencies());
    }

    private static TypedPermutation coordinateSwap(
            BinderBlockDescriptor descriptor,
            int leftIndex,
            int rightIndex) {
        Map<TypedSlot, TypedSlot> mapping = new LinkedHashMap<>();
        for (TypedSlot slot : descriptor.boundContext()) {
            mapping.put(slot, slot);
        }
        TypedSlot left = descriptor.coordinates().get(leftIndex).canonicalSlot();
        TypedSlot right = descriptor.coordinates().get(rightIndex).canonicalSlot();
        mapping.put(left, right);
        mapping.put(right, left);
        return TypedPermutation.of(descriptor.boundContext(), mapping);
    }

    private static TemporalNode temporalTree(List<NormalForm> normalForms) {
        List<TemporalNode> children = normalForms.isEmpty()
                ? Collections.emptyList()
                : temporalChildren(normalForms.get(0).getTemporalChildren());
        return new TemporalNode(naturalTemporalLabel(TemporalOp.NONE), children);
    }

    private static TemporalNode temporalTree(NormalForm normalForm) {
        return new TemporalNode(
                naturalTemporalLabel(normalForm.getTemporalOp()),
                temporalChildren(normalForm.getTemporalChildren()));
    }

    private static List<TemporalNode> temporalChildren(List<NormalForm> children) {
        List<TemporalNode> result = new ArrayList<>();
        for (int index = 0; index < children.size(); index++) {
            NormalForm child = children.get(index);
            if (isBinaryLeft(child.getTemporalOp())
                    && index + 1 < children.size()
                    && matchingRight(child.getTemporalOp())
                            == children.get(index + 1).getTemporalOp()) {
                List<TemporalNode> binaryChildren = new ArrayList<>();
                binaryChildren.addAll(temporalChildren(child.getTemporalChildren()));
                binaryChildren.addAll(temporalChildren(
                        children.get(index + 1).getTemporalChildren()));
                result.add(new TemporalNode(
                        naturalTemporalLabel(child.getTemporalOp()), binaryChildren));
                index++;
            } else {
                result.add(temporalTree(child));
            }
        }
        return result;
    }

    private static boolean isBinaryLeft(TemporalOp operation) {
        return operation == TemporalOp.UNTILL
                || operation == TemporalOp.RELEASESL
                || operation == TemporalOp.SINCEL
                || operation == TemporalOp.TRIGGEREDL;
    }

    private static TemporalOp matchingRight(TemporalOp operation) {
        switch (operation) {
            case UNTILL:
                return TemporalOp.UNTILR;
            case RELEASESL:
                return TemporalOp.RELEASESR;
            case SINCEL:
                return TemporalOp.SINCER;
            case TRIGGEREDL:
                return TemporalOp.TRIGGEREDR;
            default:
                return operation;
        }
    }

    private static String naturalTemporalLabel(TemporalOp operation) {
        switch (operation) {
            case UNTILL:
            case UNTILR:
                return "UNTIL";
            case RELEASESL:
            case RELEASESR:
                return "RELEASES";
            case SINCEL:
            case SINCER:
                return "SINCE";
            case TRIGGEREDL:
            case TRIGGEREDR:
                return "TRIGGERED";
            default:
                return operation.name();
        }
    }

    private static String sourceSymbol(EGraphNode node) {
        StringBuilder result = new StringBuilder("ALLOY/").append(node.getOpcode());
        switch (node.getOpcode()) {
            case CONSTANT:
            case GLOBALBINDING:
            case CALL:
            case SHADOW:
                result.append('/').append(normalizeAtom(node.getSourceName()));
                break;
            default:
                break;
        }
        return result.toString();
    }

    private static String normalizeAtom(String value) {
        return value == null
                ? ""
                : value.replace("this/", "").replaceAll("\\s+", "").trim();
    }

    private static String normalizeType(String type) {
        if (type == null || type.isEmpty()) {
            return "univ";
        }
        return type.startsWith("VAR_") ? type.substring(4) : type;
    }

    private static String firstNonempty(String first, String second) {
        return first != null && !first.isEmpty() ? first : second;
    }

    private static final class Origin {
        private final int phase;
        private final int coordinate;

        private Origin(int phase, int coordinate) {
            this.phase = phase;
            this.coordinate = coordinate;
        }
    }

    private static final class OriginIndex {
        private final IdentityHashMap<QuantiVar, Origin> identities = new IdentityHashMap<>();
        private final Map<Integer, Origin> ids = new HashMap<>();
        private final Map<String, Origin> deBruijn = new HashMap<>();

        private OriginIndex(
                List<NormalForm> normalForms,
                List<BinderBlockDescriptor> descriptors,
                List<? extends List<Integer>> sourceCoordinates) {
            for (int phase = 0; phase < normalForms.size(); phase++) {
                List<QuantiVar> variables = normalForms.get(phase).getMatrixQuantiVars();
                List<Integer> coordinateMap = sourceCoordinates.get(phase);
                requireDescriptorMatches(
                        variables, descriptors.get(phase), coordinateMap, phase);
                for (int source = 0; source < variables.size(); source++) {
                    QuantiVar variable = variables.get(source);
                    Origin origin = new Origin(phase, coordinateMap.get(source));
                    identities.put(variable, origin);
                    ids.putIfAbsent(variable.getId(), origin);
                    deBruijn.putIfAbsent(variable.getDeBruijnKey(), origin);
                }
            }
        }

        private Origin find(QuantiVar variable) {
            Origin result = identities.get(variable);
            if (result == null) {
                result = ids.get(variable.getId());
            }
            if (result == null) {
                result = deBruijn.get(variable.getDeBruijnKey());
            }
            if (result == null) {
                throw new IllegalStateException(
                        "An inherited repaired binding has no certified owner phase");
            }
            return result;
        }
    }

    private static final class CertifiedContainers {
        private final Map<String, Set<ContainerKind>> kinds = new HashMap<>();

        private static CertifiedContainers from(CertifiedSemanticArtifact artifact) {
            CertifiedContainers result = new CertifiedContainers();
            for (Map.Entry<String, List<ContainerLawDeclaration>> entry
                    : artifact.containerLaws().entrySet()) {
                for (ContainerLawDeclaration declaration : entry.getValue()) {
                    result.kinds.computeIfAbsent(
                            entry.getKey(), ignored -> new LinkedHashSet<>())
                            .add(portKind(declaration.kind()));
                }
            }
            return result;
        }

        private static ContainerKind portKind(ContainerLawDeclaration.Kind kind) {
            switch (kind) {
                case SEQ:
                    return ContainerKind.SEQUENCE;
                case BAG:
                    return ContainerKind.BAG;
                case SET:
                    return ContainerKind.SET;
                default:
                    throw new IllegalStateException(
                            "A certified container registry contains " + kind);
            }
        }

        private void require(String symbol, ContainerKind expected) {
            Set<ContainerKind> certified = kinds.get(symbol);
            if (certified == null || !certified.contains(expected)) {
                throw new IllegalStateException(
                        "The repair projection requested an uncertified "
                                + expected + " law for " + symbol);
            }
        }
    }
}
