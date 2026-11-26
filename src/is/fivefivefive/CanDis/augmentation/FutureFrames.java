package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.Expr;
import edu.mit.csail.sdg.ast.ExprUnary;
import java.util.ArrayList;
import java.util.List;

/** A contiguous future-only Boolean prefix; the resolved body stays in its lexical scope. */
record FutureFrames(Expr body, List<ExprUnary.Op> written, Key key) {
    enum Mode { NOW, ALL, SOME, RECURRING, PERMANENT }
    record Key(Mode mode, int shift) {
        List<ExprUnary.Op> word() {
            var ops=new ArrayList<>(java.util.Collections.nCopies(shift,ExprUnary.Op.AFTER));
            switch (mode) {
                case NOW -> {}
                case ALL -> ops.add(ExprUnary.Op.ALWAYS);
                case SOME -> ops.add(ExprUnary.Op.EVENTUALLY);
                case RECURRING -> ops.addAll(List.of(ExprUnary.Op.ALWAYS,ExprUnary.Op.EVENTUALLY));
                case PERMANENT -> ops.addAll(List.of(ExprUnary.Op.EVENTUALLY,ExprUnary.Op.ALWAYS));
            }
            return List.copyOf(ops);
        }
    }

    static FutureFrames read(Expr source) {
        Expr body=source.deNOP();
        var ops=new ArrayList<ExprUnary.Op>();
        while (body instanceof ExprUnary u && (u.op==ExprUnary.Op.AFTER ||
                u.op==ExprUnary.Op.ALWAYS || u.op==ExprUnary.Op.EVENTUALLY)) {
            ops.add(u.op);
            body=u.sub.deNOP();
        }
        return new FutureFrames(body,List.copyOf(ops),keyOf(ops));
    }

    // Right fold corresponding to AdaptiveFutureFrames.prepend.
    static Key keyOf(List<ExprUnary.Op> ops) {
        Mode mode=Mode.NOW;
        int shift=0;
        for (int i=ops.size()-1;i>=0;i--) {
            switch (ops.get(i)) {
                case AFTER -> { if (mode!=Mode.RECURRING && mode!=Mode.PERMANENT) shift++; }
                case ALWAYS -> {
                    if (mode==Mode.SOME) { mode=Mode.RECURRING; shift=0; }
                    else if (mode==Mode.NOW) mode=Mode.ALL;
                }
                case EVENTUALLY -> {
                    if (mode==Mode.ALL) { mode=Mode.PERMANENT; shift=0; }
                    else if (mode==Mode.NOW) mode=Mode.SOME;
                }
                default -> throw new IllegalArgumentException("Not a future prefix: "+ops.get(i));
            }
        }
        return new Key(mode,shift);
    }
}
