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

pred cap003437 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and some capBenchR) and some CapBenchB)) }
pred cap003437c { all renamed: CapBenchA | (((no CapBenchA and some capBenchR) and some CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((some capBenchS or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap003437 { cap003437 iff cap003437c }
check CapBenchEquivalent_cap003437 for 4
