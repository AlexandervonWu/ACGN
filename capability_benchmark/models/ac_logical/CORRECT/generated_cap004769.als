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

pred cap004769 { not ((inv4 and ((some capBenchS or some CapBenchB) or some capBenchR)) and ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004769c { ((not ((no CapBenchA and CapBenchA in CapBenchA + CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv4 and ((some capBenchS or some CapBenchB) or some capBenchR)))) }
assert CapBenchEquivalent_cap004769 { cap004769 iff cap004769c }
check CapBenchEquivalent_cap004769 for 4
