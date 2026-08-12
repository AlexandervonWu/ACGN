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

pred cap003920 { all x, y: CapBenchA | (x->y in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap003920c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv4 and ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003920 { cap003920 iff cap003920c }
check CapBenchEquivalent_cap003920 for 4
