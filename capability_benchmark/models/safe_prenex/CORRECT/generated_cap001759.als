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

pred cap001759 { ((all x: CapBenchA | x->x in capBenchR) or (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchR))) }
pred cap001759c { (all x: CapBenchA | (x->x in capBenchR or (inv1 and ((no CapBenchB or some CapBenchA) and some capBenchR)))) }
assert CapBenchEquivalent_cap001759 { cap001759 iff cap001759c }
check CapBenchEquivalent_cap001759 for 4
