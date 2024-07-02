package is.fivefivefive.ACGN.asg;
// import com.abdulfatir.jcomplexnumber.ComplexNumber;

/*
 * An edge in the naive, intermediate Multi-ASG. 
 */
public class MASGEdge {
    private int position;
    private int timeOfVisit;
    private AugmentedNode source;
    private AugmentedNode target;
    public MASGEdge(AugmentedNode source, AugmentedNode target, int position, int timeOfVisit) {
        this.position = position;
        this.timeOfVisit = timeOfVisit;
        this.source = source;
        this.target = target;
    }
    public int getPosition() {
        return position;
    }
    public int getTimeOfVisit() {
        return timeOfVisit;
    }
    public AugmentedNode getSource() {
        return source;
    }
    public AugmentedNode getTarget() {
        return target;
    }
    public double getSignatureDiff() {
        return target.getSignature() - source.getSignature();
    }
    public int logEdgeLength() {
        return position * (timeOfVisit - 1);
    }
    @Override
    public boolean equals(Object o) {
        if (o instanceof MASGEdge) {
            MASGEdge e = (MASGEdge) o;
            return e.getSource().equals(source) && e.getTarget().equals(target) && e.getPosition() == position && e.getTimeOfVisit() == timeOfVisit;
        }
        return false;
    }
}
