# Sixth batch of public certification obligations

The batch starts at `eb5f4f664f46a23194bf38161a79000cceeff016`. The ranking follows the evidence from the selected Alloy declaration to the projected repair. The source census and lineage identity can each be checked before evaluating the decoded certificate. The downstream consumer checks use both results.

| Rank | Original requirement | Source of authority and check |
| ---: | --- | --- |
| 1 | P1-19 | Select a named predicate in the original input bytes, derive its ordered, typed CALL tree, and compare the certificate for that subject against the independent commitment. The fixture family includes mixed, repeated and ordered binary calls. |
| 2 | A2-14 | Follow owner identity from allocation through a frozen forest and authorized copies. Equal-content originals and phase permutations exercise the distinction between structural equality and lineage identity. |
| 3 | P3-10 | Walk typed terms decoded from certificate bytes and enumerate kernel and binder occurrences. Match events, owners and generator paths against the registered structural coverage. |
| 4 | P3-13 | Inventory the concrete retained artifact fields, compiler-resolved reads in the registered consumers, and evidence consumed through the serialized format. |
| 5 | P3-14 | Snapshot the caller's phase list, validate each frozen object against the adapter's ordered input, and use that same snapshot throughout projection. Construct the public view's digest from the result's canonical observation key. |

The scope matrix, claim ledger and qualification profile record the five original requirement identifiers. The proof modules and executable witnesses share a finite domain described in the profile. Review each claim's correspondence boundary before using its results. Parser and JVM refinement, the exported repair sequence and exhaustive cross-file native-action coverage remain open. Historical measurements and the public certification status continue to refer to their published inputs.

## Reproduce

Use JDK 17, Lean 4.35.0, Python and Git. Run the qualifier from this checkout with a new output path outside it.

```sh
python3 -B scripts/verify_sixth_obligation_repair.py "$FRESH_OUTPUT"
```

On the development workstation, add `--external-volume /media/augustus/8618-0ED0 8618-0ED0` to enforce the storage identity and reserve. The qualifier writes the input manifest, a command record for each clean build and the comparison of the two builds' evidence. The scopes and fixture expectations are recorded in [qualification.json](qualification.json).

## Frozen phase ownership

`TheoryAlloyAdapter.Result` retains its own ordered list of frozen objects. The public projection previously checked the caller's list and continued traversing that mutable list. It now takes a private snapshot before the identity check and passes it to every consumer. The single-read regression checks this through `RepairProjection.project`, alongside the existing foreign-object, frozen mutation and concurrency cases. A separate check compares the actual view digest with the digest of the adapter's canonical key.

The model represents Java references by tokens. It proves that success implies the exact ordered source identities, that the key supplied by the adapter determines the view digest, and that every modeled write preserves an admitted frozen observation. The modeled list records reads before Java reorders phases for canonical output. The modeled write covers a frozen payload update. General correspondence for other mutators, Java memory ordering and canonical output ordering remains open. [Projection proof](FrozenProjectionSnapshot.lean)
