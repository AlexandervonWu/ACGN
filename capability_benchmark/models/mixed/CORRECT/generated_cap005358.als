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

pred cap005358 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)) and ((no CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap005358c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((no CapBenchB or no CapBenchA) and some CapBenchA)) or (not (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and some capBenchS)))) }
assert CapBenchEquivalent_cap005358 { cap005358 iff cap005358c }
check CapBenchEquivalent_cap005358 for 4
