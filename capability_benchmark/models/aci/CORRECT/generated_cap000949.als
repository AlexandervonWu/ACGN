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

pred cap000949 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
pred cap000949c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((some CapBenchB or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000949 { cap000949 iff cap000949c }
check CapBenchEquivalent_cap000949 for 4
