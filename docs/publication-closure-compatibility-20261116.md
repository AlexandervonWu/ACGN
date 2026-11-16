# Publication Closure Compatibility

The publication candidate `70e6b9cd` retains experiment source `2d70f89a`.
GitHub run `43788530118` passed frontend, manifest contracts, the cataloged
Lean audit, finite container closure and Java selector refinement. It blocked
the bounded-five policy extractor and the fourth/fifth source extractors.
These failures are not passing closure evidence.

## Isolated Policy Attribution

`PolicyRepresentationExtractor` previously attributed only `AlloyOperatorPolicy`
and relied on javac's implicit filename lookup for dependencies. The sealed
certificate hierarchy names the package-private `DerivedEqualityCertificate`,
which is declared in `EqualityCertificates.java`, not its own named file.
Full production compilation succeeds, but that incomplete source submission
cannot resolve the permitted subclass. Submit the complete frozen source set,
as the other extractors already do, and select the unique policy compilation
unit explicitly. All field, signature, assignment, nominal-type and effect
checks remain unchanged. The full closure's constructor/getter/qualifier
mutation controls remain required.

## Strict Source Bindings

The failed fourth/fifth extractors correctly reject the earlier class pins.
The reviewed implementation changes since `8579d93f` include:

- The invocation-local positive certificate memo no longer evicts at 8,192
  entries. Identity keys, policy invalidation, visiting-cycle detection,
  child verification, local verification before memo insertion, and release
  on scope close remain. Capacity is not a proof-admission condition.
- The adapter retains authenticated local-binder projection sources, deduplicates
  equal typed ambient domain operands, and consumes the admitted typed JOIN
  family. Those additions do not replace container-law admission or the
  independent wire verifier.
- The retained-source classes gained typed declaration/domain/phase provenance
  and the source-scheduling repair. Their certification matrix and source
  lineage remain distinct from metric-only comparison copies. The scheduling
  laws and evidence are described in
  [the source contract](distance-parity-20261107/CAPABILITY_SOURCE_SCHEDULING.md).

The new pins identify that exact candidate; old pins are not alternate accepted
values. Additional tests reject the superseded pairs. This does not prove every
new Java method or expand any finite claim. The existing independent observation
censuses, Lean replays, negative/source mutations and two clean builds must all
pass before a repaired closure is reported VERIFIED. Historical reports remain
unchanged. No production source, proof statement, semantic guard, measurement,
resource guard, or public-certification boundary is changed by this CI repair.

## CALL Lowering Follow-Up

Run `43791759225` subsequently passed bounded-five and next-five, then blocked
at the third-five CALL source extractor. Paired compiler-token inspection of
`91825cff` and `8cc55384` isolates one changed tracked method: `buildEGraph`
now supplies the source node to `isFlexibleArity(node, opcode)`. That existing
production correction distinguishes unary NO/ONE/LONE syntax from quantifiers.
CALL is not unary and its declared arity, ordered argument ports, nonflat
policy, occurrence checks and source certificate path remain unchanged.
Only this method's exact shape/binding pair is replaced in the extractor and
replay encoder; a new unit control rejects the superseded pair.

Do not replace other pins from an interactive shell's diagnostic. Javac's
unnamed-module display name is locale-sensitive. The paired dump produced
identical old/current tokens for those methods, and the localized module name
alone accounts for their apparent mismatch. The registered closure runner
already fixes `LC_ALL=C`; those bindings and the Registry pins are retained.
No locale normalization or widened fingerprint acceptance is added. Full
registered CI execution, including source mutations and two clean builds,
remains necessary; the diagnostic itself is not a closure result.
