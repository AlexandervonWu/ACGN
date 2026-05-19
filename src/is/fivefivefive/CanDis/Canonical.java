package is.fivefivefive.CanDis;

public class Canonical {
    // TODO:
    /** 
     * Create a canonical graph form for the predicates in terms of graphes
     * 1. Alpha-Normalize - replace variables by alpha-equivalent non-colliding hashing functions
     * 2. Sort children of commutative operators (BinaryExpr, BinaryFormula, ListExprOrFormula)
     *   :: AND OR PLUS INTERSECT IFF XOR ::
     * 3. De Morgan canonicalization - push all NOTs inward. NOT(A AND B) = NOT A OR NOT B; NOT(A OR B) = NOT A AND NOT B. 
     */
}
