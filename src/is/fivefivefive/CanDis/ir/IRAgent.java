package is.fivefivefive.CanDis.ir;

import java.util.HashMap;
import java.util.Map;
import java.util.Queue;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;
import java.util.EmptyStackException;
import java.util.LinkedList;

import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.CanDis.macros.EGraphNode;
import is.fivefivefive.CanDis.macros.NormalForm;
import is.fivefivefive.CanDis.macros.EGraphNode.Metatype;
import is.fivefivefive.CanDis.macros.EGraphNode.Opcode;
import is.fivefivefive.CanDis.macros.NormalForm.TemporalOp;
import parser.etc.Pair;

public class IRAgent {
    private Multigraph graph;
    
    private List<NormalForm> nfs; // the normal forms from the graph in temporal logical operators order; 
    // try to normalize as much as possible from MASG to the normal form. Try prenexing. 

    public IRAgent(Multigraph graph) {
        this.graph = graph;
        this.nfs = new ArrayList<>();
    }

    public List<NormalForm> normalForms() {
        return nfs;
    }

    /**
     * Build the skeleton of the e-graph prior to rewriting;
     */
    public void computeNormalForm() {
        Map<AugmentedNode, Integer> tovTracker = new HashMap<>(); // track the time of visit
        AugmentedNode root = graph.getRoot();
        boolean negation = false;
        Map<Pair<AugmentedNode, Integer>, NormalForm> anchor = new HashMap<>(); // anchor each pair of (node, time of visit) to its normal form up to temporals
        Queue<AugmentedNode> queue = new LinkedList<>();
        Stack<EGraphNode> parseStack = new Stack<>();
        int id = 0;
        queue.add(root);
        while (!queue.isEmpty()) {
            AugmentedNode node = queue.poll();
            tovTracker.putIfAbsent(node, 0);
            int tov = tovTracker.get(node) + 1;
            tovTracker.put(node, tov);
            List<MASGEdge> downlinksAtTov = node.getDownlinksAtTimeOfVisit(graph, tov);
            Symbol symbol = node.getSymbol();
            NormalForm anchoredNF = null;
            if (!anchor.isEmpty()) {
                anchoredNF = anchor.get(Pair.of(node, tov));
            }
            switch (symbol.getClass().getSimpleName()) {
                case "PredRootSymbol":
                    NormalForm rootNf = new NormalForm();
                    anchor.put(Pair.of(node, tov), rootNf);
                    anchoredNF = rootNf;
                case "SigSymbol":
                case "FieldRelation":
                    EGraphNode sigOrFieldNode = new EGraphNode(id, Opcode.GLOBALBINDING, null, false, 0, false, Metatype.ATOMIC);
                    id++;
                    checkEmpty(parseStack);
                    parseStack.peek().addChild(sigOrFieldNode);
                case "VarSymbol":
                    EGraphNode varNode = new EGraphNode(id, Opcode.VARIABLE, null, false, 0, false, Metatype.ATOMIC);
                    id++;
                    checkEmpty(parseStack);
                    parseStack.peek().addChild(varNode);
                case "ConstSymbol":
                    EGraphNode constNode = new EGraphNode(id, Opcode.CONSTANT, null, false, 0, false, Metatype.ATOMIC);
                    id++;
                    checkEmpty(parseStack);
                    parseStack.peek().addChild(constNode);
                case "EndSymbol":
                    parseStack.pop();
                case "MiddleSymbol":
                    switch (node.getSyntactic()) {
                        case -127:
                            // RelDecl Roots; put decls into; TODO: Typechecking
                            switch ((int) Math.round(node.getSemantic())) {
                                case 1:
                                    
                            }
                        case -5: 
                        switch ((int) Math.round(node.getSemantic())) {
                            case 17: {
                                // RELEASES (LEFT AND RIGHT ANCHORS)
                                EGraphNode releasesEGN = new EGraphNode(id, Opcode.RELEASES, null, false, 0, false, Metatype.BOOLEAN);
                                if (!parseStack.isEmpty()) {
                                    parseStack.peek().addChild(releasesEGN);
                                }
                                id++;
                                NormalForm nfl = new NormalForm(anchoredNF, TemporalOp.RELEASESL, id);
                                id++;
                                NormalForm nfr = new NormalForm(anchoredNF, TemporalOp.RELEASESR, id);
                                id++;
                                parseStack.push(nfr.getMatrixEGraph());
                                parseStack.push(nfl.getMatrixEGraph());
                                AugmentedNode nl = downlinksAtTov.get(0).getTarget();
                                AugmentedNode nr = downlinksAtTov.get(1).getTarget();
                                anchor.put(Pair.of(nl, tovTracker.get(nl) + 1), nfl);
                                anchor.put(Pair.of(nr, tovTracker.get(nr) + 1), nfr);
                            }
                            case 18: {
                                // SINCE
                                EGraphNode sinceEGN = new EGraphNode(id, Opcode.SINCE, null, false, 0, false, Metatype.BOOLEAN);
                                if (!parseStack.isEmpty()) {
                                    parseStack.peek().addChild(sinceEGN);
                                }
                                id++;
                                NormalForm nfl = new NormalForm(anchoredNF, TemporalOp.SINCEL, id);
                                id++;
                                NormalForm nfr = new NormalForm(anchoredNF, TemporalOp.SINCER, id);
                                id++;
                                parseStack.push(nfr.getMatrixEGraph());
                                parseStack.push(nfl.getMatrixEGraph());
                                AugmentedNode nl = downlinksAtTov.get(0).getTarget();
                                AugmentedNode nr = downlinksAtTov.get(1).getTarget();
                                anchor.put(Pair.of(nl, tovTracker.get(nl) + 1), nfl);
                                anchor.put(Pair.of(nr, tovTracker.get(nr) + 1), nfr);
                            }
                            case 19: {
                                // TRIGGERED
                                EGraphNode triggeredEGN = new EGraphNode(id, Opcode.TRIGGERED, null, false, 0, false, Metatype.BOOLEAN);
                                if (!parseStack.isEmpty()) {
                                    parseStack.peek().addChild(triggeredEGN);
                                }
                                id++;
                                NormalForm nfl = new NormalForm(anchoredNF, TemporalOp.TRIGGEREDL, id);
                                id++;
                                NormalForm nfr = new NormalForm(anchoredNF, TemporalOp.TRIGGEREDR, id);
                                id++;
                                parseStack.push(nfr.getMatrixEGraph());
                                parseStack.push(nfl.getMatrixEGraph());
                                AugmentedNode nl = downlinksAtTov.get(0).getTarget();
                                AugmentedNode nr = downlinksAtTov.get(1).getTarget();
                                anchor.put(Pair.of(nl, tovTracker.get(nl) + 1), nfl);
                                anchor.put(Pair.of(nr, tovTracker.get(nr) + 1), nfr);
                            }
                            case 20: {
                                // UNTIL
                                EGraphNode untilEGN = new EGraphNode(id, Opcode.UNTIL, null, false, 0, false, Metatype.BOOLEAN);
                                if (!parseStack.isEmpty()) {
                                    parseStack.peek().addChild(untilEGN);
                                }
                                id++;
                                NormalForm nfl = new NormalForm(anchoredNF, TemporalOp.UNTILL, id);
                                id++;
                                NormalForm nfr = new NormalForm(anchoredNF, TemporalOp.UNTILR, id);
                                id++;
                                parseStack.push(nfr.getMatrixEGraph());
                                parseStack.push(nfl.getMatrixEGraph());
                                AugmentedNode nl = downlinksAtTov.get(0).getTarget();
                                AugmentedNode nr = downlinksAtTov.get(1).getTarget();
                                anchor.put(Pair.of(nl, tovTracker.get(nl) + 1), nfl);
                                anchor.put(Pair.of(nr, tovTracker.get(nr) + 1), nfr);
                            }
                        }
                    }
                }
            for (MASGEdge downlink : downlinksAtTov) {
                AugmentedNode target = downlink.getTarget();
                queue.add(target);
                if (!anchor.containsKey(Pair.of(target, tovTracker.get(target) + 1))) {
                    anchor.put(Pair.of(target, tovTracker.get(target) + 1), anchoredNF);
                }
            }
        }
    }

    private static boolean flip(boolean f) {
        return f ? false : true;
    }
    private static <E> void checkEmpty(Stack<E> stack) {
        if (stack.isEmpty()) {
            throw new EmptyStackException("Parent node not found");
        }
    }
    private static class EmptyStackException extends RuntimeException {
        public EmptyStackException(String message) {
            super(message);
        }
    }
}
