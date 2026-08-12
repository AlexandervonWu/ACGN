sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all e : Track | e in Entry iff (all t : Track | t not in succs.e)
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

pred cap000675 { ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA)) or ((some capBenchR and no CapBenchB) or some capBenchS) or ((no CapBenchA and some CapBenchB) and some CapBenchA)) }
pred cap000675c { (((some capBenchR and no CapBenchB) or some capBenchS) or ((no CapBenchA and some CapBenchB) and some CapBenchA) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap000675 { cap000675 iff cap000675c }
check CapBenchEquivalent_cap000675 for 4
