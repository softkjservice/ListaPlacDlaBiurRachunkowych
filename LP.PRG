*******************************************************************************
* Modul glownuy programu sh.exe
*******************************************************************************
local lcolor, ek
kolor=1
set date to german
set delete on
set century on
public zdlugie_konto:=.f.
public w,has_sel:=17
public zwar_30:=.f.,zstopa:=0
public zmiesiac:=month(date()),zdata_wyplaty:=date(),znum_listy:=space(15)
public zmies_nazwa:=mies_nazwa(zmiesiac)
public vmenu_end:=.f.,sh_upraw:=0
public zw_lp:=.f.,zi_lp:=1  &&zw_lp=.t. program na wiele firm, zi_lp=ilosc firm
dset_public()           &&definiowanie zmiennych z plikow "ml_setup.dbf" i "ms_setup.dbf"
public_lset()     &&zmienne - parametry : progi podatkowe, stopy procentowe itp
public_prac()     &&zmienne pracownika
public_v_prac()   &&pomocnicza
public_fir()      &&zmienne firmy (dla wersji wielofirmowej)
public_us()       &&zmienne urzedow (us,zus,kasa)
public_druk()

druk_public()
wspolprac_public()
zwlas_public()
zleg_public()
zadmin_public()
zprzel_public()
zrmua_public()
zhas_public()
p11_inne_public()
public zkod_num,ztyt_num
public zkoncz5:=.f.,zkoncz24:=.f.
public zkey10:=.f.    &&w polaczeniu z [Ctrl-Enter] konczy instrukcje get
private zlista_plik:=.f.,zkarta_plik:=.f.,zkasa_plik:=.f.,zbilmies_plik:=.f.
private zskladki_plik:=.f.,zprzel_plik:=.f.
set key 10 to koncz()
zk_5=2
zk_24=19
vplac_plik=.f.
kplac_plik=.f.
set default to      
select 0
setcolor("n/n+")

clear
select 0
lp_tlo()
kj_okno(0,0,10, "  L I S T A   P ù A C                                                           ",2)
kj_okno(18,0,5, "         A K T U A L N E      P A R A M E T R Y      P R O G R A M U            ",2)
lcolor=setcolor()
do skom with "Wpisz hasào i zatwierd´ klawiszem [Enter]"
set color to
if zla_instal("LP")
  kj_tkom(12," Uwaga! "," Wykryto bl©dy instalacyjne!","Program nie moæe pracowaÜ poprawnie.","Naciònij dowolny klawisz.",5)
  clear
  return
endif

set default to leg01
if kj_use("leg01",.f.,3)
  if empty(ldat)
				if reclock(5)      
	              replace ldat with date()
                  unlock
	            endif			      
  endif
  zleg_lad()
  use
else
  set color to
  clear
  return    
endif	  
save screen to ek
demo_legalizuj("SH")
restore screen from ek

if demo_end("SH")
  kj_tkom(3," Uwaga!  Korzystaliòcie Pa‰stwo z wersji   D E M O "," Dalsza praca z programem b©dzie moæliwa po wykupieniu LICENCJI","Producent: Soft_KJ_Service  Tel: 0 604 219 784 ","Naciònij dowolny klawisz.",5)
  clear
  return
endif
*
set default to leg01
if kj_use("leg01",.f.,3)
  zleg_lad()
  use
else
  set color to
  clear
  return    
endif	  
*
if file("drukarki.dbf")
  if kj_use("drukarki",.f.,3)
    locate for dr="*"
	if.not.found()
	  go top
	endif
    druk_lad()	
    use
  endif
endif

if file("lpset.dbf")
  if kj_use("lpset",.t.,3)    &&blokada rownoczesnosci obslugi aplikacji
    lpset_lad()	
  else
    clear
	kj_tkom(9," Uwaga! ","Program obsluguje tylko jednego Uzytkownika."," Aby umozliwic rownoczesna prace,"," nalezy dokupic licencje na kolejne stanowisko.",5) 
    clear
	return
  endif
endif


set default to lpset
if zhaslo
  do skom with "Wpisz haslo i zatwierdz klawiszem [Enter]"
  set color to
  select 0
  if.not.kj_haslo(0,46,0)
    clear
    return
  endif
  close
endif
set color to "n/w,w/n"


if file("lset.dbf")
  select 0
  if kj_use("lset",.t.,3)
    zw_lp=w_lp
    zi_lp=i_lp
	use
  endif	
endif
if file("plik_dru.dbf")
  select 0
  if kj_use("plik_dru",.f.,3)
    plik_dru_lad()
	use
  endif	
endif

if file("administ.dbf")
  select 0
  if kj_use("administ",.f.,3)
    administ_lad()
	use
  endif	
endif

if zw_lp
  wybor_fir()
else
  if kj_use("lpfirma",.f.,3)
    fir_lad()
	use
	zfnum=1
  endif	
  zfnaz1=zlic1  
  zfnaz2=zlic2
  zfkod=zlic3
  zfmiasto=zlic4
  zfulica=zlic5
  zfnip=zlic6
  zfregon=zlic_regon
  zfpesel=zlic_pesel
  zfkonto=zlic_konto
endif


set default to &zlurzad_server
if kj_use("progi",.t.,3)
  lset_lad()  
  use
else
  set color to
  clear
  return  
endif

prac_default()
lp_paramsay()
lp_gmenu()
set color to
clear
RETURN


FUNCTION PRAC_DEFAULT()
local ldefault:="lp000"
set default to
do case
  case zfnum<10
    ldefault=stuff(ldefault,5,1,str(zfnum,1))
  case zfnum>=10.and.zfnum<100
    ldefault=stuff(ldefault,4,2,str(zfnum,2))	
  case zfnum>=100
    ldefault=stuff(ldefault,3,3,str(zfnum,3))		
endcase
set default to &ldefault
RETURN


************ PUBLIC
FUNCTION PUBLIC_PRAC
public zpnazwisko:=space(20),zpimie1:=space(12),zpimie2:=space(12)
public zpdata_ur:=ctod("  .  .  "),zpmiejsc_ur:=space(30)
public zpimie_ojca:=space(12),zpimie_matk:=space(12),zppesel:=space(11)
public zpnip:=space(13),zpmiejscow:=space(20),zpulica:=space(20)
public zpdom_nr:=space(10),zplokal_nr:=space(10),zpkod:=space(6)
public zppoczta:=space(20),zpgmina:=space(20),zpwojew:=space(20)
public zpzasadn:=0,zpdodatek:=0,zppremia:=0,zpza_chor:=0,zpkoszty:=0,zpkw_wolna:=0
public zpgrupa:=space(5),zpmagazyn:=0,zpuwagi:=space(30),zpnumer:=0
public zpsk_zycie:=0,zpsk_inne:=0,zpzasilek:=0,zpzas_inne:=0
public zplog_e:=.t.,zplog_r:=.t.,zplog_c:=.t.,zplog_z:=.t.
public zpstart:=date(),zpend:=ctod(space(8)),zpetat:=1,zpkonto:=space(60)
public zpkas_kod:=space(3),zpus_kod:=space(3),zpzus_kod:=space(3)
RETURN nil

FUNCTION PUBLIC_V_PRAC()
public vpnazwisko:=space(20),vpimie1:=space(12),vpimie2:=space(12)
public vpdata_ur:=ctod("  .  .  "),vpmiejsc_ur:=space(30)
public vpimie_ojca:=space(12),vpimie_matk:=space(12),vppesel:=space(11)
public vpnip:=space(13),vpmiejscow:=space(20),vpulica:=space(20)
public vpdom_nr:=space(10),vplokal_nr:=space(10),vpkod:=space(6)
public vppoczta:=space(20),vpgmina:=space(20),vpwojew:=space(20)
public vpzasadn:=0,vpdodatek:=0,vppremia:=0,vpza_chor:=0,vpkoszty:=0,vpkw_wolna:=0
public vpgrupa:=space(5),vpmagazyn:=0,vpuwagi:=space(30),vpnumer:=0
public vpsk_zycie:=0,vpsk_inne:=0,vpzasilek:=0,vpzas_inne:=0
public vplog_e:=.t.,vplog_r:=.t.,vplog_c:=.t.,vplog_z:=.t.
public vpstart:=date(),vpend:=ctod(space(8)),vpetat:=1,vpkonto:=space(60)
public vpkas_kod:=space(3),vpus_kod:=space(3),vpzus_kod:=space(3)
RETURN nil

FUNCTION PUBLIC_US()
public zkod:=space(3),znazwa:=space(30),zmiasto:=space(30),zulica:=space(30)
public znumer:=space(10),zkod_poczt:=space(6),zkonto1:=space(60)
public zkonto2:=space(30),zkonto3:=space(30)
RETURN nil

FUNCTION PUBLIC_FIR()
public zfnum:=1,zfnaz1:=space(30),zfnaz2:=space(30),zfkod:=space(6)
public zfmiasto:=space(30),zfulica:=space(30),zfnip:=space(13),zfregon:=space(10)
public zfkonto:=space(90),zskarbowy:=space(30),zsk_kod:=space(6),zfpesel:=space(11)
public zsk_miasto:=space(30),zsk_ulica:=space(30),zsk_konto:=space(90)
public zzus:=space(30),zzus_kod:=space(6),zzus_miasto:=space(30)
public zzus_ulica:=space(30),zzus_k1:=space(90),zzus_k2:=space(90)
public zzus_k3:=space(90),zzus_k4:=space(90)
public zwspol_ile:=0,zprzelew:="",zpieczec:="",znaz_czlon:="",ztyp_ident:=""
public ztermin:=""
public zfkraj:=space(15),zfwojewodztwo:=space(15),zfpowiat:=space(15)
public zfgmina:=space(15),zfpoczta:=space(15)
public zp11_imienaz:=space(30),zp11_rodzaj:=space(1),zp11_pit_r:=space(1)
public zp11_koszty:=space(1),zp11_ojciecmat:=space(30)
RETURN

FUNCTION WSPOLPRAC_PUBLIC()
public zw1_naz:=space(31),zw1_imie:=space(22)
public zw1_typ:=space(1),zw1_iden:=space(11)
public zw1_kodnum:=1,zw1_spol:=.t.
public zw2_naz:=space(31),zw2_imie:=space(22)
public zw2_typ:=space(1),zw2_iden:=space(11)
public zw2_kodnum:=1,zw2_spol:=.t.
RETURN nil

FUNCTION ZLEG_PUBLIC()
public zlic1:=space(50),zlic2:=space(50),zlic3:=space(6)
public zlic4:=space(50),zlic5:=space(50),zlic6:=space(13)
public zlic0:=space(15)
public zleg_kod:=space(5),zlz1:=.f.,zlz2:=.f.,zlz3:=.f.,zl123:=.f.
public zlkod:=0,zldat:=date(),zld:=14
public zlic_regon:=space(10),zlic_pesel:=space(11),zlic_konto:=space(60)
public zlic_tel:=space(15),zlic_fax:=space(15)
RETURN nil

FUNCTION ZADMIN_PUBLIC()
public zserwer:=space(8), zlurzad_serwer:="urzedy", zsurzad_serwer:="urzedy"
public zsiec:=.f.,zurzad_tryb:=0,zurzad_siec:=.f.
RETURN


*******************
FUNCTION LPSET_LAD()
local lsiec
public zp_serwer:="",zp_siec:=.f.,zsiec:=.f.,zhaslo:=.f.
public zprzelewy:=.f.,zrmua:=.f.,zrna:=.f.,zrca:=.f.,zdra:=.f.,zpit_11:=.f.
public zw_lp:=.f.,zi_lp:=1
do while.not.eof()
  do case
    case alltrim(co)=="P_SERWER"
	  zp_serwer=alltrim(jak)	  
    case alltrim(co)=="SIEC"
	  if alltrim(jak)="1"
	    zsiec=.t.
	  endif
    case alltrim(co)=="HASLO_L"
	  if alltrim(jak)="1"
	    zhaslo=.t.
	  endif	   	  
    case alltrim(co)=="PRZELEWY"
	  if alltrim(jak)="1"
	    zprzelewy=.t.
	  endif	   	  	  
    case alltrim(co)=="RMUA"
	  if alltrim(jak)="2"
	    zrmua=.t.
	  endif	 
    case alltrim(co)=="RNA"
	  if alltrim(jak)="2"
	    zrna=.t.
	  endif	
    case alltrim(co)=="RCA"
	  if alltrim(jak)="2"
	    zrca=.t.
	  endif	
    case alltrim(co)=="DRA"
	  if alltrim(jak)="2"
	    zdra=.t.
	  endif	   	  
    case alltrim(co)=="W_LP"
      lsiec=alltrim(jak)	  
	  if alltrim(jak)="1"
	    zw_lp=.t.
	  endif	  	  	  	  	     	  	  	     	  	  	    	  	  	  
    case alltrim(co)=="I_LP"
	  zi_lp=val(alltrim(jak))
    case alltrim(co)=="PIT_11"
	  if alltrim(jak)="1"
	    zpit_11=.t.
	  endif	  	  	  	  	     	  	  	     	  	  	    	  	  	  	  
    case alltrim(co)=="DLUGIE_KONTO"
	  if alltrim(jak)="1"
	    zdlugie_konto=.t.
	  endif	  	  	  	  	     	  	  	     	  	  	    	  	  	  	  	  
  endcase
  skip
enddo
RETURN nil

FUNCTION PLIK_DRU_LAD()
zlista_plik=lista_plik
zkarta_plik=karta_plik
zkasa_plik=kasa_plik
zbilmies_plik=bilmies_pl
zskladki_plik=skladki_pl
RETURN nil

FUNCTION ADMINIST_LAD()
local lsukces:=.f.
if kj_use("administ",.f.,3)
  do while.not.eof()
    do case
	  case serwer="URZEDY"
	    zlurzad_serwer=l_serwer
		zsurzad_serwer=s_serwer
		zurzad_siec=siec
		zurzad_tryb=tryb  
	endcase
    skip
  enddo
  lsukces=.t.
endif
RETURN lsukces

FUNCTION FIR_LAD()
zfnum=fnum
zfnaz1=fnaz1  
zfnaz2=fnaz2
zfkod=fkod
zfmiasto=fmiasto
zfulica=fulica
zfnip=fnip
zfregon=fregon
zfpesel=fpesel
zfkonto=fkonto
zskarbowy=skarbowy
zsk_kod=sk_kod
zsk_miasto=sk_miasto
zsk_ulica=sk_ulica
zsk_konto=sk_konto
zzus=zus
zzus_kod=zus_kod
zzus_miasto=zus_miasto
zzus_ulica=zus_ulica
zzus_k1=zus_konto1
zzus_k2=zus_konto2
zzus_k3=zus_konto3
zzus_k4=zus_konto4
zwspol_ile=val(substr(zskarbowy,1,1))
zprzelew=substr(zskarbowy,2,1)
zpieczec=substr(zskarbowy,3,1)
znaz_czlon=substr(zskarbowy,4,1)
ztyp_ident=substr(zskarbowy,5,1)
ztermin=substr(zskarbowy,6,1)
zrmnazwisko=sk_miasto
zrmimie=sk_ulica
zrmnazwa=zus
zrmdata_ur=ctod(substr(zus_miasto,1,10))
zw1_naz=substr(zzus_k1,1,31)
zw1_imie=substr(zzus_k1,32,22)
zw1_typ=substr(zzus_k1,54,1)
zw1_iden=substr(zzus_k1,55,11)
zw1_kodnum=val(substr(zzus_k1,67,2))
zw2_naz=substr(zzus_k2,1,31)
zw2_imie=substr(zzus_k2,32,22)
zw2_typ=substr(zzus_k2,54,1)
zw2_iden=substr(zzus_k2,55,11)
zw2_kodnum=val(substr(zzus_k2,67,2))
zwl_kodnum=val(substr(zsk_kod,1,2))
if substr(zzus_k1,70,1)=="T"
  zw1_spol=.T.
else
  zw1_spol=.F.
endif
if substr(zzus_k2,70,1)=="T"
  zw2_spol=.T.
else
  zw2_spol=.F.
endif
if substr(zsk_kod,4,1)=="T"
  zwl_spol=.T.
else
  zwl_spol=.F.
endif
zfkraj=substr(zzus_k3,1,15)
zfwojewodztwo=substr(zzus_k3,16,15)
zfpowiat=substr(zzus_k3,31,15)
zfgmina=substr(zzus_k3,46,15)
zfpoczta=substr(zzus_k3,61,15)
zp11_ojciecmat=substr(zzus_k4,1,30)
zp11_imienaz=zzus_ulica
zp11_rodzaj=substr(zzus_kod,1,1)
zp11_pit_r=substr(zzus_kod,2,1)
zp11_koszty=substr(zzus_kod,3,1)
RETURN

FUNCTION LSET_LAD()
zlkw_wolna=lkw_wolna
zlprog2=lprog2
zlprog3=lprog3
zlstopa1=lstopa1
zlstopa2=lstopa2
zlstopa3=lstopa3
zlodlicz1=lodlicz1
zlodlicz2=lodlicz2
zlodlicz3=lodlicz3
zlsr_placa=lsr_placa
zlsk_emeryt=lsk_emeryt
zlsk_rentp:=lsk_rentp
zlsk_rentu:=lsk_rentu
zlsk_chorob=lsk_chorob
zlsk_zdrow=lsk_zdrow
zlskzdrow_pod=lskzdrow_pod
zlsk_wypad=lsk_wypad
zlpod_zdrow=lpodstaw2
zlpodstawp=lpodstawp
zlpodstaw1=lpodstaw1
*zlpodstaw2=lpodstaw2
zlpodstaw3=lpodstaw3
zlsk_fundus=lsk_fundus
zlsk_fgsp=lsk_fgsp
RETURN nil


*******************************************************************************
*LP_MENU                                                                      *
*******************************************************************************
************************************************************************
* Menu glowne programu SH                                                     *
*******************************************************************************
FUNCTION LP_GMENU() 
local ek,ek1,ek2,ek3,ek4,ltnaz,ltkod,ltil,lfound:=.f.,lcolor,lzak_menu:=0
local lbelka:="∞ Lista plac ∞ Miesiac ∞ Wydruki ∞  Inne  ∞  Koniec ∞"
local lliter:="  L            M         W          I        K       "
local lpoz:=1,topis[20], i:=0,select,lopcje:=.f.,top[6],lit[6],lop[6]
local l_inne:=1,l_druk:=1,l_druk1:=1,lparam:=1,lkatal:=1,lop_num:=1
local lzak1:=1, lzak2:=1,luse:=.t.,ldsiec:=.f.,llista:=1,lrmua_co:=1
local lmiesiac:=zmiesiac,lmies_nazwa:=zmies_nazwa
topis[1]:="Tworzenie i podglad listy plac"
topis[2]:="Wybor miesiaca lub tworzenie nowego w oparciu o bezposrednio go poprzedzajacy"
topis[3]:="Wydruk:listy plac,kart pracowniczych,bilansu miesiaca i raportu dla kas chorych"
topis[4]:="Funkcje parametryzyjace i pomocnicze"
topis[5]:="Zamkniecie programu i powrot do systemu operacyjnego"
topis[6]:="Zamkniecie programu i powrot do systemu operacyjnego"
top[1]:="   | Przelewy ZUS "
top[2]:="   | R M U A  ZUS "
top[3]:="   | R  N  A  ZUS "
top[4]:="   | R  C  A  ZUS "
top[5]:="   | D  R  A  ZUS "
top[6]:="   | PIT-11       "
lit[1]:="     P            "
lit[2]:="     R            "
lit[3]:="        N         "
lit[4]:="        C         "
lit[5]:="     D            "
lit[6]:="         1        "
lop[1]:="Wydruk przelewow w formacie ZUZ na konta 51, 52 i 53"
lop[2]:="Wydruk raportu miesiecznego dla osoby ubezpieczonej w formacie ZUS RMUA" 
lop[3]:="Wydruk raportu imiennego ZUS RNA" 
lop[4]:="Wydruk raportu imiennego ZUS RCA" 
lop[5]:="Wydruk deklaracji rozliczeniowej  ZUS  DRA"
lop[6]:="Wydruk PIT-11 zbiorowy i indywidualny"
if.not.zdra
  top[1]:="   | Przelewy ZUS "
  top[2]:="   | PIT-11       "
  lit[1]:="     P            "
  lit[2]:="      1           "
  lop[1]:="Wydruk przelewow w formacie ZUZ na konta 51, 52 i 53"
  lop[2]:="Wydruk PIT-11 zbiorowy i indywidualny"
endif
if zw_lp
  lbelka:="∞ Lista plac ∞ Miesiac ∞ Wydruki ∞  Inne  ∞  Firma  ∞ Koniec ∞"
  lliter:="  L            M         W          I        F        K       "
  topis[5]:="Definiowanie i wybor obslugiwanych firm"
endif
do while .t.    
  if lpoz=100
    lpoz=1
  endif
  lp_paramsay()
  if.not.zw_lp
    lpoz=menu_poziom(1,0,5,lbelka,lliter,topis,lpoz,.f.,.f.)   &&Menu glowne
  else
    lpoz=menu_poziom(1,0,6,lbelka,lliter,topis,lpoz,.f.,.f.)   &&Menu glowne
  endif	
  save screen to ek
  if lastkey()=27
    if kj_gkom(4,"","Zakonczyc prace programu ?","",.t.,5).or.lastkey()=27
	  exit
	else
	  lpoz=100
	endif  
  endif
  do case
	case lpoz=1                   &&Sprzedaz
      pracownik("",.f.,"",1,.f.,1) 


	case lpoz=2                   &&Wybor miesiaca
      g_tlo()      
	  do miesiac with 4,30,lmiesiac,lmies_nazwa	  
*	  if lmiesiac=1.or.lp_new(lmiesiac)
*	    zmiesiac=lmiesiac
*	    zmies_nazwa=mies_nazwa(lmiesiac)
 *     endif
     lp_new(lmiesiac)
	 if lastkey()#27
	    zmiesiac=lmiesiac
	    zmies_nazwa=mies_nazwa(lmiesiac)	 
	 endif
    case lpoz=3                &&Baza pracownikow
      g1_tlo()
      save screen to ek1
	  lopcje=.f.
	  if zprzelewy
	    lopcje=.t.
		top[1]=stuff(top[1],2,1,"*")
	  endif
	  if zrmua
	    lopcje=.t.
		top[2]=stuff(top[2],2,1,"*")
	  endif	  
	  if zrna
	    lopcje=.t.
		top[3]=stuff(top[3],2,1,"*")
	  endif	  	  
	  if zrca
	    lopcje=.t.
		top[4]=stuff(top[4],2,1,"*")
	  endif	  	  	  
	  if zdra
	    lopcje=.t.
		top[5]=stuff(top[5],2,1,"*")
	  endif	  	  	  	  
	  if zpit_11.and..not.zdra
	    lopcje=.t.
		top[2]=stuff(top[6],2,1,"*")
	  endif
	  if zpit_11.and.zdra
	    lopcje=.t.
		top[6]=stuff(top[6],2,1,"*")
	  endif	  	  	  	  	  	  
	  do while.t.
	    restore screen from ek1
*		if lopcje
		  l_druk=ldruk1_menu(l_druk)
*		else
*		  l_druk=ldruk_menu(l_druk)
*		endif  
	    do case
	      case lastkey()=27
		    restore screen from ek1
			exit
		  case l_druk=1
            do while.t.
			  llista=lista_menu(llista)
			  if lastkey()=27
			    exit
			  endif
			  do case
			    case llista=1
			      lp_drukuj()		
			    case llista=2
			      lpi_drukuj()						
			  endcase
			enddo
		  case l_druk=2
            all_karta_druk()
		  case l_druk=3
            bil_mies()
		  case l_druk=4
            kas_raport()		  		  
		  case l_druk=5
	        skladki_mies(1)  
          case l_druk=6
            save screen to ek3
			do while.t.    
		      if.not.zdra
			    lop_num=men_pion(8,40,2,"",top,lit,lop,lop_num)
			  else
			    lop_num=men_pion(8,40,6,"",top,lit,lop,lop_num)
			  endif	
              if lastkey()=27
			    restore screen from ek3
				exit
			  endif
			  do case
		        case lop_num=1.and.substr(top[1],2,1)="*"
			      przel_zus()
				case lop_num=2.and.substr(top[2],2,1)="*".and..not.zdra
                  pit_11(0)	
		        case lop_num=2.and.substr(top[2],2,1)="*".and.zdra
			       save screen to ek4
				   lrmua_co=rmua_co_menu(lrmua_co)
                   if.not.lastkey()=27
				     do case
				       case lrmua_co=1
					     rmua_zus(0)
				       case lrmua_co=2
					     rmua_zest(0)					   
				     endcase
					 restore screen from ek3
   			       else
				     restore screen from ek4
				   endif				   
		        case lop_num=3.and.substr(top[3],2,1)="*"
			       rna_zus(0)				   
		        case lop_num=4.and.substr(top[4],2,1)="*"
			       rca_zus(0)				   				   
		        case lop_num=5.and.substr(top[5],2,1)="*"
			       dra_zus(0)				   				   				   
		        case lop_num=6.and.substr(top[6],2,1)="*"
			       pit_11(0)				   				   				   				   

		        case lop_num=1.and..not.substr(top[1],2,1)="*"
		          kj_tkom(17," Uwaga !","Wydruk dostepny w rozszerzonej wersji programu.","Wiecej informacji","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)
				case lop_num=2.and..not.substr(top[2],2,1)="*"
		          kj_tkom(17," Uwaga !","Wydruk dostepny w rozszerzonej wersji programu.","Wiecej informacji","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)
		        case lop_num=3.and..not.substr(top[3],2,1)="*"
		          kj_tkom(17," Uwaga !","Wydruk dostepny w rozszerzonej wersji programu.","Wiecej informacji","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)
		        case lop_num=4.and..not.substr(top[4],2,1)="*"
		          kj_tkom(17," Uwaga !","Wydruk dostepny w rozszerzonej wersji programu.","Wiecej informacji","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)
		        case lop_num=5.and..not.substr(top[5],2,1)="*"
		          kj_tkom(17," Uwaga !","Wydruk dostepny w rozszerzonej wersji programu.","Wiecej informacji","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)
		        case lop_num=6.and..not.substr(top[6],2,1)="*"
		          kj_tkom(17," Uwaga !","Wydruk dostepny w rozszerzonej wersji programu.","Wiecej informacji","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)				  
		      endcase  
	        enddo
	    endcase
	  enddo	
*     pracownik("",.f.,"",1,.f.,1) 
    case lpoz=4                &&Inne
	  g1_tlo()
	  do while.t.
	    l_inne=inne_menu(l_inne)
	    if lastkey()=27
		  exit
		endif		
		do case
		  case l_inne=1
		    save screen to ek1
            do while.t.
			  lparam=param_menu(lparam)
			  if lastkey()=27
			    exit
			  endif
			  do case
			    case lparam=1
			      oblicz_par()
			    case lparam=2
			      uzyt_par()
			    case lparam=3
				  save screen to ek2
			      do while .t.
				    lkatal=katal_menu(lkatal)
                    if lastkey()=27
                      exit
                    endif
                    do case
                      case lkatal=1
                        us_baza(1,.t.)
                      case lkatal=2
                        us_baza(2,.t.)
                      case lkatal=3
                        us_baza(3,.t.)					  					  
                    endcase
                  enddo
				  restore screen from ek2
			    case lparam=4
                  druk_wybor(9,43)
				  prac_default()
			  endcase	
			enddo
			restore screen from ek1
		  case l_inne=2
		    if zhaslo
			  set default to lpset
			  has_new(6,20,12)
			else
			  kj_tkom(12," Uwaga! ","Haslo dostepne w rozszerzonej wersji programu.","Wiecej informacji ","pod numerem :  (022) 784 59 19   lub   0 604 219 784",5)
			endif  
		  case l_inne=3
		    p_index()
		  case l_inne=4
           do nowyrok
		  case l_inne=5
		    if file("help\lp_help.txt")
			  lnaz:="help\lp_help.txt"
			  MEMOWRIT(lnaz,MEMOEDIT(MEMOREAD(lnaz)))		   
			  restore screen from ek
            else
			  kj_tkom(12," Uwaga!","Pliki z opisem nie zostaly odnalezione.","Uzupelnij instalacje programu i ponow probe.","Nacisnij dowolny klawisz.",5)
			endif 
		endcase
	  enddo
    case lpoz=5.and.zw_lp
	  wybor_fir()
    case ((lpoz=5.or.lpoz=0).and..not.zw_lp).or.lpoz=6
	  close all
      set color to
	  clear
	  return
  endcase

  restore screen from ek
*  sh_paramsay()
enddo
RETURN nil




*******************************************************************************
* Tworzy menu uaktywniajace funkcje techniczne programu                       *
*******************************************************************************
FUNCTION INNE_MENU(ppoz)
local ltnaz[5],ltlit[5],ltopis[5],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Parametry    "
ltnaz[2]:=" Zmiana hasla "
ltnaz[3]:=" Indeksacja   "
ltnaz[4]:=" Nowy rok     "
ltnaz[5]:=" Opis programu"
*ltnaz[3]:=" Firma        "
ltlit[1]:=" P            "
ltlit[2]:=" Z            "
ltlit[3]:=" I            "
ltlit[4]:=" N            "
ltlit[5]:=" O            "
*ltlit[3]:=" F            "
ltopis[1]:="Zmiana parametrow przyjetych do obliczen"
ltopis[2]:="Zmiana obowiazujacego hasla"
ltopis[3]:="Uporzadkowanie baz danych - odtworzenie uszkodzonych plikow indeksowych"
ltopis[4]:="Procedura przejscia do nowego roku rozliczeniowego"
ltopis[5]:="Podstawowe funkcje programu, sposob obslugi oraz algorytmy obliczeniowe"

save screen to ek
  lpoz=men_pion(2,33,5,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu uaktywniajace funkcje techniczne programu                       *
*******************************************************************************
FUNCTION PARAM_MENU(ppoz)
local ltnaz[4],ltlit[4],ltopis[4],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Obliczeniowe "
ltnaz[2]:=" Uzytkownik   "
ltnaz[3]:=" Katalogi     "
ltnaz[4]:=" Drukarki     "
ltlit[1]:=" O            "
ltlit[2]:=" U            "
ltlit[3]:=" K            "
ltlit[4]:=" D            "
ltopis[1]:="Zmiana parametrow przyjetych do obliczen"
ltopis[2]:="Dane nabywcy licencji"
ltopis[3]:="Przeglad i edycja urzedow skarbowych, ZUS-ow oraz kas chorych"
ltopis[4]:="Wybor drukarki domyslnej"

save screen to ek
  lpoz=men_pion(4,46,4,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

*******************************************************************************
* Tworzy menu uaktywniajace funkcje techniczne programu                       *
*******************************************************************************
FUNCTION LISTA_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Zbiorcza     "
ltnaz[2]:=" Indywidualna "
ltlit[1]:=" Z            "
ltlit[2]:=" I            "
ltopis[1]:="Wydruk listy plac wspolnej dla wszystkich pracownikow."
ltopis[2]:="Wydruk indywidualnej listy plac w formie paskow."

save screen to ek
  lpoz=men_pion(8,40,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu umozliwiajace wybor katalogu                                    *
*******************************************************************************
FUNCTION KATAL_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Urzedy skarbowe "
ltnaz[2]:=" Z U S - y    "
ltnaz[3]:=" Kasy chorych "
ltlit[1]:=" U            "
ltlit[2]:=" Z            "
ltlit[3]:=" K            "
ltopis[1]:="Przeglad i edycja urzedow skarbowych"
ltopis[2]:="Przeglad i edycja zakladow ubezpieczen spolecznych"
ltopis[3]:="Przeglad i edycja kas chorych"

save screen to ek
  lpoz=men_pion(7,59,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu wydruku przelewow                                               *
*******************************************************************************
FUNCTION PRZEL_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" W y d r u k       "
ltnaz[2]:=" Zmiana parametr¢w "
ltnaz[3]:=" Rezygnacja        "
ltlit[1]:=" W            "
ltlit[2]:=" Z            "
ltlit[3]:=" R            "
ltopis[1]:="Wydruk przelewow (lub przekazow) w formacie ZUS"
ltopis[2]:="Zmiana parametrow wydruku"
ltopis[3]:="Powrot do poprzedniego menu"

save screen to ek
  lpoz=men_pion(8,38,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

*******************************************************************************
* Tworzy menu wydruku przelewow                                               *
*******************************************************************************
FUNCTION PIT_11_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" W y d r u k       "
ltnaz[2]:=" Zmiana parametr¢w "
ltnaz[3]:=" Rezygnacja        "
ltlit[1]:=" W            "
ltlit[2]:=" Z            "
ltlit[3]:=" R            "
ltopis[1]:="Wydruk PIT-11 dla wszystkich pracownik¢w lub dla wybranego"
ltopis[2]:="Zmiana parametrow wydruku"
ltopis[3]:="Powrot do poprzedniego menu"

save screen to ek
  lpoz=men_pion(11,38,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu wydruku RMUA                                                    *
*******************************************************************************
FUNCTION RMUA_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" W y d r u k       "
ltnaz[2]:=" Zmiana parametrow "
ltnaz[3]:=" Rezygnacja        "
ltlit[1]:=" W            "
ltlit[2]:=" Z            "
ltlit[3]:=" R            "
ltopis[1]:="Wydruk w formacie ZUS"
ltopis[2]:="Zmiana parametrow wydruku"
ltopis[3]:="Powrot do poprzedniego menu"

save screen to ek
  lpoz=men_pion(10,39,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu wydruku RNA                                                     *
*******************************************************************************
FUNCTION RNA_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" W y d r u k       "
ltnaz[2]:=" Zmiana parametrow "
ltnaz[3]:=" Rezygnacja        "
ltlit[1]:=" W            "
ltlit[2]:=" Z            "
ltlit[3]:=" R            "
ltopis[1]:="Wydruk raportu RNA w formacie ZUS"
ltopis[2]:="Zmiana parametrow wydruku"
ltopis[3]:="Powrot do poprzedniego menu"

save screen to ek
  lpoz=men_pion(10,39,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu uaktywniajace funkcje techniczne programu                       *
*******************************************************************************
FUNCTION LDRUK_MENU(ppoz)
local ltnaz[5],ltlit[5],ltopis[5],lbelka:="",lpoz:=ppoz
ltnaz[1]:="Lista plac       "
ltnaz[2]:="Karty pracownicze"
ltnaz[3]:="Bilans miesiaca  "
ltnaz[4]:="Ub.zdrow.-doplaty"
ltnaz[5]:="S k l a d k i    "
ltlit[1]:="L                "
ltlit[2]:="K                "
ltlit[3]:="B                "
ltlit[4]:="U                "
ltlit[5]:="S                "
ltopis[1]:="Zbiorowa lista plac za biezacy miesiac"
ltopis[2]:="Indywidualne karty pracownicze dla wszystkich zatrudnionych"
ltopis[3]:="Podliczenie biezacego miesiaca"
ltopis[4]:="Wykaz pracownikow dla ktorych skladka ubezp. zdrowotnego przewyzsza podatek"
ltopis[5]:="Podliczenie wplat na konta 51, 52, 53"
save screen to ek
  lpoz=men_pion(2,23,5,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tworzy menu uaktywniajace funkcje techniczne programu                       *
*******************************************************************************
FUNCTION LDRUK1_MENU(ppoz)
local ltnaz[6],ltlit[6],ltopis[6],lbelka:="",lpoz:=ppoz
ltnaz[1]:="Lista plac          "
ltnaz[2]:="Karty pracownicze   "
ltnaz[3]:="Bilans miesiaca     "
ltnaz[4]:="Ub.zdrow.-doplaty   "
ltnaz[5]:="S k l a d k i       "
ltnaz[6]:="Procedury opcjonalne"
ltlit[1]:="L                   "
ltlit[2]:="K                   "
ltlit[3]:="B                   "
ltlit[4]:="U                   "
ltlit[5]:="S                   "
ltlit[6]:="P                   "
ltopis[1]:="Zbiorowa lista plac za biezacy miesiac"
ltopis[2]:="Indywidualne karty pracownicze dla wszystkich zatrudnionych"
ltopis[3]:="Podliczenie biezacego miesiaca"
ltopis[4]:="Wykaz pracownikow dla ktorych skladka ubezp. zdrowotnego przewyzsza podatek"
ltopis[5]:="Podliczenie wplat na konta 51, 52, 53"
ltopis[6]:="Dodatkowo instalowane w formie rozszerzenia programu opcje."
save screen to ek
  lpoz=men_pion(2,23,6,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


*******************************************************************************
* Tlo zgloszeniowe programu SH                                                *
*******************************************************************************
FUNCTION LP_TLO()
local lcolor:=setcolor()
set color to "gr+/n,n/gr+"
@ 11,0 say "∞     ÕÀ …Õ   …ÕÕÕª                                                            ∞"
@ 12,0 say "∞      ∫…º        ∫                                                            ∞"
@ 13,0 say "∞      Ã ª        ∫   ÕÕÕ       L  I  S  T  A      P  ù  A  C                  ∞"
@ 14,0 say "∞     Õ  »Õ       ∫                                                            ∞"
@ 15,0 say "∞             …ÕÕÕŒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ     ∞"
@ 16,0 say "∞             »ÕÕÕº                                                            ∞"
@ 17,0 say "∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞"
setcolor(lcolor)	
RETURN NIL

*******************************************************************************
* Drukuje na ekranie kilka aktualnych parametrow programu SH                  *
*******************************************************************************
FUNCTION LP_PARAMSAY()
setcolor("n/w,w/n")
@ 19,2 say " DATA ........................................"        
@ 19,49 say date()
@ 20,2 say " Obslugiwany miesiac.........................."
@ 20,49 say space(20)
@ 20,49 say zmies_nazwa
@ 22,2 say " Katalog roboczy ....."
*@ 19,25 say space(20)
@ 22,26 say SUBSTR(curdir(),1,30)
if zsiec
  @ 21,2 say " Wersja sieciowa          " 
else
  @ 21,2 say " Wersja jednostanowiskowa " 
endif
@ 21,49 say substr(zfnaz1,1,28)
setcolor("w/b/b/w")
@ 3,58 to 5,76
@ 4,60 say "Soft-KJ-Service"
RETURN (NIL)

FUNCTION FIRMA()
local ek
set default to
save screen to ek
kj_okno(5,20,7,"     P A R A M E T R Y    F I R M Y     ",1)
set cursor on
@ 8,25 get plic1
@ 10,25 get plic2
read
set cursor off
save to plac
restore screen from ek
RETURN NIL

FUNCTION TEST()
set default to f:\kj_legos\lp001
*set default to c:\kj_legos\lp001
select 0
if kj_use("place_01",.f.,3)
  set index to place_01
  locate for alltrim(pnazwisko)="D"
*  do while !rlock()
*  enddo
*  if reclock(3)
*    replace pnazwisko with "NoweD"
*  endif	
if addrec(3)
  replace pnazwisko with "Calkiem nowy"
endif
  browse()
endif 
use
RETURN

FUNCTION OBLICZ_PAR()
local ek
            save screen to ek
            lcolor=setcolor()
            sh_upraw=0
            set color to
            if zhaslo			
			  set default to lpset
              if.not.kj_haslo(0,46,1)
                keyboard chr(205)	
                setcolor(lcolor)	      
                restore screen from ek
			    return .f.
			  endif
			  close
            endif
			l_param()
            restore screen from ek
            setcolor(lcolor)	      
RETURN .t.			

FUNCTION RMUA_CO_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:="  Raporty       "
ltnaz[2]:="  Zestawienia   "
ltlit[1]:="  R             "
ltlit[2]:="  Z             "
ltopis[1]:="Wydruk raportow miesiecznych dla osob ubezpieczonych w formacie  ZUS  RMUA."
ltopis[2]:="Wydruk listy pracownikow otrzymujacych raport RMUA."

save screen to ek
  lpoz=men_pion(12,58,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

*******************************************************************************
*NOWYROK                                                                      *
*******************************************************************************
FUNCTION NOWYROK()
local i,ltest,lcolor:=setcolor(),ek
lstary:=curdir()
lnowy:=space(8)
save screen to ek
set color to
set default to
clear
for i=0 to 24
  @ i,0 say chr(176)
  @ i,79 say chr(176)
next
set color to n/w
@ 0,0 say "                          ZMIANA  ROKU ROZLICZENIOWEGO                          "
@ 24,0 say "                 [ENTER]-zatwierdzenie      [Esc]-rezygnacja                    "
set color to 
@ 3,2 say "Dotychczasowy katalog roboczy..."
@ 3,34 say lstary
@ 7,2 say "Nowy katalog roboczy .........."
@ 12,2 say "    W wyniku dzialania programu w katalogu glownym powstanie nowy katalog   " 
@ 13,2 say "o zdefiniowanej wyzej nazwie,do ktorego przekopiowany zostanie mijajacy rok." 
@ 14,2 say "W biezacym katalogu roboczym grudniowa lista plac przeniesiona zostanie     " 
@ 15,2 say "do tworzonego nowego roku i zastapi baze styczniowa. Pozostale beda puste.  " 
@ 20,2 say "UWAGA!  Przed rozpoczeciem operacji upewnij sie, czy biezacy dysk dysponuje " 
@ 21,2 say "odpowiednia iloscia wolnego miejsca.                                        " 
set cursor on
do while.t.
  @ 7,34 get lnowy
  read
  lnowy=alltrim(lnowy)
  if lastkey()=27
    exit
  else
    ltest=stuff(space(41),1,1,"\")
	ltest=stuff(ltest,2,40,lnowy)
    ltest=stuff(ltest,len(alltrim(ltest))+1,13,"\1dok\pam.mem")
	if.not.file(ltest)
      run bat\nowyr &lstary &lnowy
	  clear
	  exit
	else
	  set color to n/w
      @ 24,0 say "  Taki katalog juz istnieje !   Zmien nazwe i ponow probe.  Nacisnij klawisz.   "
      inkey(0)
	  set color to 	  
	endif
  endif
enddo  
set cursor off
setcolor(lcolor)
set default to pracow
restore screen from ek
RETURN

*******************************************************************************
*LP_DRUK                                                                      *
*******************************************************************************
************************************************************************
* Wydruk dokumentow                                                           *
*******************************************************************************
FUNCTION LP_DRUKUJ()
local ilosc:=1,k:=1,plik:="wydruki\nowy.txt"
if.not.set_druk()
  return
endif
if.not.zlista_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\lista.txt"
  set printer to &plik
endif
select 0
prac_use(zmiesiac)
vcol=5
*zdrabat=15
strona=1
stro=.f.

w=prow()
lp_tyt(.t.)  
lp=0
go top
do while.not.eof()
  p_lad()
  zlicz()         &&liczy stope i zwar_30
  lp=lp+1
  w=w+1
  if w>60
    strona=strona+1
	eject
	w=prow()
	lp_tyt(.t.)  
    w=w+1
  endif
  prac_druk()
  skip
enddo
w=w+1
lp_stopa()
eject
set device to screen
use
set printer to
RETURN nil


*******************************************************************************
* Wydruk dokumentow                                                           *
*******************************************************************************
FUNCTION LPI_DRUKUJ()
local ilosc:=1,k:=1,plik:="wydruki\nowy.txt",lktory,llicz_d23
if.not.set_druk()
  return
endif
if.not.zlista_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\lista.txt"
  set printer to &plik
endif
select 0
prac_use(zmiesiac)
vcol=5
*zdrabat=15
strona=0
stro=.f.
w=prow()
lp=0
lktory=0
go top
do while.not.eof()
  p_lad()
  zlicz()         &&liczy stope i zwar_30
  lp=lp+1
  lktory=lktory+1
  w=w+1
  lp_tyt(.t.)  
  w=w+1
  prac_druk()
  w=w+2
  @ w,0 say "Kwota do wypàaty:"
  llicz_d23=plicz_d23()
  @ w,20 say llicz_d23 picture "999999.99"
  pslownie(w,40,llicz_d23)
  w=w+2
  @ w,0 say "Wypàacià: "
  @ w,12 say zsporzadzil
  w=w+1
  @ w,40 say "...................................."
  w=w+1
  @ w,40 say "              podpis"
  w=w+1
  @ w,0 say replicate("-",130)
  w=w+2
  if lktory>2
	lktory=0
	eject
	w=prow()
  endif
  skip
enddo
eject
w=prow()
lp_tyt(.t.)
w=w+1
lp_stopa()
eject
set device to screen
use
set printer to
RETURN nil




FUNCTION LP_TYT(ptabelka)
*w=prow()
@ w,0 say &zdr_kkond
@ w,0 say alltrim(zfnaz1)
@ w,50 say "Za miesiac"
@ w,61 say zmies_nazwa
w=w+1
*@ w,0 say alltrim(zfnaz2)
@ w,50 say "Data wyplaty"
@ w,63 say zdata_wyplaty
w=w+2
@ w,20 say "L I S T A    P L A C     NR"

@ w,48 say znum_listy
w=w+1
@ w,20 say "------------------------------------"
if strona>0
  w=w+1
  @ w,60 say "Strona:"
  @ w,68 say strona picture "999"+&zdr_kond
else  
 @ prow(),pcol() say &zdr_kond
endif  
w=w+2
if ptabelka
  @ w,0 say "=================================================================================================================================="
  w=w+1
  @ w,0 say "| Lp.|    Pracownik       |  W Y N A G R O D Z E N I E  |  Ubezp. |  Ubezp. | Zasilek | Zaliczk.| Kwota do|    P  o  d  p  i  s  |"
  w=w+1
  @ w,0 say "|    |Nazwisko/Imie/Pesel | za prac.|chorobowe|  razem  | spolecz.| zdrowot.| in/rodz.| na podat| wyplaty |                      |"
  w=w+1
  @ w,0 say "|====|====================|=========|=========|=========|=========|=========|=========|=========|=========|======================|"
endif
RETURN nil

FUNCTION LP_TYT_latin(ptabelka)
*w=prow()
@ w,0 say &zdr_kkond
@ w,0 say alltrim(zfnaz1)
@ w,50 say "Za miesiac"
@ w,61 say zmies_nazwa
w=w+1
*@ w,0 say alltrim(zfnaz2)
@ w,50 say "Data wypàaty"
@ w,63 say zdata_wyplaty
w=w+2
@ w,20 say "L I S T A    P ù A C     NR"

@ w,48 say znum_listy
w=w+1
@ w,20 say "------------------------------------"
if strona>0
  w=w+1
  @ w,60 say "Strona:"
  @ w,68 say strona picture "999"+&zdr_kond
else  
 @ prow(),pcol() say &zdr_kond
endif  
w=w+2
if ptabelka
  @ w,0 say "=================================================================================================================================="
  w=w+1
  @ w,0 say "| Lp.|    Pracownik       |  W Y N A G R O D Z E N I E  |  Ubezp. |  Ubezp. | Zasiàek | Zaliczk.| Kwota do|    P  o  d  p  i  s  |"
  w=w+1
  @ w,0 say "|    |Nazwisko/Imi©/Pesel | za prac.|chorobowe|  razem  | spoàecz.| zdrowot.| in/rodz.| na podat| wypàaty |                      |"
  w=w+1
  @ w,0 say "|====|====================|=========|=========|=========|=========|=========|=========|=========|=========|======================|"
endif
RETURN nil



FUNCTION PRAC_DRUK()

@ w,0 say "|"
@ w,6 say alltrim(zpnazwisko)+"  "+alltrim(zpimie1)
if.not.zpzas_inne=0 
  @ w,77 say pzas_inne picture "999999.99"
endif
@ w,131 say "|"
w=w+1
@ w,0 say "|"
@ w,1 say lp picture "999"
@ w,11 say zppesel
@ w,27 say plicz_d7() picture "999999.99"
@ w,37 say pza_chor picture "999999.99"
@ w,47 say plicz_d7()+pza_chor picture "999999.99"
@ w,57 say plicz_d12() picture "999999.99"
*@ w,67 say plicz_d30() picture "999999.99"
@ w,67 say plicz_da30() picture "999999.99"
@ w,77 say pzasilek picture "999999.99"
@ w,87 say plicz_d16() picture "999999.99"
@ w,97 say plicz_d23() picture "999999.99"
@ w,131 say "|"
*w=w+1
*@ w,0 say "|"
*@ w,11 say zppesel
*@ w,131 say "|"
w=w+1
@ w,0 say "|================================================================================================================================|"
RETURN NIL

FUNCTION LP_STOPA()
local llicz_s23:=plicz_s23()
local ls_7:=0,ls_8:=0,ls_78:=0,ls_12:=0,ls_30:=0,ls_22:=0,ls_16:=0,ls_23:=0
local ls_9:=0,ls_10:=0,ls_11:=0
go top
do while.not.eof()
  p_lad()
  zlicz()
  ls_7=ls_7+plicz_d7()
  ls_8=ls_8+zpza_chor
  ls_78=ls_78+plicz_d7()+zpza_chor
  ls_12=ls_12+plicz_d12()
  *ls_30=ls_30+plicz_d30()
  ls_30=ls_30+plicz_da30()
  ls_22=ls_22+zpzasilek+zpzas_inne
  ls_16=ls_16+plicz_d16()
  ls_23=ls_23+plicz_d23()
  ls_9=ls_9+plicz_d9()
  ls_10=ls_10+plicz_d10()
  ls_11=ls_11+plicz_d11()
  skip
enddo
@ w,0 say "              |  Razem:"
@ w,27 say ls_7 picture "999999.99"
@ w,37 say ls_8 picture "999999.99" 
@ w,47 say ls_78 picture "999999.99"
@ w,57 say ls_12 picture "999999.99"
@ w,67 say ls_30 picture "999999.99"
@ w,77 say ls_22 picture "999999.99"
@ w,87 say ls_16 picture "999999.99"
@ w,97 say ls_23 picture "999999.99"
@ w,131 say "|"
w=w+1
@ w,0 say "              |  W tym:"
@ w,131 say "|"
w=w+1
@ w,0 say "              |  Skàadka emerytalna = "+alltrim(str(ls_9,9,2))+"     Rentowa = "+alltrim(str(ls_10,9,2))+"     Chorobowa =  "+alltrim(str(ls_11,9,2))
@ w,131 say "|"
w=w+1
@ w,0 say "              ===================================================================================================================="
w=w+2
if w>57
    strona=strona+1
	eject
	w=prow()
	lp_tyt(.f.)
*    w=w+1
endif
@ w,0 say "Kwota wyplacona:"
@ w,17 say llicz_s23 picture "999999.99" 
@ w,27 say "Zl."
vcol=40
ztbrut_all=llicz_s23
slownie()
w=w+2
lp_podpis()
RETURN nil

FUNCTION LP_STOPA1()
local llicz_s23:=plicz_s23()
@ w,0 say "              |  Razem:"
@ w,27 say plicz_s7() picture "999999.99"
@ w,37 say plicz_s12() picture "999999.99"
@ w,47 say plicz_s30() picture "999999.99"
@ w,57 say plicz_s22() picture "999999.99"
@ w,67 say plicz_s16() picture "999999.99"
@ w,77 say llicz_s23 picture "999999.99"
@ w,131 say "|"
w=w+1
@ w,0 say "              ===================================================================================================================="
w=w+2
if w>57
    strona=strona+1
	eject
	w=prow()
	lp_tyt(.f.)
*    w=w+1
endif
@ w,0 say "Kwota wyplacena:"
@ w,17 say llicz_s23 picture "999999.99" 
@ w,27 say "Zl."
vcol=40
ztbrut_all=llicz_s23
slownie()
w=w+2
lp_podpis()
RETURN nil

FUNCTION LP_PODPIS()
@ w,0 say "Sporzadzil:"
@ w,12 say zsporzadzil
@ w,45 say "Sprawdzil:"
@ w,56 say zsprawdzil
@ w,88 say "Zatwierdzil:"
@ w,102 say zzatwierdzi
w=w+3
@ w,0 say   "podpis    .............................." 
@ w,45 say  "podpis    .............................."
@ w,88 say  "podpis    .............................." 
RETURN


FUNCTION SET_DRUK()
local select:=select(),ek,lcolor:=setcolor(),lsukces:=.t.
znum_listy=stuff(space(15),1,len(alltrim(str(zmiesiac))),alltrim(str(zmiesiac)))
znum_listy=stuff(znum_listy,3,1,"/")
znum_listy=stuff(znum_listy,4,2,substr(str(year(date())),4))
prac_default()
select 0
if kj_use("druk_set",.t.,3)
  dset_lad()  
else
  dset_zer()
endif
save screen to ek
kj_okno(7,15,14,"           ODPOWIEDZIALNI ZA DOKUMENT             ",1)
@ 10,17 say "Sporzadzil/wyp."
@ 12,17 say "Sprawdzil ....."
@ 14,17 say "Zatwierdzil ..."
@ 16,17 say "Data wyplaty .."
@ 18,17 say "Numer listy ..."
set cursor on
@ 10,32 get zsporzadzil
@ 12,32 get zsprawdzil
@ 14,32 get zzatwierdzil
@ 16,32 get zdata_wyplaty
@ 18,32 get znum_listy   
read
set cursor off
if.not.lastkey()=27
  dset_replac()
else
  lsukces=.f.
endif
use
select &select
restore screen from ek
setcolor(lcolor)
RETURN lsukces

FUNCTION DSET_PUBLIC()
public zsporzadzil:=space(30),zsprawdzil:=space(30),zzatwierdzi:=space(30)
RETURN

FUNCTION DSET_LAD()
zsporzadzil=sporzadzil
zsprawdzil=sprawdzil
zzatwierdzi=zatwierdzi
RETURN

FUNCTION DSET_ZER()
zsporzadzil=space(30)
zsprawdzil=space(30)
zzatwierdzi=space(30)
RETURN

FUNCTION DSET_REPLAC()
replace sporzadzil with zsporzadzil,sprawdzil with zsprawdzil
replace zatwierdzi with zzatwierdzi
RETURN nil

FUNCTION KARTA_DRUK()
local k3:=0,k5:=0,k6:=0,k7:=0,k8:=0,k9:=0,k10:=0,k11:=0,k12:=0,k13:=0,k14:=0
local ksum3:=0,ksum5:=0,ksum6:=0,ksum7:=0,ksum8:=0,ksum9:=0,ksum10:=0
local ksum11:=0,ksum12:=0,ksum13:=0,ksum14:=0
local recno,i
p_lad()
recno=recno()
close
set default to &zlurzad_server
select 0
if kj_use("us",.t.,3)
  locate for kod=zpus_kod
  if found()
    us_lad()
  endif
  close
else
  prac_default()
  return .F.
endif
prac_default()
if.not.zkarta_plik
  if start_druk()
    set device to printer
  else
    return .F.
  endif
else
  set device to printer
  plik="wydruki\karta.txt"
  set printer to &plik
endif

w=prow()
@ w,0 say &zdr_kkond
@ w,0 say alltrim(zfnaz1)
w=w+1
kprac_tyt()  

lmiesiac=zmiesiac
for i=1 to lmiesiac
  zmiesiac=i
  select 0
  prac_use(i)
  locate for pnumer=zpnumer
  if found()
    p_lad()
    zlicz()
	k3=plicz_d7()+pza_chor    
	k5=zpkoszty
	k6=plicz_d9()
	k7=plicz_d10()
	k8=plicz_d11()
	k9=plicz_d13()-zpkoszty
	k10=k10+k9
    k11=plicz_d15()
	k12=plicz_d30()
	k13=plicz_d16()	
    k14=zpza_chor
	ksum3=ksum3+k3
	ksum5=ksum5+k5
	ksum6=ksum6+k6
	ksum7=ksum7+k7
	ksum8=ksum8+k8
	ksum9=ksum9+k9
	ksum11=ksum11+k11
	ksum12=ksum12+k12
	ksum13=ksum13+k13
    ksum14=ksum14+k14
	@ w,0 say "|"
    @ w,1 say mies_nazwa(i)
    @ w,14 say k3 picture "9999999.99"
    @ w,25 say k5 picture "9999999.99"
	@ w,37 say k6 picture "9999999.99"
	@ w,48 say k7 picture "9999999.99"
	@ w,59 say k8 picture "9999999.99"
	@ w,70 say k9 picture "9999999.99"
	@ w,82 say k10 picture "9999999.99"
	@ w,94 say k11 picture "9999999.99"
	@ w,106 say k12 picture "9999999.99"
	@ w,118 say k13 picture "9999999.99"
    @ w,128 say "|"
    w=w+1 
    @ w,0 say "|============|==========|===========|==========|==========|==========|===========|===========|===========|===========|==========|"
    w=w+1
  endif	
  use
next
@ w,0 say "|"
@ w,1 say " Razem:"
    @ w,14 say ksum3 picture "9999999.99"
    @ w,25 say ksum5 picture "9999999.99"
	@ w,37 say ksum6 picture "9999999.99"
	@ w,48 say ksum7 picture "9999999.99"
	@ w,59 say ksum8 picture "9999999.99"
	@ w,70 say ksum9 picture "9999999.99"
	@ w,94 say ksum11 picture "9999999.99"
	@ w,106 say ksum12 picture "9999999.99"
	@ w,118 say ksum13 picture "9999999.99"
@ w,128 say "|"
w=w+1 
@ w,0 say "================================================================================================================================="
w=w+2
@ w,0 say "Suma skladek ubezpieczenia spolecznego:"
@ w,40 say ksum6+ksum7+ksum8 picture "9999999.99"
w=w+1
@ w,0 say "Wynagrodzenie za czas choroby w miesiacu biezacym :             "
@ w,52 say k14 picture "9999999.99"
@ w,70 say "od poczatku roku :"
@ w,89 say ksum14 picture "9999999.99"
w=w+3
@ w,0 say "Dnia: "
@ w,7 say date() 
w=w+1
select 0
if kj_use("druk_set",.t.,3)
  dset_lad()  
  use
else
  dset_zer()
endif
lp_podpis()
eject
set device to screen
prac_use(zmiesiac)
go recno
p_lad()
RETURN .T.

FUNCTION KPRAC_TYT()
@ w,0 say &zdr_kond
w=w+1
@ w,22 say "K A R T A   P R Z Y C H O D O W    P R A C O W N I K A"
w=w+1	
@ w,20 say "--------------------------------------------------------"
w=w+2
@ w,0 say "DANE PERSONALNE:"
@ w,80 say "ADRES ZAMIESZKANIA:"
w=w+1
@ w,0 say "================"
@ w,80 say "==================="
w=w+1
@ w,0 say "Nazwisko ...."+zpnazwisko
@ w,40 say "Data urodzenia ...."+dtoc(zpdata_ur)
@ w,80 say alltrim(zpulica)+"  "+alltrim(zpdom_nr)+" / "+alltrim(zplokal_nr)
w=w+1
@ w,0 say "Imiona ......"+alltrim(zpimie1)+" / "+alltrim(zpimie2)
@ w,40 say "Miejsce urodzenia.."+substr(zpmiejsc_ur,1,20)
@ w,80 say zpkod+"  "+alltrim(zpmiejscow)
w=w+1
@ w,0 say "Imie ojca ..."+zpimie_ojca
@ w,40 say "Nr PESEL .........."+zppesel
@ w,80 say "Gmina: "+alltrim(zpgmina)
w=w+1
@ w,0 say "Imie matki .."+zpimie_matk
@ w,40 say "Nr  N I P  ........"+zpnip
@ w,80 say "Wojewodztwo: "+alltrim(zpwojew) 
w=w+2

@ w,0 say "ZATRUDNIENIE :   Od dnia: "+dtoc(zpstart)+"   Do dnia: "+dtoc(zpend)
w=w+2
@ w,0 say "URZAD SKARBOWY (wlasciwy w sprawie podatku dochodowego pracownika):"
w=w+1
@ w,0 say ALLTRIM(zulica)+"  "+ALLTRIM(znumer)+"    "+ALLTRIM(zkod_poczt)+"  "+ALLTRIM(zmiasto)
w=w+3
@ w,0 say "================================================================================================================================="
w=w+1
@ w,0 say "|            |          |  Koszty   | Skladki ubezpieczen spolecznych|  Dochod   |  Dochod   | Potracona |  Skladka  | Nalezna  |"
w=w+1
@ w,0 say "|  Miesiac   | Przychod | uzyskania |--------------------------------| w  danym  |od poczatku| zaliczka  |  na Kase  | zaliczka |"
w=w+1
@ w,0 say "|            |          | przychodu |emerytalna| rentowa  |chorobowa | miesiacu  |    roku   |na podatek |  Chorych  |na podatek|"
w=w+1
@ w,0 say "|============|==========|===========|==========|==========|==========|===========|===========|===========|===========|==========|"
w=w+1
@ w,0 say "|                                                                                                                               |"
RETURN

FUNCTION ALL_KARTA_DRUK()
local recno:=0,i
select 0
prac_use(zmiesiac)
do while.not.eof()
  if karta_druk()
    skip
  else
    exit
  endif	
enddo  
use
RETURN

FUNCTION KAS_RAPORT()
local kas_sel,prac_sel,ltyt:=.t.,lp:=0
local llicz_d14:=0,llicz_d15:=0,lsum_d14:=0,lsum_d15:=0
select 0
if prac_use(zmiesiac)
  prac_sel=select()
else
  return
endif
set default to &zlurzad_server
select 0
if kj_use("kasa_ch",.t.,3)
  kas_sel=select()
else
  prac_default()
  select &prac_sel
  close
  return
endif
prac_default()

if.not.zkasa_plik
  if start_druk()
    set device to printer
  else
    select &prac_sel
    close
    return
  endif
else
  set device to printer
  plik="wydruki\kasa.txt"
  set printer to &plik
endif

do while.not.eof()
  w=prow()
  ltyt=.t.
  lstop=.f.
  lp=0
  lsum_d14=0
  lsum_d15=0
  us_lad()
  select &prac_sel
  set filter to pkas_kod=zkod
  go top
  do while.not.eof()
    p_lad()
	if kas_warunek()
	  lp=lp+1
	  if ltyt
	    kas_tyt()
	  endif
	  ltyt=.f.
	  lstop=.t.
      llicz_d14=plicz_d14()
	  llicz_d15=plicz_d15()
	  @ w,0 say "|"
	  @ w,2 say lp picture "999"
      @ w,7 say zpnazwisko
	  @ w,30 say zpimie1
	  @ w,53 say zppesel
	  @ w,67 say zpnip
	  @ w,83 say zpdata_ur
	  @ w,95 say llicz_d14 picture "9 999 999.99"
	  @ w,111 say llicz_d15 picture "9 999 999.99"
	  @ w,126 say "|"
	  w=w+1
	  lsum_d14=lsum_d14+llicz_d14
	  lsum_d15=lsum_d15+llicz_d15
	endif
    skip
  enddo

  if lstop
    @ w,0 say "==================================================================================|===========|===============|===============|"
    w=w+1
	@ w,82 say "|"
	@ w,84 say "Razem:"
    @ w,95 say lsum_d14 picture "9 999 999.99"
    @ w,111 say lsum_d15 picture "9 999 999.99"	
	@ w,126 say "|"
    w=w+1
    @ w,0 say "Dopàata: Skàadka naleæna - Skàadka pobr•na  =  "
	@ w,48 say lsum_d14-lsum_d15 picture "9 999 999.99"	
    @ w,82 say "============================================="	
    select 0
    if kj_use("druk_set",.t.,3)
      dset_lad()  
      use
	else
      dset_zer()
    endif
    w=w+5
    @ w,0 say "Dnia:"
	@ w,7 say date()
	w=w+1
    lp_podpis()
    eject
  endif
  select &kas_sel
  skip
enddo
use
select &prac_sel
use
set device to screen
RETURN nil

FUNCTION KAS_TYT()
w=prow()
@ w,0 say &zdr_kond
@ w,30 say "ZESTAWIENIE ROZLICZENIA SKùADEK NA UBEZPIECZENIE ZDROWOTNE"
w=w+1
@ w,30 say "                ZA  MIESI§C "
@ w,60 say mies_nazwa(zmiesiac)
w=w+1
@ w,28 say "------------------------------------------------------------"
w=w+2
@ w,0 say "PùATNIK:"
@ w,65 say "KASA CHORYCH:"
w=w+1
@ w,0 say "========"
@ w,65 say "============="
w=w+1
@ w,0 say alltrim(zfnaz1)
@ w,65 say zkod+"  "+alltrim(znazwa)
w=w+1
@ w,0 say alltrim(zfnaz2)
@ w,65 say alltrim(zulica)+" "+alltrim(znumer)
w=w+1
@ w,0 say alltrim(zfulica)
@ w,65 say zkod_poczt+"  "+alltrim(zmiasto)
w=w+1
@ w,0 say zfkod+"  "+ALLTRIM(zfmiasto)
w=w+1
@ w,0 say "NIP: "+alltrim(zfnip)+"   REGON: "+alltrim(zfregon)+"   PESEL: "+alltrim(zfpesel)
*w=w+1
*@ w,0 say "   PESEL: "+alltrim(zfpesel)

w=w+3
@ w,0 say "==============================================================================================================================="
w=w+1
@ w,0 say "| Lp. |      Nazwisko        |        Imie          |    Pesel    |     Nip       |   Data    |  Skàadki na ubezp. zdrowotne  |"
w=w+1
@ w,0 say "|     |                      |                      |             |               | urodzenia |   Naleæne     |   Pobrane     |"
w=w+1
@ w,0 say "|=====|======================|======================|=============|===============|===========|===============|===============|"
w=w+1
@ w,0 say "|                                                                                                                             |"

RETURN nil

FUNCTION KAS_WARUNEK()
local lwarunek:=.f.
zlicz()
if plicz_d14()>plicz_d15()
  lwarunek=.t.
endif
RETURN lwarunek

FUNCTION BIL_DRUK(pprac_sum,pbrutto_sum,pzdrow_sum,pzdrow_odlicz_sum,ppodat_sum)
if.not.zbilmies_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\bilmies.txt"
  set printer to &plik
endif
w=prow()
@ w,0 say &zdr_kkond
@ w,22 say "PODSUMOWANIE ZA MIESIAC:"
@ w,47 say mies_nazwa(zmiesiac)
w=w+3
@ w,0 say "PùATNIK:"
w=w+1
@ w,0 say "========"
w=w+2
@ w,0 say alltrim(zfnaz1)+"  "+alltrim(zfnaz2)
w=w+1
@ w,0 say "NIP: "+alltrim(zfnip)+"  REGON: "+alltrim(zfregon)+"  PESEL: "+alltrim(zfpesel)
w=w+1
@ w,0 say alltrim(zfulica)+"    "+alltrim(zfkod)+"  "+alltrim(zfmiasto)
w=w+5
@ w,0 say "Liczba pracownik¢w ..........................."
@ w,47 say pprac_sum picture "99 999 999"
w=w+2
*@ w,0 say "Wynagrodzenie brutto ........................."
@ w,0 say "Suma wypàat podlegaj•ca opodatkowaniu ..... .."
@ w,47 say pbrutto_sum picture "99 999 999.99"
w=w+2
@ w,0 say "Skàadki ubezpieczenia zdrowotnego : pobrane   "
@ w,47 say pzdrow_sum picture "99 999 999.99"
w=w+1
@ w,0 say "                                    odliczone "
@ w,47 say pzdrow_odlicz_sum picture "99 999 999.99"
w=w+2
@ w,0 say "Zaliczka na podatek dochodowy (potracona) ...."
@ w,47 say ppodat_sum picture "99 999 999.99"  +&zdr_kond
    select 0
    if kj_use("druk_set",.t.,3)
      dset_lad()  
      use
	else
      dset_zer()
    endif
    w=w+7
    	@ w,0 say "Dnia:"
	@ w,7 say date()
	w=w+1
    lp_podpis()
eject
set device to screen
RETURN nil


FUNCTION SKLADKI_DRUK(p51_dawca,p51_wspol1,p51_wspol2,p51_wnik_all,p52_dawca,p52_wspol1,p52_wspol2,p52_wnik_all,p53_all,pzasilek_all)
if.not.zskladki_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\skladki.txt"
  set printer to &plik
endif
p51_all=p51_dawca+p51_wspol1+p51_wspol2+p51_wnik_all
p52_all=p52_dawca+p52_wspol1+p52_wspol2+p52_wnik_all
w=prow()
@ w,0 say &zdr_kkond
@ w,18 say "PODSUMOWANIE SKùADEK ZA MIESI§C:"
@ w,51 say mies_nazwa(zmiesiac)
w=w+3
@ w,0 say "PùATNIK:"
w=w+1
@ w,0 say "========"
w=w+2
@ w,0 say alltrim(zfnaz1)+"  "+alltrim(zfnaz2)
w=w+1
@ w,0 say "NIP: "+alltrim(zfnip)+"  REGON: "+alltrim(zfregon)+"  PESEL: "+alltrim(zfpesel)
w=w+1
@ w,0 say alltrim(zfulica)+"    "+alltrim(zfkod)+"  "+alltrim(zfmiasto)
w=w+5
*

@ w,2  say "                                      SKùADKI UBEZPIECZENIA"
w=w+2
@ w,2 say  "                            SPOùECZNEGO                   ZDROWOTNEGO"
w=w+1
@ w,2 say  "                             (Konto 51)                    (Konto 52)"
w=w+2
@ w,2 say "Pracodawca ............"
@ w,27 say p51_dawca picture "99 999 999.99"
@ w,59 say p52_dawca picture "99 999 999.99"
w=w+1
@ w,2 say "Wspolpracownik ........"
@ w,27 say p51_wspol1 picture "99 999 999.99"
@ w,59 say p52_wspol1 picture "99 999 999.99"
w=w+1
@ w,2 say "Pracownicy ............"
@ w,27 say p51_wnik_all picture "99 999 999.99"
@ w,59 say p52_wnik_all picture "99 999 999.99"
w=w+1
@ w,2 say"                         -------------                 ---------------"
w=w+1
@ w,2 say"          Razem:   " 
@ w,27 say p51_all picture "99 999 999.99"
@ w,59 say p52_all picture "99 999 999.99"
w=w+1
@ w,2 say"          - odliczenia"
@ w,27 say pzasilek_all picture "99 999 999.99"
w=w+1
@ w,2 say"          Do zapàaty"
@ w,27 say p51_all-pzasilek_all picture "99 999 999.99"
w=w+4
@ w,2 say"SKùADKI NA FUNDUSZ PRACY  (Konto 53)  ................ "
@ w,59 say p53_all picture "99 999 999.99"
w=w+4
@ w,2 say"RAZEM: (Spoleczne)-(odliczenia)+(Zdrowotne)+(Fundusz) ="
@ w,59 say p51_all-pzasilek_all+p52_all+p53_all picture "99 999 999.99" +&zdr_kond

*
    select 0
    if kj_use("druk_set",.t.,3)
      dset_lad()  
      use
	else
      dset_zer()
    endif
    w=w+7
    	@ w,0 say "Dnia:"
	@ w,7 say date()
	w=w+1
    lp_podpis()
@ prow(),pcol() say &zdr_kkond
eject
set device to screen
RETURN nil



FUNCTION PRZEL_DRUK(p51,p52,p53)
local lkonto,i,j,lkwota,lkwtxt,lfkonto,lfnaz,lfnip,lznak_byl,m,lkonto1
local lczlon1:="",lczlon2:=""
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\przelew.txt"
  set printer to &plik
endif
for m=1 to 3
  do case
    case m=1
     lkwota=p51
	  lkonto=zk_spol
	  lkonto1=zkspol
    case m=2
	  lkwota=p52
	  lkonto=zk_zdrow
	  lkonto1=zkzdrow	  
    case m=3
	  lkwota=p53
	  lkonto=zk_fundusz	  	  
	  lkonto1=zkfundusz	  	  	  
  endcase
  if lkwota>0
	lkwtxt=alltrim(str(lkwota,10,2))
    for j=1 to zdruk_il
      *w=prow()+zrow
	  w=prow()
      pion_przes(zrow)
      k=zcol

      @ w,k+1 say szertekst(lkonto,.t.)       &&Konto
      @ w,k+41 say lkonto1       &&Konto	  
      w=w+2
	  @ w,k+31 say szertekst(lkwtxt,.t.)

	  w=w+2
	  if zprzelew                          &&Numet konta / slownie
	    lfkonto=alltrim(zfkonto)
		for i=1 to len(lfkonto)
		  if.not.substr(lfkonto,i,1)$"0123456789-"
		    lfkonto=stuff(lfkonto,i,1," ")
		  endif
		next
		lfkonto=alltrim(lfkonto)
		*lfkonto=substr(lfkonto,1,25)
	    *@ w,k+5 say szertekst(lfkonto,.t.)
		if zdlugie_konto
		  lczlon1=substr(lfkonto,1,2)
		  lczlon2=substr(lfkonto,3)
		  @ w,k+1 say szertekst(lczlon1,.t.)
		  @ w,k+5 say lczlon2
		else
		  lfkonto=substr(lfkonto,1,26)
	      *@ w,k+5 say szertekst(lfkonto,.t.)		
		  @ w,k+1 say szertekst(lfkonto,.t.)		
		endif  
	  else
        slow(w,k+5,lkwtxt)	  
	  endif

      w=w+2
	  if znaz_czlon="1"                     &&Nazwa pierwszy / drugi czlon
        lfnaz=zfnaz1
	  else
        lfnaz=zfnaz2
	  endif
	  lfnaz=alltrim(lfnaz)
	  if len(lfnaz)<28 
	    @ w,k+1 say szertekst(lfnaz,.t.)	   
	    w=w+2
	  else
	    lfnaz1=substr(lfnaz,1,27)
		lfnaz2=substr(lfnaz,28,54)
		@ w,k+1 say szertekst(lfnaz1,.t.)
		w=w+2 
		@ w,k+1 say szertekst(lfnaz2,.t.)	   	   
	  endif	

      w=w+2
      lfnip=alltrim(zfnip)             &&Nip
	  do while .t.
	    lznak_byl=.f.
	    for i=1 to len(lfnip)
		  if substr(lfnip,i,1)="-"
		    lfnip=stuff(lfnip,i,1,"")
			lznak_byl=.t.
			exit
		  endif
		next
		if.not.lznak_byl
		  exit
		endif
	  enddo
      @ w,k+1 say szertekst(lfnip,.t.)

      @ w,k+23 say ztyp_ident        &&Typ id.uzup.
	  
	  do case                        &&Regon/Pesel
	    case ztyp_ident="R"
		  @ w,k+27 say szertekst(zfregon,.t.)
		otherwise
		  @ w,k+27 say szertekst(zfpesel,.t.)
	  endcase	

      w=w+2
	  @ w,k+1 say ztyp_wplaty
*      @ w,k+7 say szertekst(zprzel_rok,.t.)
*	  @ w,k+15 say szertekst(zprzel_mies,.t.)	  
*	  @ w,k+21 say szertekst(znum_deklar,.t.)
	  @ w,k+5 say szertekst(znum_deklar,.t.)
	  @ w,k+11 say szertekst(zprzel_mies,.t.)	  	  
      @ w,k+15 say szertekst(zprzel_rok,.t.)



      w=w+2
	  if zpieczec                &&Wydruk danych osoby wplacajacej
	    @ prow(),pcol() say &zdr_kond
		@ w,k+5 say zfnaz1
		w=w+1
		@ w,k+5 say zfnaz2
		w=w+1
		@ w,k+5 say zfulica
		w=w+1
		@ w,k+5 say zfkod+"   "+zfmiasto + &zdr_kkond
	  endif
	  
	  	  
	  if inkey()=27
	    exit
	  endif
	  eject
	  *@ prow(),pcol() say &strona
    next
  endif
next
@ prow(),pcol() say &zdr_kkond
set device to screen
RETURN .t.

FUNCTION SZERTEKST(ptxt,palltrim)
local ltxt:=space(100),lznak,ile
if palltrim
  ile=len(alltrim(ptxt))
else
  ile=len(ptxt)
endif
for i=1 to ile
  lznak=substr(ptxt,i,1)
  ltxt=stuff(ltxt,(2*i)-1,1,lznak)
next
if palltrim
  ltxt=alltrim(ltxt)
else
  ltxt=trim(ltxt)
endif  
RETURN ltxt

FUNCTION SZERKROP(ptxt)
local ltxt:=space(100),lznak,ile
ile=len(ptxt)
for i=1 to ile
  lznak=substr(ptxt,i,1)
  ltxt=stuff(ltxt,(2*i)-1,1,lznak)
next
ile=len(ltxt)
for i=1 to ile
  lznak=substr(ltxt,i,1)
  if lznak=="."
    *ltxt=stuff(ltxt,i-1,3,",")
	ltxt=stuff(ltxt,i-1,3," ")
	exit
  endif	
next
RETURN trim(ltxt)

FUNCTION SLOW(prow,pcol,pkwota)
local kwota:=pkwota,ilecyfr,i,j
local cyfra:=" ",lslow:=space(100),lcyfra
ilecyfr=len(kwota)
for i=1 to ilecyfr
  do case
    case substr(kwota,i,1)="0"
	  cyfra="zer*"
    case substr(kwota,i,1)="1"
	  cyfra="jed*"
    case substr(kwota,i,1)="2"
	  cyfra="dwa*"
    case substr(kwota,i,1)="3"
      cyfra="trz*"
    case substr(kwota,i,1)="4"
	  cyfra="czt*"
    case substr(kwota,i,1)="5"
      cyfra="pie*"
    case substr(kwota,i,1)="6"
	  cyfra="sze*"
    case substr(kwota,i,1)="7"
	  cyfra="sie*"
    case substr(kwota,i,1)="8"
	  cyfra="osi*"
    case substr(kwota,i,1)="9"
	  cyfra="dzi*"
   case substr(kwota,i,1)$".,"
	  cyfra="Zl*"	  
  endcase
*  @ prow,pcol+(i-1)*8 say szertekst(cyfra,.t.)
  lcyfra=szertekst(cyfra,.t.)
  if i=1
    lslow=stuff(lslow,len(alltrim(lslow))+1,len(lcyfra),lcyfra) 
  else
    lslow=stuff(lslow,len(alltrim(lslow))+2,len(lcyfra),lcyfra) 
  endif	
next
lslow=stuff(lslow,len(alltrim(lslow))+2,5,"G r *")
lslow=substr(lslow,1,50)
@ prow,pcol say lslow
RETURN

FUNCTION SLOW_OLD(prow,pcol,pkwota)
local kwota:=pkwota,ilecyfr,i,j
local cyfra:=" "
*for j=1 to len(pkwota)
*  if substr(kwota,j,1)$".,"
*    kwota=stuff(kwota,j,1,"")
*  endif
*next
ilecyfr=len(kwota)
if ilecyfr>6
  ilecyfr=6
endif
for i=1 to ilecyfr
  do case
    case substr(kwota,i,1)="0"
	  cyfra="zer*"
    case substr(kwota,i,1)="1"
	  cyfra="jed*"
    case substr(kwota,i,1)="2"
	  cyfra="dwa*"
    case substr(kwota,i,1)="3"
      cyfra="trz*"
    case substr(kwota,i,1)="4"
	  cyfra="czt*"
    case substr(kwota,i,1)="5"
      cyfra="pie*"
    case substr(kwota,i,1)="6"
	  cyfra="sze*"
    case substr(kwota,i,1)="7"
	  cyfra="sie*"
    case substr(kwota,i,1)="8"
	  cyfra="osi*"
    case substr(kwota,i,1)="9"
	  cyfra="dzi*"
   case substr(kwota,i,1)$".,"
	  cyfra="Zl*"	  
  endcase
  @ prow,pcol+(i-1)*8 say szertekst(cyfra,.t.)
next
*@ prow(),pcol() say "Koniec"
RETURN

FUNCTION NIP_(pnip)
      lfnip=alltrim(zfnip)             &&Nip
	  do while .t.
	    lznak_byl=.f.
	    for i=1 to len(lfnip)
		  if substr(lfnip,i,1)="-"
		    lfnip=stuff(lfnip,i,1,"")
			lznak_byl=.t.
			exit
		  endif
		next
		if.not.lznak_byl
		  exit
		endif
	  enddo
RETURN lfnip

FUNCTION DAT_(pdat)
local lznak_byl
      ldat=dtoc(pdat)
	  do while .t.
	    lznak_byl=.f.
	    for i=1 to len(ldat)
		  if substr(ldat,i,1)$"-./"
		    ldat=stuff(ldat,i,1,"")
			lznak_byl=.t.
			exit
		  endif
		next
		if.not.lznak_byl
		  exit
		endif
	  enddo
*ldat=stuff(ldat,5,0,"19")
RETURN ldat

FUNCTION ETAT_(ppetat)
local letat:="  "
do case
  case ppetat=0.25
    letat="    1   4"
  case ppetat=0.5
    letat="    1   2"
  case ppetat=0.75
    letat="    3   4"	
  case ppetat=1
    letat="    1   1"
  case ppetat=1.25
    letat="    5   4"
  case ppetat=1.5
    letat="    3   2"
  case ppetat=1.75
    letat="    7   4"	
  case ppetat=2
    letat="    2   1"		
endcase
RETURN letat

FUNCTION LO_RODZ()
local lile1:=substr(zpuwagi,1,1),lile2:=substr(zpuwagi,2,1),lile:=space(2)
if lile1$" 0123456789".and.lile2$" 1234567890"
  lile:=substr(zpuwagi,1,2)
endif
RETURN lile

FUNCTION LO_PIEL()
local lile1:=substr(zpuwagi,4,1),lile2:=substr(zpuwagi,5,1),lile:=space(2)
if lile1$" 0123456789".and.lile2$" 1234567890"
  lile:=substr(zpuwagi,4,2)
endif
RETURN lile

FUNCTION LASTDAY(pmies)
local llastday:="31"
do case
  case pmies=2
    llastday="28"
  case pmies=4.or.pmies=6.or.pmies=9.or.pmies=11
    llastday="30"	
endcase
RETURN llastday


FUNCTION RMUA_ADRUK()
local select:=select(),ltytul:="",ltyt_num:=val(alltrim(substr(zpuwagi,7,2)))
local recno:=recno()
set default to lpset
select 0
if file("ub_tytul.dbf")
  if kj_use("ub_tytul",.f.,3)
    tyt_sel=select()
    locate for num=ltyt_num
	if found()
      ltytul=tytul
	endif  
	use
  endif
endif
prac_default()
select &select
*go recno()
zlicz()
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rmua_a.txt"
  set printer to &plik
endif
*w=prow()+zrow
w=prow()
pion_przes(zrow)
k=zcol
@ w,k+27 say szertekst(znum_deklar,.t.)       &&Nume deklaracji
@ w,k+33 say szertekst(txt_month(val(zrmua_mies)),.t.)
*@ w,k+33 say zrmua_mies
@ w,k+37 say szertekst(zrmua_rok,.t.)
w=w+3 
@ w,k+5 say szertekst(nip_(zfnip),.t.)
@ w,k+33 say szertekst(zfregon,.t.)
w=w+2
@ w,k+5 say szertekst(zfpesel,.t.)
w=w+2
@ w,k+5 say zrmnazwisko
@ w,k+47 say zrmimie
w=w+2
@ w,k+5 say zrmnazwa
@ w,k+61 say szertekst(dat_(zrmdata_ur),.t.)
w=w+3
@ w,k+5 say zpnazwisko
@ w,k+47 say zpimie1
w=w+2
if.not.empty(zppesel)
  @ w,k+10 say "P E S E L"
  @ w,k+33 say zppesel
endif
w=w+3
@ w,k+5 say ltytul
w=w+2
@ w,k+51 say etat_(zpetat) 
w=w+3
*szerkrop(str(plicz_d7(),9,2),.f.)

@ w,k+17 say szerkrop(str(plicz_d7(),9,2),.f.)
@ w,k+42 say szerkrop(str(plicz_d7(),9,2),.f.)
@ w,k+60 say szerkrop(str(plicz_d13(),9,2),.f.)
w=w+2
@ w,k+11 say szerkrop(str(plicz_d9(),8,2),.f.)
@ w,k+27 say szerkrop(str(plicz_d10(),8,2),.f.)
@ w,k+44 say szerkrop(str(plicz_d11(),8,2),.f.)
@ w,k+62 say szerkrop(str(plicz_da30(),8,2),.f.)
w=w+2
@ w,k+11 say szerkrop(str(plicz_d9(),8,2),.f.)
@ w,k+27 say szerkrop(str(plicz_d10(),8,2),.f.)
@ w,k+44 say szerkrop(str(plicz_d31(),8,2),.f.)
w=w+2
@ w,k+60 say szerkrop(str(plicz_d32(),9,2),.f.)
w=w+17
@ w,k+17 say szertekst(lo_rodz(),.f.)
@ w,k+35 say szerkrop(str(zpzasilek,8,2),.f.)
w=w+2
@ w,k+17 say szertekst(lo_piel(),.f.)
@ w,k+35 say szerkrop(str(zpzas_inne,8,2),.f.)
@ w,k+62 say szerkrop(str(zpzasilek+zpzas_inne,8,2),.f.)

eject
set device to screen
RETURN .t.

FUNCTION RMUA_BDRUK()
local lw1,lstart_day:="01",lend_day:=lastday(val(zrmua_mies))
if month(zpstart)=val(zrmua_mies).and.str(year(zpstart))=substr(str(year(date())),3)
  lstart_day=txt_day(zpstart)
endif
*if month(zpend)=val(zrmua_mies).and.year(zpend)=year(date())
if.not.empty(zpend)
  lend_day=txt_day(zpend)
endif
zlicz()
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rmua_b.txt"
  set printer to &plik
endif
*w=prow()+zrow
w=prow()
pion_przes(zrow)
lw1=w
k=zcol
w=w+28
if len(alltrim(zrmua_mies))=1
  zrmua_mies=stuff("00",2,1,alltrim(zrmua_mies))
endif
if zpzasadn#0
  @ w,k+5 say "Wyn. zasadnicze"
  @ w,k+25 say szertekst(lstart_day,.f.)
  @ w,k+29 say szertekst(zrmua_mies,.f.)  
  @ w,k+33 say szertekst(zrmua_rok,.f.)  
  @ w,k+43 say szertekst(lend_day,.f.)
  @ w,k+47 say szertekst(zrmua_mies,.f.)  
  @ w,k+51 say szertekst(zrmua_rok,.f.)  
  @ w,k+60 say szerkrop(str(zpzasadn,9,2),.f.)  
  w=w+2
endif
if zpdodatek#0
  @ w,k+5 say "Dodatek"
  @ w,k+25 say szertekst(lstart_day,.f.)
  @ w,k+29 say szertekst(zrmua_mies,.f.)  
  @ w,k+33 say szertekst(zrmua_rok,.f.)  
  @ w,k+43 say szertekst(lend_day,.f.)
  @ w,k+47 say szertekst(zrmua_mies,.f.)  
  @ w,k+51 say szertekst(zrmua_rok,.f.)  
  @ w,k+60 say szerkrop(str(zpdodatek,9,2),.f.)
  w=w+2
endif
if zppremia#0
  @ w,k+5 say "Premia"
  @ w,k+25 say szertekst(lstart_day,.f.)
  @ w,k+29 say szertekst(zrmua_mies,.f.)  
  @ w,k+33 say szertekst(zrmua_rok,.f.)  
  @ w,k+43 say szertekst(lend_day,.f.)
  @ w,k+47 say szertekst(zrmua_mies,.f.)  
  @ w,k+51 say szertekst(zrmua_rok,.f.)  
  @ w,k+60 say szerkrop(str(zppremia,9,2),.f.)
  w=w+2
endif
@ lw1+48,k+58 say szerkrop(str(zpzasadn+zpdodatek+zppremia,10,2),.f.)
@ lw1+51,k+5 say szertekst(dat_(zrmdat),.t.)

eject
set device to screen
RETURN .t.




FUNCTION RNA_ADRUK(pa_strona,pmod)
local lw1,lstart_day:="01",lend_day:=lastday(val(zrmua_mies))
local select:=select(),lkod:="",lkod_num:=val(alltrim(substr(zpuwagi,10,2)))
local lmonth,lsum:=0
local llicz_d32:=plicz_d32(),llicz_d7:=plicz_d7()
if month(zpstart)=val(zrmua_mies).and.year(zpstart)=year(date())
  lstart_day=txt_day(zpstart)
endif
if month(zpend)=val(zrmua_mies).and.year(zpstart)=year(date())
  lend_day=txt_day(zpend)
endif
lkod=kod_tytulu(lkod_num)
select &select
zlicz()
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rna_a.txt"
  set printer to &plik
endif
if.not.pmod=="rca_2"
  *w=prow()+zrow
  w=prow()
  pion_przes(zrow)  
endif  
k=zcol
if pa_strona    
  rna_plat()
else
  w=w+1  
endif
@ w,k+5 say szertekst(zpnazwisko,.t.)
w=w+2
@ w,k+5 say szertekst(zpimie1,.t.)
if.not.empty(zppesel)
  @ w,k+50 say "P"
  @ w,k+54 say szertekst(zppesel,.t.)
endif
w=w+3
@ w,k+5 say szertekst(lkod,.t.)
@ w,k+62 say etat_(zpetat) 
w=w+3
@ w,k+16 say szerkrop(str(plicz_d7(),9,2),.f.)
@ w,k+42 say szerkrop(str(plicz_d7(),9,2),.f.)
@ w,k+60 say szerkrop(str(plicz_d13(),9,2),.f.)
w=w+2
@ w,k+10 say szerkrop(str(plicz_d9(),8,2),.f.)
@ w,k+26 say szerkrop(str(plicz_d10(),8,2),.f.)
@ w,k+44 say szerkrop(str(plicz_d11(),8,2),.f.)
@ w,k+62 say szerkrop(str(plicz_da30(),8,2),.f.)
w=w+2
@ w,k+10 say szerkrop(str(plicz_d9(),8,2),.f.)
@ w,k+26 say szerkrop(str(plicz_d10(),8,2),.f.)
@ w,k+44 say szerkrop(str(plicz_d31(),8,2),.f.)
w=w+2
@ w,k+60 say szerkrop(str(llicz_d32,9,2),.f.)
w=w+3
@ w,k+17 say szertekst(lo_rodz(),.f.)
@ w,k+34 say szerkrop(str(zpzasilek,8,2),.f.)
w=w+2
@ w,k+17 say szertekst(lo_piel(),.f.)
 @ w,k+34 say szerkrop(str(zpzas_inne,8,2),.f.)
@ w,k+62 say szerkrop(str(zpzasilek+zpzas_inne,8,2),.f.)
if substr(pmod,1,3)=="rna"
  w=w+3
  @ w,k+25 say szertekst(lstart_day,.f.)
  @ w,k+29 say szertekst(zrmua_mies,.f.)  
  @ w,k+33 say szertekst(zrmua_rok,.f.)  
  @ w,k+43 say szertekst(lend_day,.f.)
  @ w,k+47 say szertekst(zrmua_mies,.f.)  
  @ w,k+51 say szertekst(zrmua_rok,.f.)  
  @ w,k+60 say szerkrop(str(llicz_d7,9,2),.f.)  
  lsum=llicz_d32+llicz_d7+zpzasilek+zpzas_inne
  w=w+20
  if pa_strona
    @ w,k+20 say szerkrop(str(lsum,11,2),.f.)  
  else
    @ w,k+21 say szerkrop(str(lsum,11,2),.f.)  
  endif	
  @ w,k+60 say szerkrop(str(llicz_d7,9,2),.f.)  
  w=w+3
*  @ w,k+5 say szertekst(dtoc(zrmdat),.f.)  
endif	
if.not.substr(pmod,1,3)=="rca"
  if pa_strona
    eject
  else
    dat_druk(0,5)
  endif	
else
  stron_sum=stron_sum+llicz_d32+zpzasilek+zpzas_inne
endif  
set device to screen

RETURN



FUNCTION RNA_WLADRUK(pmod)
local select:=select(),lkod:=space(9),lkod_num:=zwl_kodnum,llicz
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rna_a.txt"
  set printer to &plik
endif
lkod=kod_tytulu(lkod_num)
select &select
*w=prow()+zrow
w=prow()
pion_przes(zrow)
k=zcol
rna_plat()
@ w,k+5 say szertekst(zrmnazwisko,.t.)
w=w+2
@ w,k+5 say szertekst(zrmimie,.t.)
if.not.empty(zfpesel)
  @ w,k+50 say "P"
  @ w,k+54 say szertekst(zfpesel,.t.)
endif
w=w+3
@ w,k+5 say szertekst(lkod,.t.)
**
w=w+3
@ w,k+16 say szerkrop(str(zlpodstawp,9,2),.f.)
@ w,k+42 say szerkrop(str(zlpodstawp,9,2),.f.)
@ w,k+60 say szerkrop(str(zlpod_zdrow,9,2),.f.)
w=w+2
llicz_sum=0
llicz=kj_round(zlpodstawp*((2*zlsk_emeryt)/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+10 say szerkrop(str(llicz,8,2),.f.)
*llicz=kj_round(zlpodstawp*((2*zlsk_rent)/100),2)
llicz=kj_round(zlpodstawp*((zlsk_rentp+zlsk_rentu)/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+26 say szerkrop(str(llicz,8,2),.f.)
llicz=kj_round(zlpodstawp*(zlsk_chorob/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+44 say szerkrop(str(llicz,8,2),.f.)
llicz=kj_round(zlpod_zdrow*(zlsk_zdrow/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+62 say szerkrop(str(llicz,8,2),.f.)
w=w+2
llicz=kj_round(zlpodstawp*(zlsk_wypad/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+44 say szerkrop(str(llicz,8,2),.f.)
w=w+2
@ w,k+60 say szerkrop(str(llicz_sum,9,2),.f.)
**
if pmod=="rna"
  w=w+28
  @ w,20 say szerkrop(str(llicz_sum,11,2),.f.)
  eject
endif  
if substr(pmod,1,3)=="rca"
  stron_sum=llicz_sum
endif
set device to screen
RETURN



FUNCTION RNA_WSADRUK(pa_strona,pwspol,pmod)
local select:=select(),lkod:=space(9),lkod_num,lnazwisko,limie,ltyp,liden
local lstaw,lstaw_zdrow
if pwspol=1
  lnazwisko=zw1_naz
  limie=zw1_imie
  ltyp=zw1_typ
  liden=zw1_iden
  lkod_num=zw1_kodnum
  lstaw=zlpodstaw1
  if.not.zlpodstaw1=0
    lstaw_zdrow=zlpod_zdrow
  endif	
else
  lnazwisko=zw2_naz
  limie=zw2_imie
  ltyp=zw2_typ
  liden=zw2_iden
  lkod_num=zw2_kodnum
  lstaw=zlpodstaw2
  lstaw_zdrow=lstaw
endif
lkod=kod_tytulu(lkod_num)
select &select
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rna_a.txt"
  set printer to &plik
endif
if.not.pmod=="rca_2"
  *w=prow()+zrow
  w=prow()
  pion_przes(zrow)  
endif  
k=zcol
if pa_strona
  rna_plat()
else
  w=w+1
endif    
@ w,k+5 say szertekst(lnazwisko,.t.)
w=w+2
@ w,k+5 say szertekst(limie,.t.)
if.not.empty(liden)
  @ w,k+50 say "P"
  @ w,k+54 say szertekst(liden,.t.)
endif
w=w+3
@ w,k+5 say szertekst(lkod,.t.)
**
w=w+3
@ w,k+16 say szerkrop(str(lstaw,9,2),.f.)
@ w,k+42 say szerkrop(str(lstaw,9,2),.f.)
@ w,k+60 say szerkrop(str(lstaw_zdrow,9,2),.f.)
w=w+2
llicz_sum=0
llicz=kj_round(lstaw*(zlsk_chorob/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+44 say szerkrop(str(llicz,8,2),.f.)
llicz=kj_round(lstaw_zdrow*(zlsk_zdrow/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+62 say szerkrop(str(llicz,8,2),.f.)
w=w+2


llicz=kj_round(lstaw*((2*zlsk_emeryt)/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+10 say szerkrop(str(llicz,8,2),.f.)
*llicz=kj_round(lstaw*((2*zlsk_rent)/100),2)
llicz=kj_round(lstaw*((zlsk_rentp+zlsk_rentu)/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+26 say szerkrop(str(llicz,8,2),.f.)




llicz=kj_round(lstaw*(zlsk_wypad/100),2)
llicz_sum=llicz_sum+llicz
@ w,k+44 say szerkrop(str(llicz,8,2),.f.)
w=w+2
@ w,k+60 say szerkrop(str(llicz_sum,9,2),.f.)
**
if pmod=="rna"
  w=w+28
  if pa_strona
    @ w,20 say szerkrop(str(llicz_sum,11,2),.f.)
  else
    @ w,21 say szerkrop(str(llicz_sum,11,2),.f.)
  endif	  
*  @ w,20 say szerkrop(str(llicz_sum,11,2),.f.)
endif  
if.not.substr(pmod,1,3)=="rca"
  if pa_strona
    eject
  else
    dat_druk(3,5)
  endif	
else
  stron_sum=stron_sum+llicz_sum
endif  
set device to screen

RETURN



FUNCTION TXT_DAY(pdata)
local ltxtday:="00",lday:=day(pdata)
if lday<10
  ltxtday=stuff(ltxtday,2,1,str(lday,1))
else
  ltxtday=stuff(ltxtday,1,2,str(lday,2))
endif
RETURN ltxtday

FUNCTION TXT_MONTH(pnum)
local ltxt:="00",lmon:=pnum
if lmon<10
  ltxt=stuff(ltxt,2,1,str(lmon,1))
else
  ltxt=stuff(ltxt,1,2,str(lmon,2))
endif
RETURN ltxt


FUNCTION RMUA_ZEST()
local ilosc:=1,k:=1,plik:="wydruki\nowy.txt"
if.not.set_zest()
  return
endif
if.not.zlista_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rmua_zes.txt"
  set printer to &plik
endif
select 0
prac_use(zmiesiac)
vcol=5
*zdrabat=15
strona=1
stro=.f.

w=prow()
zest_tyt(.t.)  
lp=0
go top
do while.not.eof()
  p_lad()
  lp=lp+1
  w=w+1
  if w>60
    strona=strona+1
	eject
	w=prow()
	*lp_tyt(.t.)  
	zest_tyt(.t.)  
    w=w+1
  endif
  prac_zest_druk()
  skip
enddo
w=w+3
@ w,0 say "Sporzadzil:  "+zsporzadzil
w=w+1
@ w,40 say "........................."
w=w+1
@ w,40 say "        podpis            " 
eject
set device to screen
use
set printer to
RETURN nil
RETURN nil


FUNCTION PRAC_ZEST_DRUK()
@ w,0 say "|"
@ w,6 say alltrim(zpnazwisko)+"  "+alltrim(zpimie1)
@ w,76 say "|"
w=w+1
@ w,0 say "|"
@ w,1 say lp picture "999"
@ w,11 say zppesel
@ w,76 say "|"
w=w+1
@ w,0 say "|===========================================================================|"
RETURN NIL


FUNCTION ZEST_TYT(ptabelka)
@ w,0 say &zdr_kkond
@ w,0 say alltrim(zfnaz1)
@ w,50 say "Za miesiac"
@ w,61 say zmies_nazwa
w=w+1
*@ w,0 say alltrim(zfnaz2)
@ w,50 say "Data "
@ w,58 say zdata_zest
w=w+2
@ w,20 say "Z E S T A W I E N I E    NR"

@ w,48 say znum_zest
w=w+1
@ w,20 say "------------------------------------"
w=w+2
@ w,0 say " LISTA PRACOWNIKOW OTRZYMUJACYCH RAPORT RMUA ZA OKRES "+str(zmiesiac,2)+"/"+str(year(date()),4) 
if strona>0
  w=w+1
  @ w,60 say "Strona:"
  @ w,68 say strona picture "999"
endif  
w=w+2
if ptabelka
  @ w,0 say "============================================================================="
  w=w+1
  @ w,0 say "| Lp.|    Pracownik       |   POTWIERDZENIE   OTRZYMANIA   RAPORTU   RMUA   |"
  w=w+1
  @ w,0 say "|    |Nazwisko/Imie/Pesel |        p o d p i s   p r a c o w n i k a        |"   
  w=w+1
  @ w,0 say "|====|====================|=================================================|"
endif
RETURN nil

FUNCTION SET_ZEST()
local select:=select(),ek,lcolor:=setcolor(),lsukces:=.t.
public znum_zest,zsporzadzil,zdata_zest
znum_zest=stuff(space(15),1,len(alltrim(str(zmiesiac))),alltrim(str(zmiesiac)))
znum_zest=stuff(znum_zest,3,1,"/")
znum_zest=stuff(znum_zest,4,2,substr(str(year(date())),4))
zsporzadzil=space(20)
zdata_zest:=date()
prac_default()
select 0
save screen to ek
kj_okno(14,15,9,"                P A R A M E T R Y                 ",1)
@ 17,17 say "Sporzadzil ...."
@ 19,17 say "Data ....... .."
@ 21,17 say "Nr zestawienia "
set cursor on
@ 17,32 get zsporzadzil
@ 19,32 get zdata_zest
@ 21,32 get znum_zest   
read
set cursor off
if lastkey()=27
 lsukces=.f.
endif
use
select &select
restore screen from ek
setcolor(lcolor)
RETURN lsukces

FUNCTION KOD_TYTULU(pnum)
local lkod_tytulu:=space(9)
set default to lpset
select 0
if file("ub_kod.dbf")
  if kj_use("ub_kod",.f.,3)
    locate for num=pnum
	if found()
	  lkod_tytulu=kod
	endif  
  endif
  use
endif
prac_default()
RETURN lkod_tytulu

FUNCTION RNA_PLAT()
  @ w,k+26 say szertekst(znum_deklar,.t.)       &&Nume deklaracji
  @ w,k+32 say szertekst(zrmua_mies,.t.)
  @ w,k+36 say szertekst(zrmua_rok,.t.)
  @ w,k+62 say szertekst(str(vstr,3),.f.) 
  w=w+3 
  @ w,k+5 say szertekst(nip_(zfnip),.t.)
  @ w,k+38 say szertekst(zfregon,.t.)
  w=w+2
  @ w,k+5 say szertekst(zfpesel,.t.)
  w=w+2
  @ w,k+5 say szertekst(zrmnazwa,.t.)
  w=w+2
  @ w,k+5 say szertekst(zrmnazwisko,.t.)
  w=w+2
  @ w,k+5 say szertekst(zrmimie,.t.)
  @ w,k+50 say szertekst(dat_(zrmdata_ur),.t.)
  w=w+3
RETURN nil

FUNCTION STRONSUM_DRUK(p_end)
k=zcol
  if start_druk()
    set device to printer
  else
    return
  endif
@ w,k+60 say szerkrop(str(stron_sum,9,2),.f.)
if p_end
  eject
endif  
set device to screen
RETURN nil

FUNCTION DAT_DRUK(prow,pcol)
local ldat:=space(8),ld:=dtos(zrmdat)
ldat=stuff(ldat,1,2,substr(ld,7,2))
ldat=stuff(ldat,3,2,substr(ld,5,2))
ldat=stuff(ldat,5,4,substr(ld,1,4))
k=zcol
  if start_druk()
    set device to printer
  else
    return
  endif
@ w+prow,k+pcol say szertekst(ldat,.f.)
eject
set device to screen
RETURN nil

FUNCTION PION_PRZES(pile)
@ prow(),pcol() say &zdr_8w
for i=1 to pile
  @ w,pcol() say ""
  w=w+1
next
@ prow(),pcol() say &zdr_6w
RETURN

FUNCTION DRA_ADRUK()
local l4_01:=z4_04+z4_07,l4_02:=z4_05+z4_08
local l4_03:=l4_01+l4_02,l4_06:=z4_04+z4_05
local l4_09:=z4_07+z4_08,l4_19:=z4_22,l4_20:=z4_23+z4_25
local l4_21:=l4_19+l4_20,l4_24:=z4_22+z4_23,l4_26:=z4_25
local l4_32:=l4_06+l4_09+l4_24+l4_26
local l5_05:=z5_01+z5_02+z5_03+z5_04
local l6_01:=l5_05-l4_32
local l6_02:=l4_32-l5_05
local l7_04:=z7_01, l8_03:=z8_01+z8_02 
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rna_a.txt"
  set printer to &plik
endif
w=prow()
pion_przes(zrow)
k=zcol
*
  @ w,k+5 say ztermin
  @ w,k+39 say szertekst(znum_deklar,.t.)       &&Nume deklaracji
  @ w,k+45 say szertekst(zrmua_mies,.t.)
  @ w,k+49 say szertekst(zrmua_rok,.t.)
  w=w+5 
  @ w,k+5 say szertekst(nip_(zfnip),.t.)
  @ w,k+39 say szertekst(zfregon,.t.)
  w=w+2
  @ w,k+5 say szertekst(zfpesel,.t.)
  w=w+2
  @ w,k+5 say szertekst(zrmnazwa,.t.)
  w=w+2
  @ w,k+5 say szertekst(zrmnazwisko,.t.)
  w=w+2
  @ w,k+5 say szertekst(zrmimie,.t.)
  @ w,k+50 say szertekst(dat_(zrmdata_ur),.t.)
  w=w+3
*
@ w,k+5 say szertekst(alltrim(str(z3_01,6)),.f.)
@ w,k+21 say szerkrop(str(z3_02,9,2),.f.)
@ w,k+68 say szerkrop(str(zlsk_wypad,4,2),.f.)
w=w+5
if l4_01>0
  @ w,k+13 say szerkrop(str(l4_01,11,2),.f.)
endif  
if l4_02>0
  @ w,k+34 say szerkrop(str(l4_02,11,2),.f.)
endif    
if l4_03>0
  @ w,k+56 say szerkrop(str(l4_03,11,2),.f.)
endif    
w=w+3
if z4_04>0
  @ w,k+13 say szerkrop(str(z4_04,11,2),.f.)
endif  
if z4_05>0  
  @ w,k+34 say szerkrop(str(z4_05,11,2),.f.)
endif  
if l4_06>0
  @ w,k+56 say szerkrop(str(l4_06,11,2),.f.)
endif    
w=w+2
if z4_07>0
  @ w,k+13 say szerkrop(str(z4_07,11,2),.f.)
endif  
if z4_08>0  
  @ w,k+34 say szerkrop(str(z4_08,11,2),.f.)
endif  
if l4_09>0  
  @ w,k+56 say szerkrop(str(l4_09,11,2),.f.)
endif    
w=w+10
if l4_19>0
  @ w,k+13 say szerkrop(str(l4_19,11,2),.f.)
endif  
if l4_20>0  
  @ w,k+34 say szerkrop(str(l4_20,11,2),.f.)
endif  
if l4_21>0  
  @ w,k+56 say szerkrop(str(l4_21,11,2),.f.)
endif    
w=w+3
if z4_22>0
  @ w,k+13 say szerkrop(str(z4_22,11,2),.f.)
endif  
if z4_23>0  
  @ w,k+34 say szerkrop(str(z4_23,11,2),.f.)
endif  
if l4_24>0  
  @ w,k+56 say szerkrop(str(l4_24,11,2),.f.)
endif    
w=w+2
if z4_25>0  
  @ w,k+34 say szerkrop(str(z4_25,11,2),.f.)
endif  
if l4_26>0  
  @ w,k+56 say szerkrop(str(l4_26,11,2),.f.)
endif    
w=w+6
if l4_32>0
  @ w,k+54 say szerkrop(str(l4_32,12,2),.f.)
endif    
w=w+3
if z5_01>0
  @ w,k+21 say szerkrop(str(z5_01,11,2),.f.)
endif  
if z5_03>0  
  @ w,k+56 say szerkrop(str(z5_03,11,2),.f.)
endif    
w=w+2
if z5_02>0
  @ w,k+21 say szerkrop(str(z5_02,11,2),.f.)
endif  
if z5_04>0  
  @ w,k+56 say szerkrop(str(z5_04,11,2),.f.)
endif    
w=w+2
if l5_05>0
  @ w,k+54 say szerkrop(str(l5_05,12,2),.f.)
endif    
w=w+3
if l6_01>=0
  @ w,k+19 say szerkrop(str(l6_01,12,2),.f.)
endif  
if l6_02>=0
  @ w,k+54 say szerkrop(str(l6_02,12,2),.f.)
endif  

eject
set device to screen
RETURN nil

FUNCTION DRA_BDRUK()
local l7_04:=z7_01, l8_03:=z8_01+z8_02 
local l6_02:=z4_04+z4_05+z4_07+z4_08+z4_22+z4_23+z4_25-(z5_01+z5_02+z5_03+z5_04)
local l9_01
if l6_02<0
  l6_02=0
endif
l9_01=l6_02+l7_04+l8_03
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rna_a.txt"
  set printer to &plik
endif
w=prow()
pion_przes(zrow)
k=zcol
*
w=w+1
@ w,k+25 say szerkrop(str(z7_01,9,2),.f.)
w=w+4
if l7_04>0
  @ w,k+60 say szerkrop(str(l7_04,9,2),.f.)
endif  
w=w+3
if z8_01>0
  @ w,k+25 say szerkrop(str(z8_01,9,2),.f.)
endif  
w=w+2
if z8_02>0
  @ w,k+25 say szerkrop(str(z8_02,9,2),.f.)
endif  
if l8_03>0
  @ w,k+60 say szerkrop(str(l8_03,9,2),.f.)
endif    
w=w+4
if l9_01>0
  @ w,k+60 say szerkrop(str(l9_01,9,2),.f.)
endif  
w=w+10
if z11
  @ w,k+23 say szertekst(z11_01,.t.)
  w=w+2
  @ w,k+25 say szerkrop(str(zlpodstawp,9,2),.f.)
  w=w+2
  @ w,k+25 say szerkrop(str(zlpodstawp,9,2),.f.)
  w=w+2
  @ w,k+25 say szerkrop(str(zlpod_zdrow,9,2),.f.)    
else
  w=w+6
endif
w=w+16
dat_druk(0,5)
eject
set device to screen
RETURN nil


*******************************************************************************
*LP_PRAC                                                                      *
*******************************************************************************

************************PRACOWNIK
******************************************************************************
* Moduà obsàugi kontrahenta                                                  *
* psciezka: katalog z plikami pokno=.t.:kontrahent w oknie                   *
* ptxt:tekstowa postaÜ klucza do szukania, pklucz: =1/po nazwie              *
* =2/po nipie =3/po numerze ,pksiega=.t.: wersja z kr¢tsz• nazw•             *
* ptryb=1 - aktualizacja plikow lokalnych na biezaco                         *
* ptryb=2 - aktualizacja plikow lokalnych wymuszana                          *
******************************************************************************
FUNCTION PRACOWNIK(psciezka,pokno,ptxt,pklucz,pksiega,ptryb)
local ek,lsukces,select:=select(),t[9],q[9],to[3],qo[3],ltyt:=space(80)
public enter:=.f.,fwar:=".t."
public f_nip:=space(15),f_naz1:=space(30),f_naz2:=space(30),f_miasto:=space(30)
public f_ulica:=space(30),f_grupa:=space(5),f_odebral:=space(30)
public vmenu_end:=.f.
private klucz:=pklucz,okno:=pokno,k_sciezka:=space(100)
private k_w:=0,k_k:=0
*if zsiec.and.zk_siec
*  siec=.t.
*endif
*@ 0,0 SAY MEMORY(0)
*@ 1,0 SAY MEMORY(1)
*@ 2,0 SAY MEMORY(2)
*INKEY(0)
t[1]:="pnazwisko"
t[2]:="pimie1"
t[3]:="ppesel"
t[4]:="pzasadn"
t[5]:="pdodatek"
t[6]:="ppremia"
t[7]:="pza_chor"
t[8]:="pkoszty"
t[9]:="pkw_wolna"
q[1]:="Nazwisko"
q[2]:="Imie"
q[3]:="Pesel"
q[4]:="Placa zas."
q[5]:="Dodatek"
q[6]:="Premia"
q[7]:="Za chorobe"
q[8]:="Koszty"
q[9]:="Kwota wol."
select 0
**
ltyt=stuff(ltyt,20,23,"LISTA PLAC ZA MIESIAC :")
ltyt=stuff(ltyt,50,len(alltrim(zmies_nazwa)),alltrim(zmies_nazwa))
kj_okno(0,0,24,ltyt,1)
p_menu(1,.f.)
*set default to pracow
prac_default()
*@ 0,0 SAY ALIAS()
*INKEY(0)
lsukces=prac_use(zmiesiac)
prac_sel=select()
if.not.lsukces
  select &select
  return nil
endif
save screen to ek
setcolor("n/w,w/n") 
keyboard chr(205)
**
setcolor("n/w,w/n") 
do while.t.
  do skom with "[Tab]-MENU    Klawisze aktywne:{ S,D,P,U,K,R }  [Enter]-zatw. [Esc]-rezygn."
  set color to g/gr+ 
  @ 3,1 say replicate("∞",78)
  setcolor("n/w,w/n") 
  dbedit(4,1,19,78,t,"LP_FU","",q,"ﬂ")
  if vmenu_end
    exit
  endif
enddo
select &prac_sel
use
restore screen from ek
RETURN NIL




FUNCTION L_MENU(ppoz1,pster)
local topis[10],ek
local lbelka:="∞ Szukaj ∞ Wpisz kwoty ∞ dRukuj liste plac ∞  [Tab]∞[Esc]∞"
local lliter:="  S        W              R                               "
topis[1]:="Szukaj pracownika po nazwie"
topis[2]:="Wpisz kwoty: placa, dodatek, premia, chorobowe, koszty, kwota wolna"
topis[3]:="Wydrukuj liste plac na drukarce domyslnej"
topis[4]:="Powrot z menu do tabeli"
topis[5]:="Wyjdz do poprzedniego menu"
if ppoz1=0
  ppoz1=1
endif
if pster
    ppoz1=menu_poziom(1,0,5,lbelka,lliter,topis,ppoz1,.f.,.f.)
else
   plac_tlo()
    ppoz1=menu_poziom(1,0,5,lbelka,lliter,topis,ppoz1,.t.,.f.)
endif
RETURN ppoz1





FUNCTION P_FUL_ENTER()
local recno:=recno(),ek,lcolor:=setcolor()
k_w=3
k_k=29
save screen to ek
p_dop_tlo()
p_say()
do tkom with "Nacisnij dowolny klawisz."
restore screen from ek
setcolor(lcolor)
RETURN (NIL)		

*******************************************************************************
* Opisz pomocniczy biezacego kontrahenta                                      *
*******************************************************************************
FUNCTION L_OKNOPOM()
local lcolor:=setcolor()
  set color to GR+
  @ 20,1 say replicate(chr(176),78)
  @ 21,54 say "∞"
  @ 22,54 say "∞"
  @ 23,54 say "∞"
  set color to
  @ 21,2 say "Nazwa (cd).."
  @ 22,2 say "Adres : ...."
  @ 21,15 say zknaz2
  @ 23,6 say zkkod
  @ 22,15 say zkulica
  @ 23,15 say zkmiasto
  @ 21,55 say " Tel...."
  @ 22,55 say " Fax...."
  @ 23,55 say " Grupa ."
  @ 21,64 say zktel
  @ 22,64 say zkfax
  @ 23,64 say zkgrupa
setcolor(lcolor)
RETURN NIL




FUNCTION LP_NEW(pmiesiac)
local prac_sel,prac_last
if pmiesiac>1
  prac_default()
  select 0
  lsukces=prac_use(pmiesiac)
  prac_sel=select()
  if.not.lsukces
    return .f.
  endif
  if lastrec()=0.and.kj_gkom(12," Uwaga ! ","Otwieram nowy miesiac na bazie miesiaca poprzedniego.","Wykonac ?",.t.,5)
    select 0
    lsukces=prac_use(pmiesiac-1)
    prac_last=select()
    if.not.lsukces
      return .f.
    endif
    do while.not.eof()
      p_lad()
	  select &prac_sel
	  append blank
      p_replac()
	  pk_replac()
	  select &prac_last	    
      skip
    enddo
  endif
  close_all("LP")
endif
RETURN .t.

FUNCTION P_DEFAULT()
set default to
*set default to pracow
prac_default()
RETURN

FUNCTION PRAC_BYL()
local lbyl:=.t.,select:=select(),lrecno:=recno()
if zmiesiac>1
  select 0
  prac_use(zmiesiac-1)
  locate for pnumer=zpnumer
  if.not.found()
	lbyl=.f.
  endif
  use  
endif
select &select
go lrecno
RETURN lbyl


FUNCTION P_FULL_TLO()
local ltytul:="                      S P I S     P R A C O W N I K O W                         "  
clear
kj_okno(0,0,24,ltytul,1)
set color to
@ 20,1 clear to 23,78
@ 20,1 say replicate(chr(176),78)
RETURN nil


FUNCTION P_MENU(ppoz1,pster)
local topis[10],ek
local lbelka:="∞ Szukaj ∞ Dopisz ∞ Uzupelnij ∞ Popraw ∞ Kasuj ∞ dRukuj ∞[Esc]∞"
local lliter:="  S        D        U           P        K        R                   "
topis[1]:="Szukaj pracownika po nazwie"
topis[2]:="Dopisz nowego pracownuka"
topis[3]:="Uzupelnij dane pracownika : Kasa Chorych, ZUS, US, konto, zatrudnienie"
topis[4]:="Popraw podswietlona pozycje"
topis[5]:="Kasuj podswietlona pozycje"
topis[6]:="Wydruki indywidualne"
topis[7]:="Powrot z menu do tabeli"
*topis[8]:="Wyjdz do poprzedniego menu"
if ppoz1=0
  ppoz1=1
endif
if pster
  ppoz1=menu_poziom(1,1,7,lbelka,lliter,topis,ppoz1,.f.,.f.)
else
  plac_tlo()
  ppoz1=menu_poziom(1,1,7,lbelka,lliter,topis,ppoz1,.t.,.f.)
endif
RETURN ppoz1



FUNCTION LP_FU(tryb,numer)
local last:=lastkey(),lpoz:=1,lpoz_pom:=1,recno:=recno(),topis[8],lind:=1
topis[1]:="Podaj nazwe kontrahenta"
topis[2]:="Podaj NIP kontrahenta"
topis[3]:="Podaj szukana sekwencje znakow"
topis[4]:="Ustaw warunki filtrujace"
topis[5]:="[Enter]-zatwierdz. aktualnej pozycji  [Ctrl-Enter]-zatwierdz. caàoòci [Esc]-rez."
topis[6]:="Zmiana parametrow pracownika"
topis[7]:="Usuwanie pracownika z kartoteki"
topis[8]:="Wydruk spisu pracownik¢ww"
*@ 0,0 SAY MEMORY(0)
*@ 1,0 SAY MEMORY(1)
*@ 2,0 SAY MEMORY(2)
p_lad()
do skom with "[Tab]-MENU    Klawisze aktywne:{ S,D,P,U,K,R }  [Enter]-zatw. [Esc]-rezygn."
do case
  case last=27
    vmenu_end=.t.	  
    return 0	  
  case last=13
    do skom with topis[5]
    p_lad()
	if p_kwoty(k_w,k_k)
      keyboard chr(205)
	  commit
	  return 2
	else
	  vmenu_end=.t.
      keyboard chr(205)
      return 2	  
	endif  

  case chr(last)$"Ss"
    do skom with topis[1]
	p_naz_szuk()
    keyboard chr(19)
	return 2	  	
  case chr(last)$"Dd"
    do skom with topis[5]
    p_lad()
	if p_dopisz(k_w,k_k)
	  enter=.f.
      keyboard chr(205)
	  return 2
	else
	  vmenu_end=.t.
	  enter=.f.
	  keyboard chr(205)
      return 2	  
	endif  
  case chr(last)$"Uu"
    do skom with topis[5]
    p_lad()	
	p_uzup()
    keyboard chr(205)
	return 2	
  case chr(last)$"Pp"
    do skom with topis[6]
	p_popraw(7,25)
	enter=.f.
    keyboard chr(205)
	return 2
  case chr(last)$"Kk"
    do skom with topis[7]
    skip
	recno=recno()
	skip -1
    p_kasuj()
	keyboard chr(205)
    go recno
	return 2		

  case chr(last)$"Rr"
    do skom with topis[8]
    *karta_druk()
	
	ind_druk()
	
    keyboard chr(205)	
	return 2			
  
  case lastkey()=9
	lpoz=p_menu(lpoz,.t.)
	if lastkey()=27
	  keyboard chr(205)
	  return 2
	endif
	do case
      case lpoz=1
	    p_naz_szuk()
        p_menu(lpoz_pom,.f.) 
        keyboard chr(205)
        return 2
	  case lpoz=2
        p_dopisz(7,25)  		
		keyboard chr(205)
	    return 2		
      case lpoz=3
	    p_lad()
		p_uzup()
      case lpoz=4	  
        p_popraw(7,25)
		keyboard chr(205)
	    return 2		
      case lpoz=5
	    p_kasuj()
		keyboard chr(205)
	    return 2				
      case lpoz=6
        *karta_druk()
		ind_druk()
		keyboard chr(205)
	    return 2						
      case lpoz=7
	    keyboard chr(205)
      case lpoz=7.or.lastkey()=27
        vmenu_end=.t.	  
        return 0	
    endcase
endcase
p_oknopom()
RETURN 1



FUNCTION P_UZUP()
local ek,select:=select(),lcolor:=setcolor(),lmenu:=1
local lkget:=.f.       &&Wynik funkcji k_get()
save screen to ek
do while.t.
  lmenu=prac_menu(lmenu)
  if lastkey()=27
    exit
  endif
  do case
    case lmenu=1
      us_baza(1,.f.)
    case lmenu=2
      us_baza(2,.f.)
    case lmenu=3
      us_baza(3,.f.)	  	  
    case lmenu=4
      pkonto()
    case lmenu=5
      pzatrud()	  
    case lmenu=6
	  pzasilki()
  endcase
enddo
restore screen from ek
RETURN lkget

FUNCTION P_DOPISZ(prow,pcol)
local ek,lnip_byl:=.f.,lnaz_byl:=.f.,lkoncz:=.f.
local select:=select(),lcolor:=setcolor()
local lkget:=.f.       &&Wynik funkcji k_get()
k_w:=3
k_k:=29  
save screen to ek
p_zer()
p_dop_tlo()
if enter
  p_say()
else
  p_zer()
endif  
lkget=p_get(.t.)
if lkget
  if.not.prac_jest()
    select 0
    if kj_use("praclast",.t.,3)
      replace prac_num with prac_num+1
      zpnumer=prac_num
      use
    else
      restore screen from ek
      return .f.
    endif
    select &select
    append blank
    p_replac()
    p_uzup()     
  endif
endif  
restore screen from ek
RETURN lkget

FUNCTION P_POPRAW(prow,pcol)
local ek,lnip_byl:=.f.,lnaz_byl:=.f.,lkoncz:=.f.,lkon_byl:=.f.
local select:=select(),recno:=recno()
k_w:=3
k_k:=29
save screen to ek
p_dop_tlo()
p_say()
*if p_get(.f.).and..not.prac_jest()
if p_get(.f.)
  go recno
  p_replac()
  if zsiec
    select 0
    set default to &k_sciezka
    if kj_use("kon",.t.,3)
      set index to k_num,k_naz,k_nip  
	  seek zknum
	  if found()
	    p_replac()
	  endif	
	  use
    endif	
    select &select
  endif
endif  
restore screen from ek
RETURN (NIL)


FUNCTION P_KASUJ()
local select:=select(),ek,recno:=recno()
save screen to ek
k_w=3
k_k=12
p_dop_tlo()
p_say()
zz=.t.
do gkom with "Usunac ?  [T/N] ",zz
if zz.and.lastkey()#27
  delete
  pack
  go recno
endif
restore screen from ek
RETURN NIL



FUNCTION P_NAZ_SZUK()
local ltxt:=space(30),ek,lcolor:=setcolor(),recno:=recno()
save screen to ek
set color to
@ 21,1 clear to 23,78
@ 22,16 say "Podaj nazwisko:"
set cursor on
@ 22,35 get ltxt picture "@!"
read
set cursor off
if lastkey()#27
  seek alltrim(ltxt)
  if.not.found()
    do tkom with "Pozycja nie odnaleziona.  Nacisnij dowolny klawisz."
	go recno
  endif
endif
restore screen from ek
setcolor(lcolor)
RETURN NIL



FUNCTION P_DOP_TLO()
local ltytul:="             *   P R A C O W N I K   *             "   
local lcolor:=setcolor()
g_tlo()
kj_okno(k_w,k_k,20,ltytul,7)	
set color to gr+	
@ k_w+2,k_k+4 say "Nazwisko ............."  &&28
@ k_w+3,k_k+4 say "Imie pierwsze ........"         &&10
@ k_w+4,k_k+4 say "Imie drugie .........."         &&12
@ k_w+5,k_k+4 say "Data ur. (dd.mm.rr) .."         &&12
@ k_w+6,k_k+4 say "Miejsce urodzenia ...."         &&12
@ k_w+7,k_k+4 say "Imie ojca ............"         &&12
@ k_w+8,k_k+4 say "Imie matki ..........."         &&12
@ k_w+9,k_k+4 say "Pesel ................"          &&12
@ k_w+10,k_k+4 say "Nip .................."          &&12	
@ k_w+11,k_k+4 say "Adres: Miejscowosc ..."          &&12	
@ k_w+12,k_k+4 say "       Ulica ........."          &&12	
@ k_w+13,k_k+4 say "       Numer domu ...."          &&12	
@ k_w+14,k_k+4 say "       Numer lokalu .."          &&12	
@ k_w+15,k_k+4 say "       Kod pocztowy .."          &&12	
@ k_w+16,k_k+4 say "       Poczta ........"          &&12	
@ k_w+17,k_k+4 say "       Gmina ........."          &&12	
@ k_w+18,k_k+4 say "       Wojewodztwo ..."          &&12	
*@ k_w+19,k_k+4 say "Uwagi ................"          &&12	

setcolor(lcolor)
RETURN nil

FUNCTION P_SAY()
local lcolor:=setcolor()
set color to W+	
@ k_w+2,k_k+26 say zpnazwisko
@ k_w+3,k_k+26 say zpimie1
@ k_w+4,k_k+26 say zpimie2
@ k_w+5,k_k+26 say zpdata_ur
@ k_w+6,k_k+26 say SUBSTR(zpmiejsc_ur,1,20)
@ k_w+7,k_k+26 say zpimie_ojca
@ k_w+8,k_k+26 say zpimie_matk
@ k_w+9,k_k+26 say zppesel
@ k_w+10,k_k+26 say zpnip
@ k_w+11,k_k+26 say zpmiejscow
@ k_w+12,k_k+26 say zpulica
@ k_w+13,k_k+26 say zpdom_nr
@ k_w+14,k_k+26 say zplokal_nr
@ k_w+15,k_k+26 say zpkod      
@ k_w+16,k_k+26 say zppoczta   
@ k_w+17,k_k+26 say zpgmina    
@ k_w+18,k_k+26 say zpwojew    
*@ k_w+19,k_k+26 say SUBSTR(zpuwagi,1,20)    

setcolor(lcolor)
RETURN nil



FUNCTION P_GET(pdopisz)
local lcolor:=setcolor(),las,las1,lget,select:=select()
public vrow:=k_w+2
*set confirm off
zk_5=2
zk_24=18
set key 5 to koncz5()
set key 24 to koncz24()
set color to	
set cursor on
do while.t.
  do case
    case vrow=k_w+2
      @ k_w+2,k_k+26 get zpnazwisko picture "@!"
	case vrow=k_w+3  
      @ k_w+3,k_k+26 get zpimie1 picture "@!"
	case vrow=k_w+4  
      @ k_w+4,k_k+26 get zpimie2 picture "@!"
    case vrow=k_w+5	  
      @ k_w+5,k_k+26 get zpdata_ur
	case vrow=k_w+6  
      @ k_w+6,k_k+26 get zpmiejsc_ur picture "@S20!"
	case vrow=k_w+7  
      @ k_w+7,k_k+26 get zpimie_ojca picture "@!"	  
	case vrow=k_w+8  
	  @ k_w+8,k_k+26 get zpimie_matk picture "@!"	  
    case vrow=k_w+9	  
      @ k_w+9,k_k+26 get zppesel
	case vrow=k_w+10  
      @ k_w+10,k_k+26 get zpnip
	case vrow=k_w+11  
      @ k_w+11,k_k+26 get zpmiejscow picture "@!"	  
    case vrow=k_w+12
      @ k_w+12,k_k+26 get zpulica picture "@!"	  
	case vrow=k_w+13  
      @ k_w+13,k_k+26 get zpdom_nr picture "@!"	  
	case vrow=k_w+14  
      @ k_w+14,k_k+26 get zplokal_nr picture "@!"	  
	case vrow=k_w+15  
      @ k_w+15,k_k+26 get zpkod picture "@!"	  
	case vrow=k_w+16  
      @ k_w+16,k_k+26 get zppoczta picture "@!"	    
	case vrow=k_w+17  
      @ k_w+17,k_k+26 get zpgmina picture "@!"	     
	case vrow=k_w+18  
      @ k_w+18,k_k+26 get zpwojew picture "@!"	     
*	case vrow=k_w+19  
*      @ k_w+19,k_k+26 get zpuwagi picture "@S20!"  	  	  	  	  	  
  endcase
  read
  tone(1000,0.5)

  do case
    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
	  exit
	case lastkey()=27.or.(lastkey()=13.and.vrow=k_w+18).or.lastkey()=18
	  exit  
    case lastkey()=13.or.lastkey()=24  &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+2
	    vrow=vrow-1	  
	  endif	
  endcase
  p_say()
enddo
if.not.lastkey()=27
  lget=.t.
else
  lget=.f.
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
*set confirm on
RETURN lget


FUNCTION P_REPLAC()
replace pnazwisko with zpnazwisko,pimie1 with zpimie1,pimie2 with zpimie2
replace pdata_ur with zpdata_ur,pmiejsc_ur with zpmiejsc_ur
replace pimie_ojca with zpimie_ojca,pimie_matk with zpimie_matk
replace ppesel with zppesel,pnip with zpnip,pmiejscow with zpmiejscow
replace pulica with zpulica,pdom_nr with zpdom_nr,plokal_nr with zplokal_nr
replace pkod with zpkod,ppoczta with zppoczta,pgmina with zpgmina
replace pwojew with zpwojew,pgrupa with zpgrupa,pmagazyn with zpmagazyn
replace puwagi with zpuwagi,pnumer with zpnumer
*replace plog_e with .t.,plog_r with .t.,plog_c with .t., plog_z with .t.
*replace pkw_wolna with .t.
replace plog_e with zplog_e, plog_r with zplog_r, plog_c with zplog_c
replace plog_z with zplog_z,pkw_wolna with zpkw_wolna
replace pstart with zpstart,pend with zpend,petat with zpetat
replace pkonto with zpkonto,pkas_kod with zpkas_kod,pus_kod with zpus_kod
replace pzus_kod with zpzus_kod,pstart with zpstart,pend with zpend
replace petat with zpetat
RETURN nil

FUNCTION P_ZER()  
zpnazwisko=space(20)
zpimie1=space(12)
zpimie2=space(12)
zpdata_ur=ctod("  .  .  ")
zpmiejsc_ur=space(30)
zpimie_ojca=space(12)
zpimie_matk=space(12)
zppesel=space(11)
zpnip=space(13)
zpmiejscow=space(20)
zpulica=space(20)
zpdom_nr=space(10)
zplokal_nr=space(10)
zpkod=space(6)
zppoczta=space(20)
zpgmina=space(20)
zpwojew=space(20)
zpzasadn=0
zpdodatek=0
zppremia=0
zpza_chor=0
zpkoszty=0
zpkw_wolna=.t.
zpsk_zycie=0
zpsk_inne=0
zpzasilek=0
zpzas_inne=0
zplog_e=.t.
zplog_r=.t.
zplog_c=.t.
zplog_z=.t.
zpgrupa=space(5)
zpmagazyn=0
zpuwagi=space(30)
zpnumer=0
zpetat=1
zpstart=date()
zpend=ctod(space(8))
zpkonto=space(60)
zpkas_kod=space(3)
zpus_kod=space(3)
zpzus_kod=space(3)
RETURN  nil


FUNCTION P_LAD()  
zpnazwisko=pnazwisko
zpimie1=pimie1
zpimie2=pimie2
zpdata_ur=pdata_ur
zpmiejsc_ur=pmiejsc_ur
zpimie_ojca=pimie_ojca
zpimie_matk=pimie_matk
zppesel=ppesel
zpnip=pnip
zpmiejscow=pmiejscow
zpulica=pulica   
zpdom_nr=pdom_nr  
zplokal_nr=plokal_nr
zpkod=pkod    
zppoczta=ppoczta  
zpgmina=pgmina   
zpwojew=pwojew   
zpzasadn=pzasadn
zpdodatek=pdodatek
zppremia=ppremia
zpza_chor=pza_chor
zpkoszty=pkoszty
zpkw_wolna=pkw_wolna
zpsk_zycie=psk_zycie
zpsk_inne=psk_inne
zpzasilek=pzasilek
zpzas_inne=pzas_inne
zplog_e=plog_e
zplog_r=plog_r
zplog_c=plog_c
zplog_z=plog_z
zpgrupa=pgrupa
zpmagazyn=pmagazyn
zpuwagi=puwagi   
zpnumer=pnumer
zpstart=pstart
zpend=pend
zpetat=petat
zpkonto=pkonto
zpkas_kod=pkas_kod
zpus_kod=pus_kod
zpzus_kod=pzus_kod
RETURN  nil


FUNCTION PZV_LAD()  
zpnazwisko=vpnazwisko
zpimie1=vpimie1
zpimie2=vpimie2
zpdata_ur=vpdata_ur
zpmiejsc_ur=vpmiejsc_ur
zpimie_ojca=vpimie_ojca
zpimie_matk=vpimie_matk
zppesel=vppesel
zpnip=vpnip
zpmiejscow=vpmiejscow
zpulica=vpulica   
zpdom_nr=vpdom_nr  
zplokal_nr=vplokal_nr
zpkod=vpkod    
zppoczta=vppoczta  
zpgmina=vpgmina   
zpwojew=vpwojew   
zpzasadn=vpzasadn
zpdodatek=vpdodatek
zppremia=vppremia
zpza_chor=vpza_chor
zpkoszty=vpkoszty
zpkw_wolna=vpkw_wolna
zpsk_zycie=vpsk_zycie
zpsk_inne=vpsk_inne
zpzasilek=vpzasilek
zpzas_inne=vpzas_inne
zplog_e=vplog_e
zplog_r=vplog_r
zplog_c=vplog_c
zplog_z=vplog_z
zpgrupa=vpgrupa
zpmagazyn=vpmagazyn
zpuwagi=vpuwagi   
zpnumer=vpnumer
zpstart=vpstart
zpend=vpend
zpetat=vpetat
zpkonto=vpkonto
zpkas_kod=vpkas_kod
zpus_kod=vpus_kod
zpzus_kod=vpzus_kod
RETURN  nil

FUNCTION PVZ_LAD()  
vpnazwisko=zpnazwisko
vpimie1=zpimie1
vpimie2=zpimie2
vpdata_ur=zpdata_ur
vpmiejsc_ur=zpmiejsc_ur
vpimie_ojca=zpimie_ojca
vpimie_matk=zpimie_matk
vppesel=zppesel
vpnip=zpnip
vpmiejscow=zpmiejscow
vpulica=zpulica   
vpdom_nr=zpdom_nr  
vplokal_nr=zplokal_nr
vpkod=zpkod    
vppoczta=zppoczta  
vpgmina=zpgmina   
vpwojew=zpwojew   
vpzasadn=zpzasadn
vpdodatek=zpdodatek
vppremia=zppremia
vpza_chor=zpza_chor
vpkoszty=zpkoszty
vpkw_wolna=zpkw_wolna
vpsk_zycie=zpsk_zycie
vpsk_inne=zpsk_inne
vpzasilek=zpzasilek
vpzas_inne=zpzas_inne
vplog_e=zplog_e
vplog_r=zplog_r
vplog_c=zplog_c
vplog_z=zplog_z
vpgrupa=zpgrupa
vpmagazyn=zpmagazyn
vpuwagi=zpuwagi   
vpnumer=zpnumer
vpstart=zpstart
vpend=zpend
vpetat=zpetat
vpkonto=zpkonto
vpkas_kod=zpkas_kod
vpus_kod=zpus_kod
vpzus_kod=zpzus_kod
RETURN  nil




FUNCTION PRAC_USE(pmiesiac)
local lsukces:=.f.
prac_default()
do case
  case pmiesiac=1
    if kj_use("place_01",.t.,3)
      set index to place_01
      lsukces=.t.
	endif  
  case pmiesiac=2
    if kj_use("place_02",.t.,3)
      set index to place_02
	  lsukces=.t.
	endif  
  case pmiesiac=3
    if kj_use("place_03",.t.,3)
      set index to place_03
	  lsukces=.t.
	endif  
  case pmiesiac=4
    if kj_use("place_04",.t.,3)
      set index to place_04
	  lsukces=.t.
	endif  
  case pmiesiac=5
    if kj_use("place_05",.t.,3)
      set index to place_05
	  lsukces=.t.
	endif  
  case pmiesiac=6
    if kj_use("place_06",.t.,3)
      set index to place_06
	  lsukces=.t.
	endif  
  case pmiesiac=7
    if kj_use("place_07",.t.,3)
      set index to place_07
	  lsukces=.t.
	endif  
  case pmiesiac=8
    if kj_use("place_08",.t.,3)
      set index to place_08
	  lsukces=.t.
	endif  
  case pmiesiac=9
    if kj_use("place_09",.t.,3)
      set index to place_09
	  lsukces=.t.
	endif  
  case pmiesiac=10
    if kj_use("place_10",.t.,3)
      set index to place_10
	  lsukces=.t.
	endif  
  case pmiesiac=11
    if kj_use("place_11",.t.,3)
      set index to place_11
	  lsukces=.t.
	endif  
  case pmiesiac=12
    if kj_use("place_12",.t.,3)
      set index to place_12											
	  lsukces=.t.
	endif  
endcase
RETURN lsukces


FUNCTION PRAC_USE1(pmiesiac)
local lsukces:=.f.
do case
  case pmiesiac=1
    lsukces=kj_use("place_01",.t.,3)
    set index to place_01
  case pmiesiac=2
    lsukces=kj_use("place_02",.t.,3)
    set index to place_02
  case pmiesiac=3
    lsukces=kj_use("place_03",.t.,3)
    set index to place_03
  case pmiesiac=4
    lsukces=kj_use("place_04",.t.,3)
    set index to place_04
  case pmiesiac=5
    lsukces=kj_use("place_05",.t.,3)
    set index to place_05
  case pmiesiac=6
    lsukces=kj_use("place_06",.t.,3)
    set index to place_06
  case pmiesiac=7
    lsukces=kj_use("place_07",.t.,3)
    set index to place_07
  case pmiesiac=8
    lsukces=kj_use("place_08",.t.,3)
    set index to place_08
  case pmiesiac=9
    lsukces=kj_use("place_09",.t.,3)
    set index to place_09
  case pmiesiac=10
    lsukces=kj_use("place_10",.t.,3)
    set index to place_10
  case pmiesiac=11
    lsukces=kj_use("place_11",.t.,3)
    set index to place_11
  case pmiesiac=12
    lsukces=kj_use("place_12",.t.,3)
    set index to place_12											
endcase
RETURN lsukces


FUNCTION WYBOR_FIR()
local lnum:=zfnum,t[2],q[2],ek,lcolor:=setcolor()
t[1]:="fnum"
t[2]:="fnaz1"
q[1]:="Numer"
q[2]:="Nazwa firmy"
save screen to ek
do skom with "[PgUp]-wybor        [Enter]-zatwierdzenie numeru firmy "
@ 4,27 to 6,53
@ 5,29 say "Podaj numer firmy:    "
set cursor on
@ 5,48 get lnum picture "999" range 1,zi_lp
read
set cursor off
set default to lpset
if kj_use("lpfirma",.t.,3)
  locate for fnum=lnum
  if.not.lastkey()=18
    if.not.found()
      kj_tkom(11," Uwaga! ","Firma o numerze "+str(lnum,3),"nie zostala zdefiniowana.","Nacisnij dowolny klawisz.",5) 
    else
      fir_lad()
	  use
	  restore screen from ek
	  prac_default()
	  return
    endif
  endif
  g_tlo()
  kj_okno(3,40,20,"             F  I  R  M  A              ",7)
  kj_okno(3,40,18,"             F  I  R  M  A              ",7)  
  do skom with "Dopisz    Popraw    [Enter]-zatwierdz    [Esc]-zrezygnuj"
  keyboard chr(205)
  dbedit(4,41,20,78,t,"FL_FU","",q,"ﬂ")
endif
restore screen from ek
use
prac_default()
RETURN nil

FUNCTION FL_FU(tryb,numer)
local last:=lastkey(),lfnaz1:=space(30),ek
do case
  case last=27
    return 0
  case last=13
    if fnum<=zi_lp    
	  fir_lad()  	
	else
	  kj_tkom(12," Uwaga!","Aktualna instalacja pozwala na obsluge "+str(zi_lp,3)+ " firm.","","Informacje szczegolowe :   Tel. 0 604 219 784",5) 
	endif  
    return 0
  case chr(lastkey())$"Dd"
    save screen to ek
    fir_dopisz()
	if lastkey()#27
	  go bottom
	  zfnum=fnum+1
	  append blank
	  fir_replac()
	endif  
	keyboard chr(205)
	restore screen from ek
  case chr(lastkey())$"Pp"
    save screen to ek
	k_w:=0
    k_k:=0  
    fir_lad()
    fir_dop_tlo()
	fir_say()
	fir_get()
	if lastkey()#27
      fir_replac()
	endif
	restore screen from ek	
endcase
RETURN 1





FUNCTION FIR_REPLAC()
replace fnum with zfnum,fnaz1 with zfnaz1, fnaz2 with zfnaz2,fkod with zfkod
replace fmiasto with zfmiasto,fulica with zfulica,fnip with zfnip
replace fregon with zfregon,fpesel with zfpesel,fkonto with zfkonto
replace skarbowy with zskarbowy,sk_kod with zsk_kod,sk_miasto with zsk_miasto
replace sk_ulica with zsk_ulica,sk_konto with zsk_konto,zus with zzus
replace zus_kod with zzus_kod,zus_miasto with zzus_miasto
replace zus_ulica with zzus_ulica,zus_konto1 with zzus_k1
replace zus_konto2 with zzus_k2,zus_konto3 with zzus_k3
replace zus_konto4 with zzus_k4
RETURN nil




FUNCTION FIR_ZER()
zfnum=0
zfnaz1=space(30)
zfnaz2=space(30)
zfkod=space(6)
zfmiasto=space(30)
zfulica=space(30)
zfnip=space(13)
zfregon=space(10)
zfpesel=space(11)
zfkonto=space(90)
zskarbowy=space(30)
zsk_kod=space(6)
zsk_miasto=space(30)
zsk_ulica=space(30)
zsk_konto=space(90)
zzus=space(30)
zzus_kod=space(6)
zzus_miasto=space(30)
zzus_ulica=space(30)
zzus_k1=space(90)
zzus_k2=space(90)
zzus_k3=space(90)
zzus_k4=space(90)
zwspol_ile=0
zprzelew=""
zpieczec=""
znaz_czlon=""
ztyp_ident=""
ztermin=""
zw1_naz=space(31)
zw1_imie=space(22)
zw1_typ=""
zw1_iden=space(11)
zw1_kodnum=1
zw2_kodnum=1
RETURN


*******************************************************************************
* Tworzy menu uaktywniajace funkcje techniczne programu                       *
*******************************************************************************
FUNCTION PRAC_MENU(ppoz)
local ltnaz[6],ltlit[6],ltopis[6],lbelka:="",lpoz:=ppoz
lbelka=   " DANE UZUPELNIAJACE  "
ltnaz[1]:=" Urzad Skarbowy       "
ltnaz[2]:=" Z U S                "
ltnaz[3]:=" Kasa Chorych         "
ltnaz[4]:=" Konto bankowe        "
ltnaz[5]:=" Zatrudnienie         "
ltnaz[6]:=" zAsilki              "
ltlit[1]:="       S      "
ltlit[2]:=" Z            "
ltlit[3]:="      C       "
ltlit[4]:=" K            "
ltlit[5]:=" Z            "
ltlit[6]:="  A           "
ltopis[1]:="Urzad Skarbowy wlasciwy w sprawie podatku dochodowego pracownika"
ltopis[2]:="Zaklad Ubezpieczen Spolecznych wlasciwy dla pracownika"
ltopis[3]:="Kasa Chorych do ktorej nalezy pracownik"
ltopis[4]:="Konto bankowe pracownika"
ltopis[5]:="Data zatrudnienia, etat, data zwolnienia"
ltopis[6]:="Liczba osob na ktore wyplacany jest zasilek rodzinny i pielegnacyjny"
g_tlo()
save screen to ek
*set color to
*@ 6,24 clear to 14,49
@ 6,24,15,49 box chr(176)
  lpoz=men_pion(7,25,6,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz




FUNCTION PKONTO()
local ek,lcolor:=setcolor()
save screen to ek
kj_okno(16,9,2, "              Nazwa i numer konta bankowego                   ",2)
@ 18,10 say ">"
@ 18,40 say ">"
set cursor on
set color to
@ 17,10 get zpkonto picture "@!"
read 
set cursor off
if lastkey()#27
  replace pkonto with zpkonto	
endif  
restore screen from ek
setcolor(lcolor)
RETURN nil


FUNCTION PZATRUD()
local ek,lcolor:=setcolor(),select:=select()
local ltytul:="",lkod:=""
public ztyt_num:=val(alltrim(substr(zpuwagi,7,2))),zkod_num:=val(alltrim(substr(zpuwagi,10,2)))
save screen to ek
set default to lpset
select 0
if file("ub_tytul.dbf")
  if kj_use("ub_tytul",.f.,3)
    tyt_sel=select()
    locate for num=ztyt_num
	if found()
      ltytul=tytul
	else
	  go top
	endif  
  endif
endif

select 0
if file("ub_kod.dbf")
  if kj_use("ub_kod",.f.,3)
    kod_sel=select()
    locate for num=zkod_num
	if found()
	  lkod=kod
	else
	  go top
	endif  
  endif
endif

kj_okno(12,31,10, "              Zatrudnienie                ",2)
@ 14,34 say "Nazwisko:"
@ 14,44 say zpnazwisko
@ 15,34 say "Imie:"
@ 15,44 say zpimie1
@ 16,34 say "Data rozpoczecia pracy:"
@ 17,34 say "Zatrudnienie w wymiarze       etatu"
@ 18,34 say "Tytul ubezpieczenia:   "+substr(ltytul,1,15)   
@ 19,34 say "Kod tytulu ubezp.  :       "+substr(lkod,1,15)   
@ 20,34 say "Data zakonczenia pracy:"
set cursor on
set color to
@ 16,58 get zpstart when s_kom("Data rozpoczecia pracy w formacie  (dd.mm.rr)")
@ 17,58 get zpetat picture "9.99" when s_kom("Wymiar czasu pracy przeliczony na etaty")
@ 18,54 get ztyt_num picture "99" when tyt_slow()
@ 19,54 get zkod_num  picture "99" when kod_slow(.t.)
@ 20,58 get zpend when s_kom("Data zakonczenia pracy w formacie  (dd.mm.rr)")
read 
set cursor off
select &tyt_sel
use
select &kod_sel
use
prac_default()
select &select
zpuwagi=stuff(puwagi,7,2,str(ztyt_num,2))
zpuwagi=stuff(zpuwagi,9,1,",")
zpuwagi=stuff(zpuwagi,10,2,str(zkod_num,2))
zpuwagi=stuff(zpuwagi,12,1,",")

if lastkey()#27
  replace pstart with zpstart,petat with zpetat,pend with zpend
  replace puwagi with zpuwagi
endif
restore screen from ek
setcolor(lcolor)

RETURN nil


FUNCTION PZASILKI()
local ek,lcolor:=setcolor(),select:=select()
public zrodz_ile:=val(alltrim(substr(zpuwagi,1,2))),zpiel_ile:=val(alltrim(substr(zpuwagi,4,2)))
save screen to ek
kj_okno(12,31,9,"                 Zasilki                  ",2)
@ 14,34 say "Nazwisko:"
@ 14,44 say zpnazwisko
@ 15,34 say "Imie:"
@ 15,44 say zpimie1
@ 17,34 say "Z A S I L E K :" 
@ 18,34 say "Rodzinny  -  liczba osob :"   
@ 18,65 say zrodz_ile picture "99"
@ 19,34 say "Pielegnacyjny - liczba osob :"
@ 19,65 say zpiel_ile picture "99"
set cursor on
set color to
@ 18,65 get zrodz_ile picture "99" when s_kom("Liczba osob na ktore wyplacany jest zasilek rodzinny.")
@ 19,65 get zpiel_ile picture "99" when s_kom("Liczba osob na ktore wyplacany jest zasilek pielegnacyjny.")
read 
set cursor off
zpuwagi=stuff(puwagi,1,2,str(zrodz_ile,2))
zpuwagi=stuff(zpuwagi,3,1,",")
zpuwagi=stuff(zpuwagi,4,2,str(zpiel_ile,2))
zpuwagi=stuff(zpuwagi,6,1,",")

if lastkey()#27
  replace puwagi with zpuwagi
endif
restore screen from ek
setcolor(lcolor)

RETURN nil





FUNCTION P_OKNOPOM()
local lcolor:=setcolor()
set color to g/gr+ 
@ 20,1 say replicate("∞",78)
set color to
@ 21,2 say zpmiejscow
@ 22,2 say zpulica
@ 21,40 say "Kod:  URZEDU SKARBOWEGO ........"
@ 22,40 say "      ZAKLADU UB.SPOLECZNYCH ..."
@ 23,40 say "      KASY CHORYCH ............."
@ 21,73 say zpus_kod
@ 22,73 say zpzus_kod
@ 23,73 say zpkas_kod
setcolor(lcolor)
RETURN nil

FUNCTION FIR_DOPISZ()
local ek,lnip_byl:=.f.,lnaz_byl:=.f.,lkoncz:=.f.
local select:=select(),lcolor:=setcolor()
local lkget:=.f.       &&Wynik funkcji k_get()
k_w:=0
k_k:=0  
save screen to ek
fir_zer()
fir_dop_tlo()
fir_get()
RETURN
 

FUNCTION FIR_DOP_TLO()
local ltytul:="             P A R A M E T R Y     F I R M Y                 "   
local lcolor:=setcolor()
kj_okno(k_w,k_k,18,ltytul,7)	
set color to gr+	
@ k_w+2,k_k+4  say "Nazwa ................"
@ k_w+3,k_k+4  say "Nazwa / cd / ........."
@ k_w+4,k_k+4  say "Nip .................."
@ k_w+5,k_k+4  say "Regon ................"
@ k_w+6,k_k+4  say "Pesel ................"
@ k_w+7,k_k+4  say "Nazwa skr¢cona ......."
@ k_w+8,k_k+4  say "Kraj ................."
@ k_w+9,k_k+4  say "Wojew¢dztwo  ........."
@ k_w+10,k_k+4 say "Powiat ..............."
@ k_w+11,k_k+4 say "Gmina ................"
@ k_w+12,k_k+4 say "Ulica/nr ............."
@ k_w+13,k_k+4 say "MiejscowoòÜ .........."
@ k_w+14,k_k+4 say "Kod pocztowy  ........"
@ k_w+15,k_k+4 say "Poczta ..............."
@ k_w+16,k_k+4 say "Konto bankowe ........"
setcolor(lcolor)
RETURN nil

FUNCTION FIR_GET()
local select:=select(),recno:=recno()
local lcolor:=setcolor(),las,las1,lget,lwspol_ile:=val(substr(zskarbowy,1,1))
local lprzelew:=substr(zskarbowy,2,1), lpieczec:=substr(zskarbowy,3,1)
local lnaz_czlon:=substr(zskarbowy,4,1), ltyp_ident:=substr(zskarbowy,5,1)
local ltermin:=substr(zskarbowy,6,1)
public vrow:=k_w+2
*set confirm off
zk_5=2
zk_24=16
set key 5 to koncz5()
set key 24 to koncz24()
set color to	
set cursor on
do while.t.
  do case
    case vrow=k_w+2
      @ k_w+2,k_k+26 get zfnaz1 picture "@!" when s_kom("[Enter]-zatwierdz.pozycji   [Ctrl-Enter]-zatwierdz.wszystkiego   [Esc]-rezygn.")
	case vrow=k_w+3  
      @ k_w+3,k_k+26 get zfnaz2 picture "@!"	  
	case vrow=k_w+4  
      @ k_w+4,k_k+26 get zfnip picture "@!"  	  	  	  	  	   
    case vrow=k_w+5	  
      @ k_w+5,k_k+26 get zfregon picture "@!"  	  	  	  	  	  
	case vrow=k_w+6  
      @ k_w+6,k_k+26 get zfpesel picture "@!"  	  	  	  	  	  
	case vrow=k_w+7  
      @ k_w+7,k_k+26 get zrmnazwa picture "@!"  	  	  	  	  	  
	case vrow=k_w+8  
      @ k_w+8,k_k+26 get zfkraj picture "@!"  	  	  	  	  	  
	case vrow=k_w+9  
      @ k_w+9,k_k+26 get zfwojewodztwo picture "@!"  	  	  	  	  	  
	case vrow=k_w+10  
      @ k_w+10,k_k+26 get zfpowiat picture "@!"  	  	  	  	  	  
	case vrow=k_w+11  
      @ k_w+11,k_k+26 get zfgmina picture "@!"  
    case vrow=k_w+12	  
      @ k_w+12,k_k+26 get zfulica picture "@!"	  
	case vrow=k_w+13  
	  @ k_w+13,k_k+26 get zfmiasto picture "@!"	  	  	  	  	  	  	  	  	  	  	  	  
	case vrow=k_w+14  
      @ k_w+14,k_k+26 get zfkod picture "@!"  	  	  	  	  	  	  
	case vrow=k_w+15  
      @ k_w+15,k_k+26 get zfpoczta picture "@!"  	  	  	  	  	  	  	  
	case vrow=k_w+16  
      @ k_w+16,k_k+26 get zfkonto  picture "@S30!" when s_kom("[Enter]-zatwierdz.pozycji   [Ctrl-Enter]-zatwierdz.wszystkiego   [Esc]-rezygn.")
  endcase
  read
  tone(1000,0.5)

  do case
    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
      wspol_get()
	  exit
	case lastkey()=27.or.(lastkey()=13.and.vrow=k_w+16).or.lastkey()=18
      wspol_get()
	  exit  
    case lastkey()=13.or.lastkey()=24  &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+2
	    vrow=vrow-1	  
	  endif	
  endcase
  fir_say()
enddo
if.not.lastkey()=27
  lget=.t.
  zzus_k3=stuff(zzus_k3,1,15,zfkraj)
  zzus_k3=stuff(zzus_k3,16,15,zfwojewodztwo)
  zzus_k3=stuff(zzus_k3,31,15,zfpowiat) 
  zzus_k3=stuff(zzus_k3,46,15,zfgmina)
  zzus_k3=stuff(zzus_k3,61,15,zfpoczta)  
  zzus=zrmnazwa
else
  lget=.f.
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
*set confirm on
prac_default()
select &select
RETURN lget


FUNCTION FIR_SAY()
local lcolor:=setcolor()
set color to W+	

@ k_w+2,k_k+26 say zfnaz1 picture "@!"	  
@ k_w+3,k_k+26 say zfnaz2 picture "@!"	  
@ k_w+4,k_k+26 say zfnip picture "@!"  	  	  	  	  	   
@ k_w+5,k_k+26 say zfregon picture "@!"  	  	  	  	  	  
@ k_w+6,k_k+26 say zfpesel picture "@!"  	  	  	  	  	  
@ k_w+7,k_k+26 say zrmnazwa picture "@!"  	  	  	  	  	  
@ k_w+8,k_k+26 say zfkraj picture "@!"  	  	  	  	  	  
@ k_w+9,k_k+26 say zfwojewodztwo picture "@!"  	  	  	  	  	  
@ k_w+10,k_k+26 say zfpowiat picture "@!"  	  	  	  	  	  
@ k_w+11,k_k+26 say zfgmina picture "@!"  	  	  	  	  	  
@ k_w+12,k_k+26 say zfulica picture "@!"	  
@ k_w+13,k_k+26 say zfmiasto picture "@!"	  
@ k_w+14,k_k+26 say zfkod picture "@!"  	  	  	  	  	  
@ k_w+15,k_k+26 say zfpoczta picture "@!"  	  	  	  	  	  
@ k_w+16,k_k+26 say zfkonto  picture "@S30!"
setcolor(lcolor)
RETURN nil





FUNCTION ZLA1_INSTAL()
lzla:=.t.
select 0
set default to leg01
if kj_use("leg01",.f.,3)
  locate for leg_kod="LP010"
  if found()
    lzla=.f.
  endif
  use
endif
RETURN lzla

FUNCTION LICENCJA()
l_licencja:=.f.
select 0
set default to leg01
if kj_use("leg01",.f.,3)
  locate for leg_kod="LP010"
  if found().and.l123.and.lkod=1010
    l_licencja=.t.
  endif
  use
endif
RETURN l_licencja

FUNCTION DEMO_OLD_END()
ldemo_end:=.t.
select 0
set default to leg01
if kj_use("leg01",.t.,3)
  locate for leg_kod="LP010"
  if found().and.(l123.and.lkod=1010.or.((date()-ldat)<=ld.and.lkod=2222))
    ldemo_end=.f.
  else
    replace lkod with 11111
  endif
  use
endif
RETURN ldemo_end

FUNCTION KONCZ_OLD()
set key 24 to
set key 5 to
zkey10=.t.
keyboard chr(3)
RETURN NIL

FUNCTION PRAC_JEST()
local lbyl:=.f.
seek zpnazwisko
if found()
  do while pnazwisko=zpnazwisko
    if pimie1=zpimie1.and.pimie2=zpimie2.and.pdata_ur=zpdata_ur.and.ppesel=zppesel
	  kj_tkom(12," Uwaga! ","Pracownik o tym nazwisku, imionach, dacie urodzenia","oraz numerze PESEL juz istnieje w bazie.","Nie bedzie ponownie wpisany. Nacisnij dowolny klawisz",5)
	  lbyl=.t.
	endif
    skip
  enddo
endif
RETURN lbyl




FUNCTION ZLEG_OLD_LAD()
zlic0=dekod(lic0)
zlic1=dekod(lic1)
zlic2=dekod(lic2)
zlic3=dekod(lic3)
zlic4=dekod(lic4)
zlic5=dekod(lic5)
zlic6=dekod(lic6)
zleg_kod=leg_kod
zlz1=lz1
zlz2=lz2
zlz3=lz3
zl123=l123
zlkod=lkod
zld=ld
zlic_regon=lic_regon
zlic_pesel=lic_pesel
zlic_konto=lic_konto
zlic_tel=lic_tel
zlic_fax=lic_fax
RETURN






FUNCTION TYT_SLOW(pnum)
local lnum:=pnum,ek,lznak:=lastkey(),lcolor:=setcolor()
select &tyt_sel
save screen to ek
set key 24 to
set key 5 to
keyboard chr(205)
dbedit(14,1,22,51,"tytul","TYT1_FU","","Tytul ubezpieczenia" ,"ﬂ")
restore screen from ek
do case
  case lastkey()=13
    ztyt_num=num    	
	set color to n/w,w/n
    @ 18,57 say substr(tytul,1,15)
endcase	
keyboard chr(lznak)
setcolor(lcolor)
*set key 5 to koncz5()
*set key 24 to koncz24()
RETURN .T.

FUNCTION KOD_SLOW(pznak)
local ek,lznak:=lastkey(),lcolor:=setcolor(),t[2],q[2]
t[1]:="kod"
q[1]:="Kod tytulu ubezp."
select &kod_sel
save screen to ek
keyboard chr(205)
kj_okno(13,0,10,"   *   W Y B I E R Z   *   ",1)
set cursor on
keyboard chr(205)
set key 24 to
set key 5 to
dbedit(14,1,22,25,t,"TYT_FU","",q,"ﬂ")
restore screen from ek
do case
  case lastkey()=13
    zkod_num=num
	set color to n/w,w/n
    @ 19,61 say kod
endcase	
if pznak
  keyboard chr(lznak)
endif  
setcolor(lcolor)
*restore screen from ek
*set key 5 to koncz5()
*set key 24 to koncz24()
RETURN .T.

FUNCTION TYT_FU()
local lopis:=alltrim(opis)
local last:=lastkey()
do skom with lopis
do case
  case last=27.or.last=13
    return 0
endcase
RETURN 1

FUNCTION TYT1_FU()
local last:=lastkey()
*do skom with lopis
do case
  case last=27.or.last=13
    return 0
endcase
RETURN 1


*******************************************************************************
*LP_PARAM                                                                      *
*******************************************************************************
FUNCTION PUBLIC_LSET()
public zlkw_wolna:=0,zlprog2:=0,zlprog3:=0,zlstopa1:=0,zlstopa2:=0,zlstopa3:=0
public zlodlicz1:=0,zlodlicz2:=0,zlodlicz3:=0,zlsr_placa:=0,zlsk_emeryt:=0
public zlsk_rentp:=0,zlsk_rentu:=0,zlsk_chorob:=0,zlsk_zdrow:=0,zlskzdrow_pod:=0
public zlsk_wypad:=0,zlpodstawp:=0,zlpodstaw1:=0,zlpodstaw2:=0
public zlpodstaw3:=0,zlsk_fundus:=0,zlsk_fgsp:=0,zlpod_zdrow:=0
RETURN nil


FUNCTION LSET_REPLAC()
replace lkw_wolna with zlkw_wolna,lprog2 with zlprog2,lprog3 with zlprog3
replace lstopa1 with zlstopa1,lstopa2 with zlstopa2,lstopa3 with zlstopa3
replace lodlicz1 with zlodlicz1,lodlicz2 with zlodlicz2,lodlicz3 with zlodlicz3
replace lsr_placa with zlsr_placa,lsk_emeryt with zlsk_emeryt
replace lsk_rentp with zlsk_rentp,lsk_rentu with zlsk_rentu,lsk_chorob with zlsk_chorob,lsk_zdrow with zlsk_zdrow
replace lskzdrow_pod with zlskzdrow_pod
replace lsk_wypad with zlsk_wypad,lpodstawp with zlpodstawp
replace lpodstaw1 with zlpodstaw1,lpodstaw2 with zlpod_zdrow
replace lpodstaw3 with zlpodstaw3,lsk_fundus with zlsk_fundus
replace lsk_fgsp with zlsk_fgsp
RETURN nil

FUNCTION  L_PARAM()
zk_5=2
zk_24=16
set default to &zlurzad_server
select 0
*use lsetup
if.not.kj_use("progi",.t.,3)
  return nil
endif
lset_lad()
k_w=5
k_w=0
*k_k=29
k_k=0
lpar_tlo()
l_say()
if l_get()
  lset_replac()
endif
use
prac_default()
RETURN nil

FUNCTION LPAR_TLO()
local ltytul:="             *   P A R A M E T R Y   *             "   
local lcolor:=setcolor()
kj_okno(k_w,k_k,23,ltytul,7)	
set color to gr+	
@ k_w+2,k_k+4 say "Podstawa pracodawcy E/R ..."
@ k_w+3,k_k+4 say "Podstawa wspolpracow  E/R  "
@ k_w+4,k_k+4 say "Podstawa ub. zdrowotnego .."
@ k_w+5,k_k+4 say "Srednia placa ............."

@ k_w+6,k_k+4 say  "Kwota wolna od podatku ...."
@ k_w+7,k_k+4 say  "Prog 2 ...................."
@ k_w+8,k_k+4 say  "Prog 3 ...................."
@ k_w+9,k_k+4 say  "Pierwsza stopa podatkowa .."
@ k_w+10,k_k+4 say  "Druga stopa podatkowa......"
@ k_w+11,k_k+4 say  "Trzecia stopa podatkowa...."
@ k_w+12,k_k+4 say  "Pierwsze odliczenie........"
@ k_w+13,k_k+4 say  "Drugie odliczenie.........."
@ k_w+14,k_k+4 say "Trzecie odliczenie........."

@ k_w+15,k_k+4 say "Skladka emerytalna ........"
@ k_w+16,k_k+4 say "Skladka rentowa ..........."
@ k_w+17,k_k+4 say "Skladka chorobowa ........."
@ k_w+18,k_k+4 say "Skladka zdrowotna / ZUS ..."
@ k_w+19,k_k+4 say "Skladka zdrowotna /Podatek "
@ k_w+20,k_k+4 say "Skladka wypadkowa ........."
@ k_w+21,k_k+4 say "Skladka na fundusz pracy .."
@ k_w+22,k_k+4 say "Skladka na fundusz GSP ...."
setcolor(lcolor)
RETURN nil

FUNCTION L_GET_pom()
local lcolor:=setcolor(),las,las1,lget
public vrow:=k_w+2
zk_5=2
zk_24=22
set color to	
set cursor on
      @ k_w+2,k_k+31 get zlpodstawp when s_kom("Posdtawa wyliczania skladek ubezp. pracodawcy. (minimalna podawana przez ZUS)")
      @ k_w+3,k_k+31 get zlpodstaw1 when s_kom("Posdtawa pierwszego wspolpracownika jesli istnieje, w przeciwnym razie 0")
      @ k_w+4,k_k+31 get zlpod_zdrow when s_kom("Posdtawa drugiego wspolpracownika jesli istnieje, w przeciwnym razie 0")	  	  
      @ k_w+5,k_k+31 get zlsr_placa when s_kom("Srednia placa.")
      @ k_w+6,k_k+31 get zlkw_wolna when s_kom("Kwota dochodu zwolniona od podatku (pierwszy prog podatkowy)")
      @ k_w+7,k_k+31 get zlprog2 when s_kom("Drugi prog podatkowy")
      @ k_w+8,k_k+31 get zlprog3 when s_kom("Trzeci prog podatkowy")
      @ k_w+9,k_k+35 get zlstopa1 when s_kom("Pierwsza stopa procentowa podatku dochodowego")
      @ k_w+10,k_k+35 get zlstopa2 when s_kom("Druga stopa procentowa podatku dochodowego")
      @ k_w+11,k_k+35 get zlstopa3 when s_kom("Trzecia stopa procentowa podatku dochodowego")
	  @ k_w+12,k_k+31 get zlodlicz1 when s_kom("Pierwsza odliczenie")
      @ k_w+13,k_k+31 get zlodlicz2 when s_kom("Drugie odliczenie")
      @ k_w+14,k_k+31 get zlodlicz3 when s_kom("Trzecie odliczenie")
      @ k_w+15,k_k+35 get zlsk_emeryt when s_kom("1/2 skladki emerytalnej podana w %")
      @ k_w+16,k_k+30 get zlsk_rentp when s_kom("skladka rentowa pàatnika podana w %")
	  @ k_w+16,k_k+38 get zlsk_rentu when s_kom("skladka rentowa ubezpieczonego podana w %")
      @ k_w+17,k_k+35 get zlsk_chorob when s_kom("Skladka chorobowa podana w %")
      @ k_w+18,k_k+35 get zlsk_zdrow when s_kom("Skladka zdrowotna dla potrzeb rozliczenia podatku podana w %")
      @ k_w+19,k_k+35 get zlskzdrow_pod when s_kom("Skladka zdrowotna dla potrzeb rozliczenia ZUS podana w %")
      @ k_w+20,k_k+35 get zlsk_wypad when s_kom("Skladka wypadkowa podana w %")	  	  
      @ k_w+21,k_k+35 get zlsk_fundus when s_kom("Skladka funduszu pracy podana w %")  	  
      @ k_w+22,k_k+35 get zlsk_fgsp when s_kom("Skladka funduszu pracy podana w %")  	  	  
  read
  tone(1000,0.5)

if.not.lastkey()=27
  lget=.t.
else
  lget=.f.
endif
set cursor off
setcolor(lcolor)
RETURN lget

FUNCTION L_GET()
local lcolor:=setcolor(),las,las1,lget
public vrow:=k_w+2
*set confirm off
*zk_5=2
*zk_24=19
zk_5=2
zk_24=22
set key 5 to koncz5()
set key 24 to koncz24()
set color to	
set cursor on
do while.t.
  do case
    case vrow=k_w+2
      @ k_w+2,k_k+31 get zlpodstawp when s_kom("Posdtawa wymiaru skàadek na ubezpieczenie emerytalne i rentowe pracodawcy")
    case vrow=k_w+3
      @ k_w+3,k_k+31 get zlpodstaw1 when s_kom("Posdtawa wymiaru skàadek na ubezpieczenie emerytalne i rentowe wsp¢lpracownika")
    case vrow=k_w+4
      @ k_w+4,k_k+31 get zlpod_zdrow when s_kom("Posdtawa wymiaru skàadek na ubezpieczenie zdrowotne")	  	  
	case vrow=k_w+5  
      @ k_w+5,k_k+31 get zlsr_placa when s_kom("Srednia placa.")

    case vrow=k_w+6
      @ k_w+6,k_k+31 get zlkw_wolna when s_kom("Kwota dochodu zwolniona od podatku (pierwszy prog podatkowy)")
	case vrow=k_w+7  
      @ k_w+7,k_k+31 get zlprog2 when s_kom("Drugi prog podatkowy")
	case vrow=k_w+8  
      @ k_w+8,k_k+31 get zlprog3 when s_kom("Trzeci prog podatkowy")
    case vrow=k_w+9	  
      @ k_w+9,k_k+35 get zlstopa1 when s_kom("Pierwsza stopa procentowa podatku dochodowego")
	case vrow=k_w+10 
      @ k_w+10,k_k+35 get zlstopa2 when s_kom("Druga stopa procentowa podatku dochodowego")
	case vrow=k_w+11  
      @ k_w+11,k_k+35 get zlstopa3 when s_kom("Trzecia stopa procentowa podatku dochodowego")
	case vrow=k_w+12  
	  @ k_w+12,k_k+31 get zlodlicz1 when s_kom("Pierwsza odliczenie")
    case vrow=k_w+13	  
      @ k_w+13,k_k+31 get zlodlicz2 when s_kom("Drugie odliczenie")
	case vrow=k_w+14  
      @ k_w+14,k_k+31 get zlodlicz3 when s_kom("Trzecie odliczenie")

    case vrow=k_w+15
      @ k_w+15,k_k+35 get zlsk_emeryt when s_kom("1/2 skladki emerytalnej podana w %")
	case vrow=k_w+16  
      @ k_w+16,k_k+30 get zlsk_rentp when s_kom("Skladka rentowa pàatnika podana w %")
	  @ k_w+16,k_k+38 get zlsk_rentu when s_kom("Skladka rentowa ubezpieczonego podana w %")
	case vrow=k_w+17  
      @ k_w+17,k_k+35 get zlsk_chorob when s_kom("Skladka chorobowa podana w %")
	case vrow=k_w+18  
      @ k_w+18,k_k+35 get zlsk_zdrow when  s_kom("Skladka zdrowotna dla potrzeb rozliczenia ZUS podana w %")
	case vrow=k_w+19  
      @ k_w+19,k_k+35 get zlskzdrow_pod when s_kom("Skladka zdrowotna dla potrzeb rozliczenia podatku podana w %")
	case vrow=k_w+20  
      @ k_w+20,k_k+35 get zlsk_wypad when s_kom("Skladka wypadkowa podana w %")	  	  
	case vrow=k_w+21  
      @ k_w+21,k_k+35 get zlsk_fundus when s_kom("Skladka funduszu pracy podana w %")  	  
	case vrow=k_w+22  
      @ k_w+22,k_k+35 get zlsk_fgsp when s_kom("Skladka funduszu pracy podana w %")  	  	  
  endcase
  read
  tone(1000,0.5)

  do case
    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
	  exit
	case lastkey()=27.or.(lastkey()=13.and.vrow=k_w+22.or.lastkey()=18)
	  exit  
    case lastkey()=13.or.lastkey()=24  &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+2
	    vrow=vrow-1	  
	  endif	
  endcase
  l_say()
enddo
if.not.lastkey()=27
  lget=.t.
else
  lget=.f.
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
*set confirm on
RETURN lget


FUNCTION L_SAY()
local lcolor:=setcolor()
set color to W+	
@ k_w+2,k_k+31 say zlpodstawp
@ k_w+3,k_k+31 say zlpodstaw1
@ k_w+4,k_k+31 say zlpod_zdrow
@ k_w+5,k_k+31 say zlsr_placa

@ k_w+6,k_k+31 say zlkw_wolna
@ k_w+7,k_k+31 say zlprog2
@ k_w+8,k_k+31 say zlprog3
@ k_w+9,k_k+35 say zlstopa1 
@ k_w+10,k_k+35 say zlstopa2
@ k_w+11,k_k+35 say zlstopa3
@ k_w+12,k_k+31 say zlodlicz1
@ k_w+13,k_k+31 say zlodlicz2
@ k_w+14,k_k+31 say zlodlicz3

@ k_w+15,k_k+35 say zlsk_emeryt
@ k_w+16,k_k+30 say zlsk_rentp
@ k_w+16,k_k+38 say zlsk_rentu
@ k_w+17,k_k+35 say zlsk_chorob
@ k_w+18,k_k+35 say zlsk_zdrow 
@ k_w+19,k_k+35 say zlskzdrow_pod
@ k_w+20,k_k+35 say zlsk_wypad 
@ k_w+21,k_k+35 say zlsk_fundus
@ k_w+22,k_k+35 say zlsk_fgsp
setcolor(lcolor)
RETURN nil


FUNCTION UZYT_PAR()
local llic0:=zlic0,llic1:=zlic1,llic2:=zlic2,llic3:=zlic3,llic4:=zlic4,ek
local llic5:=zlic5,llic6:=zlic6,llic_regon:=zlic_regon,llic_pesel:=zlic_pesel
local llic_konto:=zlic_konto,llic_tel:=zlic_tel,llic_fax:=zlic_fax
local lfkraj:=zfkraj,lfwojewodztwo:=zfwojewodztwo,lfpowiat:=zfpowiat
local lfgmina:=zfgmina,lfpoczta:=zfpoczta
local ltyt:="    Wlasciciel  LICENCJI :                                                      "
local lcolor:=setcolor()
save screen to ek
clear
kj_okno(0,0,22,ltyt,8)
@ 2,2 say "Nazwa (cz.1)........."
@ 3,2 say "Nazwa (cz.2) ........"
@ 5,2 say "Adres: Kod .........."
@ 6,2 say "       Miejscowosc .."
@ 7,2 say "       Ulica ........"
@ 9,2 say "N I P  .............."
@ 2,24 say llic1 
@ 3,24 say llic2 
@ 5,24 say llic3 
@ 6,24 say llic4 
@ 7,24 say llic5 
@ 9,24 say llic6 
@ 10,1 say replicate("-",78)
@ 12,2 say "Regon ..............."
@ 13,2 say "Pesel ..............."
@ 14,2 say "Konto ..............."
@ 15,2 say "Telefon ............."
@ 16,2 say "Tel/fax ............."
@ 17,2 say "Kraj ................"
@ 18,2 say "Wojew¢dztwo ........."
@ 19,2 say "Powiat .............."
@ 20,2 say "Gmina ..............."
@ 21,2 say "Poczta .............."

@ 23,5 say "Uwaga! Do zmiany nazwy, adresu lub nipu uzyj dyskietki instalacyjnej."
set cursor on

@ 12,24 get llic_regon when s_kom("Regon firmy")
@ 13,24 get llic_pesel when s_kom("Pesel plasciciela firmy")
@ 14,24 get llic_konto picture "@S50" when s_kom("Konto bankowe firmy")
@ 15,24 get llic_tel when s_kom("Telefon firmowy")
@ 16,24 get llic_fax when s_kom("Drugi telefon lub fax")
@ 17,24 get zfkraj when s_kom("Adres - kraj")
@ 18,24 get zfwojewodztwo when s_kom("Adres - wojew¢dztwo")
@ 19,24 get zfpowiat when s_kom("Adres - powiat")
@ 20,24 get zfgmina when s_kom("Adres - gmina")
@ 21,24 get zfpoczta when s_kom("Adres - poczta")
read
if lastkey()=27
  set cursor off
  setcolor(lcolor)
  restore screen from ek
  RETURN nil
endif
if llic_regon#zlic_regon.or.llic_pesel#zlic_pesel.or.;
	 llic_konto#zlic_konto.or.llic_tel#zlic_tel.or.llic_fax#zlic_fax;
	 .or.lfkraj#zfkraj.or.lfwojewodztwo#zfwojewodztwo.or.zfpowiat#lfpowiat;
	 .or.zfgmina#lfgmina.or.lfpoczta#zfpoczta
  if kj_gkom(11,"","Zapamietac wprowadzone zmiany ?","",.t.,5)	 
    zzus_k3=stuff(zzus_k3,1,15,zfkraj)
    zzus_k3=stuff(zzus_k3,16,15,zfwojewodztwo)
    zzus_k3=stuff(zzus_k3,31,15,zfpowiat) 
    zzus_k3=stuff(zzus_k3,46,15,zfgmina)
    zzus_k3=stuff(zzus_k3,61,15,zfpoczta)  

    set default to leg01
	select 0
	if kj_use("leg01",.t.,3)
      replace lic_regon with llic_regon,lic_pesel with llic_pesel
	  replace lic_konto with llic_konto,lic_tel with llic_tel,lic_fax with llic_fax      
      zleg_lad()
      use
	endif
	prac_default()  
  endif
endif	 
if.not.zw_lp
  set default to lpset
  wspol_get()
    if kj_use("lpfirma",.t.,3)
	  fir_replac()	
	use
  endif	
  prac_default()  
endif
set cursor off
setcolor(lcolor)
restore screen from ek
RETURN nil

******************************************************************************
* US_BAZA
**********
FUNCTION US_BAZA(pbaz,pkatal)
local ek,ltyt:=space(80),t[9],q[9],select:=select(),recno:=recno()
t[1]:="kod"
t[2]:="nazwa"
t[3]:="miasto"
t[4]:="ulica"
t[5]:="numer"
t[6]:="kod_poczt"
t[7]:="konto1"
t[8]:="konto2"
t[9]:="konto3"

q[1]:="Kod"
q[2]:="Nazwa"
q[3]:="Adres: miejscowosc"
q[4]:="Ulica"
q[5]:="Numer"
q[6]:="Kod_pocztowy"
q[7]:="Konto 1"
q[8]:="Konto 2"
q[9]:="Konto 3"
save screen to ek
g_tlo()
set default to &zlurzad_server
select 0
do case
  case pbaz=1
    ltyt="           URZAD    SKARBOWY            "
	if.not.kj_use("us",.t.,3)
	  prac_default()
	  select &select
	  return 
	endif
  case pbaz=2
    ltyt="    ZAKLAD UBEZPIECZEN SPOLECZNYCH      "
	if.not.kj_use("zus",.t.,3)
	  prac_default()
	  select &select
	  return 
	endif
  case pbaz=3
    ltyt="            KASA    CHORYCH             "
	if.not.kj_use("kasa_ch",.t.,3)
	  prac_default()
	  select &select
	  return 
	endif		
endcase

kj_okno(10,0,13,ltyt,1)
setcolor("n/w,w/n") 
keyboard chr(205)
do skom with "Dopisz   Popraw   Kasuj   [Enter]-zatw. [Esc]-rezygn."
dbedit(11,1,22,38,t,"US_FU","",q,"ﬂ")
use
prac_default()
if pkatal
  restore screen from ek
  RETURN nil
endif
select &select
go recno
if lastkey()=13
  do case
    case pbaz=1
      zpus_kod=zkod
	  replace pus_kod with zpus_kod
    case pbaz=2
	  zpzus_kod=zkod
      replace pzus_kod with zpzus_kod
    case pbaz=3
	  zpkas_kod=zkod
      replace pkas_kod with zpkas_kod
  endcase 
endif
restore screen from ek
RETURN nil

FUNCTION US_FU(tryb,numer)
local last:=lastkey(),ek
us_lad()
do case
  case chr(last)$"Dd"
    save screen to ek
	us_zer()
	us_dop_tlo()
    if us_get()
      append blank
	  us_replac()	
	endif
    restore screen from ek
	keyboard chr(205)
	return 2
  case chr(last)$"Pp"
    save screen to ek
	us_dop_tlo()
	us_say()
	if us_get()
	  us_replac()	
	endif
    restore screen from ek
	keyboard chr(205)
	return 2	
  case chr(last)$"Kk"
    save screen to ek
	us_dop_tlo()
    us_say()
	if kj_gkom(17," Uwaga ! ","Usunac pozycje",znazwa,.t.,5) 
	  delete
	  pack
	endif
    restore screen from ek
	keyboard chr(205)
	return 2
  case last=13
    return 0    
  case last=27
    return 0
endcase
RETURN 1

FUNCTION US_DOP_TLO()
kj_okno(8,17,10, "                                                ",5)
@ 10,19 say "Indeks ......"
@ 11,19 say "Nazwa ......."
@ 12,19 say "Kod pocztowy "
@ 13,19 say "Miejscowosc  "
@ 14,19 say "Ulica ......."
@ 15,19 say "Numer ......."
@ 16,19 say "Konto ......."
RETURN nil

FUNCTION US_GET()
local lcolor:=setcolor(),lget,luskod_byl:=.f.,lkod:=zkod
public vrow:=10
k_w=0
zk_5=10
zk_24=16
set key 5 to koncz5()
set key 24 to koncz24()
set cursor on
do while .t.
  do case
    case vrow=10
     @ 10,33 get zkod picture "@!" 
    case vrow=11    	 
      @ 11,33 get znazwa picture "@!"
    case vrow=12	  
      @ 12,33 get zkod_poczt picture "@!"
    case vrow=13	  
      @ 13,33 get zmiasto picture "@!"
    case vrow=14	  
      @ 14,33 get zulica picture "@!"
    case vrow=15	  
      @ 15,33 get znumer picture "@!"
    case vrow=16	  
      @ 16,33 get zkonto1 picture "@!S30"
  endcase
  read
  if vrow=10.and.lkod#zkod
    luskod_byl=uskod_byl()
  endif	

  do case
    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
	  exit
	case lastkey()=27.or.(lastkey()=13.and.vrow=k_w+16).or.lastkey()=18
	  exit  
    case lastkey()=13.or.lastkey()=24  &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>10
	    vrow=vrow-1	  
	  endif	
  endcase
  us_say()
enddo
tone(1000,0.5)
set key 24 to
set key 5 to
setcolor(lcolor)
if.not.lastkey()=27
  lget=.t.
else
  lget=.f.
endif
if zkod#lkod.and.luskod_byl
  kj_tkom(12," Uwaga ! ","Bledny kod urzedu. Nie bedzie zapamietany","","Nacisnij dowolny klawisz.",5)
  zkod=lkod
endif
set cursor off
RETURN lget

FUNCTION US_SAY()
local lcolor:=setcolor(),lrow:=10
set color to n/w,w/n
@ lrow,33 say zkod
@ lrow+1,33 say znazwa
@ lrow+2,33 say zkod_poczt
@ lrow+3,33 say zmiasto
@ lrow+4,33 say zulica
@ lrow+5,33 say znumer
@ lrow+6,33 say substr(zkonto1,1,30)
setcolor(lcolor)
RETURN nil

FUNCTION US_ZER()
zkod=space(3)
znazwa=space(30)
zmiasto=space(30)
zulica=space(30)
znumer=space(10)
zkod_poczt=space(6)
zkonto1=space(60)
zkonto2=space(60)
zkonto3=space(60)
RETURN nil

FUNCTION US_LAD()
zkod=kod
znazwa=nazwa
zmiasto=miasto
zulica=ulica
znumer=numer
zkod_poczt=kod_poczt
zkonto1=konto1
zkonto2=konto2
zkonto3=konto3
RETURN nil

FUNCTION US_REPLAC()
replace kod with zkod,miasto with zmiasto,ulica with zulica,numer with znumer
replace kod_poczt with zkod_poczt,konto1 with zkonto1,konto2 with zkonto2
replace konto3 with zkonto3,nazwa with znazwa 
RETURN nil

FUNCTION USKOD_BYL()
local lbyl:=.f.,recno:=recno()
if zkod=space(3)
  kj_tkom(12," Uwaga! ","Urzad musi miec nadany kod","Wpisz kod!","Nacisnij dowolny klawisz.",5)     
  lbyl=.t.
  return lbyl
endif
go top

do while.not.eof()
  if zkod=kod
    kj_tkom(12," Uwaga! ","Urzad o podanym kodzie juz istnieje","Zmien kod!","Nacisnij dowolny klawisz.",5)  
    lbyl=.T.
	exit
  endif
  skip
enddo
go recno
set cursor on
RETURN lbyl


FUNCTION WSPOL_GET()
local ek,lcolor:=setcolor(),lwspol:=" "
g_tlo()
kj_okno(2,7,19, "          DANE IDENTYFIKACYJNE OSOB WSPOLPRACUJACYCH             ",8)
set color to n/w,w/n
@ 4,9 say "Wlasciciel              "
@ 5,9 say "   Kod tytulu ubezpiecz."  
@ 6,9 say "   Czy placi skladki ZUS"
@ 7,9 say  "Osoba wspolpracujaca - I"
@ 8,9 say "   Kod tytulu ubezpiecz."  
@ 9,9 say "   Nazwisko ............"
@ 10,9 say "   Imie ................"
@ 11,9 say "   Typ identyfikatora .."
@ 12,9 say "   Identyfikator........"  
@ 13,9 say "   Czy placi skladki ZUS"

@ 14,9 say  "Osoba wspolpracujaca - II"
@ 15,9 say "   Kod tytulu ubezpiecz."  
@ 16,9 say  "   Nazwisko ............"
@ 17,9 say "   Imie ................"
@ 18,9 say "   Typ identyfikatora .."
@ 19,9 say "   Identyfikator........"  
@ 20,9 say "   Czy placi skladki ZUS"

set cursor on
s_kom("Wybierz kod tytulu ubezpieczenia wlasciciela firmy")
@ 5,34 get zwl_kodnum picture "99" when wlas_kod(1)
@ 5,34 say zwl_kodnum picture "99"
@ 6,34 get zwl_spol when s_kom("T - placi skladki ZUS   N - nie placi skladki ZUS ")

@ 8,34 get zw1_kodnum picture "99" when wspol_kod(1)
@ 8,34 say zw1_kodnum picture "99"
@ 9,34 get zw1_naz when s_kom("Nazwisko pierwszej osoby wspolpracujacej")
@ 10,34 get zw1_imie when s_kom("Imie pierwszej osoby wspolpracujacej")
@ 11,34 get zw1_typ when s_kom("Typ identyfikatora pierwszej osoby wspolpracujacej")
@ 12,34 get zw1_iden when s_kom("Identyfikator pierwszej osoby wspolpracujacej")
@ 13,34 get zw1_spol  when s_kom("T - placi skladki ZUS   N - nie placi skladki ZUS ")

@ 15,34 get zw2_kodnum picture "99" when wspol_kod(2)
@ 15,34 say zw2_kodnum picture "99"
@ 16,34 get zw2_naz when s_kom("Nazwisko drugiej osoby wspolpracujacej")
@ 17,34 get zw2_imie when s_kom("Imie drugiej osoby wspolpracujacej")
@ 18,34 get zw2_typ when s_kom("Typ identyfikatora drugiej osoby wspolpracujacej")
@ 19,34 get zw2_iden when s_kom("Identyfikator drugiej osoby wspolpracujacej")
@ 20,34 get zw2_spol  when s_kom("T - placi skladki ZUS   N - nie placi skladki ZUS ")

read
if lastkey()#27
  zzus_k1=stuff(zzus_k1,1,31,zw1_naz)
  zzus_k1=stuff(zzus_k1,32,22,zw1_imie)
  zzus_k1=stuff(zzus_k1,54,1,zw1_typ)
  zzus_k1=stuff(zzus_k1,55,11,zw1_iden)
  zzus_k1=stuff(zzus_k1,67,2,str(zw1_kodnum,2))
  if zw1_spol
    zzus_k1=stuff(zzus_k1,70,1,"T")
  else
    zzus_k1=stuff(zzus_k1,70,1,"F")
  endif  	
  zzus_k2=stuff(zzus_k2,1,31,zw2_naz)
  zzus_k2=stuff(zzus_k2,32,22,zw2_imie)
  zzus_k2=stuff(zzus_k2,54,1,zw2_typ)
  zzus_k2=stuff(zzus_k2,55,11,zw2_iden)  
  zzus_k2=stuff(zzus_k2,67,2,str(zw2_kodnum,2))  
  if zw2_spol
    zzus_k2=stuff(zzus_k2,70,1,"T")
  else
    zzus_k2=stuff(zzus_k2,70,1,"F")
  endif  	
  zsk_kod=stuff(zsk_kod,1,2,str(zwl_kodnum,2))
  if zwl_spol
    zsk_kod=stuff(zsk_kod,4,1,"T")  
  else
    zsk_kod=stuff(zsk_kod,4,1,"F")  
  endif  	
else
  return
endif
do case
  case empty(zw1_naz).and.empty(zw2_naz)
    lwspol="0"
  case.not.empty(zw1_naz).and.empty(zw2_naz)
    lwspol="1"
  case.not.empty(zw1_naz).and..not.empty(zw2_naz)
    lwspol="2"		
endcase
zskarbowy=stuff(zskarbowy,1,1,lwspol)
set cursor off
setcolor(lcolor)
inkey(1)
RETURN nil


*******************************************************************************
*LP_LICZ                                                                      *
*******************************************************************************
******************************************************************************
*OBLICZENIA
*************
FUNCTION P_KWOTY(prow,pcol)
local ek,lnip_byl:=.f.,lnaz_byl:=.f.,lkoncz:=.f.
local select:=select(),lcolor:=setcolor()
local lkget:=.f.       &&Wynik funkcji k_get()
k_w:=1
k_k:=0  
save screen to ek
pk_dop_tlo()
pk_say()
lkget=pk_get(.t.)
    if lastkey()#27
        pk_replac()
    endif  
restore screen from ek
RETURN lkget

FUNCTION PK_DOP_TLO()
local ltytul:=" Pracownik:                                        "   
local lcolor:=setcolor()
ltytul=stuff(ltytul,14,20,zpnazwisko)
ltytul=stuff(ltytul,16+len(alltrim(zpnazwisko)),len(alltrim(zpimie1)),alltrim(zpimie1))
kj_okno(k_w,k_k,17,ltytul,7)	
set color to gr+	
@ k_w+2,k_k+2 say  "PRZYCHOD:   Wynagrodzenie zasadnicze .."
@ k_w+3,k_k+2 say  "            Dodatek ..................."
@ k_w+4,k_k+2 say  "            Premia ...................."
@ k_w+5,k_k+2 say  "            Za czas choroby ..........."
@ k_w+6,k_k+2 say  "KOSZTY:     Uzyskania przychodow ......"
@ k_w+7,k_k+2 say  "POTRACENIA: Skladka ubezp. na zycie ..."
@ k_w+8,k_k+2 say  "            Inne ......................"
@ k_w+9,k_k+2 say "DODATKI:    Zasilek rodzinny .........."
@ k_w+10,k_k+2 say "            Inne nieopodatkowane ......"
@ k_w+11,k_k+2 say "NALICZANIE SKLADEK:  Emerytalna [T/N].."
@ k_w+12,k_k+2 say "                     Rentowa    [T/N].."
@ k_w+13,k_k+2 say "                     Chorobowa  [T/N].."
@ k_w+14,k_k+2 say "                     Zdrowotna  [T/N].."
@ k_w+15,k_k+2 say  "KWOTA WOLNA OD PODATKU          [T/N].."

setcolor(lcolor)
RETURN nil

FUNCTION PK_GET(pdopisz)
local lcolor:=setcolor(),las,las1,lget
zk_5=2
zk_24=15
public vrow:=k_w+2
set key 5 to koncz5()
set key 24 to koncz24()
set color to	

do while.t.
  set color to	
  set cursor on
  do case
    case vrow=k_w+2
      @ k_w+2,k_k+41 get zpzasadn picture "999999.99" when s_kom("[Enter]-zatwierdz.pozycji   [Ctrl-Enter]-zatwierdz.wszystkiego   [Esc]-rezygn.")
	case vrow=k_w+3  
      @ k_w+3,k_k+41 get zpdodatek picture "999999.99"
	case vrow=k_w+4  
      @ k_w+4,k_k+41 get zppremia picture "999999.99"
    case vrow=k_w+5	  
      @ k_w+5,k_k+41 get zpza_chor picture "999999.99"
	case vrow=k_w+6  
      @ k_w+6,k_k+41 get zpkoszty picture "999999.99"
	case vrow=k_w+7  
	  @ k_w+7,k_k+41 get zpsk_zycie picture "999999.99"
    case vrow=k_w+8  
      @ k_w+8,k_k+41 get zpsk_inne picture "999999.99"
	case vrow=k_w+9  
      @ k_w+9,k_k+41 get zpzasilek picture "999999.99"
	case vrow=k_w+10  
      @ k_w+10,k_k+41 get zpzas_inne picture "999999.99" when s_kom("[Enter]-zatwierdz.pozycji   [Ctrl-Enter]-zatwierdz.wszystkiego   [Esc]-rezygn.")
    case vrow=k_w+11
      @ k_w+11,k_k+41 get zplog_e when s_kom("Litera [ T ] - skladka naliczana      litera [ F ] - skladka nie naliczana")
	case vrow=k_w+12  
      @ k_w+12,k_k+41 get zplog_r
	case vrow=k_w+13  
      @ k_w+13,k_k+41 get zplog_c
	case vrow=k_w+14  
      @ k_w+14,k_k+41 get zplog_z
	case vrow=k_w+15 
      @ k_w+15,k_k+41 get zpkw_wolna	  
  endcase
  read
  do case
    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
	  exit
	case lastkey()=27
	  exit  
	case (lastkey()=13.and.vrow=k_w+15)
	  tone(1000,0.5)
	  licz_say()
      inkey(0)
	  exit
    case lastkey()=13
	  tone(1000,0.5)
	  licz_say()
	  vrow=vrow+1
	case lastkey()=18  
	  exit
	case lastkey()=24  &&nastepna  
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+2
	    vrow=vrow-1	  
	  endif	
    case chr(lastkey())$"Rr"
  endcase
  setcolor(lcolor)
  pk_say()
enddo
set cursor off
if.not.lastkey()=27
  lget=.t.
else
  lget=.f.
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
*set confirm on
RETURN lget


FUNCTION PK_SAY()
local lcolor:=setcolor()
set color to W+	
@ k_w+2,k_k+41 say zpzasadn picture "999999.99"
@ k_w+3,k_k+41 say zpdodatek picture "999999.99"
@ k_w+4,k_k+41 say zppremia picture "999999.99"
@ k_w+5,k_k+41 say zpza_chor picture "999999.99"
@ k_w+6,k_k+41 say zpkoszty picture "999999.99"
@ k_w+7,k_k+41 say zpsk_zycie picture "999999.99"
@ k_w+8,k_k+41 say zpsk_inne picture "999999.99"
@ k_w+9,k_k+41 say zpzasilek picture "999999.99"
@ k_w+10,k_k+41 say zpzas_inne picture "999999.99"
@ k_w+11,k_k+41 say zplog_e
@ k_w+12,k_k+41 say zplog_r
@ k_w+13,k_k+41 say zplog_c
@ k_w+14,k_k+41 say zplog_z
@ k_w+15,k_k+41 say zpkw_wolna
setcolor(lcolor)
RETURN nil

FUNCTION PK_REPLAC()
replace pzasadn with zpzasadn,pdodatek with zpdodatek,ppremia with zppremia
replace pza_chor with zpza_chor,pkoszty with zpkoszty,pkw_wolna with zpkw_wolna
replace psk_zycie with zpsk_zycie,psk_inne with zpsk_inne,pzasilek with zpzasilek
replace pzas_inne with zpzas_inne, plog_e with zplog_e,plog_r with zplog_r
replace plog_c with zplog_c, plog_z with zplog_z 
RETURN nil

FUNCTION PLAC_TLO()
set color to
@ 20,1 clear to 23,78
@ 20,1 say replicate(chr(176),78)
RETURN nil

FUNCTION LICZ_SAY()
zlicz()
set color to n/w,w/n
kj_okno(1,51,22,"    P O D S U M O W A N I E  ",1)
kj_okno(19,0,4,"         K W O T A   D O   W Y P L A T Y           ",1)
@ 3,53 say "Podstawa ubezpieczenia:"
@ 4,70 say plicz_d7() picture "999999.99"
@ 6,53 say "Ogolem przychod:"
@ 6,70 say  plicz_m8() picture "999999.99"
@ 8,53 say "SKLADKI:"
@ 9,53 say  "Emerytalna ....."
@ 10,53 say "Rentowa ........"
@ 11,53 say "Chorobowa ......"
@ 12,53 say "Razem E+R+Ch ..."
@ 13,53 say "Zdrowotna ......"
@ 14,53 say "Zdrow. pobrana ."
@ 15,53 say "Wypadkowa ......"
@ 16,53 say "Suma skladek :  "
@ 9,70 say  plicz_d9() picture "999999.99"
@ 10,70 say  plicz_d10() picture "999999.99"
@ 11,70 say  plicz_d11() picture "999999.99"
@ 12,70 say  plicz_d9()+plicz_d10()+plicz_d11() picture "999999.99"
@ 13,70 say  plicz_d14() picture "999999.99"
*@ 14,70 say plicz_d30() picture "999999.99"
*@ 14,70 say plicz_do30() picture "999999.99"
@ 14,70 say plicz_da30() picture "999999.99"
@ 15,70 say plicz_d31() picture "999999.99"
@ 16,70 say plicz_d32() picture "999999.99"

@ 18,53 say "Podstawa ub.zdrow"
@ 18,70 say  plicz_d13() picture "999999.99"
@ 19,53 say "Nalezna stopa:        % "
@ 19,70 say zstopa picture "999"
*@ 16,70 say  plicz_m13() picture "999999.99"
@ 20,53 say "Zaliczka potracona"
@ 20,70 say  plicz_d15() picture "999999.99"
@ 21,53 say "Zaliczka nalezna"
@ 21,70 say plicz_d16() picture "999999.99"
@ 21,20 say plicz_d23() picture "999999.99"
@ 22,53 say "Dopàata do zdrow."
@ 22,70 say plicz_da30()-plicz_do30() picture "999999.99"
RETURN nil

******************************************************************************
* FUNKCJE OBLICZENIOWE                                                       *
******************************************************************************


*******************************************************************************
* Funkcja analizuje zarobki pracownika od poczatku roku i przydziela          * 
* odpowiednia stope podatku dochodowego, zgodnie z zasada ze w pierwszym      *
* miesiacu o wyborze stopyb decydyja zarobki w tym miesiacu, natomiast w      *
* kazdym nastepnym suma zarobkow ze wszystkich miesiecy poprzednich (z wyla-  * 
* czeniem zarobkow z biezacego miesiaca
*******************************************************************************
FUNCTION STOPA()
local lstopa:=zlstopa1,select:=select(),i,lsum_7:=0,lrecno:=recno()
local lpnazwisko:=zpnazwisko,lpimie1:=zpimie1,lppesel:=zppesel,lmiesiac:=zmiesiac
pvz_lad()
if zmiesiac=1.or..not.prac_byl()
  *lsum_7=plicz_d7()+zpza_chor
  lsum_7=plicz_d13b()-zpkoszty
else
  for i=1 to zmiesiac-1
    select 0
    lsukces=prac_use(i)
    locate for pnumer=zpnumer
	if found()
	  *lsum_7=lsum_7+pzasadn+pdodatek+ppremia+pza_chor
	  p_lad()
	  lsum_7=lsum_7+plicz_d13b()-zpkoszty
	endif
	use
  next
  select &select
  go lrecno
endif
do case
  case lsum_7>zlprog2.and.lsum_7<=zlprog3
    lstopa=zlstopa2
    zstopa=zlstopa2  
  case lsum_7>zlprog3
    lstopa=zlstopa3	  
	zstopa=zlstopa3	  
endcase
if lsum_7>30*zlsr_placa
  zwar_30=.t.
else
  zwar_30=.f.  
endif
pzv_lad()
RETURN lstopa


*******************************************************************************
* Funkcja analizuje zarobki pracownika od poczatku roku i przydziela          * 
* odpowiednia stope podatku dochodowego, zgodnie z zasada ze w pierwszym      *
* miesiacu o wyborze stopyb decydyja zarobki w tym miesiacu, natomiast w      *
* kazdym nastepnym suma zarobkow ze wszystkich miesiecy poprzednich (z wyla-  * 
* czeniem zarobkow z biezacego miesiaca
*******************************************************************************
FUNCTION STOPA_old()
local lstopa:=zlstopa1,select:=select(),i,lsum_7:=0,lrecno:=recno()
local lpnazwisko:=zpnazwisko,lpimie1:=zpimie1,lppesel:=zppesel
if zmiesiac=1.or..not.prac_byl()
  *lsum_7=plicz_d7()+zpza_chor
  lsum_7=plicz_d13()-zpkoszty
else
  for i=1 to zmiesiac-1
    select 0
    lsukces=prac_use(i)
    locate for pnumer=zpnumer
	if found()
	  *lsum_7=lsum_7+pzasadn+pdodatek+ppremia+pza_chor
	  lsum_7=lsum_7+plicz_d13a()
	endif
	use
  next
  select &select
  go lrecno
endif
do case
  case lsum_7>zlprog2.and.lsum_7<=zlprog3
    lstopa=zlstopa2
  case lsum_7>zlprog3
    lstopa=zlstopa3	  
endcase
if lsum_7>30*zlsr_placa
  zwar_30=.t.
else
  zwar_30=.f.  
endif
RETURN lstopa


*******************************************************************************
* Funkcja zlicza zarobki pracownika i porownuje z trzydziestokrotna srednia   *
* krajowa. Jesli zarobki te sa wieksze, program automatycznie przestaje       *
* naliczac skladke ubezpieczenia spolecznego. Przyjeto zasade, ze w pierwszym *
* miesiacu porownaniu podlegaja dochody z tego miesiaca, w kazdym zastepnym - *
* dochody z miesiecy poprzednich z wylaczeniem biezacego                      *
*******************************************************************************
FUNCTION KJWAR1_30()
local lwar_30:=.f.
local select:=select(),i,lsum_war30:=0,lrecno:=recno()
if zmiesiac=1.or..not.prac_byl()
  lsum_war30=plicz_d7()+zpza_chor
else
  for i=1 to zmiesiac-1
    select 0
    lsukces=prac_use(i)
    locate for pnumer=zpnumer
	if found()
	  lsum_war30=lsum_war30+pzasadn+pdodatek+ppremia+pza_chor
	endif
	use
  next
  select &select
  go lrecno
endif
if lsum_war30>30*zlsr_placa
  lwar_30=.t.
endif
RETURN lwar_30

*******************************************************************************
* Funkcja analizujac zarobki od poczatku roku wylicza odpowiednia dla danego  *
* przcownika stope % oraz okresla warunek przekroczenia 30 srednich wynagrodze*
*******************************************************************************
FUNCTION ZLICZ()
*zwar_30=war_30()
zstopa=stopa()
RETURN nil


*******************************************************************************
* Funkcja wylicza sume wynagrodzenia - podstawe ubezpieczenia spolecznego     *
* pracownika: wyn.zasadnicze+dodatek+premia                                   *
*******************************************************************************
FUNCTION PLICZ_D7()
local llicz_d7:=zpzasadn+zpdodatek+zppremia
RETURN llicz_d7



*******************************************************************************
* Funkcja sprawdza warunek przekroczenia trzydziestokrotnej sredniej placy    *
* Jesli placa nie przekracza wyliczonej w warunku, naliczana jest skladka     *
* emerytalna jako iloczyn lacznego wynagrodzenia i stopy %. W przeciwnym      *
* wypadku funkcja zwraca 0                                                    *
* zplog_e=.f. - programowo wylaczpne obliczanie slkadki                       *
*******************************************************************************
FUNCTION PLICZ_D9()
local llicz_d9:=0
if.not.zwar_30      &&jesli nie przekroczono 30-krotnej placy sredniej 
  if zplog_e
    llicz_d9=KJ_ROUND(plicz_d7()*(zlsk_emeryt/100),2)
  endif
endif
RETURN llicz_d9

*******************************************************************************
* Funkcja sprawdza warunek przekroczenia trzydziestokrotnej sredniej placy    *
* Jesli placa nie przekracza wyliczonej w warunku, naliczana jest skladka     *
* rentowa    jako iloczyn lacznego wynagrodzenia i stopy %. W przeciwnym      *
* wypadku funkcja zwraca 0                                                    *
* zplog_r=.f. - programowo wylaczpne obliczanie slkadki                       *
*******************************************************************************
FUNCTION PLICZ_D10()
local llicz_d10:=0
if.not.zwar_30      &&jesli nie przekroczono 30-krotnej placy sredniej 
  if zplog_r
    * llicz_d10=KJ_ROUND(plicz_d7()*(zlsk_rent/100),2)
	*llicz_d10=KJ_ROUND(plicz_d7()*(zlsk_rentu/100),2)
	llicz_d10=KJ_ROUND(plicz_d7()*(zlsk_rentu/100),2)+KJ_ROUND(plicz_d7()*(zlsk_rentp/100),2)
  endif  
endif
RETURN llicz_d10

*******************************************************************************
* Funkcja sprawdza warunek przekroczenia trzydziestokrotnej sredniej placy    *
* Jesli placa nie przekracza wyliczonej w warunku, naliczana jest skladka     *
* chorobowa  jako iloczyn lacznego wynagrodzenia i stopy %. W przeciwnym      *
* wypadku funkcja zwraca 0                                                    *
* zplog_c=.f. - programowo wylaczpne obliczanie slkadki                       *
*******************************************************************************
FUNCTION PLICZ_D11()
local llicz_d11:=0
if.not.zwar_30      &&jesli nie przekroczono 30-krotnej placy sredniej 
  if zplog_c
    llicz_d11=KJ_ROUND(plicz_d7()*(zlsk_chorob/100),2)
  endif
endif
RETURN llicz_d11

*******************************************************************************
* Suma skladek ubezpieczenia spolecznego pracownika                           *
*******************************************************************************
FUNCTION PLICZ_D12()
local llicz_d12:=plicz_d9()+plicz_d10()+plicz_d11()
RETURN llicz_d12


*******************************************************************************
* Podstawa ubezpieczenia zdrowotnego i podatku docodowego                     *
* (Wynagrodzenie razem+chorobowe-suma skladek ub.spolecznego pracownika)      *
*******************************************************************************
FUNCTION PLICZ_D13()
local llicz_d13:=plicz_d7()+zpza_chor-plicz_d9()-plicz_d10()-plicz_d11()
RETURN llicz_d13

*B B B
*******************************************************************************
* Podstawa ubezpieczenia zdrowotnego i podatku docodowego                     *
* (Wynagrodzenie razem+chorobowe-suma skladek ub.spolecznego pracownika)      *
*******************************************************************************
FUNCTION PLICZ_D13B()
local llicz_d13:=plicz_d7()+zpza_chor-plicz_d9b()-plicz_d10b()-plicz_d11b()
RETURN llicz_d13
**
FUNCTION PLICZ_D9B()
local llicz_d9:=0
  if zplog_e
    llicz_d9=KJ_ROUND(plicz_d7()*(zlsk_emeryt/100),2)
  endif
RETURN llicz_d9
**
FUNCTION PLICZ_D10B()
local llicz_d10:=0
  if zplog_r
    *llicz_d10=KJ_ROUND(plicz_d7()*(zlsk_rent/100),2)
	llicz_d10=KJ_ROUND(plicz_d7()*(zlsk_rentu/100),2)
  endif  
RETURN llicz_d10
**
FUNCTION PLICZ_D11B()
local llicz_d11:=0
  if zplog_c
    llicz_d11=KJ_ROUND(plicz_d7()*(zlsk_chorob/100),2)
  endif
RETURN llicz_d11
*******************************************************************************
* Skladka ubezpieczenia zdrowotnego nalezna                                   *
*******************************************************************************
FUNCTION PLICZ_D14()
local llicz_d14:=0
if zplog_z
  llicz_d14=KJ_ROUND(plicz_d13()*(zlsk_zdrow/100),2)
endif
RETURN llicz_d14


*******************************************************************************
*Skladka ubezpieczenia zdrowotnego nalezna dla cel¢w obliczenia podatku      *
*******************************************************************************
FUNCTION PLICZ_DO14()
local llicz_d14:=0
if zplog_z
  llicz_d14=KJ_ROUND(plicz_d13()*(zlskzdrow_pod/100),2)
endif
RETURN llicz_d14



*******************************************************************************
* Funkcja wylicz zaliczk© na podatek dochodowy. Korzysta z wczesniej policzo- *
* nej stopy odpowiednij do zarobkow od poczatku roku oraz widelek procentowych*
* zpkw_wolna=.t. - pracownikowi przysluguje prawo do odliczenia kwoty wolnej  *
* Jesli wyliczona zaliczka jest mniejsza od zera funkcja zwraca 0             *
*******************************************************************************
FUNCTION PLICZ_D15()
local lstopa:=zstopa,llicz_d15
if zpkw_wolna
  llicz_d15=KJ_ROUND(plicz_m13()*(lstopa/100),2)-KJ_ROUND(zlkw_wolna/12,2)
else
  llicz_d15=KJ_ROUND(plicz_m13()*(lstopa/100),2)
endif
if llicz_d15<0
  llicz_d15=0
endif  
*llicz_d15=KJ_ROUND(llicz_d15,0)     &&060213
RETURN llicz_d15

*******************************************************************************
* Zaliczka na podatek dochodowy po potraceniu skladki na ubezpieczenie zdrowo-*
* tne. Jesli skladka wieksza od zaliczki funkcja zwraca 0                     *
*******************************************************************************
FUNCTION PLICZ_D16()
local llicz_d16:=KJ_ROUND(plicz_d15()-plicz_do14(),1)
if llicz_d16<0
  llicz_d16=0
endif
llicz_d16=KJ_ROUND(llicz_d16,0)     &&060213
RETURN llicz_d16

*******************************************************************************
* Kwota do wyplaty. (Przychod ogolem-skladki spoleczne-zdrowotne faktycznie   *
* pobrane-zaliczka na podatek dochodowy-skladki{na zycie,inne}+zasilki        *
*******************************************************************************
FUNCTION PLICZ_D23()
local llicz_d23:=plicz_m8()-plicz_d9()-plicz_d10()-plicz_d11()-plicz_da30()-plicz_d16()-zpsk_zycie-zpsk_inne+zpzasilek+zpzas_inne
RETURN llicz_d23

*******************************************************************************
* Skladka ubezpieczenia zdrowotnego naleæna            w danym miesiacu       *
* do wysokosci podatku dochodowego                                            *
*******************************************************************************
FUNCTION PLICZ_D30()
local llicz_d30:=plicz_d14()
if plicz_do14()>=plicz_d15()
  llicz_d30=plicz_d15()
endif
RETURN llicz_d30

*******************************************************************************
* Skladka ubezpieczenia zdrowotnego naleæna            w danym miesiacu       *
* do wysokosci podatku dochodowego                                            *
*******************************************************************************
FUNCTION PLICZ_DA30()
local llicz_d30:=plicz_d14()
if plicz_d14()>=plicz_d15()
  llicz_d30=plicz_d15()
endif
RETURN llicz_d30

*******************************************************************************
* Skladka ubezpieczenia zdrowotnego faktycznie pobrana w danym miesiacu       *
* do wysokosci podatku dochodowego                                            *
*******************************************************************************
FUNCTION PLICZ_DO30()
local llicz_d30:=plicz_do14()
if plicz_do14()>plicz_d15()
  llicz_d30=plicz_d15()
endif
RETURN llicz_d30

*******************************************************************************
* Funkcja wylicza nalezna skladke wypadkowa pracownika                        *
*******************************************************************************
FUNCTION PLICZ_D31()
local llicz_d31:=KJ_ROUND(plicz_d7()*(zlsk_wypad/100),2)
RETURN llicz_d31

*******************************************************************************
* Funkcja wylicza sume skladek ubezp.spol. + skladka zdrowotna faktycznie     *
* pobrana w danym miesiacu                                                    *
*******************************************************************************
FUNCTION PLICZ_D32()
local llicz_d32:=2*plicz_d9()+2*plicz_d10()+plicz_d11()+plicz_d31()+plicz_d30()
RETURN llicz_d32

*******************************************************************************
* Funkcja wylicza sume skladek ubezp.spol. (konto 51) dla wybranego pracownika*
*******************************************************************************
FUNCTION PLICZ_D33()
*local llicz_d33:=2*plicz_d9()+2*plicz_d10()+plicz_d11()+plicz_d31()
local llicz_d33:=2*plicz_d9()+plicz_d10()+plicz_d11()+plicz_d31()
RETURN llicz_d33

*******************************************************************************
* Funkcja wylicza przychod ogolem : suma wynagrodzenia+chorobowe  pracownika  *
*******************************************************************************
FUNCTION PLICZ_M8()
local llicz_m8:=plicz_d7()+zpza_chor
RETURN llicz_m8

*******************************************************************************
* Podstawa naliczania podatku dochodowego: od przychodu ogolem odjeto koszty  *
* uzyskania oraz sume skladek ubezpieczenia spolecznego poniesionych przez    *
* pracownika (m8-m9-d9-d10-d11)
*******************************************************************************
FUNCTION PLICZ_m13()
local llicz_m13:=KJ_ROUND(plicz_m8()-zpkoszty-plicz_d9()-plicz_d10()-plicz_d11(),0)
RETURN llicz_m13


*******************************************************************************
* Funkcja podlicza sume wynagrodzen wszystkich pracownikow                    *
*******************************************************************************
FUNCTION PLICZ_S7()
local llicz_s7:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s7=llicz_s7+plicz_d7()
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s7

*******************************************************************************
* Funkcja podlicza sume skladek usezpieczen spolecznych wszystkich pracownikow*
*******************************************************************************
FUNCTION PLICZ_S12()
local llicz_s12:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s12=llicz_s12+plicz_d12()
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s12

*******************************************************************************
* Funkcja podlicza sume naleznych skladek na ubezpieczenie zdrowotne          *
* (nie sa to skladki faktycznie pobrane!)
*******************************************************************************
FUNCTION PLICZ_S14()
local llicz_s14:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s14=llicz_s14+plicz_d14()
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s14

*******************************************************************************
* Funkcja podlicza sume zaliczek na podatek dochodowy do potracenia           *
* (obejmuje zaliczke na podatek zgodnie z widelkami pomniejszona o kwote      *
* skladki na ubezpieczenie zdrowotne                                          *
*******************************************************************************
FUNCTION PLICZ_S16()
local llicz_s16:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s16=llicz_s16+plicz_d16()
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s16

*******************************************************************************
* Laczna kwota zasilkow rodzinnych i zasilkow innych dla wszystkich pracownik *
*******************************************************************************
FUNCTION PLICZ_S22()
local llicz_s22:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s22=llicz_s22+zpzasilek  
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s22

*******************************************************************************
* Laczna kwota wyplaty dla wszystkich pracownikow                             *
*******************************************************************************
FUNCTION PLICZ_S23()
local llicz_s23:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s23=llicz_s23+plicz_d23()
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s23


*******************************************************************************
* Funkcja podlicza sume pobranych skladek na ubezpieczenie zdrowotne          *
*     (sa to skladki faktycznie pobrane!)
*******************************************************************************
FUNCTION PLICZ_S30()
local llicz_s30:=0,lrecno:=recno()
go top
do while.not.eof()
  p_lad()
  llicz_s30=llicz_s30+plicz_d30()
  skip
enddo  
go lrecno
p_lad()
RETURN llicz_s30


*******************************************************************************
*LP_INDEX                                                                      *
*******************************************************************************
******************************************************************************
*INDEKSACJA
*************
FUNCTION P_INDEX()
close all
*set default to pracow
prac_default()
select 0
if kj_use("place_01",.t.,3)
  index on pnazwisko to place_01
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_01","Indeksacja za styczen nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_02",.t.,3)
  index on pnazwisko to place_02
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_02","Indeksacja za luty nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_03",.t.,3)
  index on pnazwisko to place_03
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_03","Indeksacja za marzec nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_04",.t.,3)
  index on pnazwisko to place_04
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_04","Indeksacja za kwiecien nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_05",.t.,3)
  index on pnazwisko to place_05
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_05","Indeksacja za maj nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_06",.t.,3)
  index on pnazwisko to place_06
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_06","Indeksacja za czerwiec nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_07",.t.,3)
  index on pnazwisko to place_07
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_07","Indeksacja za lipiec nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_08",.t.,3)
  index on pnazwisko to place_08
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_08","Indeksacja za sierpien nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_09",.t.,3)
  index on pnazwisko to place_09
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_09","Indeksacja za wrzesian nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_10",.t.,3)
  index on pnazwisko to place_10
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_10","Indeksacja za pazdziernik nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_11",.t.,3)
  index on pnazwisko to place_11
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_11","Indeksacja za listopad nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
if kj_use("place_12",.t.,3)
  index on pnazwisko to place_12
  use
else
  kj_tkom(12," Uwaga!","Brak dostepu do pliku place_12","Indeksacja za grudzien nie zostala przeprowadzona","Nacisnij dowolny klawisz aby kontynuowac lub [Esc] aby zrezygnowac",5)
  if lastkey()=27
    return nil
  endif
endif
kj_tkom(12," Ok! ","","Indeksacja zakonczona","Nacisnij dowolny klawisz.",5)
RETURN nil


*******************************************************************************
*LP_OPCJE                                                                      *
*******************************************************************************
*******************************************************************************
* Tworzy menu wydruku indywidualnego                                          *
*******************************************************************************
FUNCTION IND_DRUK_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
lbelka=   ""
ltnaz[1]:=" Karta pracownicza  "
ltnaz[2]:=" Raport  R M U A    "
ltlit[1]:=" K                  "
ltlit[2]:=" R                  "
ltopis[1]:="Indywidualna karta pracownicza"
ltopis[2]:="Raport miesieczny  RMUA"
  lpoz=men_pion(2,49,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

*******************************************************************************
* Tworzy menu precyzujace wydruk przelewow ZUS                                *
*******************************************************************************
FUNCTION PRZEL2_MENU(ppoz)
local ltnaz[4],ltlit[4],ltopis[4],lbelka:="",lpoz:=ppoz
lbelka=   ""
ltnaz[1]:=" Wszystkie      "
ltnaz[2]:=" Tylko konto 51 "
ltnaz[3]:=" Tylko konto 52 "
ltnaz[4]:=" Tylko konto 53 "
ltlit[1]:=" W                  "
ltlit[2]:="              1     "
ltlit[3]:="              2     "
ltlit[4]:="              3     "
ltopis[1]:="Sekwencyjny wydruk wszystkich przelewow  (na konto 51 52 oraz 53)"
ltopis[2]:="Wydruk przelewu tylko na konto 51"
ltopis[3]:="Wydruk przelewu tylko na konto 52"
ltopis[4]:="Wydruk przelewu tylko na konto 53"
  lpoz=men_pion(11,57,4,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


FUNCTION R_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
lbelka=   ""
ltnaz[1]:="  Strona  A  "
ltnaz[2]:="  Strona  B  "
ltlit[1]:="          A  "
ltlit[2]:="          B  "
ltopis[1]:="Wydruk strony A"
ltopis[2]:="Wydruk strony B"
  lpoz=men_pion(12,57,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION P11_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
lbelka=   ""
ltnaz[1]:="  Zbiorowy   "
ltnaz[2]:="Indywidualny "
ltlit[1]:="  Z          "
ltlit[2]:="I            "
ltopis[1]:="Sekwencyjny wydruk PIT-11 dla wszystkich przcownik¢w"
ltopis[2]:="Wydruk PIT-11 dla wybranego pracownika"
  lpoz=men_pion(13,57,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION RMUAFORMAT_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
lbelka=   ""
ltnaz[1]:=" Format  A   "
ltnaz[2]:=" Format  B   "
ltlit[1]:="         A   "
ltlit[2]:="         B   "
ltopis[1]:="Wydruk w formacie ZUS (druk zielony) "
ltopis[2]:="Wydruk na jednej stronie A4"
  lpoz=men_pion(11,52,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


FUNCTION ZPRZEL_PUBLIC()
public zrow:=0,zcol:=0,zdruk_il:=2,zprzelew:=.f.,zpieczec:=.f.,zk_spol:=space(2)
public zk_zdrow:=space(2),zk_fundusz:=space(2),znaz_czlon:=space(1)
public ztyp_ident:=space(1),ztyp_wplaty:=space(1),znum_deklar:=space(2)
public zprzel_mies:=space(2),zprzel_rok:=space(4),ztyp_pdruk:=1
public ztermin:=space(1),zkspol:=space(1),zkzdrow:=space(1),zkfundusz:=space(1)
RETURN

FUNCTION ZPRZEL_LAD()
zrow=row
zcol=col
zdruk_il=druk_il
zprzelew=przelew
zpieczec=pieczec
zk_spol=k_spol
zk_zdrow=k_zdrow
zk_fundusz=k_fundusz
zkspol=kspol
zkzdrow=kzdrow
zkfundusz=kfundusz
znaz_czlon=naz_czlon
ztyp_ident=typ_ident
ztyp_wplaty=typ_wplaty
znum_deklar=num_deklar
ztyp_pdruk=typ_pdruk
RETURN 

FUNCTION PRZEL_REPLAC()
replace row with zrow, col with zcol, druk_il with zdruk_il
replace przelew with zprzelew, pieczec with zpieczec
replace k_spol with zk_spol, k_zdrow with zk_zdrow, k_fundusz with zk_fundusz
replace kspol with zkspol, kzdrow with zkzdrow, kfundusz with zkfundusz
replace naz_czlon with znaz_czlon, typ_ident with ztyp_ident
replace typ_wplaty with ztyp_wplaty, num_deklar with znum_deklar
replace typ_pdruk with ztyp_pdruk
RETURN nil


* ptryb=0 - tylko pokaz (_SAY)
FUNCTION PRZEL_PAR(ptryb)
local lrow,lcol,ldruk_il,lprzelew,lpieczec,lcolor:=setcolor(),ltyp_pdruk
local lk_spol,lk_zdrow,lk_fundusz,lnaz_czlon,ltyp_ident,ltyp_wplaty,lnum_deklar 
local lkspol,lkzdrow,lkfundusz
local ltyt:="* P A R A M E T R Y    W Y D R U K U *",ltermin
g_tlo()
select 0
set default to lpset
if.not.kj_use("przelew",.f.,3)
  return .f.
endif
zprzel_lad()
zprzel_mies=zp_mies()
zprzel_rok=zp_rok()
lprzel_mies=zprzel_mies
lprzel_rok=zprzel_rok
lrow=row
lcol=col
ldruk_il=druk_il
lprzelew=przelew
lpieczec=pieczec
lk_spol=k_spol
lk_zdrow=k_zdrow
lk_fundusz=k_fundusz
lkspol=kspol
lkzdrow=kzdrow
lkfundusz=kfundusz
lnaz_czlon=naz_czlon
ltyp_ident=typ_ident
ltyp_wplaty=typ_wplaty
lnum_deklar=num_deklar
ltyp_pdruk=typ_pdruk
use

    if zw_lp
      if kj_use("lpfirma",.f.,3)
        locate for fnum=zfnum
		if found()
          if substr(skarbowy,2,1)="T"
		    lprzelew=.t.
		  else
		    lprzelew=.f.
		  endif	
		  if substr(skarbowy,3,1)="T"
		    lpieczec=.t.
		  else
		    lpieczec=.f.
		  endif	
		endif	  
	  endif	  
	  znaz_czlon=substr(skarbowy,4,1)
	  ztyp_ident=substr(skarbowy,5,1)
	  ztermin=substr(skarbowy,6,1)
	  zprzelew=lprzelew
      zpieczec=lpieczec
	  lnaz_czlon=znaz_czlon
	  ltyp_ident=ztyp_ident
	  ltermin=ztermin
	  use
	endif


kj_okno(6,0,17,ltyt,8)
@ 8,3 say "Numer deklaracji .........."
@ 9,3  say "Data: miesiac ............."
@ 10,3  say "Data: rok ................."
@ 11,3 say "Przesuniecie w pionie ....."
@ 12,3 say "Przesuniecie w poziomie ..."
@ 13,3 say "Ilosc wydrukow ............"
@ 14,3 say "Przelew bankowy ........ .."
@ 15,3 say "Wydruk pieczeci ..........." 
@ 16,3 say "Ub.spoleczne:  konto ......"
@ 17,3 say "Ub.zdrowotne:  konto ......"
@ 18,3 say "Fundusz pracy: konto ......"
@ 19,3 say "Nazwa platnika ............"
@ 20,3 say "Typ id. uzupelniajacego ..."
@ 21,3 say "Typ wplaty ................"
set color to n/w,w/n
if ptryb=1
  do while.t.
    set cursor on
    @ 8,31 get znum_deklar when s_kom("Numer deklaracji zwiazanej z powyzsza wplata (w postaci dwuznakowej np. 00 01 02")
    @ 9, 31 get zprzel_mies when s_kom("Numer miesiaca ktorego dotyczy wplata.") 
    @ 10, 29 get zprzel_rok when s_kom("Rok ktorego dotyczy wplata.") 
	@ 11,30 get zrow picture "999" when s_kom("Przesuniecie w pionie - ilosc wierszy.")
    @ 12,30 get zcol picture "999" when s_kom("Przesuniecie w poziomie -  ilosc kolumn.")
    @ 13,30 get zdruk_il picture "999"when s_kom("Ilosc wydrukow tego samego typu.")
    @ 14,32 get zprzelew when s_kom("T - platne w formie przelewu bankowego   F - platne gotowka")
    @ 15,32 get zpieczec when s_kom("T - drukuj dane wplacajacego   F - pozostaw puste miejsce na pieczatke")
    @ 16,28 get zk_spol when s_kom("Pierwszy czlon konta ubezpieczen spolecznych") 
    @ 16,31 get zkspol when s_kom("Koncowka konta ubezpieczen spolecznych") 
    @ 17,28 get zk_zdrow when s_kom("Pierwszy czlon konta ubezpieczen zdrowotnych") 
    @ 17,31 get zkzdrow when s_kom("Koncowka konta ubezpieczen zdrowotnych") 
    @ 18,28 get zk_fundusz when s_kom("Pierwszy czlon konta funduszu pracy")
    @ 18,31 get zkfundusz when s_kom("Koncowka konta funduszu pracy")	
    @ 19,32 get znaz_czlon when s_kom("1 - drukuj pierwszy czlon nazwy  2 - drukuj drugi czlon nazwy ")
    @ 20,32 get ztyp_ident  picture "!" when s_kom("P - pesel      R - regon")
    @ 21,32 get ztyp_wplaty  picture "!" when s_kom("S-skladka za 1 miesiac,  {M,U,T,D,E,K}-zgodnie z opisem na poleceniu przelewu") 
    @ 22,32 get ztermin  picture "!" when s_kom("Termin przysylania deklaracji i raportow")
    read
	if.not.ztyp_ident$"RP12"
      do while.t.
	    @ 20,32 get ztyp_ident picture "!" when s_kom("Wpisz znak ze zbioru {P,R,1,2} zgodnie z opisem na druku polecenia przelewu.")
	    read
	    if ztyp_ident$"RP12".or.lastkey()=27
	      exit
	    endif
	  enddo	  
	endif		
	if.not.ztyp_wplaty$"SMUTDEK"
      do while.t.
	    @ 21,32 get ztyp_wplaty picture "!" when s_kom("Wpisz znak ze zbioru {S,M,U,T,D,E,K} zgodnie z opisem na druku polecenia przel.")
	    read
	    if ztyp_ident$"RP12".or.lastkey()=27
	      exit
	    endif
	  enddo	  
	endif			
    exit
  enddo
  set cursor off
endif 
if lastkey()=27
  setcolor(lcolor)
  prac_default()
  return
endif
@ 8,31 say znum_deklar
@ 9, 31 say zprzel_mies
@ 10, 29 say zprzel_rok
@ 11,30 say zrow picture "999"
@ 12,30 say zcol picture "999"
@ 13,30 say zdruk_il picture "999"
@ 14,32 say zprzelew
@ 15,32 say zpieczec  
@ 16,28 say zk_spol
@ 17,28 say zk_zdrow
@ 18,28 say zk_fundusz
@ 16,31 say zkspol
@ 17,31 say zkzdrow
@ 18,31 say zkfundusz
@ 19,32 say znaz_czlon
@ 20,32 say ztyp_ident
@ 21,32 say ztyp_wplaty
@ 22,32 say ztermin
if zrow#lrow.or.zcol#lcol.or.zdruk_il#ldruk_il.or.zprzelew#lprzelew.or.zpieczec#lpieczec;
   .or.zk_spol#lk_spol.or.zk_zdrow#lk_zdrow.or.zk_fundusz#lk_fundusz.or.;
   zkspol#lkspol.or.zkzdrow#lkzdrow.or.zkfundusz#lkfundusz.or.;   
   znaz_czlon#lnaz_czlon.or.ztyp_ident#ltyp_ident.or.ztyp_wplaty#ltyp_wplaty;
   .or.znum_deklar#lnum_deklar.or.ztyp_pdruk#ltyp_pdruk
  if kj_gkom(12,"","Zapamietac wprowadzone zmiany ?","",.t.,5)
    if kj_use("przelew",.t.,3)
      przel_replac()
      use
	endif         
    if zw_lp
      if kj_use("lpfirma",.t.,3)
        locate for fnum=zfnum
		if found()
		  if zprzelew
		    replace skarbowy with stuff(skarbowy,2,1,"T")
		  else
		    replace skarbowy with stuff(skarbowy,2,1,"F")		  
		  endif
		  if zpieczec
		    replace skarbowy with stuff(skarbowy,3,1,"T")
		  else
		    replace skarbowy with stuff(skarbowy,3,1,"F")		  
		  endif		  
          replace skarbowy with stuff(skarbowy,4,1,znaz_czlon)
		  replace skarbowy with stuff(skarbowy,5,1,ztyp_ident)
		  replace skarbowy with stuff(skarbowy,6,1,ztermin)
		endif	  
	    use
	  endif	  
	endif
  endif
endif
setcolor(lcolor)
prac_default()
RETURN .t.


FUNCTION ZP_MIES()
local lmies:=space(2)
do case
  case month(date())=1
    lmies="12"
  case month(date())=2
    lmies="01"
  case month(date())=3
    lmies="02"
  case month(date())=4
    lmies="03"
  case month(date())=5
    lmies="04"
  case month(date())=6
    lmies="05"
  case month(date())=7
    lmies="06"
  case month(date())=8
    lmies="07"
  case month(date())=9
    lmies="08"
  case month(date())=10
    lmies="09"
  case month(date())=11
    lmies="10"
  case month(date())=12
    lmies="11"										
endcase
RETURN lmies

FUNCTION ZP_ROK()
local lrok:=space(4)
if month(date())=1
  lrok=str(year(date())-1,4)
else
  lrok=str(year(date()),4)
endif
RETURN lrok



FUNCTION ZRMUA_PUBLIC()
public zrow:=0,zcol:=0,zdruk_il:=2,zpion_ster:="",znum_deklar:=space(2)
public zrmdat:=date(),zrmua_mies:="",zrmua_rok:=""
RETURN

FUNCTION ZWLAS_PUBLIC()
public zwl_kodnum:=1,zwl_spol:=.t.
public zrmnazwisko:=space(30),zrmimie:=space(30),zrmnazwa:=space(30) 
public zrmdata_ur:=ctod("  .  .    ")
RETURN

FUNCTION ZRMUA_LAD()
zrow=row
zcol=col
zdruk_il=druk_il
znum_deklar=num_deklar
zpion_ster=pion_ster
*zrmnazwisko=rmnazwisko
*zrmimie=rmimie
*zrmnazwa=rmnazwa
*zrmdata_ur=rmdata_ur
RETURN 

FUNCTION RMUA_REPLAC()
replace row with zrow, col with zcol, druk_il with zdruk_il
replace num_deklar with znum_deklar,pion_ster with zpion_ster
*replace rmnazwisko with zrmnazwisko,rmimie with zrmimie
*replace rmnazwa with zrmnazwa,rmdata_ur with zrmdata_ur
RETURN nil


* ptryb=0 - tylko pokaz (_SAY)
FUNCTION RMUA_PAR(ptryb,pdok,psek)
local lrow,lcol,ldruk_il,lnum_deklar,lnazwisko,limie,lnazwa,ldata_ur,ltermin 
local lrmua_mies,lrmua_rok,lrmdat,lcolor:=setcolor(),ek,lbaza:=""
local ltyt:="          *    P A R A M E T R Y     W Y D R U K U    *          "
local select:=select(),recno:=recno()
do case
  case pdok=1
    lbaza="rmua"
  case pdok=2
    lbaza="rna"	
  case pdok=3
    lbaza="rca"
  case pdok=4
    lbaza="dra"				
endcase
save screen to ek
g_tlo()
select 0
set default to lpset
if.not.kj_use(lbaza,.f.,3)
  return .f.
endif
zrmua_lad()
if.not.psek=1               && jesli wydruk sekwencyjny
  zrmua_mies=zp_mies()
else                        && jesli wydruk pojedynczy
  zrmua_mies=str(zmiesiac,2)
endif  
zrmua_rok=zp_rok()
lrmua_mies=zrmua_mies
lrmua_rok=zrmua_rok
lrmdat=zrmdat
lrow=row
lcol=col
ldruk_il=druk_il
lnum_deklar=num_deklar
lnazwisko=rmnazwisko
limie=rmimie
lnazwa=rmnazwa
ldata_ur=rmdata_ur
use

*    if zw_lp
      if kj_use("lpfirma",.f.,3)
        locate for fnum=zfnum
		if found()
          zrmnazwisko=sk_miasto
		  zrmimie=sk_ulica
		  zrmnazwa=zus
		  zrmdata_ur=ctod(substr(zus_miasto,1,10))
		  ztermin=substr(zskarbowy,6,1)
		  lnazwisko=zrmnazwisko
		  limie=zrmimie
		  lnazwa=zrmnazwa
		  ldata_ur=zrmdata_ur
		  ltermin=ztermin
		endif	  
	    use
	  endif	  


kj_okno(9,0,14,ltyt,8)
@ 11,3 say "Numer deklaracji .........."
@ 12,3  say "Za miesiac .. ............."
@ 13,3  say "W roku ...................."
@ 14,3 say "Data wypelnienia .... ....."
@ 15,3 say "Przesuniecie w pionie ....."
@ 16,3 say "Przesuniecie w poziomie ..."
@ 18,3 say "Platnik: Nazwisko ........."
@ 19,3 say "         Imie ............."
@ 20,3 say "         Data urodzenia ..."
@ 21,3 say "         Nazwa skrocona ..."
if pdok=4
  @ 22,3 say "         Termin wysylania ."
endif
set color to n/w,w/n
if ptryb=1
  do while.t.
    set cursor on
    @ 11,31 get znum_deklar when s_kom("Numer raportu miesiecznego (w postaci dwuznakowej np. 00 01 02)")
    if.not.psek=1
	  @ 12, 31 get zrmua_mies when s_kom("Numer miesiaca ktorego dotyczy raport.") 
    endif
	@ 13, 29 get zrmua_rok when s_kom("Rok ktorego dotyczy raport.") 
	@ 14,25 get zrmdat  when s_kom("Data wypelnienia raportu (dd/mm/rr).")
	@ 15,30 get zrow picture "999" when s_kom("Przesuniecie w pionie - ilosc wierszy.")	
    @ 16,30 get zcol picture "999" when s_kom("Przesuniecie w poziomie -  ilosc kolumn.")
	@ 18,30 get zrmnazwisko  when s_kom("Dane identyfikacyjne platnika skladek - II/06 Nazwisko")
	@ 19,30 get zrmimie  when s_kom("Dane identyfikacyjne platnika skladek - II/07 	Imie pierwsze")
	@ 20,30 get zrmdata_ur when s_kom("Dane identyfikacyjne platnika skladek - II/09 Data urodzenia")		
    @ 21,30 get zrmnazwa  when s_kom("Dane identyfikacyjne platnika skladek - II/08 Nazwa skrocona")	
	if pdok=4
	  @ 22,30 get ztermin  when s_kom("Termin wysylania deklaracji i raportow")
    endif
    read
    exit
  enddo
  set cursor off
endif 
if lastkey()=27
  setcolor(lcolor)
  restore screen from ek
  prac_default()
  return
endif
@ 11,31 say znum_deklar
@ 12, 31 say zrmua_mies
@ 13, 29 say zrmua_rok
@ 14,25 say zrmdat 
@ 15,30 say zrow picture "999"
@ 16,30 say zcol picture "999"
@ 18,30 say zrmnazwisko
@ 19,30 say zrmimie
@ 20,30 say zrmdata_ur
@ 21,30 say zrmnazwa
if pdok=4
  @ 22,30 say ztermin
endif
if zrow#lrow.or.zcol#lcol.or.zdruk_il#ldruk_il.or.znum_deklar#lnum_deklar;
     .or.zrmua_mies#lrmua_mies.or.zrmua_rok#lrmua_rok.or.zrmdat#lrmdat;
 	 .or.zrmnazwisko#lnazwisko.or.zrmimie#limie.or.zrmdata_ur#ldata_ur;
 	 .or.zrmnazwa#lnazwa.or.ztermin#ltermin	 
* 	 .or.zrmnazwa#lnazwa
  if kj_gkom(12,"","Zapamietac wprowadzone zmiany ?","",.t.,5)
    if kj_use(lbaza,.t.,3)
      rmua_replac()
      use
	endif         
   * if zw_lp
      if kj_use("lpfirma",.t.,3)
        locate for fnum=zfnum
	    if found()
          replace sk_miasto with zrmnazwisko,sk_ulica with zrmimie
		  replace zus with zrmnazwa
          replace  zus_miasto with stuff(zus_miasto,1,10,dtoc(zrmdata_ur))
	      replace skarbowy with stuff(skarbowy,6,1,ztermin)
		endif	  
        use
      endif	  
   * endif      
  endif
endif
setcolor(lcolor)
prac_default()
if psek=1 
  select &select
  go recno
endif  
RETURN .t.



FUNCTION IND_DRUK()
local lind:=1,ek
save screen to ek
g1_tlo()
lind=ind_druk_menu(lind)
if.not.lastkey()=27
  do case
    case lind=1
      karta_druk()
    case lind=2
      if file("lpset\rmua.dbf")
	    rmua_zus(1)
	  else
	    kj_tkom(10," Uwaga !","Opcja w tej wersji programu nie jest dostepna.","Nalezy w porozumieniu ze sprzedawca"," doinstalowac dodatkowe oprogramowanie.",5) 
	  endif	
    case lind=3
      if file("lpset\rna.dbf")
	    rna_zus(1)	  
	  else
	    kj_tkom(10," Uwaga !","Opcja w tej wersji programu nie jest dostepna.","Nalezy w porozumieniu ze sprzedawca"," doinstalowac dodatkowe oprogramowanie.",5) 
	  endif		  	
  endcase
endif  
restore screen from ek
RETURN nil



FUNCTION ALL_RMUA(pstrona)
local ek,recno:=recno(),lmiesiac:=zmiesiac
save screen to ek
use
select 0
zmiesiac=val(zrmua_mies)
if prac_use(val(zrmua_mies))
  do while.not.eof().and..not.inkey()=27
    p_lad()
	if pstrona=="A"
	  rmua_adruk()
	else
	  rmua_bdruk()
	endif  
    skip
  enddo  
  use
else
  return .f.
endif  
restore screen from ek
zmiesiac=lmiesiac
prac_default()
*prac_use(zmiesiac)
*go recno
RETURN .t.


* psek=0 wydruk sekwencyjny  psek=1 wydruk pojedynczego pracownika
FUNCTION RMUA_ZUS(psek)
local l_druk1:=1,l_druk2:=1,ek,ek1,select:=select(),lsek:=psek
local lrmua_format:=1
save screen to ek
		  if psek=1
		    zrmua_mies=str(zmiesiac,2)
*            kj_tkom(12,"","","Wydruk strony pierwszej","",5)
*				    rmua_adruk()
*			kj_tkom(12,"","","Wydruk strony drugiej","",5)		
*				    rmua_bdruk()
*			kj_skom(12,"","","Wydruk RMUA zakonczony pomyslnie","",5)		
*					RETURN
		  endif	
		    rmua_par(0,1,lsek)
*			browse()		    
			do while.t.
			  l_druk1=rmua_menu(l_druk1)
			  do case
			    case lastkey()=27
				  exit
				case l_druk1=1
				  lrmua_format=rmuaformat_menu(lrmua_format)
				  if psek=1
				    if lrmua_format=1
					  rmua_adruk()
				      rmua_bdruk()
					else
					  rmua_bformat()
					endif  
				  else
				  * 
				    if lrmua_format=1
				      save screen to ek1
				      do while.t.
				        l_druk2=r_menu(l_druk2)
					    if lastkey()=27
					      restore screen from ek1
					      exit
					    endif
					      do case
						    case l_druk2=1
						      all_rmua("A")
						    case l_druk2=2
						      all_rmua("B")							
						  endcase
					  enddo  					  
				  *
				   * all_rmua()
				    else
					  allrmua_bformat()
					endif
				  endif	
			    case l_druk1=2
			      rmua_par(1,1,lsek)            				
                  l_druk1=1
				  
				case l_druk1=3.or.l_druk1=0
			      exit
			  endcase
			enddo  
restore screen from ek
prac_default()
select &select
RETURN nil





FUNCTION RNA_ZUS(psek)
local l_druk1:=1,l_druk2:=1,ek,ek1,select:=select(),lsek:=psek
save screen to ek
if psek=1
  zrmua_mies=str(zmiesiac,2)
endif  
		    rmua_par(0,2,lsek)
			do while.t.
			  l_druk1=rmua_menu(l_druk1)
			  do case
			    case lastkey()=27
				  exit
				case l_druk1=1
				  if psek=1
				    vstr=1
                     rna_adruk(.t.,"rca")
*                    rna_wsbdruk(1) 					
*					rna_adruk()
*				    rna_bdruk()
				  else
				    save screen to ek1
				    do while.t.
				      l_druk2=r_menu(l_druk2)
					  if lastkey()=27
					    restore screen from ek1
					    exit
					  endif
					    do case
						  case l_druk2=1
						    all_rna("A")
						  case l_druk2=2
						    all_rna("B")							
						endcase
					enddo  	
				  endif	
			    case l_druk1=2
			      rmua_par(1,2,lsek)            				
                  l_druk1=1
				case l_druk1=3.or.l_druk1=0
			      exit
			  endcase
			enddo  
restore screen from ek
prac_default()
select &select
RETURN nil

FUNCTION RCA_ZUS(psek)
local l_druk1:=1,l_druk2:=1,ek,select:=select(),lsek:=psek
save screen to ek
if psek=1
  zrmua_mies=str(zmiesiac,2)
endif  
		    rmua_par(0,3,lsek)
			do while.t.
			  l_druk1=rmua_menu(l_druk1)
			  do case
			    case lastkey()=27
				  exit
				case l_druk1=1
				  if psek=1
				    vstr=1
                     rna_adruk(.f.,"rca")
*                    rna_wsbdruk(1) 					
*					rna_adruk()
*				    rna_bdruk()
				  else
				    save screen to ek1
				    do while.t.
				      l_druk2=r_menu(l_druk2)
					  if lastkey()=27
					    restore screen from ek1
					    exit
					  endif
					    do case
						  case l_druk2=1
						    all_rca("A")
						  case l_druk2=2
						    all_rca("B")							
						endcase
					enddo
				  endif	
			    case l_druk1=2
			      rmua_par(1,3,lsek)            				
                  l_druk1=1
				case l_druk1=3.or.l_druk1=0
			      exit
			  endcase
			enddo  
restore screen from ek
prac_default()
select &select
RETURN nil

FUNCTION DRA_ZUS(p_sek)
local l_druk1:=1,l_druk2:=1,ek,select:=select(),lsek:=p_sek
public z5_01:=0,z5_02:=0,z5_03:=0,z6_01:=0,z8_02:=0
public z3_01:=0, z3_02:=0,z4_04:=0,z4_05:=0,z4_07:=0,z4_08:=0
public z4_22:=0,z4_23:=0,z4_25:=0,z5_04:=0,z7_01:=0,z8_01:=0
save screen to ek
zrmua_mies=str(zmiesiac,2)
		    rmua_par(0,4,lsek)  &&lsek=1 wymusza wydruk za wskazany miesiac
			do while.t.
			  l_druk1=rmua_menu(l_druk1)
			  do case
			    case lastkey()=27
				  exit
				case l_druk1=1
				    save screen to ek1
	                  if kj_gkom(3,"     DEKLARACJA  DRA","Czy chcesz uzupelnic dane ?","",.t.,7)
					    dra_uzup()
					  endif					
				      dra_licz()
					do while.t.
			
					  l_druk2=r_menu(l_druk2)
					  if lastkey()=27
					    restore screen from ek1
					    exit
					  endif
					    do case
						  case l_druk2=1
						    dra_adruk()
						  case l_druk2=2
						    dra_bdruk()							
						endcase
					enddo
			    case l_druk1=2
			      rmua_par(1,4,lsek)            				
                  l_druk1=1
				case l_druk1=3.or.l_druk1=0
			      exit
			  endcase
			enddo  
restore screen from ek
prac_default()
select &select
RETURN nil


FUNCTION PRZEL_ZUS()
local l_druk1:=1,ek,ek1,lmiesiac:=zmiesiac,recno:=recno()
local l_druk2:=1
use

save screen to ek
		    przel_par(0)
			do while.t.
			  l_druk1=przel_menu(l_druk1)
			  do case
			    case lastkey()=27
				  exit
				case l_druk1=1
				  save screen to ek1
			      *przel_druk()
				  zmiesiac=val(zprzel_mies)            
				  do while.t.
				    l_druk2=przel2_menu(l_druk2)
				    if lastkey()=27
					  restore screen from ek1
					  exit
					endif
					do case
					  case l_druk2=1
					    skladki_mies(3)
					  case l_druk2=2
					    skladki_mies(4)
					  case l_druk2=3
					    skladki_mies(5)
					  case l_druk2=4
					    skladki_mies(6)																		
					endcase	
				  enddo
			    case l_druk1=2
			      przel_par(1)            				
                  l_druk1=1
				case l_druk1=3.or.l_druk1=0
			      exit
			  endcase
			enddo  
restore screen from ek
zmiesiac=lmiesiac
RETURN nil


FUNCTION ALL_RNA(pstrona)
local ek,lwspolprac:=val(substr(zskarbowy,1,1)),lmiesiac:=zmiesiac,recno:=recno()
local select:=select()
save screen to ek
use
select 0
zmiesiac=val(zrmua_mies)

if prac_use(zmiesiac)
  if pstrona=="A"
    vstr=1
    do case
      case lwspolprac=0.or.(lwspolprac=1.and.zw1_spol=.f.).or.(lwspolprac=2.and.zw1_spol=.f..and.zw2_spol=.f.)
        if zwl_spol
	      rna_wladruk("rna")	
		  skip
    	else
          vstr=vstr-1
		endif
        do while.not.eof().and..not.inkey()=27
		  vstr=vstr+1
	      p_lad()
	      rna_adruk(.t.,"rna")
          skip 2
        enddo  
        use		

      case lwspolprac=1.or.(lwspolprac=2.and.zw2_spol=.f.)
        do case
		  case zwl_spol.and.zw1_spol
		    rna_wladruk("rna")	

		  case zwl_spol.and..not.zw1_spol	
            rna_wladruk("rna")							
		    skip
		  case.not.zwl_spol.and.zw1_spol		
            rna_wsadruk(.t.,1,"rna")
			skip		    
		  case.not.zwl_spol.and..not.zw1_spol		
            vstr=vstr-1
		endcase
        do while.not.eof().and..not.inkey()=27
		  vstr=vstr+1
	      p_lad()
	      rna_adruk(.t.,"rna")
          skip 2
        enddo  
        use		  

      case lwspolprac=2
        do case
          case zwl_spol.and.zw1_spol.and.zw2_spol
		    rna_wladruk("rna")	
	        vstr=vstr+1
		    rna_wsadruk(.t.,2,"rna")					
	        skip
          case zwl_spol.and..not.zw1_spol.and.zw2_spol			
		    rna_wladruk("rna")				
          case.not.zwl_spol.and.zw1_spol.and.zw2_spol						
            rna_wsadruk(.t.,1,"rna")					
          case.not.zwl_spol.and..not.zw1_spol.and.zw2_spol									
		    rna_wsadruk(.t.,2,"rna")					
			skip
          case.not.zwl_spol.and.zw1_spol.and..not.zw2_spol
		    rna_wsadruk(.t.,1,"rna")
			skip														
          case.not.zwl_spol.and..not.zw1_spol.and..not.zw2_spol									
            vstr=vstr-1
		endcase
        do while.not.eof().and..not.inkey()=27
          vstr=vstr+1
	      p_lad()
	      rna_adruk(.t.,"rna")
          skip 2
        enddo  
        use		  									
   endcase
**
  else         && Strona B
**
    do case
      case lwspolprac=0.or.(lwspolprac=1.and.zw1_spol=.f.).or.(lwspolprac=2.and.zw1_spol=.f..and.zw2_spol=.f.)
        if.not.zwl_spol 
		  skip
		endif  
        do while.not.eof().and..not.inkey()=27
          p_lad()
	      rna_adruk(.f.,"rna")
          skip 2
        enddo    
        use		
	  	    
      case lwspolprac=1.or.(lwspolprac=2.and.zw2_spol=.f.)
        do case
		  case zwl_spol.and.zw1_spol
		    rna_wsadruk(.f.,1,"rna")
			skip

		  case zwl_spol.and..not.zw1_spol		
          case .not.zwl_spol.and.zw1_spol					  
          case .not.zwl_spol.and..not.zw1_spol					  			
		    skip
		endcase
        do while.not.eof().and..not.inkey()=27
          p_lad()
	      rna_adruk(.f.,"rna")
          skip 2
        enddo    
        use				  		

      case lwspolprac=2
        do case
          case zwl_spol.and.zw1_spol.and.zw2_spol
		    rna_wsadruk(.f.,1,"rna")					
          case zwl_spol.and..not.zw1_spol.and.zw2_spol			
            rna_wsadruk(.f.,2,"rna")					
          case.not.zwl_spol.and.zw1_spol.and.zw2_spol						
            skip
			rna_wsadruk(.f.,2,"rna")					
          case.not.zwl_spol.and..not.zw1_spol.and.zw2_spol									
          case.not.zwl_spol.and.zw1_spol.and..not.zw2_spol
          case.not.zwl_spol.and..not.zw1_spol.and..not.zw2_spol									
            skip
		endcase
        do while.not.eof().and..not.inkey()=27
	      p_lad()
	      rna_adruk(.f.,"rna")
          skip 2
        enddo  
        use		  									
    endcase
  endif
else
  return .f.
endif  
restore screen from ek
zmiesiac=lmiesiac
prac_default()
*select &select
*go recno
RETURN .t.


FUNCTION ALL_RCA(pstrona)
local ek,lwspolprac:=val(substr(zskarbowy,1,1)),lmiesiac:=zmiesiac,recno:=recno()
local lastrec,l_eject,last:=0
public stron_sum:=0
save screen to ek
use
select 0
zmiesiac=val(zrmua_mies)
if prac_use(zmiesiac)
***
  lastrec=lastrec()

  if pstrona=="A"
    vstr=1
    do case
      case lwspolprac=0.or.(lwspolprac=1.and.zw1_spol=.f.).or.(lwspolprac=2.and.zw1_spol=.f..and.zw2_spol=.f.)
        if zwl_spol
	      rna_wladruk("rca")
          p_lad()
	      w=w+7
	      rna_adruk(.f.,"rca_2")
          w=w+2
	      l_eject=.t.
	      stronsum_druk(l_eject)
	      skip 3	  
	      stron_sum=0
    	else
          vstr=vstr-1
		endif
		
      case lwspolprac=1.or.(lwspolprac=2.and.zw2_spol=.f.)
        do case
		  case zwl_spol.and.zw1_spol
	        rna_wladruk("rca")
            w=w+7
            rna_wsadruk(.f.,1,"rca_2")      
	        w=w+7
            l_eject=.t.
	        stronsum_druk(l_eject)
	        skip 2	  
            stron_sum=0
		  case zwl_spol.and..not.zw1_spol	
	        rna_wladruk("rca")
            w=w+7
			p_lad()
            rna_adruk(.f.,"rca_2")
			w=w+2
            l_eject=.t.
	        stronsum_druk(l_eject)
	        skip 3	  
            stron_sum=0
		  case.not.zwl_spol.and.zw1_spol		
            rna_wsadruk(.t.,1,"rca_1")      
            w=w+7
			p_lad()
            rna_adruk(.f.,"rca_2")
			w=w+2
            l_eject=.t.
	        stronsum_druk(l_eject)
	        skip 3	  
            stron_sum=0
		  case.not.zwl_spol.and..not.zw1_spol		
		    vstr=vstr-1
		endcase

      case lwspolprac=2
        do case
          case zwl_spol.and.zw1_spol.and.zw2_spol
	        rna_wladruk("rca")
            w=w+7
            rna_wsadruk(.f.,1,"rca_2")      
            w=w+7
            l_eject=.t.
            stronsum_druk(l_eject)
	        skip 	  
            stron_sum=0
          case zwl_spol.and..not.zw1_spol.and.zw2_spol			
	        rna_wladruk("rca")
            w=w+7
            rna_wsadruk(.f.,2,"rca_2")      
            w=w+7
            l_eject=.t.
            stronsum_druk(l_eject)
	        skip 2  
            stron_sum=0
          case.not.zwl_spol.and.zw1_spol.and.zw2_spol						
            rna_wsadruk(.t.,1,"rca_1")      
            w=w+7
            rna_wsadruk(.f.,2,"rca_2")      
			w=w+7
			l_eject=.t.
	        stronsum_druk(l_eject)
	        skip 3	  
            stron_sum=0
          case.not.zwl_spol.and..not.zw1_spol.and.zw2_spol									
            rna_wsadruk(.t.,2,"rca_1")      
            w=w+7
   	        rna_adruk(.f.,"rca_2")
			w=w+2
			l_eject=.t.
	        stronsum_druk(l_eject)
	        skip 3	  
            stron_sum=0
          case.not.zwl_spol.and.zw1_spol.and..not.zw2_spol
            rna_wsadruk(.t.,1,"rca_1")      
            w=w+7
   	        rna_adruk(.f.,"rca_2")
			w=w+2
			l_eject=.t.
	        stronsum_druk(l_eject)
	        skip 3	  
            stron_sum=0
          case.not.zwl_spol.and..not.zw1_spol.and..not.zw2_spol									
		    vstr=vstr-1
		endcase
   endcase
	    do while.not.eof().and..not.inkey()=27      &&Wydruk pracownikow
		  vstr=vstr+1
	      p_lad()
	      rna_adruk(.t.,"rca_1")
          skip 
		  if.not.eof()
		    p_lad()
		    w=w+2
	        rna_adruk(.f.,"rca_2")
            w=w+2
            l_eject=.t.
            stronsum_druk(l_eject)
		    skip 3	
		  else
            w=w+24
            l_eject=.t.
            stronsum_druk(l_eject)
		  endif  	
		  stron_sum=0
        enddo  
		use		   
   
**
  else         && Strona B
**
    do case
      case lwspolprac=0.or.(lwspolprac=1.and.zw1_spol=.f.).or.(lwspolprac=2.and.zw1_spol=.f..and.zw2_spol=.f.)
        if zwl_spol 
          last=1
          go top
          skip
		else
          last=2
		  go top
		  skip 2 
		endif  

	  	    
      case lwspolprac=1.or.(lwspolprac=2.and.zw2_spol=.f.)
        do case
		  case zwl_spol.and.zw1_spol
			go top
		  case zwl_spol.and..not.zw1_spol		
            last=1
			go top
			skip
          case .not.zwl_spol.and.zw1_spol					  
            last=1
			go top
			skip 
          case .not.zwl_spol.and..not.zw1_spol					  			
            last=2
			go top
			skip 2		  
		endcase
		

      case lwspolprac=2
        do case
          case zwl_spol.and.zw1_spol.and.zw2_spol
            rna_wsadruk(.f.,2,"rca_1")      
		    p_lad()
			w=w+7
		    rna_adruk(.f.,"rca_2")
            w=w+2
	        l_eject=.f.
	        stronsum_druk(l_eject)
		    dat_druk(3,5)
			skip 3	
          case zwl_spol.and..not.zw1_spol.and.zw2_spol			
            go top
          case.not.zwl_spol.and.zw1_spol.and.zw2_spol						
            go top
          case.not.zwl_spol.and..not.zw1_spol.and.zw2_spol									
            go top
			skip
          case.not.zwl_spol.and.zw1_spol.and..not.zw2_spol
            go top
			skip
          case.not.zwl_spol.and..not.zw1_spol.and..not.zw2_spol									
            skip 2 
		endcase

    endcase
		if lastrec>last
	      do while.not.eof().and..not.inkey()=27
	        p_lad()
	        rna_adruk(.f.,"rca_1")
            skip 
		    if.not.eof()
		      p_lad()
			  w=w+2
	          rna_adruk(.f.,"rca_2")
              w=w+2
	          l_eject=.f.
	          stronsum_druk(l_eject)
			  dat_druk(3,5)
			  skip 3	
		    else
              w=w+24
	          l_eject=.f.
	          stronsum_druk(l_eject)
			  dat_druk(3,5)
		    endif		
            stron_sum=0
		  enddo  	  
          use		
		endif  		
	
  endif

***

  
else
  return .f.
endif  
restore screen from ek
zmiesiac=lmiesiac
prac_default()
*go recno
RETURN .t.

FUNCTION WLAS_KOD()
local ek
zkod_num:=val(alltrim(substr(zsk_kod,1,2)))
save screen to ek
*g_tlo()

select 0
set default to lpset
if file("ub_kod.dbf")
  if kj_use("ub_kod",.f.,3)
    kod_sel=select()
    locate for num=zkod_num
	if found()
	  lkod=kod
	else
	  go top
	endif  

  endif
endif
KEYBOARD CHR(205)
kod_slow(.f.)
zwl_kodnum=num
use
zsk_kod=stuff(zsk_kod,1,2,str(zwl_kodnum,2))
restore screen from ek
RETURN .t.

FUNCTION WSPOL_KOD(pwspol)
local ek
save screen to ek
if pwspol=1
  zkod_num=zw1_kodnum
else
  zkod_num=zw2_kodnum
endif  
*g_tlo()
s_kom("Wybierz kod tytulu ubezpieczenia osoby wspolpracujacej")
select 0
set default to lpset
if file("ub_kod.dbf")
  if kj_use("ub_kod",.f.,3)
    kod_sel=select()
    locate for num=zkod_num
	if found()
	  lkod=kod
	else
	  go top
	endif  
  endif
endif
kod_slow(.t.)         &&zkod_num = numer w bazie
*if lastkey()=27
*  return
*endif
if pwspol=1
  zw1_kodnum=num
  zzus_k1=stuff(zzus_k1,67,2,str(num,2))
else
  zw2_kodnum=num
  zzus_k2=stuff(zzus_k2,67,2,str(num,2))  
endif
use
restore screen from ek
RETURN .T.


FUNCTION DRA_UZUP()
local ek,ltyt:=" *  DEKLARACJA ROZLICZENIOWA   D R A  -  DANE UZUPELNIAJACE  * "
local lw:=4,lk:=11
save screen to ek
g_tlo()
kj_okno(4,8,8,ltyt,5)
@ lw+2,lk say "Kwota swiadczen z ub. chorobowego ..........."
@ lw+4,lk say "Kwota wynagrodzenia od swiadczen ............"
@ lw+6,lk say "Kwota swiadczen z ub. wypadkowego ..........."
set cursor on
@ lw+2,lk+45 get z5_01 picture "9999999.99" when s_kom("Kwota wyplaconych swiadczen z ubezpieczenia chorobowego")
@ lw+4,lk+45 get z5_02 picture "9999999.99" when s_kom("Kwota wynagrodzenia naleznego platnikowi od wypl. swiadczen z ub. chorobowego")
@ lw+6,lk+45 get z5_03 picture "9999999.99" when s_kom("Kwota wyplaconych swiadczen z ubezpieczenia wypadkowego")
read
set cursor off
restore screen from ek
RETURN nil

FUNCTION DRA_ZER()
z3_01=0
z3_02=0
z4_04=0
z4_05=0
z4_07=0
z4_08=0
z4_22=0
z4_23=0
z4_25=0
z5_04=0
z7_01=0
z8_01=0
z8_02=0
RETURN nil

FUNCTION DRA_LICZ()
local lemeryt_sum:=0,lrent_sum:=0,lchorob_sum:=0,lwypad_sum:=0
local lzdrow_sum:=0,llicz_d7_all:=0,lzasilki_sum:=0
local lastrec:=0,llpodstawp:=zlpodstawp,llpodstaw1:=zlpodstaw1,llpodstaw2:=zlpodstaw2
local llpod_zdrow:=zlpod_zdrow
public z11:=.f.,z11_01:=""
dra_zer()
*if zwl_spol
*  z3_01=z3_01+1
*endif
z3_01=1
if zwspol_ile>0
  z3_01=z3_01+1
endif
if zwspol_ile>1
  z3_01=z3_01+1
endif
use
select 0
zmiesiac=val(zrmua_mies)
if prac_use(zmiesiac)
  lastrec:=lastrec()
  do while.not.eof()
    p_lad()
	zlicz()
	z3_01=z3_01+1
	z3_02=z3_02+zpetat
	lemeryt_sum=lemeryt_sum+plicz_d9()
	lrent_sum=lrent_sum+plicz_d10()
    lchorob_sum=lchorob_sum+plicz_d11()
	lwypad_sum=lwypad_sum+plicz_d31()
	lzdrow_sum=lzdrow_sum+plicz_da30()
    llicz_d7_all=llicz_d7_all+plicz_d7()
	lzasilki_sum=lzasilki_sum+zpzasilek+zpzas_inne
    skip
  enddo
  use
else
  return .f.
endif
z4_04=lemeryt_sum
z4_05=lrent_sum
z4_07=lemeryt_sum
z4_08=lrent_sum
z4_22=lchorob_sum
z4_25=lwypad_sum
z5_04=lzasilki_sum
z7_01=lzdrow_sum+kj_round(zlpod_zdrow*(zlsk_zdrow/100),2)
if zwl_spol
  z4_04=z4_04+kj_round(zlpodstawp*(2*zlsk_emeryt/100),2)
  *z4_05=z4_05+kj_round(zlpodstawp*(2*zlsk_rent/100),2)  
  z4_05=z4_05+kj_round(zlpodstawp*((zlsk_rentp+zlsk_rentu)/100),2)  
  z4_22=z4_22+kj_round(zlpodstawp*(zlsk_chorob/100),2)    
  z4_23=z4_23+kj_round(zlpodstawp*(zlsk_wypad/100),2)    
endif  
if zwspol_ile>0
  if zw1_spol
	z4_07=z4_07+kj_round(kj_round(zlpodstaw1*(2*zlsk_emeryt/100),2),2)		
    *z4_08=z4_08+kj_round(kj_round(zlpodstaw1*(2*zlsk_rent/100),2),2)		
	z4_08=z4_08+kj_round(kj_round(zlpodstaw1*((zlsk_rentp+zlsk_rentu)/100),2),2)		
	z4_22=z4_22+kj_round(zlpodstaw1*(zlsk_chorob/100),2)    
    z4_25=z4_25+kj_round(zlpodstaw1*(zlsk_wypad/100),2)      
  endif
  z7_01=z7_01+kj_round(zlpod_zdrow*(zlsk_zdrow/100),2)	
endif
if zwspol_ile>1
  if zw2_spol
	z4_07=z4_07+kj_round(kj_round(zlpodstaw2*(2*zlsk_emeryt/100),2),2)		
	z4_08=z4_08+kj_round(kj_round(zlpodstaw2*((zlsk_rentp+zlsk_rentu)/100),2),2)		
    z4_22=z4_22+kj_round(zlpodstaw2*(zlsk_chorob/100),2)    
    z4_25=z4_25+kj_round(zlpodstaw2*(zlsk_wypad/100),2)        
  endif	
  z7_01=z7_01+kj_round(zlpod_zdrow*(zlsk_zdrow/100),2)	
endif
if.not.zwl_spol
  llpodstawp=0
endif
if.not.zw1_spol
  llpodstaw1=0
endif
if.not.zw2_spol
  llpodstaw2=0
endif
z8_01=KJ_ROUND((llicz_d7_all+llpodstawp+llpodstaw1+llpodstaw2)*(zlsk_fundus/100),2)
*z8_02=KJ_ROUND((llicz_d7_all+zlpodstawp+zlpodstaw1+zlpodstaw2)*(zlsk_fgsp/100),2)
z8_02=KJ_ROUND((llicz_d7_all)*(zlsk_fgsp/100),2)
if lastrec=0
  z11=.t.
  z11_01=kod_tytulu(zwl_kodnum)
  prac_default()
endif
RETURN .t.

*******************************************************************************
*LP_EDRUK                                                                      *
*******************************************************************************
FUNCTION BIL_MIES()
local lprac_sum:=0,lbrutto_sum:=0,lzdrow_sum:=0,lpodat_sum:=0,ek,lcolor:=setcolor()
local lpodstawa_sum:=0,lzdrow_odlicz_sum:=0
local ltyt:=space(80)
select 0
if.not.prac_use(zmiesiac)
  return
endif
lprac_sum=lastrec()
do while.not.eof()
  p_lad()
  zlicz()
  lpodstawa_sum=lpodstawa_sum+plicz_d13()
*  lbrutto_sum=lbrutto_sum+plicz_d7()+zpza_chor
  *lzdrow_sum=lzdrow_sum+plicz_d30()
  lzdrow_sum=lzdrow_sum+plicz_da30()
  lzdrow_odlicz_sum=lzdrow_odlicz_sum+plicz_do30()
  lpodat_sum=lpodat_sum+plicz_d16()
  skip
enddo
use
save screen to ek
ltyt=stuff(ltyt,22,25,"Podsumowanie za miesiac: ")
ltyt=stuff(ltyt,49,len(alltrim(mies_nazwa(zmiesiac))),alltrim(mies_nazwa(zmiesiac)))
kj_okno(0,0,24,ltyt,2)
@ 2,2 say "PLATNIK:"
@ 3,2 say "========"
@ 5,2 say alltrim(zfnaz1)+"  "+alltrim(zfnaz2)
@ 8,2  say "Liczba pracownikow ..........................."
*@ 10,2 say "Wynagrodzenie brutto ........................."
@ 10,2 say "Suma wyplat podlegajacych opodatkowaniu ......"
@ 12,2 say "Skladki ubezpieczenia zdrowotnego : pobrane .." 
@ 13,2 say "                                    odliczone " 
@ 15,2 say "Zaliczka na podatek dochodowy (potracona) ...."
@ 8,55 say lprac_sum picture "99 999 999"
*@ 10,55 say lbrutto_sum picture "99 999 999.99"
@ 10,55 say lpodstawa_sum picture "99 999 999.99"
@ 12,55 say lzdrow_sum picture "99 999 999.99"
@ 13,55 say lzdrow_odlicz_sum picture "99 999 999.99"
@ 15,55 say lpodat_sum picture "99 999 999.99"
if kj_gkom(18,"                          ","Wydrukowac ?","",.t.,5)
*  bil_druk(lprac_sum,lbrutto_sum,lzdrow_sum,lpodat_sum)
  bil_druk(lprac_sum,lpodstawa_sum,lzdrow_sum,lzdrow_odlicz_sum,lpodat_sum)
endif
restore screen from ek
setcolor(lcolor)
RETURN nil


FUNCTION SKLADKI_MIES(ptryb)
local lprac_sum:=0,lbrutto_sum:=0,lzdrow_sum:=0,lpodat_sum:=0,ek,lcolor:=setcolor()
local lpodstawa_sum:=0
local ltyt:=space(80)
local L51_dawca,L51_wspol1,L51_wspol2,L52_dawca,L52_wspol1,L52_wspol2
local L51_wnik_all:=0,L51_all:=0,lzasilek_all:=0
local L52_wnik_all:=0,llicz_d7_all:=0,L53_all:=0,L53fp_all:=0,L53fg_all:=0
local llpodstawp:=zlpodstawp,llpodstaw1:=zlpodstaw1,llpodstaw2:=zlpodstaw2
local rlpodstawp:=zlpodstawp,rlpodstaw1:=zlpodstaw1,rlpodstaw2:=zlpodstaw2
local llpod_zdrow:=zlpod_zdrow,rlpod_zdrow:=zlpod_zdrow
local rlpod1_zdrow:=0,rlpod2_zdrow:=0
*r....aw. stosowane do naliczania zdrowotnego
if zw_lp
  if substr(zskarbowy,1,1)="0".or.substr(zskarbowy,1,1)=" "  &&nie ma wspolpracownikow
    llpodstaw1=0.00
    llpodstaw2=0.00
    rlpod1_zdrow=0.00
    rlpod2_zdrow=0.00	
  endif
  if substr(zskarbowy,1,1)="1"   &&jest jeden wspolpracownik
    rlpod1_zdrow=zlpod_zdrow
	llpodstaw2=0.00
	rlpodstaw2=0.00
  endif  
endif

  if substr(zskarbowy,1,1)="0".or.substr(zskarbowy,1,1)=" "  &&nie ma wspolpracownikow
    rlpod1_zdrow=0.00
    rlpod2_zdrow=0.00	
  endif
  if substr(zskarbowy,1,1)="1"   &&jest jeden wspolpracownik
	rlpod1_zdrow=zlpod_zdrow
	rlpodstaw2=0.00
  endif  

*
if.not.zwl_spol
  llpodstawp=0
endif
if.not.zw1_spol
  llpodstaw1=0
endif
if.not.zw2_spol
  llpodstaw2=0
endif

L51_dawca=KJ_ROUND(llpodstawp*(2*zlsk_emeryt/100),2)+KJ_ROUND(llpodstawp*((zlsk_rentp+zlsk_rentu)/100),2)+KJ_ROUND(llpodstawp*zlsk_chorob/100,2)+KJ_ROUND(llpodstawp*zlsk_wypad/100,2)
L51_wspol1=KJ_ROUND(llpodstaw1*(2*zlsk_emeryt/100),2)+KJ_ROUND(llpodstaw1*((zlsk_rentp+zlsk_rentu)/100),2)+KJ_ROUND(llpodstaw1*zlsk_chorob/100,2)+KJ_ROUND(llpodstaw1*zlsk_wypad/100,2)
L51_wspol2=KJ_ROUND(llpodstaw2*(2*zlsk_emeryt/100),2)+KJ_ROUND(llpodstaw2*((zlsk_rentp+zlsk_rentu)/100),2)+KJ_ROUND(llpodstaw2*zlsk_chorob/100,2)+KJ_ROUND(llpodstaw2*zlsk_wypad/100,2)


L52_dawca=KJ_ROUND(rlpod_zdrow*zlsk_zdrow/100,2)
L52_wspol1=KJ_ROUND(rlpod1_zdrow*(zlsk_zdrow/100),2)
*L52_wspol2=KJ_ROUND(rlpod2_zdrow*(zlsk_zdrow/100),2)
L52_wspol2=0

select 0
if.not.prac_use(zmiesiac)
  return
endif
lprac_sum=lastrec()
do while.not.eof()
  p_lad()
  zlicz()
  L51_wnik_all=L51_wnik_all+plicz_d33()
  lzasilek_all=lzasilek_all+zpzasilek+zpzas_inne
  L52_wnik_all=L52_wnik_all+plicz_da30()
  llicz_d7_all=llicz_d7_all+plicz_d7()
  L53fp_all=L53fp_all+KJ_ROUND(plicz_d7()*(zlsk_fundus/100),2)
  L53fg_all=L53fg_all+KJ_ROUND(plicz_d7()*(zlsk_fgsp/100),2)
  
  skip
enddo
use
L51_all=L51_dawca+L51_wspol1+L51_wspol2+L51_wnik_all
L52_all=L52_dawca+L52_wspol1+L52_wspol2+L52_wnik_all
*L53fp_all=KJ_ROUND((llicz_d7_all+llpodstawp+llpodstaw1+llpodstaw2)*(zlsk_fundus/100),2)
L53fp_all=L53fp_all+KJ_ROUND(llpodstawp*(zlsk_fundus/100),2)
L53fp_all=L53fp_all+KJ_ROUND(llpodstaw1*(zlsk_fundus/100),2)
L53fp_all=L53fp_all+KJ_ROUND(llpodstaw2*(zlsk_fundus/100),2)
*L53fg_all=KJ_ROUND((llicz_d7_all)*(zlsk_fgsp/100),2)
L53_all=L53fp_all+L53fg_all
save screen to ek
do case
  case ptryb=1
    ltyt=stuff(ltyt,22,25,"Podsumowanie skladek za miesiac: ")
    ltyt=stuff(ltyt,57,len(alltrim(mies_nazwa(zmiesiac))),alltrim(mies_nazwa(zmiesiac)))
    kj_okno(0,0,24,ltyt,2)
    @ 1,2 say "PLATNIK:"
    @ 1,12 say alltrim(zfnaz1)+"  "+alltrim(zfnaz2)
    @ 2,2 say replicate("=",len(alltrim(zfnaz1))+len(alltrim(zfnaz2))+12)
    @ 3,2  say "                                      SKLADKI UBEZPIECZENIA"
    @ 4,2 say  "                        SPOLECZNEGO  (Konto 51)      ZDROWOTNEGO  (Konto 52)"
    @ 5,2 say "Pracodawca ............"
    @ 6,2 say "Wspolpracownik ........"
    *@ 7,2 say "Wspolpracownik (2) ...."
    @ 7,2 say "Pracownicy ............"
    @ 8,2 say"                         -------------                 ---------------"
    @ 9,2 say"          Razem:   " 
    @ 10,2 say"          - odliczenia"
    @ 11,2 say"          Do zaplaty"
    @ 13,2 say"SKLADKI NA FUNDUSZ PRACY  ............................ "
    @ 14,2 say"SKLADKI NA FUNDUSZ GWARANTOWANYCH SWIADCZEN PRACOW. .. "	
    @ 15,2 say"                                                       ---------------"
	@ 16,2 say"                                     Razem (Konto 53): "	
    @ 18,2 say"RAZEM: (Spoleczne)-(odliczenia)+(Zdrowotne)+(Fundusze)="
    @ 5,27 say L51_dawca picture "99 999 999.99"
    @ 6,27 say L51_wspol1 picture "99 999 999.99"
    *@ 7,27 say L51_wspol2 picture "99 999 999.99"
    @ 7,27 say L51_wnik_all picture "99 999 999.99"
    @ 9,27 say L51_all picture "99 999 999.99"
    @ 10,27 say lzasilek_all picture "99 999 999.99"
    @ 11,27 say L51_all-lzasilek_all picture "99 999 999.99"
    @ 5,59 say L52_dawca picture "99 999 999.99"
    @ 6,59 say L52_wspol1 picture "99 999 999.99"
    *@ 7,59 say L52_wspol2 picture "99 999 999.99"
    @ 7,59 say L52_wnik_all picture "99 999 999.99"
    @ 9,59 say L52_all picture "99 999 999.99"
    @ 13,59 say L53fp_all picture "99 999 999.99"
	@ 14,59 say L53fg_all picture "99 999 999.99"
	@ 16,59 say L53_all picture "99 999 999.99"
    @ 18,59 say L51_all-lzasilek_all+L52_all+L53_all picture "99 999 999.99"
    if kj_gkom(20,"                          ","Wydrukowac ?","",.t.,5)
      skladki_druk(L51_dawca,L51_wspol1,L51_wspol2,L51_wnik_all,L52_dawca,L52_wspol1,L52_wspol2,L52_wnik_all,L53_all,lzasilek_all)
    endif
  
  case ptryb=2
    * Szczegoly skladek
	
  case ptryb=3      && wydruk przelewow
    l51_all=l51_all-lzasilek_all
    przel_druk(l51_all,l52_all,l53_all)		
  case ptryb=4
    l51_all=l51_all-lzasilek_all
    przel_druk(l51_all,0,0)
  case ptryb=5
    przel_druk(0,l52_all,0)
  case ptryb=6	
    przel_druk(0,0,l53_all)					  
endcase
restore screen from ek
setcolor(lcolor)
RETURN nil

FUNCTION PIT_11()
local l_druk1:=1,l_druk2:=1,ek,ek1,select:=select(),lsek:=1
local ltyt:="          *    P A R A M E T R Y     W Y D R U K U    *          "
*set century on
save screen to ek
public zp11_data:=date(),zp11_rok:=year(date())-1,zp11_podsumuj:=.t.
public zp11_inzrod:=.f.
pit_11_par(0)
			do while.t.
			  l_druk1=pit_11_menu(l_druk1)
			  do case
			    case lastkey()=27
				  exit
				case l_druk1=1
                    save screen to ek1
					do while.t.
					  l_druk2=p11_menu(l_druk2)
					  if lastkey()=27
					    restore screen from ek1
					    exit
					  endif
					    do case
						  case l_druk2=1
						    p11_alldruk()
						  case l_druk2=2
						   p11_wybor()
*						   if.not.lastkey()=27
*						     p11_druk(zpnumer)
*						   endif	 
						endcase
					enddo
			    case l_druk1=2
			      pit_11_par(1)            				
                  l_druk1=1
				case l_druk1=3.or.l_druk1=0
			      exit
			  endcase
			enddo  

restore screen from ek

prac_default()
*set century off
RETURN

FUNCTION PIT_11_PAR(ptryb)
local l_data,l_rok,lcolor:=setcolor(),ek,ek1,l_imienaz
local ltyt:="          *    P A R A M E T R Y     W Y D R U K U    *          "
local lp11_data,lp11_rok,lp11_imienaz,lp11_rodzaj,lp11_pit_r,lp11_koszty
local lp11_inzrod,lrmnazwisko,lrimie,lrmdata_ur
local lp11_ojciecmat
save screen to ek
g_tlo()
lp11_data:=zp11_data
lp11_rok=zp11_rok
lp11_imienaz=zp11_imienaz
lp11_rodzaj=zp11_rodzaj
lp11_pit_r=zp11_pit_r
lp11_koszty=zp11_koszty
lp11_inzrod=zp11_inzrod
lrmnazwisko=zrmnazwisko
lrmimie=zrmimie
lrmdata_ur=zrmdata_ur
lp11_ojciecmat=zp11_ojciecmat

kj_okno(9,0,14,ltyt,8)
@ 12,3 say "Data wypeànienia  "
@ 13,3 say "Deklaracja za rok "
@ 14,3 say "Rodzaj pàatnika ..........."
@ 15,3 say "Informacja o kosztach ....."
@ 16,3 say "Informacja PIT-R .........."
@ 17,3 say "Inne ´r¢dàa dochodu ......."
@ 18,3 say "Osoba odpow.(inie/nazwisko)"  
if zp11_rodzaj="2"
  @ 19,3 say "Platnik: Nazwisko ........."
  @ 20,3 say "         Imie ............."
  @ 21,3 say "         Data urodzenia ..."
  @ 22,3 say "         Imi© ojca/matki .."
endif
set color to n/w,w/n
if ptryb=1

    set cursor on
	@ 12, 21 get zp11_data when s_kom("Data wypeànienia deklaracji.") 
	@ 13, 21 get zp11_rok when s_kom("Rok ktorego dotyczy deklaracja.") 
	@ 14, 31 get zp11_rodzaj when s_kom("1 - pàatnik nie b©d•cy osob• fizyczn•        2 - osoba fizyczna.") 
	@ 15, 31 get zp11_koszty when s_kom("1-z jednego st.pr.  2-z wielu st.pr  3-z jednego podwyæszone 4-z wielu podwyæszone") 
	@ 16, 31 get zp11_pit_r when s_kom("1 - doà•czono informacj© PIT-R      2 - nie doà•czono informacji PIT-R.") 	
    @ 17, 31 get zp11_inzrod when s_kom(".T. - inne ´r¢dàa   .F. - brak innych ´r¢deà")
    @ 18, 31 get zp11_imienaz when s_kom("Imi© i nazwisko osoby odpowiedzilnej za obliczenie i pobranie podatku.") 	
    read
	if zp11_rodzaj="2"
      @ 19,3 say "Platnik: Nazwisko ........."
      @ 20,3 say "         Imie ............."
      @ 21,3 say "         Data urodzenia ..."
      @ 22,3 say "         Imi© ojca/matki .."	
	  @ 19,31 get zrmnazwisko  when s_kom("Dane identyfikacyjne platnika skladek -  Nazwisko")
	  @ 20,31 get zrmimie  when s_kom("Dane identyfikacyjne platnika skladek -  	Imie pierwsze")
	  @ 21,31 get zrmdata_ur when s_kom("Dane identyfikacyjne platnika skladek -  Data urodzenia")		
      @ 22,31 get zp11_ojciecmat when s_kom("Dane identyfikacyjne platnika skladek - Imi© ojca/matki")	
      read
	endif
  set cursor off
endif 
if lastkey()=27
  setcolor(lcolor)
  restore screen from ek
  prac_default()
  return
endif
@ 12,21 say zp11_data
@ 13, 21 say zp11_rok  
@ 14,31 say zp11_rodzaj
@ 15,31 say zp11_koszty
@ 16,31 say zp11_pit_r
@ 17,31 say zp11_inzrod
@ 18,31 say zp11_imienaz
	if zp11_rodzaj="2"

	  @ 19,30 say zrmnazwisko
	  @ 20,30 say zrmimie 
	  @ 21,30 say zrmdata_ur
      @ 22,30 say zp11_ojciecmat
      read
	endif

if zp11_data#lp11_data.or.zp11_rok#lp11_rok.or.zp11_imienaz#lp11_imienaz;
      .or.zp11_rodzaj#lp11_rodzaj.or.zp11_pit_r#lp11_pit_r.or.zp11_koszty#lp11_koszty;
	  .or.zp11_ojciecmat#lp11_ojciecmat.or.zp11_inzrod#lp11_inzrod;
	  .or.zrmnazwisko#lrmnazwisko.or.zrmimie#lrmimie.or.zrmdata_ur#lrmdata_ur
 
  if kj_gkom(12,"","Zapamietac wprowadzone zmiany ?","",.t.,5)
      select 0
      set default to lpset
      if kj_use("lpfirma",.t.,3)
        locate for fnum=zfnum
	    if found()
          replace zus_ulica with zp11_imienaz
		  replace zus_kod with stuff(zus_kod,1,1,zp11_rodzaj)
  		  replace zus_kod with stuff(zus_kod,2,1,zp11_pit_r)
		  replace zus_kod with stuff(zus_kod,3,1,zp11_koszty)
          replace zus_konto4 with stuff(zus_konto4,1,30,zp11_ojciecmat)
          replace sk_miasto with zrmnazwisko,sk_ulica with zrmimie
		  replace zus with zrmnazwa
          replace  zus_miasto with stuff(zus_miasto,1,10,dtoc(zrmdata_ur))
		  fir_lad()          
		endif	  
        
		use
	  endif	  
  endif
endif
setcolor(lcolor)
prac_default()
RETURN .t.

FUNCTION P11_WYBOR()
*local t[3],lmies_num:=12,ltyt:="          Lista pracownik¢w w miesi•cu                  "    
local t[3],lmies_num:=zmiesiac,ltyt:="          Lista pracownik¢w w miesi•cu                  "    
local ek,lmiesiac:=zmiesiac
p11_inne_zer()
t[1]:="pnazwisko"
t[2]:="pimie1"
t[3]:="ppesel"
prac_default()
save screen to ek
g_tlo()
keyboard chr(205)
do while.t.
  zmiesiac=lmies_num
  lmies=alltrim(str(lmies_num,2))
  ltyt=stuff(ltyt,47,2,"  ")
  ltyt=stuff(ltyt,47,len(lmies),lmies)
  s_kom("Enter - zatwierdzenie     +/- zmiana miesi•ca    Esc - rezygnacja")    
  kj_okno(5,0,18,ltyt,1)
  select 0
  if prac_use(lmies_num)
    dbedit(6,1,22,53,t,"P11_FU","",,"ﬂ")
	close
	if lastkey()=27
      exit
    endif
	do case
	  case chr(lastkey())="+"
	    lmies_num=lmies_num+1
		if lmies_num>12
		  lmies_num=1
		endif
	  case chr(lastkey())="-"
	    lmies_num=lmies_num-1
		if lmies_num<1
		  lmies_num=12
		endif		
	endcase
	keyboard chr(205)
  else
    exit
  endif	
enddo
zmiesiac=lmiesiac
restore screen from ek
RETURN

FUNCTION P11_FU()
local last:=lastkey()
do case
  case last=13
	if zp11_inzrod
	  p11_inne()
	endif  
    zpnumer=pnumer
	p11_druk(zpnumer)
	return 0
  case last=27
    return 0
  case chr(last)$"+-"
    return 0	
endcase
RETURN 1

FUNCTION P11_DRUK(ppnumer)
local lpnumer:=ppnumer,lus_nazwa:=space(30)
local lod_data,ldo_data
prac_default()
if prac_use(zmiesiac)
  locate for pnumer=lpnumer
  if.not.found()
    kj_tkom(12," Uwaga!","Pracownik o numerze "+str(lpnumer),"nie odnaleziony.","Pomijam w wydruku",5)
  endif
  p_lad()
  close
else
  return
endif
set default to urzedy
if kj_use("us.dbf",.f.,3)
  locate for zpus_kod = kod
  if found()
    lus_nazwa=nazwa
    close
  else
    if kj_gkom(12," Uwaga! ","Wyst•piày problemy z odnalezieniem nazwy wàaòciwego U.S. dla pracownika:",alltrim(zpnazwisko)+" "+alltrim(zpimie1)+"  PrzerwaÜ wydruk ?",.t.,5)
	  close
	  prac_default()
	  return
	endif
	close
  endif
  close
else
  if kj_gkom(12," Uwaga! ","Wyst•piày problemy z odnalezieniem nazwy wàaòciwego U.S. dla pracownika:",alltrim(zpnazwisko)+" "+alltrim(zpimie1)+"  PrzerwaÜ wydruk ?",.t.,5)
    prac_default()
    return
  endif
endif
if.not.zlista_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\pit_11.txt"
  set printer to &plik
endif
lod_data=max(first_day(),zpstart)
if.not.empty(zpend)
  ldo_data=min(last_day(),zpend)
else
  ldo_data=last_day()
endif
w=prow()
k=0
@ w,k say &zdr_kond+"Numer Identyfikacji Podatkowej platnika    "+&zdr_kkond+zfnip+&zdr_kond+ space(15)+"2. Numer dokumentu "+space(15)+"3. Status"
         
w=w+2
@ w,k say &zdr_kkond+&zdr_grubo+"PIT-11"
w=w+1
@ w,k+3 say "INFORMACJA O UZYSKANYCH PRZEZ PODATNIKA DOCHODACH ORAZ POBRANYCH"
w=w+1
@ w,k+3 say "              ZALICZKACH NA PODATEK DOCHODOWY"+&zdr_kgrubo
w=w+2
@ w,k+3 say "za okres  "+&zdr_kond+"4. Od (dzien-miesiac-rok)  "+&zdr_kkond+dtoc(lod_data) + space(10)+&zdr_kond+"5. Do (dzien-miesiac-rok)  "+&zdr_kkond+dtoc(ldo_data)
w=w+2
@ w,k say replicate("_",80)
w=w+1
@ w,k say "A. MIEJSCE SKLADANIA INFORMACJI"
w=w+1
@ w,k say &zdr_kond +"6. Urzad skarbowy, do ktorego adresowana jest informacja :          "+lus_nazwa
w=w+1
@ w,k say &zdr_kkond+replicate("_",80)
w=w+1
@ w,k say "B. DANE PLATNIKA"
w=w+1
@ w,k say "B.1. DANE IDENTYFIKACYJNE / DANE PERSONALNE"
w=w+1
@ w,k say &zdr_kond+"7. Rodzaj platnika          -"
do case
  case zp11_rodzaj="1"
    @ w,k+42 say "1. platnik nie bedacy osoba fizyczna"
  case zp11_rodzaj="2"
    @ w,k+42 say "2. osoba fizyczna"	
endcase
w=w+1
@ w,k say "8. Nazwa pelna / Nazwisko, pierwsze imie, data urodzenia             "
do case
  case zp11_rodzaj="1"
    @ w,k+70 say alltrim(zfnaz1)+"  "+alltrim(zfnaz2)
  case zp11_rodzaj="2"
    @ w,k+70 say alltrim(zrmnazwisko)+"  "+alltrim(zrmimie)+"    "+dtoc(zrmdata_ur)	
endcase
*w=w+1      &&060213
*@ w,k say "9. Nazwa skrocona / Imie ojca, Imie matki      "
*do case
*  case zp11_rodzaj="1"
*    @ w,k+48 say zrmnazwa+"             10. Numer identyfikacyjny REGON   "+zfregon
*  case zp11_rodzaj="2"
*    @ w,k+48 say zp11_ojciecmat+"             10. Numer identyfikacyjny REGON   "+zfregon	
*endcase
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+1
@ w,k say "B.2. ADRES SIEDZIBY / ADRES ZAMIESZKANIA"
w=w+1
@ w,k say &zdr_kond+" 9. Kraj      "+zfkraj + "          10. Wojewodztwo     "+zfwojewodztwo + "                       11. Powiat     "+zfpowiat
w=w+1
@ w,k say "12. Gmina     "+zfgmina+"          13./14./15.  Ulica/Nr domu/Nr lokalu     "+zfulica
w=w+1
@ w,k say "16. Miejscowosc     "+ALLTRIM(zfmiasto)+"          17. Kod pocztowy     "+zfkod+"          18. Poczta     "+zfpoczta
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+1
@ w,k say "C. DANE PODATNIKA"
w=w+1
@ w,k say "C.1. DANE PERSONALNE"
w=w+1
@ w,k say &zdr_kond+ "19. Numer Identyfikacji Podatkowej     "+zpnip+"          20. Nazwisko     "+zpnazwisko
w=w+1
@ w,k say "21. Pierwsze imie     "+zpimie1+"                            22. Data urodzenia     "+dtoc(zpdata_ur)
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+1
@ w,k say "C.2. ADRES MIEJSCA ZAMIESZKANIA"
w=w+1
@ w,k say &zdr_kond+"23. Kraj    "+zfkraj +"            24. Wojewodztwo     "+zpwojew+"          25. Powiat     "
w=w+1
@ w,k say "26. Gmina    "+zpgmina+"      27. Ulica    "+zpulica+"      28. Nr domu    "+zpdom_nr+"      29. Nr lokalu    "+zplokal_nr
w=w+1
@ w,k say "30. Miejscowosc     "+zpmiejscow+"          31. Kod pocztowy     "+zpkod+"          32. Poczta     "+zppoczta
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+1
@ w,k say "D. INFORMACJA O KOSZTACH UZYSKANIA PRZYCHODU"
w=w+1
@ w,k say &zdr_kond+"33. Koszty uzyskania przychodow, wykazane w poz.35, zostaly uwzglednione do wysokosci przyslugujacej podatnikowi na podstawie:"
w=w+1
do case
  case zp11_koszty="1"
    @ w,k+5 say "1. z jednego stosunku pracy (stosunkow pokrewnych)"
  case zp11_koszty="2"
    @ w,k+5 say "2. z wi©cej niz z jednego stosunku pracy (stosunk¢w pokrewnych)"	
  case zp11_koszty="3"
    @ w,k+50 say "3. z jednego stosunku pracy podwyæszone w zwiazku z zamieszkaniem poza miejscowoscia, w ktorej pracuje"	
  case zp11_koszty="4"
    @ w,k+50 say "3. z wiecej niz zjednego stosunku pracy podwyæszone w zwiazku z zamieszkaniem poza miejscowoscia, w ktorej pracuje"		
endcase
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+3
@ w,k say "E.  DOCHODY PODATNIKA,  POBRANE ZALICZKI  ORAZ   POBRANE SKLADKI           "
w=w+1
@ w,k say &zdr_kond+replicate("-",132)
w=w+1
@ w,k say "|                                              | Przychod  |  Koszty   |  Dochod   |  Pobrana  || Skladki na ubezpieczenie spole-  |"
w=w+1
@ w,k say "|  Z r o d l o   p r z y c h o d o w           | podlegaja-| uzyskania |           | zaliczka  || czne, o ktorych mowa w art.26    |"
w=w+1
@ w,k say "|                                              | cy opodat-| przychodu |           | na podatek|| ust.1 pkt 2 lit.b ustawy  [75]   |"
w=w+1
@ w,k say "|                                              | kowaniu   |           |           | dochodowy ||"
*p11_licz(.t.,2)
@ w,131 say "|" 
w=w+1
@ w,k say "|----------------------------------------------|---[ 34 ]--|---[ 35 ]--|---[ 36 ]--|---[ 37 ]--||                                  |"
p11_licz(.t.,2)
w=w+1
@ w,k say "|1.Wynagrodzenia ze stosunku: pracy,sluzbowego,"
                                                                                            @ w,k+95 say "||----------------------------------"
@ w,131 say "|" 
w=w+1
@ w,k say "| spoldzielczego i z pracy nakladczej, a takze"
p11_licz(.f.,1)
                                                                                            @ w,k+95 say "|| Skladki na ubezpieczenie zdrowo- "
@ w,131 say "|" 
w=w+1
@ w,k say "| z ubezpieczenia spolecznego wyplacone przez "
                                                                                            @ w,k+95 say "|| tne, o ktorych mowa w art.27b    "
@ w,131 say "|" 
w=w+1
@ w,k say "| zaklad pracy"
*                                                                                            @ w,k+95 say "|| Pobrane  [77]  | Odliczone  [78] "
                                                                                            @ w,k+95 say "    ust.1 pkt 2 z zastrzezeniem     "
@ w,131 say "|" 
w=w+1
@ w,k say "|----------------------------------------------|---[ 72 ]--|-----------|---[ 73 ]--|---[ 74 ]--|| art.27b ust.2 ustawy      [76]   |"
w=w+1
@ w,k say "| "+z11_zrodlo
    @ w,48 say z11_przychod picture "9999999.99"
    @ w,60 say z11_koszty picture "9999999.99"
    @ w,72 say z11_przychod-z11_koszty picture "9999999.99"
    @ w,84 say z11_zaliczka picture "9999999.99"
                                                                                            @ w,k+95 say "||                                  "
@ w,131 say "|" 
*w=w+1
*@ w,k say "|                                                                                                                                  |"
w=w+1
@ w,k say "|----------------------------------------------------------------------------------------------"
                                                                                            @ w,k+95 say "||"
p11_licz(.t.,3)																							
@ w,131 say "|" 
w=w+1
@ w,k say "|                                              |" &&060221
*p11_licz(.t.,1)
 	@ w,95 say "||                       " 
**   @ w,120 say zksum12_o+z11_odliczone picture "9999999.99"
 @ w,131 say "|" 
**w=w+1
**@ w,k say "------------------------------------------------------------------------------------------------------------------------------------"
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+1
@ w,k say "F. INFORMACJA O PRZYCHODACH ZWOLNIONYCH OD PODATKU ORAZ O ZALACZNIKU "
w=w+1
do case
  case zp11_pit_r="1" 
    @ w,k say &zdr_kond+"79. Do niniejszej informacji dolaczono informacje PIT-R"
  case zp11_pit_r="2" 
    @ w,k say &zdr_kond+"79. Do niniejszej informacji nie dolaczono informacji PIT-R"	
endcase
w=w+1
@ w,k say &zdr_kkond+replicate("_",80) 
w=w+1
@ w,k say "G. OSWIADCZENIE PLATNIKA"+&zdr_kond+" LUB OSOBY ODPOWIEDZIALNEJ ZA OBLICZENIE I POBRANIE PODATKU"
w=w+1
@ w,k say "Oswiadczam, ze sa mi znane przepisy Kodeksu karnego skarbowego o odpowiedzialnosci za podanie danych niezgodnych z rzeczywistoscia."
w=w+2
@ w,k say "80./81.   Imie / Nazwisko     "+alltrim(zp11_imienaz)
w=w+2
@ w,k say "82.  Podpis (i pieczatka) osoby odpowiedzialnej za obliczenie i pobranie podatku"
w=w+1
@ w,k say &zdr_kkond+replicate("_",80)   
eject
set device to screen
RETURN


FUNCTION P11_LICZ(psuma,ptryb)
local k3:=0,k5:=0,k6:=0,k7:=0,k8:=0,k9:=0,k10:=0,k11:=0,k12:=0,k13:=0,k14:=0
local ksum3:=0,ksum5:=0,ksum6:=0,ksum7:=0,ksum8:=0,ksum9:=0,ksum10:=0
local ksum11:=0,ksum12:=0,ksum13:=0,ksum14:=0,k12_o:=0,ksum12_o:=0
local recno,i
*p_lad()
*recno=recno()
*close
*select 0
prac_default()

lmiesiac=12
for i=1 to lmiesiac
  zmiesiac=i
  select 0
  prac_use(i)
  locate for pnumer=zpnumer
  if found()
    p_lad()
    zlicz()
	k3=plicz_d7()+pza_chor    
	k5=zpkoszty
	k6=plicz_d9()
	k7=plicz_d10()
	k8=plicz_d11()
	k9=plicz_d13()-zpkoszty
	k10=k10+k9
    k11=plicz_d15()
	k12=plicz_d30()
	k12_o=plicz_do30()
	k13=plicz_d16()	
    k14=zpza_chor
	ksum3=ksum3+k3
	ksum5=ksum5+k5
	ksum6=ksum6+k6
	ksum7=ksum7+k7
	ksum8=ksum8+k8
	ksum9=ksum9+k9
	ksum11=ksum11+k11
	ksum12=ksum12+k12
	ksum12_o=ksum12_o+k12_o
	ksum13=ksum13+k13
    ksum14=ksum14+k14
  endif	
  use
next
zksum12_o=ksum12_o
do case
  case ptryb=1
    if psuma
        @ w,48 say ksum3+z11_przychod picture "9999999.99"
        @ w,60 say ksum5+z11_koszty picture "9999999.99"
	    @ w,72 say ksum3+z11_przychod-(ksum5+z11_koszty) picture "9999999.99"
        @ w,84 say ksum13+z11_zaliczka picture "9999999.99"

    *	@ w,72 say ksum6+ksum7+ksum8+z11_skladki picture "9999999.99"
    *	@ w,84 say ksum9+z11_podstawa picture "9999999.99"
    *@ w,96 say ksum12+z11_pobrane picture "9999999.99"
    *@ w,108 say ksum12+z11_odliczone picture "9999999.99"
    *@ w,120 say ksum13+z11_zaliczka picture "9999999.99"
    else
        @ w,48 say ksum3 picture "9999999.99"
        @ w,60 say ksum5 picture "9999999.99"
	    @ w,72 say ksum3-ksum5 picture "9999999.99"
        @ w,84 say ksum13 picture "9999999.99"

    *	@ w,72 say ksum6+ksum7+ksum8 picture "9999999.99"
    *	@ w,84 say ksum9 picture "9999999.99"
    *@ w,96 say ksum12 picture "9999999.99"
    *@ w,108 say ksum12 picture "9999999.99"
    *@ w,120 say ksum13 picture "9999999.99"
    endif

  case ptryb=2
    	@ w,108 say ksum6+ksum7+ksum8+z11_skladki picture "9999999.99"
  case ptryb=3
*	@ w,96 say ksum12+z11_pobrane picture "9999999.99"   &&060214
    @ w,108 say ksum12_o+z11_odliczone picture "9999999.99"
endcase
RETURN .T.

FUNCTION P11_ALLDRUK()
local lmies_num:=zmiesiac,lastrec:=0,i,lpnumer
zmiesiac=12
prac_default()
if prac_use(zmiesiac)
  lastrec=lastrec()
  close
else
  zmiesiac=lmies_num
  return .f.
endif
for i=1 to lastrec
  if prac_use(zmiesiac)
    go i
    lnumer=pnumer
    close
  else
    zmiesiac=lmies_num
    return .f.
  endif
  p11_druk(lnumer)
next
zmiesiac=lmies_num
RETURN .t.

FUNCTION P11_INNE_PUBLIC()
public z11_zrodlo:=" Inne zrodla                                "
public z11_przychod:=0,z11_koszty:=0,z11_skladki:=0
public z11_podstawa:=0,z11_pobrane:=0,z11_odliczone:=0,z11_zaliczka:=0
public zksum12_o:=0
RETURN 

FUNCTION P11_INNE_ZER()
z11_zrodlo=" Inne zrodla                                "
z11_przychod=0
z11_koszty=0
z11_skladki=0
z11_podstawa=0
z11_pobrane=0
z11_odliczone=0
z11_zaliczka=0
RETURN 

FUNCTION P11_INNE()
local ltyt:="             *  DODATKOWE çR‡DùO PRZYCHOD‡W  *              "
kj_okno(12,20,10,ltyt,5)
@ 14,22 say "Zrodlo ..... "
@ 15,22 say "Przych¢d podlegaj•cy opodatkowaniu ......."
@ 16,22 say "Koszty uzyskania przychodu ..............."
@ 17,22 say "Skàadki na ubezp. spoà. potr•cone ........"
@ 18,22 say "Podstawa obliczenia zaliczki na podatek .."
@ 19,22 say "Kwota skàadek na ubezp. zdrow. pobrana ..."
@ 20,22 say "Kwota skàadek na ubezp. zdrow. odliczona ."
@ 21,22 say "Pobrana zaliczka na podatek dochodowy ...."
set cursor on
@ 14,35 get z11_zrodlo
@ 15,65 get z11_przychod picture "99999999.99"
@ 16,65 get z11_koszty picture "99999999.99"
@ 17,65 get z11_skladki picture "99999999.99"
@ 18,65 get z11_podstawa picture "99999999.99"
@ 19,65 get z11_pobrane picture "99999999.99"
@ 20,65 get z11_odliczone picture "99999999.99"
@ 21,65 get z11_zaliczka picture "99999999.99"
read
set cursor off
RETURN


FUNCTION FIRST_DAY()
local ldata:="01.01.    ",ldat
ldata=stuff(ldata,7,4,alltrim(str(zp11_rok)))
ldat=ctod(ldata)
RETURN ldat

FUNCTION LAST_DAY()
local ldata:="31.12.    ",ldat
ldata=stuff(ldata,7,4,alltrim(str(zp11_rok)))
ldat=ctod(ldata)
RETURN ldat
FUNCTION ALLRMUA_BFORMAT()
local ek,recno:=recno(),lmiesiac:=zmiesiac
save screen to ek
use
select 0
zmiesiac=val(zrmua_mies)
if prac_use(val(zrmua_mies))
  do while.not.eof().and..not.inkey()=27
    p_lad()
	rmua_bformat()
    skip
  enddo  
  use
else
  return .f.
endif  
restore screen from ek
zmiesiac=lmiesiac
prac_default()
RETURN



FUNCTION RMUA_BFORMAT()
local select:=select(),ltytul:="",ltyt_num:=val(alltrim(substr(zpuwagi,7,2)))
local recno:=recno()
local lw1,lstart_day:="01",lend_day:=lastday(val(zrmua_mies))
set default to lpset
select 0
if file("ub_tytul.dbf")
  if kj_use("ub_tytul",.f.,3)
    tyt_sel=select()
    locate for num=ltyt_num
	if found()
      ltytul=tytul
	endif  
	use
  endif
endif
prac_default()
select &select
zlicz()
if.not.zprzel_plik
  if start_druk()
    set device to printer
  else
    return
  endif
else
  set device to printer
  plik="wydruki\rmua_a.txt"
  set printer to &plik
endif
w=prow()
*pion_przes(zrow)
*k=zcol
k=0
@ w,k say "Z U S   R M U A       RAPORT MIESIECZNY DLA OSOBY UBEZPIECZONEJ"
w=w+1
@ w,k say "---------------------------------------------------------------"
w=w+3
@ w,k say "I. DANE ORGANIZACYJNE"+&zdr_kond
w=w+1
@ w,k+3 say "Identyfikator raportu (numer/mm/rrrr) ........    "+znum_deklar+" / "+txt_month(val(zrmua_mies))+" / "+zrmua_rok+&zdr_kkond
w=w+2
@ w,k say "II. DANE IDENTYFIKACYJNE PLATNIKA SKLADEK"+&zdr_kond
w=w+1
@ w,k+3 say "Nip: "+nip_(zfnip)+ "                 Regon: "+zfregon+"                 Pesel: "+zfpesel
w=w+1
@ w,k+3 say "Nazwisko: "+zrmnazwisko
@ w,k+60 say "Imie pierwsze: "+zrmimie
w=w+1
@ w,k+3 say "Nazwa skrocona: "+zrmnazwa
@ w,k+60 say "Data urodzenia (dd/mm/rrrr) : "+substr(dat_(zrmdata_ur),1,2)+"/"+substr(dat_(zrmdata_ur),3,2)+"/"+substr(dat_(zrmdata_ur),5) +&zdr_kkond
w=w+2
@ w,k say "III. DANE IDENTYFIKACYJNE OSOBY UBEZPIECZONEJ"+&zdr_kond
w=w+1
@ w,k+3 say "Nazwisko: "+zpnazwisko
@ w,k+60 say "Imie pierwsze: "+zpimie1
if.not.empty(zppesel)
  w=w+1
  @ w,k+3 say "Typ identyfikatora: PESEL"
  @ W,K+60 SAY "Identyfikator: "+zppesel+&zdr_kkond
else
  @ w,k say +&zdr_kkond
endif
w=w+2
@ w,k say "IV.A. ZESTAWIENIA NALEZNYCH SKLADEK NA UBEZPIECZENIE SPOLECZNE I ZDROWOTNE" +&zdr_kond
w=w+1
@ w,k+3 say "Tytul ubezpieczenia (pierwszy): "+ltytul
@ w,k+60 say "Wymiar czasu pracy: "+etat_(zpetat) 
w=w+2
@ w,k+3 say "Podstawa wymiaru skladki na    ubezpieczenie emerytalne i rentowe .........."+str(plicz_d7(),9,2)
w=w+1
@ w,k+3 say "                               chorobowe i wypadkowe ......................."+str(plicz_d7(),9,2)
w=w+1
@ w,k+3 say "                               zdrowotne ..................................."+str(plicz_d13(),9,2)
w=w+2
@ w,k+3 say "Kwota skladki finansowana przez Ubezpieczonego na ubezpieczenie    emerytalne   ..................."+str(plicz_d9(),8,2)
w=w+1
@ w,k+3 say "                                                                   rentowe  ......................."+str(plicz_d10(),8,2)
w=w+1
@ w,k+3 say "                                                                   chorobowe i wypadkowe .........."+str(plicz_d11(),8,2)
w=w+1
@ w,k+3 say "                                                                   zdrowotne ......................"+str(plicz_d30(),8,2)
w=w+2
@ w,k+3 say "Kwota skladki finansowana przez Platnika na ubezpieczenie          emerytalne   ..................."+str(plicz_d9(),8,2)
w=w+1
@ w,k+3 say "                                                                   rentowe  ......................."+str(plicz_d10(),8,2)
w=w+1
@ w,k+3 say "                                                                   chorobowe i wypadkowe .........."+str(plicz_d31(),8,2)
w=w+2 
@ w,k+3 say "Laczna kwota skladek ............... "+&zdr_kkond+str(plicz_d32(),8,2)+&zdr_kkond
w=w+2
@ w,k say "V. ZESTAWIENIE WYPLACONYCH SWIADCZEN FINANSOWANYCH Z BUDZETU PANSTWA"+&zdr_kond
w=w+1
@ w,k+3 say "Liczba osob, na ktore wyplacany jest zasilek    rodzinny .......... "+lo_rodz()
w=w+1
@ w,k+3 say "                                                pielegnacyjny ..... "+lo_piel()
w=w+2
@ w,k+3 say "Kwota wyplaconego zasilku                       rodzinnego ........ "+str(zpzasilek,8,2)
w=w+1
@ w,k+3 say "                                                pielegnacyjnego ... "+str(zpzas_inne,8,2)
w=w+2
@ w,k+3 say "Laczna kwota wyplaconych zasilkow ................................. "+str(zpzasilek+zpzas_inne,8,2)+&zdr_kkond

***** RMUA_B

if month(zpstart)=val(zrmua_mies).and.str(year(zpstart))=substr(str(year(date())),3)
  lstart_day=txt_day(zpstart)
endif
if.not.empty(zpend)
  lend_day=txt_day(zpend)
endif
if len(alltrim(zrmua_mies))=1
  zrmua_mies=stuff("00",2,1,alltrim(zrmua_mies))
endif

w=w+2
@ w,k say "VIII. ZESTAWIENIE WYPLACONYCH SKLADNIKOW WYNAGRODZENIA"+&zdr_kond
  w=w+1
  @ w,k+3 say "Rodzaj skladnika wynagrodzenia: "
if zpzasadn#0
  w=w+1
  @ w,k+10 say "Wynagrodzenie zasadnicze   za okres od dnia "+lstart_day+"/"+zrmua_mies+"/"+zrmua_rok+" do dnia "+lend_day+"/"+zrmua_mies+"/"+zrmua_rok+ "......... "+str(zpzasadn,9,2) 
endif
if zpdodatek#0
  w=w+1
  @ w,k+10 say "Dodatek                    za okres od dnia "+lstart_day+"/"+zrmua_mies+"/"+zrmua_rok+" do dnia "+lend_day+"/"+zrmua_mies+"/"+zrmua_rok+ "......... "+str(zpdodatek,9,2)
endif
if zppremia#0
  w=w+1
  @ w,k+10 say "Premia                     za okres od dnia "+lstart_day+"/"+zrmua_mies+"/"+zrmua_rok+" do dnia "+lend_day+"/"+zrmua_mies+"/"+zrmua_rok+ "......... "+str(zppremia,9,2)
endif
w=w+2
@ w,k+10 say "Laczna kwota ze wszystkich skladnikow wynagrodzenia : "+str(zpzasadn+zpdodatek+zppremia,10,2)+&zdr_kkond
w=w+2
@ w,k say "IX. OSWIADCZENIE PLATNIKA SKLADEK"+&zdr_kond
w=w+1 
@ w,k+3 say "Data wypelnienia (dd/mm/rrrr) : "+substr(dat_(zrmdat),1,2)+"/"+substr(dat_(zrmdat),3,2)+"/"+substr(dat_(zrmdat),5)
w=w+6
@ w,k+3 say "..................................................                    .................................................."
w=w+1
@ w,k+3 say "Podpis i pieczatka platnika lub osoby upowaznionej                    Pieczatka imenna oraz podpis Glownego Ksiegowego "+&zdr_kkond   
eject
set device to screen
RETURN 

