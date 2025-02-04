package is.fivefivefive.ACGN.learn;

import java.util.List;
import java.util.LinkedList;
import java.util.Queue;
import java.util.ArrayList;

import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.asg.MASGEdge;
import is.fivefivefive.ACGN.asg.Multigraph;

/**
 * Trainer for the ASG.
 * Pretrain the ASG with a given learning rate and decay.
 * @param trainSet The training set of ASGs.
 * @param validation The validation set of ASGs.
 * @param init The initial signatures.
 * @param lrInit The initial learning rate.
 * @param lrDecay The decay rate of the learning rate, should be less than 1, 1 is no decay.
 * @return The final signatures.
 * @return The final signatures.
 */
public class Trainer {
    public static List<Double> pretrain(List<Multigraph> trainSet, List<Multigraph> validation, List<Double> init, double lrInit, double lrDecay) {
        // TODO: AI generated the basis, refactor. 
        double lr = lrInit;
        List<Double> signatures = new ArrayList<Double>(init);
        for (Multigraph model : trainSet) {
            AugmentedNode root = model.getRoot();
            Queue<MASGEdge> edgeQueue = new LinkedList<MASGEdge>();
            edgeQueue.addAll(root.getDownlinks());
            while (!edgeQueue.isEmpty()) {
                MASGEdge edge = edgeQueue.poll();
                AugmentedNode target = edge.getTarget();
                double targetSig = target.getSignature();
                double sourceSig = edge.getSource().getSignature();
                double diff = targetSig - sourceSig;
                double newSig = sourceSig + lr * diff;
                edge.getSource().setSignature(newSig);
                edgeQueue.addAll(target.getDownlinks());
            }
            lr *= lrDecay;
        }
        return signatures;
    }
}
