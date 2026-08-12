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

pred cap003156 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or no CapBenchA)) and ((some CapBenchB or some CapBenchB) or some capBenchS)) }
pred cap003156c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchB) or some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((some capBenchR and no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003156 { cap003156 iff cap003156c }
check CapBenchEquivalent_cap003156 for 4
