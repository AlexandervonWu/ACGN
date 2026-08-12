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
	all u:User| u . visible in u . profile
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

pred cap003761 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
pred cap003761c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchS or some CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap003761 { cap003761 iff cap003761c }
check CapBenchEquivalent_cap003761 for 4
