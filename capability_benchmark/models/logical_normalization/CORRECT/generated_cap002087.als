sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e:Event | some s1,s2:State | s1->e->s2 in trans
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002087 { ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)) iff ((some capBenchR and some CapBenchA) or some capBenchR)) }
pred cap002087c { (((not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB))) or ((some capBenchR and some CapBenchA) or some capBenchR)) and ((not ((some capBenchR and some CapBenchA) or some capBenchR)) or (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchB)))) }
assert CapBenchEquivalent_cap002087 { cap002087 iff cap002087c }
check CapBenchEquivalent_cap002087 for 4
