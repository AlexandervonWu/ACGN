package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;

import is.fivefivefive.CanDis.core.EGraphNode;
import is.fivefivefive.CanDis.core.EGraphNode.Metatype;
import is.fivefivefive.CanDis.core.EGraphNode.Opcode;
import is.fivefivefive.CanDis.core.NormalForm;
import is.fivefivefive.CanDis.core.NormalForm.TemporalOp;
import parser.util.AlloyUtil;

public final class CanonicalBacktranslatorTest {
    private CanonicalBacktranslatorTest() {
    }

    public static void main(String[] args) throws Exception {
        testQuantifiedNormalFormCompiles();
        testDisjointBindingGroupCompiles();
        testTemporalNormalFormCompiles();
        System.out.println("CanonicalBacktranslatorTest passed");
    }

    private static void testQuantifiedNormalFormCompiles() throws Exception {
        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                relDeclOfType("Person", "x"),
                node(Opcode.IN, false, false, variable("x"), global("Student"))));
        normalForm.normalize();

        String module = module("canonical_backtranslation_quantified",
                "sig Person {}\nsig Student in Person {}\n",
                CanonicalBacktranslator.predicate("canonical_quantified", normalForm));
        assertCompiles(module);
        assertContains(module, "pred canonical_quantified[]", "predicate header must be emitted");
        assertContains(module, "all _q0: Person", "canonical quantified variable must be declared");
        assertContains(module, "_q0 in Student", "alpha-normalized variable must be used in the matrix");
    }

    private static void testDisjointBindingGroupCompiles() throws Exception {
        NormalForm normalForm = new NormalForm();
        normalForm.addEClass(node(
                Opcode.FORALL,
                false,
                false,
                disjRelDecl("x", "y"),
                node(Opcode.EQUALS, false, false, variable("x"), variable("y"))));
        normalForm.normalize();

        String module = module("canonical_backtranslation_disj",
                "sig S {}\n",
                CanonicalBacktranslator.predicate("canonical_disj", normalForm));
        assertCompiles(module);
        assertContains(module, "all disj _q0, _q1: S",
                "variables from the same disjointness class must be emitted as one disj declaration");
    }

    private static void testTemporalNormalFormCompiles() throws Exception {
        NormalForm root = new NormalForm();
        NormalForm after = new NormalForm(root, TemporalOp.AFTER, 99);
        root.addTemporalChild(after);
        after.addEClass(node(Opcode.IN, false, false, global("s"), global("S")));
        root.normalize();
        after.normalize();

        String module = module("canonical_backtranslation_temporal",
                "var sig S {}\none sig s in S {}\n",
                CanonicalBacktranslator.predicate("canonical_temporal", Arrays.asList(root, after)));
        assertCompiles(module);
        assertContains(module, "after", "temporal child must be emitted with its temporal operator");
    }

    private static String module(String moduleName, String prelude, String predicate) {
        return "module " + moduleName + "\n\n" + prelude + "\n" + predicate + "\nrun "
                + predicateName(predicate) + " for 3\n";
    }

    private static String predicateName(String predicate) {
        int start = predicate.indexOf("pred ");
        int end = predicate.indexOf("[]", start);
        return predicate.substring(start + "pred ".length(), end).trim();
    }

    private static void assertCompiles(String source) throws Exception {
        Path file = Files.createTempFile("canonical-backtranslation-", ".als");
        Files.writeString(file, source, StandardCharsets.UTF_8);
        AlloyUtil.compileAlloyModule(file.toString());
    }

    private static EGraphNode relDeclOfType(String typeName, String... variableNames) {
        EGraphNode[] children = new EGraphNode[variableNames.length + 1];
        children[0] = global(typeName);
        for (int i = 0; i < variableNames.length; i++) {
            EGraphNode declared = variable(variableNames[i]);
            declared.setSourceType(typeName);
            children[i + 1] = declared;
        }
        return node(Opcode.GENERICRELDECL, true, true, children);
    }

    private static EGraphNode disjRelDecl(String... variableNames) {
        EGraphNode[] children = new EGraphNode[variableNames.length + 1];
        children[0] = global("S");
        for (int i = 0; i < variableNames.length; i++) {
            EGraphNode declared = variable(variableNames[i]);
            declared.setSourceType("S");
            children[i + 1] = declared;
        }
        return node(Opcode.DISJ, true, true, children);
    }

    private static EGraphNode variable(String name) {
        EGraphNode variable = new EGraphNode(name.hashCode(), Opcode.VARIABLE, new ArrayList<>(), false, 0, false,
                Metatype.ATOMIC);
        variable.setSourceName(name);
        variable.setAlphaName(name);
        return variable;
    }

    private static EGraphNode global(String name) {
        EGraphNode binding = new EGraphNode(name.hashCode(), Opcode.GLOBALBINDING, new ArrayList<>(), false, 0,
                false, Metatype.SET);
        binding.setSourceName(name);
        binding.setSourceType(name);
        return binding;
    }

    private static EGraphNode node(
            Opcode opcode,
            boolean commutative,
            boolean flexible,
            EGraphNode... children) {
        return new EGraphNode(
                opcode.hashCode() + children.length,
                opcode,
                new ArrayList<>(Arrays.asList(children)),
                commutative,
                flexible ? -1 : children.length,
                flexible,
                Metatype.BOOLEAN);
    }

    private static void assertContains(String haystack, String needle, String message) {
        if (!haystack.contains(needle)) {
            throw new AssertionError(message + ": missing `" + needle + "` in\n" + haystack);
        }
    }
}
