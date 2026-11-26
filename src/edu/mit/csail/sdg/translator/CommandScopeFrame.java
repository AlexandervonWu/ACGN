package edu.mit.csail.sdg.translator;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.alloy4.Err;
import edu.mit.csail.sdg.ast.Command;
import edu.mit.csail.sdg.ast.Sig;

/** Same scope computation and actualScopes callback as execute_command, before SAT translation. */
public final class CommandScopeFrame {
    private CommandScopeFrame() {}
    public static A4Solution compute(A4Reporter reporter, A4Options options, Iterable<Sig> sigs,
                                     Command command) throws Err {
        return ScopeComputer.compute(reporter, options, sigs, command).a;
    }
}
