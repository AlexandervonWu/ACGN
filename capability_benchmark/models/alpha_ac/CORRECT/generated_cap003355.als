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

pred cap003355 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchB or some capBenchR) and some capBenchS)) and ((some CapBenchA and no CapBenchA) or some CapBenchA)) }
pred cap003355c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchA) or some CapBenchA) and renamed->renamed in capBenchR and (inv4 and ((no CapBenchB or some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap003355 { cap003355 iff cap003355c }
check CapBenchEquivalent_cap003355 for 4
