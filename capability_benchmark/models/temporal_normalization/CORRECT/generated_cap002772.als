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

pred cap002772 { not historically ((inv4 and ((some CapBenchA and no CapBenchA) or some capBenchR))) }
pred cap002772c { once (not (inv4 and ((some CapBenchA and no CapBenchA) or some capBenchR))) }
assert CapBenchEquivalent_cap002772 { cap002772 iff cap002772c }
check CapBenchEquivalent_cap002772 for 4
