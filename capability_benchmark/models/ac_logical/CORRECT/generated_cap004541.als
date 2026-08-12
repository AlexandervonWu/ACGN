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

pred cap004541 { not ((inv1 and ((some CapBenchB or some capBenchS) or some CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)) }
pred cap004541c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchA) and no CapBenchB)) or (not (inv1 and ((some CapBenchB or some capBenchS) or some CapBenchA)))) }
assert CapBenchEquivalent_cap004541 { cap004541 iff cap004541c }
check CapBenchEquivalent_cap004541 for 4
