package is.fivefivefive.CanDis.ablation;

/** Plain syntactic e-graph: hash-consing only, without rewrites or rebuilding. */
public final class RawEGraph implements AblationEngine {
    @Override
    public Result compare(AlloyTerm left, AlloyTerm right) {
        IntEGraph graph = new IntEGraph();
        int leftRoot = graph.add(left);
        int rightRoot = graph.add(right);
        int distance = graph.find(leftRoot) == graph.find(rightRoot)
                ? 0
                : EGraphEditDistance.between(left, right);
        return new Result(distance, graph.stats(0, 0));
    }
}
