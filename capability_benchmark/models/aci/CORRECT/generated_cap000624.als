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

pred cap000624 { (some ((CapBenchA.capBenchR).capBenchR) and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
pred cap000624c { (some (CapBenchA.(capBenchR.capBenchR)) and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap000624 { cap000624 iff cap000624c }
check CapBenchEquivalent_cap000624 for 4
