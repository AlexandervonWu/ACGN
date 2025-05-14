package is.fivefivefive.ACGN.util;
import java.util.Set;

import is.fivefivefive.ACGN.learn.Hyperparams;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;

public class Probability {
    public static float[] probabilitiesBySignatures(GlobalVariables gv, DoubleMap<Symbol, AugmentedNode> uniqueNodes, Symbol source, int position) {
        // calculate by the softmax function
        final float TEMPERATURE = Hyperparams.TEMPERATURE;
        Set<Symbol> candidates = gv.getCandidates(source, position);
        if (candidates != null) {
            AugmentedNode sourceNode = uniqueNodes.get(source);
            double sourceSig = sourceNode.getSignature();
            double sum = 0;
            for (Symbol candidate : candidates) {
                double candidateSig = uniqueNodes.get(candidate).getSignature();
                double diff = sourceSig - candidateSig;
                double expDiff = Math.exp(diff / TEMPERATURE);
                sum += expDiff;
            }
            float[] probabilities = new float[candidates.size()];
            int i = 0;
            for (Symbol candidate : candidates) {
                double candidateSig = uniqueNodes.get(candidate).getSignature();
                double diff = sourceSig - candidateSig;
                double expDiff = Math.exp(diff / TEMPERATURE);
                probabilities[i++] = (float) (expDiff / sum);
            }
            return probabilities;
        }

        return null;
    }

    public static float[] normalizeBySoftmax(float[] qValues) {
        // calculate by the softmax function
        double sum = 0;
        for (float qValue : qValues) {
            sum += Math.exp(qValue);
        }
        float[] probabilities = new float[qValues.length];
        for (int i = 0; i < qValues.length; i++) {
            probabilities[i] = (float) (Math.exp(qValues[i]) / sum);
        }
        return probabilities;
    }
}
