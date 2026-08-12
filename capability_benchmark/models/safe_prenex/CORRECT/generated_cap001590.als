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

pred cap001590 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((no CapBenchA and no CapBenchB) and some CapBenchB))) }
pred cap001590c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap001590 { cap001590 iff cap001590c }
check CapBenchEquivalent_cap001590 for 4
