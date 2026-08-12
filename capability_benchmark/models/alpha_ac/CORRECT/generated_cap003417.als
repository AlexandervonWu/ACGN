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

pred cap003417 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA))) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB)) }
pred cap003417c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchB or some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003417 { cap003417 iff cap003417c }
check CapBenchEquivalent_cap003417 for 4
