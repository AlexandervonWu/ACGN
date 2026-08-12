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

pred cap000993 { ((inv1 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB)) or ((no CapBenchA and no CapBenchB) and no CapBenchA) or ((some CapBenchA and some CapBenchB) or some capBenchS)) }
pred cap000993c { (((no CapBenchA and no CapBenchB) and no CapBenchA) or ((some CapBenchA and some CapBenchB) or some capBenchS) or (inv1 and ((some capBenchS or some capBenchS) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000993 { cap000993 iff cap000993c }
check CapBenchEquivalent_cap000993 for 4
