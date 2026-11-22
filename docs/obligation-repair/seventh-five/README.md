# Seventh batch of public certification obligations

The starting revision is `69c72235d414edebd272095c2475654fb36177e5`. The ranking follows the dependencies from an admitted source occurrence to its projected leaf position and on to the public certificate and edit judgments. Both frozen scope matrices and the original English requirement ledger supply the statement hashes in `qualification.json`.

| Rank | Obligation | Source and evidence |
| ---: | --- | --- |
| 1 | A2-15 | Parse the selected predicate in the supplied bytes. For the admitted plain ARROW and top-level inclusion fragment, check the identity of each raw operand, its ordered leaves, its retained producer application and its originating class witness. |
| 2 | G-08 | Carry one maximal product from its resolved syntax and declaration ancestry through retained construction, transfer and standalone FULL verification. An independent caller pin commits to the selected raw bytes and the entire binary product. |
| 3 | A2-17 | Check every public projection index against its artifact-owned occurrence, including repeated types and equal-valued leaves at different paths. |
| 4 | P6-13 | Require both submitted certificates to pass source-bound FULL. Check whether their independent typed representatives compose through the public PAIR verifier. |
| 5 | G-07 | Enumerate the admissible partial injections for the two-read fixture, verify the minimum, and replay all seven ordered action rows against the selected input owners. |

The G-08 change repairs the reconstruction of the producer’s exact-column parser proof. A caller can also provide independent declaration-hierarchy evidence for the registered single-product fragment. Details of the admission rules and examples appear in the [wire correspondence](G08-source-to-wire.md), [projection](A217Projection.md), [paired verification](p613-source-pair.md), and [assignment minimum](BoundedAssignmentMinimum.md) notes.

## Reproducing the qualification

Use JDK 17, Lean 4.35.0 and a fresh output directory. The workstation reserve and volume identity are enforced by the qualifier when supplied as below.

```sh
python3 -B docs/obligation-repair/seventh-five/verify_seventh.py "$FRESH_OUTPUT" \
  --external-volume /media/augustus/8618-0ED0 8618-0ED0
```

The two snapshots independently compile the producer, standalone verifier, companion classes and Lean proofs. The qualification compares their deterministic evidence. Repository resource gates also apply when exercising the shared fourth, fifth and sixth checks.

## Replaying an exported unary CALL edit

A caller supplies two original modules, their selected predicates, two serialized certificates and an independently trusted theory digest. Each source declares one primitive signature and a common set of local unary identity functions. Each selected body is `some` applied to a unary call chain ending in that signature. Both chains must have the same length and differ at exactly one called declaration. Callee identity is a syntactic distinction within the retained typed vocabulary. The registered runs use TEST_ONLY provenance.

Set `BUILD` to the absolute path of `build1` or `build2` in a completed qualification. Use its compiled inputs.

```sh
SEVENTH_CLASSPATH="$BUILD/source-authority-probes:$BUILD/producer:$BUILD/verifier:$BUILD/source/lib/*"
```

The exporter obtains both ordered traces from the normal native comparison, checks their agreement, then writes a fresh receipt. The replay CLI checks caller inputs and the receipt independently.

```sh
java -Dacgn.repo.root="$BUILD/source" -Dacgn.provenance.testOverride=true \
  -Dacgn.provenance.producerJar="$BUILD/producer-jar.jar" \
  -Dacgn.provenance.verifierJar="$BUILD/verifier-jar.jar" \
  -cp "$SEVENTH_CLASSPATH" is.fivefivefive.CanDis.NativeUnaryCallExport \
  "$THEORY_SHA256" "$LEFT_SOURCE" "$LEFT_ROOT" "$LEFT_CERT" \
  "$RIGHT_SOURCE" "$RIGHT_ROOT" "$RIGHT_CERT" "$NEW_RECEIPT"
java -cp "$SEVENTH_CLASSPATH" org.acgn.cert.UnaryCallSequence \
  "$THEORY_SHA256" "$LEFT_SOURCE" "$LEFT_ROOT" "$LEFT_CERT" \
  "$RIGHT_SOURCE" "$RIGHT_ROOT" "$RIGHT_CERT" "$NEW_RECEIPT"
```

Each identity includes the raw SHA-256, selected declaration and full certificate SHA-256. Replay requires both source-bound FULL outcomes, derives the two resolved call sequences and reconstructs every action’s stage, ordered address and cost. The receipt includes zero-cost steps. A cost moved to a different occurrence fails even when the sum is preserved. Unequal depths and multiple callee changes return `UNCHECKABLE`. The PAIR equivalence outcome and the edit replay outcome are independent. The executable supplement covers this single-substitution fragment. General edit minimality, arbitrary Alloy programs and refinement of the JVM implementation to the Lean models remain open.
