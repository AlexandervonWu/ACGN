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

pred cap002371 { no x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap002371c { all x: CapBenchA | not (x->x in capBenchR and (inv3 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap002371 { cap002371 iff cap002371c }
check CapBenchEquivalent_cap002371 for 4
