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
