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

pred cap004787 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)) and ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) }
pred cap004787c { ((not ((some capBenchR and some CapBenchB) or CapBenchA in CapBenchA + CapBenchB)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and some capBenchR)))) }
assert CapBenchEquivalent_cap004787 { cap004787 iff cap004787c }
check CapBenchEquivalent_cap004787 for 4
