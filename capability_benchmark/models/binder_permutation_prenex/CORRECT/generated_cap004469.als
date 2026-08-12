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

pred cap004469 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap004469c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some capBenchS or no CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap004469 { cap004469 iff cap004469c }
check CapBenchEquivalent_cap004469 for 4
