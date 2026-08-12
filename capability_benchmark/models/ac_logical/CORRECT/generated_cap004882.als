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

pred cap004882 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)) and ((no CapBenchB or some capBenchS) and some CapBenchA)) }
pred cap004882c { ((not ((no CapBenchB or some capBenchS) and some CapBenchA)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and CapBenchA in CapBenchA + CapBenchB) and some capBenchS)))) }
assert CapBenchEquivalent_cap004882 { cap004882 iff cap004882c }
check CapBenchEquivalent_cap004882 for 4
