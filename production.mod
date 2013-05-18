set MONTHS; # miesiace
set R; # oleje roslinne
set O; # oleje nieroslinne

param R_PRICES1 {R, MONTHS};
param O_PRICES1 {O, MONTHS};

var r {R, MONTHS} >= 0; #rafinacja poszczegolnego rodzaju oleju roslinnego w miesiacu
var o {O, MONTHS} >= 0; #rafinacja poszczegolnego rodzaju oleju nieroslinnego w miesiacu

var br {R, MONTHS} >=0, <=1, integer; #pomocnicza zmienna binarna pozwalajaca na spelnienie warunku rafinacji conajmniej 20 ton
var bo {O, MONTHS} >=0, <=1, integer; #pomocnicza zmienna binarna pozwalajaca na spelnienie warunku rafinacji conajmniej 20 ton

var pr {R} >= 0; #proporcja uzycia oleju roslinnego poszczegolnych rodzajow
var po {O} >= 0; #proporcja uzycia oleju nieroslinnego poszczegolnych rodzajow

var p {MONTHS} >= 0; #produkcja w poszczegolnach miesiacach

subject to max_vtype_refining {k in MONTHS}: # w danym miesiacu mozna rafinowac maksymalnie 220 ton oleju roslinnego
	0 <= sum {i in R} r[i,k] <= 220;
	
subject to max_nvtype_refining {k in MONTHS}:  # w danym miesiacu mozna rafinowac maksymalnie 270 ton oleju nieroslinnego
	0 <= sum {j in O} o[j,k] <= 270;
	
subject to vrefining_in_month1 {i in R, k in MONTHS}: #jezeli olej roslinny jest wykorzystany w danym miesiacu to co najmniej w ilosci 20
	20 * br[i,k] <= r[i,k];

subject to vrefining_in_month2 {i in R, k in MONTHS}: #a maksymalnie 220
	r[i,k] <= 220 * br[i,k];
	
subject to nvrefining_in_month1 {j in O, k in MONTHS}: #jezeli olej nieroslinny jest wykorzystany w danym miesiacu to co najmniej w ilosci 20
	20 * bo[j,k] <= o[j,k];

subject to nvrefining_in_month2 {j in O, k in MONTHS}: #a maksymalnie 270
	o[j,k] <= 270 * bo[j,k];
	
subject to sum_of_proportion_must_equal_1: #sum wszystkich proporcji musi sie rownac 1
	(sum {i in R} pr[i]) + (sum {j in O} po[j]) = 1;

subject to hardness: #ograniczenie na twardsc oleju
	3 <= 8.4 * pr['R1'] + 6.2 * pr['R2'] + 2.5 * po['O1'] + 4.4 * po['O2'] + 5.1 * po['O3'] <= 6;
	
subject to vproduction {i in R, k in MONTHS}: # nie mozna wyprodukowac wiecej produktu niz jest dostepnego oleju roslinnego
	pr[i] * p[k] <= r[i,k];
	
subject to nvproduction {j in O, k in MONTHS}: # nie mozna wyprodukowac wiecej produktu niz jest dostepnego oleju nieroslinnego
	po[j] * p[k] <= o[j,k];
	
maximize RESULT:
	(sum {k in MONTHS} p[k]) * 170 - (
	   (sum {i in R, k in MONTHS} R_PRICES1[i,k] * r[i,k]) + 
	   (sum {j in O, k in MONTHS} O_PRICES1[j,k] * o[j,k]));