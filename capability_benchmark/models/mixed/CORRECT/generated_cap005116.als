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

pred cap005116 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)) and ((some CapBenchB or some capBenchR) or some capBenchR))) }
pred cap005116c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or some capBenchR) or some capBenchR)) or (not (inv6 and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or some CapBenchB)))) }
assert CapBenchEquivalent_cap005116 { cap005116 iff cap005116c }
check CapBenchEquivalent_cap005116 for 4
