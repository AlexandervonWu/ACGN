sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some e:Entry,ex:Exit | e in Track and ex in Track
}

pred inv1c {
	some Entry
	some Exit
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005021 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some capBenchS or no CapBenchA) or some CapBenchA)) and ((no CapBenchA and some CapBenchA) and no CapBenchB))) }
pred cap005021c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchA and some CapBenchA) and no CapBenchB)) or (not (inv1 and ((some capBenchS or no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005021 { cap005021 iff cap005021c }
check CapBenchEquivalent_cap005021 for 4
