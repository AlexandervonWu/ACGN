package is.fivefivefive.CanDis.theory;

import java.util.ArrayList;
import java.util.List;

/** Step 1 of canon_G: replace invocation leaves by leaders without unfolding them. */
final class LeaderNormalizer {
    private LeaderNormalizer() {
    }

    static TypedENode normalize(
            TypedSlottedPortEGraph graph,
            TypedENode node) {
        List<PortValue> ports = new ArrayList<>(node.ports().size());
        for (PortValue port : node.ports()) {
            ports.add(normalizePort(graph, port));
        }
        return node.rebuildCanonicalCandidate(node.context(), ports);
    }

    private static PortValue normalizePort(
            TypedSlottedPortEGraph graph,
            PortValue port) {
        if (port instanceof OnePort) {
            OnePort one = (OnePort) port;
            if (one.leaf() instanceof SlotPortLeaf) {
                return one;
            }
            TypedInvocation invocation = ((InvocationPortLeaf) one.leaf()).invocation();
            TypedInvocation leader = graph.findForCanonicalization(
                    invocation).leaderInvocation();
            return new OnePort(
                    one.schema(),
                    one.context(),
                    new InvocationPortLeaf(leader));
        }
        if (port instanceof SeqPort) {
            SeqPort sequence = (SeqPort) port;
            return new SeqPort(
                    sequence.schema(),
                    sequence.context(),
                    normalizeElements(graph, sequence.elements()));
        }
        if (port instanceof BagPort) {
            BagPort bag = (BagPort) port;
            return new BagPort(
                    bag.schema(),
                    bag.context(),
                    normalizeElements(graph, bag.occurrences()));
        }
        if (port instanceof SetPort) {
            SetPort set = (SetPort) port;
            return new SetPort(
                    set.schema(),
                    set.context(),
                    normalizeElements(graph, set.elements()));
        }
        BindPort binder = (BindPort) port;
        return new BindPort(
                binder.schema(),
                binder.context(),
                binder.boundSlot(),
                normalizePort(graph, binder.body()));
    }

    private static List<PortValue> normalizeElements(
            TypedSlottedPortEGraph graph,
            List<PortValue> values) {
        List<PortValue> result = new ArrayList<>(values.size());
        for (PortValue value : values) {
            result.add(normalizePort(graph, value));
        }
        return result;
    }
}
