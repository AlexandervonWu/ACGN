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

pred cap003148 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA)) and ((some CapBenchB or some CapBenchA) or some capBenchS)) }
pred cap003148c { all renamed: CapBenchA | (((some CapBenchB or some CapBenchA) or some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap003148 { cap003148 iff cap003148c }
check CapBenchEquivalent_cap003148 for 4
