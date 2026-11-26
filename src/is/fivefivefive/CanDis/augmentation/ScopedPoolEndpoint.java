package is.fivefivefive.CanDis.augmentation;

import edu.mit.csail.sdg.alloy4.*;
import edu.mit.csail.sdg.ast.*;
import edu.mit.csail.sdg.parser.*;
import java.io.StringReader;
import java.nio.file.Path;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.*;
import org.json.JSONArray;

/** Source relocation checks shared by the default correct-reference pool comparison. */
public final class ScopedPoolEndpoint {
    private ScopedPoolEndpoint() {}
    private static void need(boolean value,String why) { if(!value) throw new IllegalArgumentException(why); }
    private static String digest(String s) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8)));
    }
    public static String closureDigest(Map<String,String> parsed) throws Exception {
        var members=new JSONArray();
        for(var entry:new TreeMap<>(parsed).entrySet()) members.put(arr(entry.getKey(),digest(entry.getValue())));
        return digest(members.toString());
    }
    static JSONArray arr(Object... xs){return new JSONArray(Arrays.asList(xs));}
    static String local(String label,String prefix){
        return !prefix.isEmpty() && label.startsWith("this/"+prefix)?"this/"+label.substring(5+prefix.length()):label;
    }
    static JSONArray decls(Iterable<Decl> ds,List<Expr> env,String p){
        var a=new JSONArray();
        for(var d:ds){
            var ns=new JSONArray();
            var domain=key(d.expr,env,p);
            for(var x:d.names){ns.put(x.type().toString());env.add(x);}
            a.put(arr(domain,ns,d.disjoint!=null,d.disjoint2!=null,d.isPrivate!=null,d.isVar!=null));
        }
        return a;
    }
    static Object key(Expr e,List<Expr> env,String p){
        e=e.deNOP();
        var a=arr(e.getClass().getSimpleName(),e.type().toString());
        if(e instanceof Sig.Field f)return a.put(f.sig.label).put(f.label);
        if(e instanceof Sig s)return a.put(s.label);
        if(e instanceof ExprVar){for(int i=env.size()-1;i>=0;i--)if(env.get(i)==e)return a.put(i);throw new IllegalArgumentException("free binder "+e);}
        if(e instanceof ExprConstant c)return a.put(c.op.name()).put(c.num).put(Objects.toString(c.string,""));
        if(e instanceof ExprUnary u)return a.put(u.op.name()).put(key(u.sub,env,p));
        if(e instanceof ExprBinary b)return a.put(b.op.name()).put(key(b.left,env,p)).put(key(b.right,env,p));
        if(e instanceof ExprCall c){a.put(local(c.fun.label,p));for(var v:c.args)a.put(key(v,env,p));return a;}
        if(e instanceof ExprList l){a.put(l.op.name());for(var v:l.args)a.put(key(v,env,p));return a;}
        if(e instanceof ExprITE i)return a.put(key(i.cond,env,p)).put(key(i.left,env,p)).put(key(i.right,env,p));
        if(e instanceof ExprLet l){a.put(key(l.expr,env,p));var n=new ArrayList<>(env);n.add(l.var);return a.put(key(l.sub,n,p));}
        if(e instanceof ExprQt q){var n=new ArrayList<>(env);return a.put(q.op.name()).put(decls(q.decls,n,p)).put(key(q.sub,n,p));}
        throw new IllegalArgumentException("missing typed source projection "+e.getClass());
    }
    static String function(Func f,String p)throws Exception{
        var env=new ArrayList<Expr>();
        return digest(arr(local(f.label,p),f.isPred,decls(f.decls,env,p),
             f.isPred?"pred":key(f.returnDecl,env,p),key(f.getBody(),env,p)).toString());
    }
    static String scope(Command c){
        need(c.parent==null && c.getGrowableSigs().isEmpty(),"requires fixed original command");
        return arr(c.check,c.overall,c.bitwidth,c.maxseq,c.minprefix,c.maxprefix,c.maxstring,c.expects,
                c.scope.toString(),c.additionalExactScopes.toString()).toString();
    }
    static final String PREFIX="acgnPoolRef";
    static CompLexer lexer(String src,CompModule m){var l=new CompLexer(new StringReader(src));l.alloy_module=m;l.alloy_filename=m.pos().filename;l.alloy_seenDollar=new ArrayList<>();return l;}
    static String rename(String text,CompModule m,Set<String> names,String prefix)throws Exception{
        var lexer=lexer(text,m);var b=new StringBuilder();int last=0;
        for(var s=lexer.next_token();s.sym!=CompSym.EOF;s=lexer.next_token()){
            String t=lexer.yytext();
            if(!names.contains(t))continue;
            int[] ix=s.pos.toStartEnd(text);
            need(text.substring(ix[0],ix[1]).equals(t),"unbound token");
            b.append(text,last,ix[0]).append(prefix).append(t);last=ix[1];
        }
        return b.append(text,last,text.length()).toString();
    }

    private record Bounds(Map<String,Integer> caps,int bits,int min,int max,boolean temporal) {
        static Bounds of(ScopedFiberRun f) {
            return new Bounds(f.carrierBounds(),f.solution().getBitwidth(),f.solution().getMinTrace(),
                    f.solution().getMaxTrace(),f.solution().getMaxTrace()>0);
        }
        boolean compatible(Bounds source, boolean staticCarriers) {
            return caps.equals(source.caps) && bits==source.bits && (min==source.min && max==source.max ||
                    temporal!=source.temporal && staticCarriers);
        }
    }
    public static final class Endpoint {
        private final Path file;
        private final String prefix, pred, base, code, context, facts, scope, suffix;
        private final Map<String,String> deps, bindings;
        private final Bounds bounds;
        private Endpoint(Path f,String p,String name,String base,String code,String ctx,String facts,String scope,
                         String suffix,Map<String,String> deps,Map<String,String> bindings,Bounds bounds) {
            this.file=f; this.prefix=p; this.pred=p+name; this.base=base; this.code=code; this.context=ctx;
            this.facts=facts; this.scope=scope; this.suffix=suffix; this.deps=Map.copyOf(deps);
            this.bindings=Map.copyOf(bindings); this.bounds=bounds;
        }
    }
    private static String context(String base,CompModule module,Set<String> forbidden) throws Exception {
        var tokens=new JSONArray(); var lex=lexer(base,module);
        for(var t=lex.next_token();t.sym!=CompSym.EOF;t=lex.next_token()) {
            // A fact that calls a relocated helper is valid input, but this relocation cannot bind it.
            if (forbidden.contains(lex.yytext())) return null;
            tokens.put(arr(t.sym,lex.yytext()));
        }
        return digest(tokens.toString());
    }
    private static void checkOpens(CompModule module,Map<String,String> loaded) {
        for(var m:module.getAllReachableModules()) for(var o:m.getOpens())
            need(o.getRealModule()!=null && loaded.containsKey(o.getRealModule().pos().filename),"unresolved dependency");
    }
    public static Endpoint read(Path source,String selected,String peer,int id,String expectedClosure) throws Exception {
        Path path=source.toRealPath(); var deps=new HashMap<String,String>();
        var m=CompUtil.parseEverything_fromFile(A4Reporter.NOP,deps,path.toString());
        need(closureDigest(deps).equals(expectedClosure),"source or dependency differs from the original reference");
        checkOpens(m,deps);
        String text=Objects.requireNonNull(deps.remove(path.toString()));
        if (text.contains(PREFIX)) return null;
        Func fn=null;
        int ordinal=-1; var remove=new ArrayList<Pos>();
        for(int i=0;i<m.getAllCommands().size();i++) {
            var c=m.getAllCommands().get(i); remove.add(c.pos);
            var pair=CommandComparison.assertionPair(m,c);
            if (pair==null) continue;
            Func chosen=pair[0].label.equals("this/"+selected) && pair[1].label.equals("this/"+peer)?pair[0]:
                    pair[1].label.equals("this/"+selected) && pair[0].label.equals("this/"+peer)?pair[1]:null;
            if (chosen==null) continue;
            if (ordinal!=-1) return null; // No single source scope for a pooled reference.
            ordinal=i; fn=chosen;
        }
        if(ordinal<0) return null;
        var command=m.getAllCommands().get(ordinal);
        String commandText=command.pos.substring(text), suffix="";
        var lex=lexer(commandText,m);
        for(var t=lex.next_token();t.sym!=CompSym.EOF;t=lex.next_token()) {
            if(t.sym==CompSym.FOR || t.sym==CompSym.EXPECT) {
                suffix=" "+commandText.substring(t.pos.toStartEnd(commandText)[0]); break;
            }
        }
        var names=new TreeSet<String>(); var locals=new HashMap<String,Func>();
        for(var g:m.getAllFunc()) {
            if (!g.label.startsWith("this/") || locals.put(g.label,g)!=null) return null;
            names.add(g.label.substring(5));remove.add(g.pos);
        }
        for(var a:m.getAllAssertions()) remove.add(a.pos);
        var chars=text.toCharArray();
        for(var pos:remove) {
            need(pos.filename.equals(path.toString()),"nonlocal declaration");
            var ix=pos.toStartEnd(text);
            for(int i=ix[0];i<ix[1];i++) if(chars[i]!='\n' && chars[i]!='\r') chars[i]=' ';
        }
        String base=new String(chars), prefix=PREFIX+id+"x";
        String ctx=context(base,m,names);
        if (ctx==null) return null;
        var fs=new TreeMap<String,Func>(); var todo=new ArrayDeque<Func>(); todo.add(fn);
        while(!todo.isEmpty()) {
            var g=todo.remove(); if(fs.putIfAbsent(g.label,g)!=null) continue;
            var es=new ArrayList<Expr>(); es.add(g.getBody()); if(!g.isPred) es.add(g.returnDecl);
            for(var d:g.decls) es.add(d.expr);
            for(var e:es) for(var h:e.findAllFunctions()) if(locals.get(h.label)==h) todo.add(h);
        }
        var code=new StringBuilder(); var bindings=new TreeMap<String,String>();
        for(var g:fs.values()) {
            code.append(rename(g.pos.substring(text),m,names,prefix)).append("\n");
            bindings.put("this/"+prefix+g.label.substring(5),function(g,""));
        }
        return new Endpoint(path,prefix,selected,base,code.toString(),ctx,
                digest(key(m.getAllReachableFacts(),List.of(),"").toString()),scope(command),suffix,deps,bindings,
                Bounds.of(ScopedFiberRun.prepare(m,ordinal,false)));
    }

    /** Empty means there was no shared authenticated scope; it does not assert inequality. */
    public static Optional<CommandComparison.Decision> compare(Endpoint a,Endpoint b) throws Exception {
        if(a==null || b==null || !a.context.equals(b.context) || !a.facts.equals(b.facts)
                || !a.deps.equals(b.deps) || !a.scope.equals(b.scope)) return Optional.empty();
        need(!a.prefix.equals(b.prefix),"reused endpoint namespace");
        String root=a.base+"\n"+a.code+b.code+"\ncheck correct { "+a.pred+" iff "+b.pred+" }"+a.suffix+"\n";
        var loaded=new HashMap<>(a.deps);
        loaded.put(a.file.toString(),root);
        var m=CompUtil.parseEverything_fromFile(A4Reporter.NOP,loaded,a.file.toString());
        checkOpens(m,loaded);
        need(root.equals(loaded.remove(a.file.toString())) && loaded.equals(a.deps),"changed parsed source closure");
        need(digest(key(m.getAllReachableFacts(),List.of(),"").toString()).equals(a.facts),"changed facts");
        var seen=new HashSet<String>();
        for(var f:m.getAllFunc()) {
            var e=f.label.startsWith("this/"+a.prefix)?a:b;
            need(seen.add(f.label) && function(f,e.prefix).equals(e.bindings.get(f.label)),"changed typed definition "+f.label);
        }
        need(seen.size()==a.bindings.size()+b.bindings.size(),"lost a local definition");
        need(m.getAllCommands().size()==1 && scope(m.getAllCommands().get(0)).equals(a.scope),"changed command scope");
        var pair=CommandComparison.assertionPair(m,m.getAllCommands().get(0));
        need(pair!=null && pair[0]==ScopedFiberRun.predicate(m,a.pred) && pair[1]==ScopedFiberRun.predicate(m,b.pred),
                "changed checked endpoints");
        var frame=ScopedFiberRun.prepare(m,0,false);
        boolean rigid=true;
        for(var s:m.getAllReachableSigs()) {
            rigid &= s.isVariable==null;
            for(var f:s.getFields()) rigid &= f.isVariable==null;
        }
        var bounds=Bounds.of(frame);
        if (!bounds.compatible(a.bounds,rigid) || !bounds.compatible(b.bounds,rigid)) return Optional.empty();
        return Optional.of(CommandComparison.evaluate(m,0,pair,frame));
    }
}
