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
import parser.etc.Pair;
import parser.util.AlloyUtil;

public class Alloy4FunAugmenter {
    private static final String DEFAULT_INPUT = "classified-data";
    private static final String DEFAULT_OUTPUT = "alloy4fun-augmented";
    private static final int DEFAULT_THREAD_COUNT = 32;
    private static final int DEFAULT_REWARD_POOL_SIZE = 1000;

    public static void main(String[] args) throws IOException {
        System.setProperty("org.slf4j.simpleLogger.defaultLogLevel", "error");
        Options options = Options.parse(args);
        Files.createDirectories(options.outputDir);
        List<Path> files = alloyFiles(options.inputDir);
        if (options.limit > 0 && options.limit < files.size()) {
            files = new ArrayList<>(files.subList(0, options.limit));
        }

        List<ModelRecord> records = parseRecords(files, options);
        Map<String, QuestionGroup> groups = groups(records);
        for (QuestionGroup group : groups.values()) {
            group.buildReferences();
        }
        writeAugmentedFiles(groups, options.outputDir);
        List<IncorrectMatch> matches = nearestIncorrectMatches(groups, options);
        if (!options.skipRewards) {
            computeRewards(matches, options);
        }
        List<ModelRecord> unmatched = incorrectWithoutReference(groups);
        writeJson(options.outputDir.resolve("index.json"), options, files.size(), groups, records, matches, unmatched);
        writeMarkdown(options.outputDir.resolve("summary.md"), options, files.size(), groups, records, matches, unmatched);
        writeRewardCsv(options.outputDir.resolve("canonical_reward_points.csv"), matches);
        writeRewardPlots(options.outputDir, matches);
        writePlotScript(options.outputDir.resolve("plot_canonical_rewards.py"));
        System.out.println("Wrote " + options.outputDir);
        System.out.println("Wrote " + options.outputDir.resolve("index.json"));
        System.out.println("Wrote " + options.outputDir.resolve("summary.md"));
        System.out.println("Wrote " + options.outputDir.resolve("canonical_reward_points.csv"));
        System.out.println("Wrote " + options.outputDir.resolve("canonical_distance_vs_reward_error_raw.svg"));
        System.out.println("Wrote " + options.outputDir.resolve("canonical_distance_vs_reward_error_log.svg"));
        System.out.println("Wrote " + options.outputDir.resolve("plot_canonical_rewards.py"));
    }

    private static List<ModelRecord> parseRecords(List<Path> files, Options options) {
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
            List<Future<ModelRecord>> futures = new ArrayList<>(files.size());
            for (Path file : files) {
                futures.add(executor.submit(() -> parseRecord(options.inputDir, file, options.verbose)));
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
            for (int i = 0; i < records.size(); i++) {
                if (!records.get(i).success()) {
                    ModelRecord retry = parseRecord(options.inputDir, files.get(i), options.verbose);
                    if (retry.success()) {
                        records.set(i, retry);
                    }
                }
            }
            return records;
        } finally {
            executor.shutdownNow();
            if (!options.verbose) {
                System.setOut(originalOut);
                System.setErr(originalErr);
            }
        }
    }

    private static ModelRecord parseRecord(Path inputRoot, Path file, boolean verbose) {
        ModelRecord record = new ModelRecord(inputRoot, file);
        try {
            CompModule module = AlloyUtil.compileAlloyModule(file.toString());
            ModelUnit model = new ModelUnit(null, module);
            PredicatePair pair = findPredicatePair(file, model);
            if (pair == null) {
                record.error = "No predicate pair of the form X and XC found.";
                return record;
            }
            record.leftPredicate = pair.leftName;
            record.rightPredicate = pair.rightName;
            record.studentBody = predicateBody(file, pair.leftName, pair.left);
            record.oracleBody = predicateBody(file, pair.rightName, pair.right);
            record.levenshteinSize = record.studentBody.length();
            record.prelude = preludeBeforePredicate(Files.readString(file, StandardCharsets.UTF_8), pair.leftName);
            record.studentAst = pair.left.getBody();
            record.oracleAst = pair.right.getBody();
            record.rawAstSize = rawAstSize(record.studentAst);

            MASGVisitor visitor = new MASGVisitor(new GlobalVariables());
            visitor.visit(model, null);
            DoubleMap<Integer, Multigraph> forest = visitor.getForest();
            record.studentGraph = forest.get(pair.leftId);
            record.oracleGraph = forest.get(pair.rightId);
            if (record.studentGraph == null || record.oracleGraph == null) {
                record.error = "Could not find both predicate graphs in MASG forest.";
            } else {
                record.canonicalSize = Canonical.canonicalFormSize(record.studentGraph);
            }
        } catch (Throwable t) {
            if (verbose) {
                t.printStackTrace(System.err);
            }
            record.error = t.getClass().getSimpleName() + ": " + t.getMessage();
        }
        return record;
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
        List<Callable<List<IncorrectMatch>>> tasks = new ArrayList<>();
        for (QuestionGroup group : groups.values()) {
            tasks.add(() -> {
                List<IncorrectMatch> matches = new ArrayList<>();
                if (group.rankingReferences().isEmpty()) {
                    return matches;
                }
                for (ModelRecord incorrect : group.incorrect) {
                    matches.add(nearestIncorrectMatch(group, incorrect));
                }
                return matches;
            });
        }
        ExecutorService executor = Executors.newFixedThreadPool(Math.max(1, options.threadCount));
        try {
            List<Future<List<IncorrectMatch>>> futures = new ArrayList<>(tasks.size());
            for (Callable<List<IncorrectMatch>> task : tasks) {
                futures.add(executor.submit(task));
            }
            List<IncorrectMatch> matches = new ArrayList<>();
            for (Future<List<IncorrectMatch>> future : futures) {
                try {
                    matches.addAll(future.get());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                } catch (ExecutionException ignored) {
                }
            }
            matches.sort(Comparator.comparing((IncorrectMatch match) -> match.record.relativePath));
            return matches;
        } finally {
            executor.shutdownNow();
        }
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
        IncorrectMatch match = new IncorrectMatch(incorrect);
        for (Reference reference : group.rankingReferences()) {
            int levenshtein = levenshteinDistance(incorrect.studentBody, reference.body);
            int rawAst = rawAstTreeDistance(incorrect.studentAst, reference.ast);
            int canonical = Canonical.distance(incorrect.studentGraph, reference.graph);
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
            try (Writer writer = Files.newBufferedWriter(file, StandardCharsets.UTF_8)) {
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

    private static void writeJson(
            Path path,
            Options options,
            int fileCount,
            Map<String, QuestionGroup> groups,
            List<ModelRecord> records,
            List<IncorrectMatch> matches,
            List<ModelRecord> unmatched) throws IOException {
        Summary summary = new Summary(groups, records, matches, unmatched);
        try (Writer writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
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
            List<ModelRecord> unmatched) throws IOException {
        Summary summary = new Summary(groups, records, matches, unmatched);
        Map<String, QuestionSetStats> questionStats = questionSetStats(groups, matches);
        Map<String, RankingModeStats> modeStats = rankingModeStats(groups);
        DistanceStats allDistances = distanceStats(matches);
        Map<String, DistanceStats> statusDistances = statusDistanceStats(matches);

        try (Writer writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
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

            writer.write("## Ranking Pools\n\n");
            writer.write("| Mode | Groups | Incorrect predicates | Min refs | Max refs |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: |\n");
            for (RankingModeStats stats : modeStats.values()) {
                writer.write("| " + stats.mode + " | " + stats.groups + " | " + stats.incorrect + " | "
                        + stats.minRefsMarkdown() + " | " + stats.maxRefsMarkdown() + " |\n");
            }
            writer.write("\n");

            writer.write("## Nearest Distance Averages\n\n");
            writer.write("| Slice | Count | Levenshtein | Raw AST | Canonical |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: |\n");
            writer.write("| All incorrect | " + allDistances.count + " | " + number(allDistances.averageLevenshtein())
                    + " | " + number(allDistances.averageRawAst()) + " | "
                    + number(allDistances.averageCanonical()) + " |\n");
            for (DistanceStats stats : statusDistances.values()) {
                writer.write("| " + stats.label + " | " + stats.count + " | "
                        + number(stats.averageLevenshtein()) + " | " + number(stats.averageRawAst())
                        + " | " + number(stats.averageCanonical()) + " |\n");
            }
            writer.write("\n");

            writer.write("## Relative Distance Averages\n\n");
            writer.write("| Slice | Count | Levenshtein / body chars | Raw AST / AST size | Canonical / canonical size |\n");
            writer.write("| --- | ---: | ---: | ---: | ---: |\n");
            writer.write("| All incorrect | " + allDistances.count + " | "
                    + number(allDistances.averageLevenshteinRatio()) + " | "
                    + number(allDistances.averageRawAstRatio()) + " | "
                    + number(allDistances.averageCanonicalRatio()) + " |\n");
            for (DistanceStats stats : statusDistances.values()) {
                writer.write("| " + stats.label + " | " + stats.count + " | "
                        + number(stats.averageLevenshteinRatio()) + " | "
                        + number(stats.averageRawAstRatio()) + " | "
                        + number(stats.averageCanonicalRatio()) + " |\n");
            }
            writer.write("\n");

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

    private static void writeGroupJson(Writer writer, QuestionGroup group) throws IOException {
        writer.write("    {\n");
        writer.write("      \"questionSet\": \"" + escape(group.questionSet) + "\",\n");
        writer.write("      \"invariantId\": \"" + escape(group.invariantId) + "\",\n");
        writer.write("      \"augmentedFile\": \"" + escape("correct/" + group.questionSet + "/" + group.invariantId + ".als") + "\",\n");
        writer.write("      \"correctCount\": " + group.correct.size() + ",\n");
        writer.write("      \"incorrectCount\": " + group.incorrect.size() + ",\n");
        writer.write("      \"parseFailureCount\": " + group.failures.size() + ",\n");
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
        try (Writer writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
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
        try (Writer writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
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

    private static void writePlotScript(Path path) throws IOException {
        try (Writer writer = Files.newBufferedWriter(path, StandardCharsets.UTF_8)) {
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
            writer.write("with CSV.open() as f:\n");
            writer.write("    rows = [r for r in csv.DictReader(f) if r.get('candidateReward')]\n");
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

    private static DistanceStats distanceStats(List<IncorrectMatch> matches) {
        DistanceStats stats = new DistanceStats("All incorrect");
        for (IncorrectMatch match : matches) {
            stats.add(match);
        }
        return stats;
    }

    private static Map<String, DistanceStats> statusDistanceStats(List<IncorrectMatch> matches) {
        Map<String, DistanceStats> stats = new java.util.TreeMap<>();
        for (IncorrectMatch match : matches) {
            DistanceStats statusStats = stats.computeIfAbsent(
                    match.record.statusFolder,
                    DistanceStats::new);
            statusStats.add(match);
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
        private Node studentAst;
        private Node oracleAst;
        private Multigraph studentGraph;
        private Multigraph oracleGraph;
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
            this.statusFolder = relative.getNameCount() > 1 ? relative.getName(1).toString() : "";
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
        private final List<Reference> correctStudentReferences = new ArrayList<>();
        private final List<Reference> oracleReferences = new ArrayList<>();

        private QuestionGroup(String questionSet, String invariantId) {
            this.questionSet = questionSet;
            this.invariantId = invariantId;
        }

        private void buildReferences() {
            ModelRecord oracleSource = oracleSource();
            if (oracleSource == null) {
                return;
            }
            Reference oracle = new Reference(
                    invariantId + "_oracle",
                    "oracle",
                    oracleSource.oracleBody,
                    oracleSource.oracleAst,
                    oracleSource.oracleGraph,
                    oracleSource);
            references.add(oracle);
            oracleReferences.add(oracle);
            int index = 0;
            for (ModelRecord record : correct) {
                boolean duplicate = false;
                for (Reference reference : correctStudentReferences) {
                    if (rawAstTreeDistance(record.studentAst, reference.ast) == 0) {
                        duplicate = true;
                        break;
                    }
                }
                if (!duplicate) {
                    Reference reference = new Reference(
                            invariantId + "_correct_" + index++,
                            "correct-student",
                            record.studentBody,
                            record.studentAst,
                            record.studentGraph,
                            record);
                    references.add(reference);
                    correctStudentReferences.add(reference);
                }
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
            return correctStudentReferences.isEmpty() ? "oracle-only" : "oracle+correct-student";
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
        private final Node ast;
        private final Multigraph graph;
        private final ModelRecord source;

        private Reference(String augmentedName, String kind, String body, Node ast, Multigraph graph, ModelRecord source) {
            this.augmentedName = augmentedName;
            this.kind = kind;
            this.body = body;
            this.ast = ast;
            this.graph = graph;
            this.source = source;
        }
    }

    private static class IncorrectMatch {
        private final ModelRecord record;
        private final Nearest levenshtein = new Nearest();
        private final Nearest rawAst = new Nearest();
        private final Nearest canonical = new Nearest();
        private int rewardPoolSize;
        private double candidateReward;
        private double rewardError;
        private boolean rewardComputed;
        private String rewardErrorMessage;

        private IncorrectMatch(ModelRecord record) {
            this.record = record;
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

    private static class DistanceStats {
        private final String label;
        private int count;
        private long levenshteinSum;
        private long rawAstSum;
        private long canonicalSum;
        private double levenshteinRatioSum;
        private double rawAstRatioSum;
        private double canonicalRatioSum;

        private DistanceStats(String label) {
            this.label = label;
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
