package is.fivefivefive.CanDis.theory;

import com.sun.source.tree.*;
import java.util.*;

/** Restrict the three production controllers to a closed, sequential Java fragment.
 * Every branch, loop, statement order, selected operand and terminal expression is read from javac. */
final class A222Control {
    private static List<? extends StatementTree> body(StatementTree s) {
        return ((BlockTree)s).getStatements();
    }
    private static String expression(StatementTree s) {
        return ((ExpressionStatementTree)s).getExpression().toString();
    }
    private static String init(StatementTree s) {
        var v=(VariableTree)s;
        return v.getName()+"="+v.getInitializer();
    }
    private static String each(EnhancedForLoopTree f) {
        return f.getVariable().getName()+" in "+f.getExpression();
    }
    private static String count(ForLoopTree f) {
        if(f.getInitializer().size()!=1 || f.getUpdate().size()!=1) throw new AssertionError("Unexpected counted loop");
        return init(f.getInitializer().get(0))+"|"+f.getCondition()+"|"+expression(f.getUpdate().get(0));
    }
    private static IfTree branch(StatementTree s) {
        var test=(IfTree)s;
        if(test.getElseStatement()!=null) throw new AssertionError("Unexpected alternate branch");
        return test;
    }
    private static void size(List<?> items,int expected) {
        if(items.size()!=expected) throw new AssertionError("Unexpected controller length "+items);
    }
    private static String guard(StatementTree s) {
        var test=branch(s);
        var yes=body(test.getThenStatement()); size(yes,1);
        return test.getCondition()+"|"+yes.get(0).getKind();
    }
    static List<String> derive(MethodTree method) {
        var s=method.getBody().getStatements();
        size(s,18);
        var decisions=new ArrayList<String>();
        for(var item:s) {
            if(item instanceof IfTree i) decisions.add("guard|"+guard(i));
            if(item instanceof VariableTree) decisions.add("value|"+init(item));
        }
        return List.copyOf(decisions);
    }
    static List<String> binary(MethodTree method) {
        var s=method.getBody().getStatements();
        size(s,6);
        var left=(EnhancedForLoopTree)s.get(4);
        var l=body(left.getStatement()); size(l,1);
        var right=(EnhancedForLoopTree)l.get(0);
        var r=body(right.getStatement()); size(r,4);
        var col=(ForLoopTree)r.get(2);
        var steps=body(col.getStatement()); size(steps,3);
        var miss=branch(steps.get(1));
        var stop=body(miss.getThenStatement()); size(stop,2);
        if(!(stop.get(1) instanceof BreakTree b) || b.getLabel()!=null) throw new AssertionError("Unlabeled break required");
        var keep=branch(r.get(3));
        var save=body(keep.getThenStatement()); size(save,1);
        return List.of("width|"+guard(s.get(0)),"authority|"+expression(s.get(1)),
                "empty|"+guard(s.get(2)),"start|"+init(s.get(3)),
                "each|"+each(left),"each|"+each(right),"new|"+init(r.get(0)),
                "flag|"+init(r.get(1)),"each|"+count(col),"derive|"+init(steps.get(0)),
                "omit|"+miss.getCondition()+"|"+expression(stop.get(0))+"|break",
                "column|"+expression(steps.get(2)),"row|"+keep.getCondition()+"|"+expression(save.get(0)),
                "finish|"+((ReturnTree)s.get(5)).getExpression());
    }
    static List<String> fold(MethodTree method) {
        var s=method.getBody().getStatements(); size(s,5);
        var loop=(ForLoopTree)s.get(3); var steps=body(loop.getStatement()); size(steps,1);
        return List.of("operands|"+expression(s.get(0)),"minimum|"+guard(s.get(1)),"first|"+init(s.get(2)),
                "next|"+count(loop),"step|"+expression(steps.get(0)),"end|"+((ReturnTree)s.get(4)).getExpression());
    }
}

