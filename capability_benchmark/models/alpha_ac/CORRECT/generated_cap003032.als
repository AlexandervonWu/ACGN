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

pred cap003032 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or some CapBenchA)) and ((some capBenchS or some CapBenchB) or no CapBenchB)) }
pred cap003032c { all renamed: CapBenchA | (((some capBenchS or some CapBenchB) or no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchA and some capBenchR) or some CapBenchA))) }
assert CapBenchEquivalent_cap003032 { cap003032 iff cap003032c }
check CapBenchEquivalent_cap003032 for 4
