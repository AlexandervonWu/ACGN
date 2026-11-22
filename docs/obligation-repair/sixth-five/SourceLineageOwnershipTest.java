package is.fivefivefive.CanDis.theory;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.ir.IRAgent;
import parser.ast.nodes.ModelUnit;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/** Checks premises of SourceLineageOwnership against public producer operations. */
public final class SourceLineageOwnershipTest {
    private static final SemanticProfile PROFILE = SemanticProfile.alloyOverflowForbidding();
    private static final String FOREIGN = "A dependent certificate was attached to another source lineage";
    private static int nextId;

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static void rejects(Runnable action, Class<? extends RuntimeException> kind, String message) {
        try {
            action.run();
        } catch (RuntimeException error) {
            if (error.getClass() == kind && message.equals(error.getMessage())) return;
            throw new AssertionError("Unexpected rejection", error);
        }
        throw new AssertionError("Accepted control: " + message);
    }

    private static EGraphNode node(Opcode opcode, int width, EGraphNode... children) {
        boolean flexible = opcode == Opcode.AND;
        var n = new EGraphNode(nextId++, opcode, new ArrayList<>(), flexible,
                flexible ? -1 : children.length, flexible, width == 0 ? Metatype.BOOLEAN : Metatype.SET, PROFILE);
        n.setExactAlloyType(width == 0 ? ExactAlloyType.boolType()
                : ExactAlloyType.relation(Collections.nCopies(width, "A")));
        for (EGraphNode child : children) n.addChild(child);
        return n;
    }

    private static EGraphNode atom(String name) {
        EGraphNode n = node(Opcode.GLOBALBINDING, 1);
        n.setSourceName(name);
        n.setSourceType(name);
        return n;
    }

    private static EGraphNode chain() {
        return node(Opcode.ARROW, 3, node(Opcode.ARROW, 2, atom("a"), atom("b")), atom("c"));
    }

    private static NormalForm form(EGraphNode root) {
        NormalForm f = new NormalForm();
        f.addEClass(root);
        return f;
    }

    private static void allocationsAndSiblings() {
        EGraphNode.beginGraph();
        try {
            long previous = 0;
            for (int i = 0; i < 64; i++) {
                long next = atom("equal").getSourceOccurrenceLineage();
                require(next > previous, "Fresh even for repeated payloads");
                previous = next;
            }
            EGraphNode left = chain(), right = chain();
            NormalForm f = form(node(Opcode.AND, 0, node(Opcode.SOME, 0, left), node(Opcode.SOME, 0, right)));
            var bindings = TheoryAlloyAdapter.adapt(List.of(f), PROFILE).dependentChainSourceBindings();
            require(bindings.size() == 2 && left != right, "Two different original owners");
            var first = bindings.get(left);
            var second = bindings.get(right);
            require(first.sourceOccurrencePath().equals("phase/0/matrix/child/0/child/0")
                    && second.sourceOccurrencePath().equals("phase/0/matrix/child/1/child/0"),
                    "Independent ordered child coordinates");
            require(left.getSourceOccurrenceLineage() != right.getSourceOccurrenceLineage()
                    && left.dependentChainSourceContentCommitment().equals(right.dependentChainSourceContentCommitment())
                    && !first.sourceOccurrenceCommitment().equals(second.sourceOccurrenceCommitment()),
                    "Equal contents and distinct committed owners");
            first.requireMatches(left);
            second.requireMatches(right);
            rejects(() -> first.requireMatches(right), IllegalStateException.class, FOREIGN);
            rejects(() -> second.requireMatches(left), IllegalStateException.class, FOREIGN);
        } finally {
            EGraphNode.endGraph();
        }
    }

    private static void reseedAndFreeze() {
        EGraphNode.beginGraph();
        try {
            EGraphNode original = chain();
            long initial = original.getSourceOccurrenceLineage();
            NormalForm f = form(node(Opcode.SOME, 0, original));
            f.normalize();
            EGraphNode retained = f.getCertificationMatrixEGraph().getChildren().get(0);
            EGraphNode repaired = f.getMatrixEGraph().getChildren().get(0);
            var result = TheoryAlloyAdapter.adapt(List.of(f), PROFILE);
            var binding = result.dependentChainSourceBindings().get(repaired);
            require(retained != repaired && retained.getSourceOccurrenceLineage() > initial
                    && retained.getSourceOccurrenceLineage() == repaired.getSourceOccurrenceLineage(),
                    "Reseed followed by an authorized copy");
            require(retained.isFrozenForCertification() && repaired.isFrozenForCertification()
                    && f.isFrozenForCertification(), "Frozen retained and repaired trees");
            binding.requireMatches(retained);
            binding.requireMatches(repaired);
            rejects(() -> retained.setSourceName("replacement"), IllegalStateException.class,
                    "A certified Fast Rewrite source e-graph is immutable");
            result.requireRepairProjectionSources(List.of(f));
            rejects(() -> result.requireRepairProjectionSources(List.of(new NormalForm())), IllegalArgumentException.class,
                    "Repair projection source identity differs at phase 0");
        } finally {
            EGraphNode.endGraph();
        }
    }

    private static void phasePermutation() throws Exception {
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP,
                "sig A { r: set A } pred p { some (r.r) and after some (r.r) }");
        MASGVisitor visitor = new MASGVisitor(new GlobalVariables(), module);
        visitor.visit(new ModelUnit(null, module), null);
        IRAgent agent = new IRAgent(visitor.getForest().get(visitor.getForestId("p")), PROFILE);
        agent.computeNormalForm();
        var phases = agent.normalForms();
        var result = TheoryAlloyAdapter.adapt(phases, PROFILE);
        var ordered = new ArrayList<>(result.dependentChainSourceBindings().entrySet());
        ordered.sort(Comparator.comparing(e -> e.getValue().sourceOccurrencePath()));
        require(phases.size() == 2 && ordered.size() == 2
                && ordered.get(0).getValue().sourceOccurrencePath().startsWith("phase/0/matrix/")
                && ordered.get(1).getValue().sourceOccurrencePath().startsWith("phase/1/matrix/"),
                "Distinct ordered phase roots");
        rejects(() -> ordered.get(0).getValue().requireMatches(ordered.get(1).getKey()),
                IllegalStateException.class, FOREIGN);
        result.requireRepairProjectionSources(phases);
        rejects(() -> result.requireRepairProjectionSources(List.of(phases.get(1), phases.get(0))),
                IllegalArgumentException.class, "Repair projection source identity differs at phase 0");
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 0) throw new IllegalArgumentException("No arguments expected");
        allocationsAndSiblings();
        reseedAndFreeze();
        phasePermutation();
        System.out.println("A2-14 ownership checks passed: allocation, sibling swap, authorized copy, frozen source, phase swap");
    }
}
