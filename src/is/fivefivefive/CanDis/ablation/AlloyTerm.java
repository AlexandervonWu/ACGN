package is.fivefivefive.CanDis.ablation;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

import parser.ast.nodes.BinaryExpr;
import parser.ast.nodes.BinaryFormula;
import parser.ast.nodes.Call;
import parser.ast.nodes.ConstExpr;
import parser.ast.nodes.FieldExpr;
import parser.ast.nodes.ITEExpr;
import parser.ast.nodes.ITEFormula;
import parser.ast.nodes.ListExpr;
import parser.ast.nodes.ListFormula;
import parser.ast.nodes.Node;
import parser.ast.nodes.ParamDecl;
import parser.ast.nodes.Predicate;
import parser.ast.nodes.QtExpr;
import parser.ast.nodes.QtFormula;
import parser.ast.nodes.RelDecl;
import parser.ast.nodes.SigExpr;
import parser.ast.nodes.UnaryExpr;
import parser.ast.nodes.UnaryFormula;
import parser.ast.nodes.VarExpr;

/** Immutable, parser-independent representation of a raw Alloy AST term. */
public final class AlloyTerm implements Comparable<AlloyTerm> {
    private final String head;
    private final String atom;
    private final List<AlloyTerm> children;
    private final int hashCode;
    private final int size;

    private AlloyTerm(String head, String atom, List<AlloyTerm> children) {
        this.head = Objects.requireNonNull(head, "head");
        this.atom = atom == null ? "" : atom;
        this.children = Collections.unmodifiableList(new ArrayList<>(children));
        this.hashCode = Objects.hash(this.head, this.atom, this.children);
        int nodeCount = 1;
        for (AlloyTerm child : this.children) {
            nodeCount += child.size;
        }
        this.size = nodeCount;
    }

    public static AlloyTerm node(String head, AlloyTerm... children) {
        List<AlloyTerm> childList = new ArrayList<>(children.length);
        Collections.addAll(childList, children);
        return new AlloyTerm(head, "", childList);
    }

    public static AlloyTerm node(String head, List<AlloyTerm> children) {
        return new AlloyTerm(head, "", children);
    }

    public static AlloyTerm atom(String head, String value) {
        return new AlloyTerm(head, value, Collections.emptyList());
    }

    /**
     * Converts a predicate while intentionally omitting its declaration name. The
     * student predicate X and oracle predicate XC therefore differ only in their
     * parameter declarations and bodies.
     */
    public static AlloyTerm fromPredicate(Predicate predicate) {
        List<AlloyTerm> children = new ArrayList<>();
        if (predicate != null) {
            List<ParamDecl> parameters = predicate.getParamList();
            if (parameters != null) {
                for (ParamDecl parameter : parameters) {
                    children.add(fromAst(parameter));
                }
            }
            if (predicate.getBody() != null) {
                children.add(fromAst(predicate.getBody()));
            }
        }
        return node("PREDICATE", children);
    }

    public static AlloyTerm fromAst(Node node) {
        if (node == null) {
            return atom("NULL", "");
        }
        if (node instanceof RelDecl) {
            RelDecl declaration = (RelDecl) node;
            List<AlloyTerm> declarationChildren = new ArrayList<>();
            if (declaration.getVariables() != null) {
                for (Node variable : declaration.getVariables()) {
                    declarationChildren.add(fromAst(variable));
                }
            }
            if (declaration.getExpr() != null) {
                declarationChildren.add(fromAst(declaration.getExpr()));
            }
            return node("DECL/" + node.getClass().getSimpleName()
                    + "/disj=" + declaration.isDisjoint()
                    + "/var=" + declaration.isVariable(), declarationChildren);
        }
        List<AlloyTerm> children = new ArrayList<>();
        List<Node> astChildren = node.getChildren();
        if (astChildren != null) {
            for (Node child : astChildren) {
                if (child != null) {
                    children.add(fromAst(child));
                }
            }
        }
        if (node instanceof VarExpr) {
            return atom("VAR", ((VarExpr) node).getName());
        }
        if (node instanceof SigExpr) {
            return atom("SIG", ((SigExpr) node).getName());
        }
        if (node instanceof FieldExpr) {
            return atom("FIELD", ((FieldExpr) node).getName());
        }
        if (node instanceof ConstExpr) {
            return atom("CONST", ((ConstExpr) node).getValue());
        }
        if (node instanceof BinaryFormula) {
            return node("BF/" + enumName(((BinaryFormula) node).getOp()), children);
        }
        if (node instanceof BinaryExpr) {
            return node("BE/" + enumName(((BinaryExpr) node).getOp()), children);
        }
        if (node instanceof UnaryFormula) {
            return node("UF/" + enumName(((UnaryFormula) node).getOp()), children);
        }
        if (node instanceof UnaryExpr) {
            return node("UE/" + enumName(((UnaryExpr) node).getOp()), children);
        }
        if (node instanceof QtFormula) {
            return node("QF/" + enumName(((QtFormula) node).getOp()), children);
        }
        if (node instanceof QtExpr) {
            return node("QE/" + enumName(((QtExpr) node).getOp()), children);
        }
        if (node instanceof ListFormula) {
            return node("LF/" + enumName(((ListFormula) node).getOp()), children);
        }
        if (node instanceof ListExpr) {
            return node("LE/" + enumName(((ListExpr) node).getOp()), children);
        }
        if (node instanceof Call) {
            return new AlloyTerm("CALL/" + node.getClass().getSimpleName(),
                    ((Call) node).getName(), children);
        }
        if (node instanceof ITEFormula) {
            return node("ITE/FORMULA", children);
        }
        if (node instanceof ITEExpr) {
            return node("ITE/EXPR", children);
        }
        return node(node.getClass().getSimpleName(), children);
    }

    private static String enumName(Enum<?> value) {
        return value == null ? "NULL" : value.name();
    }

    public String head() {
        return head;
    }

    public String atom() {
        return atom;
    }

    public List<AlloyTerm> children() {
        return children;
    }

    public int size() {
        return size;
    }

    public boolean isVariable() {
        return "VAR".equals(head);
    }

    public AlloyTerm withChildren(List<AlloyTerm> replacement) {
        if (children.equals(replacement)) {
            return this;
        }
        return new AlloyTerm(head, atom, replacement);
    }

    @Override
    public int compareTo(AlloyTerm other) {
        if (this == other) {
            return 0;
        }
        int comparison = head.compareTo(other.head);
        if (comparison != 0) {
            return comparison;
        }
        comparison = atom.compareTo(other.atom);
        if (comparison != 0) {
            return comparison;
        }
        comparison = Integer.compare(children.size(), other.children.size());
        if (comparison != 0) {
            return comparison;
        }
        for (int i = 0; i < children.size(); i++) {
            comparison = children.get(i).compareTo(other.children.get(i));
            if (comparison != 0) {
                return comparison;
            }
        }
        return 0;
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof AlloyTerm)) {
            return false;
        }
        AlloyTerm term = (AlloyTerm) other;
        return head.equals(term.head) && atom.equals(term.atom) && children.equals(term.children);
    }

    @Override
    public int hashCode() {
        return hashCode;
    }

    @Override
    public String toString() {
        if (children.isEmpty()) {
            return atom.isEmpty() ? head : head + "(" + atom + ")";
        }
        StringBuilder builder = new StringBuilder(head).append('(');
        for (int i = 0; i < children.size(); i++) {
            if (i > 0) {
                builder.append(',');
            }
            builder.append(children.get(i));
        }
        return builder.append(')').toString();
    }
}
