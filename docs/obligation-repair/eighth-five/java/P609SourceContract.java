package org.acgn.cert;

import com.sun.source.tree.ClassTree;
import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.tree.MethodInvocationTree;
import com.sun.source.tree.MethodTree;
import com.sun.source.tree.Tree;
import com.sun.source.util.JavacTask;
import com.sun.source.util.TreeScanner;
import com.sun.source.util.TreePathScanner;
import com.sun.source.util.Trees;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Set;
import java.util.TreeMap;
import javax.lang.model.element.ExecutableElement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.tools.Diagnostic;
import javax.tools.DiagnosticCollector;
import javax.tools.JavaFileObject;
import javax.tools.ToolProvider;

/** Extracts the concrete producer and replay key layouts, independently of the wire rows. */
final class P609SourceContract {
    private final Map<String, MethodTree> methods = new HashMap<>();

    private final Map<String,String> inventory = new TreeMap<>();
    private static final Map<String, Set<String>> CHECKED = Map.ofEntries(
            Map.entry("BinderOccurrenceAutomorphismCertificate", Set.of("<init>", "create", "build", "portAt", "pathKey", "appliesTo", "verifyLocal")),
            Map.entry("BinderOccurrenceProofs", Set.of("collect", "child", "path")),
            Map.entry("TypedEqualityCertificate", Set.of("<init>")),
            Map.entry("Assembler", Set.of("term", "binderRoot", "binderOccurrence", "semanticEvidence", "forEachBinderPortAlternative", "containerTerm", "normalizeWireContainerChildren")),
            Map.entry("StructuralKey", Set.of("stableString", "appendEncoded")),
            Map.entry("StableKey", Set.of("stableString", "appendEncoded")),
            Map.entry("PortValues", Set.of("immutableBag", "immutableSet", "rejectKeyCollision")),
            Map.entry("CanonicalProfileVerifier", Set.of("verifyOrbitPayload")),
            Map.entry("KernelModel", Set.of("validateContainer")),
            Map.entry("Bundle", Set.of("parse")),
            Map.entry("CertificateVerifier", Set.of("requireProductionNodeTheory")),
            Map.entry("OperatorDeclaration", Set.of("validateContainerLaws")),
            Map.entry("ContainerLawDeclaration", Set.of("requireCertified","validateEvidenceFor")),
            Map.entry("StableKeyParser", Set.of("parse", "readLengthPrefixed", "readUnsigned", "readCount", "expect", "atEnd")),
            Map.entry("SemanticEvidenceVerifier", Set.of("verify", "requireNoEmptyFixtureBinderClaims", "isExactEmptyTestFixture", "parseStableKey")),
            Map.entry("SemanticReplay", Set.of("verify", "typedCertificate", "verifyBinderOccurrence", "verifyEvidenceCoverage",
                    "collectBinderObligations", "derivedBinderOccurrenceKey", "occursAtPath", "parseOccurrencePath",
                    "requireKey", "requireExactCoverage", "actedPortKey", "portKey", "termKey", "requireOccurrenceMap", "requireConjugate")),
            Map.entry("KernelVerifier", Set.of("structuralAlpha")),
            Map.entry("IndependentVerifier", Set.of("open", "verify", "verifyPair")),
            Map.entry("AlloyLawRegistry", Set.of("admitted")));

    private P609SourceContract(Path root) throws Exception {
        String producer = "src/is/fivefivefive/CanDis/theory/";
        String verifier = "certificate-verifier/src/org/acgn/cert/";
        var paths = List.of(producer + "BinderOccurrenceAutomorphismCertificate.java",
                producer + "CertificateBundleWriter.java", producer + "StructuralKey.java",
                producer + "TypedEqualityCertificate.java", producer + "BinderOccurrenceProofs.java",
                producer + "AlloyLawRegistry.java", verifier + "SemanticEvidenceVerifier.java",
                verifier + "KernelVerifier.java", verifier + "IndependentVerifier.java", verifier + "Bundle.java",
                verifier + "KernelModel.java", verifier + "CanonicalProfileVerifier.java", producer + "PortValues.java",
                producer + "CertificateVerifier.java", producer + "ContainerLawDeclaration.java", producer + "OperatorDeclaration.java");
        var compiler = ToolProvider.getSystemJavaCompiler();
        var messages = new DiagnosticCollector<JavaFileObject>();
        try (var manager = compiler.getStandardFileManager(messages, null, StandardCharsets.UTF_8)) {
            var files = manager.getJavaFileObjectsFromPaths(paths.stream().map(root::resolve).toList());
            var task = (JavacTask) compiler.getTask(null, manager, messages, List.of("-proc:none", "--release", "17",
                    "-classpath", System.getProperty("java.class.path")),
                    null, files);
            var trees = Trees.instance(task);
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            for (CompilationUnitTree unit : units) new TreeScanner<Void, String>() {
                public Void visitClass(ClassTree c, String parent) {
                    return super.visitClass(c, c.getSimpleName().toString());
                }
                public Void visitMethod(MethodTree m, String owner) {
                    String id = owner + "." + m.getName() + "(" + String.join(",", m.getParameters().stream()
                            .map(v -> v.getType().toString()).toList()) + ")";
                    if (methods.putIfAbsent(id, m) != null) throw new AssertionError("ambiguous method " + id);
                    return null;
                }
            }.scan(unit, "");
            task.analyze();
            for (CompilationUnitTree unit : units) new TreePathScanner<Void, String>() {
                public Void visitClass(ClassTree c, String parent) {
                    return super.visitClass(c, c.getSimpleName().toString());
                }
                public Void visitMethod(MethodTree m, String owner) {
                    if (!CHECKED.getOrDefault(owner, Set.of()).contains(m.getName().toString())) return null;
                    String id = owner + "." + m.getName() + "(" + String.join(",", m.getParameters().stream()
                            .map(v -> v.getType().toString()).toList()) + ")";
                    List<String> calls = new ArrayList<>();
                    new TreePathScanner<Void, Void>() {
                        public Void visitMethodInvocation(MethodInvocationTree invocation, Void u) {
                            var callee = trees.getElement(getCurrentPath());
                            if (!(callee instanceof ExecutableElement fn))
                                throw new AssertionError("unresolved call in " + id);
                            calls.add(fn.getEnclosingElement() + "#" + fn);
                            return super.visitMethodInvocation(invocation, u);
                        }
                    }.scan(getCurrentPath(), null);
                    try {
                        var md = MessageDigest.getInstance("SHA-256");
                        String material = m + "\n" + String.join("\n", calls);
                        inventory.put(id, HexFormat.of().formatHex(md.digest(material.getBytes(StandardCharsets.UTF_8))));
                    } catch (java.security.NoSuchAlgorithmException e) { throw new AssertionError(e); }
                    return null;
                }
            }.scan(unit, "");
        }
        if (messages.getDiagnostics().stream().anyMatch(d -> d.getKind() == Diagnostic.Kind.ERROR))
            throw new AssertionError("failed to parse frozen Java");
    }

    private MethodTree method(String name) {
        MethodTree method = methods.get(name);
        if (method == null) throw new AssertionError("unresolved Java method " + name);
        return method;
    }

    private static List<String> args(MethodInvocationTree call) {
        return call.getArguments().stream().map(Tree::toString).toList();
    }

    private static MethodInvocationTree call(Tree parent, String name, int arity) {
        List<MethodInvocationTree> matches = new ArrayList<>();
        new TreeScanner<Void, Void>() {
            public Void visitMethodInvocation(MethodInvocationTree m, Void unused) {
                if (m.getMethodSelect().toString().equals(name) && m.getArguments().size() == arity) matches.add(m);
                return super.visitMethodInvocation(m, unused);
            }
        }.scan(parent, null);
        if (matches.size() != 1) throw new AssertionError("expected unique " + name + "/" + arity + ": " + matches.size());
        return matches.get(0);
    }

    private static void require(boolean ok, String detail) {
        if (!ok) throw new AssertionError(detail);
    }

    private static void fields(Tree tree, String name, String... expected) {
        var found = args(call(tree, name, expected.length));
        require(found.equals(Arrays.asList(expected)), name + " fields: " + found);
    }

    private static void ordered(MethodTree m, String... statements) {
        String body = m.getBody().toString().replaceAll("\\s+", "");
        int position = 0;
        for (String s : statements) {
            int idx = body.indexOf(s.replaceAll("\\s+", ""), position);
            require(idx >= 0, m.getName() + " missing ordered step " + s);
            position = idx + s.replaceAll("\\s+", "").length();
        }
    }

    static void check(Path root) throws Exception {
        var src = new P609SourceContract(root);
        Path registered = root.resolve("docs/obligation-repair/eighth-five/P609-methods.tsv");
        List<String> expected = Files.readAllLines(registered, StandardCharsets.UTF_8);
        List<String> found = src.inventory.entrySet().stream().map(e -> e.getKey() + "\t" + e.getValue()).toList();
        require(expected.equals(found), "P6-09 javac effects or resolved callees changed");
        var constructor = src.method("BinderOccurrenceAutomorphismCertificate.<init>(Build)");
        var superCall = call(constructor, "super", 5);
        require(args(superCall).subList(0, 4).equals(List.of("CertificateCategory.BINDER_AUTOMORPHISM",
                "TypedCertificateEndpoint.port(build.source)", "TypedCertificateEndpoint.port(build.target)",
                "Collections.singletonList(build.derivation)")), "producer binder wrapper");
        fields(superCall, "Arrays.asList", "build.enclosingRoot.structuralKey()",
                "build.source.schema().descriptor().structuralKey()", "TheoryKeys.context(build.source.context())",
                "TheoryKeys.embedding(build.source.descriptorToOccurrence())", "TheoryKeys.embedding(build.automorphism)",
                "TheoryKeys.embedding(build.occurrencePermutation)", "pathKey(build.sourcePath)",
                "build.source.structuralKey()", "build.target.structuralKey()");
        var wrap = src.method("TypedEqualityCertificate.<init>(CertificateCategory,TypedCertificateEndpoint,"
                + "TypedCertificateEndpoint,List<? extends TypedEqualityCertificate>,List<? extends StructuralKey>)");
        ordered(wrap, "children.add(leftEndpoint.structuralKey())", "children.add(rightEndpoint.structuralKey())",
                "children.add(endpointTypeCheck)", "for (StructuralKey detail : details)",
                "children.add(Objects.requireNonNull(detail", "for (TypedEqualityCertificate premise : copiedPremises)",
                "children.add(StructuralKey.branch(\"certificate-premise\"", "StructuralKey.of(\"typed-equality-certificate\"");
        var record = src.method("SemanticReplay.verifyBinderOccurrence(Wire.Node)");
        fields(record, "List.of", "termKey(root)", "descriptor.descriptorKey()", "contextKey(source.context())",
                "embeddingKey(occurrence)", "automorphismKey", "occurrenceKey", "pathKey", "termKey(source)",
                "termKey(target)");
        ordered(record, "record.requireShape(\"binder-occurrence\", 9, 0)", "root = model.term(record.scalar(8))",
                "!occursAtPath(root, source.id(), path)", "requireOccurrenceMap", "requireConjugate",
                "requireKey(record.scalar(0), expected", "binderEvidence.putIfAbsent");
        var derived = src.method("SemanticReplay.derivedBinderOccurrenceKey(KernelModel.Term,KernelModel.Term,"
                + "List<Integer>,BinderView,KernelModel.Embedding,List<Integer>)");
        fields(derived, "List.of", "termKey(root)", "descriptor.descriptorKey()", "contextKey(source.context())",
                "embeddingKey(occurrence)", "automorphismKey", "occurrenceKey", "pathKey", "termKey(source)",
                "expectedTarget");
        var writer = src.method("Assembler.binderOccurrence(BinderOccurrenceAutomorphismCertificate,TypedENode)");
        fields(writer, "leaf", "\"binder-occurrence\"", "certificate.structuralKey().stableString()",
                "scalar(term(certificate.source()), 0)", "scalar(term(certificate.target()), 0)",
                "encodePath(certificate.sourcePath())", "scalar(embedding(certificate.automorphism()), 0)",
                "scalar(embedding(certificate.occurrencePermutation()), 0)", "certificate.leftEndpoint().structuralKey().stableString()",
                "certificate.rightEndpoint().structuralKey().stableString()", "scalar(term(root), 0)");
        ordered(src.method("Assembler.binderRoot(BinderOccurrenceAutomorphismCertificate)"),
                "root = certificate.enclosingRoot()", "shape.node().equals(root)",
                "BinderOccurrenceProofs.collect(root).contains(certificate)", "return root");
        var wrapper = src.method("SemanticReplay.typedCertificate(String,StableKey,StableKey,List<StableKey>,List<StableKey>)");
        ordered(wrapper, "children.add(left)", "children.add(right)", "children.add(typeCheck)",
                "children.addAll(details)", "for (StableKey premise : premises)",
                "children.add(StableKey.of(\"certificate-premise\"", "StableKey.of(\"typed-equality-certificate\"");
        var walk = src.method("SemanticReplay.collectBinderObligations(KernelModel.Term,KernelModel.Term,List<Integer>,Set<String>)");
        ordered(walk, "current.kind() == KernelModel.TermKind.BIND_BLOCK",
                "for (List<Integer> generator : descriptor.generators())",
                "derivedBinderOccurrenceKey(root, current, path, descriptor, occurrence, generator)",
                "binderEvidence.get(key)", "evidence.rootTermId().equals(root.id())",
                "evidence.sourceTermId().equals(current.id())", "evidence.path().equals(path)",
                "target.add(key)", "index < current.children().size()", "childPath.add(index)",
                "collectBinderObligations(root, model.term(current.children().get(index)), List.copyOf(childPath), target)");
        var collect = src.method("BinderOccurrenceProofs.collect(TypedENode,PortValue,List<Integer>,List<BinderOccurrenceAutomorphismCertificate>)");
        ordered(collect, "port instanceof BindBlockPort", "BinderOccurrenceAutomorphismCertificate.create(enclosingRoot, block, path, generator)",
                "collect(enclosingRoot, block.body(), child(path, 0), target)", "port instanceof BindPort",
                "port instanceof SeqPort", "port instanceof BagPort", "port instanceof SetPort",
                "collect(enclosingRoot, children.get(index), child(path, index), target)");
        var producerFrame = src.method("StructuralKey.stableString()");
        var decoderFrame = src.method("StableKey.stableString()");
        require(producerFrame.getBody().toString().replace("StructuralKey child", "StableKey child")
                .equals(decoderFrame.getBody().toString()), "different producer/verifier key rendering");
        ordered(producerFrame, "appendEncoded(result, tag)", "append('[').append(scalars.size()).append(':')",
                "appendEncoded(result, scalar)", "append(']').append('{').append(children.size()).append(':')",
                "encoded.length()", "append(':').append(encoded)", "append('}')");
        for (String owner : List.of("StructuralKey", "StableKey"))
            ordered(src.method(owner + ".appendEncoded(StringBuilder,String)"), "append(value.length()).append(':').append(value)");
        ordered(src.method("AlloyLawRegistry.admitted(SemanticProfile,Opcode,GraphType,PortPath,PortSchema,ContainerLawCertificate.Law)"),
                "!PortPath.at(0).equals(path)", "return false", "OperatorDeclaration.elementSchema(schema)",
                "!(element instanceof OnePortSchema)", "return false");
    }
}
