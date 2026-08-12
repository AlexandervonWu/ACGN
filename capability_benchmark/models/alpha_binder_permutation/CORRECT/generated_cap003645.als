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

pred cap003645 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap003645c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003645 { cap003645 iff cap003645c }
check CapBenchEquivalent_cap003645 for 4
