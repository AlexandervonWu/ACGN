sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000281 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv3 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap000281c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv3 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap000281 { cap000281 iff cap000281c }
check CapBenchEquivalent_cap000281 for 4
