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

pred cap000887 { (inv1 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000887c { ((inv1 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (inv1 and ((no CapBenchB or some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000887 { cap000887 iff cap000887c }
check CapBenchEquivalent_cap000887 for 4
