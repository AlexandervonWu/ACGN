package is.fivefivefive.CanDis;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CompletionService;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorCompletionService;
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
import parser.etc.Pair;
import parser.util.AlloyUtil;

public class Alloy4FunAugmenter {
    private static final String DEFAULT_INPUT = "classified-data";
    private static final String DEFAULT_OUTPUT = "alloy4fun-augmented";
    private static final int DEFAULT_THREAD_COUNT = 32;
    private static final int DEFAULT_REWARD_POOL_SIZE = 10;
    private static final int[] REPAIR_RADII = { 1, 2, 5, 10 };
    private static final double[] RELATIVE_REPAIR_RADII = { 0.05, 0.10, 0.20, 0.50 };
    private static final int RELATIVE_REPAIR_CURVE_STEPS = 100;
    private static final int RAW_EDIT_REPAIR_PLOT_MAX_DISTANCE = 50;
    private static final int RAW_EDIT_REPAIR_PLOT_TICK_COUNT = 5;
    private static final int REPORT_BUFFER_SIZE = 1024 * 1024;

    public static void main(String[] args) throws IOException {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "error");
        Options options = Options.parse(args);
        Files.createDirectories(options.outputDir);
        List<Path> files = alloyFiles(options.inputDir);
        if (options.limit > 0 && options.limit < files.size()) {
            files = new ArrayList<>(files.subList(0, options.limit));
        }

        long stageStarted = beginStage("Parsing " + files.size() + " Alloy models");
        List<ModelRecord> records = parseRecords(files, options);
        endStage("Parsing Alloy models", stageStarted);

        stageStarted = beginStage("Building correct-reference pools");
        Map<String, QuestionGroup> groups = groups(records);
        for (QuestionGroup group : groups.values()) {
            group.buildReferences(options.verbose);
        }
        endStage("Building correct-reference pools", stageStarted);

        stageStarted = beginStage("Writing augmented correct pools");
        writeAugmentedFiles(groups, options.outputDir);
        endStage("Writing augmented correct pools", stageStarted);

        stageStarted = beginStage("Comparing canonically equivalent correct pairs");
        List<CorrectPoolPair> correctPoolPairs =
                correctAstDifferentCanonicalEquivalentPairs(groups, options.threadCount);
        writeCorrectPoolEquivalenceJson(
                options.outputDir.resolve("correct_ast_diff_canonical_equiv.json"),
                options,
                correctPoolPairs);
        endStage("Comparing canonically equivalent correct pairs", stageStarted);
        logRankingWork(groups);

        stageStarted = beginStage("Ranking incorrect predicates");
        List<IncorrectMatch> matches = nearestIncorrectMatches(groups, options);
        endStage("Ranking incorrect predicates", stageStarted);
        if (!options.skipRewards) {
            stageStarted = beginStage("Computing rewards");
            computeRewards(matches, options);
            endStage("Computing rewards", stageStarted);
        }

        stageStarted = beginStage("Writing reports and plots");
        List<ModelRecord> unmatched = incorrectWithoutReference(groups);
        writeJson(options.outputDir.resolve("index.json"), options, files.size(), groups, records, matches, unmatched);
        writeMarkdown(
                options.outputDir.resolve("summary.md"),
                options,
                files.size(),
                groups,
                records,
                matches,
                unmatched,
                correctPoolPairs);
        writeRewardCsv(options.outputDir.resolve("canonical_reward_points.csv"), matches);
        writeRewardPlots(options.outputDir, matches);
        writeRelativeRepairCoveragePlot(options.outputDir.resolve("relative_repair_coverage_comparison.svg"), matches);
        writeRawEditRepairCoveragePlot(options.outputDir.resolve("raw_edit_repair_coverage_ast_canonical.svg"), matches);
        writePlotScript(options.outputDir.resolve("plot_canonical_rewards.py"));
        endStage("Writing reports and plots", stageStarted);
        System.out.println("Wrote " + options.outputDir);
        System.out.println("Wrote " + options.outputDir.resolve("index.json"));
        System.out.println("Wrote " + options.outputDir.resolve("correct_ast_diff_canonical_equiv.json"));
        System.out.println("Wrote " + options.outputDir.resolve("summary.md"));
        System.out.println("Wrote " + options.outputDir.resolve("canonical_reward_points.csv"));
        System.out.println("Wrote " + options.outputDir.resolve("canonical_distance_vs_reward_error_raw.svg"));
        System.out.println("Wrote " + options.outputDir.resolve("canonical_distance_vs_reward_error_log.svg"));
        System.out.println("Wrote " + options.outputDir.resolve("relative_repair_coverage_comparison.svg"));
        System.out.println("Wrote " + options.outputDir.resolve("raw_edit_repair_coverage_ast_canonical.svg"));
        System.out.println("Wrote " + options.outputDir.resolve("plot_canonical_rewards.py"));
    }

    private static long beginStage(String label) {
        System.err.println("[Alloy4FunAugmenter] " + label + "...");
        return System.nanoTime();
    }

    private static void endStage(String label, long started) {
        double seconds = (System.nanoTime() - started) / 1_000_000_000.0;
        System.err.println("[Alloy4FunAugmenter] " + label + " completed in "
                + String.format(java.util.Locale.ROOT, "%.3f", seconds) + " s");
    }

    private static List<ModelRecord> parseRecords(List<Path> files, Options options) {
        PrintStream originalOut = System.out;
        PrintStream originalErr = System.err;
        ConcurrentMap<String, RawAstTree> astCache = new ConcurrentHashMap<>();
        ConcurrentMap<RepresentationKey, Canonical.Prepared> canonicalCache = new ConcurrentHashMap<>();
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
            List<Future<ModelRecord>> futures = new ArrayList<>(files.size());
            for (Path file : files) {
                futures.add(executor.submit(
                        () -> parseRecord(options.inputDir, file, options.verbose, astCache, canonicalCache)));
            }
            List<ModelRecord> records = new ArrayList<>(files.size());
            for (int i = 0; i < futures.size(); i++) {
                try {
                    records.add(futures.get(i).get());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    records.add(ModelRecord.failed(options.inputDir, files.get(i), "InterruptedException: " + e.getMessage()));
                } catch (ExecutionException e) {
                    Throwable cause = e.getCause() == null ? e : e.getCause();
                    records.add(ModelRecord.failed(options.inputDir, files.get(i),
                            cause.getClass().getSimpleName() + ": " + cause.getMessage()));
                }
            }
            List<Integer> failedIndexes = new ArrayList<>();
            List<Future<ModelRecord>> retries = new ArrayList<>();
            for (int i = 0; i < records.size(); i++) {
                if (!records.get(i).success()) {
                    final int failedIndex = i;
                    failedIndexes.add(failedIndex);
                    retries.add(executor.submit(
                            () -> parseRecord(
                                    options.inputDir,
                                    files.get(failedIndex),
                                    options.verbose,
                                    astCache,
                                    canonicalCache)));
                }
            }
            if (!retries.isEmpty()) {
                originalErr.println("[Alloy4FunAugmenter] Retrying " + retries.size()
                        + " parse failures in parallel...");
            }
            for (int i = 0; i < retries.size(); i++) {
                try {
                    ModelRecord retry = retries.get(i).get();
                    if (retry.success()) {
                        records.set(failedIndexes.get(i), retry);
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (ExecutionException ignored) {
                }
            }
            astCache.clear();
            canonicalCache.clear();
            return records;
        } finally {
            executor.shutdownNow();
            if (!options.verbose) {
                System.setOut(originalOut);
                System.setErr(originalErr);
            }
        }
    }

    private static ModelRecord parseRecord(
            Path inputRoot,
            Path file,
            boolean verbose,
            ConcurrentMap<String, RawAstTree> astCache,
            ConcurrentMap<RepresentationKey, Canonical.Prepared> canonicalCache) {
        ModelRecord record = new ModelRecord(inputRoot, file);
        try {
            CompModule module = AlloyUtil.compileAlloyModule(file.toString());
            ModelUnit model = new ModelUnit(null, module);
            PredicatePair pair = findPredicatePair(file, model);
            if (pair == null) {
                record.error = "No predicate pair of the form X and X[Cc] found.";
                return record;
            }
            record.leftPredicate = pair.leftName;
            record.rightPredicate = pair.rightName;
            record.studentBody = predicateBody(file, pair.leftName, pair.left);
            record.oracleBody = predicateBody(file, pair.rightName, pair.right);
            record.levenshteinSize = record.studentBody.length();
            record.prelude = preludeBeforePredicate(Files.readString(file, StandardCharsets.UTF_8), pair.leftName);
            record.studentAst = internAst(RawAstTree.from(pair.left.getBody()), astCache);
            record.oracleAst = internAst(RawAstTree.from(pair.right.getBody()), astCache);
            record.rawAstSize = record.studentAst.size;

            if (!"CORRECT".equals(record.statusFolder)) {
                return record;
            }
            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);
            DoubleMap<Integer, Multigraph> forest = visitor.getForest();
            Multigraph studentGraph = forest.get(pair.leftId);
            Multigraph oracleGraph = forest.get(pair.rightId);
            if (studentGraph == null || oracleGraph == null) {
                record.error = "Could not find both predicate graphs in MASG forest.";
            } else {
                record.studentCanonical = canonicalCache.computeIfAbsent(
                        RepresentationKey.student(record),
                        key -> Canonical.prepare(studentGraph));
                record.oracleCanonical = canonicalCache.computeIfAbsent(
                        RepresentationKey.oracle(record),
                        key -> Canonical.prepare(oracleGraph));
                record.canonicalSize = Canonical.canonicalFormSize(record.studentCanonical);
            }
        } catch (Throwable t) {
            if (verbose) {
                t.printStackTrace(System.err);
            }
            record.error = t.getClass().getSimpleName() + ": " + t.getMessage();
        }
        return record;
    }

    private static Canonical.Prepared loadCanonical(ModelRecord record, boolean oracle) {
        try {
            CompModule module = AlloyUtil.compileAlloyModule(record.file.toString());
            ModelUnit model = new ModelUnit(null, module);
            PredicatePair pair = findPredicatePair(record.file, model);
            if (pair == null) {
                throw new IllegalStateException("No predicate pair of the form X and X[Cc] found.");
            }
            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);
            Multigraph graph = visitor.getForest().get(oracle ? pair.rightId : pair.leftId);
            if (graph == null) {
                throw new IllegalStateException("Could not find predicate graph in MASG forest.");
            }
            return Canonical.prepare(graph);
        } catch (RuntimeException e) {
            throw e;
        } catch (Throwable t) {
            throw new IllegalStateException(
                    "Could not prepare " + (oracle ? "oracle" : "student") + " canonical form for "
                            + record.relativePath,
                    t);
        }
    }

    private static Canonical.Prepared loadCanonicalQuietly(ModelRecord record, boolean oracle, boolean verbose) {
        if (verbose) {
            return loadCanonical(record, oracle);
        }
        PrintStream originalOut = System.out;
        PrintStream originalErr = System.err;
        PrintStream sink = new PrintStream(new OutputStream() {
            @Override
            public void write(int b) {
            }
        });
        System.setOut(sink);
        System.setErr(sink);
        try {
            return loadCanonical(record, oracle);
        } finally {
            System.setOut(originalOut);
            System.setErr(originalErr);
            sink.close();
        }
    }

    private static RawAstTree internAst(RawAstTree ast, ConcurrentMap<String, RawAstTree> cache) {
        RawAstTree existing = cache.putIfAbsent(ast.fingerprint, ast);
        return existing == null ? ast : existing;
    }

    private static Map<String, QuestionGroup> groups(List<ModelRecord> records) {
        Map<String, QuestionGroup> groups = new java.util.TreeMap<>();
        for (ModelRecord record : records) {
            QuestionGroup group = groups.computeIfAbsent(record.groupKey(), key -> new QuestionGroup(record.questionSet, record.invariantId));
            group.records.add(record);
            if (record.success() && "CORRECT".equals(record.statusFolder)) {
                group.correct.add(record);
            } else if (record.success()) {
                group.incorrect.add(record);
            } else {
                group.failures.add(record);
            }
        }
        return groups;
    }

    private static List<IncorrectMatch> nearestIncorrectMatches(Map<String, QuestionGroup> groups, Options options) {
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
            CompletionService<RankingBatch> completion = new ExecutorCompletionService<>(executor);
            int taskCount = 0;
            for (QuestionGroup group : groups.values()) {
                if (group.rankingReferences().isEmpty()) {
                    continue;
                }
                Map<RepresentationKey, List<ModelRecord>> duplicates = new LinkedHashMap<>();
                for (ModelRecord record : group.incorrect) {
                    duplicates.computeIfAbsent(RepresentationKey.student(record), key -> new ArrayList<>())
                            .add(record);
                }
                for (List<ModelRecord> equivalentRecords : duplicates.values()) {
                    ModelRecord representative = equivalentRecords.get(0);
                    completion.submit(() -> new RankingBatch(
                            equivalentRecords,
                            nearestIncorrectMatch(group, representative)));
                    taskCount++;
                }
            }
            List<IncorrectMatch> matches = new ArrayList<>();
            for (int i = 0; i < taskCount; i++) {
                try {
                    RankingBatch batch = completion.take().get();
                    IncorrectMatch template = batch.template;
                    for (ModelRecord record : batch.records) {
                        record.canonicalSize = template.record.canonicalSize;
                        matches.add(record == template.record
                                ? template
                                : new IncorrectMatch(record, template));
                        releaseRankingRepresentation(record);
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (ExecutionException ignored) {
                }
            }
            matches.sort(Comparator.comparing((IncorrectMatch match) -> match.record.relativePath));
            return matches;
        } finally {
            executor.shutdownNow();
            if (!options.verbose) {
                System.setOut(originalOut);
                System.setErr(originalErr);
            }
        }
    }

    private static void releaseRankingRepresentation(ModelRecord record) {
        record.studentAst = null;
        record.studentCanonical = null;
        record.studentBody = null;
        record.prelude = null;
    }

    private static void logRankingWork(Map<String, QuestionGroup> groups) {
        long comparisons = 0;
        long deduplicatedComparisons = 0;
        int incorrect = 0;
        int uniqueIncorrectRepresentations = 0;
        for (QuestionGroup group : groups.values()) {
            int referenceCount = group.rankingReferences().size();
            incorrect += group.incorrect.size();
            comparisons += (long) group.incorrect.size() * referenceCount;
            Set<RepresentationKey> representations = new HashSet<>();
            for (ModelRecord record : group.incorrect) {
                representations.add(RepresentationKey.student(record));
            }
            uniqueIncorrectRepresentations += representations.size();
            deduplicatedComparisons += (long) representations.size() * referenceCount;
        }
        System.err.println("[Alloy4FunAugmenter] Ranking workload: " + incorrect
                + " incorrect predicates, " + uniqueIncorrectRepresentations
                + " unique representations, " + comparisons + " logical comparisons, "
                + deduplicatedComparisons + " computed comparisons.");
    }

    private static List<ModelRecord> incorrectWithoutReference(Map<String, QuestionGroup> groups) {
        List<ModelRecord> unmatched = new ArrayList<>();
        for (QuestionGroup group : groups.values()) {
            if (group.rankingReferences().isEmpty()) {
                unmatched.addAll(group.incorrect);
            }
        }
        unmatched.sort(Comparator.comparing(record -> record.relativePath));
        return unmatched;
    }

    private static IncorrectMatch nearestIncorrectMatch(QuestionGroup group, ModelRecord incorrect) {
        if (incorrect.studentCanonical == null) {
            incorrect.studentCanonical = loadCanonical(incorrect, false);
            incorrect.canonicalSize = Canonical.canonicalFormSize(incorrect.studentCanonical);
        }
        IncorrectMatch match = new IncorrectMatch(incorrect);
        for (Reference reference : group.rankingReferences()) {
            int levenshtein = levenshteinDistance(incorrect.studentBody, reference.body);
            int rawAst = rawAstTreeDistance(incorrect.studentAst, reference.ast);
            int canonical = Canonical.distance(incorrect.studentCanonical, reference.canonical);
            match.levenshtein.add(reference, levenshtein);
            match.rawAst.add(reference, rawAst);
            match.canonical.add(reference, canonical);
        }
        match.sortRankings();
        return match;
    }

    private static void computeRewards(List<IncorrectMatch> matches, Options options) {
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
            List<Future<?>> futures = new ArrayList<>(matches.size());
            for (IncorrectMatch match : matches) {
                futures.add(executor.submit(() -> computeReward(match, options.rewardPoolSize)));
            }
            for (Future<?> future : futures) {
                try {
                    future.get();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    return;
                } catch (ExecutionException ignored) {
                }
            }
        } finally {
            executor.shutdownNow();
            if (!options.verbose) {
                System.setOut(originalOut);
                System.setErr(originalErr);
            }
        }
    }

    private static void computeReward(IncorrectMatch match, int poolSize) {
        ModelRecord record = match.record;
        match.rewardPoolSize = poolSize;
        match.rewardComputed = true;
        try {
            CompModule module = AlloyUtil.compileAlloyModule(record.file.toString());
            Pair<InstancePool, InstancePool> instances = Rewarder.instances(module, record.rightPredicate, poolSize);
            match.candidateReward = Rewarder.computeReward(
                    module,
                    instances,
                    record.rightPredicate,
                    record.leftPredicate,
                    record.leftPredicate,
                    poolSize);
            match.rewardError = Math.max(0.0, 1.0 - match.candidateReward);
        } catch (Throwable t) {
            match.rewardErrorMessage = t.getClass().getSimpleName() + ": " + t.getMessage();
        }
    }

    private static void writeAugmentedFiles(Map<String, QuestionGroup> groups, Path outputDir) throws IOException {
        Path correctRoot = outputDir.resolve("correct");
        for (QuestionGroup group : groups.values()) {
            if (group.references.isEmpty()) {
                continue;
            }
            Files.createDirectories(correctRoot.resolve(group.questionSet));
            Path file = correctRoot.resolve(group.questionSet).resolve(group.invariantId + ".als");
            try (Writer writer = outputWriter(file)) {
                writer.write("module alloy4fun_augmented_" + sanitize(group.questionSet) + "_" + sanitize(group.invariantId) + "\n");
                String prelude = group.prelude();
                int line = prelude.indexOf('\n');
                if (line >= 0) {
                    writer.write(prelude.substring(line + 1).trim());
                    writer.write("\n\n");
                }
                for (Reference reference : group.references) {
                    writer.write("pred " + reference.augmentedName + "[] {\n");
                    writer.write(reference.body.trim());
                    writer.write("\n}\n\n");
                }
            }
        }
    }

    private static void writeCorrectPoolEquivalenceJson(
            Path path,
            Options options,
            List<CorrectPoolPair> pairs) throws IOException {
        try (Writer writer = outputWriter(path)) {
            writer.write("{\n");
            writer.write("  \"generatedAt\": \"" + escape(Instant.now().toString()) + "\",\n");
            writer.write("  \"inputRoot\": \"" + escape(options.inputDir.toString()) + "\",\n");
            writer.write("  \"outputRoot\": \"" + escape(options.outputDir.toString()) + "\",\n");
            writer.write("  \"criterion\": \"Pairs within each augmented correct pool whose raw AST distance is greater than zero and canonical distance is zero.\",\n");
            writer.write("  \"pairCount\": " + pairs.size() + ",\n");
            writer.write("  \"pairs\": [\n");
            for (int i = 0; i < pairs.size(); i++) {
                if (i > 0) {
                    writer.write(",\n");
                }
                writeCorrectPoolPairJson(writer, pairs.get(i));
            }
            writer.write("\n  ]\n");
            writer.write("}\n");
        }
    }

    private static List<CorrectPoolPair> correctAstDifferentCanonicalEquivalentPairs(
            Map<String, QuestionGroup> groups,
            int threadCount) {
        ExecutorService executor = Executors.newFixedThreadPool(Math.max(1, threadCount));
        try {
            List<Future<List<CorrectPoolPair>>> futures = new ArrayList<>();
            for (QuestionGroup group : groups.values()) {
                List<Reference> references = group.references;
                for (int i = 0; i < references.size(); i++) {
                    final int leftIndex = i;
                    futures.add(executor.submit(() -> correctPoolPairsForLeft(group, references, leftIndex)));
                }
            }
            List<CorrectPoolPair> pairs = new ArrayList<>();
            for (Future<List<CorrectPoolPair>> future : futures) {
                try {
                    pairs.addAll(future.get());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    break;
                } catch (ExecutionException ignored) {
                }
            }
            pairs.sort(Comparator
                    .comparing((CorrectPoolPair pair) -> pair.group.questionSet)
                    .thenComparing(pair -> pair.group.invariantId)
                    .thenComparing(pair -> pair.left.augmentedName)
                    .thenComparing(pair -> pair.right.augmentedName));
            return pairs;
        } finally {
            executor.shutdownNow();
        }
    }

    private static List<CorrectPoolPair> correctPoolPairsForLeft(
            QuestionGroup group,
            List<Reference> references,
            int leftIndex) {
        List<CorrectPoolPair> pairs = new ArrayList<>();
        Reference left = references.get(leftIndex);
        for (int j = leftIndex + 1; j < references.size(); j++) {
            Reference right = references.get(j);
            if (left.ast.fingerprint.equals(right.ast.fingerprint)) {
                continue;
            }
            if (left.canonicalSize != right.canonicalSize) {
                continue;
            }
            int rawAstDistance = rawAstTreeDistance(left.ast, right.ast);
            int canonicalDistance = Canonical.distance(left.canonical, right.canonical);
            if (canonicalDistance == 0) {
                pairs.add(new CorrectPoolPair(group, left, right, rawAstDistance, canonicalDistance));
            }
        }
        return pairs;
    }

    private static void writeCorrectPoolPairJson(Writer writer, CorrectPoolPair pair) throws IOException {
        writer.write("    {\n");
        writer.write("      \"questionSet\": \"" + escape(pair.group.questionSet) + "\",\n");
        writer.write("      \"invariantId\": \"" + escape(pair.group.invariantId) + "\",\n");
        writer.write("      \"augmentedFile\": \"" + escape("correct/" + pair.group.questionSet + "/" + pair.group.invariantId + ".als") + "\",\n");
        writer.write("      \"rawAstDistance\": " + pair.rawAstDistance + ",\n");
        writer.write("      \"canonicalDistance\": " + pair.canonicalDistance + ",\n");
        writer.write("      \"left\": ");
        writeReferenceJson(writer, pair.left);
        writer.write(",\n");
        writer.write("      \"right\": ");
        writeReferenceJson(writer, pair.right);
        writer.write("\n");
        writer.write("    }");
    }

    private static void writeReferenceJson(Writer writer, Reference reference) throws IOException {
        writer.write("{\"name\": \"" + escape(reference.augmentedName)
                + "\", \"kind\": \"" + escape(reference.kind)
                + "\", \"source\": \"" + escape(reference.source.relativePath)
                + "\", \"body\": \"" + escape(reference.body.trim()) + "\"}");
    }

    private static void writeJson(
            Path path,
            Options options,
            int fileCount,
            Map<String, QuestionGroup> groups,
            List<ModelRecord> records,
            List<IncorrectMatch> matches,
            List<ModelRecord> unmatched) throws IOException {
        Summary summary = new Summary(groups, records, matches, unmatched);
        try (Writer writer = outputWriter(path)) {
            writer.write("{\n");
            writer.write("  \"generatedAt\": \"" + escape(Instant.now().toString()) + "\",\n");
            writer.write("  \"inputRoot\": \"" + escape(options.inputDir.toString()) + "\",\n");
            writer.write("  \"outputRoot\": \"" + escape(options.outputDir.toString()) + "\",\n");
            writer.write("  \"sourceFileCount\": " + fileCount + ",\n");
            writer.write("  \"threadCount\": " + options.threadCount + ",\n");
            writer.write("  \"rewardPoolSize\": " + options.rewardPoolSize + ",\n");
            writer.write("  \"summary\": {\n");
            writer.write("    \"groups\": " + summary.groups + ",\n");
            writer.write("    \"parsedModels\": " + summary.parsedModels + ",\n");
            writer.write("    \"parseFailures\": " + summary.parseFailures + ",\n");
            writer.write("    \"correctModels\": " + summary.correctModels + ",\n");
            writer.write("    \"incorrectModels\": " + summary.incorrectModels + ",\n");
            writer.write("    \"oracleReferences\": " + summary.oracleReferences + ",\n");
            writer.write("    \"uniqueCorrectStudentReferences\": " + summary.uniqueCorrectStudentReferences + ",\n");
            writer.write("    \"incorrectModelsWithNearestDistances\": " + matches.size() + ",\n");
            writer.write("    \"rewardSuccesses\": " + summary.rewardSuccesses + ",\n");
            writer.write("    \"rewardFailures\": " + summary.rewardFailures + ",\n");
            writer.write("    \"averageCandidateReward\": " + number(summary.averageCandidateReward()) + ",\n");
            writer.write("    \"averageRewardError\": " + number(summary.averageRewardError()) + ",\n");
            writer.write("    \"incorrectModelsWithoutCorrectReference\": " + unmatched.size() + "\n");
            writer.write("  },\n");
            writer.write("  \"questions\": [\n");
            int index = 0;
            for (QuestionGroup group : groups.values()) {
                if (index++ > 0) {
                    writer.write(",\n");
                }
                writeGroupJson(writer, group);
            }
            writer.write("\n  ],\n");
            writer.write("  \"incorrectNearest\": [\n");
            for (int i = 0; i < matches.size(); i++) {
                if (i > 0) {
                    writer.write(",\n");
                }
                writeMatchJson(writer, matches.get(i));
            }
            writer.write("\n  ],\n");
            writer.write("  \"incorrectWithoutReference\": [\n");
            for (int i = 0; i < unmatched.size(); i++) {
                if (i > 0) {
                    writer.write(",\n");
                }
                writeUnmatchedJson(writer, unmatched.get(i));
            }
            writer.write("\n  ]\n");
            writer.write("}\n");
        }
    }

    private static void writeMarkdown(
            Path path,
            Options options,
            int fileCount,
            Map<String, QuestionGroup> groups,
            List<ModelRecord> records,
            List<IncorrectMatch> matches,
            List<ModelRecord> unmatched,
            List<CorrectPoolPair> correctPoolPairs) throws IOException {
        Summary summary = new Summary(groups, records, matches, unmatched);
        Map<String, QuestionSetStats> questionStats = questionSetStats(groups, matches);
        Map<String, CorrectTruthStats> correctTruthStats = correctTruthStats(groups, correctPoolPairs);
        Map<String, RankingModeStats> modeStats = rankingModeStats(groups);
        DistanceTableStats distanceTable = distanceTableStats(matches);
        Map<String, RepairRadiusStats> repairOverall = repairRadiusStatsOverall(matches);
        Map<String, RepairRadiusStats> repairByStatus = repairRadiusStatsByStatus(matches);
        Map<String, RepairRadiusStats> repairByQuestionSet = repairRadiusStatsByQuestionSet(matches);
        Map<String, RepairRadiusStats> repairByQuestionSetAndStatus = repairRadiusStatsByQuestionSetAndStatus(matches);

        try (Writer writer = outputWriter(path)) {
            writer.write("# Alloy4Fun Augmented Dataset Summary\n\n");
            writer.write("- Generated at: `" + Instant.now().toString() + "`\n");
            writer.write("- Input root: `" + options.inputDir + "`\n");
            writer.write("- Output root: `" + options.outputDir + "`\n");
            writer.write("- Source Alloy files: " + fileCount + "\n");
            writer.write("- Thread count: " + options.threadCount + "\n\n");
            writer.write("- Reward pool size: " + options.rewardPoolSize + "\n\n");

            writer.write("## Corpus\n\n");
            writer.write("- Question groups: " + summary.groups + "\n");
            writer.write("- Parsed models: " + summary.parsedModels + "\n");
            writer.write("- Parse failures: " + summary.parseFailures + "\n");
            writer.write("- CORRECT models: " + summary.correctModels + "\n");
            writer.write("- Incorrect models: " + summary.incorrectModels + "\n");
            writer.write("- Oracle references: " + summary.oracleReferences + "\n");
            writer.write("- AST-unique CORRECT student references: " + summary.uniqueCorrectStudentReferences + "\n");
            writer.write("- Incorrect models with rankings: " + matches.size() + "\n");
            writer.write("- Incorrect models without references: " + unmatched.size() + "\n\n");
            writer.write("- Reward successes: " + summary.rewardSuccesses + "\n");
            writer.write("- Reward failures: " + summary.rewardFailures + "\n");
            writer.write("- Average candidate reward: " + number(summary.averageCandidateReward()) + "\n");
            writer.write("- Average reward error `(1 - reward)`: " + number(summary.averageRewardError()) + "\n\n");

            writer.write("## Correct Truth Pools\n\n");
            writer.write("Truth predicates include one oracle predicate per invariant together with every CORRECT "
                    + "student predicate. AST deduplication is applied to this combined pool; the final column "
                    + "counts unordered pairs of AST-distinct truths whose canonical distance is zero. Unique "
                    + "canonical forms are connected components under that zero-distance relation.\n\n");
            writer.write("| Problem class | Correct truth predicates | AST-distinct truths | "
                    + "Unique canonical forms | AST-different, canonically equivalent pairs |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: |\n");
            CorrectTruthStats totalTruthStats = new CorrectTruthStats("Total");
            for (CorrectTruthStats stats : correctTruthStats.values()) {
                writer.write("| " + stats.questionSet + " | " + stats.correctPredicates + " | "
                        + stats.astDistinctPredicates + " | " + stats.uniqueCanonicalForms + " | "
                        + stats.canonicalEquivalentPairs + " |\n");
                totalTruthStats.add(stats);
            }
            writer.write("| **Total** | **" + totalTruthStats.correctPredicates + "** | **"
                    + totalTruthStats.astDistinctPredicates + "** | **"
                    + totalTruthStats.uniqueCanonicalForms + "** | **"
                    + totalTruthStats.canonicalEquivalentPairs + "** |\n\n");

            writer.write("## Ranking Pools\n\n");
            writer.write("| Mode | Groups | Incorrect predicates | Min refs | Max refs |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: |\n");
            for (RankingModeStats stats : modeStats.values()) {
                writer.write("| " + stats.mode + " | " + stats.groups + " | " + stats.incorrect + " | "
                        + stats.minRefsMarkdown() + " | " + stats.maxRefsMarkdown() + " |\n");
            }
            writer.write("\n");

            writer.write("## Nearest Correct-Predicate Distance Averages\n\n");
            writer.write("For each incorrect predicate and metric, the distance is the minimum over every "
                    + "AST-distinct correct predicate in the same invariant's truth pool, including the oracle. "
                    + "The three metrics may select different nearest predicates. Relative distances divide by "
                    + "the incorrect predicate's own body length, raw AST size, or canonical-form size. "
                    + "CORRECT predicates are excluded.\n\n");
            writer.write("| Problem class | Incorrectness class | Incorrect predicates | "
                    + "Avg nearest Levenshtein | Avg nearest raw AST | Avg nearest canonical | "
                    + "Avg relative Levenshtein | Avg relative raw AST | Avg relative canonical |\n");
            writer.write("| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |\n");
            DistanceStats allDistances = distanceTable.overall;
            writer.write("| **All problem classes** | **All incorrectness classes** | **"
                    + allDistances.count + "** | **" + number(allDistances.averageLevenshtein())
                    + "** | **" + number(allDistances.averageRawAst())
                    + "** | **" + number(allDistances.averageCanonical())
                    + "** | **" + number(allDistances.averageLevenshteinRatio())
                    + "** | **" + number(allDistances.averageRawAstRatio())
                    + "** | **" + number(allDistances.averageCanonicalRatio()) + "** |\n");
            for (DistanceStats stats : distanceTable.byProblemAndStatus.values()) {
                writer.write("| " + stats.problemClass + " | " + stats.statusFolder + " | "
                        + stats.count + " | " + number(stats.averageLevenshtein()) + " | "
                        + number(stats.averageRawAst()) + " | " + number(stats.averageCanonical()) + " | "
                        + number(stats.averageLevenshteinRatio()) + " | "
                        + number(stats.averageRawAstRatio()) + " | "
                        + number(stats.averageCanonicalRatio()) + " |\n");
            }
            writer.write("\n");

            writer.write("## Relative Repair Coverage Comparison\n\n");
            writer.write("The SVG plots smooth empirical coverage curves from 0% to 100% of each metric's representation size. The table gives selected checkpoints.\n\n");
            writer.write("| Fraction of representation size | Levenshtein / body chars | Raw AST / AST size | Canonical / canonical size |\n");
            writer.write("| --- | ---: | ---: | ---: |\n");
            RepairRadiusStats allRepairCoverage = repairOverall.get("All incorrect");
            if (allRepairCoverage != null) {
                for (int i = 0; i < RELATIVE_REPAIR_RADII.length; i++) {
                    writer.write("| <= " + percentLabel(RELATIVE_REPAIR_RADII[i]) + " | "
                            + countPercent(allRepairCoverage.levenshteinRelativeWithin[i], allRepairCoverage.count)
                            + " | " + countPercent(allRepairCoverage.rawAstRelativeWithin[i], allRepairCoverage.count)
                            + " | " + countPercent(allRepairCoverage.canonicalRelativeWithin[i], allRepairCoverage.count)
                            + " |\n");
                }
            }
            writer.write("\n");
            writer.write("- Plot: `relative_repair_coverage_comparison.svg`\n\n");

            writer.write("## Raw Edit Distance Coverage Comparison\n\n");
            writer.write("The SVG plots empirical coverage curves over absolute edit-distance radius for Raw AST "
                    + "and Canonical repairs. Its x-axis is capped at " + RAW_EDIT_REPAIR_PLOT_MAX_DISTANCE
                    + " edits; predicates beyond that radius remain in the coverage denominator.\n\n");
            writer.write("| Edit-distance radius | Raw AST | Canonical |\n");
            writer.write("| --- | ---: | ---: |\n");
            if (allRepairCoverage != null) {
                for (int i = 0; i < REPAIR_RADII.length; i++) {
                    writer.write("| <= " + REPAIR_RADII[i] + " | "
                            + countPercent(allRepairCoverage.rawAstWithin[i], allRepairCoverage.count)
                            + " | " + countPercent(allRepairCoverage.canonicalWithin[i], allRepairCoverage.count)
                            + " |\n");
                }
            }
            writer.write("\n");
            writer.write("- Plot: `raw_edit_repair_coverage_ast_canonical.svg`\n\n");

            writer.write("## Repair Radius Coverage\n\n");
            writer.write("Counts show incorrect predicates whose nearest CORRECT reference is within the inclusive repair radius.\n\n");
            writer.write("Absolute radii use edit-distance units. Relative radii use distance divided by the incorrect predicate's own representation size.\n\n");
            writeRepairRadiusTable(writer, "Overall", repairOverall);
            writeRepairRadiusTable(writer, "By Incorrectness Status", repairByStatus);
            writeRepairRadiusTable(writer, "By Question Set", repairByQuestionSet);
            writeRepairRadiusTable(writer, "By Question Set and Status", repairByQuestionSetAndStatus);
            writeRelativeRepairRadiusTable(writer, "Overall Relative", repairOverall);
            writeRelativeRepairRadiusTable(writer, "Relative by Incorrectness Status", repairByStatus);
            writeRelativeRepairRadiusTable(writer, "Relative by Question Set", repairByQuestionSet);
            writeRelativeRepairRadiusTable(writer, "Relative by Question Set and Status", repairByQuestionSetAndStatus);

            writer.write("## Reward Error Correlations\n\n");
            RewardDistanceStats levenshteinReward = rewardDistanceStats(matches, "levenshtein");
            RewardDistanceStats rawAstReward = rewardDistanceStats(matches, "rawAst");
            RewardDistanceStats canonicalReward = rewardDistanceStats(matches, "canonical");
            RewardDistanceStats levenshteinRatioReward = rewardRatioStats(matches, "levenshtein");
            RewardDistanceStats rawAstRatioReward = rewardRatioStats(matches, "rawAst");
            RewardDistanceStats canonicalRatioReward = rewardRatioStats(matches, "canonical");
            writer.write("- Rewarded incorrect predicates: " + canonicalReward.count + "\n\n");
            writer.write("| Metric | Pearson distance vs raw `1 - reward` | Pearson distance vs `log10(1 - reward)` | Pearson relative distance vs raw `1 - reward` | Pearson relative distance vs `log10(1 - reward)` |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: |\n");
            writer.write("| Levenshtein | " + number(levenshteinReward.rawCorrelation()) + " | "
                    + number(levenshteinReward.logCorrelation()) + " | "
                    + number(levenshteinRatioReward.rawCorrelation()) + " | "
                    + number(levenshteinRatioReward.logCorrelation()) + " |\n");
            writer.write("| Raw AST | " + number(rawAstReward.rawCorrelation()) + " | "
                    + number(rawAstReward.logCorrelation()) + " | "
                    + number(rawAstRatioReward.rawCorrelation()) + " | "
                    + number(rawAstRatioReward.logCorrelation()) + " |\n");
            writer.write("| Canonical | " + number(canonicalReward.rawCorrelation()) + " | "
                    + number(canonicalReward.logCorrelation()) + " | "
                    + number(canonicalRatioReward.rawCorrelation()) + " | "
                    + number(canonicalRatioReward.logCorrelation()) + " |\n\n");
            writer.write("- Raw plot: `canonical_distance_vs_reward_error_raw.svg`\n");
            writer.write("- Log plot: `canonical_distance_vs_reward_error_log.svg`\n");
            writer.write("- CSV: `canonical_reward_points.csv`\n\n");

            writer.write("## By Question Set\n\n");
            writer.write("| Question set | Groups | CORRECT | Incorrect | References | Ranked incorrect | Oracle-only groups |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: | ---: | ---: |\n");
            for (QuestionSetStats stats : questionStats.values()) {
                writer.write("| " + stats.questionSet + " | " + stats.groups + " | " + stats.correct + " | "
                        + stats.incorrect + " | " + stats.references + " | " + stats.rankedIncorrect
                        + " | " + stats.oracleOnlyGroups + " |\n");
            }
        }
    }

    private static void writeRepairRadiusTable(
            Writer writer,
            String title,
            Map<String, RepairRadiusStats> stats) throws IOException {
        writer.write("### " + title + "\n\n");
        writer.write("| Slice | Count");
        for (int radius : REPAIR_RADII) {
            writer.write(" | AST <= " + radius);
        }
        for (int radius : REPAIR_RADII) {
            writer.write(" | Canonical <= " + radius);
        }
        writer.write(" |\n");
        writer.write("| --- | ---:");
        for (int ignored : REPAIR_RADII) {
            writer.write(" | ---:");
        }
        for (int ignored : REPAIR_RADII) {
            writer.write(" | ---:");
        }
        writer.write(" |\n");
        for (RepairRadiusStats row : stats.values()) {
            writer.write("| " + row.label + " | " + row.count);
            for (int i = 0; i < REPAIR_RADII.length; i++) {
                writer.write(" | " + countPercent(row.rawAstWithin[i], row.count));
            }
            for (int i = 0; i < REPAIR_RADII.length; i++) {
                writer.write(" | " + countPercent(row.canonicalWithin[i], row.count));
            }
            writer.write(" |\n");
        }
        writer.write("\n");
    }

    private static void writeRelativeRepairRadiusTable(
            Writer writer,
            String title,
            Map<String, RepairRadiusStats> stats) throws IOException {
        writer.write("### " + title + "\n\n");
        writer.write("| Slice | Count");
        for (double radius : RELATIVE_REPAIR_RADII) {
            writer.write(" | Levenshtein <= " + percentLabel(radius));
        }
        for (double radius : RELATIVE_REPAIR_RADII) {
            writer.write(" | AST <= " + percentLabel(radius));
        }
        for (double radius : RELATIVE_REPAIR_RADII) {
            writer.write(" | Canonical <= " + percentLabel(radius));
        }
        writer.write(" |\n");
        writer.write("| --- | ---:");
        for (double ignored : RELATIVE_REPAIR_RADII) {
            writer.write(" | ---:");
        }
        for (double ignored : RELATIVE_REPAIR_RADII) {
            writer.write(" | ---:");
        }
        for (double ignored : RELATIVE_REPAIR_RADII) {
            writer.write(" | ---:");
        }
        writer.write(" |\n");
        for (RepairRadiusStats row : stats.values()) {
            writer.write("| " + row.label + " | " + row.count);
            for (int i = 0; i < RELATIVE_REPAIR_RADII.length; i++) {
                writer.write(" | " + countPercent(row.levenshteinRelativeWithin[i], row.count));
            }
            for (int i = 0; i < RELATIVE_REPAIR_RADII.length; i++) {
                writer.write(" | " + countPercent(row.rawAstRelativeWithin[i], row.count));
            }
            for (int i = 0; i < RELATIVE_REPAIR_RADII.length; i++) {
                writer.write(" | " + countPercent(row.canonicalRelativeWithin[i], row.count));
            }
            writer.write(" |\n");
        }
        writer.write("\n");
    }

    private static void writeGroupJson(Writer writer, QuestionGroup group) throws IOException {
        writer.write("    {\n");
        writer.write("      \"questionSet\": \"" + escape(group.questionSet) + "\",\n");
        writer.write("      \"invariantId\": \"" + escape(group.invariantId) + "\",\n");
        writer.write("      \"augmentedFile\": \"" + escape("correct/" + group.questionSet + "/" + group.invariantId + ".als") + "\",\n");
        writer.write("      \"correctCount\": " + group.correct.size() + ",\n");
        writer.write("      \"incorrectCount\": " + group.incorrect.size() + ",\n");
        writer.write("      \"parseFailureCount\": " + group.failures.size() + ",\n");
        writer.write("      \"truthCandidateCount\": " + group.truthCandidateCount + ",\n");
        writer.write("      \"astDistinctTruthCount\": " + group.references.size() + ",\n");
        writer.write("      \"astDuplicateTruthCount\": " + group.astDuplicateTruthCount + ",\n");
        writer.write("      \"referenceCount\": " + group.references.size() + ",\n");
        writer.write("      \"rankingMode\": \"" + escape(group.rankingMode()) + "\",\n");
        writer.write("      \"rankingReferenceCount\": " + group.rankingReferences().size() + ",\n");
        writer.write("      \"references\": [");
        for (int i = 0; i < group.references.size(); i++) {
            Reference reference = group.references.get(i);
            if (i > 0) {
                writer.write(", ");
            }
            writer.write("{\"name\": \"" + escape(reference.augmentedName) + "\", \"kind\": \""
                    + escape(reference.kind) + "\", \"source\": \"" + escape(reference.source.relativePath) + "\"}");
        }
        writer.write("]\n");
        writer.write("    }");
    }

    private static void writeRewardCsv(Path path, List<IncorrectMatch> matches) throws IOException {
        try (Writer writer = outputWriter(path)) {
            writer.write("relativePath,questionSet,statusFolder,invariantId,levenshteinDistance,rawAstDistance,canonicalDistance,levenshteinSize,rawAstSize,canonicalSize,levenshteinDistanceRatio,rawAstDistanceRatio,canonicalDistanceRatio,candidateReward,rewardError,rewardPoolSize,rewardErrorMessage\n");
            for (IncorrectMatch match : matches) {
                writer.write(csv(match.record.relativePath) + ",");
                writer.write(csv(match.record.questionSet) + ",");
                writer.write(csv(match.record.statusFolder) + ",");
                writer.write(csv(match.record.invariantId) + ",");
                writer.write(match.levenshtein.first().distance + ",");
                writer.write(match.rawAst.first().distance + ",");
                writer.write(match.canonical.first().distance + ",");
                writer.write(match.record.levenshteinSize + ",");
                writer.write(match.record.rawAstSize + ",");
                writer.write(match.record.canonicalSize + ",");
                writer.write(number(ratio(match.levenshtein.first().distance, match.record.levenshteinSize)) + ",");
                writer.write(number(ratio(match.rawAst.first().distance, match.record.rawAstSize)) + ",");
                writer.write(number(ratio(match.canonical.first().distance, match.record.canonicalSize)) + ",");
                if (match.rewardComputed && match.rewardErrorMessage == null) {
                    writer.write(number(match.candidateReward) + ",");
                    writer.write(number(match.rewardError) + ",");
                } else {
                    writer.write(",,");
                }
                writer.write(match.rewardPoolSize + ",");
                writer.write(csv(match.rewardComputed ? match.rewardErrorMessage : "Reward computation skipped."));
                writer.write("\n");
            }
        }
    }

    private static void writeRewardPlots(Path outputDir, List<IncorrectMatch> matches) throws IOException {
        List<IncorrectMatch> rewarded = new ArrayList<>();
        for (IncorrectMatch match : matches) {
            if (match.rewardComputed && match.rewardErrorMessage == null) {
                rewarded.add(match);
            }
        }
        if (rewarded.isEmpty()) {
            return;
        }
        writeRewardPlot(
                outputDir.resolve("canonical_distance_vs_reward_error_raw.svg"),
                rewarded,
                false,
                "Canonical distance vs reward error");
        writeRewardPlot(
                outputDir.resolve("canonical_distance_vs_reward_error_log.svg"),
                rewarded,
                true,
                "Canonical distance vs log reward error");
    }

    private static void writeRewardPlot(
            Path path,
            List<IncorrectMatch> matches,
            boolean logScale,
            String title) throws IOException {
        int width = 1000;
        int height = 620;
        int left = 80;
        int right = 30;
        int top = 58;
        int bottom = 76;
        int plotWidth = width - left - right;
        int plotHeight = height - top - bottom;
        double xMax = 1.0;
        double yMax = 1.0;
        double yMin = logScale ? rewardErrorFloor(matches) : 0.0;
        for (IncorrectMatch match : matches) {
            xMax = Math.max(xMax, match.canonical.first().distance);
            yMax = Math.max(yMax, yValue(match, logScale, yMin));
        }
        double yPlotMin = logScale ? Math.floor(Math.log10(yMin)) : 0.0;
        double yPlotMax = logScale ? Math.ceil(Math.log10(yMax)) : Math.max(1.0, yMax);
        if (yPlotMin == yPlotMax) {
            yPlotMax += 1.0;
        }
        try (Writer writer = outputWriter(path)) {
            writer.write("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + width + "\" height=\"" + height
                    + "\" viewBox=\"0 0 " + width + " " + height + "\">\n");
            writer.write("<rect width=\"100%\" height=\"100%\" fill=\"white\"/>\n");
            writer.write("<text x=\"" + (width / 2) + "\" y=\"32\" text-anchor=\"middle\" "
                    + "font-family=\"sans-serif\" font-size=\"20\">" + escapeXml(title) + "</text>\n");
            writer.write("<line x1=\"" + left + "\" y1=\"" + (top + plotHeight) + "\" x2=\""
                    + (left + plotWidth) + "\" y2=\"" + (top + plotHeight)
                    + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
            writer.write("<line x1=\"" + left + "\" y1=\"" + top + "\" x2=\"" + left + "\" y2=\""
                    + (top + plotHeight) + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
            for (int tick = 0; tick <= 5; tick++) {
                double xValue = xMax * tick / 5.0;
                double x = left + xValue * plotWidth / xMax;
                writer.write("<line x1=\"" + number(x) + "\" y1=\"" + (top + plotHeight)
                        + "\" x2=\"" + number(x) + "\" y2=\"" + (top + plotHeight + 5)
                        + "\" stroke=\"#222\"/>\n");
                writer.write("<text x=\"" + number(x) + "\" y=\"" + (top + plotHeight + 22)
                        + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"12\">"
                        + number(xValue) + "</text>\n");
            }
            for (int tick = 0; tick <= 5; tick++) {
                double yTick = yPlotMin + (yPlotMax - yPlotMin) * tick / 5.0;
                double y = top + plotHeight - (yTick - yPlotMin) * plotHeight / (yPlotMax - yPlotMin);
                String label = logScale ? "1e" + Math.round(yTick) : number(yTick);
                writer.write("<line x1=\"" + (left - 5) + "\" y1=\"" + number(y)
                        + "\" x2=\"" + left + "\" y2=\"" + number(y) + "\" stroke=\"#222\"/>\n");
                writer.write("<text x=\"" + (left - 10) + "\" y=\"" + number(y + 4)
                        + "\" text-anchor=\"end\" font-family=\"sans-serif\" font-size=\"12\">"
                        + escapeXml(label) + "</text>\n");
            }
            for (IncorrectMatch match : matches) {
                double x = left + match.canonical.first().distance * plotWidth / xMax;
                double yRaw = yValue(match, logScale, yMin);
                double yScaled = logScale ? Math.log10(yRaw) : yRaw;
                double y = top + plotHeight - (yScaled - yPlotMin) * plotHeight / (yPlotMax - yPlotMin);
                writer.write("<circle cx=\"" + number(x) + "\" cy=\"" + number(y)
                        + "\" r=\"3\" fill=\"" + statusColor(match.record.statusFolder)
                        + "\" fill-opacity=\"0.62\"><title>"
                        + escapeXml(match.record.relativePath + " d=" + match.canonical.first().distance
                                + " reward=" + number(match.candidateReward))
                        + "</title></circle>\n");
            }
            writer.write("<text x=\"" + (left + plotWidth / 2) + "\" y=\"" + (height - 22)
                    + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"14\">Minimum canonical distance to oracle/correct pool</text>\n");
            writer.write("<text x=\"18\" y=\"" + (top + plotHeight / 2)
                    + "\" transform=\"rotate(-90 18 " + (top + plotHeight / 2)
                    + ")\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"14\">1 - reward</text>\n");
            writer.write("</svg>\n");
        }
    }

    private static void writeRelativeRepairCoveragePlot(Path path, List<IncorrectMatch> matches) throws IOException {
        if (matches.isEmpty()) {
            return;
        }
        double[] levenshteinRatios = relativeRepairRatios(matches, "levenshtein");
        double[] rawAstRatios = relativeRepairRatios(matches, "rawAst");
        double[] canonicalRatios = relativeRepairRatios(matches, "canonical");
        int width = 980;
        int height = 620;
        int left = 88;
        int right = 42;
        int top = 70;
        int bottom = 86;
        int plotWidth = width - left - right;
        int plotHeight = height - top - bottom;
        int baseline = top + plotHeight;
        try (Writer writer = outputWriter(path)) {
            writer.write("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + width + "\" height=\"" + height
                    + "\" viewBox=\"0 0 " + width + " " + height + "\">\n");
            writer.write("<rect width=\"100%\" height=\"100%\" fill=\"white\"/>\n");
            writer.write("<text x=\"" + (width / 2) + "\" y=\"34\" text-anchor=\"middle\" "
                    + "font-family=\"sans-serif\" font-size=\"20\">Relative repair coverage by metric</text>\n");
            writer.write("<text x=\"" + (width / 2) + "\" y=\"54\" text-anchor=\"middle\" "
                    + "font-family=\"sans-serif\" font-size=\"12\" fill=\"#555\">Empirical coverage curve for nearest correct repairs from 0% to 100% of representation size</text>\n");
            writer.write("<line x1=\"" + left + "\" y1=\"" + baseline + "\" x2=\""
                    + (left + plotWidth) + "\" y2=\"" + baseline
                    + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
            writer.write("<line x1=\"" + left + "\" y1=\"" + top + "\" x2=\"" + left + "\" y2=\""
                    + baseline + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
            for (int tick = 0; tick <= 5; tick++) {
                double yValue = tick / 5.0;
                double y = baseline - yValue * plotHeight;
                writer.write("<line x1=\"" + left + "\" y1=\"" + number(y)
                        + "\" x2=\"" + (left + plotWidth) + "\" y2=\"" + number(y)
                        + "\" stroke=\"#e8e8e8\"/>\n");
                writer.write("<line x1=\"" + (left - 5) + "\" y1=\"" + number(y)
                        + "\" x2=\"" + left + "\" y2=\"" + number(y) + "\" stroke=\"#222\"/>\n");
                writer.write("<text x=\"" + (left - 10) + "\" y=\"" + number(y + 4)
                        + "\" text-anchor=\"end\" font-family=\"sans-serif\" font-size=\"12\">"
                        + escapeXml(percentLabel(yValue)) + "</text>\n");
            }
            for (int tick = 0; tick <= 5; tick++) {
                double fraction = tick / 5.0;
                double x = left + fraction * plotWidth;
                writer.write("<line x1=\"" + number(x) + "\" y1=\"" + top
                        + "\" x2=\"" + number(x) + "\" y2=\"" + baseline
                        + "\" stroke=\"#f0f0f0\"/>\n");
                writer.write("<line x1=\"" + number(x) + "\" y1=\"" + baseline
                        + "\" x2=\"" + number(x) + "\" y2=\"" + (baseline + 5)
                        + "\" stroke=\"#222\"/>\n");
                writer.write("<text x=\"" + number(x) + "\" y=\"" + (baseline + 24)
                        + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"12\">"
                        + escapeXml(percentLabel(fraction)) + "</text>\n");
            }
            writeRelativeCoverageSeries(writer, levenshteinRatios, "levenshtein", left, top, plotWidth, plotHeight);
            writeRelativeCoverageSeries(writer, rawAstRatios, "rawAst", left, top, plotWidth, plotHeight);
            writeRelativeCoverageSeries(writer, canonicalRatios, "canonical", left, top, plotWidth, plotHeight);
            writeMetricLegendItem(writer, width - 340, 82, "Levenshtein / lexical size", metricColor("levenshtein"));
            writeMetricLegendItem(writer, width - 340, 104, "Raw AST / AST size", metricColor("rawAst"));
            writeMetricLegendItem(writer, width - 340, 126, "Canonical / canonical size", metricColor("canonical"));
            writer.write("<text x=\"" + (left + plotWidth / 2) + "\" y=\"" + (height - 26)
                    + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"14\">Repair radius as fraction of representation size</text>\n");
            writer.write("<text x=\"22\" y=\"" + (top + plotHeight / 2)
                    + "\" transform=\"rotate(-90 22 " + (top + plotHeight / 2)
                    + ")\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"14\">Incorrect predicates repaired within radius</text>\n");
            writer.write("</svg>\n");
        }
    }

    private static void writeRawEditRepairCoveragePlot(Path path, List<IncorrectMatch> matches) throws IOException {
        if (matches.isEmpty()) {
            return;
        }
        int[] rawAstDistances = rawRepairDistances(matches, "rawAst");
        int[] canonicalDistances = rawRepairDistances(matches, "canonical");
        int xMax = RAW_EDIT_REPAIR_PLOT_MAX_DISTANCE;
        int width = 980;
        int height = 620;
        int left = 88;
        int right = 42;
        int top = 70;
        int bottom = 86;
        int plotWidth = width - left - right;
        int plotHeight = height - top - bottom;
        int baseline = top + plotHeight;
        try (Writer writer = outputWriter(path)) {
            writer.write("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + width + "\" height=\"" + height
                    + "\" viewBox=\"0 0 " + width + " " + height + "\">\n");
            writer.write("<rect width=\"100%\" height=\"100%\" fill=\"white\"/>\n");
            writer.write("<text x=\"" + (width / 2) + "\" y=\"34\" text-anchor=\"middle\" "
                    + "font-family=\"sans-serif\" font-size=\"20\">Repair coverage by edit distance</text>\n");
            //writer.write("<text x=\"" + (width / 2) + "\" y=\"54\" text-anchor=\"middle\" "
            //        + "font-family=\"sans-serif\" font-size=\"12\" fill=\"#555\">Empirical coverage curve for nearest correct repairs, excluding Levenshtein</text>\n");
            writer.write("<line x1=\"" + left + "\" y1=\"" + baseline + "\" x2=\""
                    + (left + plotWidth) + "\" y2=\"" + baseline
                    + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
            writer.write("<line x1=\"" + left + "\" y1=\"" + top + "\" x2=\"" + left + "\" y2=\""
                    + baseline + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
            for (int tick = 0; tick <= 5; tick++) {
                double yValue = tick / 5.0;
                double y = baseline - yValue * plotHeight;
                writer.write("<line x1=\"" + left + "\" y1=\"" + number(y)
                        + "\" x2=\"" + (left + plotWidth) + "\" y2=\"" + number(y)
                        + "\" stroke=\"#e8e8e8\"/>\n");
                writer.write("<line x1=\"" + (left - 5) + "\" y1=\"" + number(y)
                        + "\" x2=\"" + left + "\" y2=\"" + number(y) + "\" stroke=\"#222\"/>\n");
                writer.write("<text x=\"" + (left - 10) + "\" y=\"" + number(y + 4)
                        + "\" text-anchor=\"end\" font-family=\"sans-serif\" font-size=\"12\">"
                        + escapeXml(percentLabel(yValue)) + "</text>\n");
            }
            for (int tick = 0; tick <= RAW_EDIT_REPAIR_PLOT_TICK_COUNT; tick++) {
                int radius = (int) Math.round(xMax * tick / (double) RAW_EDIT_REPAIR_PLOT_TICK_COUNT);
                double x = left + radius * plotWidth / (double) xMax;
                writer.write("<line x1=\"" + number(x) + "\" y1=\"" + top
                        + "\" x2=\"" + number(x) + "\" y2=\"" + baseline
                        + "\" stroke=\"#f0f0f0\"/>\n");
                writer.write("<line x1=\"" + number(x) + "\" y1=\"" + baseline
                        + "\" x2=\"" + number(x) + "\" y2=\"" + (baseline + 5)
                        + "\" stroke=\"#222\"/>\n");
                writer.write("<text x=\"" + number(x) + "\" y=\"" + (baseline + 24)
                        + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"12\">"
                        + radius + "</text>\n");
            }
            writeRawEditCoverageSeries(writer, rawAstDistances, "rawAst", xMax, left, top, plotWidth, plotHeight);
            writeRawEditCoverageSeries(writer, canonicalDistances, "canonical", xMax, left, top, plotWidth, plotHeight);
            writeMetricLegendItem(writer, width - 320, 82, "Raw AST", metricColor("rawAst"));
            writeMetricLegendItem(writer, width - 320, 104, "Canonical", metricColor("canonical"));
            writer.write("<text x=\"" + (left + plotWidth / 2) + "\" y=\"" + (height - 26)
                    + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"14\">Absolute edit-distance repair radius</text>\n");
            writer.write("<text x=\"22\" y=\"" + (top + plotHeight / 2)
                    + "\" transform=\"rotate(-90 22 " + (top + plotHeight / 2)
                    + ")\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"14\">Incorrect predicates repaired within radius</text>\n");
            writer.write("</svg>\n");
        }
    }

    private static void writeRawEditCoverageSeries(
            Writer writer,
            int[] sortedDistances,
            String metric,
            int xMax,
            int left,
            int top,
            int plotWidth,
            int plotHeight) throws IOException {
        String color = metricColor(metric);
        StringBuilder path = new StringBuilder();
        for (int radius = 0; radius <= xMax; radius++) {
            double covered = sortedDistances.length == 0
                    ? 0.0
                    : upperBound(sortedDistances, radius) / (double) sortedDistances.length;
            double x = left + radius * plotWidth / (double) xMax;
            double y = top + plotHeight - covered * plotHeight;
            path.append(radius == 0 ? "M " : " L ")
                    .append(number(x))
                    .append(' ')
                    .append(number(y));
        }
        writer.write("<path d=\"" + path + "\" fill=\"none\" stroke=\"" + color
                + "\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n");
        for (int radius : REPAIR_RADII) {
            if (radius > xMax) {
                continue;
            }
            int count = upperBound(sortedDistances, radius);
            double covered = sortedDistances.length == 0 ? 0.0 : count / (double) sortedDistances.length;
            double x = left + radius * plotWidth / (double) xMax;
            double y = top + plotHeight - covered * plotHeight;
            writer.write("<circle cx=\"" + number(x) + "\" cy=\"" + number(y)
                    + "\" r=\"5\" fill=\"" + color + "\"><title>"
                    + escapeXml(repairMetricTitle(metric) + " <= " + radius + ": "
                            + countPercent(count, sortedDistances.length))
                    + "</title></circle>\n");
        }
    }

    private static void writeRelativeCoverageSeries(
            Writer writer,
            double[] sortedRatios,
            String metric,
            int left,
            int top,
            int plotWidth,
            int plotHeight) throws IOException {
        String color = metricColor(metric);
        StringBuilder path = new StringBuilder();
        for (int i = 0; i <= RELATIVE_REPAIR_CURVE_STEPS; i++) {
            double fraction = i / (double) RELATIVE_REPAIR_CURVE_STEPS;
            double covered = relativeCoverageRatio(sortedRatios, fraction);
            double x = left + fraction * plotWidth;
            double y = top + plotHeight - covered * plotHeight;
            path.append(i == 0 ? "M " : " L ")
                    .append(number(x))
                    .append(' ')
                    .append(number(y));
        }
        writer.write("<path d=\"" + path + "\" fill=\"none\" stroke=\"" + color
                + "\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n");
        for (double radius : RELATIVE_REPAIR_RADII) {
            int count = upperBound(sortedRatios, radius);
            double covered = sortedRatios.length == 0 ? 0.0 : count / (double) sortedRatios.length;
            double x = left + radius * plotWidth;
            double y = top + plotHeight - covered * plotHeight;
            writer.write("<circle cx=\"" + number(x) + "\" cy=\"" + number(y)
                    + "\" r=\"5\" fill=\"" + color + "\"><title>"
                    + escapeXml(repairMetricTitle(metric) + " <= " + percentLabel(radius)
                            + ": " + countPercent(count, sortedRatios.length))
                    + "</title></circle>\n");
        }
    }

    private static double[] relativeRepairRatios(List<IncorrectMatch> matches, String metric) {
        double[] ratios = new double[matches.size()];
        for (int i = 0; i < matches.size(); i++) {
            ratios[i] = repairMetricRatio(matches.get(i), metric);
        }
        Arrays.sort(ratios);
        return ratios;
    }

    private static int[] rawRepairDistances(List<IncorrectMatch> matches, String metric) {
        int[] distances = new int[matches.size()];
        for (int i = 0; i < matches.size(); i++) {
            distances[i] = repairMetricDistance(matches.get(i), metric);
        }
        Arrays.sort(distances);
        return distances;
    }

    private static double relativeCoverageRatio(double[] sortedRatios, double radiusFraction) {
        return sortedRatios.length == 0 ? 0.0 : upperBound(sortedRatios, radiusFraction) / (double) sortedRatios.length;
    }

    private static int upperBound(double[] sortedValues, double value) {
        int low = 0;
        int high = sortedValues.length;
        while (low < high) {
            int mid = (low + high) >>> 1;
            if (sortedValues[mid] <= value) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return low;
    }

    private static int upperBound(int[] sortedValues, int value) {
        int low = 0;
        int high = sortedValues.length;
        while (low < high) {
            int mid = (low + high) >>> 1;
            if (sortedValues[mid] <= value) {
                low = mid + 1;
            } else {
                high = mid;
            }
        }
        return low;
    }

    private static int relativeCoverageCount(RepairRadiusStats coverage, String metric, int index) {
        if ("levenshtein".equals(metric)) {
            return coverage.levenshteinRelativeWithin[index];
        }
        if ("rawAst".equals(metric)) {
            return coverage.rawAstRelativeWithin[index];
        }
        return coverage.canonicalRelativeWithin[index];
    }

    private static double relativeCoverageRatio(RepairRadiusStats coverage, String metric, int index) {
        return coverage.count == 0 ? 0.0 : relativeCoverageCount(coverage, metric, index) / (double) coverage.count;
    }

    private static String metricColor(String metric) {
        if ("levenshtein".equals(metric)) {
            return "#2ca02c";
        }
        if ("rawAst".equals(metric)) {
            return "#ff7f0e";
        }
        return "#1f77b4";
    }

    private static void writeMetricLegendItem(Writer writer, int x, int y, String label, String color) throws IOException {
        writer.write("<line x1=\"" + x + "\" y1=\"" + y + "\" x2=\"" + (x + 24)
                + "\" y2=\"" + y + "\" stroke=\"" + color + "\" stroke-width=\"3\"/>\n");
        writer.write("<circle cx=\"" + (x + 12) + "\" cy=\"" + y + "\" r=\"4\" fill=\"" + color + "\"/>\n");
        writer.write("<text x=\"" + (x + 32) + "\" y=\"" + (y + 4)
                + "\" font-family=\"sans-serif\" font-size=\"12\" fill=\"#333\">"
                + escapeXml(label) + "</text>\n");
    }

    private static void writeRepairRatioRegressionPlot(Path path, List<IncorrectMatch> matches) throws IOException {
        if (matches.isEmpty()) {
            return;
        }
        int width = 1150;
        int height = 1040;
        int left = 92;
        int right = 34;
        int top = 72;
        int bottom = 72;
        int gap = 70;
        int plotWidth = width - left - right;
        int plotHeight = (height - top - bottom - 2 * gap) / 3;
        try (Writer writer = outputWriter(path)) {
            writer.write("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + width + "\" height=\"" + height
                    + "\" viewBox=\"0 0 " + width + " " + height + "\">\n");
            writer.write("<rect width=\"100%\" height=\"100%\" fill=\"white\"/>\n");
            writer.write("<text x=\"" + (width / 2) + "\" y=\"34\" text-anchor=\"middle\" "
                    + "font-family=\"sans-serif\" font-size=\"20\">Repair distance ratio vs representation size</text>\n");
            writeRepairRatioLegend(writer, width - 430, 22);
            writeRepairRatioPanel(writer, matches, "levenshtein", left, top, plotWidth, plotHeight);
            writeRepairRatioPanel(writer, matches, "rawAst", left, top + plotHeight + gap, plotWidth, plotHeight);
            writeRepairRatioPanel(writer, matches, "canonical", left, top + 2 * (plotHeight + gap), plotWidth, plotHeight);
            writer.write("</svg>\n");
        }
    }

    private static void writeRepairRatioPanel(
            Writer writer,
            List<IncorrectMatch> matches,
            String metric,
            int left,
            int top,
            int plotWidth,
            int plotHeight) throws IOException {
        double xMax = 1.0;
        double yMax = 1.0;
        for (IncorrectMatch match : matches) {
            xMax = Math.max(xMax, repairMetricSize(match, metric));
            yMax = Math.max(yMax, repairMetricRatio(match, metric));
        }
        yMax = Math.max(1.0, yMax * 1.08);
        RepairRatioRegressionStats stats = repairRatioRegressionStats(matches, metric);
        int baseline = top + plotHeight;
        writer.write("<text x=\"" + left + "\" y=\"" + (top - 20)
                + "\" font-family=\"sans-serif\" font-size=\"16\" font-weight=\"600\">"
                + escapeXml(repairMetricTitle(metric)) + "</text>\n");
        writer.write("<text x=\"" + left + "\" y=\"" + (top - 4)
                + "\" font-family=\"sans-serif\" font-size=\"12\" fill=\"#555\">Pearson r="
                + number(stats.correlation()) + ", slope=" + number(stats.slope()) + "</text>\n");
        writer.write("<line x1=\"" + left + "\" y1=\"" + baseline + "\" x2=\""
                + (left + plotWidth) + "\" y2=\"" + baseline
                + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
        writer.write("<line x1=\"" + left + "\" y1=\"" + top + "\" x2=\"" + left + "\" y2=\""
                + baseline + "\" stroke=\"#222\" stroke-width=\"1\"/>\n");
        for (int tick = 0; tick <= 5; tick++) {
            double xValue = xMax * tick / 5.0;
            double x = left + xValue * plotWidth / xMax;
            writer.write("<line x1=\"" + number(x) + "\" y1=\"" + top
                    + "\" x2=\"" + number(x) + "\" y2=\"" + baseline
                    + "\" stroke=\"#e6e6e6\"/>\n");
            writer.write("<line x1=\"" + number(x) + "\" y1=\"" + baseline
                    + "\" x2=\"" + number(x) + "\" y2=\"" + (baseline + 5)
                    + "\" stroke=\"#222\"/>\n");
            writer.write("<text x=\"" + number(x) + "\" y=\"" + (baseline + 21)
                    + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"11\">"
                    + escapeXml(axisNumber(xValue)) + "</text>\n");
        }
        for (int tick = 0; tick <= 5; tick++) {
            double yValue = yMax * tick / 5.0;
            double y = baseline - yValue * plotHeight / yMax;
            writer.write("<line x1=\"" + left + "\" y1=\"" + number(y)
                    + "\" x2=\"" + (left + plotWidth) + "\" y2=\"" + number(y)
                    + "\" stroke=\"#e6e6e6\"/>\n");
            writer.write("<line x1=\"" + (left - 5) + "\" y1=\"" + number(y)
                    + "\" x2=\"" + left + "\" y2=\"" + number(y) + "\" stroke=\"#222\"/>\n");
            writer.write("<text x=\"" + (left - 10) + "\" y=\"" + number(y + 4)
                    + "\" text-anchor=\"end\" font-family=\"sans-serif\" font-size=\"11\">"
                    + escapeXml(axisNumber(yValue)) + "</text>\n");
        }
        for (IncorrectMatch match : matches) {
            double xValue = repairMetricSize(match, metric);
            double yValue = repairMetricRatio(match, metric);
            double x = left + xValue * plotWidth / xMax;
            double y = baseline - yValue * plotHeight / yMax;
            writer.write("<circle cx=\"" + number(x) + "\" cy=\"" + number(y)
                    + "\" r=\"2.7\" fill=\"" + statusColor(match.record.statusFolder)
                    + "\" fill-opacity=\"0.50\"><title>"
                    + escapeXml(match.record.relativePath + " size=" + axisNumber(xValue)
                            + " ratio=" + number(yValue))
                    + "</title></circle>\n");
        }
        double y0 = clamp(stats.intercept(), 0.0, yMax);
        double y1 = clamp(stats.intercept() + stats.slope() * xMax, 0.0, yMax);
        double lineY0 = baseline - y0 * plotHeight / yMax;
        double lineY1 = baseline - y1 * plotHeight / yMax;
        writer.write("<line x1=\"" + left + "\" y1=\"" + number(lineY0)
                + "\" x2=\"" + (left + plotWidth) + "\" y2=\"" + number(lineY1)
                + "\" stroke=\"#111\" stroke-width=\"2.2\" stroke-opacity=\"0.82\"/>\n");
        writer.write("<text x=\"" + (left + plotWidth / 2) + "\" y=\"" + (baseline + 43)
                + "\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"12\">"
                + escapeXml(repairMetricXAxis(metric)) + "</text>\n");
        writer.write("<text x=\"22\" y=\"" + (top + plotHeight / 2)
                + "\" transform=\"rotate(-90 22 " + (top + plotHeight / 2)
                + ")\" text-anchor=\"middle\" font-family=\"sans-serif\" font-size=\"12\">"
                + escapeXml(repairMetricYAxis(metric)) + "</text>\n");
    }

    private static void writeRepairRatioLegend(Writer writer, int x, int y) throws IOException {
        writeLegendItem(writer, x, y, "BOTH", statusColor("BOTH"));
        writeLegendItem(writer, x + 105, y, "OVER", statusColor("OVERCONSTRAINED"));
        writeLegendItem(writer, x + 215, y, "UNDER", statusColor("UNDERCONSTRAINED"));
    }

    private static void writeLegendItem(Writer writer, int x, int y, String label, String color) throws IOException {
        writer.write("<circle cx=\"" + x + "\" cy=\"" + y + "\" r=\"5\" fill=\"" + color
                + "\" fill-opacity=\"0.72\"/>\n");
        writer.write("<text x=\"" + (x + 10) + "\" y=\"" + (y + 4)
                + "\" font-family=\"sans-serif\" font-size=\"12\" fill=\"#333\">"
                + escapeXml(label) + "</text>\n");
    }

    private static void writePlotScript(Path path) throws IOException {
        try (Writer writer = outputWriter(path)) {
            writer.write("#!/usr/bin/env python3\n");
            writer.write("import csv, math\nfrom pathlib import Path\n\n");
            writer.write("ROOT = Path(__file__).resolve().parent\nCSV = ROOT / 'canonical_reward_points.csv'\n");
            writer.write("def corr(xs, ys):\n");
            writer.write("    if len(xs) < 2:\n        return 0.0\n");
            writer.write("    xb = sum(xs) / len(xs)\n    yb = sum(ys) / len(ys)\n");
            writer.write("    num = sum((x - xb) * (y - yb) for x, y in zip(xs, ys))\n");
            writer.write("    xd = math.sqrt(sum((x - xb) ** 2 for x in xs))\n");
            writer.write("    yd = math.sqrt(sum((y - yb) ** 2 for y in ys))\n");
            writer.write("    return 0.0 if xd == 0.0 or yd == 0.0 else num / (xd * yd)\n\n");
            writer.write("print('Use the generated SVG plots:')\n");
            writer.write("print(ROOT / 'canonical_distance_vs_reward_error_raw.svg')\n");
            writer.write("print(ROOT / 'canonical_distance_vs_reward_error_log.svg')\n");
            writer.write("print(ROOT / 'relative_repair_coverage_comparison.svg')\n");
            writer.write("print(ROOT / 'raw_edit_repair_coverage_ast_canonical.svg')\n");
            writer.write("with CSV.open() as f:\n");
            writer.write("    all_rows = list(csv.DictReader(f))\n");
            writer.write("rows = [r for r in all_rows if r.get('candidateReward')]\n");
            writer.write("print(f'Loaded {len(rows)} rewarded points from {CSV}')\n");
            writer.write("errs = [float(r['rewardError']) for r in rows]\n");
            writer.write("positive = [e for e in errs if e > 0.0]\n");
            writer.write("floor = min(positive) / 10.0 if positive else 1e-6\n");
            writer.write("logs = [math.log10(max(e, floor)) for e in errs]\n");
            writer.write("for key, ratio_key, label in [('levenshteinDistance', 'levenshteinDistanceRatio', 'Levenshtein'), ('rawAstDistance', 'rawAstDistanceRatio', 'Raw AST'), ('canonicalDistance', 'canonicalDistanceRatio', 'Canonical')]:\n");
            writer.write("    xs = [float(r[key]) for r in rows]\n");
            writer.write("    ratios = [float(r[ratio_key]) for r in rows]\n");
            writer.write("    print(f\"Pearson {label} distance vs raw 1-reward: {corr(xs, errs):.6f}\")\n");
            writer.write("    print(f\"Pearson {label} distance vs log10(1-reward): {corr(xs, logs):.6f}\")\n");
            writer.write("    print(f\"Pearson {label} ratio vs raw 1-reward: {corr(ratios, errs):.6f}\")\n");
            writer.write("    print(f\"Pearson {label} ratio vs log10(1-reward): {corr(ratios, logs):.6f}\")\n");
            writer.write("for size_key, ratio_key, label in [('levenshteinSize', 'levenshteinDistanceRatio', 'Levenshtein'), ('rawAstSize', 'rawAstDistanceRatio', 'Raw AST'), ('canonicalSize', 'canonicalDistanceRatio', 'Canonical')]:\n");
            writer.write("    xs = [float(r[size_key]) for r in all_rows if r.get(size_key) and r.get(ratio_key)]\n");
            writer.write("    ys = [float(r[ratio_key]) for r in all_rows if r.get(size_key) and r.get(ratio_key)]\n");
            writer.write("    print(f\"Pearson {label} repair ratio vs representation size: {corr(xs, ys):.6f}\")\n");
        }
    }

    private static void writeMatchJson(Writer writer, IncorrectMatch match) throws IOException {
        ModelRecord record = match.record;
        writer.write("    {\n");
        writer.write("      \"fileName\": \"" + escape(record.fileName) + "\",\n");
        writer.write("      \"relativePath\": \"" + escape(record.relativePath) + "\",\n");
        writer.write("      \"questionSet\": \"" + escape(record.questionSet) + "\",\n");
        writer.write("      \"statusFolder\": \"" + escape(record.statusFolder) + "\",\n");
        writer.write("      \"invariantId\": \"" + escape(record.invariantId) + "\",\n");
        writer.write("      \"leftPredicate\": \"" + escape(record.leftPredicate) + "\",\n");
        writer.write("      \"rightPredicate\": \"" + escape(record.rightPredicate) + "\",\n");
        writer.write("      \"levenshteinSize\": " + record.levenshteinSize + ",\n");
        writer.write("      \"rawAstSize\": " + record.rawAstSize + ",\n");
        writer.write("      \"canonicalSize\": " + record.canonicalSize + ",\n");
        writer.write("      \"levenshteinDistanceRatio\": "
                + number(ratio(match.levenshtein.first().distance, record.levenshteinSize)) + ",\n");
        writer.write("      \"rawAstDistanceRatio\": "
                + number(ratio(match.rawAst.first().distance, record.rawAstSize)) + ",\n");
        writer.write("      \"canonicalDistanceRatio\": "
                + number(ratio(match.canonical.first().distance, record.canonicalSize)) + ",\n");
        writer.write("      \"rewardPoolSize\": " + match.rewardPoolSize + ",\n");
        if (match.rewardComputed && match.rewardErrorMessage == null) {
            writer.write("      \"candidateReward\": " + number(match.candidateReward) + ",\n");
            writer.write("      \"rewardError\": " + number(match.rewardError) + ",\n");
        } else {
            writer.write("      \"candidateReward\": null,\n");
            writer.write("      \"rewardError\": null,\n");
            writer.write("      \"rewardErrorMessage\": \"" + escape(match.rewardComputed
                    ? match.rewardErrorMessage
                    : "Reward computation skipped.") + "\",\n");
        }
        writer.write("      \"nearestLevenshtein\": ");
        writeNearestJson(writer, match.levenshtein);
        writer.write(",\n");
        writer.write("      \"nearestRawAst\": ");
        writeNearestJson(writer, match.rawAst);
        writer.write(",\n");
        writer.write("      \"nearestCanonical\": ");
        writeNearestJson(writer, match.canonical);
        writer.write(",\n");
        writer.write("      \"levenshteinRanking\": ");
        writeRankingJson(writer, match.levenshtein);
        writer.write(",\n");
        writer.write("      \"rawAstRanking\": ");
        writeRankingJson(writer, match.rawAst);
        writer.write(",\n");
        writer.write("      \"canonicalRanking\": ");
        writeRankingJson(writer, match.canonical);
        writer.write("\n");
        writer.write("    }");
    }

    private static void writeUnmatchedJson(Writer writer, ModelRecord record) throws IOException {
        writer.write("    {\n");
        writer.write("      \"fileName\": \"" + escape(record.fileName) + "\",\n");
        writer.write("      \"relativePath\": \"" + escape(record.relativePath) + "\",\n");
        writer.write("      \"questionSet\": \"" + escape(record.questionSet) + "\",\n");
        writer.write("      \"statusFolder\": \"" + escape(record.statusFolder) + "\",\n");
        writer.write("      \"invariantId\": \"" + escape(record.invariantId) + "\",\n");
        writer.write("      \"leftPredicate\": \"" + escape(record.leftPredicate) + "\",\n");
        writer.write("      \"rightPredicate\": \"" + escape(record.rightPredicate) + "\",\n");
        writer.write("      \"reason\": \"No CORRECT reference exists for this question set and invariant id.\"\n");
        writer.write("    }");
    }

    private static void writeNearestJson(Writer writer, Nearest nearest) throws IOException {
        RankedReference first = nearest.first();
        writer.write("{\"distance\": " + first.distance + ", \"rank\": " + first.rank + ", \"referenceName\": \""
                + escape(first.reference.augmentedName) + "\", \"referenceKind\": \""
                + escape(first.reference.kind) + "\", \"referenceSource\": \""
                + escape(first.reference.source.relativePath) + "\"}");
    }

    private static void writeRankingJson(Writer writer, Nearest nearest) throws IOException {
        writer.write("[");
        for (int i = 0; i < nearest.ranking.size(); i++) {
            RankedReference ranked = nearest.ranking.get(i);
            if (i > 0) {
                writer.write(", ");
            }
            writer.write("{\"rank\": " + ranked.rank + ", \"distance\": " + ranked.distance
                    + ", \"referenceName\": \"" + escape(ranked.reference.augmentedName)
                    + "\", \"referenceKind\": \"" + escape(ranked.reference.kind)
                    + "\", \"referenceSource\": \"" + escape(ranked.reference.source.relativePath) + "\"}");
        }
        writer.write("]");
    }

    private static Map<String, QuestionSetStats> questionSetStats(
            Map<String, QuestionGroup> groups,
            List<IncorrectMatch> matches) {
        Map<String, QuestionSetStats> stats = new java.util.TreeMap<>();
        for (QuestionGroup group : groups.values()) {
            QuestionSetStats setStats = stats.computeIfAbsent(
                    group.questionSet,
                    QuestionSetStats::new);
            setStats.groups++;
            setStats.correct += group.correct.size();
            setStats.incorrect += group.incorrect.size();
            setStats.references += group.references.size();
            if ("oracle-only".equals(group.rankingMode())) {
                setStats.oracleOnlyGroups++;
            }
        }
        for (IncorrectMatch match : matches) {
            QuestionSetStats setStats = stats.computeIfAbsent(
                    match.record.questionSet,
                    QuestionSetStats::new);
            setStats.rankedIncorrect++;
        }
        return stats;
    }

    private static Map<String, CorrectTruthStats> correctTruthStats(
            Map<String, QuestionGroup> groups,
            List<CorrectPoolPair> correctPoolPairs) {
        Map<String, CorrectTruthStats> stats = new java.util.TreeMap<>();
        Map<Reference, Reference> canonicalParents = new java.util.IdentityHashMap<>();
        for (QuestionGroup group : groups.values()) {
            CorrectTruthStats setStats = stats.computeIfAbsent(
                    group.questionSet,
                    CorrectTruthStats::new);
            setStats.correctPredicates += group.truthCandidateCount;
            setStats.astDistinctPredicates += group.references.size();
            for (Reference reference : group.references) {
                canonicalParents.put(reference, reference);
            }
        }
        for (CorrectPoolPair pair : correctPoolPairs) {
            stats.computeIfAbsent(pair.group.questionSet, CorrectTruthStats::new)
                    .canonicalEquivalentPairs++;
            unionCanonicalForms(canonicalParents, pair.left, pair.right);
        }
        for (QuestionGroup group : groups.values()) {
            Set<Reference> canonicalForms =
                    java.util.Collections.newSetFromMap(new java.util.IdentityHashMap<>());
            for (Reference reference : group.references) {
                canonicalForms.add(canonicalRoot(canonicalParents, reference));
            }
            stats.get(group.questionSet).uniqueCanonicalForms += canonicalForms.size();
        }
        return stats;
    }

    private static void unionCanonicalForms(
            Map<Reference, Reference> parents,
            Reference left,
            Reference right) {
        Reference leftRoot = canonicalRoot(parents, left);
        Reference rightRoot = canonicalRoot(parents, right);
        if (leftRoot != rightRoot) {
            parents.put(rightRoot, leftRoot);
        }
    }

    private static Reference canonicalRoot(
            Map<Reference, Reference> parents,
            Reference reference) {
        Reference root = reference;
        while (parents.get(root) != root) {
            root = parents.get(root);
        }
        while (reference != root) {
            Reference next = parents.get(reference);
            parents.put(reference, root);
            reference = next;
        }
        return root;
    }

    private static Map<String, RankingModeStats> rankingModeStats(Map<String, QuestionGroup> groups) {
        Map<String, RankingModeStats> stats = new java.util.TreeMap<>();
        for (QuestionGroup group : groups.values()) {
            RankingModeStats modeStats = stats.computeIfAbsent(
                    group.rankingMode(),
                    RankingModeStats::new);
            modeStats.groups++;
            modeStats.incorrect += group.incorrect.size();
            int refs = group.rankingReferences().size();
            modeStats.minRefs = modeStats.minRefs == null ? refs : Math.min(modeStats.minRefs, refs);
            modeStats.maxRefs = modeStats.maxRefs == null ? refs : Math.max(modeStats.maxRefs, refs);
        }
        return stats;
    }

    private static DistanceTableStats distanceTableStats(List<IncorrectMatch> matches) {
        DistanceTableStats table = new DistanceTableStats();
        for (IncorrectMatch match : matches) {
            table.add(match);
        }
        return table;
    }

    private static Map<String, RepairRadiusStats> repairRadiusStatsOverall(List<IncorrectMatch> matches) {
        Map<String, RepairRadiusStats> stats = new java.util.LinkedHashMap<>();
        RepairRadiusStats all = new RepairRadiusStats("All incorrect");
        for (IncorrectMatch match : matches) {
            all.add(match);
        }
        stats.put(all.label, all);
        return stats;
    }

    private static Map<String, RepairRadiusStats> repairRadiusStatsByStatus(List<IncorrectMatch> matches) {
        Map<String, RepairRadiusStats> stats = new java.util.TreeMap<>();
        for (IncorrectMatch match : matches) {
            RepairRadiusStats row = stats.computeIfAbsent(
                    match.record.statusFolder,
                    RepairRadiusStats::new);
            row.add(match);
        }
        return stats;
    }

    private static Map<String, RepairRadiusStats> repairRadiusStatsByQuestionSet(List<IncorrectMatch> matches) {
        Map<String, RepairRadiusStats> stats = new java.util.TreeMap<>();
        for (IncorrectMatch match : matches) {
            RepairRadiusStats row = stats.computeIfAbsent(
                    match.record.questionSet,
                    RepairRadiusStats::new);
            row.add(match);
        }
        return stats;
    }

    private static Map<String, RepairRadiusStats> repairRadiusStatsByQuestionSetAndStatus(List<IncorrectMatch> matches) {
        Map<String, RepairRadiusStats> stats = new java.util.TreeMap<>();
        for (IncorrectMatch match : matches) {
            String key = match.record.questionSet + " / " + match.record.statusFolder;
            RepairRadiusStats row = stats.computeIfAbsent(
                    key,
                    RepairRadiusStats::new);
            row.add(match);
        }
        return stats;
    }

    private static RepairRatioRegressionStats repairRatioRegressionStats(List<IncorrectMatch> matches, String metric) {
        RepairRatioRegressionStats stats = new RepairRatioRegressionStats();
        for (IncorrectMatch match : matches) {
            stats.add(repairMetricSize(match, metric), repairMetricRatio(match, metric));
        }
        return stats;
    }

    private static RewardDistanceStats rewardDistanceStats(List<IncorrectMatch> matches, String metric) {
        RewardDistanceStats stats = new RewardDistanceStats();
        double floor = rewardErrorFloor(matches);
        for (IncorrectMatch match : matches) {
            if (match.rewardComputed && match.rewardErrorMessage == null) {
                stats.add(rewardMetricDistance(match, metric), match.rewardError, floor);
            }
        }
        return stats;
    }

    private static RewardDistanceStats rewardRatioStats(List<IncorrectMatch> matches, String metric) {
        RewardDistanceStats stats = new RewardDistanceStats();
        double floor = rewardErrorFloor(matches);
        for (IncorrectMatch match : matches) {
            if (match.rewardComputed && match.rewardErrorMessage == null) {
                stats.add(rewardMetricRatio(match, metric), match.rewardError, floor);
            }
        }
        return stats;
    }

    private static int repairMetricDistance(IncorrectMatch match, String metric) {
        if ("levenshtein".equals(metric)) {
            return match.levenshtein.first().distance;
        }
        if ("rawAst".equals(metric)) {
            return match.rawAst.first().distance;
        }
        return match.canonical.first().distance;
    }

    private static double repairMetricSize(IncorrectMatch match, String metric) {
        if ("levenshtein".equals(metric)) {
            return match.record.levenshteinSize;
        }
        if ("rawAst".equals(metric)) {
            return match.record.rawAstSize;
        }
        return match.record.canonicalSize;
    }

    private static double repairMetricRatio(IncorrectMatch match, String metric) {
        if ("levenshtein".equals(metric)) {
            return ratio(match.levenshtein.first().distance, match.record.levenshteinSize);
        }
        if ("rawAst".equals(metric)) {
            return ratio(match.rawAst.first().distance, match.record.rawAstSize);
        }
        return ratio(match.canonical.first().distance, match.record.canonicalSize);
    }

    private static String repairMetricTitle(String metric) {
        if ("levenshtein".equals(metric)) {
            return "Levenshtein repair ratio";
        }
        if ("rawAst".equals(metric)) {
            return "Raw AST repair ratio";
        }
        return "Canonical repair ratio";
    }

    private static String repairMetricXAxis(String metric) {
        if ("levenshtein".equals(metric)) {
            return "Incorrect predicate body size, in characters";
        }
        if ("rawAst".equals(metric)) {
            return "Incorrect raw AST size, in nodes";
        }
        return "Incorrect canonical-form size";
    }

    private static String repairMetricYAxis(String metric) {
        if ("levenshtein".equals(metric)) {
            return "Levenshtein distance / body size";
        }
        if ("rawAst".equals(metric)) {
            return "AST distance / AST size";
        }
        return "Canonical distance / canonical size";
    }

    private static double rewardMetricDistance(IncorrectMatch match, String metric) {
        if ("levenshtein".equals(metric)) {
            return match.levenshtein.first().distance;
        }
        if ("rawAst".equals(metric)) {
            return match.rawAst.first().distance;
        }
        return match.canonical.first().distance;
    }

    private static double rewardMetricRatio(IncorrectMatch match, String metric) {
        if ("levenshtein".equals(metric)) {
            return ratio(match.levenshtein.first().distance, match.record.levenshteinSize);
        }
        if ("rawAst".equals(metric)) {
            return ratio(match.rawAst.first().distance, match.record.rawAstSize);
        }
        return ratio(match.canonical.first().distance, match.record.canonicalSize);
    }

    private static double rewardErrorFloor(List<IncorrectMatch> matches) {
        double floor = Double.POSITIVE_INFINITY;
        for (IncorrectMatch match : matches) {
            if (match.rewardComputed && match.rewardErrorMessage == null && match.rewardError > 0.0) {
                floor = Math.min(floor, match.rewardError);
            }
        }
        return Double.isInfinite(floor) ? 1e-6 : floor / 10.0;
    }

    private static double yValue(IncorrectMatch match, boolean logScale, double floor) {
        return logScale ? Math.max(match.rewardError, floor) : match.rewardError;
    }

    private static double ratio(double distance, int size) {
        return size <= 0 ? 0.0 : distance / (double) size;
    }

    private static String statusColor(String status) {
        if ("OVERCONSTRAINED".equals(status)) {
            return "#d62728";
        }
        if ("UNDERCONSTRAINED".equals(status)) {
            return "#1f77b4";
        }
        if ("BOTH".equals(status)) {
            return "#9467bd";
        }
        return "#555555";
    }

    private static String csv(String value) {
        if (value == null) {
            return "";
        }
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }

    private static String escapeXml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private static String number(double value) {
        return String.format(java.util.Locale.ROOT, "%.6f", value);
    }

    private static String axisNumber(double value) {
        if (Math.abs(value) >= 100.0 || Math.abs(value - Math.rint(value)) < 1e-9) {
            return String.format(java.util.Locale.ROOT, "%.0f", value);
        }
        return String.format(java.util.Locale.ROOT, "%.2f", value);
    }

    private static double clamp(double value, double min, double max) {
        return Math.max(min, Math.min(max, value));
    }

    private static String countPercent(int value, int total) {
        double percent = total == 0 ? 0.0 : 100.0 * value / total;
        return value + " (" + String.format(java.util.Locale.ROOT, "%.1f%%", percent) + ")";
    }

    private static String percentLabel(double value) {
        return String.format(java.util.Locale.ROOT, "%.0f%%", value * 100.0);
    }

    private static PredicatePair findPredicatePair(Path file, ModelUnit model) {
        Map<String, Predicate> predicates = new HashMap<>();
        Map<String, Integer> ids = new HashMap<>();
        int id = 1;
        for (Predicate predicate : model.getPredDeclList()) {
            predicates.put(predicate.getName(), predicate);
            ids.put(predicate.getName(), id++);
        }
        String[] names = DatasetConventions.findPredicatePairNames(preferredPredicateBase(file), predicates);
        if (names == null) {
            return null;
        }
        String left = names[0];
        String right = names[1];
        return new PredicatePair(left, right, ids.get(left), ids.get(right),
                predicates.get(left), predicates.get(right));
    }

    private static String predicateBody(Path file, String predicateName, Predicate predicate) {
        try {
            String source = Files.readString(file, StandardCharsets.UTF_8);
            String body = predicateBodyFromSource(source, predicateName);
            if (body != null) {
                return body.trim();
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

    private static String preludeBeforePredicate(String source, String predicateName) {
        String needle = "pred " + predicateName;
        int start = source.indexOf(needle);
        return start < 0 ? source : source.substring(0, start);
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

    private static int levenshteinDistance(String left, String right) {
        if (left.equals(right)) {
            return 0;
        }
        int prefix = 0;
        int sharedLength = Math.min(left.length(), right.length());
        while (prefix < sharedLength && left.charAt(prefix) == right.charAt(prefix)) {
            prefix++;
        }
        int leftEnd = left.length();
        int rightEnd = right.length();
        while (leftEnd > prefix
                && rightEnd > prefix
                && left.charAt(leftEnd - 1) == right.charAt(rightEnd - 1)) {
            leftEnd--;
            rightEnd--;
        }
        int leftLength = leftEnd - prefix;
        int rightLength = rightEnd - prefix;
        if (leftLength == 0 || rightLength == 0) {
            return Math.max(leftLength, rightLength);
        }

        String rows = left;
        String columns = right;
        int rowEnd = leftEnd;
        int columnEnd = rightEnd;
        if (rightLength < leftLength) {
            rows = left;
            columns = right;
        } else {
            rows = right;
            columns = left;
            rowEnd = rightEnd;
            columnEnd = leftEnd;
            int swap = leftLength;
            leftLength = rightLength;
            rightLength = swap;
        }

        int[] previous = new int[rightLength + 1];
        int[] current = new int[rightLength + 1];
        for (int j = 0; j <= rightLength; j++) {
            previous[j] = j;
        }
        for (int i = 1; i <= leftLength; i++) {
            current[0] = i;
            char rowCharacter = rows.charAt(rowEnd - leftLength + i - 1);
            for (int j = 1; j <= rightLength; j++) {
                char columnCharacter = columns.charAt(columnEnd - rightLength + j - 1);
                int replace = previous[j - 1] + (rowCharacter == columnCharacter ? 0 : 1);
                int delete = previous[j] + 1;
                int insert = current[j - 1] + 1;
                current[j] = Math.min(replace, Math.min(delete, insert));
            }
            int[] temp = previous;
            previous = current;
            current = temp;
        }
        return previous[rightLength];
    }

    private static int rawAstTreeDistance(RawAstTree left, RawAstTree right) {
        if (left == null) {
            return right == null ? 0 : right.size;
        }
        if (right == null) {
            return left.size;
        }
        int distance = left.label.equals(right.label) ? 0 : 1;
        distance += rawAstForestDistance(left.children, right.children);
        return distance;
    }

    private static int rawAstForestDistance(List<RawAstTree> left, List<RawAstTree> right) {
        if (left.isEmpty()) {
            int distance = 0;
            for (RawAstTree tree : right) {
                distance += tree.size;
            }
            return distance;
        }
        if (right.isEmpty()) {
            int distance = 0;
            for (RawAstTree tree : left) {
                distance += tree.size;
            }
            return distance;
        }
        if (left.size() == 1 && right.size() == 1) {
            return rawAstTreeDistance(left.get(0), right.get(0));
        }

        int[] previous = new int[right.size() + 1];
        int[] current = new int[right.size() + 1];
        for (int j = 1; j <= right.size(); j++) {
            previous[j] = previous[j - 1] + right.get(j - 1).size;
        }
        for (int i = 1; i <= left.size(); i++) {
            current[0] = previous[0] + left.get(i - 1).size;
            for (int j = 1; j <= right.size(); j++) {
                int delete = previous[j] + left.get(i - 1).size;
                int insert = current[j - 1] + right.get(j - 1).size;
                int update = previous[j - 1] + rawAstTreeDistance(left.get(i - 1), right.get(j - 1));
                current[j] = Math.min(update, Math.min(delete, insert));
            }
            int[] swap = previous;
            previous = current;
            current = swap;
        }
        return previous[right.size()];
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
        if (Files.isRegularFile(root) && root.toString().endsWith(".als")) {
            files.add(root);
            return files;
        }
        try (java.util.stream.Stream<Path> stream = Files.walk(root)) {
            stream.filter(path -> Files.isRegularFile(path) && path.toString().endsWith(".als"))
                    .forEach(files::add);
        }
        files.sort(Comparator.comparing(Path::toString));
        return files;
    }

    private static String sanitize(String value) {
        return value.replaceAll("[^A-Za-z0-9_]", "_");
    }

    private static Writer outputWriter(Path path) throws IOException {
        return new BufferedWriter(
                new OutputStreamWriter(Files.newOutputStream(path), StandardCharsets.UTF_8),
                REPORT_BUFFER_SIZE);
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

    private static class Options {
        private Path inputDir = Paths.get(DEFAULT_INPUT);
        private Path outputDir = Paths.get(DEFAULT_OUTPUT);
        private int threadCount = DEFAULT_THREAD_COUNT;
        private int rewardPoolSize = DEFAULT_REWARD_POOL_SIZE;
        private int limit = -1;
        private boolean verbose;
        private boolean skipRewards;

        private static Options parse(String[] args) {
            Options options = new Options();
            int positional = 0;
            for (int i = 0; i < args.length; i++) {
                if ("--threads".equals(args[i]) && i + 1 < args.length) {
                    options.threadCount = Integer.parseInt(args[++i]);
                } else if ("--reward-pool".equals(args[i]) && i + 1 < args.length) {
                    options.rewardPoolSize = Integer.parseInt(args[++i]);
                } else if ("--limit".equals(args[i]) && i + 1 < args.length) {
                    options.limit = Integer.parseInt(args[++i]);
                } else if ("--skip-rewards".equals(args[i])) {
                    options.skipRewards = true;
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

    private static final class RawAstTree {
        private final String label;
        private final List<RawAstTree> children;
        private final int size;
        private final String fingerprint;

        private RawAstTree(String label, List<RawAstTree> children, int size, String fingerprint) {
            this.label = label;
            this.children = children;
            this.size = size;
            this.fingerprint = fingerprint;
        }

        private static RawAstTree from(Node node) {
            if (node == null) {
                return null;
            }
            String label = rawAstLabel(node);
            List<RawAstTree> children = new ArrayList<>(node.getChildren().size());
            int size = 1;
            StringBuilder fingerprint = new StringBuilder();
            appendFingerprintPart(fingerprint, label);
            fingerprint.append('[');
            for (Node childNode : node.getChildren()) {
                RawAstTree child = from(childNode);
                children.add(child);
                size += child.size;
                appendFingerprintPart(fingerprint, child.fingerprint);
            }
            fingerprint.append(']');
            return new RawAstTree(label, children, size, fingerprint.toString());
        }

        private static void appendFingerprintPart(StringBuilder target, String value) {
            target.append(value.length()).append(':').append(value);
        }
    }

    private static class ModelRecord {
        private final Path file;
        private final String fileName;
        private final String relativePath;
        private final String questionSet;
        private final String statusFolder;
        private final String invariantId;
        private String leftPredicate;
        private String rightPredicate;
        private String studentBody;
        private String oracleBody;
        private String prelude;
        private RawAstTree studentAst;
        private RawAstTree oracleAst;
        private Canonical.Prepared studentCanonical;
        private Canonical.Prepared oracleCanonical;
        private int levenshteinSize;
        private int rawAstSize;
        private int canonicalSize;
        private String error;

        private ModelRecord(Path root, Path file) {
            this.file = file;
            Path relative = root.relativize(file);
            this.fileName = file.getFileName().toString();
            this.relativePath = relative.toString().replace('\\', '/');
            this.questionSet = relative.getNameCount() > 0 ? relative.getName(0).toString() : "";
            this.statusFolder = DatasetConventions.normalizeStatusFolder(
                    relative.getNameCount() > 1 ? relative.getName(1).toString() : "");
            this.invariantId = preferredPredicateBase(file);
        }

        private static ModelRecord failed(Path root, Path file, String error) {
            ModelRecord record = new ModelRecord(root, file);
            record.error = error;
            return record;
        }

        private boolean success() {
            return error == null;
        }

        private String groupKey() {
            return questionSet + "/" + invariantId;
        }
    }

    private static class QuestionGroup {
        private final String questionSet;
        private final String invariantId;
        private final List<ModelRecord> records = new ArrayList<>();
        private final List<ModelRecord> correct = new ArrayList<>();
        private final List<ModelRecord> incorrect = new ArrayList<>();
        private final List<ModelRecord> failures = new ArrayList<>();
        private final List<Reference> references = new ArrayList<>();
        private int truthCandidateCount;
        private int astDuplicateTruthCount;

        private QuestionGroup(String questionSet, String invariantId) {
            this.questionSet = questionSet;
            this.invariantId = invariantId;
        }

        private void buildReferences(boolean verbose) {
            ModelRecord oracleSource = oracleSource();
            if (oracleSource == null) {
                releaseOracleRepresentations();
                return;
            }
            if (oracleSource.oracleCanonical == null) {
                oracleSource.oracleCanonical = loadCanonicalQuietly(oracleSource, true, verbose);
            }
            Reference oracle = new Reference(
                    invariantId + "_oracle",
                    "oracle",
                    oracleSource.oracleBody,
                    oracleSource.oracleAst,
                    oracleSource.oracleCanonical,
                    oracleSource);
            Set<String> fingerprints = new HashSet<>();
            truthCandidateCount++;
            addAstDistinctReference(oracle, fingerprints);
            int index = 0;
            for (ModelRecord record : correct) {
                truthCandidateCount++;
                Reference reference = new Reference(
                        invariantId + "_correct_" + index,
                        "correct-student",
                        record.studentBody,
                        record.studentAst,
                        record.studentCanonical,
                        record);
                if (addAstDistinctReference(reference, fingerprints)) {
                    index++;
                }
            }
            releaseCorrectRepresentations();
            releaseOracleRepresentations();
        }

        private boolean addAstDistinctReference(Reference reference, Set<String> fingerprints) {
            if (!fingerprints.add(reference.ast.fingerprint)) {
                astDuplicateTruthCount++;
                return false;
            }
            references.add(reference);
            return true;
        }

        private void releaseCorrectRepresentations() {
            for (ModelRecord record : correct) {
                record.studentAst = null;
                record.studentCanonical = null;
            }
        }

        private void releaseOracleRepresentations() {
            for (ModelRecord record : records) {
                record.oracleCanonical = null;
                record.oracleAst = null;
                record.oracleBody = null;
            }
        }

        private ModelRecord oracleSource() {
            if (!correct.isEmpty()) {
                return correct.get(0);
            }
            for (ModelRecord record : records) {
                if (record.success()) {
                    return record;
                }
            }
            return null;
        }

        private List<Reference> rankingReferences() {
            return references;
        }

        private String rankingMode() {
            return correct.isEmpty() ? "oracle-only" : "oracle+correct-student";
        }

        private String prelude() {
            if (!correct.isEmpty()) {
                return correct.get(0).prelude;
            }
            ModelRecord source = oracleSource();
            return source == null ? "module unknown\n" : source.prelude;
        }
    }

    private static class Reference {
        private final String augmentedName;
        private final String kind;
        private final String body;
        private final RawAstTree ast;
        private final Canonical.Prepared canonical;
        private final int canonicalSize;
        private final ModelRecord source;

        private Reference(
                String augmentedName,
                String kind,
                String body,
                RawAstTree ast,
                Canonical.Prepared canonical,
                ModelRecord source) {
            this.augmentedName = augmentedName;
            this.kind = kind;
            this.body = body;
            this.ast = ast;
            this.canonical = canonical;
            this.canonicalSize = Canonical.canonicalFormSize(canonical);
            this.source = source;
        }
    }

    private static class CorrectPoolPair {
        private final QuestionGroup group;
        private final Reference left;
        private final Reference right;
        private final int rawAstDistance;
        private final int canonicalDistance;

        private CorrectPoolPair(
                QuestionGroup group,
                Reference left,
                Reference right,
                int rawAstDistance,
                int canonicalDistance) {
            this.group = group;
            this.left = left;
            this.right = right;
            this.rawAstDistance = rawAstDistance;
            this.canonicalDistance = canonicalDistance;
        }
    }

    private static final class RepresentationKey {
        private final String context;
        private final String body;
        private final String astFingerprint;

        private RepresentationKey(String context, String body, String astFingerprint) {
            this.context = context;
            this.body = body;
            this.astFingerprint = astFingerprint;
        }

        private static RepresentationKey student(ModelRecord record) {
            return new RepresentationKey(
                    record.groupKey() + '\0' + record.prelude,
                    record.studentBody,
                    record.studentAst.fingerprint);
        }

        private static RepresentationKey oracle(ModelRecord record) {
            return new RepresentationKey(
                    record.groupKey() + '\0' + record.prelude,
                    record.oracleBody,
                    record.oracleAst.fingerprint);
        }

        @Override
        public boolean equals(Object other) {
            if (!(other instanceof RepresentationKey)) {
                return false;
            }
            RepresentationKey representation = (RepresentationKey) other;
            return context.equals(representation.context)
                    && body.equals(representation.body)
                    && astFingerprint.equals(representation.astFingerprint);
        }

        @Override
        public int hashCode() {
            int result = context.hashCode();
            result = 31 * result + body.hashCode();
            return 31 * result + astFingerprint.hashCode();
        }
    }

    private static final class RankingBatch {
        private final List<ModelRecord> records;
        private final IncorrectMatch template;

        private RankingBatch(List<ModelRecord> records, IncorrectMatch template) {
            this.records = records;
            this.template = template;
        }
    }

    private static class IncorrectMatch {
        private final ModelRecord record;
        private final Nearest levenshtein;
        private final Nearest rawAst;
        private final Nearest canonical;
        private int rewardPoolSize;
        private double candidateReward;
        private double rewardError;
        private boolean rewardComputed;
        private String rewardErrorMessage;

        private IncorrectMatch(ModelRecord record) {
            this.record = record;
            this.levenshtein = new Nearest();
            this.rawAst = new Nearest();
            this.canonical = new Nearest();
        }

        private IncorrectMatch(ModelRecord record, IncorrectMatch template) {
            this.record = record;
            this.levenshtein = template.levenshtein;
            this.rawAst = template.rawAst;
            this.canonical = template.canonical;
        }

        private void sortRankings() {
            levenshtein.sort();
            rawAst.sort();
            canonical.sort();
        }
    }

    private static class Nearest {
        private final List<RankedReference> ranking = new ArrayList<>();

        private void add(Reference candidate, int candidateDistance) {
            ranking.add(new RankedReference(candidate, candidateDistance));
        }

        private void sort() {
            ranking.sort(Comparator
                    .comparingInt((RankedReference ranked) -> ranked.distance)
                    .thenComparing(ranked -> ranked.reference.augmentedName)
                    .thenComparing(ranked -> ranked.reference.source.relativePath));
            int currentRank = 0;
            int previousDistance = Integer.MIN_VALUE;
            for (int i = 0; i < ranking.size(); i++) {
                RankedReference ranked = ranking.get(i);
                if (i == 0 || ranked.distance != previousDistance) {
                    currentRank = i + 1;
                    previousDistance = ranked.distance;
                }
                ranked.rank = currentRank;
            }
        }

        private RankedReference first() {
            return ranking.get(0);
        }
    }

    private static class RankedReference {
        private final Reference reference;
        private final int distance;
        private int rank;

        private RankedReference(Reference reference, int distance) {
            this.reference = reference;
            this.distance = distance;
        }
    }

    private static class QuestionSetStats {
        private final String questionSet;
        private int groups;
        private int correct;
        private int incorrect;
        private int references;
        private int rankedIncorrect;
        private int oracleOnlyGroups;

        private QuestionSetStats(String questionSet) {
            this.questionSet = questionSet;
        }
    }

    private static class CorrectTruthStats {
        private final String questionSet;
        private int correctPredicates;
        private int astDistinctPredicates;
        private int uniqueCanonicalForms;
        private int canonicalEquivalentPairs;

        private CorrectTruthStats(String questionSet) {
            this.questionSet = questionSet;
        }

        private void add(CorrectTruthStats other) {
            correctPredicates += other.correctPredicates;
            astDistinctPredicates += other.astDistinctPredicates;
            uniqueCanonicalForms += other.uniqueCanonicalForms;
            canonicalEquivalentPairs += other.canonicalEquivalentPairs;
        }
    }

    private static class RankingModeStats {
        private final String mode;
        private int groups;
        private int incorrect;
        private Integer minRefs;
        private Integer maxRefs;

        private RankingModeStats(String mode) {
            this.mode = mode;
        }

        private String minRefsMarkdown() {
            return minRefs == null ? "n/a" : minRefs.toString();
        }

        private String maxRefsMarkdown() {
            return maxRefs == null ? "n/a" : maxRefs.toString();
        }
    }

    private static class DistanceTableStats {
        private final DistanceStats overall =
                new DistanceStats("All problem classes", "All incorrectness classes");
        private final Map<String, DistanceStats> byProblemAndStatus = new java.util.TreeMap<>();

        private void add(IncorrectMatch match) {
            overall.add(match);
            String key = match.record.questionSet + '\0' + match.record.statusFolder;
            DistanceStats group = byProblemAndStatus.computeIfAbsent(
                    key,
                    ignored -> new DistanceStats(match.record.questionSet, match.record.statusFolder));
            group.add(match);
        }
    }

    private static class DistanceStats {
        private final String problemClass;
        private final String statusFolder;
        private int count;
        private long levenshteinSum;
        private long rawAstSum;
        private long canonicalSum;
        private double levenshteinRatioSum;
        private double rawAstRatioSum;
        private double canonicalRatioSum;

        private DistanceStats(String problemClass, String statusFolder) {
            this.problemClass = problemClass;
            this.statusFolder = statusFolder;
        }

        private void add(IncorrectMatch match) {
            count++;
            levenshteinSum += match.levenshtein.first().distance;
            rawAstSum += match.rawAst.first().distance;
            canonicalSum += match.canonical.first().distance;
            levenshteinRatioSum += ratio(match.levenshtein.first().distance, match.record.levenshteinSize);
            rawAstRatioSum += ratio(match.rawAst.first().distance, match.record.rawAstSize);
            canonicalRatioSum += ratio(match.canonical.first().distance, match.record.canonicalSize);
        }

        private double averageLevenshtein() {
            return count == 0 ? 0.0 : (double) levenshteinSum / count;
        }

        private double averageRawAst() {
            return count == 0 ? 0.0 : (double) rawAstSum / count;
        }

        private double averageCanonical() {
            return count == 0 ? 0.0 : (double) canonicalSum / count;
        }

        private double averageLevenshteinRatio() {
            return count == 0 ? 0.0 : levenshteinRatioSum / count;
        }

        private double averageRawAstRatio() {
            return count == 0 ? 0.0 : rawAstRatioSum / count;
        }

        private double averageCanonicalRatio() {
            return count == 0 ? 0.0 : canonicalRatioSum / count;
        }
    }

    private static class RepairRadiusStats {
        private final String label;
        private int count;
        private final int[] rawAstWithin = new int[REPAIR_RADII.length];
        private final int[] canonicalWithin = new int[REPAIR_RADII.length];
        private final int[] levenshteinRelativeWithin = new int[RELATIVE_REPAIR_RADII.length];
        private final int[] rawAstRelativeWithin = new int[RELATIVE_REPAIR_RADII.length];
        private final int[] canonicalRelativeWithin = new int[RELATIVE_REPAIR_RADII.length];

        private RepairRadiusStats(String label) {
            this.label = label;
        }

        private void add(IncorrectMatch match) {
            count++;
            int levenshteinDistance = match.levenshtein.first().distance;
            int rawAstDistance = match.rawAst.first().distance;
            int canonicalDistance = match.canonical.first().distance;
            double levenshteinRatio = ratio(levenshteinDistance, match.record.levenshteinSize);
            double rawAstRatio = ratio(rawAstDistance, match.record.rawAstSize);
            double canonicalRatio = ratio(canonicalDistance, match.record.canonicalSize);
            for (int i = 0; i < REPAIR_RADII.length; i++) {
                if (rawAstDistance <= REPAIR_RADII[i]) {
                    rawAstWithin[i]++;
                }
                if (canonicalDistance <= REPAIR_RADII[i]) {
                    canonicalWithin[i]++;
                }
            }
            for (int i = 0; i < RELATIVE_REPAIR_RADII.length; i++) {
                if (levenshteinRatio <= RELATIVE_REPAIR_RADII[i]) {
                    levenshteinRelativeWithin[i]++;
                }
                if (rawAstRatio <= RELATIVE_REPAIR_RADII[i]) {
                    rawAstRelativeWithin[i]++;
                }
                if (canonicalRatio <= RELATIVE_REPAIR_RADII[i]) {
                    canonicalRelativeWithin[i]++;
                }
            }
        }
    }

    private static class RepairRatioRegressionStats {
        private int count;
        private double xSum;
        private double ySum;
        private double xxSum;
        private double yySum;
        private double xySum;

        private void add(double size, double ratio) {
            count++;
            xSum += size;
            ySum += ratio;
            xxSum += size * size;
            yySum += ratio * ratio;
            xySum += size * ratio;
        }

        private double slope() {
            if (count < 2) {
                return 0.0;
            }
            double denominator = count * xxSum - xSum * xSum;
            if (denominator == 0.0) {
                return 0.0;
            }
            return (count * xySum - xSum * ySum) / denominator;
        }

        private double intercept() {
            if (count == 0) {
                return 0.0;
            }
            return (ySum / count) - slope() * (xSum / count);
        }

        private double correlation() {
            if (count < 2) {
                return 0.0;
            }
            double numerator = count * xySum - xSum * ySum;
            double xDenominator = count * xxSum - xSum * xSum;
            double yDenominator = count * yySum - ySum * ySum;
            if (xDenominator <= 0.0 || yDenominator <= 0.0) {
                return 0.0;
            }
            return numerator / Math.sqrt(xDenominator * yDenominator);
        }
    }

    private static class RewardDistanceStats {
        private int count;
        private double xSum;
        private double ySum;
        private double xxSum;
        private double yySum;
        private double xySum;
        private double logYSum;
        private double logYYSum;
        private double xLogYSum;

        private void add(double distance, double rewardError, double floor) {
            double logRewardError = Math.log10(Math.max(rewardError, floor));
            count++;
            xSum += distance;
            ySum += rewardError;
            xxSum += distance * distance;
            yySum += rewardError * rewardError;
            xySum += distance * rewardError;
            logYSum += logRewardError;
            logYYSum += logRewardError * logRewardError;
            xLogYSum += distance * logRewardError;
        }

        private double rawCorrelation() {
            return correlation(count, xSum, ySum, xxSum, yySum, xySum);
        }

        private double logCorrelation() {
            return correlation(count, xSum, logYSum, xxSum, logYYSum, xLogYSum);
        }

        private static double correlation(
                int count,
                double xSum,
                double ySum,
                double xxSum,
                double yySum,
                double xySum) {
            if (count < 2) {
                return 0.0;
            }
            double numerator = count * xySum - xSum * ySum;
            double xDenominator = count * xxSum - xSum * xSum;
            double yDenominator = count * yySum - ySum * ySum;
            if (xDenominator <= 0.0 || yDenominator <= 0.0) {
                return 0.0;
            }
            return numerator / Math.sqrt(xDenominator * yDenominator);
        }
    }

    private static class Summary {
        private int groups;
        private int parsedModels;
        private int parseFailures;
        private int correctModels;
        private int incorrectModels;
        private int oracleReferences;
        private int uniqueCorrectStudentReferences;

        private int incorrectModelsWithoutCorrectReference;
        private int rewardSuccesses;
        private int rewardFailures;
        private double candidateRewardSum;
        private double rewardErrorSum;

        private Summary(
                Map<String, QuestionGroup> groups,
                List<ModelRecord> records,
                List<IncorrectMatch> matches,
                List<ModelRecord> unmatched) {
            this.groups = groups.size();
            this.incorrectModelsWithoutCorrectReference = unmatched.size();
            for (IncorrectMatch match : matches) {
                if (!match.rewardComputed) {
                    continue;
                }
                if (match.rewardErrorMessage == null) {
                    rewardSuccesses++;
                    candidateRewardSum += match.candidateReward;
                    rewardErrorSum += match.rewardError;
                } else {
                    rewardFailures++;
                }
            }
            for (ModelRecord record : records) {
                if (record.success()) {
                    parsedModels++;
                    if ("CORRECT".equals(record.statusFolder)) {
                        correctModels++;
                    } else {
                        incorrectModels++;
                    }
                } else {
                    parseFailures++;
                }
            }
            for (QuestionGroup group : groups.values()) {
                for (Reference reference : group.references) {
                    if ("oracle".equals(reference.kind)) {
                        oracleReferences++;
                    } else {
                        uniqueCorrectStudentReferences++;
                    }
                }
            }
        }

        private double averageCandidateReward() {
            return rewardSuccesses == 0 ? 0.0 : candidateRewardSum / rewardSuccesses;
        }

        private double averageRewardError() {
            return rewardSuccesses == 0 ? 0.0 : rewardErrorSum / rewardSuccesses;
        }
    }
}
