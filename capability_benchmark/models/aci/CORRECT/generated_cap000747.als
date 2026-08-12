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

pred cap000747 { ((inv4 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) or ((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)) or ((no CapBenchA and no CapBenchA) and some CapBenchB)) }
pred cap000747c { (((some capBenchR and some capBenchR) or capBenchR in (CapBenchA -> CapBenchA)) or ((no CapBenchA and no CapBenchA) and some CapBenchB) or (inv4 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB))) }
assert CapBenchEquivalent_cap000747 { cap000747 iff cap000747c }
check CapBenchEquivalent_cap000747 for 4
