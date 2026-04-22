package is.fivefivefive.ACGN.alloy;
import is.fivefivefive.ACGN.asg.AugmentedNode;

public class LetSymbol extends RefSymbol {
    public LetSymbol(AugmentedNode n, String nm) {
        super(n, nm);
        setType("Let");
    }
}
