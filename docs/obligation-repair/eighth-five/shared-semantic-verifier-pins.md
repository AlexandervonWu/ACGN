# Exact-empty binder verifier correspondence

The P6-09 guard changes `SemanticEvidenceVerifier` in the eighth source set. The exact-empty, TEST_ONLY semantic-evidence path previously returned its fixture authorization without inspecting canonical-orbit binder claims. It now reads the proof table, rejects nonempty binder references and checks the orbit bases for a generator-bearing binder block that would require a missing occurrence. The traversal deduplicates term IDs and follows child terms from those bases. A fixture with no such claim still permits bare port-alpha verification. The existing ARROW-pin check runs first. Normal nonempty semantic-evidence replay and external CALL/ARROW authority retain their existing paths.

## Compiler inputs and exact pins

The baseline is the published seventh tree `7aa4d502`. OpenJDK 17.0.21.1 attributed the baseline and eighth standalone source sets under `--release 17` with the same eight dependency JARs from `lib/`. The diagnostic invoked the registered whole-class scanners on each fully attributed `org.acgn.cert.SemanticEvidenceVerifier` tree. Every prior binding remains in order. Eight new entries arise at the call site and 122 in the guard method. No historical reports supply the new values.

| Input or whole-class fingerprint | Seventh | Eighth |
| --- | --- | --- |
| Java source | `92ddd16fb93b4d18d0b074b08d166291ae115bc985ed6b60a3a71f4efc3cd382` | `40a1f30e354e4e4fac5fabfa60e7c940743fe3a54f160ff5fea967be6c439d9d` |
| javac tree | `b5112361b564655f391d9f9ce264bed924f79a9b3fcbd8b6f2039cc2ad24aa01` | `454ab4a9ae622571b4b1f5fc690cddddc50a811fb24c9806ac472b9a696302d6` |
| Ordinary resolved bindings | `47dc4427500b1ef24863201ee627c2bb3905ecf4aaa2e15836a82ff0e9b87b3d` (19,985) | `0e1a6587d36c037fe55af80bdff163bd7816d0eec1dfc69c14dbf7aea60bcec8` (20,115) |
| Dependent-chain resolved bindings | `3279c660456f16d9b160c97f2e0a859d5bad57a9c0239c6e50856e0349676ab8` (20,037) | `c3eca7cea4ea918b262f8b03b132b90e5c83dc356e436cfc4b09f937ec95c26f` (20,167) |

The compiler pins are mirrored by the profile, container, dependent-chain, flat/container and law Java extractors and the four corresponding independent Python inventories. The fifth law replay imports the fourth profile inventory. Each encoder challenges a stale shape alone, a stale binding alone, and their pair for both the pre-ARROW and seventh verifier. The dependent-chain test submits each challenge to the Lean kernel. The five focused suites ran 19 chain, 18 profile, 13 container, 10 flat/container and 20 law tests. P6-09 controls distinguish missing explicit refs, missing derived occurrences, and admissible empty fixtures. The P6-11 witness checks schema admission on the complete regenerated distribution.

## Live P3-13 retained reads

The compiler census adds one access, `Bundle.proofs()` in `SemanticEvidenceVerifier.verify()`, for the canonical-orbit scan. Its later metadata access moves from ordinal 3 to 4. The other 228 observations retain their targets and methods, including the thirteen retained field/getter pairs and all six wire endpoints. The live 229-row receipt hashes to `4060c2797d27e1622c281e994ccadaaabfce9f611d637d2cf743f6e0ec5cf25e`. The historical sixth and seventh snapshots describe their own input roots.
