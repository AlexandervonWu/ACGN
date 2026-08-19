package is.fivefivefive.CanDis;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.ast.nodes.ModelUnit;
import parser.util.AlloyUtil;

/** Producer-backed representative source export and independent-verifier census. */
public final class CertificateVerifierExportSmoke {
    private static final String SOURCE = """
            module certificate_smoke

            sig A {}

            pred nullary {}
            pred slotBearing[x: A] { x = x }
            pred deliberatelyUnsupported[x, y: A] {
              (x = y or x != y) and (y = x or y != x)
            }
            """;

    private CertificateVerifierExportSmoke() {
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            throw new IllegalArgumentException(
                    "usage: CertificateVerifierExportSmoke <output-dir>");
        }
        Path output = Path.of(args[0]).toAbsolutePath();
        Files.createDirectories(output);
        Path verifierJar = configuredVerifierJar();
        Parsed parsed = parseRepresentativeModel();
        List<Case> cases = List.of(
                new Case("nullary", "nullary construction"),
                new Case("slotBearing", "slot-bearing construction"),
                new Case("deliberatelyUnsupported", "deliberately unsupported construction"));
        List<Result> results = new ArrayList<>();
        for (Case testCase : cases) {
            results.add(export(parsed, testCase, output, verifierJar));
        }
        writeCensus(output.resolve("coverage-census.tsv"), results);
        long verified = results.stream().filter(value -> value.status.equals("VERIFIED")).count();
        long uncheckable = results.stream().filter(
                value -> value.status.equals("UNCHECKABLE")).count();
        long rejected = results.stream().filter(value -> value.status.equals("REJECTED")).count();
        System.out.println("certificate export census: total=" + results.size()
                + " VERIFIED=" + verified
                + " UNCHECKABLE=" + uncheckable
                + " REJECTED=" + rejected);
        for (Result result : results) {
            System.out.println(result.name + "\t" + result.status + "\t" + result.reason);
        }
        if (rejected != 0) {
            throw new IllegalStateException("Representative export census contains REJECTED cases");
        }
    }

    private static Result export(
            Parsed parsed,
            Case testCase,
            Path output,
            Path verifierJar) {
        Integer graphId = parsed.visitor.getForestId(testCase.name);
        DoubleMap<Integer, Multigraph> forest = parsed.visitor.getForest();
        Multigraph graph = graphId == null ? null : forest.get(graphId);
        if (graph == null) {
            return new Result(testCase.name, testCase.coverage, "REJECTED",
                    "MASG did not produce the selected predicate", "");
        }
        Path bundle = output.resolve(testCase.name + ".acgncert");
        try {
            CanonicalAlloyPipeline.Prepared prepared =
                    CanonicalAlloyPipeline.prepareForVerification(
                            graph,
                            "certificate-smoke.als#" + testCase.name,
                            SOURCE.getBytes(StandardCharsets.UTF_8));
            prepared.certificateExportSession().write(bundle);
            ProcessResult verification = verify(verifierJar, bundle);
            return new Result(
                    testCase.name,
                    testCase.coverage,
                    verification.exitCode == 0 ? "VERIFIED"
                            : verification.exitCode == 3 ? "UNCHECKABLE" : "REJECTED",
                    compact(verification.output),
                    bundle.getFileName().toString());
        } catch (UncheckedIOException exception) {
            return new Result(testCase.name, testCase.coverage, "REJECTED",
                    compact(exception.getMessage()), "");
        } catch (IOException exception) {
            String message = compact(exception.getMessage());
            String status = message.startsWith("UNCHECKABLE:")
                    ? "UNCHECKABLE" : "REJECTED";
            return new Result(testCase.name, testCase.coverage, status, message, "");
        } catch (RuntimeException exception) {
            return new Result(testCase.name, testCase.coverage, "REJECTED",
                    compact(exception.getClass().getSimpleName() + ": "
                            + exception.getMessage()), "");
        }
    }

    private static Parsed parseRepresentativeModel() throws Exception {
        Path directory = Files.createTempDirectory("acgn-certificate-smoke-");
        Path source = directory.resolve("certificate-smoke.als");
        try {
            Files.writeString(source, SOURCE, StandardCharsets.UTF_8);
            CompModule module = AlloyUtil.compileAlloyModule(source.toString());
            if (module == null) {
                throw new IllegalStateException("Alloy rejected the representative smoke model");
            }
            ModelUnit model = new ModelUnit(null, module);
            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);
            return new Parsed(visitor);
        } finally {
            Files.deleteIfExists(source);
            Files.deleteIfExists(directory);
        }
    }

    private static Path configuredVerifierJar() {
        String configured = System.getProperty("acgn.provenance.verifierJar", "");
        if (configured.isBlank()) {
            throw new IllegalStateException(
                    "acgn.provenance.verifierJar is required by the export smoke");
        }
        Path path = Path.of(configured).toAbsolutePath().normalize();
        if (!Files.isRegularFile(path)) {
            throw new IllegalStateException("Verifier JAR is missing: " + path);
        }
        return path;
    }

    private static ProcessResult verify(Path verifierJar, Path bundle) throws IOException {
        Process digestProcess = new ProcessBuilder(
                javaExecutable(), "-cp", verifierJar.toString(),
                "org.acgn.cert.ManifestInspector", bundle.toString())
                .redirectErrorStream(true)
                .start();
        String digest = readProcess(digestProcess, "manifest inspection").trim();
        Process verifyProcess = new ProcessBuilder(
                javaExecutable(), "-jar", verifierJar.toString(),
                "--profile", "full", "--theory-digest", digest, bundle.toString())
                .redirectErrorStream(true)
                .start();
        try {
            String output = new String(
                    verifyProcess.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
            return new ProcessResult(verifyProcess.waitFor(), output);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IOException("Verifier smoke was interrupted", exception);
        }
    }

    private static String readProcess(Process process, String label) throws IOException {
        try {
            String output = new String(
                    process.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
            int status = process.waitFor();
            if (status != 0) {
                throw new IOException(label + " failed: " + compact(output));
            }
            return output;
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new IOException(label + " was interrupted", exception);
        }
    }

    private static String javaExecutable() {
        return Path.of(System.getProperty("java.home"), "bin", "java").toString();
    }

    private static void writeCensus(Path output, List<Result> results) throws IOException {
        StringBuilder text = new StringBuilder("predicate\tcoverage\tstatus\treason\tbundle\n");
        for (Result result : results) {
            text.append(result.name).append('\t')
                    .append(result.coverage).append('\t')
                    .append(result.status).append('\t')
                    .append(result.reason.replace('\t', ' ')).append('\t')
                    .append(result.bundle).append('\n');
        }
        Files.writeString(output, text, StandardCharsets.UTF_8);
    }

    private static String compact(String value) {
        if (value == null || value.isBlank()) {
            return "no detail";
        }
        return value.replace('\n', ' ').replace('\r', ' ').trim();
    }

    private record Parsed(MASGVisitor visitor) {
    }

    private record Case(String name, String coverage) {
    }

    private record Result(
            String name,
            String coverage,
            String status,
            String reason,
            String bundle) {
    }

    private record ProcessResult(int exitCode, String output) {
    }
}
