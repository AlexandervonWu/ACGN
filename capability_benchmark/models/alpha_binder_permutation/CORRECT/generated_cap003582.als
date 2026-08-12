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

pred cap003582 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
pred cap003582c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003582 { cap003582 iff cap003582c }
check CapBenchEquivalent_cap003582 for 4
