package is.fivefivefive.CanDis.ablation;

import java.util.LinkedHashSet;
import java.util.Set;

/** Conventional fixed-arity e-graph saturated with the shared Alloy rules. */
public final class RawEGraph implements AblationEngine {
    private static final int MAX_TERM_SIZE = 50_000;

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
            AlloyRewriteSystem.Pass leftPass = AlloyRewriteSystem.rewriteOnce(
                    leftFrontier, AlloyRewriteSystem.ArityMode.FIXED);
            AlloyRewriteSystem.Pass rightPass = AlloyRewriteSystem.rewriteOnce(
                    rightFrontier, AlloyRewriteSystem.ArityMode.FIXED);
            int roundApplications = leftPass.applications + rightPass.applications;
            if (roundApplications == 0) {
                break;
            }
            iterations++;
            applications += roundApplications;
            if (leftPass.applications > 0 && leftPass.term.size() <= MAX_TERM_SIZE) {
                leftFrontier = leftPass.term;
                graph.union(leftRoot, graph.add(leftFrontier));
                leftRoots.add(leftFrontier);
            }
            if (rightPass.applications > 0 && rightPass.term.size() <= MAX_TERM_SIZE) {
                rightFrontier = rightPass.term;
                graph.union(rightRoot, graph.add(rightFrontier));
                rightRoots.add(rightFrontier);
            }
            graph.rebuild();
        }

        boolean sameClass = graph.find(leftRoot) == graph.find(rightRoot);
        int distance = sameClass ? 0 : EGraphEditDistance.minimum(leftRoots, rightRoots);
        return new Result(distance, graph.stats(applications, iterations));
    }
}
