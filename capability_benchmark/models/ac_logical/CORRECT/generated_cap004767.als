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

pred cap004767 { not ((inv1 and ((no CapBenchB or some CapBenchB) and some capBenchR)) and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004767c { ((not ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((no CapBenchB or some CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004767 { cap004767 iff cap004767c }
check CapBenchEquivalent_cap004767 for 4
