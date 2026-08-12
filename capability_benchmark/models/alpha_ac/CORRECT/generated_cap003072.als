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

pred cap003072 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchB) or some CapBenchB)) and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) }
pred cap003072c { all renamed: CapBenchA | (((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB) and renamed->renamed in capBenchR and (inv1 and ((some CapBenchA and some CapBenchB) or some CapBenchB))) }
assert CapBenchEquivalent_cap003072 { cap003072 iff cap003072c }
check CapBenchEquivalent_cap003072 for 4
