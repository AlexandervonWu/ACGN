package parser.ast.nodes;

import edu.mit.csail.sdg.ast.Decl;
import edu.mit.csail.sdg.ast.Expr;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.ast.ExprVar;
import java.util.ArrayList;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import parser.util.AlloyUtil;

/** An occurrence belongs to precisely one parser-resolved declaration in this model. */
public final class ResolvedBindingOrigins {
    public static final class Slot {
        private final Decl owner;
        private final int position;
        private final ExprVar source;
        private final ExprUnary.Op multiplicity;
        private Slot(Decl owner, int position, ExprVar source) {
            this.owner = owner;
            this.position = position;
            this.source = source;
            // Resolved predicate parameters can retain an undecorated domain. Alloy
            // supplies the implicit ONE only for unary domains with no multiplicity.
            this.multiplicity = effectiveMultiplicity(owner.expr);
        }
        public boolean named(String name) { return source.label.equals(name); }
        public boolean implicitOne() { return owner.expr.mult == 0 && owner.expr.type().arity() == 1; }
        public boolean authorizesOne() { return multiplicity == ExprUnary.Op.ONEOF; }
        public boolean authorizesSome() { return multiplicity == ExprUnary.Op.SOMEOF; }
    }

    static ExprUnary.Op effectiveMultiplicity(Expr domain) {
        return domain.mult == 0 && domain.type().arity() == 1 ? ExprUnary.Op.ONEOF : domain.mult();
    }

    /** The two consumers use both Node.children and the typed operand getters.
        Capture both views since the adapter's setters need not synchronize them. */
    private record View(Node node, Node parent, edu.mit.csail.sdg.ast.Type type,
            Object operation, int flags, List<Node> children, List<Node> operands) {
        private static View at(Node n) {
            var operands = new ArrayList<Node>();
            Object operation = null;
            int flags = 0;
            if (n instanceof RelDecl d) {
                flags = (d.isVariable() ? 1 : 0) | (d.isDisjoint() ? 2 : 0);
                if (!append(operands, d.getVariables())) return null;
                operands.add(d.getExpr());
            } else if (n instanceof BinaryExprOrFormula b) {
                operation = b instanceof BinaryExpr e ? e.getOp() : ((BinaryFormula)b).getOp();
                operands.add(b.getLeft()); operands.add(b.getRight());
            } else if (n instanceof UnaryExprOrFormula u) {
                operation = u instanceof UnaryExpr e ? e.getOp() : ((UnaryFormula)u).getOp();
                operands.add(u.getSub());
            } else if (n instanceof QtExprOrFormula q) {
                operation = q instanceof QtExpr e ? e.getOp() : ((QtFormula)q).getOp();
                if (!append(operands, q.getVarDecls())) return null;
                operands.add(q.getBody());
            } else if (n instanceof ListExprOrFormula l) {
                operation = l instanceof ListExpr e ? e.getOp() : ((ListFormula)l).getOp();
                if (!append(operands, l.getArguments())) return null;
            } else if (n instanceof Call c) {
                operation = c.getName();
                if (!append(operands, c.getArguments())) return null;
            } else if (n instanceof ITEExprOrFormula i) {
                operands.add(i.getCondition()); operands.add(i.getThenClause()); operands.add(i.getElseClause());
            } else if (n instanceof LetExpr l) {
                operands.add(l.getVar()); operands.add(l.getBound()); operands.add(l.getBody());
            } else if (n instanceof Body b) {
                operands.add(b.getBodyExpr());
            } else if (n instanceof ConstExpr c) {
                operation = c.getValue(); flags = c.isBoolean() ? 1 : 0;
            } else if (n instanceof SigExpr s) {
                operation = s.getName(); flags = s.isVariable() ? 1 : 0;
            } else if (n instanceof FieldExpr f) {
                operation = f.getName(); flags = f.isVariable() ? 1 : 0;
            } else if (n instanceof VarExpr v) {
                operation = v.getName();
            } else {
                return null;
            }
            if (n.getChildren() == null) return null;
            // The private lists admit null placeholders used by parser NOOP wrappers.
            return new View(n, n.getParent(), n instanceof ExprOrFormula e ? e.getType() : null,
                    operation, flags, new ArrayList<>(n.getChildren()), operands);
        }

        private static boolean append(List<Node> target, List<? extends Node> list) {
            if (list == null) return false;
            target.addAll(list);
            return true;
        }

        private static boolean sameNodes(List<Node> left, List<Node> right) {
            if (left.size() != right.size()) return false;
            for (int i = 0; i < left.size(); i++) if (left.get(i) != right.get(i)) return false;
            return true;
        }

        boolean intact() {
            View current = at(node);
            return current != null && current.parent == parent && current.type == type
                    && current.flags == flags && java.util.Objects.equals(current.operation, operation)
                    && sameNodes(children, current.children) && sameNodes(operands, current.operands);
        }

        void descend(java.util.ArrayDeque<Node> stack) {
            for (Node child : children) if (child != null) stack.push(child);
            for (Node child : operands) if (child != null) stack.push(child);
        }
    }

    private record Bound(RelDecl declaration, List<Slot> slots) {
        boolean intact(Map<Node, View> originals) {
            var seen = java.util.Collections.newSetFromMap(new IdentityHashMap<Node, Boolean>());
            var stack = new java.util.ArrayDeque<Node>();
            stack.push(declaration);
            while (!stack.isEmpty()) {
                Node node = stack.pop();
                if (!seen.add(node)) continue;
                View snapshot = originals.get(node);
                if (snapshot == null || !snapshot.intact()) return false;
                // Traverse saved edges; altered back-edges cannot cause an unbounded walk.
                snapshot.descend(stack);
            }
            return true;
        }
    }

    private final Map<Node, View> adapterViews = new IdentityHashMap<>();

    private void captureViews() {
        var stack = new java.util.ArrayDeque<Node>(declarations.keySet());
        while (!stack.isEmpty()) {
            Node node = stack.pop();
            if (adapterViews.containsKey(node)) continue;
            View snapshot = View.at(node);
            adapterViews.put(node, snapshot);
            if (snapshot != null) snapshot.descend(stack);
        }
    }

    private final Map<RelDecl, Decl> originals = new IdentityHashMap<>();
    private final Map<VarExpr, ExprVar> reads = new IdentityHashMap<>();
    private final Map<ExprVar, Slot> slots = new IdentityHashMap<>();
    private final Map<RelDecl, Bound> declarations = new IdentityHashMap<>();
    private boolean sealed;

    void capture(Object source, Node adapter) {
        if (sealed) return;
        if (source instanceof Decl decl && (adapter instanceof ParamDecl || adapter instanceof VarDecl)) {
            originals.putIfAbsent((RelDecl) adapter, decl);
        } else if (source instanceof ExprVar var && adapter instanceof VarExpr read) {
            reads.putIfAbsent(read, var);
        }
    }

    void seal() {
        if (sealed) throw new IllegalStateException("Binding origins already sealed");
        var ambiguous = java.util.Collections.newSetFromMap(new IdentityHashMap<ExprVar, Boolean>());
        for (var entry : originals.entrySet()) {
            RelDecl decl = entry.getKey();
            Decl original = entry.getValue();
            List<ExprOrFormula> variables = List.copyOf(decl.getVariables());
            if (variables.size() != original.names.size()) continue;
            List<Slot> bound = new ArrayList<>();
            for (int i = 0; i < variables.size(); i++) {
                Node leaf = AlloyUtil.getFirstNonNOOPChild(variables.get(i));
                if (!(leaf instanceof VarExpr var) || !(original.names.get(i) instanceof ExprVar source)
                        || reads.get(var) != source || !source.label.equals(var.getName())) break;
                Slot slot = slots.get(source);
                if (slot == null) {
                    slot = new Slot(original, i, source);
                    slots.put(source, slot);
                } else if (slot.owner != original || slot.position != i) {
                    ambiguous.add(source);
                }
                bound.add(slot);
            }
            if (bound.size() != variables.size()) continue;
            declarations.put(decl, new Bound(decl, List.copyOf(bound)));
        }
        ambiguous.forEach(slots::remove);
        declarations.values().removeIf(bound -> bound.slots.stream().anyMatch(slot -> slots.get(slot.source) != slot));
        captureViews();
        sealed = true;
        originals.clear();
    }

    private static ResolvedBindingOrigins model(Node node) {
        return node != null && node.getNodeMap() instanceof ResolvedCallOrigins map
                && map.bindings.sealed ? map.bindings : null;
    }

    public static List<Slot> declaration(RelDecl declaration) {
        var model = model(declaration);
        var bound = model == null ? null : model.declarations.get(declaration);
        return bound != null && bound.intact(model.adapterViews) ? bound.slots : List.of();
    }

    public static Slot read(VarExpr variable) {
        var model = model(variable);
        if (model == null) return null;
        ExprVar source = model.reads.get(variable);
        return source == null || !source.label.equals(variable.getName()) ? null : model.slots.get(source);
    }
}
