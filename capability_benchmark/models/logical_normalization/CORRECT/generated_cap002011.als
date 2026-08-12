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

pred cap002011 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
pred cap002011c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((no CapBenchB or some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap002011 { cap002011 iff cap002011c }
check CapBenchEquivalent_cap002011 for 4
