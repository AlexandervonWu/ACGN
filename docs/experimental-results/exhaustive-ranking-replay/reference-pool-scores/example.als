sig Person  {
	Tutors : set Person,
	Teaches : set Class
}
sig Group {}

sig Class  {
	Groups : Person -> Group
}

sig Teacher in Person  {}

sig Student in Person  {}

           
                                
 

            
                                
 

                               
                             
                            
         
          


pred acgnPoolRef192xinv6c {
  all t:Teacher | some t.Teaches
}
pred acgnPoolRef193xinv6 {
all t : Teacher | (#t.Teaches)>0
}

check correct { acgnPoolRef192xinv6c iff acgnPoolRef193xinv6 }
