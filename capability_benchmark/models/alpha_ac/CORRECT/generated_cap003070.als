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

pred cap003070 { all x: CapBenchA | (x->x in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB)) and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) }
pred cap003070c { all renamed: CapBenchA | (((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB) and renamed->renamed in capBenchR and (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap003070 { cap003070 iff cap003070c }
check CapBenchEquivalent_cap003070 for 4
