package is.fivefivefive.CanDis;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import edu.mit.csail.sdg.parser.CompModule;
import is.fivefivefive.ACGN.asg.Multigraph;
import is.fivefivefive.ACGN.learn.Rewarder;
import is.fivefivefive.ACGN.util.GlobalVariables;
import is.fivefivefive.ACGN.util.InstancePool;
import is.fivefivefive.ACGN.visitor.MASGVisitor;
import is.fivefivefive.alloyasg.etc.DoubleMap;
import parser.ast.nodes.ModelUnit;
import parser.ast.nodes.Node;
import parser.ast.nodes.Predicate;
import parser.util.AlloyUtil;
import parser.etc.Pair;

public class CanonicalBatchTest {
    private static final String DEFAULT_INPUT = "classified-data";
    private static final String DEFAULT_OUTPUT = "distance_results";
    private static final int DEFAULT_REWARD_POOL_SIZE = 10;
    private static final int DEFAULT_THREAD_COUNT = 32;

    public static void main(String[] args) throws IOException {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "error");
        Options options = Options.parse(args);
        Files.createDirectories(options.outputDir);
        Path jsonPath = options.outputDir.resolve("distances.json");
        Path markdownPath = options.outputDir.resolve("summary.md");

        List<Path> files = alloyFiles(options.inputDir);
        if (options.limit > 0 && options.limit < files.size()) {
            files = new ArrayList<>(files.subList(0, options.limit));
        }

        Summary summary = new Summary();
        List<FileResult> results = processFiles(files, options);
        try (Writer json = Files.newBufferedWriter(jsonPath, StandardCharsets.UTF_8)) {
            writeJsonHeader(json, options, files.size());
            for (int i = 0; i < results.size(); i++) {
                FileResult result = results.get(i);
                summary.add(result);
                if (i > 0) {
                    json.write(",\n");
                }
                writeJsonResult(json, result);
                if (options.verbose) {
                    System.err.println(result.relativePath + " -> " + result.status());
                }
            }
            writeJsonFooter(json, summary);
        }
        writeMarkdown(markdownPath, options, summary);
        System.out.println("Wrote " + jsonPath);
        System.out.println("Wrote " + markdownPath);
    }

    private static List<FileResult> processFiles(List<Path> files, Options options) {
        PrintStream originalOut = System.out;
        PrintStream originalErr = System.err;
        if (!options.verbose) {
            PrintStream sink = new PrintStream(new OutputStream() {
                @Override
                public void write(int b) {
                }
            });
            System.setOut(sink);
            System.setErr(sink);
        }
        ExecutorService executor = Executors.newFixedThreadPool(Math.max(1, options.threadCount));
        try {
            List<Future<FileResult>> futures = new ArrayList<>(files.size());
            for (Path file : files) {
                Callable<FileResult> task = () -> processFile(options.inputDir, file, options);
                futures.add(executor.submit(task));
            }
            List<FileResult> results = new ArrayList<>(files.size());
            for (int i = 0; i < futures.size(); i++) {
                try {
                    results.add(futures.get(i).get());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    results.add(failedResult(options.inputDir, files.get(i), "InterruptedException: " + e.getMessage()));
                } catch (ExecutionException e) {
                    Throwable cause = e.getCause() == null ? e : e.getCause();
                    results.add(failedResult(options.inputDir, files.get(i),
                            cause.getClass().getSimpleName() + ": " + cause.getMessage()));
                }
            }
            return results;
        } finally {
            executor.shutdownNow();
            if (!options.verbose) {
                System.setOut(originalOut);
                System.setErr(originalErr);
            }
        }
    }

    private static FileResult failedResult(Path inputRoot, Path file, String error) {
        FileResult result = new FileResult(inputRoot, file);
        result.error = error;
        return result;
    }

    private static FileResult processFile(Path inputRoot, Path file, Options options) {
        FileResult result = new FileResult(inputRoot, file);
        try {
            CompModule module = AlloyUtil.compileAlloyModule(file.toString());
            ModelUnit model = new ModelUnit(null, module);
            PredicatePair pair = findPredicatePair(file, model);
            if (pair == null) {
                result.error = "No predicate pair of the form X and XC found.";
                return result;
            }
            String leftBody = predicateBody(file, pair.leftName, pair.left);
            String rightBody = predicateBody(file, pair.rightName, pair.right);
            result.leftPredicate = pair.leftName;
            result.rightPredicate = pair.rightName;
            result.leftRawAstSize = rawAstSize(pair.left.getBody());
            result.rightRawAstSize = rawAstSize(pair.right.getBody());
            result.rawAstSize = Math.max(result.leftRawAstSize, result.rightRawAstSize);
            result.rawAstTreeDistance = rawAstTreeDistance(pair.left.getBody(), pair.right.getBody());
            result.normalizedRawAstDistance = normalizedDistance(result.rawAstTreeDistance, result.rawAstSize);
            if (result.rawAstTreeDistance == 0) {
                result.skipped = true;
                result.skipReason = "Identical raw AST predicate body.";
                return result;
            }

            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);
            DoubleMap<Integer, Multigraph> forest = visitor.getForest();
            Multigraph left = forest.get(pair.leftId);
            Multigraph right = forest.get(pair.rightId);
            if (left == null || right == null) {
                result.error = "Could not find both predicate graphs in MASG forest.";
                return result;
            }

            result.leftGraphId = pair.leftId;
            result.rightGraphId = pair.rightId;
            result.predicateBodyLevenshteinDistance = levenshteinDistance(leftBody, rightBody);
            result.leftVertices = left.size();
            result.rightVertices = right.size();
            result.distance = Canonical.distance(left, right);
            result.leftCanonicalFormSize = Canonical.canonicalFormSize(left);
            result.rightCanonicalFormSize = Canonical.canonicalFormSize(right);
            result.canonicalFormSize = Math.max(result.leftCanonicalFormSize, result.rightCanonicalFormSize);
            result.normalizedCanonicalDistance = normalizedDistance(result.distance, result.canonicalFormSize);
            result.leftIRTemporalFOL = Canonical.irTemporalFol(left);
            result.rightIRTemporalFOL = Canonical.irTemporalFol(right);
            result.edits = Canonical.edits(left, right);
            computeRewardMetrics(module, result, options.rewardPoolSize);
            return result;
        } catch (Throwable t) {
            if (options.verbose) {
                t.printStackTrace(System.err);
            }
            result.error = t.getClass().getSimpleName() + ": " + t.getMessage();
            return result;
        }
    }

    private static void computeRewardMetrics(CompModule module, FileResult result, int poolSize) {
        try {
            Pair<InstancePool, InstancePool> instances = Rewarder.instances(module, result.rightPredicate, poolSize);
            result.rewardPoolSize = poolSize;
            result.candidateReward = Rewarder.computeReward(
                    module,
                    instances,
                    result.rightPredicate,
                    result.leftPredicate,
                    result.leftPredicate,
                    poolSize);
            result.groundTruthReward = Rewarder.computeReward(
                    module,
                    instances,
                    result.rightPredicate,
                    result.rightPredicate,
                    result.rightPredicate,
                    poolSize);
            result.rewardGap = result.groundTruthReward - result.candidateReward;
        } catch (Throwable t) {
            result.rewardError = t.getClass().getSimpleName() + ": " + t.getMessage();
        }
    }

    private static PredicatePair findPredicatePair(Path file, ModelUnit model) {
        Map<String, Predicate> predicates = new HashMap<>();
        Map<String, Integer> ids = new HashMap<>();
        int id = 1;
        for (Predicate predicate : model.getPredDeclList()) {
            predicates.put(predicate.getName(), predicate);
            ids.put(predicate.getName(), id++);
        }

        String preferred = preferredPredicateBase(file);
        if (preferred != null && ids.containsKey(preferred) && ids.containsKey(preferred + "C")) {
            return new PredicatePair(preferred, preferred + "C", ids.get(preferred), ids.get(preferred + "C"),
                    predicates.get(preferred), predicates.get(preferred + "C"));
        }

        for (String name : ids.keySet()) {
            if (name.endsWith("C") && name.length() > 1) {
                String base = name.substring(0, name.length() - 1);
                if (ids.containsKey(base)) {
                    return new PredicatePair(base, name, ids.get(base), ids.get(name),
                            predicates.get(base), predicates.get(name));
                }
            }
        }
        return null;
    }

    private static String predicateBody(Path file, String predicateName, Predicate predicate) {
        try {
            String source = Files.readString(file, StandardCharsets.UTF_8);
            String body = predicateBodyFromSource(source, predicateName);
            if (body != null) {
                return normalizeWhitespace(body);
            }
        } catch (IOException ignored) {
        }
        if (predicate == null || predicate.getBody() == null || predicate.getBody().getBodyExpr() == null) {
            return "";
        }
        return predicate.getBody().getBodyExpr().toString();
    }

    private static String predicateBodyFromSource(String source, String predicateName) {
        String needle = "pred " + predicateName;
        int start = source.indexOf(needle);
        while (start >= 0) {
            int nameEnd = start + needle.length();
            if (nameEnd < source.length() && Character.isJavaIdentifierPart(source.charAt(nameEnd))) {
                start = source.indexOf(needle, nameEnd);
                continue;
            }
            int open = source.indexOf('{', nameEnd);
            if (open < 0) {
                return null;
            }
            int close = matchingBrace(source, open);
            return close < 0 ? null : source.substring(open + 1, close);
        }
        return null;
    }

    private static int matchingBrace(String source, int open) {
        int depth = 0;
        for (int i = open; i < source.length(); i++) {
            char c = source.charAt(i);
            if (c == '{') {
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0) {
                    return i;
                }
            }
        }
        return -1;
    }

    private static String normalizeWhitespace(String value) {
        return value.replaceAll("\\s+", " ").trim();
    }

    private static int levenshteinDistance(String left, String right) {
        int[] previous = new int[right.length() + 1];
        int[] current = new int[right.length() + 1];
        for (int j = 0; j <= right.length(); j++) {
            previous[j] = j;
        }
        for (int i = 1; i <= left.length(); i++) {
            current[0] = i;
            for (int j = 1; j <= right.length(); j++) {
                int replace = previous[j - 1] + (left.charAt(i - 1) == right.charAt(j - 1) ? 0 : 1);
                int delete = previous[j] + 1;
                int insert = current[j - 1] + 1;
                current[j] = Math.min(replace, Math.min(delete, insert));
            }
            int[] temp = previous;
            previous = current;
            current = temp;
        }
        return previous[right.length()];
    }

    private static int rawAstTreeDistance(Node left, Node right) {
        if (left == null) {
            return rawAstSize(right);
        }
        if (right == null) {
            return rawAstSize(left);
        }
        int distance = rawAstLabel(left).equals(rawAstLabel(right)) ? 0 : 1;
        distance += rawAstForestDistance(left.getChildren(), right.getChildren());
        return distance;
    }

    private static int rawAstForestDistance(List<Node> left, List<Node> right) {
        int[][] dp = new int[left.size() + 1][right.size() + 1];
        for (int i = 1; i <= left.size(); i++) {
            dp[i][0] = dp[i - 1][0] + rawAstSize(left.get(i - 1));
        }
        for (int j = 1; j <= right.size(); j++) {
            dp[0][j] = dp[0][j - 1] + rawAstSize(right.get(j - 1));
        }
        for (int i = 1; i <= left.size(); i++) {
            for (int j = 1; j <= right.size(); j++) {
                int delete = dp[i - 1][j] + rawAstSize(left.get(i - 1));
                int insert = dp[i][j - 1] + rawAstSize(right.get(j - 1));
                int update = dp[i - 1][j - 1] + rawAstTreeDistance(left.get(i - 1), right.get(j - 1));
                dp[i][j] = Math.min(update, Math.min(delete, insert));
            }
        }
        return dp[left.size()][right.size()];
    }

    private static int rawAstSize(Node node) {
        if (node == null) {
            return 0;
        }
        int size = 1;
        for (Node child : node.getChildren()) {
            size += rawAstSize(child);
        }
        return size;
    }

    private static double normalizedDistance(int distance, int size) {
        return size == 0 ? 0.0 : (double) distance / size;
    }

    private static String rawAstLabel(Node node) {
        StringBuilder label = new StringBuilder(node.getClass().getSimpleName());
        appendAstAttribute(label, node, "getOp");
        appendAstAttribute(label, node, "getName");
        appendAstAttribute(label, node, "getValue");
        return label.toString();
    }

    private static void appendAstAttribute(StringBuilder label, Node node, String methodName) {
        try {
            Object value = node.getClass().getMethod(methodName).invoke(node);
            if (value != null) {
                label.append(':').append(value);
            }
        } catch (ReflectiveOperationException ignored) {
        }
    }

    private static String preferredPredicateBase(Path file) {
        String name = file.getFileName().toString();
        int dot = name.lastIndexOf('.');
        if (dot >= 0) {
            name = name.substring(0, dot);
        }
        int underscore = name.lastIndexOf('_');
        if (underscore < 0 || underscore + 1 >= name.length()) {
            return null;
        }
        return name.substring(underscore + 1);
    }

    private static List<Path> alloyFiles(Path root) throws IOException {
        List<Path> files = new ArrayList<>();
        try (java.util.stream.Stream<Path> stream = Files.walk(root)) {
            stream.filter(path -> Files.isRegularFile(path) && path.toString().endsWith(".als"))
                    .forEach(files::add);
        }
        files.sort(Comparator.comparing(Path::toString));
        return files;
    }

    private static void writeJsonHeader(Writer writer, Options options, int fileCount) throws IOException {
        writer.write("{\n");
        writer.write("  \"generatedAt\": \"" + escape(Instant.now().toString()) + "\",\n");
        writer.write("  \"inputRoot\": \"" + escape(options.inputDir.toString()) + "\",\n");
        writer.write("  \"fileCount\": " + fileCount + ",\n");
        writer.write("  \"threadCount\": " + options.threadCount + ",\n");
        writer.write("  \"results\": [\n");
    }

    private static void writeJsonFooter(Writer writer, Summary summary) throws IOException {
        writer.write("\n  ],\n");
        writer.write("  \"summary\": {\n");
        writer.write("    \"total\": " + summary.total + ",\n");
        writer.write("    \"successes\": " + summary.successes + ",\n");
        writer.write("    \"skippedIdenticalRawAstPairs\": " + summary.skipped + ",\n");
        writer.write("    \"failures\": " + summary.failures + ",\n");
        writer.write("    \"averageDistance\": " + number(summary.averageDistance()) + ",\n");
        writer.write("    \"averagePredicateBodyLevenshteinDistance\": " + number(summary.averageLevenshteinDistance()) + ",\n");
        writer.write("    \"averageRawAstTreeDistance\": " + number(summary.averageRawAstTreeDistance()) + ",\n");
        writer.write("    \"averageRawAstSize\": " + number(summary.averageRawAstSize()) + ",\n");
        writer.write("    \"averageCanonicalFormSize\": " + number(summary.averageCanonicalFormSize()) + ",\n");
        writer.write("    \"averageNormalizedRawAstDistance\": " + number(summary.averageNormalizedRawAstDistance()) + ",\n");
        writer.write("    \"averageNormalizedCanonicalDistance\": " + number(summary.averageNormalizedCanonicalDistance()) + ",\n");
        writer.write("    \"correctCanonicalZeroRawAstNonzero\": "
                + summary.correctCanonicalZeroRawAstNonzero + ",\n");
        writer.write("    \"minDistance\": " + summary.minDistanceJson() + ",\n");
        writer.write("    \"maxDistance\": " + summary.maxDistanceJson() + ",\n");
        writer.write("    \"rewardSuccesses\": " + summary.rewardSuccesses + ",\n");
        writer.write("    \"rewardFailures\": " + summary.rewardFailures() + ",\n");
        writer.write("    \"averageCandidateReward\": " + number(summary.averageCandidateReward()) + ",\n");
        writer.write("    \"averageGroundTruthReward\": " + number(summary.averageGroundTruthReward()) + ",\n");
        writer.write("    \"averageRewardGap\": " + number(summary.averageRewardGap()) + ",\n");
        writer.write("    \"distanceCandidateRewardPearsonSamples\": " + summary.distanceRewardSamples + ",\n");
        writer.write("    \"distanceCandidateRewardPearson\": " + number(summary.distanceRewardCorrelation()) + ",\n");
        writer.write("    \"levenshteinCandidateRewardPearson\": " + number(summary.levenshteinRewardCorrelation()) + ",\n");
        writer.write("    \"rawAstCandidateRewardPearson\": " + number(summary.rawAstRewardCorrelation()) + ",\n");
        writer.write("    \"normalizedRawAstCandidateRewardPearson\": "
                + number(summary.normalizedRawAstRewardCorrelation()) + ",\n");
        writer.write("    \"normalizedCanonicalCandidateRewardPearson\": "
                + number(summary.normalizedCanonicalRewardCorrelation()) + "\n");
        writer.write("  }\n");
        writer.write("}\n");
    }

    private static void writeJsonResult(Writer writer, FileResult result) throws IOException {
        writer.write("    {\n");
        writer.write("      \"fileName\": \"" + escape(result.fileName) + "\",\n");
        writer.write("      \"relativePath\": \"" + escape(result.relativePath) + "\",\n");
        writer.write("      \"problemClass\": \"" + escape(result.problemClass) + "\",\n");
        writer.write("      \"statusFolder\": \"" + escape(result.statusFolder) + "\",\n");
        writer.write("      \"success\": " + result.success() + ",\n");
        if (result.success()) {
            writer.write("      \"leftPredicate\": \"" + escape(result.leftPredicate) + "\",\n");
            writer.write("      \"rightPredicate\": \"" + escape(result.rightPredicate) + "\",\n");
            writer.write("      \"leftGraphId\": " + result.leftGraphId + ",\n");
            writer.write("      \"rightGraphId\": " + result.rightGraphId + ",\n");
            writer.write("      \"leftVertices\": " + result.leftVertices + ",\n");
            writer.write("      \"rightVertices\": " + result.rightVertices + ",\n");
            writer.write("      \"leftRawAstSize\": " + result.leftRawAstSize + ",\n");
            writer.write("      \"rightRawAstSize\": " + result.rightRawAstSize + ",\n");
            writer.write("      \"rawAstSize\": " + result.rawAstSize + ",\n");
            writer.write("      \"predicateBodyLevenshteinDistance\": " + result.predicateBodyLevenshteinDistance + ",\n");
            writer.write("      \"rawAstTreeDistance\": " + result.rawAstTreeDistance + ",\n");
            writer.write("      \"normalizedRawAstDistance\": " + number(result.normalizedRawAstDistance) + ",\n");
            writer.write("      \"leftCanonicalFormSize\": " + result.leftCanonicalFormSize + ",\n");
            writer.write("      \"rightCanonicalFormSize\": " + result.rightCanonicalFormSize + ",\n");
            writer.write("      \"canonicalFormSize\": " + result.canonicalFormSize + ",\n");
            writer.write("      \"distance\": " + result.distance + ",\n");
            writer.write("      \"normalizedCanonicalDistance\": " + number(result.normalizedCanonicalDistance) + ",\n");
            writer.write("      \"rewardPoolSize\": " + result.rewardPoolSize + ",\n");
            if (result.rewardError == null) {
                writer.write("      \"candidateReward\": " + number(result.candidateReward) + ",\n");
                writer.write("      \"groundTruthReward\": " + number(result.groundTruthReward) + ",\n");
                writer.write("      \"rewardGap\": " + number(result.rewardGap) + ",\n");
            } else {
                writer.write("      \"candidateReward\": null,\n");
                writer.write("      \"groundTruthReward\": null,\n");
                writer.write("      \"rewardGap\": null,\n");
                writer.write("      \"rewardError\": \"" + escape(result.rewardError) + "\",\n");
            }
            writer.write("      \"leftIRTemporalFOL\": ");
            writeJsonStringArray(writer, result.leftIRTemporalFOL);
            writer.write(",\n");
            writer.write("      \"rightIRTemporalFOL\": ");
            writeJsonStringArray(writer, result.rightIRTemporalFOL);
            writer.write(",\n");
            writer.write("      \"editCount\": " + result.edits.size() + ",\n");
            writer.write("      \"edits\": ");
            writeJsonStringArray(writer, result.edits);
            writer.write("\n");
        } else if (result.skipped) {
            writer.write("      \"skipped\": true,\n");
            writer.write("      \"leftPredicate\": \"" + escape(result.leftPredicate) + "\",\n");
            writer.write("      \"rightPredicate\": \"" + escape(result.rightPredicate) + "\",\n");
            writer.write("      \"leftRawAstSize\": " + result.leftRawAstSize + ",\n");
            writer.write("      \"rightRawAstSize\": " + result.rightRawAstSize + ",\n");
            writer.write("      \"rawAstSize\": " + result.rawAstSize + ",\n");
            writer.write("      \"rawAstTreeDistance\": " + result.rawAstTreeDistance + ",\n");
            writer.write("      \"skipReason\": \"" + escape(result.skipReason) + "\"\n");
        } else {
            writer.write("      \"skipped\": false,\n");
            writer.write("      \"error\": \"" + escape(result.error) + "\"\n");
        }
        writer.write("    }");
    }

    private static void writeMarkdown(Path path, Options options, Summary summary) throws IOException {
        try (Writer writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
            writer.write("# Canonical Rewrite Distance Summary\n\n");
            writer.write("- Input root: `" + options.inputDir + "`\n");
            writer.write("- Thread count: " + options.threadCount + "\n");
            writer.write("- Total files: " + summary.total + "\n");
            writer.write("- Successful distances: " + summary.successes + "\n");
            writer.write("- Skipped identical raw AST predicate pairs: " + summary.skipped + "\n");
            writer.write("- Failures: " + summary.failures + "\n");
            writer.write("- Average distance: " + number(summary.averageDistance()) + "\n");
            writer.write("- Average predicate-body Levenshtein distance: "
                    + number(summary.averageLevenshteinDistance()) + "\n");
            writer.write("- Average raw AST tree distance: " + number(summary.averageRawAstTreeDistance()) + "\n");
            writer.write("- Average raw AST size: " + number(summary.averageRawAstSize()) + "\n");
            writer.write("- Average canonical form size: " + number(summary.averageCanonicalFormSize()) + "\n");
            writer.write("- Average normalized raw AST distance: "
                    + number(summary.averageNormalizedRawAstDistance()) + "\n");
            writer.write("- Average normalized canonical distance: "
                    + number(summary.averageNormalizedCanonicalDistance()) + "\n");
            writer.write("- CORRECT models with canonical distance 0 and raw AST distance > 0: "
                    + summary.correctCanonicalZeroRawAstNonzero + "\n");
            writer.write("- Min distance: " + summary.minDistanceMarkdown() + "\n");
            writer.write("- Max distance: " + summary.maxDistanceMarkdown() + "\n\n");
            writer.write("## Reward Comparison\n\n");
            writer.write("- Rewarded files: " + summary.rewardSuccesses + "\n");
            writer.write("- Reward failures: " + summary.rewardFailures() + "\n");
            writer.write("- Reward pool size: " + options.rewardPoolSize + "\n");
            writer.write("- Average candidate reward: " + number(summary.averageCandidateReward()) + "\n");
            writer.write("- Average ground-truth self reward: " + number(summary.averageGroundTruthReward()) + "\n");
            writer.write("- Average reward gap: " + number(summary.averageRewardGap()) + "\n");
            writer.write("- Pearson correlation sample: non-CORRECT rewarded predicates ("
                    + summary.distanceRewardSamples + " files)\n");
            writer.write("- Pearson correlation, distance vs candidate reward: "
                    + number(summary.distanceRewardCorrelation()) + "\n\n");
            writer.write("- Pearson correlation, Levenshtein vs candidate reward: "
                    + number(summary.levenshteinRewardCorrelation()) + "\n");
            writer.write("- Pearson correlation, raw AST tree distance vs candidate reward: "
                    + number(summary.rawAstRewardCorrelation()) + "\n\n");
            writer.write("- Pearson correlation, normalized raw AST distance vs candidate reward: "
                    + number(summary.normalizedRawAstRewardCorrelation()) + "\n");
            writer.write("- Pearson correlation, normalized canonical distance vs candidate reward: "
                    + number(summary.normalizedCanonicalRewardCorrelation()) + "\n\n");

            writer.write("## By Problem Class And Status\n\n");
            writer.write("| Problem class | Status | Files | Successes | Skipped | Failures | Avg distance | Avg reward | Corr(distance,reward) | Min | Max |\n");
            writer.write("| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n");
            for (Map.Entry<String, Stats> entry : summary.groupStats.entrySet()) {
                Stats stats = entry.getValue();
                writer.write("| " + stats.problemClass + " | " + stats.statusFolder + " | "
                        + stats.total + " | " + stats.successes + " | " + stats.skipped + " | "
                        + stats.failures + " | "
                        + number(stats.averageDistance()) + " | " + number(stats.averageCandidateReward()) + " | "
                        + number(stats.distanceRewardCorrelation()) + " | " + stats.minDistanceMarkdown() + " | "
                        + stats.maxDistanceMarkdown() + " |\n");
            }

            if (!summary.failureSamples.isEmpty()) {
                writer.write("\n## Failure Samples\n\n");
                for (FileResult result : summary.failureSamples) {
                    writer.write("- `" + result.relativePath + "`: " + result.error + "\n");
                }
            }
        }
    }

    private static void writeJsonStringArray(Writer writer, List<String> values) throws IOException {
        writer.write("[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) {
                writer.write(", ");
            }
            writer.write("\"" + escape(values.get(i)) + "\"");
        }
        writer.write("]");
    }

    private static String escape(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char c = value.charAt(i);
            switch (c) {
                case '\\':
                    sb.append("\\\\");
                    break;
                case '"':
                    sb.append("\\\"");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    if (c < 0x20) {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    private static String number(double value) {
        return String.format(java.util.Locale.ROOT, "%.6f", value);
    }

    private static class Options {
        private Path inputDir = Paths.get(DEFAULT_INPUT);
        private Path outputDir = Paths.get(DEFAULT_OUTPUT);
        private int limit = -1;
        private int rewardPoolSize = DEFAULT_REWARD_POOL_SIZE;
        private int threadCount = DEFAULT_THREAD_COUNT;
        private boolean verbose;

        private static Options parse(String[] args) {
            Options options = new Options();
            int positional = 0;
            for (int i = 0; i < args.length; i++) {
                if ("--limit".equals(args[i]) && i + 1 < args.length) {
                    options.limit = Integer.parseInt(args[++i]);
                } else if ("--reward-pool".equals(args[i]) && i + 1 < args.length) {
                    options.rewardPoolSize = Integer.parseInt(args[++i]);
                } else if ("--threads".equals(args[i]) && i + 1 < args.length) {
                    options.threadCount = Integer.parseInt(args[++i]);
                } else if ("--verbose".equals(args[i])) {
                    options.verbose = true;
                } else if (positional == 0) {
                    options.inputDir = Paths.get(args[i]);
                    positional++;
                } else if (positional == 1) {
                    options.outputDir = Paths.get(args[i]);
                    positional++;
                }
            }
            return options;
        }
    }

    private static class PredicatePair {
        private final String leftName;
        private final String rightName;
        private final int leftId;
        private final int rightId;
        private final Predicate left;
        private final Predicate right;

        private PredicatePair(String leftName, String rightName, int leftId, int rightId, Predicate left, Predicate right) {
            this.leftName = leftName;
            this.rightName = rightName;
            this.leftId = leftId;
            this.rightId = rightId;
            this.left = left;
            this.right = right;
        }
    }

    private static class FileResult {
        private final String fileName;
        private final String relativePath;
        private final String problemClass;
        private final String statusFolder;
        private String leftPredicate;
        private String rightPredicate;
        private int leftGraphId;
        private int rightGraphId;
        private int leftVertices;
        private int rightVertices;
        private int leftRawAstSize;
        private int rightRawAstSize;
        private int rawAstSize;
        private int predicateBodyLevenshteinDistance;
        private int rawAstTreeDistance;
        private double normalizedRawAstDistance;
        private int leftCanonicalFormSize;
        private int rightCanonicalFormSize;
        private int canonicalFormSize;
        private int distance;
        private double normalizedCanonicalDistance;
        private int rewardPoolSize;
        private double candidateReward;
        private double groundTruthReward;
        private double rewardGap;
        private String rewardError;
        private List<String> leftIRTemporalFOL = new ArrayList<>();
        private List<String> rightIRTemporalFOL = new ArrayList<>();
        private List<String> edits = new ArrayList<>();
        private boolean skipped;
        private String skipReason;
        private String error;

        private FileResult(Path root, Path file) {
            Path relative = root.relativize(file);
            this.fileName = file.getFileName().toString();
            this.relativePath = relative.toString().replace('\\', '/');
            this.problemClass = relative.getNameCount() > 0 ? relative.getName(0).toString() : "";
            this.statusFolder = relative.getNameCount() > 1 ? relative.getName(1).toString() : "";
        }

        private boolean success() {
            return error == null && !skipped;
        }

        private String status() {
            if (success()) {
                return "distance " + distance;
            }
            return skipped ? "skipped " + skipReason : "error " + error;
        }
    }

    private static class Summary {
        private int total;
        private int successes;
        private int skipped;
        private int failures;
        private long distanceSum;
        private long levenshteinDistanceSum;
        private long rawAstTreeDistanceSum;
        private long rawAstSizeSum;
        private long canonicalFormSizeSum;
        private double normalizedRawAstDistanceSum;
        private double normalizedCanonicalDistanceSum;
        private int correctCanonicalZeroRawAstNonzero;
        private Integer minDistance;
        private Integer maxDistance;
        private int rewardSuccesses;
        private double candidateRewardSum;
        private double groundTruthRewardSum;
        private double rewardGapSum;
        private int distanceRewardSamples;
        private double distanceRewardXSum;
        private double distanceRewardYSum;
        private double distanceRewardXXSum;
        private double distanceRewardYYSum;
        private double distanceRewardXYSum;
        private double levenshteinRewardXSum;
        private double levenshteinRewardXXSum;
        private double levenshteinRewardXYSum;
        private double rawAstRewardXSum;
        private double rawAstRewardXXSum;
        private double rawAstRewardXYSum;
        private double normalizedRawAstRewardXSum;
        private double normalizedRawAstRewardXXSum;
        private double normalizedRawAstRewardXYSum;
        private double normalizedCanonicalRewardXSum;
        private double normalizedCanonicalRewardXXSum;
        private double normalizedCanonicalRewardXYSum;
        private Map<String, Stats> groupStats = new java.util.TreeMap<>();
        private List<FileResult> failureSamples = new ArrayList<>();

        private void add(FileResult result) {
            total++;
            Stats stats = groupStats.computeIfAbsent(
                    result.problemClass + "/" + result.statusFolder,
                    key -> new Stats(result.problemClass, result.statusFolder));
            stats.add(result);
            if (result.skipped) {
                skipped++;
            } else if (result.success()) {
                successes++;
                distanceSum += result.distance;
                levenshteinDistanceSum += result.predicateBodyLevenshteinDistance;
                rawAstTreeDistanceSum += result.rawAstTreeDistance;
                rawAstSizeSum += result.rawAstSize;
                canonicalFormSizeSum += result.canonicalFormSize;
                normalizedRawAstDistanceSum += result.normalizedRawAstDistance;
                normalizedCanonicalDistanceSum += result.normalizedCanonicalDistance;
                if ("CORRECT".equals(result.statusFolder)
                        && result.distance == 0
                        && result.rawAstTreeDistance > 0) {
                    correctCanonicalZeroRawAstNonzero++;
                }
                minDistance = minDistance == null ? result.distance : Math.min(minDistance, result.distance);
                maxDistance = maxDistance == null ? result.distance : Math.max(maxDistance, result.distance);
                if (result.rewardError == null) {
                    rewardSuccesses++;
                    candidateRewardSum += result.candidateReward;
                    groundTruthRewardSum += result.groundTruthReward;
                    rewardGapSum += result.rewardGap;
                    if (isCorrelationEligible(result)) {
                        distanceRewardSamples++;
                        distanceRewardXSum += result.distance;
                        distanceRewardYSum += result.candidateReward;
                        distanceRewardXXSum += (double) result.distance * result.distance;
                        distanceRewardYYSum += result.candidateReward * result.candidateReward;
                        distanceRewardXYSum += result.distance * result.candidateReward;
                        levenshteinRewardXSum += result.predicateBodyLevenshteinDistance;
                        levenshteinRewardXXSum += (double) result.predicateBodyLevenshteinDistance
                                * result.predicateBodyLevenshteinDistance;
                        levenshteinRewardXYSum += result.predicateBodyLevenshteinDistance * result.candidateReward;
                        rawAstRewardXSum += result.rawAstTreeDistance;
                        rawAstRewardXXSum += (double) result.rawAstTreeDistance * result.rawAstTreeDistance;
                        rawAstRewardXYSum += result.rawAstTreeDistance * result.candidateReward;
                        normalizedRawAstRewardXSum += result.normalizedRawAstDistance;
                        normalizedRawAstRewardXXSum += result.normalizedRawAstDistance
                                * result.normalizedRawAstDistance;
                        normalizedRawAstRewardXYSum += result.normalizedRawAstDistance * result.candidateReward;
                        normalizedCanonicalRewardXSum += result.normalizedCanonicalDistance;
                        normalizedCanonicalRewardXXSum += result.normalizedCanonicalDistance
                                * result.normalizedCanonicalDistance;
                        normalizedCanonicalRewardXYSum += result.normalizedCanonicalDistance * result.candidateReward;
                    }
                }
            } else {
                failures++;
                if (failureSamples.size() < 25) {
                    failureSamples.add(result);
                }
            }
        }

        private double averageDistance() {
            return successes == 0 ? 0.0 : (double) distanceSum / successes;
        }

        private double averageLevenshteinDistance() {
            return successes == 0 ? 0.0 : (double) levenshteinDistanceSum / successes;
        }

        private double averageRawAstTreeDistance() {
            return successes == 0 ? 0.0 : (double) rawAstTreeDistanceSum / successes;
        }

        private double averageRawAstSize() {
            return successes == 0 ? 0.0 : (double) rawAstSizeSum / successes;
        }

        private double averageCanonicalFormSize() {
            return successes == 0 ? 0.0 : (double) canonicalFormSizeSum / successes;
        }

        private double averageNormalizedRawAstDistance() {
            return successes == 0 ? 0.0 : normalizedRawAstDistanceSum / successes;
        }

        private double averageNormalizedCanonicalDistance() {
            return successes == 0 ? 0.0 : normalizedCanonicalDistanceSum / successes;
        }

        private int rewardFailures() {
            return successes - rewardSuccesses;
        }

        private double averageCandidateReward() {
            return rewardSuccesses == 0 ? 0.0 : candidateRewardSum / rewardSuccesses;
        }

        private double averageGroundTruthReward() {
            return rewardSuccesses == 0 ? 0.0 : groundTruthRewardSum / rewardSuccesses;
        }

        private double averageRewardGap() {
            return rewardSuccesses == 0 ? 0.0 : rewardGapSum / rewardSuccesses;
        }

        private double distanceRewardCorrelation() {
            return correlation(
                    distanceRewardSamples,
                    distanceRewardXSum,
                    distanceRewardYSum,
                    distanceRewardXXSum,
                    distanceRewardYYSum,
                    distanceRewardXYSum);
        }

        private double levenshteinRewardCorrelation() {
            return correlation(
                    distanceRewardSamples,
                    levenshteinRewardXSum,
                    distanceRewardYSum,
                    levenshteinRewardXXSum,
                    distanceRewardYYSum,
                    levenshteinRewardXYSum);
        }

        private double rawAstRewardCorrelation() {
            return correlation(
                    distanceRewardSamples,
                    rawAstRewardXSum,
                    distanceRewardYSum,
                    rawAstRewardXXSum,
                    distanceRewardYYSum,
                    rawAstRewardXYSum);
        }

        private double normalizedRawAstRewardCorrelation() {
            return correlation(
                    distanceRewardSamples,
                    normalizedRawAstRewardXSum,
                    distanceRewardYSum,
                    normalizedRawAstRewardXXSum,
                    distanceRewardYYSum,
                    normalizedRawAstRewardXYSum);
        }

        private double normalizedCanonicalRewardCorrelation() {
            return correlation(
                    distanceRewardSamples,
                    normalizedCanonicalRewardXSum,
                    distanceRewardYSum,
                    normalizedCanonicalRewardXXSum,
                    distanceRewardYYSum,
                    normalizedCanonicalRewardXYSum);
        }

        private String minDistanceJson() {
            return minDistance == null ? "null" : minDistance.toString();
        }

        private String maxDistanceJson() {
            return maxDistance == null ? "null" : maxDistance.toString();
        }

        private String minDistanceMarkdown() {
            return minDistance == null ? "n/a" : minDistance.toString();
        }

        private String maxDistanceMarkdown() {
            return maxDistance == null ? "n/a" : maxDistance.toString();
        }
    }

    private static class Stats {
        private final String problemClass;
        private final String statusFolder;
        private int total;
        private int successes;
        private int skipped;
        private int failures;
        private long distanceSum;
        private Integer minDistance;
        private Integer maxDistance;
        private int rewardSuccesses;
        private double candidateRewardSum;
        private int distanceRewardSamples;
        private double distanceRewardXSum;
        private double distanceRewardYSum;
        private double distanceRewardXXSum;
        private double distanceRewardYYSum;
        private double distanceRewardXYSum;

        private Stats(String problemClass, String statusFolder) {
            this.problemClass = problemClass;
            this.statusFolder = statusFolder;
        }

        private void add(FileResult result) {
            total++;
            if (result.skipped) {
                skipped++;
            } else if (result.success()) {
                successes++;
                distanceSum += result.distance;
                minDistance = minDistance == null ? result.distance : Math.min(minDistance, result.distance);
                maxDistance = maxDistance == null ? result.distance : Math.max(maxDistance, result.distance);
                if (result.rewardError == null) {
                    rewardSuccesses++;
                    candidateRewardSum += result.candidateReward;
                    if (isCorrelationEligible(result)) {
                        distanceRewardSamples++;
                        distanceRewardXSum += result.distance;
                        distanceRewardYSum += result.candidateReward;
                        distanceRewardXXSum += (double) result.distance * result.distance;
                        distanceRewardYYSum += result.candidateReward * result.candidateReward;
                        distanceRewardXYSum += result.distance * result.candidateReward;
                    }
                }
            } else {
                failures++;
            }
        }

        private double averageDistance() {
            return successes == 0 ? 0.0 : (double) distanceSum / successes;
        }

        private double averageCandidateReward() {
            return rewardSuccesses == 0 ? 0.0 : candidateRewardSum / rewardSuccesses;
        }

        private double distanceRewardCorrelation() {
            return correlation(
                    distanceRewardSamples,
                    distanceRewardXSum,
                    distanceRewardYSum,
                    distanceRewardXXSum,
                    distanceRewardYYSum,
                    distanceRewardXYSum);
        }

        private String minDistanceMarkdown() {
            return minDistance == null ? "n/a" : minDistance.toString();
        }

        private String maxDistanceMarkdown() {
            return maxDistance == null ? "n/a" : maxDistance.toString();
        }
    }

    private static boolean isCorrelationEligible(FileResult result) {
        return !"CORRECT".equals(result.statusFolder);
    }

    private static double correlation(int n, double xSum, double ySum, double xxSum, double yySum, double xySum) {
        if (n < 2) {
            return 0.0;
        }
        double numerator = n * xySum - xSum * ySum;
        double xDenominator = n * xxSum - xSum * xSum;
        double yDenominator = n * yySum - ySum * ySum;
        if (xDenominator <= 0.0 || yDenominator <= 0.0) {
            return 0.0;
        }
        return numerator / Math.sqrt(xDenominator * yDenominator);
    }
}
