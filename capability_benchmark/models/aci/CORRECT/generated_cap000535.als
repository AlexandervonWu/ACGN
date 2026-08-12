sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
trans in State -> some Event -> State
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000535 { (some ((CapBenchA + CapBenchB) + CapBenchA) and (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchA))) }
pred cap000535c { (some (CapBenchA + (CapBenchB + CapBenchA)) and (inv1 and ((no CapBenchB or some capBenchR) and some CapBenchA))) }
assert CapBenchEquivalent_cap000535 { cap000535 iff cap000535c }
check CapBenchEquivalent_cap000535 for 4
