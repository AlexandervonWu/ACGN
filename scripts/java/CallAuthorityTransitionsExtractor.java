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

/** Closed structural/resolved-symbol grammar, not a Java-to-Lean compiler.
 * Like v2.13 ChainSequenceExtractor, no learn/accept-current-source mode exists.
 */
public final class CallAuthorityTransitionsExtractor {
    private static final String A = "is.fivefivefive.ACGN.alloy.";
    private static final String V = "is.fivefivefive.ACGN.visitor.MASGVisitor";
    private static final String I = "is.fivefivefive.CanDis.ir.IRAgent";
    private static final String C = "is.fivefivefive.CanDis.core.";
    private static final String T = "is.fivefivefive.CanDis.theory.";
    private record Target(String id, String owner, String member, int arity, String firstType, String model) { }
    private static Target t(String id, String owner, String member, int arity, String model) {
        return new Target(id, owner, member, arity, "", model);
    }
    private static final List<Target> TARGETS = List.of(
        new Target("visitor-reset", V, "visit", 2, "parser.ast.nodes.ModelUnit", "resolve"),
        t("declaration-index", V, "indexCallableDeclarations", 1, "resolve"),
        t("declaration-register", V, "registerCallable", 2, "resolve"),
        t("declaration-alias", V, "putCallableAlias", 2, "resolve"),
        t("declaration-arity", V, "declaredArity", 1, "declaredArity"),
        t("declaration-find", V, "findDeclaredCallable", 3, "resolve"),
        t("declaration-resolve", V, "resolveCallable", 3, "resolve"),
        t("declaration-descriptor", V + ".CallableDescriptor", "<init>", 5, "resolve"),
        t("import-resolve", V, "importedCallable", 1, "resolve"),
        t("import-alias", V, "registerImportedAlias", 2, "resolve"),
        t("ledger-state", A + "AlloyLibraryCallableLedger", "SIGNATURES", -1, "resolve"),
        t("ledger-table", A + "AlloyLibraryCallableLedger", "signatures", 0, "resolve"),
        t("ledger-require", A + "AlloyLibraryCallableLedger", "require", 4, "resolve"),
        t("ledger-key", A + "AlloyLibraryCallableLedger", "key", 4, "resolve"),
        t("ledger-put", A + "AlloyLibraryCallableLedger", "put", 5, "resolve"),
        t("ledger-expression", A + "AlloyLibraryCallableLedger", "expression", 4, "resolve"),
        t("ledger-formula", A + "AlloyLibraryCallableLedger", "formula", 4, "resolve"),
        t("signature-init", A + "AlloyLibraryCallableLedger.Signature", "<init>", 2, "resolve"),
        t("signature-arity", A + "AlloyLibraryCallableLedger.Signature", "arity", 0, "resolve"),
        t("signature-kind", A + "AlloyLibraryCallableLedger.Signature", "kind", 0, "resolve"),
        t("call-init", A + "CallSymbol", "<init>", 6, "resolve"),
        t("call-arity", A + "CallSymbol", "getDeclaredArity", 0, "resolve"),
        t("call-authority", A + "CallSymbol", "getArityAuthority", 0, "resolve"),
        t("call-occurrence", A + "CallSymbol", "getOccurrenceId", 0, "consume"),
        t("visitor-call", V, "visitCall", 4, "lower"),
        t("visitor-capture", V + ".CallVisitCapture", "<init>", 3, "consume"),
        t("visitor-time", V, "updateTimeOfVisit", 2, "consume"),
        t("counter-step", I, "nextTov", 2, "advance"),
        t("visit-select", I, "downlinksFor", 3, "consume"),
        t("visit-validate", I, "validateCallDownlinks", 3, "consume"),
        t("ir-build", I, "buildEGraph", 7, "lower"),
        t("ir-metadata", I, "attachSourceMetadata", 3, "resolve"),
        t("metadata-require", C + "CallMetadata", "require", 1, "resolve"),
        t("call-policy", C + "AlloyOperatorPolicy", "forShape", 4, "lower"),
        t("policy-nonflat", C + "AlloyOperatorPolicy", "nonflat", 2, "lower"),
        t("ir-policy", C + "EGraphNode", "operatorPolicy", 0, "lower"),
        t("ir-append", C + "EGraphNode", "appendChild", 2, "lowerArgs"),
        t("ir-sort-key", C + "EGraphNode", "appendSortKey", 2, "lowerArgs"),
        t("ir-semantic-head", C + "EGraphNode", "appendSemanticHead", 2, "lower"),
        t("adapter-operands", T + "TheoryAlloyAdapter.Builder", "buildOperand", 5, "lowerArgs"),
        t("adapter-node", T + "TheoryAlloyAdapter.Builder", "constructNode", 3, "lower"),
        t("adapter-head", T + "TheoryAlloyAdapter", "semanticHead", 1, "lower"),
        t("certificate-binding", T + "CallOccurrenceCertificate", "requireExactBinding", 0, "checkRepresentation")
    );
    private static final Map<String, String> HASHES = Map.ofEntries(
        Map.entry("visitor-reset", "73683c3b95ce9da53c0b653390f017c5b82dc4dbdb00feff4a4595354067718b e89e776f9598f418930d95d58bbda398be1edcea28aab4313d884e21faab2c0e"),
        Map.entry("declaration-index", "1b4df432580f2c90db961cf0a7a9cba309a9b6eaef82694e4d1884ac319b69c3 692bdee7e6a5240a7ac6328281fd19e108fe6f982de03094b858ae30d880fa2b"),
        Map.entry("declaration-register", "d6a6382bf5a7aadc1c7ddd88d14a0ed946ba0ba6560fee198c32d3668e428fc0 899e2be9854bcfc032ff399016e68d1e4fc1a78e3e386dad43cdd51cc71faa22"),
        Map.entry("declaration-alias", "b7ac72cbccb6ff3d1181abc77fe99ef9a5f3104e3d3771b9bc71ca58b5633b09 b39f31703b09793e494a7bce10682db5314714a2801fd149cb90e38203826b11"),
        Map.entry("declaration-arity", "cd052b0803af2564fc0d29aa6fed793c1756fbadb62449709b4ce62b6afd9752 3331299a9ac07de21b3e0342ec8833545d0232265c8e4c2f9a80324f2000eece"),
        Map.entry("declaration-find", "187102482436b85f9d4baa8189d1e331a15765ec14e4f6ceae52dfa436df71ec ce306c8158356cfa573fae8f00d5535fe6fc1662b84752919fb1fe22d45de03d"),
        Map.entry("declaration-resolve", "7c60f840f187c4ddf540075a02fe9f1222bf38cf3bf25a43f9be64b1528df13e c943c1ea8f86971372c218ca4e29277126531288406f86100cbae6aad2d7c479"),
        Map.entry("declaration-descriptor", "14e084adcdc05c2cb0327ebe626487cb5ae7bcb1a37e0529650cbe3e2f59ac43 19704f05cad6deb2185f92fa5cdd384329546c6fb19106a3e3b825f6bfa91865"),
        Map.entry("import-resolve", "36a5212061bbfe89e3aa0d463bbe86f8f82a89f8fbdec5f37e4ce03e6087b9c8 84c9502f51118aad90625b37998d967ad6c40839fa77fdcbd81e020e6412ab57"),
        Map.entry("import-alias", "ab34dcd38724704434a44c91fb77dbdefaa903ea02eb84bcbb82d7512fe5c6af 3e224eae477c2bf18581842ee72c7eb9fb71d3e0a568e76242a4dd1a7ec43665"),
        Map.entry("ledger-state", "02f72e1a1375f8b40a32e5956e52a5deb042b63e863d37149a0ced5eb392b1b2 406d84bbb778dbabc490316e14e9de65c71f7b4e547623119443e7a75006db56"),
        Map.entry("ledger-table", "0cdb2e012692c77d55b05c320990cb7a90c438e32c037f2968dab670ca5fa45c 2248fc6421ef7be0c3dbfc85a6b90cebe0326796b4d1d3cdd36a473f0d01078f"),
        Map.entry("ledger-require", "41f3f492fad4e97e26fab42b28be6f17e21681ef7e1943692155c3501aff3ce6 cc1d4a95ceee19a8206163cee89ca904d5e6bb7d50edc44a55de7ae1905eee83"),
        Map.entry("ledger-key", "1a6bca531c66367bf3d68dcdcd6cd173ff4638408cbbb9a90ce5365390b1ca54 cc7de580c69bbb4b90bd293eb9d2463bc0cf93fef8a7c97f1cce37d2afab8844"),
        Map.entry("ledger-put", "eb33bd79bf64dbe383b3957b52640f1356a788a549a51edaf308505e564b02cd 0a25bcde0e5fec9bab6789805792c3fee306c1b46f14761bef8750163524e453"),
        Map.entry("ledger-expression", "15e02fe527327eb4f151ae2338b6ed316363051c3287a8d9509eb04576068ab5 7686c7887c130504c227023d88ea59ddf8b24b5eaad38e939536ca3f13f9440f"),
        Map.entry("ledger-formula", "83cf28e668266dc4051a6cc36d4fb15878d636aab584f8b5f4b77aee0a56501d 1984689fe579b8a45a511aa86607fabdbbb1a4930febdf86b05047a4da77e62c"),
        Map.entry("signature-init", "f92a5f16aef4908457d8d38f173a15e60010379fa6716a618d46b0f85c0b94a4 1a859397e5d678ee90ddfc40c9723af449b273b304ca4af77453220f6aafa30c"),
        Map.entry("signature-arity", "216753480b5878f5179d3d4747980828af15e05b845bb7852ff41065dd3d8639 a6e1ccf1ba6034281718f0fa92d0b7c35d0b80dcfcf32aa29aeb749ba44f0528"),
        Map.entry("signature-kind", "8d47123c1b2fada11e3c1ba243ff1a8105455fa1b794dfbb0df80b45b9e616b0 e66541832c00204b0778ec3e0267451b6acb0446e094883e3e34526f8752b4a6"),
        Map.entry("call-init", "d2f1c1f184cde4d8ba813e08973958cca9b84df8adaccf81a88c0401e87a07a8 3ab762e6702fe3435e65465094ae6f6fc56346df8e0244bc8f9cb110fafa89da"),
        Map.entry("call-arity", "98749e545b911638540cd3b407b3b4b7d666f5df126cc8c42bbe6d8ec1e9320b 72b0e4717c7c3998d7f675e38c1bf019041089ad85218a42377e7cf339bac79c"),
        Map.entry("call-authority", "00638cd2844378ebc68f60b6951bd93bea8b5d5131f9e0f5cee4e7f058a27452 3c5193e40de49d3df9e79133c1b2199ff643b62a1925b1ef1d949a5e27a9ccc3"),
        Map.entry("call-occurrence", "8051debd4c00af859bb3859cae336cd2d21aaed4b9c9fb8e4d79e586b52c525f 14f7a4ec7fd3b9fdd0bccb4839ed0f840f0952edba3306acd0a268e0587912a4"),
        Map.entry("visitor-call", "cff919b971bb71660927853efb261a65abe6f48411a62f3dcbc34c9d0b28788f 76c882982b9c3e21f4d49eccbd8b15ec40a0acc6f371442010cf276cc3d9b701"),
        Map.entry("visitor-capture", "c74ace5d90a939855bab500f6a37275a3b2edeced7993b942174e1a804749926 282cf5ac3e9c0b14db21d75e32943441ef9be42ad8dab60c87c0dfef5721e1a7"),
        Map.entry("visitor-time", "900df7caf5565593a73f3bb20efe1cdbcfdae4d23d20a83b8041c6d397d3d3bb 471597317b0132b2bc8c9adcc6107c34676ae74770aa0d5ccfb1935bba1f6b1d"),
        Map.entry("counter-step", "12aa5e443728d10bb0a6943e331848d47e2f162bbb42c3a0be1050c7bb9b44f5 3bc21ce8b86aaa8b387bbcf4faff31bf9a2a5f96fc4974d2917ab8b6dc0c1b6f"),
        Map.entry("visit-select", "2ef01c475fafe71a8ef3147e060a39994fb7be4c6fcd5eb7bbd820c6fc1fb749 abb9cbe0df10caeee4054872582cbdb7192462e84e16e9d291f86a9274afda03"),
        Map.entry("visit-validate", "e31285d22293db48dc79371b9a1356921f396fc45d8bdc675331daacdce52c1b f3f9239e2a1cde4517a8b6c7cc752c4cfa4f957441faabcef9241b3df811abde"),
        Map.entry("ir-build", "208277c8f3a1b5b478af357aec94e025cfaffae629d26804cb245fee19b469a8 9fc429a3d13bba99523297e44d18929bd39093379a9924fb8bd37e1936c0d35a"),
        Map.entry("ir-metadata", "e759a23b19b2202140a66ad981d9eb1939b550619938b85f52eac7aa13c9d66c 076a961620d57ebda4f35a7a329373e3db8f3cdab42ac9a5d29c07379d20a60d"),
        Map.entry("metadata-require", "69401097cfad53a7ec8c5b70ca96194e670b61fcb6202223ecf8f93451c538ec d446b5a1a33b8b09c53c5cb9c736eba858e4984fff54a55a0ce245a63ffbaef3"),
        Map.entry("call-policy", "6c40534b36a68b02d76f2bfb4fe81a34da3476f8bbe5c5a180c2f18e8cd1b908 fe86e671b326be1e6bdac868a85a4bfedc5ac8c3a891081426b7ae4c699b9326"),
        Map.entry("policy-nonflat", "bf8585a75accaa2103553160a214a177bf978ae5e561514d830b47bcfa930908 298778f57cdb1570636cc6b70aebff3111f0c540743e7dc0cb7087913aa20e03"),
        Map.entry("ir-policy", "6aeb9f71ca0c8dcf971817d7bfdc962697607b4f0dd31fbf9bccfd757b51333c 18f806312715ae3915697a3c8df612dce436c58b8021daf156f076ddd6450076"),
        Map.entry("ir-append", "94a65db193bac0473708e78a2d814fd3379e1f801e4f6e55255fd62d4e2e159a 1f3c8d04816ac7396ab05e70a3f9a2e947b03f5f009f3d427ba621076a6916d2"),
        Map.entry("ir-sort-key", "2c3e8cf84f2c659112c951642a3f4d39a207e30c2f53c2bf4a2c63536ac3ebca eb1d69a7414586430ee8f687002b9fcb599ef76c1d807dda08930884c31289aa"),
        Map.entry("ir-semantic-head", "7722aba5ffd35631ef67b057f90e05fc3ba65eb436d660110bf48126de099ab2 aff92b0f97fa6e3a341443fa948562a93ce60ce3ec6ebb50e43d2bd0fe9cd2f8"),
        Map.entry("adapter-operands", "ef797f2df65b535d8c16c813edf7a6cfa10be15d43a63ae854286f25f7d63eeb b58add826ea5961bfdff8eec4f7b4b632d56a35146d3759573ab5f1abda8fcec"),
        Map.entry("adapter-node", "5f695bebc5f200fc17a889b47ce5b0aad05cbc80753e6f2e9c8004922b42ee58 1c1f9354ef01980ea0c097063310fc5084143f2a981e45967b1b6054b6e99396"),
        Map.entry("adapter-head", "21694899b06e2b1c236a5675edd0468b3b209497ef8129124aa3f29234bd8372 1b7e8b8231ae3661093cf163a7bca9f7e8856f5ee9d83de7633a8ab53af2a2b6"),
        Map.entry("certificate-binding", "296e271c33884c7268fa43bed75a4666e42bbde703c74cedf8534a2e8b0545ec 942f842d37e2ff848fe42f7d9efd734de65edbe7c3402cde020ed03d186316aa")
    );

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
    private static List<String> shape(Tree tree) {
        List<String> result = new ArrayList<>(JoinGuardExtractor.shape(tree));
        new TreeScanner<Void, Void>() {
            @Override public Void visitLiteral(LiteralTree literal, Void unused) {
                if (literal.getValue() instanceof String value) result.add("string:" + value);
                return super.visitLiteral(literal, unused);
            }
        }.scan(tree, null);
        return result;
    }
    private static String modifiers(Element element) {
        return element == null ? "" : element.getModifiers().stream().map(Object::toString).sorted().collect(Collectors.joining(","));
    }
    private static List<String> bindings(CompilationUnitTree unit, Tree root, Trees trees) {
        List<String> result = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            private void bind(Tree tree) {
                Element e = trees.getElement(TreePath.getPath(unit, tree));
                require(e != null, "Unresolved symbol: " + tree);
                Element owner = e.getEnclosingElement();
                result.add(tree.getKind() + ":" + e.getKind() + ":" + owner + ":" + e + ":" + e.asType()
                        + ":" + modifiers(e) + ":owner=" + modifiers(owner));
            }
            @Override public Void visitMethod(MethodTree tree, Void unused) {
                bind(tree); return super.visitMethod(tree, unused);
            }
            @Override public Void visitVariable(VariableTree tree, Void unused) {
                bind(tree); return super.visitVariable(tree, unused);
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
        }.scan(root, null);
        return result;
    }
    public static void main(String[] args) throws Exception {
        require(args.length == 2, "Usage: CallAuthorityTransitionsExtractor snapshotRoot outputTSV");
        Path root = Path.of(args[0]).toAbsolutePath().normalize(), output = Path.of(args[1]);
        Files.deleteIfExists(output);
        require(Runtime.version().feature() == 17, "Resolved grammar pinned to JDK 17");
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        require(compiler != null, "Full JDK required");
        List<Path> sources, jars;
        try (var files = Files.walk(root.resolve("src"))) {
            sources = files.filter(p -> p.toString().endsWith(".java")).sorted().toList();
        }
        try (var files = Files.list(root.resolve("lib"))) {
            jars = files.filter(p -> p.toString().endsWith(".jar")).sorted().toList();
        }
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (var fm = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            JavacTask task = (JavacTask) compiler.getTask(null, fm, diagnostics, List.of("--release", "17",
                    "-proc:none", "-implicit:none", "-encoding", "UTF-8", "-sourcepath", root.resolve("src").toString(),
                    "-classpath", jars.stream().map(Path::toString).collect(Collectors.joining(File.pathSeparator))),
                    null, fm.getJavaFileObjectsFromPaths(sources));
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var d : diagnostics.getDiagnostics()) require(d.getKind() != Diagnostic.Kind.ERROR, "JAVAC_ERROR: " + d);
            Trees trees = Trees.instance(task);
            List<String> rows = new ArrayList<>(List.of("object\towner\tmethod\tarity\tshapeSha256\tbindingsSha256\tmodel"));
            List<String> failures = new ArrayList<>();
            for (Target target : TARGETS) {
                List<Map.Entry<CompilationUnitTree, Tree>> found = new ArrayList<>();
                TypeElement owner = task.getElements().getTypeElement(target.owner);
                require(owner != null, "Missing exact owner: " + target.owner);
                for (Element e : owner.getEnclosedElements()) {
                    if (!e.getSimpleName().contentEquals(target.member)) continue;
                    boolean matches = target.arity == -1 ? e.getKind() == ElementKind.FIELD
                            : e instanceof ExecutableElement method && method.getParameters().size() == target.arity
                            && (target.firstType.isEmpty() || method.getParameters().get(0).asType().toString().equals(target.firstType));
                    if (matches) {
                        TreePath path = trees.getPath(e);
                        require(path != null, "Object must be in snapshot source: " + target.id);
                        found.add(Map.entry(path.getCompilationUnit(), path.getLeaf()));
                    }
                }
                require(found.size() == 1, "Missing/ambiguous exact source object: " + target.id);
                var entry = found.get(0);
                String shape = digest(shape(entry.getValue()));
                String bindings = digest(bindings(entry.getKey(), entry.getValue(), trees));
                if (!(shape + " " + bindings).equals(HASHES.get(target.id))) failures.add(target.id + " observed " + shape + " " + bindings);
                rows.add(String.join("\t", target.id, target.owner, target.member, Integer.toString(target.arity),
                        shape, bindings, target.model));
            }
            require(failures.isEmpty(), "UNMODELED_SOURCE:\n" + String.join("\n", failures));
            require(TARGETS.size() == 43 && HASHES.size() == 43, "Incomplete source census");
            Files.writeString(output, String.join("\n", rows) + "\n", StandardCharsets.UTF_8);
            System.out.println("CallAuthorityTransitionsExtractor: objects=43");
        }
    }
}
