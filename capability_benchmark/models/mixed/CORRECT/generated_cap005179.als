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

pred cap005179 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((some CapBenchA and some capBenchR) or some capBenchS))) }
pred cap005179c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and some capBenchR) or some capBenchS)) or (not (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap005179 { cap005179 iff cap005179c }
check CapBenchEquivalent_cap005179 for 4
