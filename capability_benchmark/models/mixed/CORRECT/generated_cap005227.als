sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005227 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv7 and ((no CapBenchB or some capBenchR) and no CapBenchB)) and ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap005227c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchA and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv7 and ((no CapBenchB or some capBenchR) and no CapBenchB)))) }
assert CapBenchEquivalent_cap005227 { cap005227 iff cap005227c }
check CapBenchEquivalent_cap005227 for 4
