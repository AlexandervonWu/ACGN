package is.fivefivefive.ACGN.learn;

import java.util.List;
import java.util.ArrayList;

import is.fivefivefive.ACGN.asg.Multigraph;

public class Trainer {
    public static List<Double> pretrain(List<Multigraph> trainSet, List<Multigraph> validation, List<Double> init, double lr) {
        // TODO
        List<Double> weight = new ArrayList<Double>(init);
        for (Multigraph model : trainSet) {
            
        }
        return null;
    }
}
