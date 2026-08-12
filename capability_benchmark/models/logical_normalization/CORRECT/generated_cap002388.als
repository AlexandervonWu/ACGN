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

pred cap002388 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
pred cap002388c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some capBenchR and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap002388 { cap002388 iff cap002388c }
check CapBenchEquivalent_cap002388 for 4
