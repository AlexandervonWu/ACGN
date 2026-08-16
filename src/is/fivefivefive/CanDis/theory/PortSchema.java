package is.fivefivefive.CanDis.theory;

import java.util.Map;
import java.util.Set;

/** The explicit port grammar from Definition 3. */
public sealed interface PortSchema permits
        OnePortSchema, SeqPortSchema, BagPortSchema, SetPortSchema, BindPortSchema {
    enum Kind {
        ONE,
        SEQ,
        BAG,
        SET,
        BIND
    }

    Kind kind();

    Set<String> typeVariables();

    PortSchema substitute(Map<String, GraphType> substitution);

    StructuralKey structuralKey();
}
