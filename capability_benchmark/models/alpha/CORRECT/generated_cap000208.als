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

pred cap000208 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv7 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
pred cap000208c { all alphaOuter: CapBenchA | some alphaInner: CapBenchA | (alphaOuter->alphaInner in capBenchR and (inv7 and ((some CapBenchA and no CapBenchA) or no CapBenchB))) }
assert CapBenchEquivalent_cap000208 { cap000208 iff cap000208c }
check CapBenchEquivalent_cap000208 for 4
