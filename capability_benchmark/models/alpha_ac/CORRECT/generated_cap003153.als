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

pred cap003153 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((some CapBenchB or no CapBenchB) or no CapBenchA)) and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS)) }
pred cap003153c { all renamed: CapBenchA | (((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some capBenchS) and renamed->renamed in capBenchR and (inv4 and ((some CapBenchB or no CapBenchB) or no CapBenchA))) }
assert CapBenchEquivalent_cap003153 { cap003153 iff cap003153c }
check CapBenchEquivalent_cap003153 for 4
