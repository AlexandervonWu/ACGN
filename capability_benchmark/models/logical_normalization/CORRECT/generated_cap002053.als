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

pred cap002053 { no x: CapBenchA | (x->x in capBenchR and (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
pred cap002053c { all x: CapBenchA | not (x->x in capBenchR and (inv4 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchA))) }
assert CapBenchEquivalent_cap002053 { cap002053 iff cap002053c }
check CapBenchEquivalent_cap002053 for 4
