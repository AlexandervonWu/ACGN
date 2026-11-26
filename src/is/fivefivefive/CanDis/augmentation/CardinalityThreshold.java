package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.Optional;

/** A local, parsed comparison. Reading it does not authorize a multiplicity rewrite. */
public final class CardinalityThreshold {
    private CardinalityThreshold() {}

    public record Read(Expr relation, ExprBinary.Op comparison, int literal, int bitwidth) {}

    /** Read an inclusive bound (or an AND whose complete signed interval is a single point). */
    public static Optional<Read> readInclusive(Expr formula, Command command) {
        return readInclusive(formula, command.bitwidth);
    }

    static Optional<Read> readInclusive(Expr formula, int width) {
        var e=formula.deNOP();
        if (isAnd(e)) {
            var i=readInterval(e,width);
            return i!=null && i.lo==i.hi ? Optional.of(new Read(i.relation,ExprBinary.Op.EQUALS,i.lo,width)) : Optional.empty();
        }
        return inclusiveAtom(e,width);
    }

    static Optional<Read> inclusiveAtom(Expr formula, int width) {
        return read(formula, width).map(CardinalityThreshold::inclusive);
    }

    static Read inclusive(Read q) {
        var b=inclusive(q.comparison(),q.literal(),q.bitwidth());
        return b.comparison==q.comparison()?q:new Read(q.relation(),b.comparison,b.literal,q.bitwidth());
    }

    record Bound(ExprBinary.Op comparison,int literal) {}
    static Bound inclusive(ExprBinary.Op op,int k,int width) {
        long half=1L<<(width-1);
        if(op==ExprBinary.Op.GT && k<half-1) return new Bound(ExprBinary.Op.GTE,k+1);
        if(op==ExprBinary.Op.LT && k> -half) return new Bound(ExprBinary.Op.LTE,k-1);
        return new Bound(op,k);
    }

    record Interval(Expr relation, int lo, int hi) {
        boolean is(long lower,long upper) { return lo==lower && hi==upper; }
        Interval meet(Interval other) {
            if (other==null || !sameOperand(relation,other.relation)) return null;
            int l=Math.max(lo,other.lo), h=Math.min(hi,other.hi);
            return l<=h ? new Interval(relation,l,h) : null;
        }
    }

    private static boolean isAnd(Expr e) {
        return e instanceof ExprList l && l.op==ExprList.Op.AND || e instanceof ExprBinary b && b.op==ExprBinary.Op.AND;
    }

    // Unlike printed names, resolved leaves identify the field and binder. Prime is an operator.
    private static boolean sameOperand(Expr a, Expr b) {
        a=a.deNOP(); b=b.deNOP();
        if (a==b) return true;
        if (!a.type().equals(b.type())) return false;
        if (a instanceof ExprBinary x && b instanceof ExprBinary y)
            return x.op==y.op && sameOperand(x.left,y.left) && sameOperand(x.right,y.right);
        if (a instanceof ExprUnary x && b instanceof ExprUnary y)
            return x.op==y.op && sameOperand(x.sub,y.sub);
        return a instanceof ExprConstant && a.isSame(b);
    }

    static Interval readInterval(Expr formula,int width) {
        var e=formula.deNOP();
        if (e instanceof ExprList l && l.op==ExprList.Op.AND && !l.args.isEmpty()) {
            var i=readInterval(l.args.get(0),width);
            for (int n=1;i!=null && n<l.args.size();n++) i=i.meet(readInterval(l.args.get(n),width));
            return i;
        }
        if (e instanceof ExprBinary b && b.op==ExprBinary.Op.AND) {
            var i=readInterval(b.left,width);
            return i==null ? null : i.meet(readInterval(b.right,width));
        }
        var q=inclusiveAtom(e,width).orElse(null);
        if (q==null) return null;
        long half=1L<<(width-1);
        return switch(q.comparison) {
            case EQUALS -> new Interval(q.relation,q.literal,q.literal);
            case GTE -> new Interval(q.relation,q.literal,(int)(half-1));
            case LTE -> new Interval(q.relation,(int)-half,q.literal);
            default -> null;
        };
    }

    public static Optional<Read> read(Expr formula, Command command) {
        return read(formula, command.bitwidth);
    }

    static Optional<Read> read(Expr formula, int width) {
        if (width<1 || width>32) return Optional.empty();
        var expression=formula.deNOP();
        boolean negated=false;
        while (expression instanceof ExprUnary u && u.op==ExprUnary.Op.NOT) {
            negated=!negated;
            expression=u.sub.deNOP();
        }
        if (!(expression instanceof ExprBinary b)) return Optional.empty();
        Expr count=b.left.deNOP(), literal=b.right.deNOP();
        boolean reversed=count instanceof ExprConstant;
        if (reversed) { literal=count; count=b.right.deNOP(); }
        if (!(count instanceof ExprUnary u) || u.op!=ExprUnary.Op.CARDINALITY ||
                !(literal instanceof ExprConstant k) || k.op!=ExprConstant.Op.NUMBER) return Optional.empty();
        long half=1L << (width-1);
        if (k.num < -half || k.num >= half) return Optional.empty();
        var op=switch (b.op) {
            case EQUALS, NOT_EQUALS -> b.op;
            case LT -> reversed ? ExprBinary.Op.GT : b.op;
            case LTE -> reversed ? ExprBinary.Op.GTE : b.op;
            case GT -> reversed ? ExprBinary.Op.LT : b.op;
            case GTE -> reversed ? ExprBinary.Op.LTE : b.op;
            default -> null;
        };
        if (op==null) return Optional.empty();
        return Optional.of(new Read(u.sub.deNOP(),negated ? complement(op) : op,k.num,width));
    }

    static ExprBinary.Op complement(ExprBinary.Op op) {
        return switch (op) {
            case EQUALS -> ExprBinary.Op.NOT_EQUALS; case NOT_EQUALS -> ExprBinary.Op.EQUALS;
            case LT -> ExprBinary.Op.GTE; case LTE -> ExprBinary.Op.GT;
            case GT -> ExprBinary.Op.LTE; case GTE -> ExprBinary.Op.LT;
            default -> throw new IllegalArgumentException("Not a comparison: "+op);
        };
    }
}
