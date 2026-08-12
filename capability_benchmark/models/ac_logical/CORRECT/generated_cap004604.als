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

pred cap004604 { not ((inv1 and ((some CapBenchA and some capBenchS) or some CapBenchB)) and ((some capBenchS or no CapBenchA) or some capBenchR)) }
pred cap004604c { ((not ((some capBenchS or no CapBenchA) or some capBenchR)) or (not (inv1 and ((some CapBenchA and some capBenchS) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004604 { cap004604 iff cap004604c }
check CapBenchEquivalent_cap004604 for 4
