sig A {}
pred p { not ((some A) until (no A)) }
pred q { (no A) releases (some A) }
assert CapBenchEquivalent_captest { p iff q }
check CapBenchEquivalent_captest for 4
