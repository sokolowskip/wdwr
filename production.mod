set MONTHS; # miesiace
set TYPES; # rodzaje oleju
set SCENARIOS;

param PRICES1 {TYPES, MONTHS};
param PRICES2 {TYPES, MONTHS};
param PRICES3 {TYPES, MONTHS};
param MAX_PRODUCTION {TYPES};
param PROB {SCENARIOS};
param risk_tolarance;

var oil {TYPES, MONTHS} >= 0; #rafinacja poszczegolnego rodzaju oleju w miesiacu
var b_oil {TYPES, MONTHS} >=0, <=1, integer; #pomocnicza zmienna binarna pozwalajaca na spelnienie warunku rafinacji conajmniej 20 ton
var pp_oil {TYPES, MONTHS} >=0; #produkcja polproduktu 

var income; #przychod
var store_cost; #koszt magazynowania

var ni;
var y{SCENARIOS}; # zysk przy odpowiednich realizacjach
var d_minus{SCENARIOS} >= 0;

subject to max_vtype_refining {k in MONTHS}: # w danym miesiacu mozna rafinowac maksymalnie 220 ton oleju roslinnego
	oil['R1',k] + oil['R2',k]<= 220;
	
subject to max_nvtype_refining {k in MONTHS}:  # w danym miesiacu mozna rafinowac maksymalnie 270 ton oleju nieroslinnego
	oil['O1',k] + oil['O2',k] + oil['O3',k] <= 270;

# nastepne 2 ograniczenia sa typu 20 * b_oil <= oil <= 270 * b_oil
# oznacza, to ze albo oleju jest uzyte ponad 20, albo wcale

subject to refining_in_month_lower {i in TYPES, k in MONTHS}: 
	20 * b_oil[i,k] <= oil[i,k];
subject to refining_in_month_upper {i in TYPES, k in MONTHS}: 
	oil[i,k] <= 220 * b_oil[i,k];

# Nastepne 2 ogranizenia zapewniaja wymagana twardosc oleju w kazdym z miesiecy.
# Podane nierownosci wynikaja juz  z lekkiego przeksztalcenia.
# I tak na przykladzie ograniczenia gornego: (twardosc < 6) losc kazdego uzytego polproduktu jest mnozona przez odpowiednia wage po lewej stronie,
# a po prawej suma wszystkich polproduktow przez 6. Po przeniesieniu wszystkich zmiennych na lewo nierownosc przyjmuje postac jak ponizej. 

subject to hardness_upper { k in MONTHS}: #ograniczenie na twardsc oleju
	2.4 * pp_oil['R1',k] + 0.2 * pp_oil['R2',k] - 3.5 * pp_oil['O1',k] - 1.6 * pp_oil['O2',k] -0.9 * pp_oil['O3',k] <= 0;
subject to hardness_lower { k in MONTHS}: #ograniczenie na twardsc oleju
	0 <= 5.4 * pp_oil['R1',k] + 3.2 * pp_oil['R2',k] - 0.5 * pp_oil['O1',k] + 1.4 * pp_oil['O2',k] + 2.1 * pp_oil['O3',k];
	
# W pierwszym miesiacu ilosc uzytego polproduktu musi byc mniejsza niz 200 + ilosc zakupionego oleju surowego
subject to store_M1 {i in TYPES}: 
	pp_oil[i, 'M1'] <= 200 + oil[i, 'M1'];

# W drugim miesiacu mozemy wytworzyc nastepujaca ilosc polproduktu: to co wyprodukowano przez 2 miesiace + 200 - to co zuzyto w pierwszym miesiacu.
subject to store_M2 {i in TYPES}:
	pp_oil[i, 'M2'] <= 200 + oil[i, 'M1'] + oil[i, 'M2'] - pp_oil[i,'M1'];

# analogicznie jak store_M2
subject to store_M3 {i in TYPES}:
	pp_oil[i, 'M3'] <= 200 + oil[i, 'M1'] + oil[i, 'M2'] + oil[i,'M3'] - pp_oil[i,'M1'] - pp_oil[i,'M2'];

#ograniczenie na maksymalna ilosc przechowywanego rodzaju oleju,
# wprowadzone tylko po 3 miesiacach, wczesniej nie da sie go przekroczyc z powodu ograniczen na zakupy (200 + 2 * 270 < 800)
subject to store_max {i in TYPES}:
	200 + oil[i, 'M1'] + oil[i, 'M2'] + oil[i,'M3'] - pp_oil[i,'M1'] - pp_oil[i,'M2'] <= 800;
	
# na koniec musimy miec dalej 200 ton zapasu, czyli mozemy zuuzyc maksymalnie tyle polproduktu ile zakupilismy oleju surowego
subject to store_end {i in TYPES}:
	sum { k in MONTHS} pp_oil[i,k] <= sum { k in MONTHS} oil[i,k];
	
subject to store_cost_subject:
	store_cost = sum { i in TYPES} (6000 + 30 * oil[i, 'M1'] + 20 * oil[i, 'M2'] + 10 * oil[i, 'M3'] - 30 * pp_oil[i, 'M1'] - 20 * pp_oil[i, 'M2'] - 10 * pp_oil[i, 'M3']);
	
subject to income_subject: # zyskiem wbedzie suma ilosci uzytych polproduktow pomonozona przez 170
	income = 170 * (sum{i in TYPES,k in MONTHS} pp_oil[i,k]);

subject to y_1:
	y['S1'] = income - store_cost - (sum {i in TYPES, k in MONTHS} PRICES1[i,k] * oil[i,k]);

subject to y_2:
	y['S2'] = income - store_cost - (sum {i in TYPES, k in MONTHS} PRICES2[i,k] * oil[i,k]);

subject to y_3:
	y['S3'] = income - store_cost - (sum {i in TYPES, k in MONTHS} PRICES3[i,k] * oil[i,k]);

subject to d_minus_subject {s in SCENARIOS}:
	d_minus[s] >= ni - y[s];
	
maximize RESULT:
	ni - (1/risk_tolarance) * (sum{s in SCENARIOS} PROB[s] * d_minus[s]);