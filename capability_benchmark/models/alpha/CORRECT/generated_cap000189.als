sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4 {
all t:Track | t in Entry <=> t not in Track.^succs
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

pred cap000189 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap000189c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv4 and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap000189 { cap000189 iff cap000189c }
check CapBenchEquivalent_cap000189 for 4
