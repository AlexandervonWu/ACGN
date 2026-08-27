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

pred cap000648 { (some (((CapBenchA + CapBenchB) & CapBenchA) & CapBenchA) and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
pred cap000648c { (some ((CapBenchA + CapBenchB) & (CapBenchA & CapBenchA)) and (inv4 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap000648 { cap000648 iff cap000648c }
check CapBenchEquivalent_cap000648 for 4
