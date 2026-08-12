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

pred cap001924 { ((some x: CapBenchA | x->x in capBenchR) and (inv4 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001924c { (some x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchA and some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001924 { cap001924 iff cap001924c }
check CapBenchEquivalent_cap001924 for 4
