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

pred cap000783 { ((inv4 and ((no CapBenchB or no CapBenchB) and some capBenchR)) or ((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap000783c { (((some CapBenchA and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB) or ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB) or (inv4 and ((no CapBenchB or no CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap000783 { cap000783 iff cap000783c }
check CapBenchEquivalent_cap000783 for 4
