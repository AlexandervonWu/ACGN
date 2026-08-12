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

pred cap000983 { (inv1 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) }
pred cap000983c { ((inv1 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or (inv1 and ((no CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000983 { cap000983 iff cap000983c }
check CapBenchEquivalent_cap000983 for 4
