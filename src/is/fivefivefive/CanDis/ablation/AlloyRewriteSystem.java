package is.fivefivefive.CanDis.ablation;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/** Shared, terminating orientation of the Alloy equivalences used by the baselines. */
final class AlloyRewriteSystem {
    static final int MAX_ITERATIONS = 32;

    private static final Set<String> ACI = Set.of(
            "BOOL/AND", "BOOL/OR", "REL/PLUS", "REL/INTERSECT");
    private static final Set<String> AC = Set.of(
            "ARITH/MUL", "ARITH/PLUS", "LIST/DISJOINT");
    private static final Set<String> ASSOCIATIVE = Set.of(
            "BOOL/AND", "BOOL/OR", "REL/PLUS", "REL/INTERSECT",
            "ARITH/MUL", "ARITH/PLUS", "REL/JOIN", "REL/ARROW");
    private static final Set<String> COMMUTATIVE = Set.of(
            "BOOL/AND", "BOOL/OR", "REL/PLUS", "REL/INTERSECT",
            "ARITH/MUL", "ARITH/PLUS", "LIST/DISJOINT", "BF/EQUALS");

    private AlloyRewriteSystem() {
    }

    static Pass rewriteOnce(AlloyTerm input) {
        Counter counter = new Counter();
        AlloyTerm output = rewriteTree(input, counter);
        return new Pass(output, counter.changes);
    }

    private static AlloyTerm rewriteTree(AlloyTerm input, Counter counter) {
        List<AlloyTerm> children = input.children();
        List<AlloyTerm> rewrittenChildren = new ArrayList<>(children.size());
        boolean childChanged = false;
        for (AlloyTerm child : children) {
            AlloyTerm rewritten = rewriteTree(child, counter);
            rewrittenChildren.add(rewritten);
            childChanged |= rewritten != child;
        }
        AlloyTerm current = childChanged ? input.withChildren(rewrittenChildren) : input;
        AlloyTerm rewritten = rewriteNode(current);
        if (!rewritten.equals(current)) {
            counter.changes++;
            return rewritten;
        }
        return current;
    }

    private static AlloyTerm rewriteNode(AlloyTerm input) {
        String canonicalHead = canonicalHead(input.head());
        AlloyTerm current = canonicalHead.equals(input.head())
                ? input
                : newTerm(canonicalHead, input.atom(), input.children());

        if ("CONST".equals(current.head()) && !current.atom().equals(current.atom().toLowerCase())) {
            return AlloyTerm.atom("CONST", current.atom().toLowerCase());
        }
        if ("UE/NOOP".equals(current.head()) && current.children().size() == 1) {
            return current.children().get(0);
        }
        if ("LetExpr".equals(current.head()) && current.children().size() >= 3) {
            AlloyTerm variable = current.children().get(0);
            if (variable.isVariable()) {
                AlloyTerm bound = current.children().get(1);
                AlloyTerm body = unwrapBody(current.children().get(current.children().size() - 1));
                return substitute(body, variable.atom(), bound);
            }
        }
        if ("BF/NOT_EQUALS".equals(current.head()) && current.children().size() == 2) {
            return not(AlloyTerm.node("BF/EQUALS", current.children()));
        }
        if ("BF/NOT_IN".equals(current.head()) && current.children().size() == 2) {
            return not(AlloyTerm.node("BF/IN", current.children()));
        }
        if ("BOOL/IMPLIES".equals(current.head()) && current.children().size() == 2) {
            return AlloyTerm.node("BOOL/OR", not(current.children().get(0)), current.children().get(1));
        }
        if ("BOOL/IFF".equals(current.head()) && current.children().size() == 2) {
            AlloyTerm left = current.children().get(0);
            AlloyTerm right = current.children().get(1);
            return AlloyTerm.node("BOOL/AND",
                    AlloyTerm.node("BOOL/OR", not(left), right),
                    AlloyTerm.node("BOOL/OR", not(right), left));
        }
        if ("ITE/FORMULA".equals(current.head()) && current.children().size() == 3) {
            AlloyTerm condition = current.children().get(0);
            AlloyTerm thenClause = current.children().get(1);
            AlloyTerm elseClause = current.children().get(2);
            return AlloyTerm.node("BOOL/OR",
                    AlloyTerm.node("BOOL/AND", condition, thenClause),
                    AlloyTerm.node("BOOL/AND", not(condition), elseClause));
        }
        if ("BOOL/NOT".equals(current.head()) && current.children().size() == 1) {
            return rewriteNot(current.children().get(0));
        }
        if (current.head().startsWith("QF/")) {
            AlloyTerm empty = emptyDomainResult(current);
            if (empty != null) {
                return empty;
            }
            if ("QF/NO".equals(current.head())) {
                return rewriteQuantifier(current, "QF/ALL", true);
            }
        }
        if ("BF/IN".equals(current.head()) && current.children().size() == 2) {
            AlloyTerm domain = current.children().get(1);
            if (isConstant(domain, "none")) {
                return bool(false);
            }
            if (isConstant(domain, "univ")) {
                return bool(true);
            }
        }
        if ("REL/PLUS".equals(current.head())) {
            List<AlloyTerm> kept = withoutConstant(current.children(), "none");
            if (kept.isEmpty()) {
                return constant("none");
            }
            if (kept.size() == 1) {
                return kept.get(0);
            }
            if (kept.size() != current.children().size()) {
                current = AlloyTerm.node(current.head(), kept);
            }
        }
        if ("REL/INTERSECT".equals(current.head()) && containsConstant(current.children(), "none")) {
            return constant("none");
        }
        if (ASSOCIATIVE.contains(current.head())) {
            List<AlloyTerm> flattened = new ArrayList<>();
            flatten(current.head(), current, flattened);
            current = AlloyTerm.node(current.head(), flattened);
        }
        if (COMMUTATIVE.contains(current.head())) {
            List<AlloyTerm> sorted = new ArrayList<>(current.children());
            Collections.sort(sorted);
            current = current.withChildren(sorted);
        }
        if (ACI.contains(current.head())) {
            List<AlloyTerm> unique = deduplicate(current.children());
            current = current.withChildren(unique);
        }
        if ("BOOL/AND".equals(current.head())) {
            if (containsConstant(current.children(), "false") || containsComplement(current.children())) {
                return bool(false);
            }
            List<AlloyTerm> kept = withoutConstant(current.children(), "true");
            return finishVariadic(current.head(), kept, true);
        }
        if ("BOOL/OR".equals(current.head())) {
            if (containsConstant(current.children(), "true") || containsComplement(current.children())) {
                return bool(true);
            }
            List<AlloyTerm> kept = withoutConstant(current.children(), "false");
            return finishVariadic(current.head(), kept, false);
        }
        return current;
    }

    private static AlloyTerm rewriteNot(AlloyTerm child) {
        if (isConstant(child, "true")) {
            return bool(false);
        }
        if (isConstant(child, "false")) {
            return bool(true);
        }
        if ("BOOL/NOT".equals(child.head()) && child.children().size() == 1) {
            return child.children().get(0);
        }
        if (("BOOL/AND".equals(child.head()) || "BOOL/OR".equals(child.head()))) {
            String opposite = "BOOL/AND".equals(child.head()) ? "BOOL/OR" : "BOOL/AND";
            List<AlloyTerm> negated = new ArrayList<>(child.children().size());
            for (AlloyTerm item : child.children()) {
                negated.add(not(item));
            }
            return AlloyTerm.node(opposite, negated);
        }
        if (child.head().startsWith("QF/")) {
            switch (child.head()) {
                case "QF/ALL":
                    return rewriteQuantifier(child, "QF/SOME", true);
                case "QF/SOME":
                    return rewriteQuantifier(child, "QF/ALL", true);
                case "QF/NO":
                    return rewriteQuantifier(child, "QF/SOME", false);
                case "QF/ONE":
                    return rewriteQuantifier(child, "QF/NOTONE", false);
                case "QF/LONE":
                    return rewriteQuantifier(child, "QF/NOTLONE", false);
                case "QF/NOTONE":
                    return rewriteQuantifier(child, "QF/ONE", false);
                case "QF/NOTLONE":
                    return rewriteQuantifier(child, "QF/LONE", false);
                default:
                    break;
            }
        }
        return not(child);
    }

    private static AlloyTerm rewriteQuantifier(AlloyTerm quantifier, String head, boolean negateBody) {
        List<AlloyTerm> children = new ArrayList<>(quantifier.children());
        if (!children.isEmpty() && negateBody) {
            int bodyIndex = children.size() - 1;
            AlloyTerm body = children.get(bodyIndex);
            if ("Body".equals(body.head()) && body.children().size() == 1) {
                children.set(bodyIndex, AlloyTerm.node("Body", not(body.children().get(0))));
            } else {
                children.set(bodyIndex, not(body));
            }
        }
        return AlloyTerm.node(head, children);
    }

    private static AlloyTerm emptyDomainResult(AlloyTerm quantifier) {
        boolean empty = false;
        for (AlloyTerm child : quantifier.children()) {
            if (child.head().startsWith("DECL/") && !child.children().isEmpty()
                    && isConstant(child.children().get(child.children().size() - 1), "none")) {
                empty = true;
                break;
            }
        }
        if (!empty) {
            return null;
        }
        switch (quantifier.head()) {
            case "QF/ALL":
            case "QF/NO":
            case "QF/LONE":
            case "QF/NOTONE":
                return bool(true);
            case "QF/SOME":
            case "QF/ONE":
            case "QF/NOTLONE":
                return bool(false);
            default:
                return null;
        }
    }

    private static AlloyTerm substitute(AlloyTerm term, String variable, AlloyTerm replacement) {
        Set<String> replacementNames = new HashSet<>();
        collectVariableNames(replacement, replacementNames);
        Set<String> usedNames = new HashSet<>(replacementNames);
        collectVariableNames(term, usedNames);
        return substitute(term, variable, replacement, replacementNames, usedNames,
                new HashMap<>(), true, new int[] { 0 });
    }

    private static AlloyTerm substitute(
            AlloyTerm term,
            String variable,
            AlloyTerm replacement,
            Set<String> replacementNames,
            Set<String> usedNames,
            Map<String, String> renames,
            boolean substitutionVisible,
            int[] nextFresh) {
        if (term.isVariable()) {
            String renamed = renames.getOrDefault(term.atom(), term.atom());
            if (substitutionVisible && renamed.equals(variable)) {
                return replacement;
            }
            return renamed.equals(term.atom()) ? term : AlloyTerm.atom("VAR", renamed);
        }
        if (term.children().isEmpty()) {
            return term;
        }
        if ("LetExpr".equals(term.head()) && term.children().size() >= 3) {
            List<AlloyTerm> children = new ArrayList<>(term.children().size());
            AlloyTerm binder = term.children().get(0);
            AlloyTerm rewrittenBound = substitute(term.children().get(1), variable, replacement,
                    replacementNames, usedNames, renames, substitutionVisible, nextFresh);
            Map<String, String> localRenames = new HashMap<>(renames);
            boolean bodyVisible = substitutionVisible;
            if (binder.isVariable()) {
                String original = binder.atom();
                String renamed = renames.getOrDefault(original, original);
                if (substitutionVisible && replacementNames.contains(renamed)) {
                    renamed = freshName(usedNames, nextFresh);
                }
                localRenames.put(original, renamed);
                children.add(AlloyTerm.atom("VAR", renamed));
                if (renamed.equals(variable) || original.equals(variable)) {
                    bodyVisible = false;
                }
            } else {
                children.add(substitute(binder, variable, replacement, replacementNames,
                        usedNames, renames, substitutionVisible, nextFresh));
            }
            children.add(rewrittenBound);
            for (int i = 2; i < term.children().size(); i++) {
                children.add(substitute(term.children().get(i), variable, replacement,
                        replacementNames, usedNames, localRenames, bodyVisible, nextFresh));
            }
            return term.withChildren(children);
        }
        if (isBinder(term)) {
            List<AlloyTerm> children = new ArrayList<>(term.children().size());
            Map<String, String> localRenames = new HashMap<>(renames);
            boolean bodyVisible = substitutionVisible;
            for (AlloyTerm child : term.children()) {
                if (!child.head().startsWith("DECL/")) {
                    children.add(substitute(child, variable, replacement, replacementNames,
                            usedNames, localRenames, bodyVisible, nextFresh));
                    continue;
                }
                List<AlloyTerm> declaration = new ArrayList<>(child.children().size());
                List<AlloyTerm> declaredVariables = new ArrayList<>();
                for (AlloyTerm declarationChild : child.children()) {
                    if (declarationChild.isVariable()) {
                        declaredVariables.add(declarationChild);
                    } else {
                        declaration.add(substitute(declarationChild, variable, replacement,
                                replacementNames, usedNames, localRenames, bodyVisible, nextFresh));
                    }
                }
                List<AlloyTerm> renamedVariables = new ArrayList<>(declaredVariables.size());
                for (AlloyTerm declaredVariable : declaredVariables) {
                    String original = declaredVariable.atom();
                    String renamed = localRenames.getOrDefault(original, original);
                    if (bodyVisible && replacementNames.contains(renamed)) {
                        renamed = freshName(usedNames, nextFresh);
                    }
                    localRenames.put(original, renamed);
                    renamedVariables.add(AlloyTerm.atom("VAR", renamed));
                    if (renamed.equals(variable) || original.equals(variable)) {
                        bodyVisible = false;
                    }
                }
                renamedVariables.addAll(declaration);
                children.add(child.withChildren(renamedVariables));
            }
            return term.withChildren(children);
        }
        List<AlloyTerm> children = new ArrayList<>(term.children().size());
        for (AlloyTerm child : term.children()) {
            children.add(substitute(child, variable, replacement, replacementNames,
                    usedNames, renames, substitutionVisible, nextFresh));
        }
        return term.withChildren(children);
    }

    private static boolean isBinder(AlloyTerm term) {
        return "PREDICATE".equals(term.head())
                || term.head().startsWith("QF/")
                || term.head().startsWith("QE/");
    }

    private static void collectVariableNames(AlloyTerm term, Set<String> names) {
        if (term.isVariable()) {
            names.add(term.atom());
        }
        for (AlloyTerm child : term.children()) {
            collectVariableNames(child, names);
        }
    }

    private static String freshName(Set<String> usedNames, int[] nextFresh) {
        String candidate;
        do {
            candidate = "@beta:" + nextFresh[0]++;
        } while (!usedNames.add(candidate));
        return candidate;
    }

    private static AlloyTerm unwrapBody(AlloyTerm term) {
        return "Body".equals(term.head()) && term.children().size() == 1
                ? term.children().get(0)
                : term;
    }

    private static void flatten(String head, AlloyTerm term, List<AlloyTerm> output) {
        if (head.equals(term.head())) {
            for (AlloyTerm child : term.children()) {
                flatten(head, child, output);
            }
        } else {
            output.add(term);
        }
    }

    private static List<AlloyTerm> deduplicate(List<AlloyTerm> children) {
        List<AlloyTerm> output = new ArrayList<>(children.size());
        AlloyTerm previous = null;
        for (AlloyTerm child : children) {
            if (previous == null || !previous.equals(child)) {
                output.add(child);
                previous = child;
            }
        }
        return output;
    }

    private static boolean containsComplement(List<AlloyTerm> children) {
        Set<AlloyTerm> positive = new HashSet<>();
        Set<AlloyTerm> negative = new HashSet<>();
        for (AlloyTerm child : children) {
            if ("BOOL/NOT".equals(child.head()) && child.children().size() == 1) {
                AlloyTerm item = child.children().get(0);
                if (positive.contains(item)) {
                    return true;
                }
                negative.add(item);
            } else {
                if (negative.contains(child)) {
                    return true;
                }
                positive.add(child);
            }
        }
        return false;
    }

    private static List<AlloyTerm> withoutConstant(List<AlloyTerm> children, String value) {
        List<AlloyTerm> output = new ArrayList<>(children.size());
        for (AlloyTerm child : children) {
            if (!isConstant(child, value)) {
                output.add(child);
            }
        }
        return output;
    }

    private static boolean containsConstant(List<AlloyTerm> children, String value) {
        for (AlloyTerm child : children) {
            if (isConstant(child, value)) {
                return true;
            }
        }
        return false;
    }

    private static AlloyTerm finishVariadic(String head, List<AlloyTerm> children, boolean identity) {
        if (children.isEmpty()) {
            return bool(identity);
        }
        if (children.size() == 1) {
            return children.get(0);
        }
        return AlloyTerm.node(head, children);
    }

    private static String canonicalHead(String head) {
        switch (head) {
            case "BF/AND":
            case "LF/AND":
                return "BOOL/AND";
            case "BF/OR":
            case "LF/OR":
                return "BOOL/OR";
            case "BF/IMPLIES":
                return "BOOL/IMPLIES";
            case "BF/IFF":
                return "BOOL/IFF";
            case "UF/NOT":
                return "BOOL/NOT";
            case "BE/PLUS":
                return "REL/PLUS";
            case "BE/INTERSECT":
                return "REL/INTERSECT";
            case "BE/JOIN":
                return "REL/JOIN";
            case "BE/ARROW":
                return "REL/ARROW";
            case "BE/MUL":
                return "ARITH/MUL";
            case "BE/IPLUS":
                return "ARITH/PLUS";
            case "LE/DISJOINT":
                return "LIST/DISJOINT";
            default:
                return head;
        }
    }

    private static AlloyTerm not(AlloyTerm child) {
        return AlloyTerm.node("BOOL/NOT", child);
    }

    private static AlloyTerm bool(boolean value) {
        return constant(Boolean.toString(value));
    }

    private static AlloyTerm constant(String value) {
        return AlloyTerm.atom("CONST", value);
    }

    private static boolean isConstant(AlloyTerm term, String value) {
        return "CONST".equals(term.head()) && value.equalsIgnoreCase(term.atom());
    }

    private static AlloyTerm newTerm(String head, String atom, List<AlloyTerm> children) {
        if (children.isEmpty()) {
            return AlloyTerm.atom(head, atom);
        }
        return AlloyTerm.node(head, children);
    }

    static final class Pass {
        final AlloyTerm term;
        final int applications;

        Pass(AlloyTerm term, int applications) {
            this.term = term;
            this.applications = applications;
        }
    }

    private static final class Counter {
        private int changes;
    }
}
