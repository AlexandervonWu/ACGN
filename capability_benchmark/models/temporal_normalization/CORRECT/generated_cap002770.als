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

pred cap002770 { not always ((inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
pred cap002770c { eventually (not (inv4 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some capBenchR))) }
assert CapBenchEquivalent_cap002770 { cap002770 iff cap002770c }
check CapBenchEquivalent_cap002770 for 4
