sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6 {
all e : Entry | some e.signals & Speed
}

pred inv6c {
	all t : Entry | some t.signals & Speed
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005136 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some CapBenchA and some CapBenchB) or no CapBenchA)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR))) }
pred cap005136c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or some capBenchR)) or (not (inv6 and ((some CapBenchA and some CapBenchB) or no CapBenchA)))) }
assert CapBenchEquivalent_cap005136 { cap005136 iff cap005136c }
check CapBenchEquivalent_cap005136 for 4
