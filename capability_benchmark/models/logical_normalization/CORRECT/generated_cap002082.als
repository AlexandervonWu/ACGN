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

pred cap002082 { not (all x: CapBenchA | (x->x in capBenchR and (inv4 and ((no CapBenchA and no CapBenchA) and some CapBenchB)))) }
pred cap002082c { some x: CapBenchA | not (x->x in capBenchR and (inv4 and ((no CapBenchA and no CapBenchA) and some CapBenchB))) }
assert CapBenchEquivalent_cap002082 { cap002082 iff cap002082c }
check CapBenchEquivalent_cap002082 for 4
