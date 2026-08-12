abstract sig Source {}
sig User extends Source {
    profile : set Work,
    visible : set Work
}
sig Institution extends Source {}

sig Id {}
sig Work {
    ids : some Id,
    source : one Source
}

pred inv1 {
	all u: User | u.visible in u.profile
}

pred inv1c {
	all u : User | u.visible in u.profile
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 




sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000929 { (inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000929c { ((inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (inv1 and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000929 { cap000929 iff cap000929c }
check CapBenchEquivalent_cap000929 for 4
