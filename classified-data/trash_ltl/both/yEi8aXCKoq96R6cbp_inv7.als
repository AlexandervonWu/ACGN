var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv7 {
eventually File in Protected
}

pred inv7c {
	eventually some Protected
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 


