var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv8 {
always (all f:File| some f.*link implies eventually  f.*link  in Trash)
}

pred inv8c {
	always (all f:link.File | eventually f in Trash)
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 


