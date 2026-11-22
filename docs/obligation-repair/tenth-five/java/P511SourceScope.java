package is.fivefivefive.CanDis.core.egraph;

import edu.mit.csail.sdg.ast.*;
import java.util.*;
import parser.ast.nodes.ResolvedBindingOrigins.Slot;

/** Computes lexical coordinates on original Alloy objects, before ModelUnit construction. */
final class P511SourceScope {
    record Var(int coordinate, String spelling, boolean positive) {}
    final List<Var> declarations = new ArrayList<>();
    final List<String> reads = new ArrayList<>();
    final List<Var> letSources = new ArrayList<>();
    final List<String> groups = new ArrayList<>();

    static P511SourceScope resolve(Func function) {
        P511SourceScope result = new P511SourceScope();
        Map<ExprVar,Var> scope = new IdentityHashMap<>();
        for (Decl decl : function.decls) result.declare(decl, scope);
        result.expression(function.getBody(), scope);
        Collections.sort(result.reads);
        return result;
    }

    private void declare(Decl d, Map<ExprVar,Var> scope) {
        expression(d.expr, scope);
        boolean positive = (d.expr.mult == 0 && d.expr.type().arity() == 1)
                || d.expr.mult() == ExprUnary.Op.ONEOF || d.expr.mult() == ExprUnary.Op.SOMEOF;
        String kind = d.expr.mult == 0 ? "bare" : switch (d.expr.mult()) {
            case ONEOF -> "one";
            case SOMEOF -> "some";
            case SETOF -> "set";
            case LONEOF -> "lone";
            case EXACTLYOF -> "exactly";
            default -> throw new AssertionError("Unsupported fixture domain " + d.expr);
        };
        var group = new StringJoiner(",").add(kind).add(Integer.toString(d.expr.type().arity()));
        for (ExprHasName name : d.names) {
            Var frame = new Var(declarations.size()+1, name.label, positive);
            declarations.add(frame);
            scope.put((ExprVar)name, frame);
            group.add(Integer.toString(frame.coordinate));
        }
        groups.add(group.toString());
    }

    private static Expr unwrapped(Expr expr) {
        while (expr instanceof ExprUnary u && u.op == ExprUnary.Op.NOOP) expr = u.sub;
        return expr;
    }

    private void expression(Expr expr, Map<ExprVar,Var> scope) {
        if (expr instanceof ExprQt q) {
            var local = new IdentityHashMap<>(scope);
            for (Decl d : q.decls) declare(d, local);
            expression(q.sub, local);
        } else if (expr instanceof ExprLet l) {
            expression(l.expr, scope);
            if (unwrapped(l.expr) instanceof ExprVar rhs && scope.get(rhs)!=null)
                letSources.add(scope.get(rhs));
            var local = new IdentityHashMap<>(scope);
            local.put(l.var, new Var(0,l.var.label,false));
            expression(l.sub,local);
        } else if (expr instanceof ExprUnary u) {
            expression(u.sub,scope);
        } else if (expr instanceof ExprBinary b) {
            if (b.op == ExprBinary.Op.IN || b.op == ExprBinary.Op.NOT_IN) {
                if (!(unwrapped(b.left) instanceof ExprVar read) || !scope.containsKey(read))
                    throw new AssertionError("Fixture membership lacks an original lexical variable: " + b);
                Var frame = scope.get(read);
                reads.add(b.op.name() + "/" + frame.coordinate + "/" + frame.positive);
            }
            expression(b.left,scope);
            expression(b.right,scope);
        } else if (expr instanceof ExprList list) {
            for (Expr child : list.args) expression(child,scope);
        } else if (!(expr instanceof ExprVar || expr instanceof Sig || expr instanceof ExprConstant)) {
            throw new AssertionError("Outside the lexical fixture grammar: " + expr.getClass());
        }
    }

    Map<Slot,Var> bind(AlloyTerm raw) {
        var authority = new IdentityHashMap<Slot,Var>();
        install(raw, authority);
        if (authority.size() != declarations.size()) throw new AssertionError("Parsed declaration count differs");
        return authority;
    }

    private void install(AlloyTerm term, Map<Slot,Var> authority) {
        if (term.head().startsWith("DECL/")) {
            List<AlloyTerm> children = term.children();
            for (int i = 0; i < children.size()-1; i++) {
                AlloyTerm child = children.get(i);
                Slot token = child.binding();
                Var expected = declarations.get(authority.size());
                if (token == null || !term.owns(token) || !child.atom().equals(expected.spelling)
                        || expected.positive != (token.authorizesOne() || token.authorizesSome())
                        || authority.put(token,expected) != null)
                    throw new AssertionError("Source declaration identity/multiplicity mismatch: " + expected);
            }
        }
        for (AlloyTerm child : term.children()) install(child,authority);
    }

    List<String> frontier(AlloyTerm term, Map<Slot,Var> authority) {
        List<String> found = new ArrayList<>();
        inspect(term,authority,new HashMap<>(),found);
        Collections.sort(found);
        if (!reads.equals(found)) throw new AssertionError("Source/frontier reads differ: " + reads + " vs " + found);
        return found;
    }

    private static void inspect(AlloyTerm term, Map<Slot,Var> authority,
            Map<String,Slot> active, List<String> found) {
        String head = term.head();
        if (head.equals("BF/IN") || head.equals("BF/NOT_IN")) {
            AlloyTerm left = term.children().get(0);
            while (left.head().equals("UE/NOOP") && left.children().size()==1) left = left.children().get(0);
            if (!left.isVariable()) throw new AssertionError("Non-variable in lexical witness");
            Slot token = left.binding();
            Var original = authority.get(token);
            if (token != null && original == null) throw new AssertionError("Foreign token on genuine input");
            boolean authorized = original != null && original.positive() && token == active.get(left.atom());
            found.add(head.substring(3) + "/" + (original == null ? 0 : original.coordinate()) + "/" + authorized);
        }
        if (head.equals("PREDICATE") || head.startsWith("QF/") || head.startsWith("QE/")) {
            var local = new HashMap<>(active);
            for (AlloyTerm child : term.children()) {
                inspect(child,authority,local,found);
                if (child.head().startsWith("DECL/")) {
                    List<AlloyTerm> items = child.children();
                    for (int i = 0; i < items.size()-1; i++) {
                        AlloyTerm binder = items.get(i);
                        Slot token = binder.binding();
                        if (token == null || !child.owns(token) || !authority.containsKey(token))
                            throw new AssertionError("Dropped source coordinate: " + child);
                        local.put(binder.atom(), token);
                    }
                }
            }
        } else {
            for (AlloyTerm child : term.children()) inspect(child,authority,active,found);
        }
    }
}
