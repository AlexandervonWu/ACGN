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

pred cap001166 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
pred cap001166c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap001166 { cap001166 iff cap001166c }
check CapBenchEquivalent_cap001166 for 4
