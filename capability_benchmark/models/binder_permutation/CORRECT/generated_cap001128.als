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

pred cap001128 { all x, y: CapBenchA | (x->y in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
pred cap001128c { all a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some CapBenchA and some CapBenchA) or no CapBenchA))) }
assert CapBenchEquivalent_cap001128 { cap001128 iff cap001128c }
check CapBenchEquivalent_cap001128 for 4
