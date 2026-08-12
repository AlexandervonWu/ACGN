sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t : Track | t in Entry iff no t.~succs
}

pred inv4c {
	all t : Track | t in Entry iff no succs.t
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002631 { not (((inv4 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) since (((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap002631c { ((not (inv4 and ((no CapBenchB or some CapBenchA) and no CapBenchA))) triggered (not ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
assert CapBenchEquivalent_cap002631 { cap002631 iff cap002631c }
check CapBenchEquivalent_cap002631 for 4
