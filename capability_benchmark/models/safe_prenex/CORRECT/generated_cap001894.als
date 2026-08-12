sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv1 {
some t,a:Track| t in Entry and a in Exit
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

pred cap001894 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001894c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001894 { cap001894 iff cap001894c }
check CapBenchEquivalent_cap001894 for 4
