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

pred cap003395 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) }
pred cap003395c { all renamed: CapBenchA | (((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchB or some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003395 { cap003395 iff cap003395c }
check CapBenchEquivalent_cap003395 for 4
