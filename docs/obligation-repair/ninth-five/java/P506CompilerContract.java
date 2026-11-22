package is.fivefivefive.CanDis;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HashMap;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** Closed symbolic bytecode inventory of the parser, authority transport and guard methods. */
public final class P506CompilerContract {
    private static final String INVENTORY = """
        parser.ast.nodes.ResolvedBindingOrigins	capture	9d485b755eb9358f5d00141cb6ea5dd63f0134ca598cd1dade88d9651841abda
        parser.ast.nodes.ResolvedBindingOrigins	seal	ed71afb9cb8e0e21e3e72aa731df938dac06245388bd9927cd0d3be23b4c1fd3
        parser.ast.nodes.ResolvedBindingOrigins	declaration	5b794d6a73e95825dcac023bf0651a68b1ea2ed3b90b7320cddf277b249fe35e
        parser.ast.nodes.ResolvedBindingOrigins	read	3de9d11dd399375c897cc45e8bf8a028a256b5c741fe776deefc920cf768fc3a
        parser.ast.nodes.ResolvedBindingOrigins	effectiveMultiplicity	9887c5b099505b04f057b9192f528505ef2a9e0e979b7b360a0e10f6761d4ed2
        parser.ast.nodes.ResolvedBindingOrigins	captureViews	db1c7c0a1fdc4e2a504a195e3d3128711f5173c8274575fc852280f61c29873d
        parser.ast.nodes.ResolvedBindingOrigins$Bound	intact	23c047359825da0c024e0f8d1b74ba5f291ba1aca51f02faf8b94d5a9d23d031
        parser.ast.nodes.ResolvedBindingOrigins$Slot	authorizesSome	79c4ee36f5242cb98f3c5b34acee0d056bff9ab13ce58f2c5921a7b0e2b565a2
        parser.ast.nodes.ResolvedBindingOrigins$Slot	authorizesOne	04c4f747404409ab4e072e90d93b38c7014512cd80851ed43bd7958990065e9c
        parser.ast.nodes.ResolvedBindingOrigins$Slot	implicitOne	54d9a40e2c4f9d62e234b8e8fa2c47a5b4820f6ba75fcad726b95660233a2681
        is.fivefivefive.CanDis.core.NormalForm	sourceNonemptySlots	7ab2376c075afc1129d0c71ae99ca280f8c4df4771271112515539d14a07b902
        is.fivefivefive.CanDis.core.NormalForm	isStaticallyNonemptySet	5fd4735db42b2809d48c92bd96a6caec7eaa2021165443bd14aa016d2509f7a0
        is.fivefivefive.CanDis.core.NormalForm	addGuardedBindingFacts	b7ef0da0cfdfd64977289cd110c599563ae289b0913112f8ab14b3b777929ff0
        is.fivefivefive.CanDis.core.NormalForm	guardedBindingFacts	4a4be3c403815fe308667f71ee1399ab624e9450bb7eb792a7d382ffbfd0ac80
        is.fivefivefive.CanDis.core.NormalForm	bindingParent	8258e93351ff61cd91739643907e0fe99d36190c88a1fe6437ff65930f0d95d2
        is.fivefivefive.CanDis.core.NormalForm	domainDescriptor	af2cf4fb6a99482b67146b4acbac1742bef85a33e52818f937b7247253164a7b
        is.fivefivefive.CanDis.core.NormalForm	retainDeclarationFrame	983b77542b7a95c332e9acbebf7e389a64bc761216d561556dc0eeb3d6a8fb95
        is.fivefivefive.CanDis.core.egraph.AlloyRewriteSystem	addDeclarationBindings	e17e75f99245ed497a8ceb6f02321c84a43ea371d92876381ab52d729f23dd4b
        is.fivefivefive.CanDis.core.egraph.AlloyRewriteSystem	isPositiveBindingDomain	ca0990e66ee8adb45cc8bd1f99760396cd1f686a44d4c01e6875ebd4a46b4576
        is.fivefivefive.CanDis.core.egraph.AlloyRewriteSystem	isStaticallyNonempty	a9e1b565f1eeae5aff42e9fc83fde985cbc722bf32e3fb960013c82c1d7500d1
        is.fivefivefive.CanDis.core.EGraphNode	attachParsedBinding	15955c4f695480fcd1903639c129eecc0facf98fb7edb0e9aa3fe43c32ef3d09
        is.fivefivefive.CanDis.core.EGraphNode	ownsParsedBinding	9d73503b0bd32045ee33e74379a5476fe8615e2661db3707c30a5c011f6db78e
        is.fivefivefive.CanDis.core.EGraphNode	adopt	c292c6ab88068170bb3c81af988cd36bb23438d434250a043e3620543ba52ce0
        is.fivefivefive.CanDis.core.EGraphNode	copyPayloadTo	245cd962dc664309a71c3c1e75a9be32e90677c96e48315649ac79a13d0f1d0b
        is.fivefivefive.CanDis.core.EGraphNode	preserveSourceOccurrenceLineageFrom	5d14a66a5653e58ef37f7053dc48c5fee5e7c2abb024ebe656ce78f136b3038a
        is.fivefivefive.CanDis.core.EGraphNode	retireSemanticPayload	2a0f8d4ea8518d413c43ead9f20050a24c88af5f1fe6362b50dd9f955d92556d
        is.fivefivefive.CanDis.core.EGraphNode	collapseToSetConstant	d187e2116b61c154e22c67d2021ae20b7974ed7c86371fa3af7f2952ec9f987f
        is.fivefivefive.CanDis.core.EGraphNode	collapseToBooleanConstant	b0e4ba336b070001b036fcb73d67f445a47ddaffba04b7aa0bf9ae008b2780c6
        is.fivefivefive.ACGN.asg.AugmentedNode	retainBindingVisit	0ee8f498a90061b5a5205483043dee92daf215335f8c614a1921262878f04b47
        is.fivefivefive.ACGN.asg.AugmentedNode	parsedBindingVisit	35d1e39f92456017bcad1be3a158a234144dfa4b4e8795dfa14cf2b831e09d19
        is.fivefivefive.CanDis.ir.IRAgent$BindingOrigin	checked	5c15fdab2647da89e27e5cc4499269d4e62f21f553e6119e7e7242510a477f22
        is.fivefivefive.ACGN.visitor.MASGVisitor$BindingVisit	belongsTo	5ce603eab96cba4c61d61d5349d729042dc440521662f6e5068b96791e911cfe
        is.fivefivefive.ACGN.visitor.MASGVisitor	visitRelDecl	27878ff0ae0b1b66eb4098b641a7e80b79ef8a2db34cfcf2c9ecc06c98871afa
        is.fivefivefive.ACGN.visitor.MASGVisitor	recordLeafExactType	ebe797d48fbbf44fdb9bc1d2a6db5dc8eb9437304c2dcf6b603655fc8fc5fbc6
        is.fivefivefive.CanDis.ir.IRAgent	buildEGraph	dc529f96abc2ffa794e5e4b5b1247be4f1612da64270d27425423316b1431c23
        is.fivefivefive.CanDis.core.egraph.AlloyTerm	parsedVariable	19416b9d8e9ca3665bf40a4994541bf02ef4f1d98293cc3cc125d09e6123b55e
        is.fivefivefive.CanDis.core.egraph.AlloyTerm	parsedDeclaration	b4babbdeb6e2bbfbd471657dda76a762299a573731840582ee15cf258d7c24c5
        is.fivefivefive.CanDis.core.egraph.AlloyTerm	rewrittenChildren	a9cb79dd58669f3a877d2b832c46c304247ebb7283c488639500b8238f337482
        is.fivefivefive.CanDis.core.egraph.AlloyTerm	renameVariable	e2d595796697cec5f1e108843835f5c9a64de672a6f227c0cacfeaa55df41b99
        is.fivefivefive.CanDis.core.egraph.AlloyTerm	eraseSlotTypes	9d35eee56ff6d9c0d7aa6a24fb03c1505d12f289ea5f02b5d6780e3a136cf432
        parser.ast.nodes.ResolvedCallOrigins	addToMap	9017ca38496bfc33466a4649f64ca9e6fd4f0223e9fa5ed5e47f251387340513
        parser.ast.nodes.ResolvedCallOrigins	seal	7d3d034d536b712d3741fd679539cc181f1531979c37f1968f9f9d556d0e527d
        is.fivefivefive.CanDis.adapter.AlloyAstTermAdapter	fromAst(parser.ast.nodes.Node, boolean)	8e2da04ea58afe08a3b7c68ce1bf88e0e9746b6bd040b4271057645b4320d902
        parser.ast.nodes.RelDecl	parser.ast.nodes.RelDecl(parser.ast.nodes.Node, edu.mit.csail.sdg.ast.Decl)	06204e012bc0edc50477fa02a904bc077ccc779b470e96d530a477221b63f22d
        parser.ast.nodes.VarExpr	parser.ast.nodes.VarExpr(parser.ast.nodes.Node, edu.mit.csail.sdg.ast.ExprVar)	90f329a0a4f4e0efdb6d8f157c9540701d86f3fc507880d577fe132b042d2aae
        edu.mit.csail.sdg.ast.Expr	mult	505c6c26938f9bc2f36fea5d8e8b9e9cff39c528c1569b42c6c49449a7c2039f
        edu.mit.csail.sdg.translator.TranslateAlloyToKodkod	addOne	157cc5be7a6cd3d4c3b43a79e8818d93ef6acf6c19f303734c6fec331e2f2948
        parser.ast.nodes.ResolvedBindingOrigins$View	at	acd7b00a0a1c59ff1e3bd665322b4937424ed538725bc54252211414d151a3c2
        parser.ast.nodes.ResolvedBindingOrigins$View	intact	fc958fd2e65a65ae336025ad640cce11bdf8bb4254ff196f4e1c7029f09359be
        parser.ast.nodes.ResolvedBindingOrigins$View	sameNodes	c867cd057eaf5db9ef8e0c5e341ef1ce0e2c4b6cdaf34c2bcdeb7f37129f8db8
        parser.ast.nodes.ResolvedBindingOrigins$View	descend	ce169c470f23c458d2975b2634ca117e7f4cec4aa4558ebe193e32572a648e5e
        parser.ast.nodes.ResolvedBindingOrigins$View	append	46d138be3faac6ad0d075ccbb63954fe5c91d508b839e3cd260cac98885d0237
        parser.ast.nodes.ExprOrFormula	setType	eb93dcd47f198836281616116daff4ca07a109ad30697e044a3177628ad03596
        parser.ast.nodes.BinaryExpr	setOp	63ca90be6d3147d0eec7ecaeb05e4bda9df7e1019505b90b2183e9aa0515f689
        parser.ast.nodes.BinaryExprOrFormula	setRight	8b4f8e4c00b1d6e02b56459b82eb7f5d08583e4a939f3e324b65c5250cfbc1c5
        """;
    private static final String SHALLOW_BOUND = "d64e4c64fdc8f134bd38a12f3573d4bbbd0dc38a8d58601c76a6dd3ed56f9c10";
    private static final String PREVIOUS_DOMAIN = "2310aa75c11589f4a723125e1580b2051d1cd67c3d0ed3b52f37d107bfa85161";
    private static final String ORIGINAL_GUARD = "5f67e2f82997fa5df43e0d30ea0e5b446c33e77fb5b5d723a3e72f56e3e7d5e1";

    private static String hash(byte[] bytes) throws Exception {
        return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
    }

    private static Path loadedOrigin(String name) throws Exception {
        var type = Class.forName(name, false, P506CompilerContract.class.getClassLoader());
        return Path.of(type.getProtectionDomain().getCodeSource().getLocation().toURI());
    }

    private static List<String> listing(String owner) throws Exception {
        Path javap = Path.of(System.getProperty("java.home"), "bin", "javap");
        var process = new ProcessBuilder(javap.toString(), "-J-Xmx120m", "-classpath",
                loadedOrigin(owner).toString(), "-p", "-s", "-c", owner).redirectErrorStream(true).start();
        var output = java.util.concurrent.CompletableFuture.supplyAsync(() -> {
            try (var stream = process.getInputStream()) {
                return stream.readAllBytes();
            } catch (java.io.IOException ex) {
                throw new java.io.UncheckedIOException(ex);
            }
        });
        try {
            if (!process.waitFor(25, TimeUnit.SECONDS) || process.exitValue() != 0) {
                throw new IllegalArgumentException("javap failed for " + owner);
            }
            return new String(output.get(5, TimeUnit.SECONDS), StandardCharsets.UTF_8).lines().toList();
        } finally {
            if (process.isAlive()) process.destroyForcibly();
        }
    }

    private static String method(List<String> clazz, String name) throws Exception {
        String selector = " " + (name.contains("(") ? name : name + "(");
        int position = -1;
        for (int i = 0; i < clazz.size(); i++) {
            String line = clazz.get(i);
            if (line.startsWith("  ") && !line.startsWith("   ") && line.contains(selector)) {
                if (position != -1) throw new IllegalArgumentException("Ambiguous method " + name);
                position = i + 1;
            }
        }
        if (position < 0 || !clazz.get(position).strip().startsWith("descriptor: ")
                || !clazz.get(position + 1).strip().equals("Code:")) {
            throw new IllegalArgumentException("No compiled body for " + name);
        }
        var body = new StringBuilder();
        for (int i = position; i < clazz.size() && !clazz.get(i).isBlank(); i++) {
            // Pool indices may move; retain descriptors, operands, branch targets and resolved names.
            body.append(clazz.get(i).strip().replaceAll("#[0-9]+", "#")).append('\n');
        }
        return hash(body.toString().getBytes(StandardCharsets.UTF_8));
    }

    private static void requireMatch(String owner, String name, String expected, String observed) {
        if (!expected.equals(observed)) throw new IllegalArgumentException("UNMODELED_P506_METHOD " + owner
                + "." + name + " " + observed);
    }

    private static boolean rejects(String owner, String name, String expected, String prior) {
        try {
            requireMatch(owner, name, expected, prior);
            return false;
        } catch (IllegalArgumentException changed) {
            return changed.getMessage().equals("UNMODELED_P506_METHOD " + owner + "." + name + " " + prior);
        }
    }

    static String verify() throws Exception {
        if (Runtime.version().feature() != 17) throw new IllegalArgumentException("JDK 17 required");
        if (!hash(Files.readAllBytes(loadedOrigin("parser.ast.nodes.RelDecl"))).equals(
                "be040bcd26ddcf042bb629f9c2a8c56e2f8bca0c829281c5cc0d07a047474fe3")
                || !hash(Files.readAllBytes(loadedOrigin("edu.mit.csail.sdg.ast.Expr"))).equals(
                "8a8746b89d95f28762903c9acbd2bee8aca5014fe49a522b7184ba32ffcc5b58")) {
            throw new IllegalArgumentException("Unexpected parser/Alloy distribution");
        }
        Map<String, List<String>> cache = new HashMap<>();
        boolean previousDomainRejected = false;
        boolean staleGuardRejected = false;
        boolean shallowBoundRejected = false;
        String[] pins = INVENTORY.strip().split("\n");
        if (pins.length != 55) throw new IllegalArgumentException("Incomplete method inventory");
        for (String row : pins) {
            String[] fields = row.split("\t", -1);
            if (fields.length != 3) throw new IllegalArgumentException("Invalid method inventory");
            String owner = fields[0], name = fields[1], expected = fields[2];
            if (!cache.containsKey(owner)) cache.put(owner, listing(owner));
            requireMatch(owner, name, expected, method(cache.get(owner), name));
            if (owner.equals("is.fivefivefive.CanDis.core.NormalForm") && name.equals("domainDescriptor")) {
                previousDomainRejected = rejects(owner, name, expected, PREVIOUS_DOMAIN);
            }
            if (name.equals("isStaticallyNonemptySet")) {
                staleGuardRejected = rejects(owner, name, expected, ORIGINAL_GUARD);
            }
            if (owner.equals("parser.ast.nodes.ResolvedBindingOrigins$Bound") && name.equals("intact")) {
                shallowBoundRejected = rejects(owner, name, expected, SHALLOW_BOUND);
            }
        }
        if (!previousDomainRejected || !staleGuardRejected || !shallowBoundRejected) throw new IllegalArgumentException("Prior guard/projection accepted");
        return hash(INVENTORY.getBytes(StandardCharsets.UTF_8));
    }
}
