package is.fivefivefive.ACGN.util;
import java.util.Map;
import java.util.Set;

import is.fivefivefive.ACGN.learn.Hyperparams;
import is.fivefivefive.AlloyDataProcessor.EdgeCounter;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.etc.Pair;
import is.fivefivefive.ACGN.alloy.Symbol;
import is.fivefivefive.ACGN.asg.AugmentedNode;
import is.fivefivefive.ACGN.etc.BiMap;

public class Probability {
    /**
     * Calculate the probabilities of candidates by their signatures using the softmax function.
     * @param gv Global variables containing the candidates.
     * @param uniqueNodes Unique nodes mapping symbols to their augmented nodes.
     * @param source The source symbol for which candidates are being evaluated.
     * @param position The position in the ASG where the source symbol is located.
     * @return An array of probabilities for each candidate symbol.
     */
    public static float[] probabilitiesBySignatures(GlobalVariables gv, BiMap<Symbol, AugmentedNode> uniqueNodes, Symbol source, int position) {
        // calculate by the softmax function
        final float TEMPERATURE = Hyperparams.TEMPERATURE;
        Set<Symbol> candidates = gv.getCandidates(source, position);
        if (candidates != null) {
            AugmentedNode sourceNode = uniqueNodes.get(source);
            if (sourceNode == null) {
                System.out.println("Source node not found for symbol: " + source);
                throw new RuntimeException("Source node not found for symbol: " + source.getName());
            }
            double sourceSig = sourceNode.getSignature();
            double sum = 0;
            int validCandidates = 0;
            for (Symbol candidate : candidates) {
                try {
                    // still not right! CANDIDATE MASK SHOULD BE PURGED BEFORE. 
                    //  Symbol candidateMask = EdgeCounter.getSymbolForPretrain(candidate);
                    if (!uniqueNodes.containsKey(candidate)) {
                        continue; // non-presenting symbols
                    }
                    double candidateSig = uniqueNodes.get(candidate).getSignature();
                    double diff = sourceSig - candidateSig;
                    double expDiff = Math.exp(diff / TEMPERATURE);
                    sum += expDiff;
                    validCandidates++;
                } catch(NullPointerException e) {
                    System.out.println(candidate.getType() + ",, " + candidate.getName());
                    throw e;
                }

            }
            float[] probabilities = new float[validCandidates];
            int i = 0;
            for (Symbol candidate : candidates) {
                // still not right! 
                //Symbol candidateMask = EdgeCounter.getSymbolForPretrain(candidate);
                if (!uniqueNodes.containsKey(candidate)) {
                    continue; // non-presenting symbols
                }
                double candidateSig = uniqueNodes.get(candidate).getSignature();
                double diff = sourceSig - candidateSig;
                double expDiff = Math.exp(diff / TEMPERATURE);
                probabilities[i] = (float) (expDiff / sum);
                System.out.println("Transitional Probability between " + source.getName() + " and " + candidate.getName() + " at position " + position + ": " + probabilities[i]);
                i++;
            }
            return probabilities;
        }

        return null;
    }

    /**
     * Normalize an array of Q-values using the softmax function.
     * @param qValues The array of Q-values to normalize.
     * @return An array of probabilities normalized by the softmax function.
     */
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
