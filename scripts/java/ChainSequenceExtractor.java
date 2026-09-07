import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.stream.Collectors;
import javax.lang.model.element.*;
import javax.tools.*;

/** Closed Javac body/signature grammar plus exact resolved-symbol inventory.
 * This is finite structural conformance, not a Java semantics proof.
 * No baseline-learning/accept-current-source mode is exposed.
 */
public final class ChainSequenceExtractor {
    private static final String P = "is.fivefivefive.CanDis.theory.";
    private static final String V = "org.acgn.cert.";
    private record Target(String id, String owner, String method, int arity,
            String firstType, String model, String shape, String bindings) { }
    private static final Map<String, String> HASHES = hashes();

    // Reviewed whole methods, including guards and effects around each sequence operation.
    // Shape also binds literals (including wire tags), unlike diagnostic-only guard extraction.
    private static final List<Target> TARGETS = List.of(
        t("source-application", P + "DependentChainApplication", "<init>", 3, "", "sourceLeaves"),
        t("source-leaf", P + "DependentChainLeaf", "leaves", 0, "", "sourceLeaves"),
        t("source-left", P + "DependentChainApplication", "left", 0, "", "sourceLeaves"),
        t("source-right", P + "DependentChainApplication", "right", 0, "", "sourceLeaves"),
        t("source-leaves", P + "DependentChainApplication", "leaves", 0, "", "sourceLeaves"),
        t("source-collector", P + "DependentChainApplication", "collectLeafInputs", 2, "", "collect"),
        t("source-leaf-inputs", P + "DependentChainApplication", "leafInputs", 0, "", "collect"),
        t("construction", P + "TypedENode", "constructDependentChainCertified", 3, "", "construct"),
        t("construction-default", P + "TypedENode", "constructDependentChainCertified", 2, "", "construct"),
        t("schema-factory", P + "SeqPortSchema", "dependent", 1, "", "construct"),
        t("schema-copy", P + "SeqPortSchema", "<init>", 1, "java.util.List<? extends " + P + "PortSchema>", "construct"),
        t("schema-kind", P + "SeqPortSchema", "kind", 0, "", "construct"),
        t("schema-quotient", P + "SeqPortSchema", "siblingQuotient", 0, "", "construct"),
        t("schema-dependent", P + "SeqPortSchema", "isDependent", 0, "", "construct"),
        t("schema-position", P + "SeqPortSchema", "schemaAt", 1, "", "construct"),
        t("sequence-copy", P + "SeqPort", "<init>", 3, "", "construct"),
        t("sequence-elements", P + "SeqPort", "elements", 0, "", "construct"),
        t("producer-certificate", P + "DependentChainCertificate", "build", 4, "", "accepts"),
        t("wire-source", P + "CertificateBundleWriter.Assembler", "dependentChainInput", 1, "", "sourceLeaves"),
        t("wire-certificate", P + "CertificateBundleWriter.Assembler", "dependentChainConstruction", 1, "", "accepts"),
        t("wire-port", P + "CertificateBundleWriter.Assembler", "term", 1, P + "PortValue", "construct"),
        t("wire-container", P + "CertificateBundleWriter.Assembler", "containerTerm", 4, "", "construct"),
        t("wire-normalization", P + "CertificateBundleWriter.Assembler", "normalizeWireContainerChildren", 2, "", "construct"),
        t("adapter-application", P + "TheoryAlloyAdapter.Builder", "dependentChainApplication", 7, "", "sourceLeaves"),
        t("adapter-barrier", P + "TheoryAlloyAdapter.Builder", "dependentChainInput", 7, "", "sourceLeaves"),
        t("replay-source", V + "SemanticEvidenceVerifier.SemanticReplay", "dependentChainInput", 3, "", "replayLeaves"),
        t("replay-certificate", V + "SemanticEvidenceVerifier.SemanticReplay", "verifyDependentChain", 1, "", "accepts"),
        t("replay-schema", V + "KernelModel.Schema", "isDependentSequence", 0, "", "accepts")
    );

    private static Target t(String id, String owner, String method, int arity, String firstType, String model) {
        String[] hashes = HASHES.getOrDefault(id, "UNREGISTERED UNREGISTERED").split(" ");
        return new Target(id, owner, method, arity, firstType, model, hashes[0], hashes[1]);
    }

    private static Map<String, String> hashes() {
        return Map.ofEntries(
            Map.entry("source-application", "f06d3d5f129ee1bd98ca70cb1a14a9d0708ea8de2169dbf4d959d5e1172507ce 25414086ed6a27f64f9c9f20d4112e0eb53b6b7d23af8ab57172b1c9884a991c"),
            Map.entry("source-leaf", "47a17c280fcb620b6cab02a705ef9608f71d3a6e3070d1286a6cfa7a387d24d5 55802c0d955badfba252881d08c5222a00f18dd7bd9f8587beb192709d808dd5"),
            Map.entry("source-left", "3042660f49a38a8189fb2cf65d4c882750a321a7db7d2da2aac1ac51100378cb cb564d8376c184e7b78b40ada50e550cc9435c9fc120637c9bf7f33ccf178b30"),
            Map.entry("source-right", "3f7172072cf19cdffada1a676d377ef5e9560e2d2cfa5c4344394c73b44d3836 3bf2d59612d94dac0108cd83a4f02d4625637a161934d54ef183143442fb8d9e"),
            Map.entry("source-leaves", "4f7edd72422a83e6704c1e64572ae0820d46526ec04a8ed106867a8f3e8da4ca 6a7328556746c87e9e46b8941a7687bd0a60e7c01c4c00837aff1262ebb7976e"),
            Map.entry("source-collector", "2a66f5108b51ef42266653fabbb389d0b099a21df0769e935c6efdddd4a1b3fb d7cb6da8bd79be34205e3099dd1cc3b1ffbbe0b5daab63f71095ba652f2e9101"),
            Map.entry("source-leaf-inputs", "aca74d24f009d560460f06dad41c1777fca1a738cf28b0a4ff49cfd9d106ee59 09a742d4c4832fdb18fcf9f3f9d2bb209f52e9665c6d1753e94e3b1ccdf2570f"),
            Map.entry("construction", "9d89f36ac7e577bb58cbc601a8b7a766722e05951d516fd00afbd2e6957beff0 5e051a72b5815c2e246b0c9366e1db9bfd5059214a37ab20e2f8dc1137a62b73"),
            Map.entry("construction-default", "69d97a0c46a8bfe47460aad51acd870a48c6a23e8c4ad80f1f80a19c5673a0e1 eb8b39361f16ae1260744efeafe9a6a1028b060f322917f6de974f08116d7b9d"),
            Map.entry("schema-factory", "6c8cb060e1b9fdc8c155dff059fc6f866142f9a3801113e840a25ff3330216a9 369d7beb54327d854bcd1c95c40c4e41ef89b91aa133fcc2b4c85f1f22724501"),
            Map.entry("schema-copy", "403fa473070f36f2aa90b61223a54c3ca3c1a573c9ed836299cfbaa22c837362 7c41c72ba45969937a95207d33644414eaa22cbccd38d27b91c5dad54e788bf9"),
            Map.entry("schema-kind", "fc5afbad18e94bf1cfbf810e6165ef0e2f06cb2db90fb10046630b142840a656 2272396b0872686cef949237fed6ff3f9ba39d6c15421e3c08ccdbe75ea85067"),
            Map.entry("schema-quotient", "f41cc531655d3f7345e6515abef098c4b705eb2689a9ea20dd0cf766efbe18d9 d85f95efe0ffb1cee82e2974f405220b47c52f1b32ed9d45346c19bdcf751cf0"),
            Map.entry("schema-dependent", "ebc281b75a9d9cc60b201fbe39becd3683d8691252009007a656349719e398d9 20f28abc713a138bef22c4a79681f042c5559f030d3f3cccb1cfe58902c9258f"),
            Map.entry("schema-position", "296bfceafb76e966df2ddd364304a653dee18ebdaf74a8720b82b281d17bfaa5 db7d218ac0e581238e83c82ff273f2108d1c1cd3aaa04b413bcb9a5bfe43ce7d"),
            Map.entry("sequence-copy", "d9562b9d503c58ead5158af44390f76804e02e96172f972b4c83e40beae497fa 437bf589cfa753ac970867d68e64d8bdd157dc951275ca40f19f174cd538c50a"),
            Map.entry("sequence-elements", "95f4cfade306edc4d86d1e0d7c288283ceb774b9ad73f386d6a09577941685c8 9911340f9f2a87c0d0aa266c1c531a3b7a4084916d418cabcb51549a0069d24f"),
            Map.entry("producer-certificate", "4c6fca493193fc84c10eb96e7affa397f7e27f5739c2a0348d7706eec0fb162b a625caaa03ac2fb97ef302287748c3bf968feb0bf4e3ebe2c98e5189ea0cbb1d"),
            Map.entry("wire-source", "4b2a373756fab76b58f186b44a6f635f016dea03d78d6702bf94fd426152410f 6b0a54fb74591c970da465e7eaab0ee6426a928a28a61a7458fb5b23174f8b4c"),
            Map.entry("wire-certificate", "8ac4bcb15224c014b497f4ff8fd98c317d1bc7a7a3bef916d3462a03c2918ad0 16f27ae243431068b8fd4f4a478a7d6c1cc9dfa91416c69937f3a46157dec186"),
            Map.entry("wire-port", "bb4738db27af0e257ef6aa309d9ebad3632be8d43f1c6850001d549e10965200 7714102e11703e181e09d457ef8bc95d39508144d1f17466cabe96bf3444160b"),
            Map.entry("wire-container", "46c8e7cd2d935874693d4667ef24e42c6f3b5a088b807fdc6f1f0f500423785e 89354291322ed1331af87e11fd8a658085cea29df377dab098382b7194ec81dc"),
            Map.entry("wire-normalization", "8eea28698577028eb46f608ab8d15193f4ab45346d5952167b7cb31e8e044aa4 a4a72e41a72e15cdfdab6970e4b6044b32cd162b8927fc7797c2154c90bd2a00"),
            Map.entry("adapter-application", "0ec3ad4a558d9ce596ff9d724082f4c690c89ff84dae5524c843db5e88d296f9 f533f6eae851c20b482b6dbb79cc6fc12c9fa72a5e56625fc14344359dd9b076"),
            Map.entry("adapter-barrier", "e85148fc525fbd3f0976e00ae778add3109d3435f9c13e5f08a9eb7e6a9fa650 2a28bdf9a25d77fa01eba72bf7a70c4874dd0b0afdf0c98299064284b7dbc8a2"),
            Map.entry("replay-source", "4cc45f14bf4ad74089ba62eae9a9f1daa4f612b9179dee4e7fe372bca2f7af74 c03e4e9fd111db518c63997f8fb8ec9d3a043ee80de6ee32cdfd0b0edf0be5fe"),
            Map.entry("replay-certificate", "a578ce184539c708e9f9b24b5757cfa9e048acfbe41296a8166089c82f51e38f 253f55eca20f1e12481db83947987977913183e792d073d88df895ec55b22390"),
            Map.entry("replay-schema", "15d9e16b453a19b3838939ba283e4ac80f3eab69977a35cb50771c8409c37653 6ca14aa251c7a500fbcbcf9b806a3ef869b46939b0369b0892b469eafdb7d01d")
        );
    }

    private static void require(boolean ok, String message) {
        if (!ok) throw new IllegalArgumentException(message);
    }

    private static String digest(List<String> tokens) throws Exception {
        MessageDigest hash = MessageDigest.getInstance("SHA-256");
        for (String token : tokens) {
            byte[] bytes = token.getBytes(StandardCharsets.UTF_8);
            hash.update((bytes.length + ":").getBytes(StandardCharsets.US_ASCII));
            hash.update(bytes);
        }
        return HexFormat.of().formatHex(hash.digest());
    }

    private static List<String> shape(MethodTree method) {
        List<String> result = new ArrayList<>(JoinGuardExtractor.shape(method));
        new TreeScanner<Void, Void>() {
            @Override public Void visitLiteral(LiteralTree literal, Void unused) {
                if (literal.getValue() instanceof String value) result.add("string:" + value);
                return super.visitLiteral(literal, unused);
            }
        }.scan(method, null);
        return result;
    }

    private static List<String> bindings(CompilationUnitTree unit, MethodTree method, Trees trees) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element element = trees.getElement(TreePath.getPath(unit, tree));
                require(element != null, "Unresolved symbol: " + tree);
                String owner = element.getEnclosingElement() == null ? "" : element.getEnclosingElement().toString();
                result.add(tree.getKind() + ":" + element.getKind() + ":" + owner + ":" + element + ":" + element.asType()
                        + ":" + modifiers(element) + ":owner=" + modifiers(element.getEnclosingElement()));
            }
            @Override public Void visitIdentifier(IdentifierTree tree, Void unused) {
                bind(tree); return super.visitIdentifier(tree, unused);
            }
            @Override public Void visitMemberSelect(MemberSelectTree tree, Void unused) {
                bind(tree); return super.visitMemberSelect(tree, unused);
            }
            @Override public Void visitMethodInvocation(MethodInvocationTree tree, Void unused) {
                bind(tree); return super.visitMethodInvocation(tree, unused);
            }
            @Override public Void visitNewClass(NewClassTree tree, Void unused) {
                bind(tree); return super.visitNewClass(tree, unused);
            }
            @Override public Void visitMemberReference(MemberReferenceTree tree, Void unused) {
                bind(tree); return super.visitMemberReference(tree, unused);
            }
        }.scan(method, null);
        return result;
    }

    private static String modifiers(Element element) {
        return element == null ? "" : element.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }

    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: ChainSequenceExtractor ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]).toAbsolutePath().normalize();
        Path output = Path.of(args[1]);
        // A failed run must not leave a previous success at the requested output.
        Files.deleteIfExists(output);
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "Full JDK 17 required");
        require(Runtime.version().feature() == 17, "Resolved-symbol grammar is pinned to JDK 17");
        List<String> rows = new ArrayList<>(List.of("object\towner\tmethod\tarity\tshapeSha256\tbindingsSha256\tmodel"));
        List<String> failures = new ArrayList<>();
        for (String baseName : List.of("src", "certificate-verifier/src")) {
            Path base = root.resolve(baseName);
            List<Path> sources;
            try (var paths = Files.walk(base)) {
                sources = paths.filter(p -> p.toString().endsWith(".java")).sorted().toList();
            }
            List<Path> jars;
            try (var paths = Files.list(root.resolve("lib"))) {
                jars = paths.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
            }
            DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
            try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
                JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics, List.of(
                        "--release", "17", "-proc:none", "-implicit:none", "-encoding", "UTF-8",
                        "-sourcepath", base.toString(), "-classpath",
                        jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                        null, fm.getJavaFileObjectsFromPaths(sources));
                List<CompilationUnitTree> units = new ArrayList<>();
                task.parse().forEach(units::add);
                task.analyze();
                for (var d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR, d.toString());
                Trees trees = Trees.instance(task);
                for (Target target : TARGETS) {
                    if (target.owner.startsWith(P) != baseName.equals("src")) continue;
                    int nested = target.owner.indexOf('.', target.owner.startsWith(P) ? P.length() : V.length());
                    String topOwner = nested < 0 ? target.owner : target.owner.substring(0, nested);
                    Path path = base.resolve(topOwner.replace('.', '/') + ".java");
                    List<CompilationUnitTree> matchingUnits = units.stream()
                            .filter(u -> Path.of(u.getSourceFile().toUri()).equals(path)).toList();
                    require(matchingUnits.size() == 1, "Missing/ambiguous source unit: " + target.id);
                    CompilationUnitTree unit = matchingUnits.get(0);
                    List<MethodTree> methods = new ArrayList<>();
                    new TreeScanner<Void, Void>() {
                        @Override public Void visitMethod(MethodTree method, Void unused) {
                            Element symbol = trees.getElement(TreePath.getPath(unit, method));
                            if (symbol instanceof ExecutableElement e && e.getEnclosingElement().toString().equals(target.owner)
                                    && method.getName().contentEquals(target.method) && e.getParameters().size() == target.arity
                                    && (target.firstType.isEmpty() || e.getParameters().get(0).asType().toString().equals(target.firstType))) methods.add(method);
                            return super.visitMethod(method, unused);
                        }
                    }.scan(unit, null);
                    require(methods.size() == 1, "Missing/ambiguous exact method owner: " + target.id);
                    MethodTree method = methods.get(0);
                    String shape = digest(shape(method));
                    List<String> resolved = bindings(unit, method, trees);
                    if (target.id.equals("construction")) {
                        TypeElement operator = task.getElements().getTypeElement(P + "InstantiatedOperator");
                        require(operator != null, "Missing instantiated operator state owner");
                        List<? extends Element> fields = operator.getEnclosedElements().stream()
                                .filter(e -> e.getKind() == ElementKind.FIELD && e.getSimpleName().contentEquals("portSchemas")).toList();
                        require(fields.size() == 1, "Missing/ambiguous retained operator schemas");
                        Element field = fields.get(0);
                        resolved.add("retained-state:" + operator + ":" + modifiers(operator) + ":" + field
                                + ":" + field.asType() + ":" + modifiers(field));
                    }
                    String bindings = digest(resolved);
                    if (!shape.equals(target.shape) || !bindings.equals(target.bindings)) {
                        failures.add(target.id + " observed " + shape + " " + bindings);
                    }
                    rows.add(String.join("\t", target.id, target.owner, target.method, Integer.toString(target.arity),
                            shape, bindings, target.model));
                }
            }
        }
        require(failures.isEmpty(), "Unmodeled chain structure/resolution:\n" + String.join("\n", failures));
        require(rows.size() == 29, "Incomplete source inventory");
        Files.writeString(output, String.join("\n", rows) + "\n", StandardCharsets.UTF_8);
        System.out.println("ChainSequenceExtractor passed: objects=28");
    }
}
