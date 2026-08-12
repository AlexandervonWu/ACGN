sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s: State | some s.trans
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

pred cap000926 { ((inv1 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB) and ((some capBenchS or some CapBenchA) or some capBenchR)) }
pred cap000926c { (((some capBenchS or some CapBenchA) or some capBenchR) and (inv1 and ((no CapBenchA and some capBenchS) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) }
assert CapBenchEquivalent_cap000926 { cap000926 iff cap000926c }
check CapBenchEquivalent_cap000926 for 4
