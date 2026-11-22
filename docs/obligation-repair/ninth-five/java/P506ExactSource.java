package parser.ast.nodes;

import edu.mit.csail.sdg.alloy4.Pos;
import edu.mit.csail.sdg.ast.ExprUnary;
import edu.mit.csail.sdg.ast.Sig;

/** Uses the installed Alloy AST's exact-domain constructor without issuing a binding. */
public final class P506ExactSource {
    public static void verify() {
        var exact = ExprUnary.Op.EXACTLYOF.make(Pos.UNKNOWN, Sig.NONE);
        if (ResolvedBindingOrigins.effectiveMultiplicity(exact) != ExprUnary.Op.EXACTLYOF) {
            throw new AssertionError("EXACTLY none changed declaration multiplicity");
        }
    }
}
