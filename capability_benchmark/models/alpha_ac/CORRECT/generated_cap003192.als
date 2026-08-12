sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no (link.Trash)
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

pred cap003192 { all x: CapBenchA | (x->x in capBenchR and (inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchB)) and ((some capBenchS or some capBenchS) or some capBenchS)) }
pred cap003192c { all renamed: CapBenchA | (((some capBenchS or some capBenchS) or some capBenchS) and renamed->renamed in capBenchR and (inv7 and ((some CapBenchA and some CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap003192 { cap003192 iff cap003192c }
check CapBenchEquivalent_cap003192 for 4
