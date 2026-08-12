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

pred cap004285 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
pred cap004285c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchS or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap004285 { cap004285 iff cap004285c }
check CapBenchEquivalent_cap004285 for 4
