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

pred cap002152 { ((inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA)) implies ((some capBenchS or some CapBenchA) or some capBenchS)) }
pred cap002152c { ((not (inv1 and ((some CapBenchA and no CapBenchB) or no CapBenchA))) or ((some capBenchS or some CapBenchA) or some capBenchS)) }
assert CapBenchEquivalent_cap002152 { cap002152 iff cap002152c }
check CapBenchEquivalent_cap002152 for 4
