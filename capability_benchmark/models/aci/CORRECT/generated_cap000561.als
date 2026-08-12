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

pred cap000561 { ((inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA)) or ((no CapBenchA and some capBenchS) and no CapBenchB) or ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000561c { (((no CapBenchA and some capBenchS) and no CapBenchB) or ((some CapBenchA and no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) or (inv1 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap000561 { cap000561 iff cap000561c }
check CapBenchEquivalent_cap000561 for 4
