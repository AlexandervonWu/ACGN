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

pred cap005143 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap005143c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005143 { cap005143 iff cap005143c }
check CapBenchEquivalent_cap005143 for 4
