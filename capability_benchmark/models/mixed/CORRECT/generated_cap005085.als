sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9 {
all t : Track | (no t.succs & Junction) implies no (t.signals & Semaphore)
}

pred inv9c {
	all t : Track | no t.succs & Junction implies no t.signals & Semaphore
}

check correct { inv9 <=> inv9c}
pred under { inv9 and !inv9c}
pred over { !inv9 and inv9c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005085 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv9 and ((some capBenchS or no CapBenchA) or some CapBenchB)) and ((no CapBenchA and some CapBenchA) and some capBenchR))) }
pred cap005085c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and some capBenchR)) or (not (inv9 and ((some capBenchS or no CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005085 { cap005085 iff cap005085c }
check CapBenchEquivalent_cap005085 for 4
