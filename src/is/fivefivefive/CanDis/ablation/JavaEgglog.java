package is.fivefivefive.CanDis.ablation;

import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Java replica of egglog's core execution model: constructor/function-table
 * hash-consing, union facts, semi-naive rule rounds, and congruence rebuilding.
 * It intentionally implements the core needed by this Alloy ablation rather
 * than egglog's textual language front end.
 */
public final class JavaEgglog implements AblationEngine {
    private static final int MAX_TERM_SIZE = 50_000;

    /** Returns the fixed-point representative used by the Alloy rewrite program. */
    public static AlloyTerm normalForm(AlloyTerm term) {
        AlloyTerm current = term;
        for (int iteration = 0; iteration < AlloyRewriteSystem.MAX_ITERATIONS; iteration++) {
            AlloyRewriteSystem.Pass pass = AlloyRewriteSystem.rewriteOnce(current);
            if (pass.applications == 0 || pass.term.size() > MAX_TERM_SIZE) {
                return current;
            }
            current = pass.term;
        }
        return current;
    }

    @Override
    public Result compare(AlloyTerm left, AlloyTerm right) {
        IntEGraph graph = new IntEGraph();
        int leftRoot = graph.add(left);
        int rightRoot = graph.add(right);
        AlloyTerm leftFrontier = left;
        AlloyTerm rightFrontier = right;
        Set<AlloyTerm> leftRoots = new LinkedHashSet<>();
        Set<AlloyTerm> rightRoots = new LinkedHashSet<>();
        leftRoots.add(left);
        rightRoots.add(right);
        long applications = 0;
        long iterations = 0;

        for (int iteration = 0; iteration < AlloyRewriteSystem.MAX_ITERATIONS; iteration++) {
            AlloyRewriteSystem.Pass leftPass = AlloyRewriteSystem.rewriteOnce(leftFrontier);
            AlloyRewriteSystem.Pass rightPass = AlloyRewriteSystem.rewriteOnce(rightFrontier);
            int roundApplications = leftPass.applications + rightPass.applications;
            if (roundApplications == 0) {
                break;
            }
            iterations++;
            applications += roundApplications;
            if (leftPass.term.size() <= MAX_TERM_SIZE && leftPass.applications > 0) {
                graph.union(leftRoot, graph.add(leftPass.term));
                leftFrontier = leftPass.term;
                leftRoots.add(leftFrontier);
            }
            if (rightPass.term.size() <= MAX_TERM_SIZE && rightPass.applications > 0) {
                graph.union(rightRoot, graph.add(rightPass.term));
                rightFrontier = rightPass.term;
                rightRoots.add(rightFrontier);
            }
            graph.rebuild();
        }

        boolean sameClass = graph.find(leftRoot) == graph.find(rightRoot);
        int distance = sameClass ? 0 : EGraphEditDistance.minimum(leftRoots, rightRoots);
        return new Result(distance, graph.stats(applications, iterations));
    }
}
