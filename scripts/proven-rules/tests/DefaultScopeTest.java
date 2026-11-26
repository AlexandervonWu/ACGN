package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.parser.CompUtil;
import java.nio.file.*;
import java.util.*;

/** Changing the selected command must not change a structural key or confer equality on a peer. */
public final class DefaultScopeTest {
    private static void need(boolean check, String message) {
        if (!check) throw new AssertionError(message);
    }
    private static String digest(Path file) throws Exception {
        var loaded = new HashMap<String,String>();
        CompUtil.parseEverything_fromFile(A4Reporter.NOP, loaded, file.toRealPath().toString());
        return ScopedPoolEndpoint.closureDigest(loaded);
    }
    public static void main(String[] args) throws Exception {
        String predicates = ClassifierControls.BASE + "pred a {" + ClassifierControls.A + "}\n"
                + "pred b {" + ClassifierControls.B + "}\n";
        String small = "check small {a iff b}" + ClassifierControls.SMALL + "\n";
        String wide = "check wide {b iff a}" + ClassifierControls.EIGHT + "\n";
        var module = CompUtil.parseEverything_fromString(A4Reporter.NOP, predicates + small + wide
                + wide.replace("wide", "widerInt").replace("4 Int", "5 Int")
                + "check notIff {a implies b}" + ClassifierControls.SMALL);
        var decisions = CommandComparison.compare(module, "a", "b");
        need(decisions.equals(CommandComparison.compare(module, "b", "a")), "endpoint order");
        need(decisions.size() == 3 && CommandComparison.compare(module, "a", "missing").isEmpty(), "command binding");
        need(decisions.get(0).matched() && decisions.get(0).json(11).getInt("comparisonDistance") == 0, "small");
        need(!decisions.get(1).matched() && decisions.get(1).json(11).getInt("comparisonDistance") == 11
                && ScopedFiberRun.execute(module, 1).solution().satisfiable(), "signed overflow counterexample");
        need(decisions.get(2).matched() && decisions.get(2).bitwidth() == 5, "recovered at five bits");

        Path left = Path.of(args[0]), right = left.resolveSibling("peer.als");
        Files.writeString(left, predicates + small);
        Files.writeString(right, predicates + small);
        var a = ScopedPoolEndpoint.read(left, "a", "b", 0, digest(left));
        String sha = digest(right);
        var b = ScopedPoolEndpoint.read(right, "b", "a", 1, sha);
        need(ScopedPoolEndpoint.compare(a, b).orElseThrow().matched(), "cross-file source match");
        Files.writeString(right, predicates + wide);
        try {
            ScopedPoolEndpoint.read(right, "b", "a", 1, sha);
            throw new AssertionError("accepted replaced source");
        } catch (IllegalArgumentException expected) {
            need(expected.getMessage().contains("differs from the original"), "unexpected source failure");
        }
        b = ScopedPoolEndpoint.read(right, "b", "a", 1, digest(right));
        need(ScopedPoolEndpoint.compare(a, b).isEmpty(), "different commands were combined");
        Files.writeString(right, predicates + small + wide);
        need(ScopedPoolEndpoint.read(right, "b", "a", 1, digest(right)) == null, "ambiguous command");
        Files.writeString(right, predicates + "fact { b }\n" + small);
        need(ScopedPoolEndpoint.read(right, "b", "a", 1, digest(right)) == null,
                "fact calling relocated predicate should leave the structural result intact");
        System.out.println("Default source and pool scope controls passed");
    }
}
