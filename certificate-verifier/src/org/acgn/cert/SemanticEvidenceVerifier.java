package org.acgn.cert;

import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.ArrayDeque;
import java.util.Base64;
import java.util.Collections;
import java.util.Comparator;
import java.util.Deque;
import java.util.HexFormat;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/** Independent verifier for the exact Alloy semantic-evidence ledger. */
final class SemanticEvidenceVerifier {
    private static final String EMPTY_RELATION_PREFIX =
            "AlloyEmptyRelation$arity=";
    private static final String FIXED_ALLOY_TEMPORAL_MODE = "alloy-temporal";
    private static final String FIXED_ALLOY_REWRITE_MODE =
            "repaired-normal-form-v2";
    private static final String FIXED_ALLOY_SIGNATURE_VERSION =
            "alloy-signature-v2";
    private static final String SOURCE_COMMAND_CONTEXT_TAG =
            "alloy-source-command-context-v1";
    private static final String SOURCE_COMMAND_CONTEXT_VERSION =
            "alloy-command-options-v2";
    private static final String CALL_OCCURRENCE_ANCHOR_PREFIX =
            "ACGN/CALL-OCCURRENCE/";
    private static final String PRODUCTION_ALLOY_REWRITE_MODE =
            "repaired-normal-form-v3;typed-alloy-normal-form-adapter-v11";
    private static final String PRODUCTION_ALLOY_SIGNATURE_VERSION =
            "canonical-alloy-signature-v7";
    private static final String REGISTRY_VERSION = "alloy-container-law-theory-v2";
    private static final String REGISTRY_TEXT = String.join("\n",
            "AND:Set+:A,C,I",
            "OR:Set+:A,C,I",
            "PLUS:Set+:A,C,I",
            "INTERSECT:Set+:A,C,I",
            "IPLUS:forbid=Bag2:C;modular=Bag+:A,C",
            "MUL:forbid=Bag2:C;modular=Bag+:A,C",
            "EQUALS:Bag2:C",
            "NOT_EQUALS:Bag2:C",
            "IFF:Bag2:C",
            "DISJOINT:Bag+:C");
    private static final String REGISTRY_DIGEST = sha256(
            REGISTRY_VERSION + "\n" + REGISTRY_TEXT);
    private static final String DEPENDENT_CHAIN_VERSION =
            "alloy-dependent-chain-theory-v10";
    private static final String DEPENDENT_CHAIN_TEXT = String.join("\n",
            "FAMILY:finite-union-of-correlated-ordered-products;normalized=subtype-antichain",
            "DAG:edges=specific-to-general;synthetic-union-and-common-ancestor-nodes-are-not-nominal-authority",
            "UNION:retain-correlation;deduplicate;absorb-only-authenticated-componentwise-subtypes",
            "INTERSECTION:pairwise-product-meet;omit-only-authenticated-disjoint-PrimSig-branches",
            "SET-DERIVATION:source UNION and INTERSECTION DAGs are recursively derived before parser-result equality",
            "JOIN:ordered;complete-alternative-pair-matrix;overlap=exact-or-one-endpoint-on-parser-derived-PrimSig-parent-path;result=init(left)++tail(right)",
            "ARROW:ordered;complete-cartesian-product;result=columns(left)++columns(right)",
            "SUBTYPE:path starts at exact AlloySig carrier, including parser-provided univ;edges are direct PrimSig parents;witness ends at opposite boundary",
            "SUBTYPE-HIERARCHY:single-parent;acyclic;univ-terminal;independent-verification-requires-external-source-hierarchy-authority",
            "DISJOINT:two distinct authenticated PrimSig branches with first common ancestor;univ-commonality-never-implies-overlap",
            "AUTHORITY:one-complete-nominal-path-per-top;one-live-parser-module-per-chain",
            "JOIN-FLAT-GUARD:every interior source operand has retained relation arity at least two, including typed-empty families",
            "LEAF:exact correlated relation family or Int/AlloyCarrier primitive singleton;no-name-based-parameter-authority",
            "UNIV:explicit parser-provided AlloySig:univ is an exact carrier;absent-or-unresolved-types-never-invent-univ",
            "EMPTY:positive-arity typed empty family has zero alternatives;all-disjoint JOIN retains complete evidence and ordered Seq",
            "CONTAINER:ordered-duplicate-preserving-Seq",
            "laws=guarded-associativity-only;no-commutativity;no-idempotency;no-unit");
    private static final String DEPENDENT_CHAIN_DIGEST = sha256(
            DEPENDENT_CHAIN_VERSION + "\n" + DEPENDENT_CHAIN_TEXT);
    private static final String ZERO_SHA256 = "0".repeat(64);
    private static final String POLYMORPHIC_OPERATOR_KEY_PREFIX =
            "operator/polymorphic-key-v1/";
    private static final String PRODUCER_ORBIT_SOURCE_MARKER =
            "producer-orbit-source-v1";
    private static final List<String> EMPTY_TEST_SCALARS = List.of(
            "4",
            "FORBID",
            "test-only-temporal",
            "test-only-rewrite",
            "test-only-signature",
            ZERO_SHA256,
            "test-only-law-theory-v1",
            ZERO_SHA256);
    private static final Set<String> KNOWN_OPERATORS = Set.of(
            "AND", "OR", "PLUS", "INTERSECT", "IPLUS", "MUL",
            "EQUALS", "NOT_EQUALS", "IFF", "DISJOINT");

    static boolean isAdmittedAtomicChainColumn(
            String kind,
            String symbol,
            int argumentCount) {
        if (argumentCount != 0) {
            return false;
        }
        if ("INT".equals(kind)) {
            return true;
        }
        return "CONSTRUCTOR".equals(kind)
                && symbol != null
                && symbol.startsWith("AlloySig:")
                && hasAdmittedAlloySignatureIdentity(symbol);
    }

    private static boolean hasAdmittedAlloySignatureIdentity(String symbol) {
        String identity = symbol.substring("AlloySig:".length());
        return isAdmittedIdentity(identity) && !identity.startsWith("this/");
    }

    static boolean isAdmittedIdentity(String identity) {
        return identity != null
                && !identity.isEmpty()
                && identity.codePoints().noneMatch(
                SemanticEvidenceVerifier::isForbiddenIdentityCodePoint);
    }

    private static boolean isForbiddenIdentityCodePoint(int codePoint) {
        int type = Character.getType(codePoint);
        return Character.isWhitespace(codePoint)
                || Character.isSpaceChar(codePoint)
                || Character.isISOControl(codePoint)
                || type == Character.FORMAT
                || type == Character.SURROGATE
                || type == Character.PRIVATE_USE
                || type == Character.UNASSIGNED;
    }

    private final Bundle bundle;
    private final KernelModel model;
    private final Limits limits;
    private long parsedKeyNodes;

    SemanticEvidenceVerifier(Bundle bundle, KernelModel model, Limits limits) {
        this.bundle = Objects.requireNonNull(bundle, "bundle");
        this.model = Objects.requireNonNull(model, "model");
        this.limits = Objects.requireNonNull(limits, "limits");
    }

    Authorization verify() {
        Wire.Node evidence = bundle.semanticEvidence().requireShape(
                "semantic-evidence", 8, 6);
        requireSection(evidence.child(0), "law-certificates");
        requireSection(evidence.child(1), "flat-constructions");
        requireSection(evidence.child(2), "container-constructions");
        requireSection(evidence.child(3), "binder-occurrences");
        requireSection(evidence.child(4), "exact-types");
        requireSection(evidence.child(5), "call-occurrences");

        if (bundle.metadata().mode().equals("TEST_ONLY")
                && isExactEmptyTestFixture(evidence)) {
            return Authorization.testOnlyFixture();
        }

        boolean testOnly = bundle.metadata().mode().equals("TEST_ONLY");
        ProfileEvidence profile = verifyAuthorizedProfile(evidence, testOnly);
        requireCanonicalEvidenceOrder(evidence.child(1), "flat construction");
        requireCanonicalEvidenceOrder(evidence.child(2), "container construction");
        requireCanonicalEvidenceOrder(evidence.child(3), "binder occurrence");
        requireCanonicalEvidenceOrder(evidence.child(5), "call occurrence");
        TypeLedger exactTypes = parseExactTypes(evidence.child(4));
        verifyCallOccurrences(evidence.child(5));
        requireModelTypeCoverage(exactTypes, !testOnly);
        LawLedger laws = verifyLaws(
                evidence.child(0), profile, exactTypes, !testOnly);
        SemanticReplay replay = new SemanticReplay(
                profile, exactTypes, laws, !testOnly);
        replay.verify(evidence.child(1), evidence.child(2), evidence.child(3));
        replay.verifyProducerOrbitOrders();
        return Authorization.checked(
                model,
                laws.byOperatorPath(),
                replay::canonicalShapeKey,
                replay.orbitComparisonKeys,
                replay.orbitRepresentativeKeys);
    }

    private void verifyCallOccurrences(Wire.Node section) {
        if (section.children().size() > limits.maxTableEntries()) {
            throw resource("call occurrence table exceeds its configured bound");
        }
        Set<Long> occurrenceIds = new HashSet<>();
        Set<String> sourcePaths = new HashSet<>();
        Set<String> coveredCallOperators = new HashSet<>();
        Map<String, KernelModel.Term> coveredOccurrenceAnchors = new HashMap<>();
        for (Wire.Node record : section.children()) {
            record.requireTag("call-occurrence");
            if (record.scalars().size() != 9) {
                throw malformed("call occurrence record");
            }
            StableKey suppliedKey = parseStableKey(
                    record.scalar(0), "call occurrence structural key");
            long occurrenceId = parseNonnegativeLong(
                    record.scalar(1), "call occurrence id");
            String sourcePath = requireCanonicalIdentity(
                    record.scalar(2), "call occurrence source path");
            String sourceName = requireCanonicalIdentity(
                    record.scalar(3), "call occurrence source spelling");
            String callee = requireCanonicalIdentity(
                    record.scalar(4), "call occurrence qualified callee");
            int separator = callee.lastIndexOf('/');
            if (separator <= 0 || separator + 1 >= callee.length()) {
                throw theory("CALL occurrence has unqualified callee identity");
            }
            String kind = record.scalar(5);
            if (!kind.equals("call/formula") && !kind.equals("call/expression")) {
                throw theory("CALL occurrence has invalid formula/expression kind");
            }
            int arity = parseNonnegativeInt(record.scalar(6), "CALL declared arity");
            String authority = record.scalar(7);
            if (!authority.equals("DECLARATION")
                    && !authority.equals("TYPECHECKED_IMPORT")) {
                throw theory("CALL occurrence has invalid arity authority");
            }
            KernelModel.Term source = model.term(record.scalar(8));
            if (source.kind() != KernelModel.TermKind.APP) {
                throw theory("CALL occurrence endpoint is not an application term");
            }
            KernelModel.Operator operator = model.operator(source.symbol());
            coveredCallOperators.add(operator.semanticIdentity());
            String expectedOperator = "ALLOY/CALL/" + callee + "/" + arity
                    + "/" + kind + "/" + authority;
            if (!expectedOperator.equals(operator.semanticIdentity())
                    || source.children().size() != arity
                    || record.children().size() != arity) {
                throw theory("CALL occurrence endpoint disagrees with its declaration");
            }
            List<StableKey> argumentKeys = new ArrayList<>(arity);
            for (int role = 0; role < arity; role++) {
                Wire.Node argument = record.child(role).requireShape(
                        "call-argument", 2, 0);
                if (!argument.scalar(0).equals(Integer.toString(role))
                        || !argument.scalar(1).equals(source.children().get(role))) {
                    throw theory("CALL occurrence argument role/order mismatch");
                }
                KernelModel.Term endpoint = model.term(argument.scalar(1));
                argumentKeys.add(StableKey.of(
                        "alloy-call-wire-argument-v1",
                        List.of(Integer.toString(role), endpoint.id()),
                        List.of()));
            }
            StableKey expectedKey = StableKey.of(
                    "alloy-call-wire-occurrence-v1",
                    List.of(
                            Long.toString(occurrenceId),
                            sourcePath,
                            sourceName,
                            callee,
                            kind,
                            Integer.toString(arity),
                            authority),
                    List.of(
                            StableKey.of(
                                    "alloy-call-wire-source-term-v1",
                                    List.of(source.id()),
                                    List.of()),
                            StableKey.of(
                                    "alloy-call-wire-ordered-arguments-v1",
                                    List.of(),
                                    argumentKeys)));
            if (!suppliedKey.equals(expectedKey)) {
                throw theory("CALL occurrence structural key does not replay");
            }
            String anchorIdentity = CALL_OCCURRENCE_ANCHOR_PREFIX
                    + Base64.getUrlEncoder().withoutPadding().encodeToString(
                            expectedKey.stableString().getBytes(
                                    StandardCharsets.UTF_8));
            if (coveredOccurrenceAnchors.put(anchorIdentity, source) != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "CALL occurrence anchor is duplicated");
            }
            if (!occurrenceIds.add(occurrenceId) || !sourcePaths.add(sourcePath)) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "CALL occurrence id/path is duplicated");
            }
        }
        Set<String> requiredCallOperators = new HashSet<>();
        Map<String, KernelModel.Term> requiredOccurrenceAnchors = new HashMap<>();
        for (Map.Entry<String, KernelModel.Term> entry : model.terms().entrySet()) {
            KernelModel.Term term = entry.getValue();
            if (term.kind() != KernelModel.TermKind.APP) {
                continue;
            }
            KernelModel.Operator operator = model.operator(term.symbol());
            String identity = operator.semanticIdentity();
            if (identity.startsWith("ALLOY/CALL/")) {
                requiredCallOperators.add(identity);
            } else if (identity.startsWith(CALL_OCCURRENCE_ANCHOR_PREFIX)) {
                String encoded = identity.substring(
                        CALL_OCCURRENCE_ANCHOR_PREFIX.length());
                byte[] decoded;
                try {
                    decoded = Base64.getUrlDecoder().decode(encoded);
                } catch (IllegalArgumentException exception) {
                    throw theory("CALL occurrence anchor is not canonical Base64");
                }
                if (decoded.length > limits.maxStringBytes()
                        || !encoded.equals(Base64.getUrlEncoder().withoutPadding()
                                .encodeToString(decoded))
                        || !term.children().isEmpty()
                        || !operator.schemas().isEmpty()
                        || !operator.flatPath().equals("none")) {
                    throw theory("CALL occurrence anchor is malformed");
                }
                decodeCanonicalUtf8(decoded, "CALL occurrence anchor");
                if (requiredOccurrenceAnchors.put(identity, term) != null) {
                    throw new FormatException(
                            FailureCode.DUPLICATE_ID,
                            "CALL occurrence anchor term is duplicated");
                }
            }
        }
        if (!requiredCallOperators.equals(coveredCallOperators)) {
            throw new FormatException(
                    FailureCode.MISSING_EVIDENCE,
                    "CALL application operators and occurrence evidence differ");
        }
        if (!requiredOccurrenceAnchors.keySet().equals(
                coveredOccurrenceAnchors.keySet())) {
            throw new FormatException(
                    FailureCode.MISSING_EVIDENCE,
                    "CALL occurrence anchors and occurrence evidence differ");
        }
        Map<String, Integer> anchorReferences = scalarReferenceCounts(
                requiredOccurrenceAnchors.values().stream()
                        .map(KernelModel.Term::id)
                        .collect(java.util.stream.Collectors.toSet()));
        for (Map.Entry<String, KernelModel.Term> entry
                : requiredOccurrenceAnchors.entrySet()) {
            KernelModel.Term marker = entry.getValue();
            KernelModel.Term source = coveredOccurrenceAnchors.get(entry.getKey());
            int references = anchorReferences.getOrDefault(marker.id(), 0);
            if (!isIsolatedCallAnchor(marker, source, references)) {
                throw theory(
                        "CALL occurrence anchor must match its source context/type "
                                + "and remain an isolated provenance term");
            }
        }
    }

    static boolean isIsolatedCallAnchor(
            KernelModel.Term marker,
            KernelModel.Term source,
            int scalarReferences) {
        return marker.context().equals(source.context())
                && marker.sort().equals(source.sort())
                && scalarReferences == 1;
    }

    private Map<String, Integer> scalarReferenceCounts(Set<String> selected) {
        Map<String, Integer> counts = new HashMap<>();
        for (String value : selected) {
            counts.put(value, 0);
        }
        Deque<Wire.Node> pending = new ArrayDeque<>();
        pending.push(model.bundle().root());
        int visited = 0;
        while (!pending.isEmpty()) {
            if (++visited > limits.maxNodes()) {
                throw resource("CALL anchor reference scan exceeds node bound");
            }
            Wire.Node node = pending.pop();
            for (String scalar : node.scalars()) {
                if (counts.containsKey(scalar)) {
                    counts.put(scalar, Math.incrementExact(counts.get(scalar)));
                }
            }
            for (Wire.Node child : node.children()) {
                pending.push(child);
            }
        }
        return counts;
    }

    private static void requireSection(Wire.Node section, String tag) {
        section.requireTag(tag);
        if (!section.scalars().isEmpty()) {
            throw malformed(tag + " section carries scalars");
        }
    }

    private boolean isExactEmptyTestFixture(Wire.Node evidence) {
        if (!evidence.scalars().equals(EMPTY_TEST_SCALARS)) {
            return false;
        }
        for (Wire.Node section : evidence.children()) {
            if (!section.scalars().isEmpty() || !section.children().isEmpty()) {
                return false;
            }
        }
        return true;
    }

    private ProfileEvidence verifyAuthorizedProfile(
            Wire.Node evidence,
            boolean testOnly) {
        int bitwidth = parseNonnegativeInt(
                evidence.scalar(0), "semantic bitwidth");
        if (bitwidth > 30) {
            throw theory("Alloy semantic bitwidth exceeds 30");
        }
        OverflowMode overflow = enumValue(
                OverflowMode.class, evidence.scalar(1), "overflow mode");
        if (evidence.scalar(2).equals(FIXED_ALLOY_TEMPORAL_MODE)) {
            if (!testOnly
                    || bitwidth != 4
                    || !evidence.scalar(3).equals(FIXED_ALLOY_REWRITE_MODE)
                    || !evidence.scalar(4).equals(
                            FIXED_ALLOY_SIGNATURE_VERSION)) {
                throw theory(
                        "Fixed compatibility profiles are authorized only for TEST_ONLY evidence");
            }
        } else {
            if (!evidence.scalar(3).equals(PRODUCTION_ALLOY_REWRITE_MODE)
                    || !evidence.scalar(4).equals(
                            PRODUCTION_ALLOY_SIGNATURE_VERSION)) {
                throw theory(
                        "Source-command evidence names unsupported semantic implementation versions");
            }
            StableKey context = parseStableKey(
                    evidence.scalar(2), "source-command semantic context");
            verifySourceCommandContext(context, bitwidth, overflow);
        }
        StableKey profileKey = StableKey.of(
                "semantic-profile",
                evidence.scalars().subList(0, 5),
                List.of());
        String fingerprint = sha256(profileKey.stableString());
        if (!fingerprint.equals(evidence.scalar(5))) {
            throw new FormatException(
                    FailureCode.DIGEST_MISMATCH,
                    "Semantic-profile fingerprint does not match its five-scalar profile");
        }
        if (!REGISTRY_VERSION.equals(evidence.scalar(6))) {
            throw theory("Semantic evidence names an unknown Alloy law registry");
        }
        if (!REGISTRY_DIGEST.equals(evidence.scalar(7))) {
            throw new FormatException(
                    FailureCode.DIGEST_MISMATCH,
                    "Alloy law-registry digest does not match the fixed v2 source text");
        }
        return new ProfileEvidence(overflow, profileKey, fingerprint);
    }

    private void verifySourceCommandContext(
            StableKey context,
            int bitwidth,
            OverflowMode overflow) {
        if (!context.tag().equals(SOURCE_COMMAND_CONTEXT_TAG)
                || context.scalars().size() != 11
                || context.children().size() != 3) {
            throw theory("Source-command semantic context has the wrong shape");
        }
        if (!context.scalars().get(0).equals(SOURCE_COMMAND_CONTEXT_VERSION)) {
            throw theory("Source-command semantic context has an unsupported version");
        }
        requireNonblankText(context.scalars().get(1), "source command label");
        requireNonblankText(context.scalars().get(2), "source command formula");
        parseCanonicalBoolean(context.scalars().get(3), "source command check flag");
        parseCanonicalInt(context.scalars().get(4), "source command overall scope");
        int contextWidth = parseCanonicalInt(
                context.scalars().get(5), "source command effective bitwidth");
        if (contextWidth != bitwidth) {
            throw theory("Source-command context and profile bitwidth disagree");
        }
        for (int index = 6; index < context.scalars().size(); index++) {
            parseCanonicalInt(
                    context.scalars().get(index),
                    "source command integer field " + index);
        }

        StableKey scopes = context.children().get(0);
        if (!scopes.tag().equals("scopes") || !scopes.scalars().isEmpty()) {
            throw theory("Source-command scopes have the wrong shape");
        }
        verifyCanonicalContextChildren(scopes.children(), "scope", 5);
        for (StableKey scope : scopes.children()) {
            requireNonblankText(scope.scalars().get(0), "scope signature");
            parseCanonicalBoolean(scope.scalars().get(1), "scope exactness");
            for (int index = 2; index < 5; index++) {
                parseCanonicalInt(scope.scalars().get(index), "scope bound");
            }
        }

        StableKey exactScopes = context.children().get(1);
        if (!exactScopes.tag().equals("additional-exact-scopes")
                || !exactScopes.scalars().isEmpty()) {
            throw theory("Additional exact scopes have the wrong shape");
        }
        verifyCanonicalContextChildren(
                exactScopes.children(), "exact-scope", 1);
        for (StableKey exactScope : exactScopes.children()) {
            requireNonblankText(
                    exactScope.scalars().get(0), "exact-scope signature");
        }

        StableKey options = context.children().get(2);
        if (!options.tag().equals("execution-options")
                || options.scalars().size() != 10
                || !options.children().isEmpty()) {
            throw theory("Source-command execution options have the wrong shape");
        }
        parseCanonicalBoolean(
                options.scalars().get(0), "infer-partial-instance option");
        for (int index : List.of(1, 2, 3, 4, 7, 8, 9)) {
            parseCanonicalInt(
                    options.scalars().get(index),
                    "execution option field " + index);
        }
        requireNonblankText(options.scalars().get(5), "solver identity");
        boolean noOverflow = parseCanonicalBoolean(
                options.scalars().get(6), "no-overflow option");
        OverflowMode expected = noOverflow
                ? OverflowMode.FORBID : OverflowMode.MODULAR;
        if (overflow != expected) {
            throw theory("Source-command context and overflow mode disagree");
        }
    }

    private static void verifyCanonicalContextChildren(
            List<StableKey> children,
            String expectedTag,
            int scalarCount) {
        String prior = null;
        for (StableKey child : children) {
            if (!child.tag().equals(expectedTag)
                    || child.scalars().size() != scalarCount
                    || !child.children().isEmpty()) {
                throw theory(expectedTag + " context entry has the wrong shape");
            }
            String encoded = child.stableString();
            if (prior != null && prior.compareTo(encoded) >= 0) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        expectedTag + " context entries are not strictly ordered");
            }
            prior = encoded;
        }
    }

    private void requireCanonicalEvidenceOrder(Wire.Node section, String label) {
        if (section.children().size() > limits.maxTableEntries()) {
            throw resource(label + " table exceeds its configured bound");
        }
        String prior = null;
        for (Wire.Node record : section.children()) {
            if (record.scalars().isEmpty()) {
                throw malformed(label + " record has no structural key");
            }
            String key = record.scalar(0);
            parseStableKey(key, label + " structural key");
            prior = requireIncreasing(prior, key, label);
        }
    }

    private TypeLedger parseExactTypes(Wire.Node section) {
        if (section.children().size() > limits.maxTableEntries()) {
            throw resource("exact-type table exceeds its configured bound");
        }
        Map<String, Wire.Node> records = new LinkedHashMap<>();
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireTag("exact-type");
            if (record.scalars().size() != 3) {
                throw malformed("exact-type record");
            }
            String id = record.scalar(0);
            prior = requireIncreasing(prior, id, "exact type");
            if (!id.equals(Bundle.contentId(record))) {
                throw new FormatException(
                        FailureCode.CONTENT_ID_MISMATCH,
                        "Exact type content ID mismatch: " + id);
            }
            for (Wire.Node child : record.children()) {
                child.requireShape("type-ref", 1, 0);
            }
            if (records.put(id, record) != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate exact type ID " + id);
            }
        }
        Map<String, ExactType> resolved = new LinkedHashMap<>();
        Set<String> active = new HashSet<>();
        for (String id : records.keySet()) {
            resolveExactType(id, records, resolved, active);
        }
        Map<String, ExactType> byDisplay = new LinkedHashMap<>();
        for (ExactType type : resolved.values()) {
            ExactType collision = byDisplay.putIfAbsent(type.display(), type);
            if (collision != null && !collision.id().equals(type.id())) {
                throw new FormatException(
                        FailureCode.INVALID_TYPE,
                        "Two exact type IDs render as " + type.display());
            }
        }
        for (Map.Entry<String, ExactType> display : byDisplay.entrySet()) {
            ExactType idCollision = resolved.get(display.getKey());
            if (idCollision != null
                    && !idCollision.id().equals(display.getValue().id())) {
                throw new FormatException(
                        FailureCode.INVALID_TYPE,
                        "An exact type display collides with another type ID: "
                                + display.getKey());
            }
        }
        return new TypeLedger(
                Collections.unmodifiableMap(resolved),
                Collections.unmodifiableMap(byDisplay));
    }

    private ExactType resolveExactType(
            String id,
            Map<String, Wire.Node> records,
            Map<String, ExactType> resolved,
            Set<String> active) {
        ExactType prior = resolved.get(id);
        if (prior != null) {
            return prior;
        }
        Wire.Node record = records.get(id);
        if (record == null) {
            throw new FormatException(
                    FailureCode.DANGLING_REFERENCE,
                    "Exact type refers to missing type ID " + id);
        }
        if (!active.add(id)) {
            throw new FormatException(
                    FailureCode.INVALID_TYPE,
                    "Exact type records contain a cycle at " + id);
        }
        TypeKind kind;
        try {
            kind = TypeKind.valueOf(record.scalar(1));
        } catch (IllegalArgumentException exception) {
            throw new FormatException(
                    FailureCode.INVALID_TYPE,
                    "Unknown exact type kind " + record.scalar(1), exception);
        }
        List<ExactType> arguments = new ArrayList<>();
        for (Wire.Node child : record.children()) {
            arguments.add(resolveExactType(
                    child.scalar(0), records, resolved, active));
        }
        String symbol = null;
        switch (kind) {
            case TYPE_VARIABLE, CONSTRUCTOR -> {
                if (!isAdmittedIdentity(record.scalar(2))) {
                    throw invalidType(
                            kind + " requires one well-formed visible symbol");
                }
                symbol = record.scalar(2);
            }
            default -> {
                if (!record.scalar(2).isEmpty()) {
                    throw invalidType(kind + " must not carry a symbol");
                }
            }
        }
        switch (kind) {
            case TYPE_VARIABLE, INT, BOOL -> requireTypeArity(kind, arguments, 0);
            case ARROW -> requireTypeArity(kind, arguments, 2);
            case RELATION -> {
                if (arguments.isEmpty()) {
                    throw invalidType("RELATION requires at least one column");
                }
            }
            case CONSTRUCTOR -> {
                // Constructors admit any finite number of exact type arguments.
            }
        }
        if (kind == TypeKind.CONSTRUCTOR) {
            if (symbol.startsWith("AlloySig:")
                    && !hasAdmittedAlloySignatureIdentity(symbol)) {
                throw invalidType(
                        "Alloy signature constructors require one canonical identity");
            }
            if ("AlloyEmptyRelation".equals(symbol)
                    || (symbol.startsWith(EMPTY_RELATION_PREFIX)
                            && emptyRelationArity(symbol) == null)) {
                throw invalidType(
                        "Empty relation constructor has no canonical positive arity");
            }
            if (symbol.startsWith(EMPTY_RELATION_PREFIX)
                    && !arguments.isEmpty()) {
                throw invalidType(
                        "Empty relation constructor must be nullary");
            }
        }
        String display = switch (kind) {
            case TYPE_VARIABLE -> "'" + symbol;
            case INT -> "Int";
            case BOOL -> "Bool";
            case ARROW -> "(" + arguments.get(0).display() + " -> "
                    + arguments.get(1).display() + ")";
            case RELATION -> formatApplication("Rel", arguments);
            case CONSTRUCTOR -> arguments.isEmpty()
                    ? symbol : formatApplication(symbol, arguments);
        };
        StableKey structuralKey = typeStructuralKey(kind, symbol, arguments);
        ExactType result = new ExactType(
                id, kind, symbol, List.copyOf(arguments), structuralKey, display);
        active.remove(id);
        resolved.put(id, result);
        return result;
    }

    private static void requireTypeArity(
            TypeKind kind,
            List<ExactType> arguments,
            int expected) {
        if (arguments.size() != expected) {
            throw invalidType(kind + " requires " + expected + " arguments");
        }
    }

    private static String formatApplication(String head, List<ExactType> arguments) {
        return head + "(" + String.join(",", arguments.stream()
                .map(ExactType::display).toList()) + ")";
    }

    private void requireModelTypeCoverage(
            TypeLedger exactTypes,
            boolean publication) {
        for (KernelModel.Context context : model.contexts().values()) {
            for (KernelModel.Slot slot : context.slots()) {
                requireType(exactTypes, slot.type(), publication,
                        "context " + context.id() + " slot " + slot.name());
            }
        }
        for (KernelModel.Operator operator : model.operators().values()) {
            requireType(exactTypes, operator.outputType(), publication,
                    "operator " + operator.id() + " output");
        }
        for (KernelModel.Schema schema : model.schemas().values()) {
            switch (schema.kind()) {
                case ONE, ONE_SLOT, ONE_TERM, BIND -> requireType(
                        exactTypes, schema.value(), publication,
                        "schema " + schema.id());
                default -> {
                    // Container values are empty; BIND_BLOCK values name descriptors.
                }
            }
        }
        for (KernelModel.Binder binder : model.binders().values()) {
            for (KernelModel.BinderCoordinate coordinate : binder.coordinates()) {
                requireType(exactTypes, coordinate.type(), publication,
                        "binder " + binder.id() + " coordinate " + coordinate.index());
            }
        }
        for (KernelModel.Term term : model.terms().values()) {
            requireRuntimeSort(
                    exactTypes, term.sort(), publication, "term " + term.id());
        }
        for (KernelModel.Witness witness : model.witnesses().values()) {
            requireType(exactTypes, witness.type(), publication,
                    "witness " + witness.id());
        }
        for (KernelModel.Axiom axiom : model.axioms().values()) {
            requirePatternTypes(exactTypes, axiom.left(), publication, axiom.id());
            requirePatternTypes(exactTypes, axiom.right(), publication, axiom.id());
            for (Map.Entry<String, KernelModel.Sort> variable
                    : axiom.termVariables().entrySet()) {
                requireRuntimeSort(
                        exactTypes,
                        variable.getValue(),
                        publication,
                        "axiom " + axiom.id() + " variable " + variable.getKey());
            }
        }
        requireProofTypeCoverage(exactTypes, publication);
        requireSnapshotTypeCoverage(exactTypes, publication);
    }

    private void requirePatternTypes(
            TypeLedger exactTypes,
            KernelModel.Pattern pattern,
            boolean publication,
            String axiomId) {
        requireRuntimeSort(
                exactTypes, pattern.sort(), publication, "axiom " + axiomId);
        for (KernelModel.Pattern child : pattern.children()) {
            requirePatternTypes(exactTypes, child, publication, axiomId);
        }
    }

    private static void requireRuntimeSort(
            TypeLedger exactTypes,
            KernelModel.Sort sort,
            boolean publication,
            String owner) {
        if (sort.kind() == KernelModel.SortKind.TERM
                && !sort.value().startsWith("$")) {
            requireType(exactTypes, sort.value(), publication, owner);
        }
    }

    private void requireProofTypeCoverage(
            TypeLedger exactTypes,
            boolean publication) {
        for (Wire.Node proof : bundle.proofs().values()) {
            if (proof.scalars().size() > 4 && proof.scalar(3).equals("TERM")) {
                requireType(exactTypes, proof.scalar(4), publication,
                        "proof " + proof.scalar(0));
            }
            if (!proof.children().isEmpty()) {
                requireTypeEntries(proof.child(proof.children().size() - 1),
                        exactTypes, publication, "proof " + proof.scalar(0));
            }
        }
    }

    private void requireTypeEntries(
            Wire.Node node,
            TypeLedger exactTypes,
            boolean publication,
            String owner) {
        if (node.tag().equals("type-entry")) {
            node.requireShape("type-entry", 2, 0);
            requireType(exactTypes, node.scalar(1), publication, owner);
            return;
        }
        for (Wire.Node child : node.children()) {
            requireTypeEntries(child, exactTypes, publication, owner);
        }
    }

    private void requireSnapshotTypeCoverage(
            TypeLedger exactTypes,
            boolean publication) {
        for (Wire.Node snapshot : bundle.snapshots().values()) {
            if (snapshot.children().isEmpty()) {
                continue;
            }
            Wire.Node classes = snapshot.child(0).requireTag("classes");
            for (Wire.Node eclass : classes.children()) {
                eclass.requireShape("class", 4, 0);
                requireType(exactTypes, eclass.scalar(3), publication,
                        "snapshot class " + eclass.scalar(0));
            }
        }
    }

    private LawLedger verifyLaws(
            Wire.Node section,
            ProfileEvidence profile,
            TypeLedger exactTypes,
            boolean publication) {
        Map<String, ExpectedLaw> expected = expectedLaws(
                profile, exactTypes, publication);
        Map<OperatorPath, Map<Law, ExpectedLaw>> checked = new LinkedHashMap<>();
        if (section.children().size() > limits.maxTableEntries()) {
            throw resource("law-certificate table exceeds its configured bound");
        }
        String prior = null;
        for (Wire.Node record : section.children()) {
            record.requireShape("law-certificate", 17, 0);
            prior = requireIncreasing(prior, record.scalar(0), "law certificate");
            StableKey claimedIndex = parseStableKey(
                    record.scalar(0), "law-certificate index");
            ExpectedLaw law = expected.remove(record.scalar(0));
            if (law == null) {
                throw theory("Law certificate is not required by a production operator: "
                        + record.scalar(0));
            }
            verifyLawRecord(record, claimedIndex, law);
            Map<Law, ExpectedLaw> atPath = checked.computeIfAbsent(
                    new OperatorPath(law.operatorId(), law.path()),
                    ignored -> new LinkedHashMap<>());
            if (atPath.put(law.law(), law) != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate law at one exact operator path");
            }
        }
        if (!expected.isEmpty()) {
            throw new FormatException(
                    FailureCode.MISSING_EVIDENCE,
                    "Missing exact Alloy law certificates: " + expected.keySet());
        }
        Map<OperatorPath, Map<Law, ExpectedLaw>> immutable = new LinkedHashMap<>();
        for (Map.Entry<OperatorPath, Map<Law, ExpectedLaw>> entry
                : checked.entrySet()) {
            immutable.put(entry.getKey(), Map.copyOf(entry.getValue()));
        }
        return new LawLedger(Collections.unmodifiableMap(immutable));
    }

    private Map<String, ExpectedLaw> expectedLaws(
            ProfileEvidence profile,
            TypeLedger exactTypes,
            boolean publication) {
        Map<String, ExpectedLaw> result = new LinkedHashMap<>();
        for (KernelModel.Operator operator : model.operators().values()) {
            String opcode = opcode(operator.semanticIdentity());
            if (opcode == null) {
                continue;
            }
            if (operator.schemas().size() != 1) {
                throw theory(operator.semanticIdentity()
                        + " must expose exactly one certified container port");
            }
            KernelModel.Schema schema = model.schema(operator.schemas().get(0));
            ExactType resultType = requireType(
                    exactTypes, operator.outputType(), publication,
                    "law-bearing operator output");
            ExactType elementType = requireLawSchema(
                    opcode, operator, schema, profile.overflow(), exactTypes,
                    publication);
            List<Law> laws = requiredLaws(opcode, profile.overflow());
            requireExactLawCarrier(opcode, resultType, elementType);
            StableKey schemaKey = lawSchemaKey(schema, exactTypes, publication);
            for (Law law : laws) {
                ExpectedLaw expected = expectedLaw(
                        profile, opcode, operator, schema, schemaKey,
                        resultType, law);
                ExpectedLaw prior = result.putIfAbsent(
                        expected.index().stableString(), expected);
                if (prior != null) {
                    throw new FormatException(
                            FailureCode.NONCANONICAL_ENCODING,
                            "Two law-bearing declarations reuse one law index");
                }
            }
        }
        return result;
    }

    private ExactType requireLawSchema(
            String opcode,
            KernelModel.Operator operator,
            KernelModel.Schema schema,
            OverflowMode overflow,
            TypeLedger exactTypes,
            boolean publication) {
        KernelModel.SchemaKind kind;
        KernelModel.SiblingQuotient quotient;
        KernelModel.ArityPolicy arity;
        boolean associative;
        if (Set.of("AND", "OR", "PLUS", "INTERSECT").contains(opcode)) {
            kind = KernelModel.SchemaKind.SET;
            quotient = KernelModel.SiblingQuotient.COMMUTATIVE_IDEMPOTENT_SET;
            arity = atLeast(1);
            associative = true;
        } else if ((opcode.equals("IPLUS") || opcode.equals("MUL"))
                && overflow == OverflowMode.MODULAR) {
            kind = KernelModel.SchemaKind.BAG;
            quotient = KernelModel.SiblingQuotient.COMMUTATIVE_BAG;
            arity = atLeast(1);
            associative = true;
        } else if (opcode.equals("DISJOINT")) {
            kind = KernelModel.SchemaKind.BAG;
            quotient = KernelModel.SiblingQuotient.COMMUTATIVE_BAG;
            arity = atLeast(1);
            associative = false;
        } else {
            kind = KernelModel.SchemaKind.BAG;
            quotient = KernelModel.SiblingQuotient.COMMUTATIVE_BAG;
            arity = finite(2);
            associative = false;
        }
        if (schema.kind() != kind
                || schema.siblingQuotient() != quotient
                || !schema.arityPolicy().equals(arity)) {
            throw theory(operator.semanticIdentity()
                    + " has a container outside the fixed Alloy law matrix");
        }
        String expectedFlatPath = associative ? "0/0" : "none";
        if (!operator.flatPath().equals(expectedFlatPath)) {
            throw theory(operator.semanticIdentity()
                    + " has a flat license inconsistent with its fixed law matrix");
        }
        KernelModel.Schema element = model.schema(schema.childSchema());
        if (element.kind() != KernelModel.SchemaKind.ONE
                || element.siblingQuotient() != KernelModel.SiblingQuotient.RIGID
                || !element.arityPolicy().equals(finite(1))
                || !element.childSchema().isEmpty()) {
            throw theory(operator.semanticIdentity()
                    + " does not use an exact One(elementType) schema");
        }
        return requireType(exactTypes, element.value(), publication,
                "law-bearing operator element");
    }

    private static void requireExactLawCarrier(
            String opcode,
            ExactType result,
            ExactType element) {
        switch (opcode) {
            case "AND", "OR" -> requireTypes(
                    result.is(TypeKind.BOOL) && element.is(TypeKind.BOOL), opcode);
            case "PLUS", "INTERSECT" -> requireTypes(
                    relationArity(result) != null
                            && result.key().equals(element.key()),
                    opcode);
            case "IPLUS", "MUL" -> requireTypes(
                    result.is(TypeKind.INT) && element.is(TypeKind.INT), opcode);
            case "EQUALS", "NOT_EQUALS" -> requireTypes(
                    result.is(TypeKind.BOOL), opcode);
            case "IFF" -> requireTypes(
                    result.is(TypeKind.BOOL) && element.is(TypeKind.BOOL), opcode);
            case "DISJOINT" -> requireTypes(
                    result.is(TypeKind.BOOL) && relationArity(element) != null, opcode);
            default -> throw new AssertionError("Unhandled fixed law opcode " + opcode);
        }
    }

    private static void requireTypes(boolean condition, String opcode) {
        if (!condition) {
            throw theory("ALLOY/" + opcode + " has the wrong exact result/element types");
        }
    }

    private static Integer relationArity(ExactType type) {
        if (type.is(TypeKind.RELATION)) {
            return type.arguments().size();
        }
        Integer emptyArity = type.is(TypeKind.CONSTRUCTOR)
                && type.arguments().isEmpty()
                        ? emptyRelationArity(type.symbol()) : null;
        if (emptyArity != null) {
            return emptyArity;
        }
        if (!type.is(TypeKind.CONSTRUCTOR)
                || !(type.symbol().equals("AlloyComparableCarrier")
                        || type.symbol().equals("AlloyRelationUnion"))
                || type.arguments().isEmpty()) {
            return null;
        }
        Integer arity = null;
        for (ExactType alternative : type.arguments()) {
            Integer next = relationArity(alternative);
            if (next == null || (arity != null && !arity.equals(next))) {
                return null;
            }
            arity = next;
        }
        return arity;
    }

    private static Integer emptyRelationArity(String symbol) {
        if (symbol == null || !symbol.startsWith(EMPTY_RELATION_PREFIX)) {
            return null;
        }
        String encoded = symbol.substring(EMPTY_RELATION_PREFIX.length());
        try {
            int arity = Integer.parseInt(encoded);
            return arity > 0 && Integer.toString(arity).equals(encoded)
                    ? arity : null;
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private ExpectedLaw expectedLaw(
            ProfileEvidence profile,
            String opcode,
            KernelModel.Operator operator,
            KernelModel.Schema schema,
            StableKey schemaKey,
            ExactType resultType,
            Law law) {
        String path = "0/0";
        StableKey parameter = StableKey.of(
                "alloy-law-parameter-v1",
                List.of(opcode, path, law.name(), law.family()),
                List.of(profile.key(), resultType.key(), schemaKey));
        StableKey index = StableKey.of(
                "container-law-index-v2",
                List.of(
                        "ALLOY_PROFILE_THEORY",
                        operator.semanticIdentity(),
                        path,
                        law.name(),
                        REGISTRY_DIGEST),
                List.of(profile.key(), resultType.key(), schemaKey, parameter));
        StableKey left = StableKey.of(
                "container-law-source-endpoint", List.of("left"), List.of(index));
        StableKey right = StableKey.of(
                "container-law-source-endpoint", List.of("right"), List.of(index));
        String sourceArtifact = REGISTRY_VERSION + "/" + REGISTRY_DIGEST;
        String declarationId = operator.semanticIdentity() + "@" + path + ":"
                + law.name() + ":" + sha256(parameter.stableString());
        return new ExpectedLaw(
                index,
                operator.id(),
                operator.semanticIdentity(),
                operator.outputType(),
                resultType,
                path,
                law,
                schema.id(),
                schemaKey,
                parameter,
                left,
                right,
                sourceArtifact,
                declarationId);
    }

    private void verifyLawRecord(
            Wire.Node record,
            StableKey claimedIndex,
            ExpectedLaw expected) {
        StableKey schema = parseStableKey(record.scalar(9), "law schema");
        StableKey parameter = parseStableKey(record.scalar(10), "law parameter");
        StableKey left = parseStableKey(record.scalar(11), "law left endpoint");
        StableKey right = parseStableKey(record.scalar(12), "law right endpoint");
        List<String> actual = List.of(
                record.scalar(1),
                record.scalar(2),
                record.scalar(3),
                record.scalar(5),
                record.scalar(6),
                record.scalar(7),
                record.scalar(8),
                record.scalar(13),
                record.scalar(14),
                record.scalar(15),
                record.scalar(16));
        List<String> required = List.of(
                "ALLOY_PROFILE_THEORY",
                expected.operatorIdentity(),
                expected.runtimeTypeReference(),
                expected.path(),
                expected.law().name(),
                REGISTRY_DIGEST,
                expected.schemaId(),
                "SIGNATURE_CONTAINER_LAW",
                expected.sourceArtifact(),
                expected.declarationId(),
                Integer.toString(expected.law().ordinal()));
        if (!actual.equals(required)
                || !claimedIndex.equals(expected.index())
                || !record.scalar(4).equals(expected.resultType().id())
                || !schema.equals(expected.schemaKey())
                || !parameter.equals(expected.parameter())
                || !left.equals(expected.left())
                || !right.equals(expected.right())) {
            throw theory("Law certificate does not reconstruct from its fixed registry index");
        }
    }

    private StableKey lawSchemaKey(
            KernelModel.Schema schema,
            TypeLedger exactTypes,
            boolean publication) {
        String tag = switch (schema.kind()) {
            case SET -> "schema/set";
            case BAG -> "schema/bag";
            default -> throw theory("Fixed Alloy law does not use Set or Bag");
        };
        KernelModel.Schema element = model.schema(schema.childSchema());
        StableKey elementKey = StableKey.of(
                "schema/one",
                List.of(),
                List.of(requireType(exactTypes, element.value(), publication,
                        "law schema element").key()));
        return StableKey.of(
                tag,
                List.of(schema.siblingQuotient().name()),
                List.of(arityKey(schema.arityPolicy()), elementKey));
    }

    private static StableKey arityKey(KernelModel.ArityPolicy policy) {
        List<String> scalars = new ArrayList<>();
        if (policy.atLeast()) {
            scalars.add("AT_LEAST");
            scalars.add(Integer.toString(policy.minimum()));
        } else {
            scalars.add("FINITE");
            policy.finite().stream().sorted().map(Object::toString)
                    .forEach(scalars::add);
        }
        return StableKey.of("arity-policy", scalars, List.of());
    }

    private static List<Law> requiredLaws(String opcode, OverflowMode overflow) {
        if (Set.of("AND", "OR", "PLUS", "INTERSECT").contains(opcode)) {
            return List.of(Law.ASSOCIATIVITY, Law.COMMUTATIVITY, Law.IDEMPOTENCY);
        }
        if ((opcode.equals("IPLUS") || opcode.equals("MUL"))
                && overflow == OverflowMode.MODULAR) {
            return List.of(Law.ASSOCIATIVITY, Law.COMMUTATIVITY);
        }
        return List.of(Law.COMMUTATIVITY);
    }

    private static String opcode(String semanticIdentity) {
        if (!semanticIdentity.startsWith("ALLOY/")) {
            return null;
        }
        String opcode = semanticIdentity.substring("ALLOY/".length());
        return KNOWN_OPERATORS.contains(opcode) ? opcode : null;
    }

    private static KernelModel.ArityPolicy atLeast(int minimum) {
        return new KernelModel.ArityPolicy(true, minimum, Set.of());
    }

    private static KernelModel.ArityPolicy finite(int arity) {
        return new KernelModel.ArityPolicy(false, -1, Set.of(arity));
    }

    private static ExactType requireType(
            TypeLedger exactTypes,
            String reference,
            boolean publication,
            String owner) {
        ExactType type = publication
                ? exactTypes.byId().get(reference)
                : exactTypes.byId().getOrDefault(
                        reference, exactTypes.byDisplay().get(reference));
        if (type == null) {
            throw new FormatException(
                    FailureCode.MISSING_EVIDENCE,
                    owner + " has no exact structural type for " + reference);
        }
        return type;
    }

    private static StableKey typeStructuralKey(
            TypeKind kind,
            String symbol,
            List<ExactType> arguments) {
        return StableKey.of(
                "type/" + kind.name(),
                symbol == null ? List.of() : List.of(symbol),
                arguments.stream().map(ExactType::key).toList());
    }

    /** Rebuilds every concrete semantic-evidence claim from the decoded model. */
    private final class SemanticReplay {
        private static final String BINDER_SIGNATURE =
                "canonical-alloy-signature-v7";
        private static final String BINDER_DECLARATION = "alloy-binder-block";

        private final ProfileEvidence profile;
        private final TypeLedger types;
        private final LawLedger laws;
        private final boolean publication;
        private final Map<String, StableKey> contextKeys = new HashMap<>();
        private final Map<String, StableKey> schemaKeys = new HashMap<>();
        private final Map<String, BinderView> binderViews = new HashMap<>();
        private final Map<String, StableKey> operatorKeys = new HashMap<>();
        private final Map<String, StableKey> termKeys = new HashMap<>();
        private final Set<String> verifiedFlatConstructions = new HashSet<>();
        private final Set<String> verifiedChainConstructions = new HashSet<>();
        private final Set<String> verifiedContainerConstructions = new HashSet<>();
        private final Set<String> verifiedBinderOccurrences = new HashSet<>();
        private final Map<String, ConstructionEvidence> flatEvidence =
                new HashMap<>();
        private final Map<String, ConstructionEvidence> chainEvidence =
                new HashMap<>();
        private final SubtypeStackLedger<StableKey> chainSubtypeStacks =
                new SubtypeStackLedger<>();
        private final Map<String, ConstructionEvidence> containerEvidence =
                new HashMap<>();
        private final Map<String, BinderEvidence> binderEvidence = new HashMap<>();
        private final Map<String, VerifiedReplayConstruction> replayConstructions =
                new HashMap<>();
        private final Map<String, StableKey> orbitComparisonKeys = new HashMap<>();
        private final Map<String, StableKey> orbitRepresentativeKeys = new HashMap<>();
        private long orbitWork;
        private boolean hasUntrustedSubtypeHierarchy;

        private SemanticReplay(
                ProfileEvidence profile,
                TypeLedger types,
                LawLedger laws,
                boolean publication) {
            this.profile = profile;
            this.types = types;
            this.laws = laws;
            this.publication = publication;
        }

        private void verify(
                Wire.Node flat,
                Wire.Node containers,
                Wire.Node binders) {
            for (Wire.Node record : flat.children()) {
                if (record.tag().equals("flat-construction")) {
                    verifyFlat(record);
                } else if (record.tag().equals(
                        "dependent-chain-construction")) {
                    verifyDependentChain(record);
                } else {
                    throw new FormatException(
                            FailureCode.UNKNOWN_VARIANT,
                            "Unknown source construction " + record.tag());
                }
            }
            for (Wire.Node record : containers.children()) {
                verifyContainer(record);
            }
            for (Wire.Node record : binders.children()) {
                verifyBinderOccurrence(record);
            }
            verifyEvidenceCoverage();
            if (hasUntrustedSubtypeHierarchy) {
                throw new UncheckableException(
                        FailureCode.MISSING_EVIDENCE,
                        "Subtype JOIN ancestry is internally consistent but lacks "
                                + "an independently pinned source-hierarchy authority");
            }
        }

        private void verifyProducerOrbitOrders() {
            TermOps terms = new TermOps(model, limits);
            for (Wire.Node canonical : bundle.canonicalRecords().values()) {
                canonical.requireShape("canonical-record", 3, 1);
                Wire.Node orbit = bundle.proofs().get(canonical.scalar(1));
                Wire.Node replay = bundle.proofs().get(canonical.child(0)
                        .requireShape("source-replay-ref", 1, 0).scalar(0));
                if (orbit == null || replay == null) {
                    throw theory("Canonical record omits its orbit or source replay");
                }
                orbit.requireShape("proof", 7, 2);
                replay.requireShape("proof", 7, 2);
                if (!orbit.scalar(1).equals("CANONICAL_ORBIT")
                        || !replay.scalar(1).equals("KERNEL_REPLAY")) {
                    throw theory("Canonical record references the wrong proof variants");
                }
                Wire.Node payload = orbit.child(1).requireShape(
                        "canonical-orbit", 6, 4);
                Wire.Node replayPayload = replay.child(1).requireShape(
                        "kernel-replay", 7, 5);
                VerifiedReplayConstruction verified = replayConstructions.get(
                        replay.scalar(0));
                if (verified == null) {
                    throw theory("Canonical replay lacks verified source construction coverage");
                }
                KernelModel.Term replaySource = model.term(replayPayload.scalar(0));
                KernelModel.Term replayLeft = model.term(replay.scalar(5));
                KernelModel.Term replayRight = model.term(replay.scalar(6));
                KernelModel.Term replayKernel = model.term(replayPayload.scalar(2));
                KernelModel.Term orbitSource = model.term(payload.scalar(0));
                KernelModel.Term base = model.term(payload.scalar(1));
                Wire.Node construction = replayPayload.child(4)
                        .requireShape("source-construction", 4, 0);
                if (!verified.matches(replaySource, construction)) {
                    throw theory("Canonical replay changed its verified construction reference");
                }
                if (!replayLeft.id().equals(replaySource.id())
                        || !replayRight.id().equals(replayKernel.id())
                        || !replayKernel.id().equals(orbitSource.id())
                        || !orbitSource.id().equals(base.id())) {
                    throw theory(
                            "Source construction, kernel replay, and canonical orbit do not compose exactly");
                }
                if (verified.kind() != ConstructionKind.NONE) {
                    continue;
                }
                if (!construction.scalar(1).equals(PRODUCER_ORBIT_SOURCE_MARKER)) {
                    continue;
                }
                KernelModel.Term producerSource = model.term(construction.scalar(2));
                KernelModel.Embedding producerSelected = model.embedding(
                        construction.scalar(3));
                KernelModel.Embedding wireSelected = model.embedding(payload.scalar(4));
                verifyRigidProducerOrbit(
                        payload,
                        producerSource,
                        producerSelected,
                        wireSelected,
                        terms);
            }
        }

        private void verifyRigidProducerOrbit(
                Wire.Node payload,
                KernelModel.Term producerSource,
                KernelModel.Embedding producerSelected,
                KernelModel.Embedding wireSelected,
                TermOps terms) {
            KernelModel.Term source = model.term(payload.scalar(0));
            KernelModel.Term base = model.term(payload.scalar(1));
            KernelModel.Context target = model.context(payload.scalar(2));
            KernelModel.Term representative = model.term(payload.scalar(3));
            if (!isRigidSlotOnly(base, terms)
                    || !isRigidSlotOnly(producerSource, terms)
                    || !payload.child(1).requireTag("leader-groups").children().isEmpty()
                    || !payload.child(3).requireTag("binder-occurrence-refs")
                            .children().isEmpty()) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_ORBIT,
                        "Nonidentity free-slot ordering is certified only for rigid slot-only orbits");
            }
            if (!isIdentity(wireSelected)
                    || !wireSelected.source().equals(base.context())
                    || !wireSelected.target().equals(target)
                    || !terms.act(base, wireSelected).id().equals(source.id())
                    || !representative.id().equals(source.id())
                    || !source.id().equals(base.id())
                    || !producerSource.context().equals(base.context())
                    || producerSelected.kind()
                            != KernelModel.EmbeddingKind.BIJECTION
                    || !producerSelected.source().equals(base.context())
                    || !producerSelected.target().equals(target)) {
                throw theory("Producer orbit source/witness endpoints do not compose exactly");
            }

            Wire.Node free = payload.child(0).requireTag("free-renamings");
            if (!free.scalars().isEmpty() || free.children().isEmpty()) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_ORBIT,
                        "Producer orbit has no explicit free-renaming ledger");
            }
            ProducerOrbitCandidate minimum = null;
            String priorWitnessId = null;
            for (Wire.Node reference : free.children()) {
                consumeOrbitWork();
                String witnessId = reference.requireShape(
                        "embedding-ref", 1, 0).scalar(0);
                if (priorWitnessId != null
                        && priorWitnessId.compareTo(witnessId) >= 0) {
                    throw new FormatException(
                            FailureCode.NONCANONICAL_ENCODING,
                            "Producer free-renaming witnesses are duplicated or unsorted");
                }
                priorWitnessId = witnessId;
                KernelModel.Embedding witness = model.embedding(witnessId);
                if (witness.kind() != KernelModel.EmbeddingKind.BIJECTION
                        || !witness.source().equals(base.context())
                        || !witness.target().equals(target)) {
                    throw theory("Producer orbit contains a witness with different endpoints");
                }
                KernelModel.Embedding inverse = inverse(witness);
                KernelModel.Term wireTerm = terms.act(base, witness);
                KernelModel.Term producerCandidate = terms.act(producerSource, inverse);
                StableKey candidateShape = canonicalShapeKey(producerCandidate, terms);
                StableKey completeOrder = StableKey.of(
                        "canonical-orbit-candidate-v1",
                        List.of(),
                        List.of(candidateShape, witnessOrderKey(witness)));
                ProducerOrbitCandidate candidate = new ProducerOrbitCandidate(
                        wireTerm, witness, candidateShape, completeOrder);
                if (minimum == null
                        || candidate.completeOrder().compareTo(
                                minimum.completeOrder()) < 0) {
                    minimum = candidate;
                }
            }

            if (minimum == null) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_ORBIT,
                        "Producer orbit has no free-renaming candidate");
            }
            StableKey expectedShape = canonicalShapeKey(base, terms);
            StableKey expectedOrder = StableKey.of(
                    "canonical-orbit-candidate-v1",
                    List.of(),
                    List.of(expectedShape, witnessOrderKey(producerSelected)));
            if (!minimum.completeOrder().equals(expectedOrder)
                    || !minimum.witness().id().equals(producerSelected.id())
                    || !terms.act(base, minimum.witness()).id().equals(
                            producerSource.id())) {
                throw new FormatException(
                        FailureCode.NONMINIMAL_CANONICAL_REPRESENTATIVE,
                        "Serialized orbit does not select the producer's complete (shape,witness) minimum");
            }
            putExact(
                    orbitRepresentativeKeys,
                    representative.id(),
                    expectedShape,
                    "orbit representative");
        }

        private boolean isRigidSlotOnly(KernelModel.Term term, TermOps terms) {
            if (term.kind() != KernelModel.TermKind.APP || term.children().isEmpty()) {
                return false;
            }
            Set<String> contextSlots = new java.util.LinkedHashSet<>();
            for (KernelModel.Slot slot : term.context().slots()) {
                contextSlots.add(slot.name());
            }
            if (!terms.support(term).equals(contextSlots)) {
                return false;
            }
            for (String childId : term.children()) {
                KernelModel.Term child = terms.term(childId);
                if (child.kind() != KernelModel.TermKind.ONE_SLOT
                        || !child.context().equals(term.context())
                        || child.attributes().size() != 1
                        || !child.children().isEmpty()) {
                    return false;
                }
            }
            return true;
        }

        private KernelModel.Embedding inverse(KernelModel.Embedding witness) {
            Map<String, String> images = new LinkedHashMap<>();
            for (KernelModel.Slot target : witness.target().slots()) {
                String preimage = null;
                for (KernelModel.Slot source : witness.source().slots()) {
                    if (witness.apply(source.name()).equals(target.name())) {
                        if (preimage != null) {
                            throw theory("Free-renaming witness is not injective");
                        }
                        preimage = source.name();
                    }
                }
                if (preimage == null) {
                    throw theory("Free-renaming witness is not surjective");
                }
                images.put(target.name(), preimage);
            }
            String id = TermOps.embeddingId(
                    KernelModel.EmbeddingKind.BIJECTION,
                    witness.target(),
                    witness.source(),
                    images);
            KernelModel.Embedding inverse = model.embedding(id);
            if (!inverse.images().equals(images)) {
                throw theory("Declared inverse free renaming differs from reconstruction");
            }
            return inverse;
        }

        private boolean isIdentity(KernelModel.Embedding witness) {
            if (!witness.source().equals(witness.target())) {
                return false;
            }
            for (KernelModel.Slot slot : witness.source().slots()) {
                if (!witness.apply(slot.name()).equals(slot.name())) {
                    return false;
                }
            }
            return true;
        }

        private StableKey witnessOrderKey(KernelModel.Embedding witness) {
            List<KernelModel.Slot> sources = new ArrayList<>(witness.source().slots());
            sources.sort(Comparator.comparing(KernelModel.Slot::name));
            List<String> mapping = new ArrayList<>(sources.size() * 2);
            for (KernelModel.Slot source : sources) {
                mapping.add(source.name());
                mapping.add(witness.apply(source.name()));
            }
            return StableKey.of(
                    "canonical-witness-order-v1",
                    mapping,
                    List.of(contextKey(witness.source()), contextKey(witness.target())));
        }

        private void putExact(
                Map<String, StableKey> target,
                String id,
                StableKey value,
                String owner) {
            StableKey prior = target.putIfAbsent(id, value);
            if (prior != null && !prior.equals(value)) {
                throw new UncheckableException(
                        FailureCode.INCOMPLETE_ORBIT,
                        owner + " has incompatible producer-order roles");
            }
        }

        private void verifyFlat(Wire.Node record) {
            record.requireShape("flat-construction", 9, 3);
            requireFingerprint(record.scalar(1), "flat construction");
            KernelModel.Operator operator = model.operator(record.scalar(2));
            if (!operator.flatPath().equals(record.scalar(3))
                    || !record.scalar(3).equals("0/0")
                    || operator.schemas().size() != 1) {
                throw theory("Flat evidence does not name its exact licensed root port");
            }
            Map<Law, ExpectedLaw> operatorLaws = requireOperatorLaws(
                    operator, record.scalar(3));
            if (!operatorLaws.containsKey(Law.ASSOCIATIVITY)) {
                throw theory("Flat evidence lacks its exact associativity certificate");
            }
            KernelModel.Schema container = model.schema(operator.schemas().get(0));
            if (!isHomogeneousContainer(container)) {
                throw theory("Flat evidence is not rooted at a homogeneous container schema");
            }

            List<FlatSplice> splices = new ArrayList<>();
            FlatView source = flatInput(
                    record.child(0), operator, null, new ArrayList<>(), splices);
            requireKey(record.child(0).scalar(3), source.key(),
                    "flat source application");
            Wire.Node spliceSection = record.child(1).requireTag("splices");
            if (!spliceSection.scalars().isEmpty()
                    || spliceSection.children().size() != splices.size()) {
                throw malformed("flat splice ledger");
            }
            for (int index = 0; index < splices.size(); index++) {
                verifySplice(spliceSection.child(index), splices.get(index));
            }

            Normalization normalized = normalize(
                    container, source.context(), source.leafTerms());
            KernelModel.Term target = model.term(record.scalar(5));
            StableKey right;
            StableKey targetDetail;
            String targetKind = record.scalar(4);
            if (targetKind.equals("NODE")) {
                requireTargetNode(operator, source.context(), target, normalized);
                targetDetail = termKey(target);
                right = endpointNode(target);
            } else if (targetKind.equals("SINGLETON")) {
                if (container.kind() != KernelModel.SchemaKind.SET
                        || normalized.outputTerms().size() != 1
                        || !target.sort().equals(new KernelModel.Sort(
                                KernelModel.SortKind.PORT,
                                model.schema(container.childSchema()).id()))
                        || !termKey(target).equals(normalized.outputKeys().get(0))) {
                    throw theory("Flat singleton target is not the exact Set quotient");
                }
                targetDetail = termKey(target);
                right = endpointOneTerm(target);
            } else {
                throw new FormatException(
                        FailureCode.UNKNOWN_VARIANT,
                        "Unknown flat-construction target kind " + targetKind);
            }

            TraceView trace = verifyTrace(
                    record.child(2), container, source.context(),
                    source.leafTerms(), normalized);
            StableKey left = endpointFlat(source);
            requireKey(record.scalar(6), left, "flat left endpoint");
            requireKey(record.scalar(7), right, "flat right endpoint");

            List<StableKey> premises = new ArrayList<>();
            if (!splices.isEmpty()) {
                premises.add(lawCertificateKey(
                        operatorLaws.get(Law.ASSOCIATIVITY)));
            }
            if (trace.reordered()) {
                premises.add(lawCertificateKey(requireLaw(
                        operatorLaws, Law.COMMUTATIVITY, "flat reordering")));
            }
            if (trace.deduplicated()) {
                premises.add(lawCertificateKey(requireLaw(
                        operatorLaws, Law.IDEMPOTENCY, "flat deduplication")));
            }
            List<StableKey> details = new ArrayList<>(List.of(
                    profile.key(),
                    operatorKey(operator),
                    StableKey.of("port-path", List.of("0/0"), List.of()),
                    source.key(),
                    targetDetail,
                    trace.key()));
            splices.stream().map(FlatSplice::key).forEach(details::add);
            requireKey(record.scalar(0), typedCertificate(
                    "CONTAINER_NORMALIZATION", left, right, details, premises),
                    "flat construction certificate");
            verifiedFlatConstructions.add(record.scalar(0));
            ConstructionEvidence prior = flatEvidence.putIfAbsent(
                    record.scalar(0),
                    new ConstructionEvidence(
                            record.scalar(0), target.id(), operator.id(), record.scalar(3),
                            record.scalar(6), record.scalar(8)));
            if (prior != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate flat construction evidence key");
            }
        }

        private void verifyDependentChain(Wire.Node record) {
            record.requireShape("dependent-chain-construction", 11, 1);
            requireFingerprint(record.scalar(1), "dependent chain");
            ChainKind kind;
            try {
                kind = ChainKind.valueOf(record.scalar(2));
            } catch (IllegalArgumentException exception) {
                throw new FormatException(
                        FailureCode.UNKNOWN_VARIANT,
                        "Unknown dependent-chain kind " + record.scalar(2),
                        exception);
            }
            if (!record.scalar(7).equals(DEPENDENT_CHAIN_VERSION)
                    || !record.scalar(8).equals(DEPENDENT_CHAIN_DIGEST)) {
                throw theory("Dependent chain names another fixed source theory");
            }

            ChainView source = dependentChainInput(
                    record.child(0), kind, null);
            requireSoundDependentFlattening(kind, source.leafTypes());
            KernelModel.Term target = model.term(record.scalar(3));
            if (target.kind() != KernelModel.TermKind.APP
                    || !target.context().equals(source.context())
                    || target.children().size() != 1) {
                throw theory("Dependent-chain target is not one exact application");
            }
            KernelModel.Operator operator = model.operator(target.symbol());
            String identity = "ALLOY/DEPENDENT-CHAIN/" + kind.name();
            if (!operator.semanticIdentity().equals(identity)
                    || !operator.flatPath().equals("none")
                    || operator.schemas().size() != 1
                    || !type(operator.outputType(), "dependent-chain operator output")
                            .key().equals(source.outputType().key())) {
                throw theory("Dependent-chain target uses another operator instance");
            }
            KernelModel.Schema schema = model.schema(operator.schemas().get(0));
            if (!schema.isDependentSequence()
                    || schema.childSchemas().size() != source.leaves().size()
                    || !schema.arityPolicy().equals(new KernelModel.ArityPolicy(
                            false, -1, Set.of(source.leaves().size())))) {
                throw theory("Dependent-chain target lacks its exact positional Seq schema");
            }
            KernelModel.Term sequence = model.term(target.children().get(0));
            if (sequence.kind() != KernelModel.TermKind.SEQ
                    || !sequence.sort().value().equals(schema.id())
                    || !sequence.context().equals(source.context())
                    || sequence.children().size() != source.leaves().size()) {
                throw theory("Dependent-chain target is not one ordered Seq carrier");
            }
            for (int index = 0; index < source.leaves().size(); index++) {
                KernelModel.Term expected = source.leaves().get(index);
                if (!sequence.children().get(index).equals(expected.id())
                        || !expected.sort().value().equals(
                                schema.childSchemas().get(index))) {
                    throw theory("Dependent-chain target changed operand role " + index);
                }
            }

            StableKey theoryIndex = dependentChainTheoryIndex(
                    kind,
                    source.leafDags(),
                    source.outputDag());
            requireKey(record.scalar(9), theoryIndex,
                    "dependent-chain theory index");
            StableKey sourceOccurrenceCommitment = parseStableKey(
                    record.scalar(10), "dependent-chain source occurrence commitment");
            requireDependentChainSourceOccurrenceCommitment(
                    sourceOccurrenceCommitment, source.key());
            StableKey left = endpointDependentChain(
                    source, sourceOccurrenceCommitment);
            StableKey right = endpointNode(target);
            requireKey(record.scalar(4), left, "dependent-chain left endpoint");
            requireKey(record.scalar(5), right, "dependent-chain right endpoint");
            StableKey expectedCertificate = typedCertificate(
                    "DEPENDENT_CHAIN_NORMALIZATION",
                    left,
                    right,
                    List.of(
                            profile.key(),
                            StableKey.of(
                                    "dependent-chain-theory",
                                    List.of(DEPENDENT_CHAIN_DIGEST),
                                    List.of()),
                            theoryIndex,
                            source.key(),
                            sourceOccurrenceCommitment,
                            termKey(target)),
                    List.of());
            requireKey(record.scalar(0), expectedCertificate,
                    "dependent-chain certificate");
            verifiedChainConstructions.add(record.scalar(0));
            ConstructionEvidence prior = chainEvidence.putIfAbsent(
                    record.scalar(0),
                    new ConstructionEvidence(
                            record.scalar(0),
                            target.id(),
                            operator.id(),
                            "0/0",
                            record.scalar(4),
                            record.scalar(6)));
            if (prior != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate dependent-chain construction evidence key");
            }
        }

        private void requireSoundDependentFlattening(
                ChainKind kind,
                List<ExactType> operandTypes) {
            if (operandTypes.size() < 2) {
                throw theory("A dependent chain has fewer than two operands");
            }
            if (kind == ChainKind.JOIN && operandTypes.size() > 2) {
                for (int index = 1; index + 1 < operandTypes.size(); index++) {
                    ExactType interior = operandTypes.get(index);
                    Integer arity = relationArity(interior);
                    if (arity == null || arity < 2) {
                        throw theory(
                                "JOIN reassociation uses a unary interior operand");
                    }
                }
            }
        }

        private void requireDependentChainSourceOccurrenceCommitment(
                StableKey commitment,
                StableKey typedSourceKey) {
            if (!commitment.tag().equals(
                            "alloy-dependent-chain-source-occurrence-v1")
                    || commitment.scalars().size() != 1
                    || commitment.scalars().get(0).isBlank()
                    || commitment.children().size() != 2) {
                throw theory(
                        "Dependent-chain evidence lacks one exact Alloy source occurrence");
            }
            StableKey typedSource = commitment.children().get(0);
            if (!typedSource.equals(StableKey.of(
                    "alloy-dependent-chain-typed-source-v1",
                    List.of(),
                    List.of(typedSourceKey)))) {
                throw theory(
                        "Dependent-chain source occurrence names another typed source");
            }
            StableKey content = commitment.children().get(1);
            if (!content.tag().equals(
                            "alloy-dependent-chain-source-content-v1")
                    || content.scalars().size() != 1
                    || content.scalars().get(0).isEmpty()
                    || !content.children().isEmpty()) {
                throw theory(
                        "Dependent-chain source occurrence has malformed content evidence");
            }
        }

        private ChainView dependentChainInput(
                Wire.Node node,
                ChainKind expectedKind,
            KernelModel.Context expectedContext) {
            if (node.tag().equals("dependent-chain-leaf")) {
                node.requireShape("dependent-chain-leaf", 5, 1);
                KernelModel.Term term = model.term(node.scalar(0));
                KernelModel.Schema schema = model.schema(term.sort().value());
                if ((term.kind() != KernelModel.TermKind.ONE_SLOT
                                && term.kind() != KernelModel.TermKind.ONE_TERM)
                        || (schema.kind() != KernelModel.SchemaKind.ONE
                                && schema.kind() != KernelModel.SchemaKind.ONE_SLOT
                                && schema.kind() != KernelModel.SchemaKind.ONE_TERM)
                        || (expectedContext != null
                                && !term.context().equals(expectedContext))) {
                    throw theory("Dependent-chain leaf is not one exact relation port");
                }
                ExactType stored = type(schema.value(), "dependent-chain stored leaf");
                ExactType output = type(node.scalar(1), "dependent-chain relation view");
                LeafTypeRule rule = requireLeafTypeRule(stored, output);
                if (!node.scalar(2).equals(rule.name())) {
                    throw theory("Dependent-chain leaf names another typing rule");
                }
                StableKey typeProof = StableKey.of(
                        "dependent-chain-leaf-type-proof-v1",
                        List.of(rule.name()),
                        List.of(stored.key(), output.key()));
                requireKey(node.scalar(4), typeProof,
                        "dependent-chain leaf type proof");
                ChainDag dag = dependentTypeDag(node.child(0), output);
                StableKey key = StableKey.of(
                        "dependent-chain-leaf-v3",
                        List.of(),
                        List.of(
                                portKey(term),
                                typeProof,
                                dag.key()));
                requireKey(node.scalar(3), key, "dependent-chain leaf key");
                return new ChainView(
                        expectedKind,
                        term.context(),
                        dag,
                        key,
                        List.of(term),
                        List.of(output),
                        List.of(dag));
            }

            node.requireShape("dependent-chain-application", 4, 4);
            if (!node.scalar(0).equals(expectedKind.name())) {
                throw theory("Dependent source tree changes operator family");
            }
            KernelModel.Context context = model.context(node.scalar(1));
            if (expectedContext != null && !context.equals(expectedContext)) {
                throw theory("Dependent source tree changes caller context");
            }
            ChainView left = dependentChainInput(
                    node.child(0), expectedKind, context);
            ChainView right = dependentChainInput(
                    node.child(1), expectedKind, context);
            ExactType output = type(node.scalar(2), "dependent-chain application");
            ChainCombination combination = requireChainCombination(
                    expectedKind,
                    left.outputDag(),
                    right.outputDag());
            ChainDag outputDag = dependentTypeDag(node.child(2), output);
            if (!outputDag.equals(combination.outputDag())) {
                throw theory(
                        "Dependent-chain application serializes another output DAG");
            }
            requireCombinationCasesWire(
                    node.child(3), combination.cases());
            List<KernelModel.Term> leaves = new ArrayList<>(left.leaves());
            leaves.addAll(right.leaves());
            List<ExactType> leafTypes = new ArrayList<>(left.leafTypes());
            leafTypes.addAll(right.leafTypes());
            List<ChainDag> leafDags = new ArrayList<>(left.leafDags());
            leafDags.addAll(right.leafDags());
            StableKey key = StableKey.of(
                    "dependent-chain-application-v3",
                    List.of(expectedKind.name()),
                    List.of(
                    contextKey(context),
                    output.key(),
                    outputDag.key(),
                    left.key(),
                    right.key(),
                    StableKey.of(
                            "dependent-chain-combination-cases-v1",
                            List.of(),
                            combination.cases().stream()
                                    .map(CombinationCaseView::key)
                                    .toList())));
            requireKey(node.scalar(3), key, "dependent-chain application key");
            return new ChainView(
                    expectedKind,
                    context,
                    outputDag,
                    key,
                    List.copyOf(leaves),
                    List.copyOf(leafTypes),
                    List.copyOf(leafDags));
        }

        private ChainDag dependentTypeDag(
                Wire.Node node,
                ExactType expectedType) {
            node.requireShape(
                    "dependent-type-dag", 4, node.children().size());
            ExactType relationType = type(
                    node.scalar(0), "dependent type DAG relation family");
            if (!relationType.key().equals(expectedType.key())) {
                throw theory("A dependent type DAG names another relation family");
            }
            int arity = parsePositiveInt(
                    node.scalar(2), "dependent type DAG arity");
            if (node.children().isEmpty()) {
                Integer emptyArity = relationArity(relationType);
                if (emptyArity == null
                        || emptyRelationArity(relationType.symbol()) == null
                        || emptyArity != arity
                        || !"NONE".equals(node.scalar(1))) {
                    throw theory(
                            "An alternative-free dependent DAG is not one typed empty relation");
                }
                StableKey key = dependentTypeDagKey(
                        List.of(), relationType, null);
                requireKey(node.scalar(3), key, "dependent empty type DAG");
                return new ChainDag(relationType, List.of(), null, key);
            }
            List<ExactType> productTypes = relationProducts(
                    relationType, "dependent type DAG relation family");
            if (productTypes.size() != node.children().size()) {
                throw theory(
                        "A dependent type DAG changed its correlated alternatives");
            }
            if (productTypes.get(0).arguments().size() != arity) {
                throw theory("A dependent type DAG changed its relation arity");
            }
            List<List<ChainColumn>> alternatives = new ArrayList<>();
            for (int index = 0; index < productTypes.size(); index++) {
                alternatives.add(dependentTypeProduct(
                        node.child(index), index, productTypes.get(index)));
            }
            requireNormalizedAlternatives(alternatives);
            ExactType common = commonAncestorType(alternatives);
            if ("NONE".equals(node.scalar(1))) {
                if (common != null) {
                    throw theory(
                            "A dependent type DAG omitted its common ancestor");
                }
            } else {
                ExactType encoded = type(
                        node.scalar(1), "dependent type DAG common ancestor");
                if (common == null || !encoded.key().equals(common.key())) {
                    throw theory(
                            "A dependent type DAG changed its common ancestor");
                }
            }
            StableKey key = dependentTypeDagKey(
                    alternatives, relationType, common);
            requireKey(node.scalar(3), key, "dependent type DAG");
            return new ChainDag(
                    relationType,
                    List.copyOf(alternatives),
                    common,
                    key);
        }

        private List<ChainColumn> dependentTypeProduct(
                Wire.Node node,
                int expectedIndex,
                ExactType relationType) {
            requireRelation(relationType, "dependent type product");
            node.requireShape(
                    "dependent-type-product", 3, relationType.arguments().size());
            if (!Integer.toString(expectedIndex).equals(node.scalar(0))
                    || !type(node.scalar(1), "dependent type product")
                            .key().equals(relationType.key())) {
                throw theory("A dependent type product changed its index or type");
            }
            List<ChainColumn> columns = new ArrayList<>();
            for (int index = 0; index < node.children().size(); index++) {
                Wire.Node encoded = node.child(index);
                encoded.requireShape(
                        "dependent-chain-column", 2, encoded.children().size());
                if (encoded.children().isEmpty()) {
                    throw theory("A dependent column ancestry is empty");
                }
                ExactType exact = type(
                        encoded.scalar(0), "dependent-chain exact column");
                if (!exact.key().equals(relationType.arguments().get(index).key())) {
                    throw theory("Dependent column evidence names another relation column");
                }
                requireAtomicChainColumn(exact, "dependent-chain exact column");
                List<ExactType> ancestry = new ArrayList<>();
                Set<StableKey> seen = new HashSet<>();
                for (Wire.Node step : encoded.children()) {
                    step.requireShape("dependent-chain-ancestor", 1, 0);
                    ExactType ancestor = type(
                            step.scalar(0), "dependent-chain ancestor");
                    requireAtomicChainColumn(ancestor, "dependent-chain ancestor");
                    if (!seen.add(ancestor.key())) {
                        throw theory("Dependent column ancestry contains a cycle");
                    }
                    ancestry.add(ancestor);
                }
                if (!ancestry.get(0).key().equals(exact.key())) {
                    throw theory("Dependent column ancestry does not start at its exact type");
                }
                for (int indexInPath = 0;
                        indexInPath + 1 < ancestry.size();
                        indexInPath++) {
                    if ("AlloySig:univ".equals(
                            ancestry.get(indexInPath).symbol())) {
                        throw theory(
                                "AlloySig:univ must terminate a dependent ancestry");
                    }
                }
                ChainColumn column = new ChainColumn(
                        exact, List.copyOf(ancestry), chainColumnKey(exact, ancestry));
                requireKey(encoded.scalar(1), column.key(),
                        "dependent-chain column evidence");
                registerChainAncestry(column);
                columns.add(column);
            }
            StableKey key = dependentTypeProductKey(columns);
            requireKey(node.scalar(2), key, "dependent type product");
            return List.copyOf(columns);
        }

        private void registerChainAncestry(ChainColumn column) {
            List<StableKey> path = column.ancestry().stream()
                    .map(ExactType::key)
                    .toList();
            if (path.size() > 1) {
                hasUntrustedSubtypeHierarchy = true;
            }
            try {
                chainSubtypeStacks.register(column.exact().key(), path);
            } catch (IllegalArgumentException exception) {
                throw theory(exception.getMessage());
            }
        }

        private LeafTypeRule requireLeafTypeRule(
                ExactType stored,
                ExactType relation) {
            if (stored.key().equals(relation.key())
                    && relationArity(relation) != null) {
                return LeafTypeRule.EXACT_RELATION;
            }
            List<ExactType> alternatives = relationProducts(
                    relation, "dependent-chain relation view");
            if (alternatives.size() != 1
                    || alternatives.get(0).arguments().size() != 1) {
                throw theory("A primitive slot can justify only a unary relation view");
            }
            ExactType expectedColumn = primitiveRelationColumn(stored);
            if (expectedColumn == null
                    || !expectedColumn.key().equals(
                            alternatives.get(0).arguments().get(0).key())) {
                throw theory("Stored primitive type does not justify its relation view");
            }
            return LeafTypeRule.PRIMITIVE_SET_SINGLETON;
        }

        private ExactType primitiveRelationColumn(ExactType stored) {
            if (stored.is(TypeKind.INT)) {
                return stored;
            }
            if (!stored.is(TypeKind.CONSTRUCTOR)
                    || !"AlloyCarrier".equals(stored.symbol())
                    || stored.arguments().size() != 1) {
                return null;
            }
            ExactType carrier = stored.arguments().get(0);
            if (!carrier.is(TypeKind.CONSTRUCTOR)
                    || !carrier.arguments().isEmpty()) {
                return null;
            }
            String expected = carrier.symbol().startsWith("AlloySig:")
                    ? carrier.symbol() : "AlloySig:" + carrier.symbol();
            if (!isAdmittedAtomicChainColumn("CONSTRUCTOR", expected, 0)) {
                return null;
            }
            for (ExactType candidate : types.byId().values()) {
                if (candidate.is(TypeKind.CONSTRUCTOR)
                        && expected.equals(candidate.symbol())
                        && candidate.arguments().isEmpty()) {
                    return candidate;
                }
            }
            return null;
        }

        private ChainCombination requireChainCombination(
                ChainKind kind,
                ChainDag left,
                ChainDag right) {
            Integer leftArity = relationArity(left.relationType());
            Integer rightArity = relationArity(right.relationType());
            if (leftArity == null || rightArity == null) {
                throw theory("A dependent-chain operand has no positive relation arity");
            }
            int resultArity;
            try {
                resultArity = kind == ChainKind.ARROW
                        ? Math.addExact(leftArity, rightArity)
                        : Math.subtractExact(
                                Math.addExact(leftArity, rightArity), 2);
            } catch (ArithmeticException exception) {
                throw theory("Dependent-chain result arity overflows");
            }
            if (resultArity <= 0) {
                throw theory("JOIN dependent-chain claims a nullary relation");
            }
            List<List<ChainColumn>> products = new ArrayList<>();
            List<CombinationCaseView> cases = new ArrayList<>();
            for (int leftIndex = 0;
                    leftIndex < left.alternatives().size();
                    leftIndex++) {
                List<ChainColumn> leftProduct =
                        left.alternatives().get(leftIndex);
                for (int rightIndex = 0;
                        rightIndex < right.alternatives().size();
                        rightIndex++) {
                    List<ChainColumn> rightProduct =
                            right.alternatives().get(rightIndex);
                    if (kind == ChainKind.ARROW) {
                        List<ChainColumn> result = new ArrayList<>(leftProduct);
                        result.addAll(rightProduct);
                        List<ChainColumn> frozen = List.copyOf(result);
                        products.add(frozen);
                        cases.add(combinationCase(
                                leftIndex,
                                rightIndex,
                                CombinationDecision.ARROW_PRODUCT,
                                null,
                                frozen));
                        continue;
                    }
                    BoundaryView boundary = deriveBoundary(
                            leftProduct.get(leftProduct.size() - 1),
                            rightProduct.get(0));
                    if (boundary.rule() == BoundaryRule.DISJOINT_BRANCHES) {
                        cases.add(combinationCase(
                                leftIndex,
                                rightIndex,
                                CombinationDecision.JOIN_DISJOINT,
                                boundary,
                                null));
                        continue;
                    }
                    List<ChainColumn> result = new ArrayList<>();
                    result.addAll(leftProduct.subList(
                            0, leftProduct.size() - 1));
                    result.addAll(rightProduct.subList(
                            1, rightProduct.size()));
                    if (result.isEmpty()) {
                        throw theory(
                                "A positive JOIN result arity produced a nullary alternative");
                    }
                    List<ChainColumn> frozen = List.copyOf(result);
                    products.add(frozen);
                    cases.add(combinationCase(
                            leftIndex,
                            rightIndex,
                            CombinationDecision.JOIN_OVERLAP,
                            boundary,
                            frozen));
                }
            }
            ChainDag output = products.isEmpty()
                    ? emptyChainDag(resultArity)
                    : chainDagFromAlternatives(
                            normalizeAlternatives(products));
            return new ChainCombination(output, List.copyOf(cases));
        }

        private void requireColumnsMatch(
                ExactType relation,
                List<ChainColumn> columns,
                String role) {
            if (relation.arguments().size() != columns.size()
                    || !relation.arguments().stream().map(ExactType::key).toList()
                            .equals(columns.stream()
                                    .map(column -> column.exact().key()).toList())) {
                throw theory("Dependent-chain " + role
                        + " ancestry names another relation type");
            }
        }

        private BoundaryView deriveBoundary(
                ChainColumn left,
                ChainColumn right) {
            ExactType leftType = left.exact();
            ExactType rightType = right.exact();
            BoundaryRule rule;
            ExactType meet;
            ExactType common;
            List<ExactType> leftPath;
            List<ExactType> rightPath;
            if (leftType.key().equals(rightType.key())) {
                rule = BoundaryRule.EXACT;
                meet = leftType;
                common = leftType;
                leftPath = List.of(leftType);
                rightPath = List.of(rightType);
            } else {
                requireNominalChainSignature(leftType);
                requireNominalChainSignature(rightType);
                int rightInLeft = ancestryIndex(left.ancestry(), rightType);
                int leftInRight = ancestryIndex(right.ancestry(), leftType);
                if (rightInLeft > 0 && leftInRight > 0) {
                    throw theory("JOIN subtype evidence contains an ancestry cycle");
                }
                if (rightInLeft > 0) {
                    rule = BoundaryRule.LEFT_SUBTYPE_OF_RIGHT;
                    meet = leftType;
                    common = rightType;
                    leftPath = left.ancestry().subList(0, rightInLeft + 1);
                    rightPath = List.of(rightType);
                } else if (leftInRight > 0) {
                    rule = BoundaryRule.RIGHT_SUBTYPE_OF_LEFT;
                    meet = rightType;
                    common = leftType;
                    leftPath = List.of(leftType);
                    rightPath = right.ancestry().subList(0, leftInRight + 1);
                } else {
                    common = firstCommonAncestor(
                            left.ancestry(), right.ancestry());
                    if (common == null) {
                        throw theory(
                                "JOIN boundary lacks authenticated overlap or disjointness");
                    }
                    int leftCommon = ancestryIndex(left.ancestry(), common);
                    int rightCommon = ancestryIndex(right.ancestry(), common);
                    if (leftCommon <= 0 || rightCommon <= 0) {
                        throw theory(
                                "A divergent JOIN boundary has invalid common ancestry");
                    }
                    rule = BoundaryRule.DISJOINT_BRANCHES;
                    meet = null;
                    leftPath = left.ancestry().subList(0, leftCommon + 1);
                    rightPath = right.ancestry().subList(0, rightCommon + 1);
                }
                hasUntrustedSubtypeHierarchy = true;
            }
            StableKey key = boundaryKey(
                    rule,
                    leftType,
                    rightType,
                    meet,
                    common,
                    leftPath,
                    rightPath);
            return new BoundaryView(
                    rule,
                    leftType,
                    rightType,
                    meet,
                    common,
                    List.copyOf(leftPath),
                    List.copyOf(rightPath),
                    key);
        }

        private void requireCombinationCasesWire(
                Wire.Node node,
                List<CombinationCaseView> expected) {
            node.requireShape(
                    "dependent-chain-combination-cases", 1, expected.size());
            if (!Integer.toString(expected.size()).equals(node.scalar(0))) {
                throw theory("A dependent combination changed its matrix size");
            }
            for (int index = 0; index < expected.size(); index++) {
                CombinationCaseView proof = expected.get(index);
                Wire.Node encoded = node.child(index);
                encoded.requireShape(
                        "dependent-chain-combination-case", 4, 2);
                if (!Integer.toString(proof.leftAlternative())
                                .equals(encoded.scalar(0))
                        || !Integer.toString(proof.rightAlternative())
                                .equals(encoded.scalar(1))
                        || !proof.decision().name().equals(encoded.scalar(2))) {
                    throw theory(
                            "A dependent combination changed an alternative-pair decision");
                }
                requireBoundaryWire(encoded.child(0), proof.boundary());
                if (proof.resultAlternative() == null) {
                    encoded.child(1).requireShape(
                            "dependent-chain-no-result", 1, 0);
                    if (!"DISJOINT".equals(encoded.child(1).scalar(0))) {
                        throw theory("A disjoint JOIN case carries a result product");
                    }
                } else {
                    ExactType resultType = relationType(
                            proof.resultAlternative());
                    List<ChainColumn> parsed = dependentTypeProduct(
                            encoded.child(1), -1, resultType);
                    if (!parsed.equals(proof.resultAlternative())) {
                        throw theory(
                                "A dependent combination changed its result product");
                    }
                }
                requireKey(encoded.scalar(3), proof.key(),
                        "dependent combination case");
            }
        }

        private void requireBoundaryWire(
                Wire.Node node,
                BoundaryView expected) {
            if (expected == null) {
                node.requireShape("dependent-chain-no-boundary", 1, 0);
                if (!"ARROW".equals(node.scalar(0))) {
                    throw theory("ARROW source carries a JOIN boundary proof");
                }
                return;
            }
            node.requireShape(
                    "dependent-chain-boundary", 6, 2);
            if (!node.scalar(0).equals(expected.rule().name())
                    || !type(node.scalar(1), "left JOIN boundary").key()
                            .equals(expected.left().key())
                    || !type(node.scalar(2), "right JOIN boundary").key()
                            .equals(expected.right().key())
                    || !(expected.meet() == null
                            ? "NONE".equals(node.scalar(3))
                            : type(node.scalar(3), "JOIN boundary meet").key()
                                    .equals(expected.meet().key()))
                    || !type(node.scalar(4), "JOIN boundary common ancestor")
                            .key().equals(expected.common().key())) {
                throw theory("JOIN boundary wire does not match its derived correspondence");
            }
            List<StableKey> leftPath = boundaryPath(
                    node.child(0), "dependent-chain-boundary-left-path");
            List<StableKey> rightPath = boundaryPath(
                    node.child(1), "dependent-chain-boundary-right-path");
            if (!leftPath.equals(expected.leftPath().stream()
                            .map(ExactType::key).toList())
                    || !rightPath.equals(expected.rightPath().stream()
                            .map(ExactType::key).toList())) {
                throw theory("JOIN boundary witness paths were changed");
            }
            requireKey(node.scalar(5), expected.key(),
                    "JOIN boundary correspondence");
        }

        private List<StableKey> boundaryPath(
                Wire.Node node,
                String expectedTag) {
            node.requireShape(expectedTag, 0, node.children().size());
            if (node.children().isEmpty()) {
                throw theory("A JOIN boundary path is empty");
            }
            List<StableKey> path = new ArrayList<>();
            for (Wire.Node step : node.children()) {
                step.requireShape("dependent-chain-boundary-step", 1, 0);
                path.add(type(step.scalar(0), "JOIN boundary witness").key());
            }
            return List.copyOf(path);
        }

        private static int ancestryIndex(
                List<ExactType> ancestry,
                ExactType candidate) {
            for (int index = 0; index < ancestry.size(); index++) {
                if (ancestry.get(index).key().equals(candidate.key())) {
                    return index;
                }
            }
            return -1;
        }

        private void requireAtomicChainColumn(ExactType type, String label) {
            if (!isAdmittedAtomicChainColumn(
                    type.kind().name(), type.symbol(), type.arguments().size())) {
                throw theory(label + " is not an atomic Alloy carrier");
            }
        }

        private void requireNominalChainSignature(ExactType type) {
            if (type.is(TypeKind.INT)) {
                return;
            }
            if (!isAdmittedAtomicChainColumn(
                    type.kind().name(), type.symbol(), type.arguments().size())) {
                throw theory(
                        "Subtype JOIN correspondence requires Alloy signatures");
            }
        }

        private StableKey chainColumnKey(
                ExactType exact,
                List<ExactType> ancestry) {
            return StableKey.of(
                    "dependent-column-evidence-v1",
                    List.of(),
                    List.of(
                            exact.key(),
                            StableKey.of(
                                    "direct-parent-path-v1",
                                    List.of(),
                                    ancestry.stream().map(ExactType::key).toList())));
        }

        private StableKey dependentTypeProductKey(List<ChainColumn> columns) {
            return StableKey.of(
                    "dependent-type-product-v1",
                    List.of(),
                    columns.stream().map(ChainColumn::key).toList());
        }

        private StableKey boundaryKey(
                BoundaryRule rule,
                ExactType left,
                ExactType right,
                ExactType meet,
                ExactType common,
                List<ExactType> leftPath,
                List<ExactType> rightPath) {
            return StableKey.of(
                    "dependent-boundary-correspondence-v2",
                    List.of(rule.name()),
                    List.of(
                            left.key(),
                            right.key(),
                            meet == null
                                    ? StableKey.of(
                                            "dependent-boundary-empty-meet-v1",
                                            List.of("disjoint"),
                                            List.of())
                                    : meet.key(),
                            common.key(),
                            StableKey.of(
                                    "dependent-boundary-left-path-v1",
                                    List.of(),
                                    leftPath.stream().map(ExactType::key).toList()),
                            StableKey.of(
                                    "dependent-boundary-right-path-v1",
                                    List.of(),
                                    rightPath.stream().map(ExactType::key).toList())));
        }

        private void requireRelation(ExactType type, String label) {
            if (!type.is(TypeKind.RELATION) || type.arguments().isEmpty()) {
                throw theory(label + " is not an exact nonnullary relation type");
            }
        }

        private List<ExactType> relationProducts(
                ExactType type,
                String label) {
            if (type.is(TypeKind.RELATION) && !type.arguments().isEmpty()) {
                return List.of(type);
            }
            if (!type.is(TypeKind.CONSTRUCTOR)
                    || !"AlloyRelationUnion".equals(type.symbol())
                    || type.arguments().size() < 2) {
                throw theory(label + " is not a correlated relation family");
            }
            int arity = -1;
            ExactType previous = null;
            for (ExactType alternative : type.arguments()) {
                requireRelation(alternative, label + " alternative");
                if (arity < 0) {
                    arity = alternative.arguments().size();
                } else if (arity != alternative.arguments().size()) {
                    throw theory(label + " has mixed relation arity");
                }
                if (previous != null
                        && compareExactType(previous, alternative) >= 0) {
                    throw theory(label + " alternatives are not strictly normalized");
                }
                previous = alternative;
            }
            return type.arguments();
        }

        private ExactType relationType(List<ChainColumn> columns) {
            List<StableKey> expected = columns.stream()
                    .map(column -> column.exact().key())
                    .toList();
            for (ExactType candidate : types.byId().values()) {
                if (candidate.is(TypeKind.RELATION)
                        && candidate.arguments().stream()
                                .map(ExactType::key).toList().equals(expected)) {
                    return candidate;
                }
            }
            throw theory("A dependent product has no declared exact relation type");
        }

        private ExactType relationFamilyType(
                List<List<ChainColumn>> alternatives) {
            List<ExactType> products = alternatives.stream()
                    .map(this::relationType)
                    .sorted(this::compareExactType)
                    .toList();
            if (products.size() == 1) {
                return products.get(0);
            }
            List<StableKey> expected = products.stream()
                    .map(ExactType::key).toList();
            for (ExactType candidate : types.byId().values()) {
                if (candidate.is(TypeKind.CONSTRUCTOR)
                        && "AlloyRelationUnion".equals(candidate.symbol())
                        && candidate.arguments().stream()
                                .map(ExactType::key).toList().equals(expected)) {
                    return candidate;
                }
            }
            throw theory("A dependent DAG has no declared correlated family type");
        }

        private ChainDag chainDagFromAlternatives(
                List<List<ChainColumn>> alternatives) {
            if (alternatives.isEmpty()) {
                throw theory("A dependent DAG result has no alternatives");
            }
            ExactType relation = relationFamilyType(alternatives);
            ExactType common = commonAncestorType(alternatives);
            return new ChainDag(
                    relation,
                    List.copyOf(alternatives),
                    common,
                    dependentTypeDagKey(alternatives, relation, common));
        }

        private ChainDag emptyChainDag(int arity) {
            ExactType relation = null;
            String expected = EMPTY_RELATION_PREFIX + arity;
            for (ExactType candidate : types.byId().values()) {
                if (candidate.is(TypeKind.CONSTRUCTOR)
                        && candidate.arguments().isEmpty()
                        && expected.equals(candidate.symbol())) {
                    relation = candidate;
                    break;
                }
            }
            if (relation == null) {
                throw theory("A dependent empty DAG has no declared result type");
            }
            return new ChainDag(
                    relation,
                    List.of(),
                    null,
                    dependentTypeDagKey(List.of(), relation, null));
        }

        private List<List<ChainColumn>> normalizeAlternatives(
                List<List<ChainColumn>> source) {
            if (source.isEmpty()) {
                throw theory("A dependent relation family is empty");
            }
            int arity = source.get(0).size();
            Map<String, List<ChainColumn>> unique = new LinkedHashMap<>();
            for (List<ChainColumn> product : source) {
                if (product.isEmpty() || product.size() != arity) {
                    throw theory("A dependent relation family has mixed or nullary products");
                }
                ExactType productType = relationType(product);
                List<ChainColumn> previous = unique.putIfAbsent(
                        productType.key().stableString(), List.copyOf(product));
                if (previous != null && !previous.equals(product)) {
                    throw theory(
                            "One dependent product has conflicting ancestry evidence");
                }
            }
            List<List<ChainColumn>> candidates = new ArrayList<>(unique.values());
            List<List<ChainColumn>> result = new ArrayList<>();
            for (int candidateIndex = 0;
                    candidateIndex < candidates.size();
                    candidateIndex++) {
                boolean absorbed = false;
                for (int otherIndex = 0;
                        otherIndex < candidates.size();
                        otherIndex++) {
                    if (candidateIndex != otherIndex
                            && productSubtypeOrEqual(
                                    candidates.get(candidateIndex),
                                    candidates.get(otherIndex))) {
                        absorbed = true;
                        break;
                    }
                }
                if (!absorbed) {
                    result.add(candidates.get(candidateIndex));
                }
            }
            result.sort((left, right) -> compareExactType(
                    relationType(left), relationType(right)));
            return result.stream().map(List::copyOf).toList();
        }

        private void requireNormalizedAlternatives(
                List<List<ChainColumn>> alternatives) {
            List<List<ChainColumn>> normalized = normalizeAlternatives(alternatives);
            if (!normalized.equals(alternatives)) {
                throw theory(
                        "A dependent type DAG is not its normalized subtype antichain");
            }
        }

        private boolean productSubtypeOrEqual(
                List<ChainColumn> specific,
                List<ChainColumn> general) {
            if (specific.size() != general.size()) {
                return false;
            }
            boolean strict = false;
            for (int index = 0; index < specific.size(); index++) {
                ChainColumn left = specific.get(index);
                ChainColumn right = general.get(index);
                if (left.exact().key().equals(right.exact().key())) {
                    continue;
                }
                if (ancestryIndex(left.ancestry(), right.exact()) <= 0) {
                    return false;
                }
                strict = true;
                hasUntrustedSubtypeHierarchy = true;
            }
            return strict;
        }

        private ExactType commonAncestorType(
                List<List<ChainColumn>> alternatives) {
            if (alternatives.size() == 1) {
                return relationType(alternatives.get(0));
            }
            List<ChainColumn> first = alternatives.get(0);
            List<ChainColumn> common = new ArrayList<>();
            for (int column = 0; column < first.size(); column++) {
                ExactType ancestor = null;
                for (ExactType candidate : first.get(column).ancestry()) {
                    boolean present = true;
                    for (int alternative = 1;
                            alternative < alternatives.size();
                            alternative++) {
                        if (ancestryIndex(
                                alternatives.get(alternative).get(column).ancestry(),
                                candidate) < 0) {
                            present = false;
                            break;
                        }
                    }
                    if (present) {
                        ancestor = candidate;
                        break;
                    }
                }
                if (ancestor == null) {
                    return null;
                }
                common.add(new ChainColumn(
                        ancestor,
                        List.of(ancestor),
                        chainColumnKey(ancestor, List.of(ancestor))));
            }
            return relationType(common);
        }

        private ExactType firstCommonAncestor(
                List<ExactType> left,
                List<ExactType> right) {
            for (ExactType candidate : left) {
                if (ancestryIndex(right, candidate) >= 0) {
                    return candidate;
                }
            }
            return null;
        }

        private StableKey dependentTypeDagKey(
                List<List<ChainColumn>> alternatives,
                ExactType relation,
                ExactType common) {
            Integer arity = relationArity(relation);
            if (arity == null || arity <= 0) {
                throw theory("A dependent DAG key has no positive relation arity");
            }
            return StableKey.of(
                    "dependent-type-dag-v1",
                    List.of(Integer.toString(arity)),
                    List.of(
                            StableKey.of(
                                    "dependent-type-correlated-alternatives-v1",
                                    List.of(),
                                    alternatives.stream()
                                            .map(this::dependentTypeProductKey)
                                            .toList()),
                            relation.key(),
                            common == null
                                    ? StableKey.of(
                                            "dependent-type-no-common-ancestor-v1",
                                            List.of("none"),
                                            List.of())
                                    : common.key()));
        }

        private CombinationCaseView combinationCase(
                int leftAlternative,
                int rightAlternative,
                CombinationDecision decision,
                BoundaryView boundary,
                List<ChainColumn> resultAlternative) {
            if (decision == CombinationDecision.ARROW_PRODUCT
                    ? boundary != null || resultAlternative == null
                    : decision == CombinationDecision.JOIN_OVERLAP
                            ? boundary == null
                                    || boundary.rule() == BoundaryRule.DISJOINT_BRANCHES
                                    || resultAlternative == null
                            : boundary == null
                                    || boundary.rule() != BoundaryRule.DISJOINT_BRANCHES
                                    || resultAlternative != null) {
                throw theory("A dependent combination case is internally inconsistent");
            }
            StableKey key = StableKey.of(
                    "dependent-type-combination-case-v1",
                    List.of(
                            Integer.toString(leftAlternative),
                            Integer.toString(rightAlternative),
                            decision.name()),
                    List.of(
                            boundary == null
                                    ? StableKey.of(
                                            "dependent-type-no-boundary-v1",
                                            List.of("arrow"),
                                            List.of())
                                    : boundary.key(),
                            resultAlternative == null
                                    ? StableKey.of(
                                            "dependent-type-empty-result-v1",
                                            List.of("disjoint"),
                                            List.of())
                                    : StableKey.of(
                                            "dependent-type-case-result-v1",
                                            List.of(),
                                            resultAlternative.stream()
                                                    .map(ChainColumn::key)
                                                    .toList())));
            return new CombinationCaseView(
                    leftAlternative,
                    rightAlternative,
                    decision,
                    boundary,
                    resultAlternative == null ? null : List.copyOf(resultAlternative),
                    key);
        }

        private StableKey dependentChainTheoryIndex(
                ChainKind kind,
                List<ChainDag> leafDags,
                ChainDag result) {
            if (leafDags.size() < 2) {
                throw theory("A dependent chain requires at least two operands");
            }
            List<StableKey> foldSteps = new ArrayList<>();
            ChainDag folded = leafDags.get(0);
            for (int index = 1; index < leafDags.size(); index++) {
                ChainDag right = leafDags.get(index);
                ChainCombination combination = requireChainCombination(
                        kind, folded, right);
                foldSteps.add(StableKey.of(
                        "dependent-chain-fold-step-v1",
                        List.of(Integer.toString(index)),
                        List.of(
                                folded.key(),
                                right.key(),
                                StableKey.of(
                                        "dependent-chain-complete-case-matrix-v1",
                                        List.of(),
                                        combination.cases().stream()
                                                .map(CombinationCaseView::key)
                                                .toList()),
                                combination.outputDag().key())));
                folded = combination.outputDag();
            }
            if (!folded.equals(result)) {
                throw theory("Dependent chain flat fold has another result DAG");
            }
            return StableKey.of(
                    "dependent-chain-theory-index-v3",
                    List.of(
                            DEPENDENT_CHAIN_VERSION,
                            DEPENDENT_CHAIN_DIGEST,
                            kind.name()),
                    List.of(
                            StableKey.of(
                                    "dependent-chain-operand-dags-v1",
                                    List.of(),
                                    leafDags.stream().map(ChainDag::key).toList()),
                            StableKey.of(
                                    "dependent-chain-fold-steps-v1",
                                    List.of(), foldSteps),
                            result.key()));
        }

        private int compareExactType(ExactType left, ExactType right) {
            int compared = Integer.compare(
                    left.kind().ordinal(), right.kind().ordinal());
            if (compared != 0) {
                return compared;
            }
            String leftSymbol = left.symbol();
            String rightSymbol = right.symbol();
            if (leftSymbol == null) {
                compared = rightSymbol == null ? 0 : -1;
            } else {
                compared = rightSymbol == null ? 1
                        : leftSymbol.compareTo(rightSymbol);
            }
            if (compared != 0) {
                return compared;
            }
            int shared = Math.min(
                    left.arguments().size(), right.arguments().size());
            for (int index = 0; index < shared; index++) {
                compared = compareExactType(
                        left.arguments().get(index),
                        right.arguments().get(index));
                if (compared != 0) {
                    return compared;
                }
            }
            return Integer.compare(
                    left.arguments().size(), right.arguments().size());
        }

        private FlatView flatInput(
                Wire.Node node,
                KernelModel.Operator expectedOperator,
                KernelModel.Context expectedContext,
                List<Integer> path,
                List<FlatSplice> splices) {
            if (node.tag().equals("flat-leaf")) {
                node.requireShape("flat-leaf", 1, 0);
                KernelModel.Term term = model.term(node.scalar(0));
                KernelModel.Schema element = model.schema(
                        model.schema(expectedOperator.schemas().get(0)).childSchema());
                if (term.sort().kind() != KernelModel.SortKind.PORT
                        || !term.sort().value().equals(element.id())
                        || (expectedContext != null
                            && !term.context().equals(expectedContext))) {
                    throw theory("Flat leaf has the wrong schema or caller context");
                }
                return FlatView.leaf(term, StableKey.of(
                        "flat-input/leaf",
                        List.of(),
                        List.of(portKey(term))));
            }
            node.requireTag("flat-application");
            if (node.scalars().size() != 4) {
                throw malformed("flat application");
            }
            KernelModel.Operator operator = model.operator(node.scalar(0));
            KernelModel.Context context = model.context(node.scalar(1));
            int arity = parseNonnegative(node.scalar(2), "flat source arity");
            if (!operator.equals(expectedOperator)
                    || (expectedContext != null && !context.equals(expectedContext))
                    || arity != node.children().size()
                    || !model.schema(operator.schemas().get(0))
                            .arityPolicy().admits(arity)) {
                throw theory("Flat source crosses an operator, context, or arity boundary");
            }
            List<StableKey> children = new ArrayList<>(arity + 2);
            children.add(operatorKey(operator));
            children.add(contextKey(context));
            List<KernelModel.Term> leaves = new ArrayList<>();
            for (int position = 0; position < node.children().size(); position++) {
                Wire.Node child = node.child(position);
                List<Integer> childPath = new ArrayList<>(path);
                childPath.add(position);
                FlatView operand = flatInput(
                        child, operator, context, childPath, splices);
                if (!operand.leaf()) {
                    splices.add(new FlatSplice(
                            List.copyOf(childPath),
                            arity,
                            operand.arity(),
                            position,
                            operand.key()));
                }
                children.add(operand.key());
                leaves.addAll(operand.leafTerms());
            }
            StableKey key = StableKey.of(
                    "flat-input/application", List.of(), children);
            requireKey(node.scalar(3), key, "flat application key");
            return FlatView.application(operator, context, arity, key, leaves);
        }

        private void verifySplice(Wire.Node node, FlatSplice expected) {
            node.requireShape("splice", 5, 0);
            List<String> actual = node.scalars();
            List<String> required = List.of(
                    encodePath(expected.path()),
                    Integer.toString(expected.outerArity()),
                    Integer.toString(expected.nestedArity()),
                    Integer.toString(expected.position()),
                    expected.nestedSource().stableString());
            if (!actual.equals(required)) {
                throw theory("Flat splice does not reconstruct from the visible source tree");
            }
            requireKey(node.scalar(4), expected.nestedSource(),
                    "flat splice nested source");
        }

        private void verifyContainer(Wire.Node record) {
            record.requireShape("container-construction", 8, 2);
            requireFingerprint(record.scalar(1), "container construction");
            KernelModel.Operator operator = model.operator(record.scalar(2));
            if (!operator.flatPath().equals("none")
                    || !record.scalar(3).equals("0/0")
                    || operator.schemas().size() != 1) {
                throw theory("Container evidence does not name one exact nonflat root port");
            }
            KernelModel.Schema schema = model.schema(operator.schemas().get(0));
            if (!isHomogeneousContainer(schema)) {
                throw theory("Container evidence names a non-homogeneous container schema");
            }
            Map<Law, ExpectedLaw> operatorLaws = requireOperatorLaws(operator, "0/0");
            Wire.Node inputsNode = record.child(0).requireTag("input-occurrences");
            if (!inputsNode.scalars().isEmpty()) {
                throw malformed("container input occurrences");
            }
            List<KernelModel.Term> inputs = new ArrayList<>();
            for (Wire.Node input : inputsNode.children()) {
                input.requireShape("input", 1, 0);
                KernelModel.Term term = model.term(input.scalar(0));
                requireContainerElement(schema, null, term, "container input");
                inputs.add(term);
            }
            if (!schema.arityPolicy().admits(inputs.size())) {
                throw theory("Container evidence uses an inadmissible source arity");
            }
            KernelModel.Term target = model.term(record.scalar(4));
            KernelModel.Context context = target.context();
            for (KernelModel.Term input : inputs) {
                requireContainerElement(schema, context, input, "container input");
            }
            Normalization normalized = normalize(schema, context, inputs);
            requireTargetNode(operator, context, target, normalized);
            TraceView trace = verifyTrace(
                    record.child(1), schema, context, inputs, normalized);

            StableKey left = endpointContainerApplication(
                    operator, context, inputs);
            StableKey right = endpointNode(target);
            requireKey(record.scalar(5), left, "container left endpoint");
            requireKey(record.scalar(6), right, "container right endpoint");

            List<StableKey> premises = new ArrayList<>();
            if ((schema.kind() == KernelModel.SchemaKind.BAG
                            || schema.kind() == KernelModel.SchemaKind.SET)
                    && inputs.size() > 1) {
                premises.add(lawCertificateKey(requireLaw(
                        operatorLaws, Law.COMMUTATIVITY,
                        "container commutative quotient")));
            }
            if (trace.deduplicated()) {
                premises.add(lawCertificateKey(requireLaw(
                        operatorLaws, Law.IDEMPOTENCY,
                        "container idempotent quotient")));
            }
            List<StableKey> details = List.of(
                    profile.key(),
                    operatorKey(operator),
                    StableKey.of("port-path", List.of("0/0"), List.of()),
                    termKey(target),
                    trace.key());
            requireKey(record.scalar(0), typedCertificate(
                    "CONTAINER_NORMALIZATION", left, right, details, premises),
                    "container construction certificate");
            verifiedContainerConstructions.add(record.scalar(0));
            ConstructionEvidence prior = containerEvidence.putIfAbsent(
                    record.scalar(0),
                    new ConstructionEvidence(
                            record.scalar(0), target.id(), operator.id(), record.scalar(3),
                            record.scalar(5), record.scalar(7)));
            if (prior != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate container construction evidence key");
            }
        }

        private void requireTargetNode(
                KernelModel.Operator operator,
                KernelModel.Context context,
                KernelModel.Term target,
                Normalization normalized) {
            if (target.kind() != KernelModel.TermKind.APP
                    || !target.symbol().equals(operator.id())
                    || !target.context().equals(context)
                    || target.children().size() != 1) {
                throw theory("Construction target is not the exact root operator node");
            }
            KernelModel.Term targetContainer = model.term(target.children().get(0));
            if (!termKey(targetContainer).equals(normalized.containerKey())) {
                throw theory("Construction target is not the independently normalized container");
            }
        }

        private void requireContainerElement(
                KernelModel.Schema container,
                KernelModel.Context context,
                KernelModel.Term term,
                String label) {
            if (!isHomogeneousContainer(container)) {
                throw theory(label + " cannot use a dependent positional sequence");
            }
            if (term.sort().kind() != KernelModel.SortKind.PORT
                    || !term.sort().value().equals(container.childSchema())
                    || (context != null && !term.context().equals(context))) {
                throw theory(label + " has the wrong exact schema or context");
            }
        }

        private Normalization normalize(
                KernelModel.Schema schema,
                KernelModel.Context context,
                List<KernelModel.Term> inputs) {
            if (!isHomogeneousContainer(schema)) {
                throw theory(
                        "Generic container normalization cannot consume a dependent sequence");
            }
            List<IndexedTerm> indexed = new ArrayList<>();
            for (int index = 0; index < inputs.size(); index++) {
                KernelModel.Term term = inputs.get(index);
                requireContainerElement(schema, context, term, "normalization input");
                indexed.add(new IndexedTerm(index, term, termKey(term)));
            }
            List<KernelModel.Term> outputs = new ArrayList<>();
            List<StableKey> outputKeys = new ArrayList<>();
            List<List<Integer>> fibers = new ArrayList<>();
            if (schema.kind() == KernelModel.SchemaKind.SEQ) {
                for (IndexedTerm value : indexed) {
                    outputs.add(value.term());
                    outputKeys.add(value.key());
                    fibers.add(List.of(value.index()));
                }
            } else {
                Map<String, List<IndexedTerm>> groups = new java.util.TreeMap<>();
                for (IndexedTerm value : indexed) {
                    groups.computeIfAbsent(
                            value.key().stableString(), ignored -> new ArrayList<>())
                            .add(value);
                }
                for (List<IndexedTerm> group : groups.values()) {
                    if (schema.kind() == KernelModel.SchemaKind.BAG) {
                        for (IndexedTerm value : group) {
                            outputs.add(value.term());
                            outputKeys.add(value.key());
                            fibers.add(List.of(value.index()));
                        }
                    } else if (schema.kind() == KernelModel.SchemaKind.SET) {
                        outputs.add(group.get(0).term());
                        outputKeys.add(group.get(0).key());
                        fibers.add(group.stream().map(IndexedTerm::index).toList());
                    } else {
                        throw theory("Normalization evidence uses a non-container schema");
                    }
                }
            }
            String tag = switch (schema.kind()) {
                case SEQ -> "port/seq";
                case BAG -> "port/bag";
                case SET -> "port/set";
                default -> throw theory("Normalization evidence uses a rigid schema");
            };
            List<StableKey> children = new ArrayList<>(outputKeys.size() + 2);
            children.add(schemaKey(schema));
            children.add(contextKey(context));
            children.addAll(outputKeys);
            return new Normalization(
                    List.copyOf(outputs),
                    List.copyOf(outputKeys),
                    List.copyOf(fibers),
                    StableKey.of(tag, List.of(), children));
        }

        private TraceView verifyTrace(
                Wire.Node node,
                KernelModel.Schema schema,
                KernelModel.Context context,
                List<KernelModel.Term> inputs,
                Normalization normalized) {
            node.requireTag("container-trace");
            if (node.scalars().size() != 5
                    || !node.scalar(0).equals(schema.id())
                    || !node.scalar(1).equals(context.id())
                    || parseNonnegative(node.scalar(2), "trace input count")
                            != inputs.size()
                    || parseNonnegative(node.scalar(3), "trace output count")
                            != normalized.outputTerms().size()
                    || node.children().size()
                            != inputs.size() + normalized.outputTerms().size()) {
                throw malformed("container trace");
            }
            List<StableKey> traceChildren = new ArrayList<>();
            for (int index = 0; index < inputs.size(); index++) {
                Wire.Node input = node.child(index).requireShape("trace-input", 1, 0);
                if (!input.scalar(0).equals(inputs.get(index).id())) {
                    throw theory("Container trace input order differs from source occurrences");
                }
                traceChildren.add(StableKey.of(
                        "container-application/input", List.of(),
                        List.of(termKey(inputs.get(index)))));
            }
            boolean reordered = inputs.size() != normalized.outputTerms().size();
            for (int index = 0; index < normalized.outputTerms().size(); index++) {
                Wire.Node output = node.child(inputs.size() + index);
                output.requireTag("trace-output");
                if (!output.children().isEmpty() || output.scalars().isEmpty()
                        || !output.scalar(0).equals(
                                normalized.outputTerms().get(index).id())) {
                    throw malformed("container trace output");
                }
                List<Integer> fiber = new ArrayList<>();
                for (int scalar = 1; scalar < output.scalars().size(); scalar++) {
                    fiber.add(parseNonnegative(
                            output.scalar(scalar), "container fiber index"));
                }
                if (!fiber.equals(normalized.fibers().get(index))) {
                    throw theory("Container trace fiber is not the exact quotient fiber");
                }
                reordered |= !fiber.equals(List.of(index));
                traceChildren.add(StableKey.of(
                        "container-application/output",
                        fiber.stream().map(Object::toString).toList(),
                        List.of(normalized.outputKeys().get(index))));
            }
            List<StableKey> keyChildren = new ArrayList<>();
            keyChildren.add(schemaKey(schema));
            keyChildren.add(contextKey(context));
            keyChildren.addAll(traceChildren);
            StableKey key = StableKey.of(
                    "container-application-trace-v1", List.of(), keyChildren);
            requireKey(node.scalar(4), key, "container trace key");
            boolean deduplicated = schema.kind() == KernelModel.SchemaKind.SET
                    && normalized.outputTerms().size() < inputs.size();
            return new TraceView(key, reordered, deduplicated);
        }

        private StableKey termKey(KernelModel.Term term) {
            return termKey(term, null);
        }

        private StableKey termKey(KernelModel.Term term, TermOps dynamicTerms) {
            StableKey prior = termKeys.get(term.id());
            if (prior != null) {
                return prior;
            }
            StableKey key = switch (term.kind()) {
                case APP -> {
                    KernelModel.Operator operator = model.operator(term.symbol());
                    List<StableKey> children = new ArrayList<>();
                    children.add(operatorKey(operator));
                    children.add(contextKey(term.context()));
                    for (String child : term.children()) {
                        children.add(portKey(resolveTerm(child, dynamicTerms), dynamicTerms));
                    }
                    yield StableKey.of("e-node", List.of(), children);
                }
                case INVOKE -> invocationKey(term, dynamicTerms);
                case ONE_SLOT, ONE_TERM, SEQ, BAG, SET, BIND, BIND_BLOCK ->
                        portKey(term, dynamicTerms);
                default -> throw theory(
                        "Semantic evidence references non-semantic term " + term.kind());
            };
            termKeys.put(term.id(), key);
            return key;
        }

        private StableKey canonicalShapeKey(
                KernelModel.Term term,
                TermOps dynamicTerms) {
            if (term.kind() != KernelModel.TermKind.APP) {
                throw theory("Canonical orbit candidate is not an e-node application");
            }
            return StableKey.of(
                    "canonical-shape", List.of(), List.of(termKey(term, dynamicTerms)));
        }

        private KernelModel.Term resolveTerm(String id, TermOps dynamicTerms) {
            return dynamicTerms == null ? model.term(id) : dynamicTerms.term(id);
        }

        private StableKey portKey(KernelModel.Term term) {
            return portKey(term, null);
        }

        private StableKey portKey(KernelModel.Term term, TermOps dynamicTerms) {
            KernelModel.Schema schema = model.schema(term.sort().value());
            List<StableKey> children = new ArrayList<>();
            children.add(schemaKey(schema));
            children.add(contextKey(term.context()));
            switch (term.kind()) {
                case ONE_SLOT -> children.add(StableKey.of(
                        "port-leaf/slot", List.of(),
                        List.of(slotKey(term.context().slot(term.attributes().get(0))))));
                case ONE_TERM -> children.add(StableKey.of(
                        "port-leaf/invocation", List.of(),
                        List.of(invocationKey(
                                resolveTerm(term.children().get(0), dynamicTerms),
                                dynamicTerms))));
                case SEQ, BAG, SET -> {
                    List<StableKey> values = term.children().stream()
                            .map(child -> resolveTerm(child, dynamicTerms))
                            .map(child -> portKey(child, dynamicTerms))
                            .collect(java.util.stream.Collectors.toCollection(ArrayList::new));
                    if (term.kind() != KernelModel.TermKind.SEQ) {
                        values.sort(StableKey::compareTo);
                    }
                    if (term.kind() == KernelModel.TermKind.SET) {
                        for (int index = 1; index < values.size(); index++) {
                            if (values.get(index - 1).equals(values.get(index))) {
                                throw theory("Serialized Set port retains a duplicate value");
                            }
                        }
                    }
                    children.addAll(values);
                }
                case BIND -> {
                    children.add(slotKey(resolveTerm(term.children().get(0), dynamicTerms)
                            .context().slot(term.attributes().get(0))));
                    children.add(portKey(
                            resolveTerm(term.children().get(0), dynamicTerms), dynamicTerms));
                }
                case BIND_BLOCK -> {
                    children.add(embeddingKey(model.embedding(term.attributes().get(0))));
                    children.add(portKey(
                            resolveTerm(term.children().get(0), dynamicTerms), dynamicTerms));
                }
                default -> throw theory("Expected a concrete port term, got " + term.kind());
            }
            String tag = switch (term.kind()) {
                case ONE_SLOT, ONE_TERM -> "port/one";
                case SEQ -> "port/seq";
                case BAG -> "port/bag";
                case SET -> "port/set";
                case BIND -> "port/bind";
                case BIND_BLOCK -> "port/bind-block";
                default -> throw new AssertionError();
            };
            return StableKey.of(tag, List.of(), children);
        }

        private StableKey invocationKey(KernelModel.Term term) {
            return invocationKey(term, null);
        }

        private StableKey invocationKey(
                KernelModel.Term term,
                TermOps dynamicTerms) {
            if (term.kind() != KernelModel.TermKind.INVOKE
                    || term.attributes().size() != 1) {
                throw theory("One-port term is not an exact invocation");
            }
            KernelModel.Witness witness = model.witness(term.symbol());
            StableKey eclass = StableKey.of(
                    "eclass",
                    List.of(canonicalEclass(witness.eclass())),
                    List.of(
                            type(witness.type(), "invocation witness").key(),
                            contextKey(witness.context())));
            return StableKey.of(
                    "invocation", List.of(),
                    List.of(eclass, embeddingKey(model.embedding(term.attributes().get(0)))));
        }

        private String canonicalEclass(String value) {
            if (value.length() < 2 || value.charAt(0) != 'e') {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "E-class identifier must use the producer e<decimal> grammar");
            }
            String decimal = value.substring(1);
            long parsed = Bundle.parseUnsignedLong(decimal, "e-class identifier");
            if (!Long.toString(parsed).equals(decimal)) {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        "E-class identifier is not canonical");
            }
            return decimal;
        }

        private StableKey operatorKey(KernelModel.Operator operator) {
            StableKey prior = operatorKeys.get(operator.id());
            if (prior != null) {
                return prior;
            }
            List<StableKey> schemaChildren = operator.schemas().stream()
                    .map(model::schema).map(this::schemaKey).toList();
            StableKey flat = StableKey.of(
                    "flat-license", List.of(operator.flatPath()), List.of());
            List<StableKey> declarationChildren = new ArrayList<>(schemaChildren);
            declarationChildren.add(type(operator.outputType(), "operator output").key());
            declarationChildren.add(flat);
            for (int port = 0; port < operator.schemas().size(); port++) {
                collectLawDeclarations(
                        operator,
                        model.schema(operator.schemas().get(port)),
                        port,
                        0,
                        declarationChildren);
            }
            String flatLabel = operator.flatPath().equals("none")
                    ? "nonflat" : "flat@" + operator.flatPath();
            StableKey declaration = StableKey.of(
                    "operator-declaration",
                    List.of(operator.semanticIdentity(), flatLabel),
                    declarationChildren);
            List<StableKey> instantiated = new ArrayList<>();
            instantiated.add(declaration);
            instantiated.addAll(schemaChildren);
            instantiated.add(type(operator.outputType(), "operator output").key());
            StableKey result = StableKey.of(
                    "instantiated-operator",
                    List.of(operator.semanticIdentity()),
                    instantiated);
            if (operator.id().startsWith(POLYMORPHIC_OPERATOR_KEY_PREFIX)) {
                result = verifiedPolymorphicOperatorKey(
                        operator, schemaChildren, flat, result);
            }
            operatorKeys.put(operator.id(), result);
            return result;
        }

        private StableKey verifiedPolymorphicOperatorKey(
                KernelModel.Operator operator,
                List<StableKey> instantiatedSchemas,
                StableKey flat,
                StableKey monomorphicProjection) {
            String suffix = operator.id().substring(
                    POLYMORPHIC_OPERATOR_KEY_PREFIX.length());
            int separator = suffix.indexOf('/');
            if (separator != 64 || separator + 1 >= suffix.length()) {
                throw theory("Polymorphic operator key commitment is malformed");
            }
            String digest = suffix.substring(0, separator);
            String encoded = suffix.substring(separator + 1);
            byte[] decoded;
            try {
                decoded = Base64.getUrlDecoder().decode(encoded);
            } catch (IllegalArgumentException exception) {
                throw theory("Polymorphic operator key commitment is not canonical Base64");
            }
            if (decoded.length > limits.maxStringBytes()
                    || !encoded.equals(Base64.getUrlEncoder().withoutPadding()
                            .encodeToString(decoded))) {
                throw theory("Polymorphic operator key commitment exceeds its bound or is noncanonical");
            }
            String stable = decodeCanonicalUtf8(
                    decoded, "polymorphic operator key commitment");
            if (!digest.equals(sha256(stable))) {
                throw theory("Polymorphic operator key commitment digest mismatch");
            }
            StableKey committed = parseStableKey(stable, "polymorphic operator key");
            validatePolymorphicOperatorKey(
                    operator, committed, instantiatedSchemas, flat, monomorphicProjection);
            return committed;
        }

        private void validatePolymorphicOperatorKey(
                KernelModel.Operator operator,
                StableKey committed,
                List<StableKey> instantiatedSchemas,
                StableKey flat,
                StableKey monomorphicProjection) {
            if (!committed.tag().equals("instantiated-operator")
                    || committed.scalars().size() < 2
                    || !committed.scalars().get(0).equals(operator.semanticIdentity())) {
                throw theory("Polymorphic operator commitment has the wrong outer declaration");
            }
            List<String> parameters = committed.scalars().subList(
                    1, committed.scalars().size());
            Set<String> unique = new java.util.LinkedHashSet<>();
            for (String parameter : parameters) {
                if (!unique.add(requireCanonicalIdentity(
                        parameter, "type parameter"))) {
                    throw theory("Polymorphic operator repeats a type parameter");
                }
            }
            int schemaCount = instantiatedSchemas.size();
            int expectedChildren = 1 + parameters.size() + schemaCount + 1;
            if (committed.children().size() != expectedChildren) {
                throw theory("Polymorphic operator commitment has the wrong instantiated arity");
            }
            StableKey declaration = committed.children().get(0);
            String flatLabel = operator.flatPath().equals("none")
                    ? "nonflat" : "flat@" + operator.flatPath();
            List<String> declarationScalars = new ArrayList<>();
            declarationScalars.add(operator.semanticIdentity());
            declarationScalars.addAll(parameters);
            declarationScalars.add(flatLabel);
            if (!declaration.tag().equals("operator-declaration")
                    || !declaration.scalars().equals(declarationScalars)
                    || declaration.children().size() < schemaCount + 2) {
                throw theory("Polymorphic declaration commitment is malformed");
            }

            Map<String, StableKey> substitution = new LinkedHashMap<>();
            for (int index = 0; index < parameters.size(); index++) {
                StableKey argument = committed.children().get(1 + index);
                if (!argument.tag().equals("type-argument")
                        || !argument.scalars().equals(List.of(parameters.get(index)))
                        || argument.children().size() != 1) {
                    throw theory("Polymorphic substitution ledger is incomplete or reordered");
                }
                StableKey type = argument.children().get(0);
                requireTypeKey(type, "polymorphic type argument");
                substitution.put(parameters.get(index), type);
            }

            int instantiatedOffset = 1 + parameters.size();
            for (int index = 0; index < schemaCount; index++) {
                if (!committed.children().get(instantiatedOffset + index)
                        .equals(instantiatedSchemas.get(index))) {
                    throw theory("Polymorphic instantiated schema differs from the wire schema");
                }
            }
            StableKey output = type(operator.outputType(), "operator output").key();
            if (!committed.children().get(instantiatedOffset + schemaCount).equals(output)) {
                throw theory("Polymorphic instantiated output differs from the wire output");
            }

            Set<String> usedVariables = new java.util.LinkedHashSet<>();
            for (int index = 0; index < schemaCount; index++) {
                StableKey declaredSchema = declaration.children().get(index);
                collectTypeVariables(declaredSchema, usedVariables);
                if (!substituteTypes(declaredSchema, substitution)
                        .equals(instantiatedSchemas.get(index))) {
                    throw theory("Polymorphic schema substitution does not replay");
                }
            }
            StableKey declaredOutput = declaration.children().get(schemaCount);
            collectTypeVariables(declaredOutput, usedVariables);
            requireTypeKey(declaredOutput, "polymorphic declared output");
            if (!substituteTypes(declaredOutput, substitution).equals(output)) {
                throw theory("Polymorphic output substitution does not replay");
            }
            if (!unique.containsAll(usedVariables)) {
                throw theory("Polymorphic declaration uses an undeclared type variable");
            }
            if (!declaration.children().get(schemaCount + 1).equals(flat)) {
                throw theory("Polymorphic declaration changes its flat license");
            }

            List<StableKey> expectedLawChildren = new ArrayList<>();
            for (int port = 0; port < operator.schemas().size(); port++) {
                collectLawDeclarations(
                        operator,
                        model.schema(operator.schemas().get(port)),
                        port,
                        0,
                        expectedLawChildren);
            }
            List<StableKey> committedLawChildren = declaration.children().subList(
                    schemaCount + 2, declaration.children().size());
            if (!committedLawChildren.equals(expectedLawChildren)) {
                throw theory("Polymorphic declaration law ledger differs from checked evidence");
            }

            if (parameters.isEmpty() || committed.equals(monomorphicProjection)) {
                throw theory("Polymorphic key commitment does not retain a nonempty substitution");
            }
        }

        private void requireTypeKey(StableKey key, String owner) {
            String kind = key.tag();
            if (!kind.startsWith("type/")) {
                throw theory(owner + " is not a structural type");
            }
            String suffix = kind.substring("type/".length());
            boolean valid = switch (suffix) {
                case "TYPE_VARIABLE" -> key.scalars().size() == 1
                        && key.children().isEmpty();
                case "INT", "BOOL" -> key.scalars().isEmpty()
                        && key.children().isEmpty();
                case "ARROW" -> key.scalars().isEmpty()
                        && key.children().size() == 2;
                case "RELATION" -> key.scalars().isEmpty()
                        && !key.children().isEmpty();
                case "CONSTRUCTOR" -> key.scalars().size() == 1;
                default -> false;
            };
            if (!valid) {
                throw theory(owner + " has an invalid structural type shape");
            }
            for (StableKey child : key.children()) {
                requireTypeKey(child, owner);
            }
        }

        private void collectTypeVariables(StableKey key, Set<String> target) {
            if (key.tag().equals("type/TYPE_VARIABLE")) {
                requireTypeKey(key, "declared type variable");
                target.add(key.scalars().get(0));
                return;
            }
            for (StableKey child : key.children()) {
                collectTypeVariables(child, target);
            }
        }

        private StableKey substituteTypes(
                StableKey key,
                Map<String, StableKey> substitution) {
            if (key.tag().equals("type/TYPE_VARIABLE")
                    && key.scalars().size() == 1
                    && key.children().isEmpty()) {
                StableKey replacement = substitution.get(key.scalars().get(0));
                return replacement == null ? key : replacement;
            }
            List<StableKey> children = key.children().stream()
                    .map(child -> substituteTypes(child, substitution)).toList();
            return StableKey.of(key.tag(), key.scalars(), children);
        }

        private void collectLawDeclarations(
                KernelModel.Operator operator,
                KernelModel.Schema schema,
                int port,
                int depth,
                List<StableKey> target) {
            String path = port + "/" + depth;
            if (isContainer(schema)) {
                Map<Law, ExpectedLaw> atPath = laws.byOperatorPath().get(
                        new OperatorPath(operator.id(), path));
                if (atPath == null) {
                    if (schema.kind() == KernelModel.SchemaKind.SEQ
                            || schema.kind()
                                    == KernelModel.SchemaKind.DEPENDENT_SEQ) {
                        atPath = Map.of();
                    } else {
                        throw new FormatException(
                                FailureCode.MISSING_EVIDENCE,
                                "Operator structural key lacks exact laws at " + path);
                    }
                }
                target.add(StableKey.of(
                        "port-law", List.of(path),
                        List.of(lawDeclarationKey(schema, atPath))));
            }
            if (schema.childSchemas().size() == 1) {
                collectLawDeclarations(
                        operator, model.schema(schema.childSchemas().get(0)),
                        port, depth + 1, target);
            }
        }

        private StableKey lawDeclarationKey(
                KernelModel.Schema schema,
                Map<Law, ExpectedLaw> atPath) {
            List<StableKey> evidence = new ArrayList<>();
            for (Law law : Law.values()) {
                ExpectedLaw expected = atPath.get(law);
                if (expected != null) {
                    evidence.add(StableKey.of(
                            "container-law-evidence", List.of(law.name()),
                            List.of(expected.index())));
                }
            }
            return StableKey.of(
                    "container-laws",
                    List.of(
                            schema.kind() == KernelModel.SchemaKind.DEPENDENT_SEQ
                                    ? "SEQ" : schema.kind().name(),
                            Boolean.toString(atPath.containsKey(Law.ASSOCIATIVITY)),
                            Boolean.toString(schema.kind() == KernelModel.SchemaKind.BAG
                                    || schema.kind() == KernelModel.SchemaKind.SET),
                            Boolean.toString(schema.kind() == KernelModel.SchemaKind.SET),
                            atPath.containsKey(Law.UNIT) ? "EXPLICIT" : "ABSENT"),
                    evidence);
        }

        private StableKey schemaKey(KernelModel.Schema schema) {
            StableKey prior = schemaKeys.get(schema.id());
            if (prior != null) {
                return prior;
            }
            StableKey result = switch (schema.kind()) {
                case ONE, ONE_SLOT, ONE_TERM -> StableKey.of(
                        "schema/one", List.of(),
                        List.of(type(schema.value(), "One schema").key()));
                case SEQ, BAG, SET -> StableKey.of(
                        "schema/" + schema.kind().name().toLowerCase(),
                        List.of(schema.siblingQuotient().name()),
                        List.of(
                                arityKey(schema.arityPolicy()),
                                schemaKey(model.schema(schema.childSchema()))));
                case DEPENDENT_SEQ -> {
                    List<StableKey> children = new ArrayList<>();
                    children.add(arityKey(schema.arityPolicy()));
                    schema.childSchemas().stream()
                            .map(model::schema)
                            .map(this::schemaKey)
                            .forEach(children::add);
                    yield StableKey.of(
                            "schema/dependent-seq",
                            List.of(schema.siblingQuotient().name()),
                            children);
                }
                case BIND -> StableKey.of(
                        "schema/bind", List.of(),
                        List.of(
                                type(schema.value(), "Bind schema").key(),
                                schemaKey(model.schema(schema.childSchema()))));
                case BIND_BLOCK -> StableKey.of(
                        "schema/bind-block", List.of(),
                        List.of(
                                binderView(model.binder(schema.value())).descriptorKey(),
                                schemaKey(model.schema(schema.childSchema()))));
            };
            schemaKeys.put(schema.id(), result);
            return result;
        }

        private StableKey contextKey(KernelModel.Context context) {
            return contextKeys.computeIfAbsent(context.id(), ignored -> {
                List<SemanticSlot> slots = semanticSlots(context);
                return StableKey.of(
                        "context", List.of(),
                        slots.stream().map(SemanticSlot::key).toList());
            });
        }

        private List<SemanticSlot> semanticSlots(KernelModel.Context context) {
            List<SemanticSlot> slots = context.slots().stream()
                    .map(slot -> semanticSlot(slot, "context " + context.id()))
                    .sorted(this::compareSlots)
                    .toList();
            return slots;
        }

        private SemanticSlot semanticSlot(KernelModel.Slot slot, String owner) {
            String name = slot.name();
            if (name.length() < 5 || name.charAt(0) != '$') {
                throw theory(owner + " has a malformed canonical slot " + name);
            }
            String alphabet = switch (name.charAt(1)) {
                case 's' -> "SOURCE";
                case 'f' -> "CANONICAL_FREE";
                case 'b' -> "CANONICAL_BOUND";
                default -> throw theory(owner + " has an unknown slot alphabet " + name);
            };
            int colon = name.indexOf(':', 2);
            if (colon < 3 || colon == name.length() - 1) {
                throw theory(owner + " has a malformed canonical slot " + name);
            }
            String ordinalText = name.substring(2, colon);
            if (!ordinalText.chars().allMatch(Character::isDigit)
                    || (ordinalText.length() > 1 && ordinalText.charAt(0) == '0')) {
                throw theory(owner + " has a noncanonical slot ordinal " + name);
            }
            BigInteger ordinal = new BigInteger(ordinalText);
            ExactType exact = type(slot.type(), owner + " slot");
            if (!name.substring(colon + 1).equals(exact.display())) {
                throw theory(owner + " slot display disagrees with its exact type");
            }
            StableKey key = StableKey.of(
                    "slot", List.of(alphabet, ordinal.toString()),
                    List.of(exact.key()));
            return new SemanticSlot(name, exact, alphabet, ordinal, key);
        }

        private StableKey slotKey(KernelModel.Slot slot) {
            return semanticSlot(slot, "slot").key();
        }

        private int compareSlots(SemanticSlot left, SemanticSlot right) {
            int compared = compareTypes(left.type(), right.type());
            if (compared != 0) {
                return compared;
            }
            compared = Integer.compare(
                    alphabetOrdinal(left.alphabet()),
                    alphabetOrdinal(right.alphabet()));
            return compared != 0 ? compared : left.ordinal().compareTo(right.ordinal());
        }

        private int compareTypes(ExactType left, ExactType right) {
            int compared = Integer.compare(left.kind().ordinal(), right.kind().ordinal());
            if (compared != 0) {
                return compared;
            }
            compared = compareNullable(left.symbol(), right.symbol());
            if (compared != 0) {
                return compared;
            }
            int shared = Math.min(left.arguments().size(), right.arguments().size());
            for (int index = 0; index < shared; index++) {
                compared = compareTypes(
                        left.arguments().get(index), right.arguments().get(index));
                if (compared != 0) {
                    return compared;
                }
            }
            return Integer.compare(left.arguments().size(), right.arguments().size());
        }

        private StableKey embeddingKey(KernelModel.Embedding embedding) {
            List<StableKey> children = new ArrayList<>();
            children.add(contextKey(embedding.source()));
            children.add(contextKey(embedding.target()));
            for (SemanticSlot source : semanticSlots(embedding.source())) {
                KernelModel.Slot target = embedding.target().slot(
                        embedding.apply(source.name()));
                children.add(StableKey.of(
                        "map-entry", List.of(),
                        List.of(source.key(), slotKey(target))));
            }
            return StableKey.of("embedding", List.of(), children);
        }

        private StableKey endpointNode(KernelModel.Term node) {
            return endpoint(
                    "NODE", node.context(),
                    certificateSortTerm(node.sort().value()),
                    StableKey.of("certificate-term/node", List.of(),
                            List.of(termKey(node))));
        }

        private StableKey endpointOneTerm(KernelModel.Term port) {
            KernelModel.Schema schema = model.schema(port.sort().value());
            return endpoint(
                    "ONE_TERM", port.context(),
                    certificateSortTerm(schema.value()),
                    StableKey.of("certificate-term/one-port", List.of(),
                            List.of(termKey(port))));
        }

        private StableKey endpointFlat(FlatView source) {
            return endpoint(
                    "FLAT_APPLICATION", source.context(),
                    certificateSortTerm(source.operator().outputType()),
                    StableKey.of(
                            "certificate-term/flat-application", List.of(),
                            List.of(profile.key(), source.key())));
        }

        private StableKey endpointContainerApplication(
                KernelModel.Operator operator,
                KernelModel.Context context,
                List<KernelModel.Term> inputs) {
            List<StableKey> children = new ArrayList<>();
            children.add(profile.key());
            children.add(operatorKey(operator));
            children.add(StableKey.of("port-path", List.of("0/0"), List.of()));
            for (int index = 0; index < inputs.size(); index++) {
                children.add(StableKey.of(
                        "container-source-occurrence",
                        List.of(Integer.toString(index)),
                        List.of(termKey(inputs.get(index)))));
            }
            return endpoint(
                    "CONTAINER_APPLICATION", context,
                    certificateSortTerm(operator.outputType()),
                    StableKey.of(
                            "certificate-term/container-application",
                            List.of(), children));
        }

        private StableKey endpointDependentChain(
                ChainView source,
                StableKey sourceOccurrenceCommitment) {
            return endpoint(
                    "DEPENDENT_CHAIN_APPLICATION",
                    source.context(),
                    certificateSortTerm(source.outputType().id()),
                    StableKey.of(
                            "certificate-term/dependent-chain-application-v1",
                            List.of(),
                            List.of(
                                    profile.key(),
                                    source.key(),
                                    sourceOccurrenceCommitment)));
        }

        private StableKey endpointPort(KernelModel.Term port) {
            return endpoint(
                    "PORT", port.context(),
                    certificateSortPort(model.schema(port.sort().value())),
                    StableKey.of("certificate-term/port", List.of(),
                            List.of(termKey(port))));
        }

        private StableKey endpoint(
                String kind,
                KernelModel.Context context,
                StableKey sort,
                StableKey expression) {
            return StableKey.of(
                    "certificate-endpoint", List.of(kind),
                    List.of(contextKey(context), sort, expression));
        }

        private StableKey certificateSortTerm(String reference) {
            return StableKey.of(
                    "certificate-sort", List.of("TERM"),
                    List.of(type(reference, "certificate term sort").key()));
        }

        private StableKey certificateSortPort(KernelModel.Schema schema) {
            return StableKey.of(
                    "certificate-sort", List.of("PORT"),
                    List.of(schemaKey(schema)));
        }

        private StableKey typedCertificate(
                String category,
                StableKey left,
                StableKey right,
                List<StableKey> details,
                List<StableKey> premises) {
            StableKey context = left.children().get(0);
            StableKey sort = left.children().get(1);
            if (!context.equals(right.children().get(0))
                    || !sort.equals(right.children().get(1))) {
                throw theory("Reconstructed certificate endpoints have different types");
            }
            StableKey typeCheck = StableKey.of(
                    "certificate-endpoint-type-check", List.of(),
                    List.of(context, sort));
            List<StableKey> children = new ArrayList<>(3 + details.size()
                    + premises.size());
            children.add(left);
            children.add(right);
            children.add(typeCheck);
            children.addAll(details);
            for (StableKey premise : premises) {
                children.add(StableKey.of(
                        "certificate-premise", List.of(), List.of(premise)));
            }
            return StableKey.of(
                    "typed-equality-certificate", List.of(category), children);
        }

        private StableKey lawCertificateKey(ExpectedLaw law) {
            StableKey schema = law.schemaKey();
            StableKey emptyContext = StableKey.of("context", List.of(), List.of());
            StableKey sort = StableKey.of(
                    "certificate-sort", List.of("PORT"), List.of(schema));
            StableKey left = StableKey.of(
                    "certificate-endpoint", List.of("CONTAINER_PATTERN"),
                    List.of(
                            emptyContext,
                            sort,
                            StableKey.of(
                                    "certificate-pattern/container-law",
                                    List.of(law.law().name(), "left"),
                                    List.of(schema, law.index()))));
            StableKey right = StableKey.of(
                    "certificate-endpoint", List.of("CONTAINER_PATTERN"),
                    List.of(
                            emptyContext,
                            sort,
                            StableKey.of(
                                    "certificate-pattern/container-law",
                                    List.of(law.law().name(), "right"),
                                    List.of(schema, law.index()))));
            StableKey origin = StableKey.of(
                    "certificate-origin",
                    List.of(
                            "SIGNATURE_CONTAINER_LAW",
                            law.sourceArtifact(),
                            law.declarationId(),
                            Integer.toString(law.law().ordinal())),
                    List.of());
            return typedCertificate(
                    "CONTAINER_LAW", left, right,
                    List.of(law.index(), origin), List.of());
        }

        private Map<Law, ExpectedLaw> requireOperatorLaws(
                KernelModel.Operator operator,
                String path) {
            Map<Law, ExpectedLaw> result = laws.byOperatorPath().get(
                    new OperatorPath(operator.id(), path));
            if (result == null) {
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        "No exact laws for " + operator.id() + " at " + path);
            }
            return result;
        }

        private ExpectedLaw requireLaw(
                Map<Law, ExpectedLaw> available,
                Law law,
                String use) {
            ExpectedLaw result = available.get(law);
            if (result == null) {
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        use + " lacks " + law + " authority");
            }
            return result;
        }

        private ExactType type(String reference, String owner) {
            return requireType(types, reference, publication, owner);
        }

        private void requireFingerprint(String actual, String owner) {
            if (!actual.equals(profile.fingerprint())) {
                throw new FormatException(
                        FailureCode.DIGEST_MISMATCH,
                        owner + " uses another semantic profile");
            }
        }

        private void requireKey(String actual, StableKey expected, String owner) {
            StableKey parsed = parseStableKey(actual, owner);
            if (!parsed.equals(expected)) {
                throw theory(owner + " does not independently reconstruct"
                        + " (claimed=" + sha256(actual)
                        + ", replay=" + sha256(expected.stableString())
                        + ", firstDifference="
                        + firstDifference(parsed, expected, "root") + ")");
            }
        }

        private String firstDifference(
                StableKey claimed,
                StableKey expected,
                String path) {
            if (!claimed.tag().equals(expected.tag())) {
                return path + ".tag:" + claimed.tag() + "!=" + expected.tag();
            }
            if (!claimed.scalars().equals(expected.scalars())) {
                return path + ".scalars:" + claimed.scalars()
                        + "!=" + expected.scalars();
            }
            if (claimed.children().size() != expected.children().size()) {
                return path + ".children:" + claimed.children().size()
                        + "!=" + expected.children().size();
            }
            for (int index = 0; index < claimed.children().size(); index++) {
                StableKey left = claimed.children().get(index);
                StableKey right = expected.children().get(index);
                if (!left.equals(right)) {
                    return firstDifference(left, right, path + "/" + index);
                }
            }
            return path + ":unknown";
        }

        private int parseNonnegative(String value, String field) {
            long parsed = Bundle.parseUnsignedLong(value, field);
            if (parsed > Integer.MAX_VALUE || !Long.toString(parsed).equals(value)) {
                throw new FormatException(
                        FailureCode.INTEGER_OVERFLOW,
                        field + " is not a canonical nonnegative int");
            }
            return (int) parsed;
        }

        private String encodePath(List<Integer> path) {
            return String.join("/", path.stream().map(Object::toString).toList());
        }

        private boolean isContainer(KernelModel.Schema schema) {
            return schema.kind() == KernelModel.SchemaKind.SEQ
                    || schema.kind() == KernelModel.SchemaKind.DEPENDENT_SEQ
                    || schema.kind() == KernelModel.SchemaKind.BAG
                    || schema.kind() == KernelModel.SchemaKind.SET;
        }

        private boolean isHomogeneousContainer(KernelModel.Schema schema) {
            return schema.kind() == KernelModel.SchemaKind.SEQ
                    || schema.kind() == KernelModel.SchemaKind.BAG
                    || schema.kind() == KernelModel.SchemaKind.SET;
        }

        private int compareNullable(String left, String right) {
            if (left == null) {
                return right == null ? 0 : -1;
            }
            return right == null ? 1 : left.compareTo(right);
        }

        private int alphabetOrdinal(String alphabet) {
            return switch (alphabet) {
                case "SOURCE" -> 0;
                case "CANONICAL_FREE" -> 1;
                case "CANONICAL_BOUND" -> 2;
                default -> throw new AssertionError(alphabet);
            };
        }

        private void verifyBinderOccurrence(Wire.Node record) {
            record.requireShape("binder-occurrence", 9, 0);
            KernelModel.Term source = model.term(record.scalar(1));
            KernelModel.Term target = model.term(record.scalar(2));
            if (source.kind() != KernelModel.TermKind.BIND_BLOCK
                    || target.kind() != KernelModel.TermKind.BIND_BLOCK
                    || !source.sort().equals(target.sort())
                    || !source.context().equals(target.context())
                    || !source.attributes().equals(target.attributes())) {
                throw theory("Binder occurrence endpoints do not share one exact block");
            }
            KernelModel.Schema schema = model.schema(source.sort().value());
            if (schema.kind() != KernelModel.SchemaKind.BIND_BLOCK) {
                throw theory("Binder occurrence source has no block descriptor");
            }
            BinderView descriptor = binderView(model.binder(schema.value()));
            List<Integer> path = parseOccurrencePath(record.scalar(3));
            KernelModel.Term root = model.term(record.scalar(8));
            if (!occursAtPath(root, source.id(), path)) {
                throw theory("Binder occurrence path does not locate its source block");
            }

            KernelModel.Embedding occurrence = model.embedding(source.attributes().get(0));
            KernelModel.Embedding automorphism = model.embedding(record.scalar(4));
            KernelModel.Embedding conjugated = model.embedding(record.scalar(5));
            List<Integer> permutation = descriptorPermutation(
                    descriptor, automorphism, "binder automorphism");
            requireOccurrenceMap(descriptor, occurrence, source);
            requireConjugate(occurrence, permutation, conjugated);

            KernelModel.Term sourceBody = model.term(source.children().get(0));
            KernelModel.Term targetBody = model.term(target.children().get(0));
            Map<String, String> bodyAction = binderBodyAction(
                    source.context(), conjugated);
            StableKey actedBody = actedPortKey(
                    sourceBody, sourceBody.context(), sourceBody.context(), bodyAction);
            if (!actedBody.equals(termKey(targetBody))) {
                throw theory("Binder target body is not the conjugated occurrence action");
            }
            StableKey expectedTarget = StableKey.of(
                    "port/bind-block", List.of(),
                    List.of(
                            schemaKey(schema),
                            contextKey(source.context()),
                            embeddingKey(occurrence),
                            actedBody));
            if (!expectedTarget.equals(termKey(target))) {
                throw theory("Binder target does not preserve its descriptor occurrence");
            }

            StableKey left = endpointPort(source);
            StableKey right = endpointPort(target);
            requireKey(record.scalar(6), left, "binder left endpoint");
            requireKey(record.scalar(7), right, "binder right endpoint");
            StableKey automorphismKey = embeddingKey(automorphism);
            StableKey occurrenceKey = embeddingKey(conjugated);
            StableKey premise = binderDerivationCertificate(descriptor, permutation);
            StableKey pathKey = StableKey.of(
                    "binder-occurrence-source-path-v1",
                    path.stream().map(Object::toString).toList(), List.of());
            StableKey expected = typedCertificate(
                    "BINDER_AUTOMORPHISM",
                    left,
                    right,
                    List.of(
                            termKey(root),
                            descriptor.descriptorKey(),
                            contextKey(source.context()),
                            embeddingKey(occurrence),
                            automorphismKey,
                            occurrenceKey,
                            pathKey,
                            termKey(source),
                            termKey(target)),
                    List.of(premise));
            requireKey(record.scalar(0), expected,
                    "binder occurrence certificate");
            verifiedBinderOccurrences.add(record.scalar(0));
            BinderEvidence prior = binderEvidence.putIfAbsent(
                    record.scalar(0),
                    new BinderEvidence(
                            record.scalar(0), root.id(), source.id(), List.copyOf(path)));
            if (prior != null) {
                throw new FormatException(
                        FailureCode.DUPLICATE_ID,
                        "Duplicate binder occurrence evidence key");
            }
        }

        private void verifyEvidenceCoverage() {
            Map<String, String> sourceOwners = constructionSourceOwners();
            Set<String> flatReferences = new HashSet<>();
            Set<String> chainReferences = new HashSet<>();
            Set<String> containerReferences = new HashSet<>();
            Set<String> derivedBinderObligations = new HashSet<>();
            for (Wire.Node proof : bundle.proofs().values()) {
                if (proof.scalar(1).equals("KERNEL_REPLAY")) {
                    Wire.Node payload = proof.child(1)
                            .requireShape("kernel-replay", 7, 5);
                    KernelModel.Term sourceTerm = model.term(payload.scalar(0));
                    Wire.Node sourceReference = payload.child(4)
                            .requireShape("source-construction", 4, 0);
                    ConstructionKind expected = constructionKind(sourceTerm);
                    ConstructionEvidence construction = verifyConstructionReference(
                            sourceTerm,
                            sourceReference,
                            expected,
                            sourceOwners.get(proof.scalar(0)),
                            flatReferences,
                            chainReferences,
                            containerReferences);
                    VerifiedReplayConstruction verified =
                            new VerifiedReplayConstruction(
                                    expected,
                                    sourceTerm.id(),
                                    sourceReference.scalar(1),
                                    sourceReference.scalar(2),
                                    sourceReference.scalar(3),
                                    construction);
                    VerifiedReplayConstruction prior = replayConstructions.putIfAbsent(
                            proof.scalar(0), verified);
                    if (prior != null && !prior.equals(verified)) {
                        throw new FormatException(
                                FailureCode.DUPLICATE_ID,
                                "One replay proof has multiple construction references");
                    }
                } else if (proof.scalar(1).equals("CANONICAL_ORBIT")) {
                    Wire.Node payload = proof.child(1)
                            .requireShape("canonical-orbit", 6, 4);
                    KernelModel.Term orbitSource = model.term(payload.scalar(1));
                    Set<String> localObligations = new HashSet<>();
                    collectBinderObligations(
                            orbitSource,
                            orbitSource,
                            List.of(),
                            localObligations);
                    Wire.Node references = payload.child(3)
                            .requireTag("binder-occurrence-refs");
                    if (!references.scalars().isEmpty()) {
                        throw malformed("binder occurrence references");
                    }
                    Set<String> localReferences = new HashSet<>();
                    for (Wire.Node reference : references.children()) {
                        reference.requireShape("binder-occurrence-ref", 1, 0);
                        addEvidenceReference(
                                localReferences,
                                reference.scalar(0),
                                "binder occurrence");
                    }
                    if (!localReferences.equals(localObligations)) {
                        throw new FormatException(
                                FailureCode.MISSING_EVIDENCE,
                                "Binder references differ from obligations derived from "
                                        + "the exact orbit source");
                    }
                    derivedBinderObligations.addAll(localObligations);
                }
            }
            requireExactCoverage(
                    "flat constructions", verifiedFlatConstructions, flatReferences);
            requireExactCoverage(
                    "dependent-chain constructions",
                    verifiedChainConstructions,
                    chainReferences);
            requireExactCoverage(
                    "container constructions",
                    verifiedContainerConstructions,
                    containerReferences);
            requireExactCoverage(
                    "binder occurrences",
                    verifiedBinderOccurrences,
                    derivedBinderObligations);
        }

        private ConstructionKind constructionKind(KernelModel.Term source) {
            if (source.kind() != KernelModel.TermKind.APP) {
                return ConstructionKind.NONE;
            }
            KernelModel.Operator operator = model.operator(source.symbol());
            if (isDependentChainOperator(operator)) {
                return ConstructionKind.CHAIN;
            }
            if (!operator.flatPath().equals("none")) {
                return ConstructionKind.FLAT;
            }
            Map<Law, ExpectedLaw> rootLaws = laws.byOperatorPath().get(
                    new OperatorPath(operator.id(), "0/0"));
            if (operator.schemas().size() == 1
                    && isContainer(model.schema(operator.schemas().get(0)))
                    && rootLaws != null
                    && !rootLaws.isEmpty()) {
                return ConstructionKind.CONTAINER;
            }
            return ConstructionKind.NONE;
        }

        private ConstructionEvidence verifyConstructionReference(
                KernelModel.Term source,
                Wire.Node reference,
                ConstructionKind expected,
                String expectedSourceOwner,
                Set<String> flatReferences,
                Set<String> chainReferences,
                Set<String> containerReferences) {
            ConstructionKind claimed;
            try {
                claimed = ConstructionKind.valueOf(reference.scalar(0));
            } catch (IllegalArgumentException exception) {
                throw new FormatException(
                        FailureCode.UNKNOWN_VARIANT,
                        "Unknown source-construction reference kind "
                                + reference.scalar(0),
                        exception);
            }
            if (claimed != expected) {
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        "Decoded replay source requires " + expected
                                + " construction evidence, not " + claimed);
            }
            if (expected == ConstructionKind.NONE) {
                boolean empty = reference.scalar(1).isEmpty()
                        && reference.scalar(2).isEmpty()
                        && reference.scalar(3).isEmpty();
                boolean producerOrbit = reference.scalar(1).equals(
                        PRODUCER_ORBIT_SOURCE_MARKER)
                        && !reference.scalar(2).isEmpty()
                        && !reference.scalar(3).isEmpty();
                if (!empty && !producerOrbit) {
                    throw malformed("empty source construction reference");
                }
                return null;
            }
            String key = reference.scalar(1);
            if (expectedSourceOwner == null
                    || !expectedSourceOwner.equals(reference.scalar(3))) {
                throw new FormatException(
                        FailureCode.THEORY_MISMATCH,
                        "Construction evidence belongs to another source occurrence");
            }
            addEvidenceReference(
                    expected == ConstructionKind.FLAT
                            ? flatReferences
                            : expected == ConstructionKind.CHAIN
                                    ? chainReferences : containerReferences,
                    key,
                    expected.name().toLowerCase() + " construction");
            ConstructionEvidence evidence = switch (expected) {
                case FLAT -> flatEvidence.get(key);
                case CHAIN -> chainEvidence.get(key);
                case CONTAINER -> containerEvidence.get(key);
                case NONE -> null;
            };
            if (evidence == null) {
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        "Replay references absent " + expected + " construction evidence");
            }
            KernelModel.Operator operator = model.operator(source.symbol());
            String path = expected == ConstructionKind.FLAT
                    ? operator.flatPath() : "0/0";
            if (!evidence.targetTermId().equals(source.id())
                    || !evidence.operatorId().equals(operator.id())
                    || !evidence.path().equals(path)
                    || !evidence.sourceEndpointKey().equals(reference.scalar(2))
                    || !evidence.sourceOwner().equals(expectedSourceOwner)) {
                throw new FormatException(
                        FailureCode.THEORY_MISMATCH,
                        "Construction evidence belongs to another replay endpoint");
            }
            return evidence;
        }

        private boolean isDependentChainOperator(KernelModel.Operator operator) {
            if ((!operator.semanticIdentity().equals(
                            "ALLOY/DEPENDENT-CHAIN/JOIN")
                        && !operator.semanticIdentity().equals(
                            "ALLOY/DEPENDENT-CHAIN/ARROW"))
                    || !operator.flatPath().equals("none")
                    || operator.schemas().size() != 1) {
                return false;
            }
            return model.schema(operator.schemas().get(0)).isDependentSequence();
        }

        private Map<String, String> constructionSourceOwners() {
            Map<String, String> result = new HashMap<>();
            Bundle.Metadata metadata = bundle.metadata();
            for (Wire.Node event : bundle.events()) {
                if (event.scalars().size() != 4 || event.children().size() != 1) {
                    throw malformed("event source owner");
                }
                String kind = event.scalar(1);
                if (!kind.equals("INSERT_FRESH")
                        && !kind.equals("INSERT_COLLISION")) {
                    continue;
                }
                Wire.Node payload = event.child(0);
                if (payload.scalars().size() < 3) {
                    throw malformed("insertion source owner");
                }
                String replay = payload.scalar(2);
                String owner = "source-owner/" + Wire.contentId(Wire.node(
                        "construction-source-owner-v1",
                        List.of(
                                metadata.inputIdentifier(),
                                metadata.inputSha256(),
                                event.scalar(0),
                                payload.scalar(0)),
                        List.of()));
                String prior = result.putIfAbsent(replay, owner);
                if (prior != null && !prior.equals(owner)) {
                    throw new FormatException(
                            FailureCode.DUPLICATE_ID,
                            "One replay proof has multiple source owners");
                }
            }
            return Map.copyOf(result);
        }

        private void collectBinderObligations(
                KernelModel.Term root,
                KernelModel.Term current,
                List<Integer> path,
                Set<String> target) {
            if (current.kind() == KernelModel.TermKind.BIND_BLOCK) {
                KernelModel.Schema schema = model.schema(current.sort().value());
                BinderView descriptor = binderView(model.binder(schema.value()));
                KernelModel.Embedding occurrence = model.embedding(
                        current.attributes().get(0));
                requireOccurrenceMap(descriptor, occurrence, current);
                for (List<Integer> generator : descriptor.generators()) {
                    String key = derivedBinderOccurrenceKey(
                            root,
                            current,
                            path,
                            descriptor,
                            occurrence,
                            generator);
                    BinderEvidence evidence = binderEvidence.get(key);
                    if (evidence == null) {
                        throw new FormatException(
                                FailureCode.MISSING_EVIDENCE,
                                "Orbit source requires absent binder-occurrence evidence");
                    }
                    if (!evidence.rootTermId().equals(root.id())
                            || !evidence.sourceTermId().equals(current.id())
                            || !evidence.path().equals(path)) {
                        throw new FormatException(
                                FailureCode.THEORY_MISMATCH,
                                "Binder evidence belongs to another orbit occurrence");
                    }
                    if (!target.add(key)) {
                        throw new FormatException(
                                FailureCode.DUPLICATE_ID,
                                "One orbit derives the same binder obligation twice");
                    }
                }
            }
            for (int index = 0; index < current.children().size(); index++) {
                List<Integer> childPath = new ArrayList<>(path);
                childPath.add(index);
                collectBinderObligations(
                        root,
                        model.term(current.children().get(index)),
                        List.copyOf(childPath),
                        target);
            }
        }

        private String derivedBinderOccurrenceKey(
                KernelModel.Term root,
                KernelModel.Term source,
                List<Integer> path,
                BinderView descriptor,
                KernelModel.Embedding occurrence,
                List<Integer> permutation) {
            Map<String, String> conjugatedImages = new LinkedHashMap<>();
            for (int index = 0; index < descriptor.coordinateSlots().size(); index++) {
                String sourceOccurrence = occurrence.apply(
                        descriptor.coordinateSlots().get(index).name());
                String targetOccurrence = occurrence.apply(
                        descriptor.coordinateSlots().get(permutation.get(index)).name());
                conjugatedImages.put(sourceOccurrence, targetOccurrence);
            }
            StableKey automorphismKey = permutationEmbedding(descriptor, permutation);
            StableKey occurrenceKey = embeddingKey(
                    occurrence.target(), occurrence.target(), conjugatedImages);
            KernelModel.Term sourceBody = model.term(source.children().get(0));
            Map<String, String> bodyAction = new LinkedHashMap<>();
            for (KernelModel.Slot caller : source.context().slots()) {
                bodyAction.put(caller.name(), caller.name());
            }
            bodyAction.putAll(conjugatedImages);
            StableKey actedBody = actedPortKey(
                    sourceBody,
                    sourceBody.context(),
                    sourceBody.context(),
                    bodyAction);
            KernelModel.Schema schema = model.schema(source.sort().value());
            StableKey expectedTarget = StableKey.of(
                    "port/bind-block", List.of(),
                    List.of(
                            schemaKey(schema),
                            contextKey(source.context()),
                            embeddingKey(occurrence),
                            actedBody));
            StableKey left = endpointPort(source);
            StableKey right = endpoint(
                    "PORT",
                    source.context(),
                    certificateSortPort(schema),
                    StableKey.of(
                            "certificate-term/port", List.of(),
                            List.of(expectedTarget)));
            StableKey pathKey = StableKey.of(
                    "binder-occurrence-source-path-v1",
                    path.stream().map(Object::toString).toList(),
                    List.of());
            StableKey premise = binderDerivationCertificate(descriptor, permutation);
            return typedCertificate(
                    "BINDER_AUTOMORPHISM",
                    left,
                    right,
                    List.of(
                            termKey(root),
                            descriptor.descriptorKey(),
                            contextKey(source.context()),
                            embeddingKey(occurrence),
                            automorphismKey,
                            occurrenceKey,
                            pathKey,
                            termKey(source),
                            expectedTarget),
                    List.of(premise)).stableString();
        }

        private void addEvidenceReference(
                Set<String> target,
                String encoded,
                String owner) {
            parseStableKey(encoded, owner + " reference");
            target.add(encoded);
        }

        private void requireExactCoverage(
                String owner,
                Set<String> records,
                Set<String> references) {
            if (!records.equals(references)) {
                Set<String> missing = new HashSet<>(references);
                missing.removeAll(records);
                Set<String> unreferenced = new HashSet<>(records);
                unreferenced.removeAll(references);
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        owner + " completeness mismatch: missing=" + missing.size()
                                + " unreferenced=" + unreferenced.size());
            }
        }

        private BinderView binderView(KernelModel.Binder binder) {
            BinderView prior = binderViews.get(binder.id());
            if (prior != null) {
                return prior;
            }
            List<SemanticSlot> coordinateSlots = new ArrayList<>();
            List<StableKey> coordinates = new ArrayList<>();
            List<String> payloads = new ArrayList<>();
            Map<String, SemanticSlot> slotsByName = new LinkedHashMap<>();
            for (KernelModel.BinderCoordinate coordinate : binder.coordinates()) {
                SemanticSlot slot = semanticSlot(
                        new KernelModel.Slot(coordinate.slotName(), coordinate.type()),
                        "binder " + binder.id());
                if (!slot.alphabet().equals("CANONICAL_BOUND")) {
                    throw theory("Binder descriptor does not use canonical bound slots");
                }
                coordinateSlots.add(slot);
                slotsByName.put(slot.name(), slot);
                List<SemanticSlot> dependencies = coordinate.dependencies().stream()
                        .map(name -> {
                            SemanticSlot dependency = slotsByName.get(name);
                            if (dependency == null) {
                                throw theory("Binder dependency is not a preceding coordinate");
                            }
                            return dependency;
                        }).sorted(this::compareSlots).toList();
                StableKey dependencyContext = contextKey(dependencies);
                StableKey domain = parseStableKey(
                        coordinate.domain(), "binder coordinate domain");
                StableKey coordinateKey = StableKey.of(
                        "binder-coordinate",
                        List.of(
                                coordinate.quantifier(),
                                coordinate.multiplicity(),
                                canonicalSignedInt(
                                        coordinate.disjointClass(),
                                        "binder disjointness class", true),
                                canonicalSignedInt(
                                        coordinate.exchangeClass(),
                                        "binder exchange class", false)),
                        List.of(slot.key(), domain, dependencyContext));
                coordinates.add(coordinateKey);
                payloads.add(String.join("\u0000",
                        coordinate.type(), coordinate.domain(), coordinate.quantifier(),
                        coordinate.multiplicity(), coordinate.disjointClass(),
                        coordinate.exchangeClass(),
                        String.join("\u0001", coordinate.dependencies())));
            }
            List<SemanticSlot> ordered = coordinateSlots.stream()
                    .sorted(this::compareSlots).toList();
            StableKey boundContext = contextKey(ordered);

            List<List<Integer>> expectedGenerators = new ArrayList<>();
            Map<String, Integer> previous = new HashMap<>();
            Map<String, Integer> generatedOrdinals = new HashMap<>();
            for (int index = 0; index < payloads.size(); index++) {
                Integer left = previous.put(payloads.get(index), index);
                if (left == null) {
                    continue;
                }
                List<Integer> swap = identityPermutation(payloads.size());
                swap.set(left, index);
                swap.set(index, left);
                expectedGenerators.add(swap);
                generatedOrdinals.put(permutationAction(
                        coordinateSlots, ordered, swap).stableString(),
                        generatedOrdinals.size());
            }
            expectedGenerators.sort(Comparator.comparing(value -> permutationAction(
                    coordinateSlots, ordered, value).stableString()));
            if (!binder.generators().equals(expectedGenerators)) {
                throw theory("Binder generator ledger is not the Alloy descriptor replay");
            }

            List<List<Integer>> canonicalGenerators = canonicalPermutationPresentation(
                    expectedGenerators, coordinateSlots, ordered);
            List<StableKey> groupChildren = new ArrayList<>();
            groupChildren.add(boundContext);
            for (List<Integer> generator : canonicalGenerators) {
                groupChildren.add(StableKey.of(
                        "binder-automorphism-canonical-generator", List.of(),
                        List.of(permutationAction(
                                coordinateSlots, ordered, generator))));
            }
            StableKey group = StableKey.of(
                    "binder-automorphism-canonical-presentation-v1",
                    List.of(), groupChildren);
            List<StableKey> payloadChildren = new ArrayList<>();
            payloadChildren.add(boundContext);
            payloadChildren.addAll(coordinates);
            StableKey payload = StableKey.of(
                    "binder-block-payload", List.of(), payloadChildren);
            List<StableKey> descriptorChildren = new ArrayList<>(coordinates);
            descriptorChildren.add(group);
            StableKey descriptorKey = StableKey.of(
                    "binder-block-descriptor", List.of(), descriptorChildren);
            BinderView result = new BinderView(
                    binder,
                    List.copyOf(coordinateSlots),
                    List.copyOf(ordered),
                    boundContext,
                    payload,
                    descriptorKey,
                    List.copyOf(expectedGenerators),
                    Map.copyOf(generatedOrdinals));
            binderViews.put(binder.id(), result);
            return result;
        }

        private StableKey binderGeneratorCertificate(
                BinderView descriptor,
                List<Integer> permutation,
                StableKey embedding,
                int ordinal) {
            StableKey identityEmbedding = permutationEmbedding(
                    descriptor, identityPermutation(descriptor.coordinateSlots().size()));
            StableKey left = binderPatternEndpoint(
                    descriptor, identityEmbedding);
            StableKey right = binderPatternEndpoint(descriptor, embedding);
            StableKey origin = StableKey.of(
                    "certificate-origin",
                    List.of(
                            "SIGNATURE_BINDER_AUTOMORPHISM",
                            BINDER_SIGNATURE,
                            BINDER_DECLARATION,
                            Integer.toString(ordinal)),
                    List.of());
            return typedCertificate(
                    "BINDER_AUTOMORPHISM", left, right,
                    List.of(descriptor.payloadKey(), embedding, origin), List.of());
        }

        private StableKey binderDerivationCertificate(
                BinderView descriptor,
                List<Integer> target) {
            List<Integer> identity = identityPermutation(
                    descriptor.coordinateSlots().size());
            String identityKey = permutationAction(
                    descriptor, identity).stableString();
            String targetKey = permutationAction(descriptor, target).stableString();
            StableKey identityEndpoint = binderPatternEndpoint(
                    descriptor, permutationEmbedding(descriptor, identity));
            StableKey reflexivity = typedCertificate(
                    "REFLEXIVITY",
                    identityEndpoint,
                    identityEndpoint,
                    List.of(),
                    List.of());
            if (identityKey.equals(targetKey)) {
                return reflexivity;
            }

            List<BinderProofStep> steps = new ArrayList<>();
            for (List<Integer> generator : descriptor.generators()) {
                StableKey action = permutationAction(descriptor, generator);
                Integer ordinal = descriptor.generatorOrdinals().get(
                        action.stableString());
                if (ordinal == null) {
                    throw theory("Binder generator has no independently fixed origin");
                }
                StableKey generatorProof = binderGeneratorCertificate(
                        descriptor,
                        generator,
                        permutationEmbedding(descriptor, generator),
                        ordinal);
                steps.add(new BinderProofStep(generator, generatorProof));

                List<Integer> inverse = inverse(generator);
                StableKey inverseEndpoint = binderPatternEndpoint(
                        descriptor, permutationEmbedding(descriptor, inverse));
                StableKey renamed = typedCertificate(
                        "RENAMING",
                        inverseEndpoint,
                        identityEndpoint,
                        List.of(permutationEmbedding(descriptor, inverse)),
                        List.of(generatorProof));
                StableKey inverseProof = typedCertificate(
                        "EQUATIONAL_SYMMETRY",
                        identityEndpoint,
                        inverseEndpoint,
                        List.of(),
                        List.of(renamed));
                steps.add(new BinderProofStep(inverse, inverseProof));
            }

            Map<String, BinderDerivation> reached = new LinkedHashMap<>();
            Deque<List<Integer>> pending = new ArrayDeque<>();
            reached.put(identityKey, new BinderDerivation(identity, reflexivity));
            pending.add(identity);
            while (!pending.isEmpty() && !reached.containsKey(targetKey)) {
                List<Integer> current = pending.removeFirst();
                BinderDerivation currentProof = reached.get(
                        permutationAction(descriptor, current).stableString());
                for (BinderProofStep step : steps) {
                    List<Integer> candidate = compose(current, step.permutation());
                    String candidateKey = permutationAction(
                            descriptor, candidate).stableString();
                    if (reached.containsKey(candidateKey)) {
                        continue;
                    }
                    StableKey stepEndpoint = binderPatternEndpoint(
                            descriptor,
                            permutationEmbedding(descriptor, step.permutation()));
                    StableKey candidateEndpoint = binderPatternEndpoint(
                            descriptor,
                            permutationEmbedding(descriptor, candidate));
                    StableKey transported = typedCertificate(
                            "RENAMING",
                            stepEndpoint,
                            candidateEndpoint,
                            List.of(permutationEmbedding(
                                    descriptor, step.permutation())),
                            List.of(currentProof.proof()));
                    StableKey proof = typedCertificate(
                            "TRANSITIVITY",
                            identityEndpoint,
                            candidateEndpoint,
                            List.of(),
                            List.of(step.proof(), transported));
                    reached.put(
                            candidateKey,
                            new BinderDerivation(List.copyOf(candidate), proof));
                    pending.addLast(candidate);
                }
            }
            BinderDerivation result = reached.get(targetKey);
            if (result == null) {
                throw theory("Binder occurrence permutation is outside the certified group");
            }
            return result.proof();
        }

        private StableKey binderPatternEndpoint(
                BinderView descriptor,
                StableKey embedding) {
            StableKey sort = StableKey.of(
                    "certificate-sort", List.of("BINDER_LAW"),
                    List.of(descriptor.payloadKey()));
            StableKey expression = StableKey.of(
                    "certificate-pattern/binder-automorphism", List.of(),
                    List.of(descriptor.payloadKey(), embedding));
            return StableKey.of(
                    "certificate-endpoint", List.of("BINDER_PATTERN"),
                    List.of(descriptor.boundContextKey(), sort, expression));
        }

        private void requireOccurrenceMap(
                BinderView descriptor,
                KernelModel.Embedding occurrence,
                KernelModel.Term source) {
            if (occurrence.kind() != KernelModel.EmbeddingKind.BIJECTION
                    || occurrence.source().slots().size()
                            != descriptor.coordinateSlots().size()
                    || occurrence.target().slots().size()
                            != descriptor.coordinateSlots().size()
                    || !source.context().slots().stream().noneMatch(
                            slot -> occurrence.target().contains(slot.name()))) {
                throw theory("Binder descriptor-to-occurrence map is not fresh and bijective");
            }
            for (SemanticSlot slot : descriptor.coordinateSlots()) {
                KernelModel.Slot sourceSlot = occurrence.source().slot(slot.name());
                if (!slot.key().equals(slotKey(sourceSlot))) {
                    throw theory("Binder occurrence map starts at another descriptor");
                }
            }
        }

        private List<Integer> descriptorPermutation(
                BinderView descriptor,
                KernelModel.Embedding embedding,
                String owner) {
            if (embedding.kind() != KernelModel.EmbeddingKind.BIJECTION) {
                throw theory(owner + " is not bijective");
            }
            List<Integer> result = new ArrayList<>();
            for (SemanticSlot slot : descriptor.coordinateSlots()) {
                String image = embedding.apply(slot.name());
                int index = -1;
                for (int candidate = 0;
                        candidate < descriptor.coordinateSlots().size(); candidate++) {
                    if (descriptor.coordinateSlots().get(candidate).name().equals(image)) {
                        index = candidate;
                        break;
                    }
                }
                if (index < 0) {
                    throw theory(owner + " leaves the descriptor context");
                }
                result.add(index);
            }
            return List.copyOf(result);
        }

        private void requireConjugate(
                KernelModel.Embedding occurrence,
                List<Integer> permutation,
                KernelModel.Embedding conjugated) {
            if (conjugated.kind() != KernelModel.EmbeddingKind.BIJECTION
                    || !conjugated.source().equals(occurrence.target())
                    || !conjugated.target().equals(occurrence.target())) {
                throw theory("Binder occurrence permutation has the wrong context");
            }
            List<KernelModel.Slot> descriptorSlots = occurrence.source().slots();
            for (int index = 0; index < descriptorSlots.size(); index++) {
                String sourceOccurrence = occurrence.apply(
                        descriptorSlots.get(index).name());
                String targetOccurrence = occurrence.apply(
                        descriptorSlots.get(permutation.get(index)).name());
                if (!conjugated.apply(sourceOccurrence).equals(targetOccurrence)) {
                    throw theory("Binder occurrence map is not rho^-1;pi;rho");
                }
            }
        }

        private StableKey actedPortKey(
                KernelModel.Term source,
                KernelModel.Embedding action) {
            Map<String, String> images = new LinkedHashMap<>();
            for (KernelModel.Slot slot : action.source().slots()) {
                images.put(slot.name(), action.apply(slot.name()));
            }
            return actedPortKey(
                    source, action.source(), action.target(), images);
        }

        private Map<String, String> binderBodyAction(
                KernelModel.Context caller,
                KernelModel.Embedding occurrencePermutation) {
            Map<String, String> images = new LinkedHashMap<>();
            for (KernelModel.Slot slot : caller.slots()) {
                images.put(slot.name(), slot.name());
            }
            for (KernelModel.Slot slot : occurrencePermutation.source().slots()) {
                if (images.putIfAbsent(
                        slot.name(), occurrencePermutation.apply(slot.name())) != null) {
                    throw theory("Binder occurrence captures a caller slot");
                }
            }
            return images;
        }

        private StableKey actedPortKey(
                KernelModel.Term source,
                KernelModel.Context actionSource,
                KernelModel.Context actionTarget,
                Map<String, String> actionImages) {
            if (!source.context().equals(actionSource)) {
                throw theory("Binder body action starts at the wrong context");
            }
            KernelModel.Schema schema = model.schema(source.sort().value());
            List<StableKey> children = new ArrayList<>();
            children.add(schemaKey(schema));
            children.add(contextKey(actionTarget));
            String tag;
            switch (source.kind()) {
                case ONE_SLOT -> {
                    String image = actionImages.get(source.attributes().get(0));
                    if (image == null) {
                        throw theory("Binder body action is not total");
                    }
                    children.add(StableKey.of(
                            "port-leaf/slot", List.of(),
                            List.of(slotKey(actionTarget.slot(image)))));
                    tag = "port/one";
                }
                case ONE_TERM -> {
                    KernelModel.Term invocation = model.term(source.children().get(0));
                    KernelModel.Witness witness = model.witness(invocation.symbol());
                    KernelModel.Embedding original = model.embedding(
                            invocation.attributes().get(0));
                    Map<String, String> images = new LinkedHashMap<>();
                    for (KernelModel.Slot slot : original.source().slots()) {
                        String image = actionImages.get(original.apply(slot.name()));
                        if (image == null) {
                            throw theory("Binder invocation action is not total");
                        }
                        images.put(slot.name(), image);
                    }
                    StableKey composed = embeddingKey(
                            original.source(), actionTarget, images);
                    StableKey eclass = StableKey.of(
                            "eclass", List.of(canonicalEclass(witness.eclass())),
                            List.of(
                                    type(witness.type(), "binder body witness").key(),
                                    contextKey(witness.context())));
                    StableKey invocationKey = StableKey.of(
                            "invocation", List.of(), List.of(eclass, composed));
                    children.add(StableKey.of(
                            "port-leaf/invocation", List.of(), List.of(invocationKey)));
                    tag = "port/one";
                }
                case SEQ, BAG, SET -> {
                    List<StableKey> values = new ArrayList<>();
                    for (String child : source.children()) {
                        values.add(actedPortKey(
                                model.term(child),
                                actionSource,
                                actionTarget,
                                actionImages));
                    }
                    if (source.kind() != KernelModel.TermKind.SEQ) {
                        values.sort(StableKey::compareTo);
                    }
                    if (source.kind() == KernelModel.TermKind.SET) {
                        for (int index = 1; index < values.size(); index++) {
                            if (values.get(index - 1).equals(values.get(index))) {
                                throw theory("Binder action produced a duplicate Set value");
                            }
                        }
                    }
                    children.addAll(values);
                    tag = switch (source.kind()) {
                        case SEQ -> "port/seq";
                        case BAG -> "port/bag";
                        case SET -> "port/set";
                        default -> throw new AssertionError();
                    };
                }
                case BIND -> {
                    if (!actionSource.equals(actionTarget)) {
                        throw theory("Nested binder action must be an endomorphism");
                    }
                    KernelModel.Term body = model.term(source.children().get(0));
                    String bound = source.attributes().get(0);
                    Map<String, String> extended = new LinkedHashMap<>(actionImages);
                    extended.put(bound, bound);
                    children.add(slotKey(body.context().slot(bound)));
                    children.add(actedPortKey(
                            body, body.context(), body.context(), extended));
                    tag = "port/bind";
                }
                case BIND_BLOCK -> {
                    if (!actionSource.equals(actionTarget)) {
                        throw theory("Nested binder-block action must be an endomorphism");
                    }
                    KernelModel.Embedding occurrence = model.embedding(
                            source.attributes().get(0));
                    KernelModel.Term body = model.term(source.children().get(0));
                    Map<String, String> extended = new LinkedHashMap<>(actionImages);
                    for (KernelModel.Slot bound : occurrence.target().slots()) {
                        if (extended.putIfAbsent(bound.name(), bound.name()) != null) {
                            throw theory("Nested binder-block occurrence captures a caller slot");
                        }
                    }
                    children.add(embeddingKey(occurrence));
                    children.add(actedPortKey(
                            body, body.context(), body.context(), extended));
                    tag = "port/bind-block";
                }
                default -> throw new FormatException(
                        FailureCode.INVALID_RECORD_SHAPE,
                        "Binder occurrence body is not a concrete port");
            }
            return StableKey.of(tag, List.of(), children);
        }

        private StableKey embeddingKey(
                KernelModel.Context source,
                KernelModel.Context target,
                Map<String, String> images) {
            List<StableKey> children = new ArrayList<>();
            children.add(contextKey(source));
            children.add(contextKey(target));
            for (SemanticSlot slot : semanticSlots(source)) {
                String image = images.get(slot.name());
                if (image == null) {
                    throw theory("Reconstructed embedding is not total");
                }
                children.add(StableKey.of(
                        "map-entry", List.of(),
                        List.of(slot.key(), slotKey(target.slot(image)))));
            }
            return StableKey.of("embedding", List.of(), children);
        }

        private StableKey permutationEmbedding(
                BinderView descriptor,
                List<Integer> permutation) {
            Map<String, SemanticSlot> images = new HashMap<>();
            for (int index = 0; index < permutation.size(); index++) {
                images.put(
                        descriptor.coordinateSlots().get(index).name(),
                        descriptor.coordinateSlots().get(permutation.get(index)));
            }
            List<StableKey> children = new ArrayList<>();
            children.add(descriptor.boundContextKey());
            children.add(descriptor.boundContextKey());
            for (SemanticSlot slot : descriptor.orderedSlots()) {
                children.add(StableKey.of(
                        "map-entry", List.of(),
                        List.of(slot.key(), images.get(slot.name()).key())));
            }
            return StableKey.of("embedding", List.of(), children);
        }

        private StableKey permutationAction(
                BinderView descriptor,
                List<Integer> permutation) {
            return permutationAction(
                    descriptor.coordinateSlots(), descriptor.orderedSlots(), permutation);
        }

        private StableKey permutationAction(
                List<SemanticSlot> coordinates,
                List<SemanticSlot> ordered,
                List<Integer> permutation) {
            Map<String, Integer> orderedIndex = new HashMap<>();
            for (int index = 0; index < ordered.size(); index++) {
                orderedIndex.put(ordered.get(index).name(), index);
            }
            Map<String, Integer> coordinateIndex = new HashMap<>();
            for (int index = 0; index < coordinates.size(); index++) {
                coordinateIndex.put(coordinates.get(index).name(), index);
            }
            List<String> image = new ArrayList<>();
            for (SemanticSlot source : ordered) {
                int sourceCoordinate = coordinateIndex.get(source.name());
                SemanticSlot target = coordinates.get(permutation.get(sourceCoordinate));
                image.add(Integer.toString(orderedIndex.get(target.name())));
            }
            return StableKey.of("permutation-action", image, List.of());
        }

        private StableKey contextKey(List<SemanticSlot> slots) {
            List<SemanticSlot> ordered = slots.stream()
                    .sorted(this::compareSlots).toList();
            return StableKey.of(
                    "context", List.of(),
                    ordered.stream().map(SemanticSlot::key).toList());
        }

        private List<Integer> identityPermutation(int size) {
            List<Integer> result = new ArrayList<>(size);
            for (int index = 0; index < size; index++) {
                result.add(index);
            }
            return result;
        }

        private List<Integer> compose(List<Integer> before, List<Integer> after) {
            List<Integer> result = new ArrayList<>(before.size());
            for (int index = 0; index < before.size(); index++) {
                result.add(after.get(before.get(index)));
            }
            return result;
        }

        private List<Integer> inverse(List<Integer> permutation) {
            List<Integer> result = new ArrayList<>(Collections.nCopies(
                    permutation.size(), -1));
            for (int index = 0; index < permutation.size(); index++) {
                result.set(permutation.get(index), index);
            }
            return result;
        }

        private List<List<Integer>> canonicalPermutationPresentation(
                List<? extends List<Integer>> sourceGenerators,
                List<SemanticSlot> coordinates,
                List<SemanticSlot> ordered) {
            List<List<Integer>> selected = new ArrayList<>();
            while (true) {
                Map<String, List<Integer>> selectedClosure = permutationClosure(
                        selected, coordinates, ordered);
                Map<String, List<Integer>> sourceClosure = permutationClosure(
                        sourceGenerators, coordinates, ordered);
                List<Integer> leastMissing = null;
                for (Map.Entry<String, List<Integer>> entry : sourceClosure.entrySet()) {
                    if (!selectedClosure.containsKey(entry.getKey())) {
                        leastMissing = entry.getValue();
                        break;
                    }
                }
                if (leastMissing == null) {
                    return List.copyOf(selected);
                }
                selected.add(List.copyOf(leastMissing));
            }
        }

        private Map<String, List<Integer>> permutationClosure(
                List<? extends List<Integer>> generators,
                List<SemanticSlot> coordinates,
                List<SemanticSlot> ordered) {
            Map<String, List<Integer>> closure = new java.util.TreeMap<>();
            Deque<List<Integer>> pending = new ArrayDeque<>();
            List<Integer> identity = identityPermutation(coordinates.size());
            closure.put(permutationAction(
                    coordinates, ordered, identity).stableString(), identity);
            pending.add(identity);
            List<List<Integer>> steps = new ArrayList<>(generators.size() * 2);
            for (List<Integer> generator : generators) {
                steps.add(List.copyOf(generator));
                steps.add(inverse(generator));
            }
            steps.sort(Comparator.comparing(value -> permutationAction(
                    coordinates, ordered, value).stableString()));
            while (!pending.isEmpty()) {
                List<Integer> current = pending.removeFirst();
                consumeOrbitWork();
                for (List<Integer> step : steps) {
                    List<Integer> composed = compose(current, step);
                    String key = permutationAction(
                            coordinates, ordered, composed).stableString();
                    if (!closure.containsKey(key)) {
                        if (closure.size() >= limits.maxTableEntries()) {
                            throw resource(
                                    "binder group closure exceeds the table-entry bound");
                        }
                        closure.put(key, composed);
                        pending.addLast(composed);
                    }
                }
            }
            return closure;
        }

        private void consumeOrbitWork() {
            orbitWork = Math.addExact(orbitWork, 1L);
            if (orbitWork > limits.maxOrbitMembers()) {
                throw resource(
                        "semantic group reconstruction exceeds the bundle orbit-work bound");
            }
        }

        private String canonicalSignedInt(
                String value,
                String field,
                boolean allowMinusOne) {
            try {
                int parsed = Integer.parseInt(value);
                if ((!allowMinusOne && parsed < 0) || (allowMinusOne && parsed < -1)
                        || !Integer.toString(parsed).equals(value)) {
                    throw new NumberFormatException();
                }
                return value;
            } catch (NumberFormatException exception) {
                throw new FormatException(
                        FailureCode.INTEGER_OVERFLOW,
                        field + " is not canonical", exception);
            }
        }

        private List<Integer> parseOccurrencePath(String encoded) {
            if (encoded.isEmpty()) {
                throw malformed("empty binder occurrence path");
            }
            List<Integer> result = new ArrayList<>();
            for (String coordinate : encoded.split("/", -1)) {
                result.add(parseNonnegative(coordinate, "binder occurrence path"));
            }
            return List.copyOf(result);
        }

        private boolean occursAtPath(
                KernelModel.Term root,
                String sourceId,
                List<Integer> path) {
            if (root.kind() != KernelModel.TermKind.APP) {
                return false;
            }
            KernelModel.Term current = root;
            for (int coordinate : path) {
                if (coordinate >= current.children().size()) {
                    return false;
                }
                current = model.term(current.children().get(coordinate));
            }
            return current.id().equals(sourceId);
        }

        private record SemanticSlot(
                String name,
                ExactType type,
                String alphabet,
                BigInteger ordinal,
                StableKey key) {
        }

        private record IndexedTerm(
                int index, KernelModel.Term term, StableKey key) {
        }

        private record Normalization(
                List<KernelModel.Term> outputTerms,
                List<StableKey> outputKeys,
                List<List<Integer>> fibers,
                StableKey containerKey) {
        }

        private record TraceView(
                StableKey key, boolean reordered, boolean deduplicated) {
        }

        private record BinderView(
                KernelModel.Binder binder,
                List<SemanticSlot> coordinateSlots,
                List<SemanticSlot> orderedSlots,
                StableKey boundContextKey,
                StableKey payloadKey,
                StableKey descriptorKey,
                List<List<Integer>> generators,
                Map<String, Integer> generatorOrdinals) {
        }

        private record BinderProofStep(
                List<Integer> permutation, StableKey proof) {
        }

        private record BinderDerivation(
                List<Integer> permutation, StableKey proof) {
        }

        private enum ConstructionKind {
            NONE,
            FLAT,
            CHAIN,
            CONTAINER
        }

        private enum ChainKind {
            JOIN,
            ARROW
        }

        private enum BoundaryRule {
            EXACT,
            LEFT_SUBTYPE_OF_RIGHT,
            RIGHT_SUBTYPE_OF_LEFT,
            DISJOINT_BRANCHES
        }

        private enum CombinationDecision {
            ARROW_PRODUCT,
            JOIN_OVERLAP,
            JOIN_DISJOINT
        }

        private enum LeafTypeRule {
            EXACT_RELATION,
            PRIMITIVE_SET_SINGLETON
        }

        private record ConstructionEvidence(
                String key,
                String targetTermId,
                String operatorId,
                String path,
                String sourceEndpointKey,
                String sourceOwner) {
        }

        private record VerifiedReplayConstruction(
                ConstructionKind kind,
                String sourceTermId,
                String evidenceKey,
                String sourceEndpointKey,
                String sourceOwner,
                ConstructionEvidence evidence) {
            private boolean matches(
                    KernelModel.Term source,
                    Wire.Node reference) {
                if (!sourceTermId.equals(source.id())
                        || !kind.name().equals(reference.scalar(0))
                        || !evidenceKey.equals(reference.scalar(1))
                        || !sourceEndpointKey.equals(reference.scalar(2))
                        || !sourceOwner.equals(reference.scalar(3))) {
                    return false;
                }
                return evidence == null
                        || evidence.targetTermId().equals(source.id());
            }
        }

        private record BinderEvidence(
                String key,
                String rootTermId,
                String sourceTermId,
                List<Integer> path) {
            private BinderEvidence {
                path = List.copyOf(path);
            }
        }

        private record FlatSplice(
                List<Integer> path,
                int outerArity,
                int nestedArity,
                int position,
                StableKey nestedSource) {
            private StableKey key() {
                List<String> scalars = new ArrayList<>(
                        path.stream().map(Object::toString).toList());
                scalars.add(Integer.toString(outerArity));
                scalars.add(Integer.toString(nestedArity));
                scalars.add(Integer.toString(position));
                return StableKey.of(
                        "associative-splice-v1", scalars,
                        List.of(nestedSource));
            }
        }

        private record FlatView(
                KernelModel.Operator operator,
                KernelModel.Context context,
                int arity,
                StableKey key,
                List<KernelModel.Term> leafTerms,
                boolean leaf) {
            private static FlatView leaf(KernelModel.Term term, StableKey key) {
                return new FlatView(null, term.context(), 0, key, List.of(term), true);
            }

            private static FlatView application(
                    KernelModel.Operator operator,
                    KernelModel.Context context,
                    int arity,
                    StableKey key,
                    List<KernelModel.Term> leaves) {
                return new FlatView(
                        operator, context, arity, key, List.copyOf(leaves), false);
            }
        }

        private record ChainView(
                ChainKind kind,
                KernelModel.Context context,
                ChainDag outputDag,
                StableKey key,
                List<KernelModel.Term> leaves,
                List<ExactType> leafTypes,
                List<ChainDag> leafDags) {
            private ChainView {
                leaves = List.copyOf(leaves);
                leafTypes = List.copyOf(leafTypes);
                leafDags = List.copyOf(leafDags);
                if (leaves.size() != leafTypes.size()
                        || leaves.size() != leafDags.size()) {
                    throw new IllegalArgumentException(
                            "Dependent-chain leaves and type proofs differ in arity");
                }
            }

            private ExactType outputType() {
                return outputDag.relationType();
            }
        }

        private record ChainDag(
                ExactType relationType,
                List<List<ChainColumn>> alternatives,
                ExactType commonAncestor,
                StableKey key) {
            private ChainDag {
                alternatives = alternatives.stream().map(List::copyOf).toList();
            }
        }

        private record ChainColumn(
                ExactType exact,
                List<ExactType> ancestry,
                StableKey key) {
            private ChainColumn {
                ancestry = List.copyOf(ancestry);
            }
        }

        private record BoundaryView(
                BoundaryRule rule,
                ExactType left,
                ExactType right,
                ExactType meet,
                ExactType common,
                List<ExactType> leftPath,
                List<ExactType> rightPath,
                StableKey key) {
            private BoundaryView {
                leftPath = List.copyOf(leftPath);
                rightPath = List.copyOf(rightPath);
            }
        }

        private record ChainCombination(
                ChainDag outputDag,
                List<CombinationCaseView> cases) {
            private ChainCombination {
                cases = List.copyOf(cases);
            }
        }

        private record CombinationCaseView(
                int leftAlternative,
                int rightAlternative,
                CombinationDecision decision,
                BoundaryView boundary,
                List<ChainColumn> resultAlternative,
                StableKey key) {
            private CombinationCaseView {
                resultAlternative = resultAlternative == null
                        ? null : List.copyOf(resultAlternative);
            }
        }
    }

    private StableKey parseStableKey(String encoded, String label) {
        if (encoded.length() > limits.maxStringBytes()) {
            throw resource(label + " exceeds its configured string bound");
        }
        StableKeyParser parser = new StableKeyParser(encoded, label);
        StableKey key = parser.parse(0);
        if (!parser.atEnd()) {
            throw malformed(label + " has trailing structural-key data");
        }
        if (!encoded.equals(key.stableString())) {
            throw new FormatException(
                    FailureCode.NONCANONICAL_ENCODING,
                    label + " is not canonically length encoded");
        }
        return key;
    }

    private final class StableKeyParser {
        private final String source;
        private final String label;
        private int offset;

        private StableKeyParser(String source, String label) {
            this.source = source;
            this.label = label;
        }

        private StableKey parse(int depth) {
            if (depth > limits.maxDepth()) {
                throw resource(label + " exceeds the structural-key depth bound");
            }
            parsedKeyNodes = Math.addExact(parsedKeyNodes, 1);
            if (parsedKeyNodes > limits.maxNodes()) {
                throw resource("semantic structural keys exceed the node bound");
            }
            String tag = readLengthPrefixed("tag");
            if (tag.isEmpty()) {
                throw malformed(label + " has an empty tag");
            }
            expect('[');
            int scalarCount = readCount("scalar count");
            List<String> scalars = new ArrayList<>(scalarCount);
            for (int index = 0; index < scalarCount; index++) {
                scalars.add(readLengthPrefixed("scalar"));
            }
            expect(']');
            expect('{');
            int childCount = readCount("child count");
            List<StableKey> children = new ArrayList<>(childCount);
            for (int index = 0; index < childCount; index++) {
                int length = readUnsigned("child length", ':');
                if (length > source.length() - offset) {
                    throw malformed(label + " has a truncated child key");
                }
                String childSource = source.substring(offset, offset + length);
                offset += length;
                StableKeyParser childParser = new StableKeyParser(childSource, label);
                StableKey child = childParser.parse(depth + 1);
                if (!childParser.atEnd()) {
                    throw malformed(label + " child length does not delimit one key");
                }
                children.add(child);
            }
            expect('}');
            return StableKey.of(tag, scalars, children);
        }

        private int readCount(String field) {
            int value = readUnsigned(field, ':');
            if (value > limits.maxTableEntries()) {
                throw resource(label + " " + field + " exceeds its configured bound");
            }
            return value;
        }

        private String readLengthPrefixed(String field) {
            int length = readUnsigned(field + " length", ':');
            if (length > source.length() - offset) {
                throw malformed(label + " has a truncated " + field);
            }
            String value = source.substring(offset, offset + length);
            offset += length;
            return value;
        }

        private int readUnsigned(String field, char delimiter) {
            int start = offset;
            while (offset < source.length() && source.charAt(offset) != delimiter) {
                char character = source.charAt(offset);
                if (character < '0' || character > '9') {
                    throw malformed(label + " has a nonnumeric " + field);
                }
                offset++;
            }
            if (offset == start || offset >= source.length()) {
                throw malformed(label + " has a missing " + field);
            }
            String digits = source.substring(start, offset++);
            if (digits.length() > 1 && digits.charAt(0) == '0') {
                throw new FormatException(
                        FailureCode.NONCANONICAL_ENCODING,
                        label + " has a noncanonical " + field);
            }
            try {
                long value = Long.parseLong(digits);
                if (value > Integer.MAX_VALUE) {
                    throw new NumberFormatException("too large");
                }
                return (int) value;
            } catch (NumberFormatException exception) {
                throw new FormatException(
                        FailureCode.INTEGER_OVERFLOW,
                        label + " has an overflowing " + field,
                        exception);
            }
        }

        private void expect(char character) {
            if (offset >= source.length() || source.charAt(offset) != character) {
                throw malformed(label + " expected '" + character + "'");
            }
            offset++;
        }

        private boolean atEnd() {
            return offset == source.length();
        }
    }

    private static int parsePositiveInt(String encoded, String field) {
        long value = Bundle.parseUnsignedLong(encoded, field);
        if (value == 0 || value > Integer.MAX_VALUE) {
            throw malformed(field + " is not a positive int");
        }
        return (int) value;
    }

    private static int parseNonnegativeInt(String encoded, String field) {
        long value = Bundle.parseUnsignedLong(encoded, field);
        if (value > Integer.MAX_VALUE) {
            throw malformed(field + " exceeds int range");
        }
        return (int) value;
    }

    private static long parseNonnegativeLong(String encoded, String field) {
        return Bundle.parseUnsignedLong(encoded, field);
    }

    private static int parseCanonicalInt(String encoded, String field) {
        try {
            int value = Integer.parseInt(encoded);
            if (!Integer.toString(value).equals(encoded)) {
                throw new NumberFormatException("noncanonical integer");
            }
            return value;
        } catch (NumberFormatException exception) {
            throw new FormatException(
                    FailureCode.INVALID_RECORD_SHAPE,
                    field + " is not a canonical signed int",
                    exception);
        }
    }

    private static boolean parseCanonicalBoolean(String encoded, String field) {
        if (encoded.equals("true")) {
            return true;
        }
        if (encoded.equals("false")) {
            return false;
        }
        throw malformed(field + " is not a canonical boolean");
    }

    private static String requireNonblankText(String value, String field) {
        if (value == null || value.isBlank()) {
            throw malformed(field + " is blank");
        }
        return value;
    }

    private static String requireCanonicalText(String value, String field) {
        if (value == null || value.isBlank() || !value.equals(value.trim())) {
            throw malformed(field + " is blank or noncanonical");
        }
        return value;
    }

    static String requireCanonicalIdentity(String value, String field) {
        if (!isAdmittedIdentity(value)) {
            throw malformed(field + " is not a well-formed visible identity");
        }
        return value;
    }

    private static <E extends Enum<E>> E enumValue(
            Class<E> type,
            String encoded,
            String field) {
        try {
            return Enum.valueOf(type, encoded);
        } catch (IllegalArgumentException exception) {
            throw new FormatException(
                    FailureCode.UNKNOWN_VARIANT,
                    "Unknown " + field + " " + encoded,
                    exception);
        }
    }

    private static String requireIncreasing(String prior, String value, String label) {
        if (value.isEmpty()) {
            throw malformed(label + " has an empty key");
        }
        if (prior != null && prior.compareTo(value) >= 0) {
            FailureCode code = prior.equals(value)
                    ? FailureCode.DUPLICATE_ID : FailureCode.NONCANONICAL_ENCODING;
            throw new FormatException(code, label + " records are duplicated or unsorted");
        }
        return value;
    }

    private static FormatException malformed(String message) {
        return new FormatException(FailureCode.INVALID_RECORD_SHAPE, message);
    }

    private static FormatException invalidType(String message) {
        return new FormatException(FailureCode.INVALID_TYPE, message);
    }

    private static FormatException theory(String message) {
        return new FormatException(FailureCode.THEORY_MISMATCH, message);
    }

    private static FormatException resource(String message) {
        return new FormatException(FailureCode.RESOURCE_LIMIT, message);
    }

    static String decodeCanonicalUtf8(byte[] value, String label) {
        try {
            return StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT)
                    .onUnmappableCharacter(CodingErrorAction.REPORT)
                    .decode(ByteBuffer.wrap(value))
                    .toString();
        } catch (CharacterCodingException exception) {
            throw theory(label + " is not canonical UTF-8");
        }
    }

    private static String sha256(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(
                    value.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new AssertionError("JDK 17 must provide SHA-256", exception);
        }
    }

    private enum OverflowMode {
        FORBID,
        MODULAR
    }

    private enum TypeKind {
        TYPE_VARIABLE,
        INT,
        BOOL,
        ARROW,
        RELATION,
        CONSTRUCTOR
    }

    private enum Law {
        ASSOCIATIVITY("all-legal-outer-nested-arities-and-splice-positions"),
        COMMUTATIVITY("all-admitted-sibling-permutations"),
        IDEMPOTENCY("all-admitted-quotient-surjections"),
        UNIT("exact-empty-fold-deletion");

        private final String family;

        Law(String family) {
            this.family = family;
        }

        String family() {
            return family;
        }
    }

    private record ProfileEvidence(
            OverflowMode overflow,
            StableKey key,
            String fingerprint) {
    }

    private record TypeLedger(
            Map<String, ExactType> byId,
            Map<String, ExactType> byDisplay) {
    }

    private record ExactType(
            String id,
            TypeKind kind,
            String symbol,
            List<ExactType> arguments,
            StableKey key,
            String display) {
        private ExactType {
            arguments = List.copyOf(arguments);
            Objects.requireNonNull(key, "key");
            Objects.requireNonNull(display, "display");
        }

        boolean is(TypeKind expected) {
            return kind == expected;
        }
    }

    private record ExpectedLaw(
            StableKey index,
            String operatorId,
            String operatorIdentity,
            String runtimeTypeReference,
            ExactType resultType,
            String path,
            Law law,
            String schemaId,
            StableKey schemaKey,
            StableKey parameter,
            StableKey left,
            StableKey right,
            String sourceArtifact,
            String declarationId) {
    }

    private record OperatorPath(String operatorId, String path) {
    }

    private record ProducerOrbitCandidate(
            KernelModel.Term wireTerm,
            KernelModel.Embedding witness,
            StableKey candidateShape,
            StableKey completeOrder) {
        private ProducerOrbitCandidate {
            Objects.requireNonNull(wireTerm, "wireTerm");
            Objects.requireNonNull(witness, "witness");
            Objects.requireNonNull(candidateShape, "candidateShape");
            Objects.requireNonNull(completeOrder, "completeOrder");
        }
    }

    private record LawLedger(
            Map<OperatorPath, Map<Law, ExpectedLaw>> byOperatorPath) {
    }

    /** Checked quotient authority consumed by the proof kernel. */
    static final class Authorization {
        private final boolean testOnlyFixture;
        private final Map<String, ContainerAuthority> containers;
        private final CanonicalKeyProvider canonicalKeyProvider;
        private final Map<String, StableKey> orbitComparisonKeys;
        private final Map<String, StableKey> orbitRepresentativeKeys;

        private Authorization(
                boolean testOnlyFixture,
                Map<String, ContainerAuthority> containers,
                CanonicalKeyProvider canonicalKeyProvider,
                Map<String, StableKey> orbitComparisonKeys,
                Map<String, StableKey> orbitRepresentativeKeys) {
            this.testOnlyFixture = testOnlyFixture;
            this.containers = Collections.unmodifiableMap(
                    new LinkedHashMap<>(containers));
            this.canonicalKeyProvider = canonicalKeyProvider;
            this.orbitComparisonKeys = Collections.unmodifiableMap(
                    new LinkedHashMap<>(orbitComparisonKeys));
            this.orbitRepresentativeKeys = Collections.unmodifiableMap(
                    new LinkedHashMap<>(orbitRepresentativeKeys));
        }

        static Authorization testOnlyFixture() {
            return new Authorization(true, Map.of(), null, Map.of(), Map.of());
        }

        static Authorization checked(
                KernelModel model,
                Map<OperatorPath, Map<Law, ExpectedLaw>> checkedLaws,
                CanonicalKeyProvider canonicalKeyProvider,
                Map<String, StableKey> orbitComparisonKeys,
                Map<String, StableKey> orbitRepresentativeKeys) {
            Map<String, ContainerAuthority> containers = new LinkedHashMap<>();
            for (KernelModel.Operator operator : model.operators().values()) {
                for (int port = 0; port < operator.schemas().size(); port++) {
                    collectContainerAuthorities(
                            model,
                            operator,
                            model.schema(operator.schemas().get(port)),
                            port,
                            0,
                            checkedLaws,
                            containers);
                }
            }
            return new Authorization(
                    false,
                    containers,
                    Objects.requireNonNull(canonicalKeyProvider, "canonicalKeyProvider"),
                    Objects.requireNonNull(orbitComparisonKeys, "orbitComparisonKeys"),
                    Objects.requireNonNull(
                            orbitRepresentativeKeys, "orbitRepresentativeKeys"));
        }

        int compareCanonicalTerms(
                KernelModel.Term left,
                KernelModel.Term right,
                TermOps fallback) {
            Objects.requireNonNull(left, "left");
            Objects.requireNonNull(right, "right");
            Objects.requireNonNull(fallback, "fallback");
            if (testOnlyFixture) {
                return fallback.structuralNode(left).compareTo(
                        fallback.structuralNode(right));
            }
            StableKey leftOrbit = orbitComparisonKeys.get(left.id());
            StableKey rightOrbit = orbitComparisonKeys.get(right.id());
            if (leftOrbit != null || rightOrbit != null) {
                if (leftOrbit == null || rightOrbit == null) {
                    throw new UncheckableException(
                            FailureCode.INCOMPLETE_ORBIT,
                            "Canonical comparison crosses an incomplete producer-order orbit");
                }
                return leftOrbit.compareTo(rightOrbit);
            }
            return canonicalShapeKey(left, fallback).compareTo(
                    canonicalShapeKey(right, fallback));
        }

        String canonicalTermKey(KernelModel.Term term, TermOps fallback) {
            if (testOnlyFixture) {
                return Base64.getEncoder().encodeToString(
                        Codec.encodeNode(fallback.structuralNode(term)));
            }
            StableKey representative = orbitRepresentativeKeys.get(term.id());
            if (representative != null) {
                return representative.stableString();
            }
            return canonicalShapeKey(term, fallback).stableString();
        }

        private StableKey canonicalShapeKey(
                KernelModel.Term term,
                TermOps dynamicTerms) {
            return canonicalKeyProvider.key(term, dynamicTerms);
        }

        void requireContainerNormalization(
                String operatorId,
                String path,
                String schemaId,
                KernelModel.TermKind kind) {
            if (testOnlyFixture) {
                return;
            }
            ContainerAuthority authority = containers.get(
                    operatorId + "\u0000" + path);
            if (authority == null
                    || !authority.schemaId().equals(schemaId)
                    || !containerKindsAgree(authority.kind(), kind)) {
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        "Container normalization lacks exact operator/path authority for "
                                + operatorId + "@" + path);
            }
            Set<Law> laws = authority.laws();
            boolean authorized = kind == KernelModel.TermKind.SEQ
                    || (kind == KernelModel.TermKind.BAG
                            && laws.contains(Law.COMMUTATIVITY))
                    || (kind == KernelModel.TermKind.SET
                            && laws.contains(Law.COMMUTATIVITY)
                            && laws.contains(Law.IDEMPOTENCY));
            if (!authorized) {
                throw new FormatException(
                        FailureCode.MISSING_EVIDENCE,
                        "Container normalization lacks exact quotient-law evidence for "
                                + operatorId + "@" + path);
            }
        }

        private static void collectContainerAuthorities(
                KernelModel model,
                KernelModel.Operator operator,
                KernelModel.Schema schema,
                int port,
                int depth,
                Map<OperatorPath, Map<Law, ExpectedLaw>> checkedLaws,
                Map<String, ContainerAuthority> target) {
            String path = port + "/" + depth;
            if (schema.kind() == KernelModel.SchemaKind.SEQ
                    || schema.kind() == KernelModel.SchemaKind.DEPENDENT_SEQ
                    || schema.kind() == KernelModel.SchemaKind.BAG
                    || schema.kind() == KernelModel.SchemaKind.SET) {
                Map<Law, ExpectedLaw> laws = checkedLaws.getOrDefault(
                        new OperatorPath(operator.id(), path), Map.of());
                ContainerAuthority authority = new ContainerAuthority(
                        schema.id(), schema.kind(), Set.copyOf(laws.keySet()));
                ContainerAuthority prior = target.putIfAbsent(
                        operator.id() + "\u0000" + path, authority);
                if (prior != null && !prior.equals(authority)) {
                    throw theory("Conflicting exact container authority at "
                            + operator.id() + "@" + path);
                }
            }
            if (schema.childSchemas().size() == 1) {
                collectContainerAuthorities(
                        model,
                        operator,
                        model.schema(schema.childSchemas().get(0)),
                        port,
                        depth + 1,
                        checkedLaws,
                        target);
            }
        }

        private record ContainerAuthority(
                String schemaId,
                KernelModel.SchemaKind kind,
                Set<Law> laws) {
        }

        private static boolean containerKindsAgree(
                KernelModel.SchemaKind schema,
                KernelModel.TermKind term) {
            return term == KernelModel.TermKind.SEQ
                            && (schema == KernelModel.SchemaKind.SEQ
                                    || schema
                                            == KernelModel.SchemaKind.DEPENDENT_SEQ)
                    || term == KernelModel.TermKind.BAG
                            && schema == KernelModel.SchemaKind.BAG
                    || term == KernelModel.TermKind.SET
                            && schema == KernelModel.SchemaKind.SET;
        }
    }

    @FunctionalInterface
    private interface CanonicalKeyProvider {
        StableKey key(KernelModel.Term term, TermOps dynamicTerms);
    }

    private static final class StableKey implements Comparable<StableKey> {
        private final String tag;
        private final List<String> scalars;
        private final List<StableKey> children;

        private StableKey(String tag, List<String> scalars, List<StableKey> children) {
            this.tag = Objects.requireNonNull(tag, "tag");
            this.scalars = List.copyOf(scalars);
            this.children = List.copyOf(children);
        }

        static StableKey of(
                String tag,
                List<String> scalars,
                List<StableKey> children) {
            return new StableKey(tag, scalars, children);
        }

        String tag() {
            return tag;
        }

        List<String> scalars() {
            return scalars;
        }

        List<StableKey> children() {
            return children;
        }

        String stableString() {
            StringBuilder result = new StringBuilder();
            appendEncoded(result, tag);
            result.append('[').append(scalars.size()).append(':');
            for (String scalar : scalars) {
                appendEncoded(result, scalar);
            }
            result.append(']').append('{').append(children.size()).append(':');
            for (StableKey child : children) {
                String encoded = child.stableString();
                result.append(encoded.length()).append(':').append(encoded);
            }
            return result.append('}').toString();
        }

        @Override
        public int compareTo(StableKey other) {
            Objects.requireNonNull(other, "other");
            int compared = tag.compareTo(other.tag);
            if (compared != 0) {
                return compared;
            }
            compared = compareStrings(scalars, other.scalars);
            if (compared != 0) {
                return compared;
            }
            int shared = Math.min(children.size(), other.children.size());
            for (int index = 0; index < shared; index++) {
                compared = children.get(index).compareTo(other.children.get(index));
                if (compared != 0) {
                    return compared;
                }
            }
            return Integer.compare(children.size(), other.children.size());
        }

        private static int compareStrings(List<String> left, List<String> right) {
            int shared = Math.min(left.size(), right.size());
            for (int index = 0; index < shared; index++) {
                int compared = left.get(index).compareTo(right.get(index));
                if (compared != 0) {
                    return compared;
                }
            }
            return Integer.compare(left.size(), right.size());
        }

        private static void appendEncoded(StringBuilder target, String value) {
            target.append(value.length()).append(':').append(value);
        }

        @Override
        public boolean equals(Object other) {
            return other instanceof StableKey key
                    && tag.equals(key.tag)
                    && scalars.equals(key.scalars)
                    && children.equals(key.children);
        }

        @Override
        public int hashCode() {
            return Objects.hash(tag, scalars, children);
        }
    }
}
