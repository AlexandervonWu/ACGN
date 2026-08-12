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

pred cap002357 { ((inv4 and ((some capBenchS or some capBenchR) or some capBenchS)) iff ((no CapBenchA and no CapBenchA) and some CapBenchA)) }
pred cap002357c { (((not (inv4 and ((some capBenchS or some capBenchR) or some capBenchS))) or ((no CapBenchA and no CapBenchA) and some CapBenchA)) and ((not ((no CapBenchA and no CapBenchA) and some CapBenchA)) or (inv4 and ((some capBenchS or some capBenchR) or some capBenchS)))) }
assert CapBenchEquivalent_cap002357 { cap002357 iff cap002357c }
check CapBenchEquivalent_cap002357 for 4
