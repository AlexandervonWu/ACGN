package is.fivefivefive.CanDis.ablation;

import java.util.List;

/** Fast executable regression tests for the three ablation engines. */
public final class EGraphAblationTest {
    private EGraphAblationTest() {
    }

    public static void main(String[] args) {
        AlloyTerm a = AlloyTerm.atom("VAR", "a");
        AlloyTerm b = AlloyTerm.atom("VAR", "b");
        AlloyTerm andAB = AlloyTerm.node("BF/AND", a, b);
        AlloyTerm andBA = AlloyTerm.node("BF/AND", b, a);

        AblationEngine.Result rawOrder = new RawEGraph().compare(andAB, andBA);
        check(!rawOrder.equivalent,
                "raw e-graph must preserve operand order");
        check(rawOrder.distance == 2,
                "raw distance must count both ordered operand replacements");
        AblationEngine.Result eggOrder = new JavaEgglog().compare(andAB, andBA);
        check(eggOrder.equivalent && eggOrder.distance == 0,
                "egglog core must saturate commutativity");

        AlloyTerm pA = AlloyTerm.node("P", a);
        AlloyTerm pB = AlloyTerm.node("P", b);
        check(new RawEGraph().compare(pA, pB).distance == 1,
                "an atom replacement must cost one edit");

        AlloyTerm notAnd = AlloyTerm.node("UF/NOT", andAB);
        AlloyTerm deMorgan = AlloyTerm.node("BF/OR",
                AlloyTerm.node("UF/NOT", a), AlloyTerm.node("UF/NOT", b));
        check(new JavaEgglog().compare(notAnd, deMorgan).equivalent,
                "egglog core must saturate De Morgan");

        AlloyTerm implication = AlloyTerm.node("BF/IMPLIES", a, b);
        AlloyTerm disjunction = AlloyTerm.node("BF/OR", AlloyTerm.node("UF/NOT", a), b);
        AblationEngine.Result implicationResult = new JavaEgglog().compare(implication, disjunction);
        check(implicationResult.equivalent && implicationResult.distance == 0,
                "egglog core must eliminate implication");
        AlloyTerm nearDisjunction = AlloyTerm.node("BOOL/OR",
                AlloyTerm.node("BOOL/NOT", a), AlloyTerm.atom("VAR", "c"));
        check(new JavaEgglog().compare(implication, nearDisjunction).distance == 1,
                "egglog distance must minimize over retained rewrite roots");

        AlloyTerm duplicateAnd = AlloyTerm.node("BF/AND", a, a);
        AlloyTerm duplicateUnion = AlloyTerm.node("BE/PLUS", a, a);
        check(new JavaEgglog().compare(duplicateAnd, a).equivalent,
                "boolean conjunction must be idempotent");
        check(new JavaEgglog().compare(duplicateUnion, a).equivalent,
                "relational union must be idempotent");

        AlloyTerm alphaLeft = predicate("x", AlloyTerm.node("P", AlloyTerm.atom("VAR", "x")));
        AlloyTerm alphaRight = predicate("renamed", AlloyTerm.node("P", AlloyTerm.atom("VAR", "renamed")));
        check(!new JavaEgglog().compare(alphaLeft, alphaRight).equivalent,
                "ordinary e-graph must retain literal identifiers");
        AblationEngine.Result alphaResult = new SlottedEGraph().compare(alphaLeft, alphaRight);
        check(alphaResult.equivalent && alphaResult.distance == 0,
                "slotted e-graph must preserve alpha-equivalence");

        AlloyTerm permutationLeft = quantified(
                "QF/ALL", List.of("x", "y"), "User",
                AlloyTerm.node("F", AlloyTerm.atom("VAR", "x"), AlloyTerm.atom("VAR", "y")));
        AlloyTerm permutationRight = quantified(
                "QF/ALL", List.of("x", "y"), "User",
                AlloyTerm.node("F", AlloyTerm.atom("VAR", "y"), AlloyTerm.atom("VAR", "x")));
        check(new SlottedEGraph().compare(permutationLeft, permutationRight).equivalent,
                "same-declaration formula-quantifier slots must form a permutation group");

        AlloyTerm aliased = quantified(
                "QF/ALL", List.of("x", "y"), "User",
                AlloyTerm.node("F", AlloyTerm.atom("VAR", "x"), AlloyTerm.atom("VAR", "x")));
        AblationEngine.Result aliasResult = new SlottedEGraph().compare(aliased, permutationLeft);
        check(!aliasResult.equivalent && aliasResult.distance > 0,
                "slot shapes must preserve aliasing patterns");

        AlloyTerm shadowed = quantified("QF/ALL", "x", "Outer",
                quantified("QF/SOME", "x", "Inner",
                        AlloyTerm.node("P", AlloyTerm.atom("VAR", "x"))));
        AlloyTerm shadowRenamed = quantified("QF/ALL", "outer", "Outer",
                quantified("QF/SOME", "inner", "Inner",
                        AlloyTerm.node("P", AlloyTerm.atom("VAR", "inner"))));
        AlloyTerm capturesOuter = quantified("QF/ALL", "outer", "Outer",
                quantified("QF/SOME", "inner", "Inner",
                        AlloyTerm.node("P", AlloyTerm.atom("VAR", "outer"))));
        check(new SlottedEGraph().compare(shadowed, shadowRenamed).equivalent,
                "lexically shadowed slots must remain alpha-equivalent");
        check(!new SlottedEGraph().compare(shadowed, capturesOuter).equivalent,
                "inner and outer slots must remain distinct under shadowing");

        AlloyTerm captureUnsafeLet = quantified("QF/ALL", "y", "S",
                AlloyTerm.node("LetExpr",
                        AlloyTerm.atom("VAR", "x"),
                        AlloyTerm.atom("VAR", "y"),
                        AlloyTerm.node("Body", quantified("QF/SOME", "y", "S",
                                AlloyTerm.node("BF/NOT_EQUALS",
                                        AlloyTerm.atom("VAR", "x"), AlloyTerm.atom("VAR", "y"))))));
        AlloyTerm capturedResult = quantified("QF/ALL", "y", "S",
                quantified("QF/SOME", "y", "S",
                        AlloyTerm.node("BF/NOT_EQUALS",
                                AlloyTerm.atom("VAR", "y"), AlloyTerm.atom("VAR", "y"))));
        check(!new JavaEgglog().compare(captureUnsafeLet, capturedResult).equivalent,
                "egglog beta reduction must avoid capture by shadowing quantifiers");

        AlloyTerm simpleLet = AlloyTerm.node("LetExpr",
                AlloyTerm.atom("VAR", "x"), a,
                AlloyTerm.node("Body", AlloyTerm.node("P", AlloyTerm.atom("VAR", "x"))));
        check(new JavaEgglog().compare(simpleLet, AlloyTerm.node("P", a)).equivalent,
                "capture-safe beta reduction must still eliminate ordinary lets");

        AlloyTerm comprehensionLeft = comprehension(
                AlloyTerm.node("BF/IN", AlloyTerm.atom("VAR", "y"),
                        AlloyTerm.node("BE/JOIN", AlloyTerm.atom("VAR", "x"), AlloyTerm.atom("FIELD", "r"))));
        AlloyTerm comprehensionRight = comprehension(
                AlloyTerm.node("BF/IN", AlloyTerm.atom("VAR", "x"),
                        AlloyTerm.node("BE/JOIN", AlloyTerm.atom("VAR", "y"), AlloyTerm.atom("FIELD", "r"))));
        check(!new SlottedEGraph().compare(comprehensionLeft, comprehensionRight).equivalent,
                "comprehension columns are ordered and must not form a permutation group");

        AlloyTerm falseTerm = AlloyTerm.atom("CONST", "false");
        AblationEngine.Result redundant = new SlottedEGraph().compare(
                AlloyTerm.node("BF/AND", a, falseTerm), falseTerm);
        check(redundant.equivalent, "slotted saturation must eliminate false conjunctions");
        check(redundant.stats.redundantSlots > 0,
                "slot-redundancy elimination must be observable in the statistics");

        System.out.println("EGraph ablation tests passed.");
    }

    private static AlloyTerm predicate(String variable, AlloyTerm body) {
        return predicate(List.of(variable), body);
    }

    private static AlloyTerm predicate(List<String> variables, AlloyTerm body) {
        List<AlloyTerm> declarationChildren = new java.util.ArrayList<>();
        for (String variable : variables) {
            declarationChildren.add(AlloyTerm.atom("VAR", variable));
        }
        declarationChildren.add(AlloyTerm.atom("SIG", "User"));
        AlloyTerm declaration = AlloyTerm.node(
                "DECL/ParamDecl/disj=false/var=false", declarationChildren);
        return AlloyTerm.node("PREDICATE", declaration, AlloyTerm.node("Body", body));
    }

    private static AlloyTerm quantified(String head, String variable, String domain, AlloyTerm body) {
        return quantified(head, List.of(variable), domain, body);
    }

    private static AlloyTerm quantified(String head, List<String> variables, String domain, AlloyTerm body) {
        List<AlloyTerm> declarationChildren = new java.util.ArrayList<>();
        for (String variable : variables) {
            declarationChildren.add(AlloyTerm.atom("VAR", variable));
        }
        declarationChildren.add(AlloyTerm.atom("SIG", domain));
        AlloyTerm declaration = AlloyTerm.node(
                "DECL/VarDecl/disj=false/var=false",
                declarationChildren);
        return AlloyTerm.node(head, declaration, AlloyTerm.node("Body", body));
    }

    private static AlloyTerm comprehension(AlloyTerm body) {
        AlloyTerm declaration = AlloyTerm.node(
                "DECL/VarDecl/disj=false/var=false",
                AlloyTerm.atom("VAR", "x"), AlloyTerm.atom("VAR", "y"), AlloyTerm.atom("SIG", "S"));
        return AlloyTerm.node("QE/COMPREHENSION", declaration, AlloyTerm.node("Body", body));
    }

    private static void check(boolean condition, String message) {
        if (!condition) {
            throw new AssertionError(message);
        }
    }
}
