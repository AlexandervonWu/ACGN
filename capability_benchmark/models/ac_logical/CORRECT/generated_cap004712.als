sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s : State | some s.trans
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

pred cap004712 { not ((inv1 and ((some capBenchR and no CapBenchA) or no CapBenchB)) and ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004712c { ((not ((some CapBenchB or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv1 and ((some capBenchR and no CapBenchA) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004712 { cap004712 iff cap004712c }
check CapBenchEquivalent_cap004712 for 4
