import com.sun.source.tree.*;
import com.sun.source.util.*;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.stream.Stream;
import javax.lang.model.element.*;
import javax.tools.*;

/** Attributed direct-read census of the retained artifact and its public consumers. */
public final class RetainedArtifactReadsExtractor extends TreePathScanner<Void, Void> {
    private static final String THEORY = "is.fivefivefive.CanDis.theory.";
    private static final String ARTIFACT = THEORY + "CertifiedSemanticArtifact";
    private static final String WRITER = THEORY + "CertificateBundleWriter";
    private static final String PROJECTION = "is.fivefivefive.CanDis.metric.RepairProjection";
    private static final String CERT = "org.acgn.cert.";

    private final Trees trees;
    private final List<String> rows = new ArrayList<>();
    private final Map<String, Integer> ordinals = new HashMap<>();
    private final Set<String> fields = new TreeSet<>();
    private final Set<String> getters = new TreeSet<>();
    private String callerType = "";
    private String caller = "<initializer>";

    private RetainedArtifactReadsExtractor(Trees trees) {
        this.trees = trees;
    }

    private void record(String kind, String target, String detail) {
        String key = kind + "\t" + callerType + "\t" + caller;
        int ordinal = ordinals.merge(key, 1, Integer::sum);
        rows.add(key + "\t" + ordinal + "\t" + target + "\t"
                + detail.replaceAll("\\s+", " ").trim());
    }

    @Override
    public Void visitClass(ClassTree tree, Void unused) {
        String oldType = callerType;
        String oldCaller = caller;
        Element element = trees.getElement(getCurrentPath());
        if (!(element instanceof TypeElement type)) {
            throw new IllegalStateException("Unresolved source class: " + tree.getSimpleName());
        }
        String name = type.getQualifiedName().toString();
        callerType = name.isEmpty() ? oldType + "$local(" + oldCaller + ")" : name;
        caller = "<initializer>";
        try {
            return super.visitClass(tree, unused);
        } finally {
            callerType = oldType;
            caller = oldCaller;
        }
    }

    @Override
    public Void visitVariable(VariableTree tree, Void unused) {
        Element member = trees.getElement(getCurrentPath());
        if (callerType.equals(ARTIFACT) && member != null
                && member.getKind() == ElementKind.FIELD
                && !member.getModifiers().contains(Modifier.STATIC)) {
            if (!member.getModifiers().containsAll(Set.of(Modifier.PRIVATE, Modifier.FINAL))) {
                throw new IllegalStateException("Mutable or externally visible retained field: " + member);
            }
            fields.add(member.getSimpleName().toString());
            record("FIELD", member.getSimpleName().toString(), member.asType().toString());
        }
        return super.visitVariable(tree, unused);
    }

    @Override
    public Void visitMethod(MethodTree tree, Void unused) {
        String oldCaller = caller;
        ExecutableElement method = (ExecutableElement) trees.getElement(getCurrentPath());
        caller = method.toString();
        try {
            if (callerType.equals(ARTIFACT) && method.getParameters().isEmpty()
                    && method.getModifiers().contains(Modifier.PUBLIC)
                    && tree.getBody() != null && tree.getBody().getStatements().size() == 1
                    && tree.getBody().getStatements().get(0) instanceof ReturnTree ret) {
                Element value = trees.getElement(TreePath.getPath(getCurrentPath(), ret.getExpression()));
                if (value != null && value.getKind() == ElementKind.FIELD
                        && value.getEnclosingElement().equals(method.getEnclosingElement())
                        && value.getSimpleName().contentEquals(method.getSimpleName())) {
                    getters.add(value.getSimpleName().toString());
                    record("GETTER", value.getSimpleName().toString(), value.asType().toString());
                }
            }
            return super.visitMethod(tree, unused);
        } finally {
            caller = oldCaller;
        }
    }

    private void read(Tree site) {
        Element resolved = trees.getElement(getCurrentPath());
        if (!(resolved instanceof ExecutableElement target)) return;
        String owner = target.getEnclosingElement().toString();
        String name = target.getSimpleName().toString();
        String kind = null;
        if (owner.equals(ARTIFACT) && target.getParameters().isEmpty()
                && target.getModifiers().contains(Modifier.PUBLIC)
                && target.getKind() == ElementKind.METHOD) {
            kind = "ARTIFACT_READ";
        } else if (callerType.startsWith(WRITER) && owner.equals(THEORY + "CertificateExportSession")) {
            kind = "SESSION_READ";
        } else if (callerType.startsWith(PROJECTION) && owner.equals(THEORY + "TheoryAlloyAdapter.Result")) {
            kind = "ADAPTER_READ";
        } else if (callerType.startsWith(PROJECTION) && owner.equals("is.fivefivefive.CanDis.core.NormalForm")) {
            kind = "FORM_READ";
        } else if (callerType.startsWith(CERT) && !callerType.equals(CERT + "Bundle")
                && owner.equals(CERT + "Bundle") && target.getKind() == ElementKind.METHOD
                && !target.getModifiers().contains(Modifier.STATIC)) {
            kind = "BUNDLE_READ";
        } else if (callerType.startsWith(CERT) && owner.equals(CERT + "Bundle.Metadata")
                && target.getKind() == ElementKind.METHOD && target.getParameters().isEmpty()
                && !target.getModifiers().contains(Modifier.STATIC)) {
            kind = "BUNDLE_METADATA_READ";
        } else if (callerType.startsWith(CERT) && owner.equals(CERT + "VerificationPolicy")
                && target.getKind() == ElementKind.METHOD) {
            kind = "POLICY_READ";
        }
        if (kind != null) {
            String detail = site.toString();
            if (kind.equals("ARTIFACT_READ") && callerType.equals(WRITER + ".Assembler")
                    && caller.equals("semanticEvidence()")) {
                // Capture which local payload receives each accessor, including the two writers
                // into the flat-constructions wire table. No inference from similar field names.
                for (TreePath p = getCurrentPath(); p != null; p = p.getParentPath()) {
                    Tree node = p.getLeaf();
                    if (node instanceof EnhancedForLoopTree loop) {
                        detail = loop.getVariable() + " in " + loop.getExpression();
                        break;
                    }
                    if (node instanceof ExpressionStatementTree || node instanceof VariableTree) {
                        detail = node.toString();
                        break;
                    }
                }
            }
            record(kind, owner + "." + target, detail);
        }

        if (!(site instanceof MethodInvocationTree call)) return;
        Tree parent = getCurrentPath().getParentPath().getLeaf();
        if (callerType.equals(WRITER + ".Assembler") && caller.equals("semanticEvidence()")
                && owner.equals(WRITER) && name.equals("node")
                && call.getArguments().size() == 2 && parent instanceof MethodInvocationTree list) {
            int slot = list.getArguments().indexOf(call);
            if (slot >= 0) record("WIRE_WRITE", Integer.toString(slot), call.toString());
        }
        if (callerType.equals(CERT + "SemanticEvidenceVerifier") && caller.equals("verify()")
                && owner.equals(CERT + "Wire.Node") && name.equals("child")
                && call.getMethodSelect() instanceof MemberSelectTree select
                && select.getExpression().toString().equals("evidence")
                && parent instanceof MethodInvocationTree consumer) {
            Element endpoint = trees.getElement(getCurrentPath().getParentPath());
            record("WIRE_READ", call.getArguments().get(0).toString(), endpoint.getEnclosingElement()
                    + "." + endpoint + " argument " + consumer.getArguments().indexOf(call)
                    + " of " + consumer);
        }
    }

    @Override
    public Void visitMethodInvocation(MethodInvocationTree tree, Void unused) {
        read(tree);
        return super.visitMethodInvocation(tree, unused);
    }

    @Override
    public Void visitMemberReference(MemberReferenceTree tree, Void unused) {
        read(tree);
        return super.visitMemberReference(tree, unused);
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) throw new IllegalArgumentException("ROOT OUTPUT.tsv");
        Path root = Path.of(args[0]);
        List<Path> sources = new ArrayList<>();
        for (String dir : List.of("src", "certificate-verifier/src")) {
            try (Stream<Path> files = Files.walk(root.resolve(dir))) {
                files.filter(f -> f.toString().endsWith(".java") && !f.toString().endsWith("Test.java"))
                        .sorted().forEach(sources::add);
            }
        }
        List<String> classpath = new ArrayList<>();
        for (String name : List.of("ACGN_SIXTH_PRODUCER_CLASSES", "ACGN_SIXTH_VERIFIER_CLASSES")) {
            classpath.add(Objects.requireNonNull(System.getenv(name), name));
        }
        try (Stream<Path> files = Files.list(root.resolve("lib"))) {
            files.filter(f -> f.toString().endsWith(".jar")).sorted()
                    .forEach(f -> classpath.add(f.toString()));
        }
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (var manager = compiler.getStandardFileManager(diagnostics, Locale.ROOT, StandardCharsets.UTF_8)) {
            List<String> options = List.of("--release", "17", "-proc:none", "-implicit:none",
                    "-sourcepath", "", "-classpath", String.join(File.pathSeparator, classpath));
            JavacTask task = (JavacTask) compiler.getTask(null, manager, diagnostics, options, null,
                    manager.getJavaFileObjectsFromPaths(sources));
            List<CompilationUnitTree> units = new ArrayList<>();
            task.parse().forEach(units::add);
            task.analyze();
            for (var d : diagnostics.getDiagnostics()) {
                if (d.getKind() == Diagnostic.Kind.ERROR) throw new IllegalStateException(d.toString());
            }
            RetainedArtifactReadsExtractor extractor = new RetainedArtifactReadsExtractor(Trees.instance(task));
            for (CompilationUnitTree unit : units) extractor.scan(unit, null);
            if (extractor.fields.isEmpty() || !extractor.fields.equals(extractor.getters)) {
                throw new IllegalStateException("Unbound retained fields: " + extractor.fields
                        + " vs getter returns " + extractor.getters);
            }
            Collections.sort(extractor.rows);
            extractor.rows.add(0, "kind\towner\tmethod\toccurrence\ttarget\tdetail");
            Files.write(Path.of(args[1]), extractor.rows, StandardCharsets.UTF_8,
                    StandardOpenOption.CREATE_NEW);
        }
    }
}
