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

pred cap003033 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchB or some capBenchR) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB)) }
pred cap003033c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchB or some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap003033 { cap003033 iff cap003033c }
check CapBenchEquivalent_cap003033 for 4
