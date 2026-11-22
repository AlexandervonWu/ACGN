package is.fivefivefive.CanDis;

import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.metric.RepairProjection;
import is.fivefivefive.CanDis.metric.RepairView;
import is.fivefivefive.CanDis.theory.AlloyTypeBridge;
import is.fivefivefive.CanDis.theory.GraphType;
import is.fivefivefive.CanDis.theory.TheoryAlloyAdapter;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

/** Public Layer 3 projection versus independently parsed, occurrence-addressed ARROW inputs. */
public final class A217ProjectionTest {
    private static final String BASE = "phase/0/matrix";
    private static final List<String> rows = new ArrayList<>(List.of(
            "fixture\tcheck\tchain\tindex\tsource_address\tfield\tresult"));

    private record Selected(String path, EGraphNode node) {}
    private record Sample(Canonical.Prepared prepared, TheoryAlloyAdapter.Result result, RepairView view) {
        static Sample project(RawArrowOccurrenceAuthority.Produced produced) {
            var prepared = produced.prepared();
            var result = produced.result();
            return new Sample(prepared, result, RepairProjection.project(result, prepared.normalizedForms()));
        }
    }

    private static void check(boolean ok, String reason) {
        if (!ok) throw new AssertionError(reason);
    }

    /** Random access from binary source cardinalities, independent of the production collector. */
    private static int width(EGraphNode node) {
        if (node.getOpcode() != Opcode.ARROW) return 1;
        check(node.getChildren().size() == 2, "nonbinary source ARROW");
        return Math.addExact(width(node.getChildren().get(0)), width(node.getChildren().get(1)));
    }

    private static Selected select(String path, EGraphNode node, int ordinal) {
        check(ordinal >= 0 && ordinal < width(node), "index outside source");
        while (node.getOpcode() == Opcode.ARROW) {
            int left = width(node.getChildren().get(0));
            int side = ordinal < left ? 0 : 1;
            if (side == 1) ordinal -= left;
            path += "/child/" + side;
            node = node.getChildren().get(side);
        }
        return new Selected(path, node);
    }

    private static void checkSlot(RawArrowOccurrenceAuthority.Leaf expected, Selected selected,
            RepairView.Node projected, GraphType certified) {
        if (!selected.path().equals(expected.path())) throw new IllegalArgumentException("SOURCE_ADDRESS");
        GraphType type = GraphType.relation(expected.columns().stream()
                .map(c -> GraphType.constructor("AlloySig:" + c)).toList());
        check(selected.node().getOpcode() == Opcode.GLOBALBINDING
                && expected.name().equals(selected.node().getSourceName())
                && type.equals(AlloyTypeBridge.graphType(selected.node().getExactAlloyType()))
                && type.equals(certified), "wrong source or certificate leaf");
        if (!"GLOBALBINDING".equals(projected.operator()) || !type.equals(projected.observationType())
                || !expected.name().equals(projected.payload()) || !projected.children().isEmpty())
            throw new IllegalArgumentException("PROJECTED_LEAF");
    }

    private static void control(String label, String caseName, String reason, Runnable action) {
        try {
            action.run();
        } catch (IllegalArgumentException | IllegalStateException e) {
            if (!reason.equals(e.getMessage())) throw e;
            rows.add(String.join("\t", label, caseName, "-", "-", "-", "-", reason));
            return;
        }
        throw new AssertionError("control accepted: " + caseName);
    }

    private static byte[] module(String body) {
        return ("module arrows\nsig A {r,s: set A}\npred selected { " + body + " }\n")
                .getBytes(StandardCharsets.UTF_8);
    }

    private static void fixture(String label, byte[] bytes, List<Integer> widths) throws Exception {
        EGraphNode.beginGraph();
        try {
            RawArrowOccurrenceAuthority raw = RawArrowOccurrenceAuthority.parse(bytes, "arrows/selected");
            var produced = RawArrowOccurrenceAuthority.produce(bytes, raw.root());
            raw.verify(produced);
            Sample sample = Sample.project(produced);
            var phaseSources = sample.view().originalPhaseSources(sample.prepared().normalizedForms());
            check(phaseSources.size() == 1 && sample.view().phases().size() == 1, "wrong phase owner");
            var matrix = phaseSources.get(0).getMatrixEGraph();
            var viewRoot = sample.view().phases().get(0).matrix();
            check(matrix.getOpcode() == Opcode.PREDICATE && matrix.getChildren().size() == 1
                    && viewRoot.operator().equals("PREDICATE") && viewRoot.children().size() == 1,
                    "wrong hypothesis wrapper");
            var body = matrix.getChildren().get(0);
            var viewBody = viewRoot.children().get(0);
            check(body.getOpcode().name().equals(viewBody.operator()) && widths.size() == raw.occurrences().size()
                    && widths.size() == body.getChildren().size() && widths.size() == viewBody.children().size(),
                    "wrong public predicate body");
            for (int arm = 0; arm < widths.size(); arm++) {
                var expected = raw.occurrences().get(arm);
                String rootPath = BASE + "/child/0/child/" + arm;
                EGraphNode source = body.getChildren().get(arm);
                RepairView.Node chain = viewBody.children().get(arm);
                var binding = sample.result().dependentChainSourceBindings().get(source);
                check(binding != null && binding.sourceOccurrencePath().equals(rootPath)
                        && expected.path().equals(rootPath) && source.getOpcode() == Opcode.ARROW,
                        "missing exact source binding");
                binding.requireMatches(source);
                var cert = binding.certificate();
                check(sample.result().semanticArtifact().dependentChainConstructions().stream().anyMatch(c -> c == cert),
                        "certificate outside the immutable artifact");
                check(chain.operator().equals("ARROW") && !chain.orderInsensitive()
                        && chain.containerKind() == RepairView.ContainerKind.SEQUENCE
                        && chain.observationType().equals(cert.target().outputType()),
                        "wrong projected sequence or result type");
                int count = widths.get(arm);
                check(width(source) == count && cert.operandTypes().size() == count
                        && chain.children().size() == count && expected.leaves().size() == count,
                        "wrong occurrence multiplicity");
                List<Selected> indexed = new ArrayList<>();
                for (int i = 0; i < count; i++) {
                    var position = select(rootPath, source, i);
                    var leaf = expected.leaves().get(i);
                    checkSlot(leaf, position, chain.children().get(i), cert.operandTypes().get(i));
                    rows.add(String.join("\t", label, "projected", rootPath, Integer.toString(i),
                            leaf.path(), leaf.name(), chain.children().get(i).observationType().toString()));
                    indexed.add(position);
                }
                if (arm == 0) {
                    check(cert.operandTypes().get(0).equals(cert.operandTypes().get(1))
                            && !chain.children().get(0).payload().equals(chain.children().get(1).payload()),
                            "equal-type swap requires distinct observable names");
                    control(label, "equal-type-projected-swap", "PROJECTED_LEAF", () ->
                            checkSlot(expected.leaves().get(0), indexed.get(0), chain.children().get(1),
                                    cert.operandTypes().get(0)));
                    if (count == 3) {
                        check(indexed.get(0).node().getSourceOccurrenceLineage() != indexed.get(2).node().getSourceOccurrenceLineage()
                                && expected.leaves().get(0).name().equals(expected.leaves().get(2).name()),
                                "repeated leaf fixture requires distinct actual source occurrences");
                        control(label, "equal-name-source-index-swap", "SOURCE_ADDRESS", () ->
                                checkSlot(expected.leaves().get(0), indexed.get(2), chain.children().get(0),
                                        cert.operandTypes().get(0)));
                    }
                    if (widths.size() == 2) {
                        control(label, "sibling-binding", "A dependent certificate was attached to another source lineage",
                                () -> binding.requireMatches(body.getChildren().get(1)));
                    }
                }
            }
            var foreign = RawArrowOccurrenceAuthority.produce(bytes, raw.root());
            control(label, "detached-phase", "Repair projection source identity differs at phase 0",
                    () -> RepairProjection.project(sample.result(), foreign.prepared().normalizedForms()));
        } finally {
            EGraphNode.endGraph();
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) throw new IllegalArgumentException("fresh output TSV required");
        fixture("binary", RawArrowOccurrenceAuthority.fixtureBytes(), List.of(2, 2));
        fixture("opposite-association", module("(r->s)->r in r->(s->r)"), List.of(3, 3));
        fixture("single", module("some (r->s)"), List.of(2));
        Files.write(Path.of(args[0]), rows, StandardCharsets.UTF_8, StandardOpenOption.CREATE_NEW);
        System.out.println("A217ProjectionTest passed: observations=" + (rows.size() - 1));
    }
}
