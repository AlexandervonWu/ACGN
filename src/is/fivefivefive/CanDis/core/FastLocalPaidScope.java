package is.fivefivefive.CanDis.core;

import java.util.*;
import is.fivefivefive.ACGN.alloy.ExactAlloyType;

/** Eligibility only: retained local binders are neither hoisted nor paid outer links. */
final class FastLocalPaidScope {
    private static final int MAX_VISITS = 4096;
    private static final int MAX_DEPTH = 128;
    private final Map<String,QuantiVar> locals = new HashMap<>();
    private final Set<String> usedOwners = new HashSet<>();
    private final Map<Long,LocalPlan> sourcePlans = new HashMap<>();
    private final Map<Long,QuantiVar> sourceVariables = new HashMap<>();
    private final ExactAlloyType module;
    private int visits;
    private boolean checkingSource = true;

    private record LocalPlan(QuantiVar binding,long declaration,long variable,EGraphNode domain) { }

    private FastLocalPaidScope(ExactAlloyType module) { this.module=module; }

    static boolean supports(NormalForm form) {
        var outer=new HashMap<String,QuantiVar>();
        for(var q:form.getMatrixQuantiVars()) if(outer.put(q.getName(),q)!=null) return false;
        if(outer.isEmpty()) return false;
        var check=new FastLocalPaidScope(form.getMatrixQuantiVars().get(0).getExactAlloyType());
        for(var q:form.getLocalQuantiVars()) {
            if(outer.containsKey(q.getName()) || check.locals.put(q.getName(),q)!=null) return false;
        }
        if(!check.walk(form.getCertificationMatrixEGraph(),outer,0,false) || check.sourcePlans.size()!=1) return false;
        check.checkingSource=false;
        check.usedOwners.clear();
        return check.walk(form.getMatrixEGraph(),outer,0,false) && check.usedOwners.size()==1;
    }

    private boolean typed(EGraphNode n,QuantiVar q) {
        var type=q.getExactAlloyType();
        return type!=null && type.hasParserAuthenticatedAncestry()
                && type.sharesParserModuleAuthorityWith(module)
                && type.sameOccurrenceEvidenceAs(n.getExactAlloyType());
    }

    private static QuantiVar.Quantifier localKind(EGraphNode.Opcode opcode) {
        return switch(opcode) {
            case FORALL -> QuantiVar.Quantifier.ALL;
            case EXISTS -> QuantiVar.Quantifier.SOME;
            case ONE -> QuantiVar.Quantifier.ONE;
            case LONE -> QuantiVar.Quantifier.LONE;
            default -> null;
        };
    }

    private boolean walk(EGraphNode n,Map<String,QuantiVar> visible,int depth,boolean inside) {
        if(++visits>MAX_VISITS || depth>MAX_DEPTH)
            throw new IllegalStateException("PAID_DECLARATION_LOCAL_SCOPE_BUDGET");
        if(n.getOpcode()==EGraphNode.Opcode.CALL || n.getOpcode()==EGraphNode.Opcode.REF) return false;
        if(n.getOpcode()==EGraphNode.Opcode.VARIABLE) {
            var q=visible.get(n.getAlphaName());
            if(q==null || !n.getChildren().isEmpty() || q.getExactAlloyType()==null
                    || !q.getExactAlloyType().hasParserAuthenticatedAncestry()
                    || !q.getExactAlloyType().sharesParserModuleAuthorityWith(module)
                    || !q.getExactAlloyType().equals(n.getExactAlloyType())) return false;
            // NormalForm's generated domain guards use synthetic type values.
            // Authority stays on the original scoped binding, never that value.
            if(n.getExactAlloyType().hasParserAuthenticatedAncestry() && !typed(n,q)) return false;
            if(checkingSource) {
                var prior=sourceVariables.putIfAbsent(n.getSourceOccurrenceLineage(),q);
                return prior==null || prior==q;
            }
            return sourceVariables.get(n.getSourceOccurrenceLineage())==q;
        }
        boolean declares=n.getChildren().stream().anyMatch(c->switch(c.getOpcode()) {
            case GENERICRELDECL,DISJ,VAR,DISJVAR -> true;
            default -> false;
        });
        if(declares || n.getOpcode()==EGraphNode.Opcode.EXISTS || n.getOpcode()==EGraphNode.Opcode.FORALL) {
            var kind=localKind(n.getOpcode());
            if(kind==null) return false;
            if(inside || n.getChildren().size()!=2) return false;
            var decl=n.getChildren().get(0);
            if(decl.getOpcode()!=EGraphNode.Opcode.GENERICRELDECL || decl.getChildren().size()!=2) return false;
            var domain=decl.getChildren().get(0); var variable=decl.getChildren().get(1);
            if(domain.getOpcode()!=EGraphNode.Opcode.ONE || domain.getChildren().size()!=1
                    || domain.getChildren().get(0).getOpcode()!=EGraphNode.Opcode.GLOBALBINDING
                    || !domain.getChildren().get(0).getChildren().isEmpty()
                    || variable.getOpcode()!=EGraphNode.Opcode.VARIABLE) return false;
            var plan=sourcePlans.get(n.getSourceOccurrenceLineage());
            var q=checkingSource ? locals.get(variable.getAlphaName()) : plan==null ? null : plan.binding();
            String name=variable.getAlphaName();
            if(q==null || name==null || !q.isFrozenForCertification() || visible.containsKey(name)
                    || q.getBindingPath().isEmpty() || q.getQuantifier()!=kind
                    || q.getCardinality()!=QuantiVar.Cardinality.ONE || q.getDisjointnessClass()!=0
                    || !typed(variable,q) || !typed(domain,q) || !typed(domain.getChildren().get(0),q)
                    || !usedOwners.add(q.getName())) return false;
            if(checkingSource) {
                if(!sourcePlans.isEmpty()) return false;
                sourcePlans.put(n.getSourceOccurrenceLineage(),new LocalPlan(q,decl.getSourceOccurrenceLineage(),
                        variable.getSourceOccurrenceLineage(),domain));
            } else if(plan.declaration()!=decl.getSourceOccurrenceLineage()
                    || plan.variable()!=variable.getSourceOccurrenceLineage()
                    || plan.domain().getSourceOccurrenceLineage()!=domain.getSourceOccurrenceLineage()
                    || plan.domain().getChildren().get(0).getSourceOccurrenceLineage()
                        !=domain.getChildren().get(0).getSourceOccurrenceLineage()
                    || !Objects.equals(plan.domain().getChildren().get(0).getSemanticIdentity(),
                        domain.getChildren().get(0).getSemanticIdentity())
                    || !Objects.equals(plan.domain().getChildren().get(0).getSourceName(),
                        domain.getChildren().get(0).getSourceName())) return false;
            // Fast's local spelling differs from the original alpha name. The
            // actual owner/declaration/variable lineage licenses that transfer.
            var scoped=new HashMap<>(visible); scoped.put(name,q);
            // The declaration variable is checked only in its owner's scope.
            return walk(variable,scoped,depth+1,true)
                    && walk(n.getChildren().get(1),scoped,depth+1,true);
        }
        switch(n.getOpcode()) {
            case GENERICRELDECL, DISJ, VAR, DISJVAR -> { return false; }
            default -> { }
        }
        for(var child:n.getChildren()) if(!walk(child,visible,depth+1,inside)) return false;
        return true;
    }
}
