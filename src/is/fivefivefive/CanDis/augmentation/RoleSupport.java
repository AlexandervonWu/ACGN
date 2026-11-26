package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.ast.*;
import java.util.*;
import java.util.function.Function;
import static edu.mit.csail.sdg.ast.ExprBinary.Op.*;
import static edu.mit.csail.sdg.ast.ExprUnary.Op.*;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.binary;
import static is.fivefivefive.CanDis.augmentation.ScopedOperands.sub;

/** Typed existential counterexamples for owner restrictions and homogeneous rows. */
public final class RoleSupport {
    private RoleSupport() {}
    private enum Sort { OWNER, TARGET, OUTSIDE }
    private record V(Sort sort, int level) {}
    record Anchor(Sig.Field field, Sig role, Sig target, boolean mixed) {
        Sort domainSort() {return mixed?Sort.TARGET:Sort.OWNER;}
        Sort rangeSort() {return mixed?Sort.OWNER:Sort.TARGET;}
    }
    public record Result(String lowerQuery, String upperQuery, boolean onBad, boolean onGood) {
        public boolean matches() {return onBad && !onGood;}
    }
    record Limit(Sig carrier, boolean signed) {}
    record Conditional(Result result, Sig target, List<Limit> limits) {}
    private static final class Outside extends RuntimeException {
        private Outside() {super(null,null,false,false);}
    }
    private static void need(boolean p) {if (!p) throw new Outside();}
    private static Anchor anchor(Expr e) {
        var in=binary(e,IN);
        if(in==null || !(in.left.deNOP() instanceof Sig.Field f)) return null;
        var t=ScopedOperands.target(f); var p=binary(in.right,ARROW);
        if(t==null || f.sig==t || p==null || p.right.deNOP()!=t || !(p.left.deNOP() instanceof Sig.SubsetSig r)
                || r.parents.size()!=1 || r.parents.get(0)!=f.sig) return null;
        return new Anchor(f,r,t,false);
    }
    static Anchor mixedAnchor(Expr e) {
        if(!(e.deNOP() instanceof ExprQt q) || q.op!=ExprQt.Op.ALL || q.decls.size()!=1) return null;
        var d=q.decls.get(0);
        var domain=binary(ScopedOperands.singletonDomain(d),JOIN);var in=binary(q.sub,IN);
        if(domain==null || in==null || !(domain.left.deNOP() instanceof Sig.Field f) ||
                !(domain.right.deNOP() instanceof Sig role) || in.right.deNOP()!=role) return null;
        var t=ScopedOperands.target(f);var row=binary(in.left,JOIN);
        if(t==null || f.sig==t || row==null || row.left.deNOP()!=d.names.get(0) || row.right.deNOP()!=f) return null;
        boolean direct=role instanceof Sig.PrimSig r && r.parent==t ||
                role instanceof Sig.SubsetSig s && s.parents.size()==1 && s.parents.get(0)==t;
        return direct?new Anchor(f,role,t,true):null;
    }
    public static Optional<Result> inspect(Func a, Func b) {
        return read(a,b,0).map(Conditional::result);
    }
    static Optional<Conditional> read(Func a, Func b,int width) {
        return read(a,b,width,RoleSupport::anchor);
    }
    public static Optional<Result> inspectMixed(Func a, Func b) {
        return readMixed(a,b,0).map(Conditional::result);
    }
    static Optional<Conditional> readMixed(Func a,Func b,int width) {
        return read(a,b,width,RoleSupport::mixedAnchor);
    }
    private static Optional<Conditional> read(Func a, Func b,int width,Function<Expr,Anchor> find) {
        if(!a.isPred || !b.isPred || !a.decls.isEmpty() || !b.decls.isEmpty()) return Optional.empty();
        return readBodies(a.getBody(),b.getBody(),width,find);
    }
    static Optional<Conditional> mixedBodies(Expr a,Expr b,int width) {
        return readBodies(a,b,width,RoleSupport::mixedAnchor);
    }
    private static Optional<Conditional> readBodies(Expr a,Expr b,int width,Function<Expr,Anchor> find) {
        var k=find.apply(b); Expr source=a;
        if(k==null) {k=find.apply(source); source=b;}
        if(k==null) return Optional.empty();
        try {
            var reader=new Reader(k,width);var lo=reader.formula(source,false);
            reader.upper=true;
            var hi=reader.approximated ? reader.formula(source,false) : lo;
            var result=new Result(lo.lean(),hi.lean(),lo.test(k.mixed?Template.FORK:Template.BAD,List.of(),List.of()),
                    hi.test(k.mixed?Template.SEPARATED:Template.GOOD,List.of(),List.of()));
            return Optional.of(new Conditional(result,k.target,List.copyOf(reader.limits)));
        } catch(Outside e) {return Optional.empty();}
    }

    private enum Op { yes,no,role,edge,sameOwner,sameTarget,conj,disj,owner,target }
    private enum Template {
        BAD,GOOD,FORK,SEPARATED;
        boolean edge(boolean x,boolean y) {
            return switch(this) {case BAD,FORK -> true; case GOOD -> x; case SEPARATED -> x==y;};
        }
    }
    private record Q(Op op,int i,int j,Q l,Q r) {
        String lean() {
            return switch(op) {
                case yes,no -> "."+op;
                case role -> "(.role "+(i!=0)+" "+j+")";
                case sameOwner,sameTarget,edge -> "(."+op+" "+i+" "+j+")";
                case conj,disj -> "(."+op+" "+l.lean()+" "+r.lean()+")";
                case owner,target -> "(."+op+" "+l.lean()+")";
            };
        }
        boolean test(Template t,List<Boolean> xs,List<Boolean> ys) {
            return switch(op) {
                case yes -> true; case no -> false;
                case role -> xs.get(j)==(i!=0);
                case edge -> t.edge(xs.get(i),ys.get(j));
                case sameOwner -> xs.get(i).equals(xs.get(j)); case sameTarget -> ys.get(i).equals(ys.get(j));
                case conj -> l.test(t,xs,ys) && r.test(t,xs,ys);
                case disj -> l.test(t,xs,ys) || r.test(t,xs,ys);
                case target,owner -> {
                    boolean owner=op==Op.owner;
                    var more=new ArrayList<>(owner?xs:ys); more.add(0,false);
                    var left=owner?more:xs;var right=owner?ys:more;
                    if(l.test(t,left,right)) yield true;
                    more.set(0,true);yield (owner?t!=Template.BAD:t==Template.SEPARATED) && l.test(t,left,right);
                }
            };
        }
    }
    private static Q atom(Op op,int i,int j) {return new Q(op,i,j,null,null);}
    private static Q truth(boolean b) {return atom(b?Op.yes:Op.no,0,0);}
    private static Q combine(boolean and,Q a,Q b) {
        if(a.op==Op.yes || a.op==Op.no) return (a.op==Op.yes)==and ? b : a;
        if(b.op==Op.yes || b.op==Op.no) return (b.op==Op.yes)==and ? a : b;
        return a.equals(b)?a:new Q(and?Op.conj:Op.disj,0,0,a,b);
    }
    private static final class Reader {
        final Anchor k;
        final IdentityHashMap<ExprVar,V> env=new IdentityHashMap<>();
        final int[] depth=new int[2];
        final int width;
        final Set<Limit> limits=new LinkedHashSet<>();
        boolean upper,approximated;
        Reader(Anchor k,int width) {this.k=k;this.width=width;}
        int index(V v) {return depth[v.sort.ordinal()]-v.level-1;}
        Q bind(Sort s,Function<V,Q> body) {
            int level=depth[s.ordinal()]++;
            try {
                var q=body.apply(new V(s,level));
                return q.op==Op.no?q:new Q(s==Sort.OWNER?Op.owner:Op.target,0,0,q,null);
            }
            finally {depth[s.ordinal()]--;}
        }
        Sort[] sorts(Expr e) {
            var products=e.type().fold(); need(products.size()==1);
            var cols=products.get(0); var result=new Sort[cols.size()];
            for(int i=0;i<cols.size();i++){
                var c=cols.get(i); need(c==k.field.sig || c==k.target || k.mixed && c==k.role);
                result[i]=c==k.role?Sort.OWNER:c==k.target?k.rangeSort():k.domainSort();
            }
            return result;
        }
        V[] single(Expr src) {
            var e=src.deNOP();
            if(e instanceof ExprVar v) {need(env.containsKey(v));return new V[]{env.get(v)};}
            var p=binary(e,ARROW);
            if(p!=null) {
                var a=single(p.left);var b=single(p.right);
                if(a!=null && a.length==1 && b!=null && b.length==1) return new V[]{a[0],b[0]};
            }
            return null;
        }
        Q same(V x,V y,boolean pos) {
            need(x.sort!=Sort.OUTSIDE && y.sort!=Sort.OUTSIDE);
            if(x.sort!=y.sort || x.equals(y)) return truth(x.equals(y)==pos);
            if(pos)return atom(x.sort==Sort.OWNER?Op.sameOwner:Op.sameTarget,index(x),index(y));
            need(k.mixed);approximated=true;
            if(upper || x.sort!=Sort.OWNER)return truth(upper);
            return combine(false,combine(true,atom(Op.role,1,index(x)),atom(Op.role,0,index(y))),
                    combine(true,atom(Op.role,0,index(x)),atom(Op.role,1,index(y))));
        }
        Q tuples(Expr e,Function<V[],Q> f) {
            if(e.deNOP()==Sig.UNIV) {
                need(f.apply(new V[]{new V(Sort.OUTSIDE,-1)}).op==Op.no);
                return combine(false,bind(Sort.OWNER,x->f.apply(new V[]{x})),bind(Sort.TARGET,y->f.apply(new V[]{y})));
            }
            var v=single(e); if(v!=null) return f.apply(v);
            var ss=sorts(e);need(ss.length==1 || ss.length==2);
            Function<V[],Q> take=vs->combine(true,mem(e,vs,true),f.apply(vs));
            return bind(ss[0],x->ss.length==1?take.apply(new V[]{x}):bind(ss[1],y->take.apply(new V[]{x,y})));
        }
        Q join(ExprBinary b,V[] vs,boolean pos) {
            need(vs.length==1);
            boolean right=b.left.type().arity()==2 && b.right.type().arity()==1;
            need(right || b.left.type().arity()==1 && b.right.type().arity()==2);
            var set=right?b.right:b.left;var rel=right?b.left:b.right;
            Function<V,Q> edge=z->mem(rel,right?new V[]{vs[0],z}:new V[]{z,vs[0]},pos);
            var v=single(set);
            if(v!=null) return edge.apply(v[0]);
            need(pos);return tuples(set,z->edge.apply(z[0]));
        }
        Q mem(Expr src,V[] vs,boolean pos) {
            var e=src.deNOP();
            if(e==Sig.NONE) return truth(!pos);
            var v=single(e);
            if(v!=null) {
                need(v.length==vs.length);Q q=truth(pos);
                for(int i=0;i<v.length;i++) q=combine(pos,q,same(v[i],vs[i],pos));return q;
            }
            if(e instanceof Sig s) {
                need(vs.length==1);var x=vs[0];
                if(s==Sig.UNIV)return truth(pos);
                if(s==k.role) return x.sort==Sort.OWNER?atom(Op.role,pos?1:0,index(x)):truth(!pos);
                need(s==k.field.sig || s==k.target);
                return truth((x.sort==(s==k.target?k.rangeSort():k.domainSort()))==pos);
            }
            if(e instanceof Sig.Field f) {
                need(f==k.field && vs.length==2);
                if(vs[0].sort!=k.domainSort() || vs[1].sort!=k.rangeSort()) return truth(!pos);
                need(pos);return atom(Op.edge,index(vs[k.mixed?1:0]),index(vs[k.mixed?0:1]));
            }
            var reverse=sub(e,TRANSPOSE);
            if(reverse!=null) {need(vs.length==2);return mem(reverse,new V[]{vs[1],vs[0]},pos);}
            if(k.mixed && sub(e,CLOSURE)==k.field)return mem(k.field,vs,pos); // Disjoint declared endpoints.
            if(!(e instanceof ExprBinary b)) throw new Outside();
            return switch(b.op) {
                case MINUS,INTERSECT,PLUS -> combine((b.op!=PLUS)==pos,mem(b.left,vs,pos),mem(b.right,vs,b.op==MINUS?!pos:pos));
                case JOIN -> join(b,vs,pos);
                case ARROW -> {need(vs.length==2);yield combine(pos,mem(b.left,new V[]{vs[0]},pos),mem(b.right,new V[]{vs[1]},pos));}
                case DOMAIN,RANGE -> {
                    if(k.mixed && vs.length==1) {need(e.type().arity()==1);yield combine(pos,mem(b.left,vs,pos),mem(b.right,vs,pos));}
                    need(vs.length==2);boolean d=b.op==DOMAIN;
                    yield combine(pos,mem(d?b.left:b.right,new V[]{vs[d?0:1]},pos),mem(d?b.right:b.left,vs,pos));
                }
                default -> throw new Outside();
            };
        }
        Q nonempty(Expr e,boolean pos) {
            if(e.deNOP()==Sig.NONE) return truth(!pos);
            var m=binary(e,INTERSECT);
            if(m!=null) {
                var v=single(m.left);if(v!=null)return mem(m.right,v,pos);
                v=single(m.right);if(v!=null)return mem(m.left,v,pos);
            }
            need(pos);return tuples(e,vs->truth(true));
        }
        Q inclusion(Expr a,Expr b,boolean pos) {
            var union=binary(a,PLUS);
            if(k.mixed && union!=null)return combine(pos,inclusion(union.left,b,pos),inclusion(union.right,b,pos));
            var v=single(a);if(v!=null)return mem(b,v,pos);
            if(a.deNOP()==b.deNOP() || a.deNOP()==Sig.NONE) return truth(pos);
            var restrict=binary(a,DOMAIN);
            if(restrict!=null && restrict.right.deNOP()==b.deNOP())return truth(pos);
            if(b.deNOP()==Sig.NONE)return nonempty(a,!pos);
            var restricted=binary(b,DOMAIN);
            if(!pos && restricted!=null && restricted.right.deNOP()==a.deNOP())
                return tuples(a,vs->mem(restricted.left,new V[]{vs[0]},false));
            need(!pos);return tuples(a,vs->mem(b,vs,false));
        }
        private enum Slice {FULL,SELECTED,OTHER}
        private record Row(ExprVar owner,Expr full,Slice slice) {}
        Row row(Expr e) {
            if(e==null)return null;
            Slice slice=Slice.FULL;
            if(e.deNOP() instanceof ExprBinary m && (m.op==INTERSECT || m.op==MINUS)) {
                if(m.right.deNOP()==k.role)e=m.left;
                else if(m.op==INTERSECT && m.left.deNOP()==k.role)e=m.right;
                else return null;
                slice=m.op==MINUS?Slice.OTHER:Slice.SELECTED;
            }
            var j=binary(e,JOIN);
            if(j==null || !(j.left.deNOP() instanceof ExprVar u) || j.right.deNOP()!=k.field ||
                    !env.containsKey(u) || env.get(u).sort!=k.domainSort())return null;
            return new Row(u,e,slice);
        }
        Q rowEquality(Expr a,Expr b,boolean eq,boolean counts) {
            var x=row(a);var y=row(b);
            if(x==null || y==null || x.owner!=y.owner || x.slice==y.slice)return null;
            var part=x.slice==Slice.FULL?y:x;
            if(x.slice!=Slice.FULL && y.slice!=Slice.FULL)return null;
            need(!eq); // A witness missing from the filtered row.
            boolean removedSelected=part.slice==Slice.OTHER;
            if(counts)limits.add(new Limit(removedSelected?k.role:k.target,false));
            return tuples(part.full,vs->mem(k.role,vs,removedSelected));
        }
        Q decls(ExprQt q,int d,int n,boolean pos) {
            if(d==q.decls.size()) return formula(q.sub,pos);
            var decl=q.decls.get(d);
            need(decl.disjoint==null && decl.disjoint2==null && decl.isVar==null);
            var domain=sub(decl.expr,ONEOF); need(domain!=null && domain.type().arity()==1);
            var name=decl.names.get(n);need(name instanceof ExprVar && !env.containsKey(name));
            return tuples(domain,vs->{
                env.put((ExprVar)name,vs[0]);
                try {return n+1==decl.names.size()?decls(q,d+1,0,pos):decls(q,d,n+1,pos);}
                finally {env.remove(name);}
            });
        }
        Q formula(Expr src,boolean pos) {
            var e=src.deNOP();
            if(e instanceof ExprQt q) {
                if(k.mixed && q.op==ExprQt.Op.NO && !pos)return decls(q,0,0,true);
                need(q.op==(pos?ExprQt.Op.SOME:ExprQt.Op.ALL));return decls(q,0,0,pos);
            }
            if(e instanceof ExprUnary u) return switch(u.op) {
                case NOT -> formula(u.sub,!pos);
                case NO,SOME -> nonempty(u.sub,(u.op==SOME)==pos);
                default -> throw new Outside();
            };
            if(e instanceof ExprList l) {
                need(l.op==ExprList.Op.AND || l.op==ExprList.Op.OR);
                boolean and=(l.op==ExprList.Op.AND)==pos;Q q=truth(and);
                for(var arg:l.args) q=combine(and,q,formula(arg,pos));return q;
            }
            if(!(e instanceof ExprBinary b)) throw new Outside();
            if(width>=2 && width<=32) {
                var ct=CardinalityThreshold.inclusiveAtom(e,width).orElse(null);
                if(ct!=null) {
                    boolean occupied=ct.comparison()==GTE && ct.literal()==1;
                    boolean nonzero=k.mixed && ct.comparison()==NOT_EQUALS && ct.literal()==0;
                    need(occupied || nonzero || ct.comparison()==EQUALS && ct.literal()==0);
                    var r=row(ct.relation());need(r!=null && (k.mixed || r.slice==Slice.FULL));
                    limits.add(new Limit(r.slice==Slice.SELECTED?k.role:k.target,occupied));
                    return nonempty(ct.relation(),pos==(occupied || nonzero));
                }
            }
            return switch(b.op) {
                case IN,NOT_IN -> inclusion(b.left,b.right,(b.op==IN)==pos);
                case IMPLIES -> combine(!pos,formula(b.left,!pos),formula(b.right,pos));
                case AND,OR -> combine((b.op==AND)==pos,formula(b.left,pos),formula(b.right,pos));
                case EQUALS, NOT_EQUALS -> {
                    boolean eq=(b.op==EQUALS)==pos;
                    if(k.mixed) {
                        var z=rowEquality(b.left,b.right,eq,false);
                        if(z==null && width>=2 && width<=32)
                            z=rowEquality(sub(b.left,CARDINALITY),sub(b.right,CARDINALITY),eq,true);
                        if(z!=null)yield z;
                    }
                    if(b.left.deNOP()==Sig.NONE || b.right.deNOP()==Sig.NONE)
                        yield nonempty(b.left.deNOP()==Sig.NONE?b.right:b.left,!eq);
                    if(eq && !k.mixed) {
                        var y=single(b.right);var row=binary(b.left,JOIN);
                        if(y==null) {y=single(b.left);row=binary(b.right,JOIN);}
                        if(y!=null && y.length==1 && y[0].sort==Sort.TARGET && row!=null &&
                                row.right.deNOP()==k.field && single(row.left)!=null) {
                            approximated=true;
                            yield upper ? mem(row,y,true) : truth(false);
                        }
                    }
                    yield combine(eq,inclusion(b.left,b.right,eq),inclusion(b.right,b.left,eq));
                }
                default -> throw new Outside();
            };
        }
    }
}
