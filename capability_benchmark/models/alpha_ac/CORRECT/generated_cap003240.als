sig Track {
	succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2 {
all x: Signal | one y : Track | x in y.signals
}

pred inv2c {
	all s : Signal | one signals.s
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap003240 { all x: CapBenchA | (x->x in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap003240c { all renamed: CapBenchA | (((some capBenchS or no CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)) and renamed->renamed in capBenchR and (inv2 and ((some CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB))) }
assert CapBenchEquivalent_cap003240 { cap003240 iff cap003240c }
check CapBenchEquivalent_cap003240 for 4
