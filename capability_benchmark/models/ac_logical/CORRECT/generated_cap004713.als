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

pred cap004713 { not ((inv4 and ((some capBenchS or no CapBenchA) or no CapBenchB)) and ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004713c { ((not ((no CapBenchA and some CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv4 and ((some capBenchS or no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004713 { cap004713 iff cap004713c }
check CapBenchEquivalent_cap004713 for 4
