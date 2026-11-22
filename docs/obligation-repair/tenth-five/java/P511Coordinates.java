package is.fivefivefive.CanDis.core.egraph;

import java.util.*;
import parser.ast.nodes.ResolvedBindingOrigins.Slot;

/** Samples complete lexical stacks and actual leaf references without consulting the rewrite guard. */
final class P511Coordinates {
    record Frame(int name,int slot) {}
    record Read(String operation,int slot,int name,List<Frame> scope) {
        String boundary() { return operation+"/"+slot; }
        String frames() {
            var s = new StringJoiner("|");
            for (Frame f : scope) s.add(f.name+","+f.slot);
            return s.toString();
        }
    }

    private final Map<String,Integer> labels = new HashMap<>();
    private final Map<Slot,P511SourceScope.Var> declarations;
    private final List<Read> reads = new ArrayList<>();

    private P511Coordinates(Map<Slot,P511SourceScope.Var> declarations) { this.declarations = declarations; }

    private int label(String spelling) { return labels.computeIfAbsent(spelling, key -> labels.size()+1); }

    private int slot(AlloyTerm leaf) {
        if (leaf.binding()==null) return 0;
        var source = declarations.get(leaf.binding());
        if (source==null) throw new AssertionError("Outside selected parser root");
        return source.coordinate();
    }

    private void walk(AlloyTerm term, List<Frame> outer) {
        String op = term.head();
        if (op.equals("BF/IN") || op.equals("BF/NOT_IN")) {
            var leaf = term.children().get(0);
            while (leaf.head().equals("UE/NOOP")) leaf = leaf.children().get(0);
            reads.add(new Read(op.substring(3),slot(leaf),label(leaf.atom()),List.copyOf(outer)));
        }
        if (op.equals("PREDICATE") || op.startsWith("QE/") || op.startsWith("QF/")) {
            List<Frame> local = new ArrayList<>(outer);
            for (AlloyTerm child : term.children()) {
                walk(child,local);
                if (child.head().startsWith("DECL/")) {
                    for (int i=0; i<child.children().size()-1; i++) {
                        AlloyTerm binder = child.children().get(i);
                        if (slot(binder)==0 || !child.owns(binder.binding())) throw new AssertionError("Detached binder");
                        local.add(0,new Frame(label(binder.atom()),slot(binder)));
                    }
                }
            }
        } else for (AlloyTerm child : term.children()) walk(child,outer);
    }

    static void substitutedRhs(P511SourceScope source,Map<Slot,P511SourceScope.Var> declarations,AlloyTerm rewritten) {
        var actual = new P511Coordinates(declarations);
        actual.walk(rewritten,List.of());
        if (source.letSources.size()!=1 || actual.reads.size()!=1) throw new AssertionError("Expected one let RHS/read");
        Read occurrence = actual.reads.get(0);
        int resolved = occurrence.scope.stream().filter(frame->frame.name==occurrence.name)
                .map(Frame::slot).findFirst().orElse(0);
        if (occurrence.slot!=source.letSources.get(0).coordinate() || resolved!=occurrence.slot)
            throw new AssertionError("Substitution lost or captured the original RHS");
    }

    static void pair(List<String> output,String id,String method,P511SourceScope source,
            Map<Slot,P511SourceScope.Var> declarations,AlloyTerm before,AlloyTerm after) {
        var left = new P511Coordinates(declarations);
        var right = new P511Coordinates(declarations);
        left.walk(before,List.of()); right.walk(after,List.of());
        var order = Comparator.comparing(Read::boundary);
        left.reads.sort(order); right.reads.sort(order);
        if (left.reads.size()!=right.reads.size() || source.reads.size()!=left.reads.size())
            throw new AssertionError("Changed occurrence count");
        for (int i=0; i<left.reads.size(); i++) {
            Read l = left.reads.get(i), r = right.reads.get(i);
            if (!l.boundary().equals(r.boundary()) || !source.reads.get(i).startsWith(l.boundary()+"/"))
                throw new AssertionError("Changed original lexical token");
            String originalGuard = source.reads.get(i).substring(l.boundary().length()+1);
            output.add(String.join("\t",id,method,l.operation,String.join("|",source.groups),
                    Integer.toString(l.slot),Integer.toString(l.name),l.frames(),
                    Integer.toString(r.name),r.frames(),originalGuard));
        }
    }
}
