-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Czas generowania: 05 Lis 2019, 22:20
-- Wersja serwera: 8.0.18
-- Wersja PHP: 7.2.24-0ubuntu0.18.04.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `cmms_database`
--

DELIMITER $$
--
-- Procedury
--
CREATE DEFINER=`cmms_user`@`%` PROCEDURE `aktualizuj_date_logowania` (IN `login` VARCHAR(45))  Update Uzytkownicy
    set Uzy_DataOstatniegoLogowania = now()
    where Uzy_Login = login$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `czytniki_linialu_wprowadz_dane` (IN `rodzaj_sygnalu` VARCHAR(45), IN `sposob_montazu` VARCHAR(45), IN `uwagi` VARCHAR(255))  BEGIN
Declare IDrodzaj_sygnalu INT;
Declare IDsposob_montazu INT;
Declare Clnid int;

IF EXISTS (select uwagi from dual where uwagi = "") THEN
	select null into uwagi from dual;
END IF;

IF EXISTS(Select * from Slownik where Slo_InternalId = 4 and Slo_Varchar1 = rodzaj_sygnalu) THEN
	Select Slo_Id into IDrodzaj_sygnalu from Slownik where Slo_InternalId = 4 and Slo_Varchar1 = rodzaj_sygnalu;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (4,'Rodzaje sygnalow',rodzaj_sygnalu);
    select last_insert_id() into IDrodzaj_sygnalu;
END IF;


IF EXISTS(Select * from Slownik where Slo_InternalId = 8 and Slo_Varchar1 = sposob_montazu) THEN
	Select Slo_Id into IDsposob_montazu from Slownik where Slo_InternalId = 8 and Slo_Varchar1 = sposob_montazu;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (8,'Sposoby montazu',sposob_montazu);
    select last_insert_id() into IDsposob_montazu;
END IF;

IF EXISTS(Select * from CzytnikiLinialu where Cln_RodzajSygnalu = IDrodzaj_sygnalu and Cln_SposobMontazu = IDsposob_montazu and isnull(Cln_Uwagi) = isnull(uwagi)) THEN
	Select Cln_Id into Clnid from CzytnikiLinialu where Cln_RodzajSygnalu = IDrodzaj_sygnalu and Cln_SposobMontazu = IDsposob_montazu and Cln_Uwagi = uwagi;
ELSE 
	
	Insert into CzytnikiLinialu 
(Cln_RodzajSygnalu,Cln_SposobMontazu,Cln_Uwagi)
VALUES (
IDrodzaj_sygnalu,
IDsposob_montazu,
uwagi);
    select last_insert_id() into Clnid;
END IF;

select Clnid;


END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `glowice_wprowadz_dane` (IN `nazwa` VARCHAR(45), IN `nazwa_producenta` VARCHAR(100), IN `uwagi` VARCHAR(255))  BEGIN
DECLARE prdId int;
declare gloid int;

IF EXISTS (select uwagi from dual where uwagi = "") THEN
	select null into uwagi from dual;
END IF;

IF EXISTS(Select * from Producenci where Prd_PelnaNazwa = nazwa_producenta) THEN
	Select Prd_Id into prdId from Producenci where Prd_PelnaNazwa = nazwa_producenta;
ELSE 
	
	Insert into Producenci (Prd_PelnaNazwa) values (nazwa_producenta);
    select last_insert_id() into prdId;
END IF;

IF EXISTS(Select * from Glowice where Glw_nazwa = nazwa and Glw_PrdId = prdId and Glw_Uwagi = uwagi) THEN
	Select Glw_Id into gloid from Glowice where Glw_nazwa = nazwa and Glw_PrdId = prdId and Glw_Uwagi = uwagi;
ELSE 
	
	Insert into Glowice (Glw_nazwa, Glw_PrdId, Glw_Uwagi) VALUES (nazwa,prdId, uwagi);
    select last_insert_id() into gloid;
END IF;

	select gloid;
	
END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `klienci_wprowadz_dane` (IN `pelna_nazwa` VARCHAR(200), IN `krotka_nazwa` VARCHAR(45), IN `nip` VARCHAR(100), IN `adres` VARCHAR(45), IN `region` VARCHAR(100), IN `kod_pocztowy` VARCHAR(15), IN `kraj` VARCHAR(20), IN `telefon` VARCHAR(25), IN `fax` VARCHAR(25), IN `mail` VARCHAR(100), IN `uwagi` VARCHAR(255))  BEGIN
declare klnid int;

IF EXISTS(Select * from Klienci where Kln_Nip = nip) THEN
	Select Kln_Id into klnid from Klienci where Kln_Nip = nip;
ELSE 
	
	Insert into Klienci (Kln_PelnaNazwa,Kln_KrotkaNazwa,Kln_Nip,Kln_Adres,Kln_Region,Kln_KodPocztowy,Kln_Kraj,Kln_Telefon,Kln_Fax,Kln_Mail,Kln_Uwagi) 
    VALUES (pelna_nazwa,krotka_nazwa,nip,adres,region,kod_pocztowy,kraj,telefon,fax,mail,uwagi);

	select last_insert_id() into klnid;
END IF;





END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `kompensacja_temp_wprowadz_dane` (IN `rodzaj_czujnikow` VARCHAR(45), IN `interfejs` VARCHAR(45), IN `uwagi` VARCHAR(255))  BEGIN
declare IDrodzajczujnikow int;
declare kmtid int;

/*słownik: 'Rodzeje napedow', 19*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 20 and Slo_Varchar1 = rodzaj_czujnikow) THEN
	Select Slo_Id into IDrodzajczujnikow from Slownik where Slo_InternalId = 20 and Slo_Varchar1 = rodzaj_czujnikow;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (20,'Rodzaje czujnikow',rodzaj_czujnikow);
    select last_insert_id() into IDrodzajczujnikow;
END IF;

IF EXISTS(Select * from KompensacjaTemperatury where KMT_RodzajCzujnikow = rodzaj_czujnikow and KMT_Interfejs = interfejs and KMT_Uwagi = uwagi) THEN
	Select KMT_ID into kmtid from KompensacjaTemperatury 
	where KMT_RodzajCzujnikow = rodzaj_czujnikow 
	and KMT_Interfejs = interfejs 
	and KMT_Uwagi = uwagi;
ELSE 
	
	Insert into KompensacjaTemperatury (KMT_RodzajCzujnikow, KMT_Interfejs, KMT_Uwagi) VALUES (IDrodzajczujnikow,interfejs,uwagi);

	select last_insert_id() into kmtid;
END IF;

	select kmtid;



END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `linialy_wprowadz_dane` (IN `material` VARCHAR(45), IN `rozdzielczosc` VARCHAR(100), IN `rodzaj_sygnalu` VARCHAR(255), IN `rodzaj_sygnalu_szcz` VARCHAR(255), IN `sposob_montazu` VARCHAR(255), IN `czytnik` INT, IN `nazwa_producenta` VARCHAR(255), IN `uwagi` VARCHAR(255))  BEGIN
DECLARE IDrodzaj_sygnalu int;
DECLARE prdId int;
DECLARE IDsposob_montazu int;
Declare linid int;

IF EXISTS (select uwagi from dual where uwagi = "") THEN
	select null into uwagi from dual;
END IF;

IF EXISTS(Select * from Producenci where Prd_PelnaNazwa = nazwa_producenta) THEN
	Select Prd_Id into prdId from Producenci where Prd_PelnaNazwa = nazwa_producenta;
ELSE 
	
	Insert into Producenci (Prd_PelnaNazwa) values (nazwa_producenta);
    select last_insert_id() into prdId;
END IF;

IF EXISTS(Select * from Slownik where Slo_InternalId = 4 and Slo_Varchar1 = rodzaj_sygnalu) THEN
	Select Slo_Id into IDrodzaj_sygnalu from Slownik where Slo_InternalId = 4 and Slo_Varchar1 = rodzaj_sygnalu;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (4,'Rodzaje sygnalow',rodzaj_sygnalu);
    select last_insert_id() into IDrodzaj_sygnalu;
END IF;


IF EXISTS(Select * from Slownik where Slo_InternalId = 8 and Slo_Varchar1 = sposob_montazu) THEN
	Select Slo_Id into IDsposob_montazu from Slownik where Slo_InternalId = 8 and Slo_Varchar1 = sposob_montazu;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (8,'Sposoby montazu',sposob_montazu);
    select last_insert_id() into IDsposob_montazu;
END IF;

IF EXISTS(Select * from Linialy where Lin_material = material and Lin_rozdzielczosc = rozdzielczosc and Lin_rodzajsygnalu = IDrodzaj_sygnalu
 and Lin_rodzajsygnaluszcz = rodzaj_sygnalu_szcz and Lin_sposobmontazu = IDsposob_montazu and Lin_ClnId = czytnik and Lin_PrdId = prdId and Lin_Uwagi = uwagi) THEN
	Select Lin_Id into linid from Linialy where Lin_material = material and Lin_rozdzielczosc = rozdzielczosc and Lin_rodzajsygnalu = IDrodzaj_sygnalu
 and Lin_rodzajsygnaluszcz = rodzaj_sygnalu_szcz and Lin_sposobmontazu = IDsposob_montazu and Lin_ClnId = czytnik and Lin_PrdId = prdId and Lin_Uwagi = uwagi;
ELSE 
	
	Insert into Linialy 
    (Lin_material,
    Lin_rozdzielczosc, 
    Lin_rodzajsygnalu, 
    Lin_rodzajsygnaluszcz,
    Lin_sposobmontazu,
    Lin_ClnId,
    Lin_PrdId,
    Lin_Uwagi) 
    VALUES 
    (material,
    rozdzielczosc,
    IDrodzaj_sygnalu,
    rodzaj_sygnalu_szcz,
    IDsposob_montazu,
    czytnik,
    prdId,
    uwagi
    );
    select last_insert_id() into linid;
END IF; 

	
select linid;


END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `maszyny_wprowadz_dane` (IN `nazwa_producenta` VARCHAR(45), IN `model` VARCHAR(45), IN `zakresx` FLOAT, IN `zakresy` FLOAT, IN `zakresz` FLOAT, IN `glowica` INT, IN `pinola` INT, IN `uklad_pneu` INT, IN `napedy` INT, IN `oprogramowanie` INT, IN `klient` INT, IN `linial` INT, IN `urzadzenieio` INT, IN `sterowniki` INT, IN `utworzone_przez` INT, IN `kompensacja_temp` INT, IN `tab_znamionowa` VARCHAR(45), IN `opis` VARCHAR(255), IN `informacje` VARCHAR(255))  BEGIN
declare prdId int;

/*Producent*/
IF EXISTS(Select * from Producenci where Prd_PelnaNazwa = nazwa_producenta) THEN
	Select Prd_Id into prdId from Producenci where Prd_PelnaNazwa = nazwa_producenta;
ELSE 
	
	Insert into Producenci (Prd_PelnaNazwa) values (nazwa_producenta);
    select last_insert_id() into prdId;
END IF;

Insert into Maszyny (Mas_PrdId, 
Mas_Model, 
Mas_ZakresX, 
Mas_ZakresY,
Mas_ZakresZ, 
Mas_GlwId,
Mas_PinId,
Mas_UpnId,
Mas_NapId,
Mas_OprId,
Mas_KlnId,
Mas_LinId,
Mas_UioId,
Mas_StrId,
Mas_UtworzonePrzez,
Mas_TabZnomionowa,
Mas_Opis,
Mas_Informacje,
Mas_KmtId)

values (
prdId,
model,
zakresx,
zakresy,
zakresz,
glowica,
pinola,
uklad_pneu,
napedy,
oprogramowanie,
klient,
linial,
urzadzenieio,
sterowniki,
utworzone_przez,
tab_znamionowa,
opis,
informacje,
kompensacja_temp);





END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `napedy_wprowadz_dane` (IN `model` VARCHAR(45), `parametry` VARCHAR(45), `rodzaj_napedu` VARCHAR(45), `uwagi` VARCHAR(255))  BEGIN
declare IDrodzajnapedu int;
declare napid int;

/*słownik: 'Rodzeje napedow', 19*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 19 and Slo_Varchar1 = rodzaj_napedu) THEN
	Select Slo_Id into IDrodzajnapedu from Slownik where Slo_InternalId = 19 and Slo_Varchar1 = rodzaj_napedu;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (19,'Rodzeje napedow',rodzaj_napedu);
    select last_insert_id() into IDrodzajnapedu;
END IF;

IF EXISTS(Select * from Napedy where Nap_ModelSilnika = model and Nap_Parametry = parametry and Nap_RodzajNapedu = IDrodzajnapedu and Nap_Uwagi = uwagi) THEN
	Select Nap_Id into napid from Napedy where Nap_ModelSilnika = model 
    and Nap_Parametry = parametry 
    and Nap_RodzajNapedu = IDrodzajnapedu 
    and Nap_Uwagi = uwagi;
ELSE 
	
	Insert into Napedy (Nap_ModelSilnika, Nap_Parametry,Nap_RodzajNapedu, Nap_Uwagi) VALUES (model,parametry, IDrodzajnapedu, uwagi);

	select last_insert_id() into napid;
END IF;

	select napid;



END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `oprogramowanie_wprowadz_dane` (IN `rodzaj` VARCHAR(100), IN `wersja` VARCHAR(100), IN `uwagi` VARCHAR(255))  BEGIN
declare OprId int;
IF EXISTS(Select * from Oprogramowanie where Opr_Rodzaj = rodzaj and Opr_wersja = wersja and Opr_Uwagi = uwagi) THEN
	Select Opr_id into OprId from Oprogramowanie where Opr_Rodzaj = rodzaj and Opr_wersja = wersja and Opr_Uwagi = uwagi;
ELSE 
	
	Insert into Oprogramowanie (Opr_Rodzaj, Opr_wersja, Opr_Uwagi) values (rodzaj,wersja,uwagi);
    select last_insert_id() into OprId;
    
END IF;
	select OprId;


END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `pinole_wprowadz_dane` (IN `opis` VARCHAR(100), IN `wymiar_zewnetrzny` VARCHAR(45), IN `wymiar_srub` VARCHAR(45), IN `adapter_glowicy` VARCHAR(45), IN `uwagi` VARCHAR(255))  BEGIN
Declare Pinid int;
IF exists (select opis from dual where opis = "") THEN
select null into opis from dual;
END IF;

IF exists (select uwagi from dual where uwagi = "") THEN
select null into uwagi from dual;
END IF;

IF EXISTS(Select * from Pinole where Pin_Opis = opis and Pin_WymiarZewnetrzny = wymiar_zewnetrzny and Pin_WymiarsrubMontazu = wymiar_srub 
and Pin_Uwagi = uwagi) THEN
	Select Pin_Id into Pinid from Pinole where Pin_Opis = opis and Pin_WymiarZewnetrzny = wymiar_zewnetrzny and Pin_WymiarsrubMontazu = wymiar_srub 
and Pin_Uwagi = uwagi;
ELSE 
 	
 	Insert into Pinole (Pin_Opis, Pin_WymiarZewnetrzny, Pin_WymiarsrubMontazu,Pin_AdapterGlowicy, Pin_Uwagi) VALUES (opis, wymiar_zewnetrzny,wymiar_srub,adapter_glowicy,uwagi);

	select last_insert_id() into Pinid;
END IF;

	select Pinid;

END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `sterowniki_wprowadz_dane` (IN `nazwa_producenta` VARCHAR(45), IN `model` VARCHAR(45), IN `rodzaj_szatyster` VARCHAR(45), IN `rodzaj_interfejsu` VARCHAR(45), IN `uwagi` VARCHAR(45), IN `rodzaj_panelu` VARCHAR(45))  BEGIN
DECLARE prdId int;
declare IDrodzaj_interfejsu int;
declare IDrodzaj_szatyster int;
declare strid int;


IF EXISTS (select uwagi from dual where uwagi = "") THEN
	select null into uwagi from dual;
END IF;


IF EXISTS (select rodzaj_szatyster from dual where rodzaj_szatyster = "") THEN
	select null into rodzaj_szatyster from dual;
END IF;


IF EXISTS (select rodzaj_interfejsu from dual where rodzaj_interfejsu = "") THEN
	select null into rodzaj_interfejsu from dual;
END IF;


IF EXISTS (select rodzaj_panelu from dual where rodzaj_panelu = "") THEN
	select null into rodzaj_panelu from dual;
END IF;

IF EXISTS(Select * from Producenci where Prd_PelnaNazwa = nazwa_producenta) THEN
	Select Prd_Id into prdId from Producenci where Prd_PelnaNazwa = nazwa_producenta;
ELSE 
	
	Insert into Producenci (Prd_PelnaNazwa) values (nazwa_producenta);
    select last_insert_id() into prdId;
END IF;

/*słownik: 'Rodzaje interfejsów', 17*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 17 and Slo_Varchar1 = rodzaj_interfejsu) THEN
	Select Slo_Id into IDrodzaj_interfejsu from Slownik where Slo_InternalId = 17 and Slo_Varchar1 = rodzaj_interfejsu;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (17,'Rodzaje interfejsów',rodzaj_interfejsu);
    select last_insert_id() into IDrodzaj_interfejsu;
END IF;

/*słownik: 'Rodzaje szat sterowniczych', 18*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 18 and Slo_Varchar1 = rodzaj_szatyster) THEN
	Select Slo_Id into IDrodzaj_interfejsu from Slownik where Slo_InternalId = 18 and Slo_Varchar1 = rodzaj_szatyster;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (18,'Rodzaje szat sterowniczych',rodzaj_szatyster);
    select last_insert_id() into IDrodzaj_szatyster;
END IF;

IF EXISTS(Select * from Sterowniki where 
Str_PrdId = prdId 
and Str_Model = model 
and Str_RodzajSzatySter = IDrodzaj_szatyster 
and Str_RodzajInterfejsu = IDrodzaj_interfejsu 
and Str_Uwagi = uwagi) THEN
	Select Str_ID into strid from Sterowniki where Str_PrdId = prdId 
and Str_Model = model 
and Str_RodzajSzatySter = IDrodzaj_szatyster 
and Str_RodzajInterfejsu = IDrodzaj_interfejsu 
and Str_Uwagi = uwagi;
ELSE 
	
	Insert into Sterowniki (Str_PrdId,Str_Model,Str_RodzajSzatySter, Str_RodzajInterfejsu, Str_Uwagi) VALUES (prdId, model, IDrodzaj_szatyster, IDrodzaj_interfejsu, uwagi);

	select last_insert_id() into strid;
END IF;

	select strid;



END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `uklad_pneu_wprowadz_dane` (IN `filtry_model` VARCHAR(45), IN `przeciwwaga_mdl` VARCHAR(45), IN `przeciwwaga_rodzaj` VARCHAR(45), IN `system_antywibracyjny` VARCHAR(45), IN `lozyska_pow_rodzaj` VARCHAR(45), IN `lozyska_pow_model` VARCHAR(45), IN `lozyska_pow_par` VARCHAR(45), IN `nazwa_producenta` VARCHAR(45), IN `uwagi` VARCHAR(255))  BEGIN

DECLARE IDfiltry_model int;
DECLARE IDprzeciwwaga_mdl int;
DECLARE IDprzeciwwaga_rodzaj int;
DECLARE IDsystem_antywibracyjny int;
DECLARE IDlozyska_pow_rodzaj int;
DECLARE IDlozyska_pow_model int;
DECLARE prdId int;
Declare upnid int;

/*uwagi to pole nieobowiazkowe*/
IF EXISTS (select uwagi from dual where uwagi = '') THEN
select null into uwagi from dual;
END IF;

/*słownik: 'Modele filtrow', 7*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 7 and Slo_Varchar1 = filtry_model) THEN
	Select Slo_Id into IDfiltry_model from Slownik where Slo_InternalId = 7 and Slo_Varchar1 = filtry_model;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (7,'Modele filtrow',filtry_model);
    select last_insert_id() into IDfiltry_model;
END IF;

/*Filtry model - słownik: 'Modele przeciwwag', 9*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 9 and Slo_Varchar1 = przeciwwaga_mdl) THEN
	Select Slo_Id into IDprzeciwwaga_mdl from Slownik where Slo_InternalId = 9 and Slo_Varchar1 = przeciwwaga_mdl;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (9,'Modele przeciwwag',przeciwwaga_mdl);
    select last_insert_id() into IDprzeciwwaga_mdl;
END IF;

/*słownik: 'Rodzaje przeciwwag', 12*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 12 and Slo_Varchar1 = przeciwwaga_rodzaj) THEN
	Select Slo_Id into IDprzeciwwaga_rodzaj from Slownik where Slo_InternalId = 12 and Slo_Varchar1 = przeciwwaga_rodzaj;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (12,'Rodzaje przeciwwag',przeciwwaga_rodzaj);
    select last_insert_id() into IDprzeciwwaga_rodzaj;
END IF;

/*słownik: 'Systemy antywibracyjne', 13*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 13 and Slo_Varchar1 = system_antywibracyjny) THEN
	Select Slo_Id into IDsystem_antywibracyjny from Slownik where Slo_InternalId = 13 and Slo_Varchar1 = system_antywibracyjny;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (13,'Systemy antywibracyjne',system_antywibracyjny);
    select last_insert_id() into IDsystem_antywibracyjny;
END IF;

/*słownik: 'Rodzaj lozysk powietrznych', 14*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 14 and Slo_Varchar1 = lozyska_pow_rodzaj) THEN
	Select Slo_Id into IDlozyska_pow_rodzaj from Slownik where Slo_InternalId = 14 and Slo_Varchar1 = lozyska_pow_rodzaj;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (14,'Rodzaje lozysk powietrznych',lozyska_pow_rodzaj);
    select last_insert_id() into IDlozyska_pow_rodzaj;
END IF;

/*słownik: 'Modele lozysk powietrznych', 15*/
IF EXISTS(Select * from Slownik where Slo_InternalId = 15 and Slo_Varchar1 = lozyska_pow_model) THEN
	Select Slo_Id into IDlozyska_pow_rodzaj from Slownik where Slo_InternalId = 15 and Slo_Varchar1 = lozyska_pow_model;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (15,'Modele lozysk powietrznych',lozyska_pow_model);
    select last_insert_id() into IDlozyska_pow_model;
END IF;


/*Producent*/
IF EXISTS(Select * from Producenci where Prd_PelnaNazwa = nazwa_producenta) THEN
	Select Prd_Id into prdId from Producenci where Prd_PelnaNazwa = nazwa_producenta;
ELSE 
	
	Insert into Producenci (Prd_PelnaNazwa) values (nazwa_producenta);
    select last_insert_id() into prdId;
END IF;

IF EXISTS(Select * from UkladPneumatyczny where Upn_FiltryModel = IDfiltry_model
and Upn_PrzeciwwagaModel = IDprzeciwwaga_mdl
and Upn_PrzeciwwagaRodzaj = IDprzeciwwaga_rodzaj
and Upn_SystemAntywibracyjny = IDsystem_antywibracyjny
and Upn_LozyskaPowRodzaj = IDlozyska_pow_rodzaj
and Upn_LozyskaPowModel = IDlozyska_pow_model
and Upn_LozyskaPowParametryUst = lozyska_pow_par
and Upn_PrdId = prdId
and Upn_Uwagi = uwagi) THEN
	Select Upn_Id into prdId from UkladPneumatyczny where Upn_FiltryModel = IDfiltry_model
and Upn_PrzeciwwagaModel = IDprzeciwwaga_mdl
and Upn_PrzeciwwagaRodzaj = IDprzeciwwaga_rodzaj
and Upn_SystemAntywibracyjny = IDsystem_antywibracyjny
and Upn_LozyskaPowRodzaj = IDlozyska_pow_rodzaj
and Upn_LozyskaPowModel = IDlozyska_pow_model
and Upn_LozyskaPowParametryUst = lozyska_pow_par
and Upn_PrdId = prdId
and Upn_Uwagi = uwagi;

ELSE 
	
	Insert into UkladPneumatyczny 
(Upn_FiltryModel,
Upn_PrzeciwwagaModel,
Upn_PrzeciwwagaRodzaj, 
Upn_SystemAntywibracyjny, 
Upn_LozyskaPowRodzaj, 
Upn_LozyskaPowModel, 
Upn_LozyskaPowParametryUst, 
Upn_PrdId,
Upn_Uwagi) 

VALUES (IDfiltry_model,
IDprzeciwwaga_mdl,
IDprzeciwwaga_rodzaj,
IDsystem_antywibracyjny,
IDlozyska_pow_rodzaj,
IDlozyska_pow_model,
lozyska_pow_par,
prdId,
uwagi);
    select last_insert_id() into upnid;
END IF;

	select upnid;


END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `urzadzeniaio_wprowadz_dane` (IN `hamulec_rodzaj` VARCHAR(45), IN `hamulec_napiecie` VARCHAR(45), IN `krancowki_rodzaj` VARCHAR(45), IN `krancowki_zasilanie` VARCHAR(45), IN `kontrolacis` VARCHAR(45), IN `inne_urzadzenia` VARCHAR(45), IN `uwagi` VARCHAR(255))  BEGIN
declare IDhamulec_rodzaj int;
declare IDkrancowki_rodzaj int;
declare UIOID int;

IF EXISTS (select inne_urzadzenia from dual where inne_urzadzenia = '') then
select null into inne_urzadzenia from dual;
END IF;

IF EXISTS(Select * from Slownik where Slo_InternalId = 2 and Slo_Varchar1 = hamulec_rodzaj) THEN
	Select Slo_Id into IDhamulec_rodzaj from Slownik where Slo_InternalId = 2 and Slo_Varchar1 = hamulec_rodzaj;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (2,'Rodzaje hamulców',hamulec_rodzaj);
    select last_insert_id() into IDhamulec_rodzaj;
END IF;


IF EXISTS(Select * from Slownik where Slo_InternalId = 3 and Slo_Varchar1 = krancowki_rodzaj) THEN
	Select Slo_Id into IDkrancowki_rodzaj from Slownik where Slo_InternalId = 3 and Slo_Varchar1 = krancowki_rodzaj;
ELSE 
	
	Insert into Slownik (Slo_InternalId, Slo_Nazwa, Slo_Varchar1) values (3,'Rodzaje krancowek',krancowki_rodzaj);
    select last_insert_id() into IDkrancowki_rodzaj;
END IF;

IF EXISTS(Select * from UrzadzeniaIO where Uio_HamulecRodzaj = IDhamulec_rodzaj and
Uio_HamulecNapiecie =hamulec_napiecie
and Uio_KrancowkiRodzaj =IDkrancowki_rodzaj
and Uio_KrancowkiZasilanie=krancowki_zasilanie
and Uio_KontrolaCisnieniaRodzajSygn=kontrolacis
and Uio_Uwagi= uwagi) THEN
Select Uio_Id into UIOID from UrzadzeniaIO where 
Uio_HamulecRodzaj = IDhamulec_rodzaj and
Uio_HamulecNapiecie = hamulec_napiecie
and Uio_KrancowkiRodzaj = IDkrancowki_rodzaj
and Uio_KrancowkiZasilanie = krancowki_zasilanie
and Uio_KontrolaCisnieniaRodzajSygn = kontrolacis
and Uio_InneUrzadzenia = inne_urzadzenia
and Uio_Uwagi = uwagi;
ELSE 
	
	Insert into UrzadzeniaIO (
Uio_HamulecRodzaj,
Uio_HamulecNapiecie,
Uio_KrancowkiRodzaj,
Uio_KrancowkiZasilanie,
Uio_KontrolaCisnieniaRodzajSygn,
Uio_InneUrzadzenia,
Uio_Uwagi)
VALUES (
IDhamulec_rodzaj,
hamulec_napiecie,
IDkrancowki_rodzaj,
krancowki_zasilanie,
kontrolacis,
inne_urzadzenia,
uwagi);
select last_insert_id() into UIOID;

END IF;


select UIOID;

	
END$$

CREATE DEFINER=`cmms_user`@`%` PROCEDURE `uzytkownicy_wprowadz_dane` (IN `login` VARCHAR(45), IN `imie` VARCHAR(45), IN `nazwisko` VARCHAR(45), IN `haslo` VARCHAR(255), IN `rola` VARCHAR(50))  BEGIN

Insert into Uzytkownicy(Uzy_Login, Uzy_Imie, Uzy_Nazwisko, Uzy_Haslo, Uzy_Rola) 
values (login, imie,nazwisko, md5(haslo), (select Slo_Id from Slownik where Slo_Varchar1 = rola limit 1));

END$$

--
-- Funkcje
--
CREATE DEFINER=`cmms_user`@`%` FUNCTION `czy_login_w_bazie` (`login` VARCHAR(12)) RETURNS INT(11) BEGIN 
  DECLARE result int;
  IF ((SELECT count(*) FROM Uzytkownicy WHERE Uzy_Login = login) > 0) THEN
  
    	SET result = 1;
    
   ELSE 
   SET result = 0;
   END IF;

RETURN (result);
END$$

CREATE DEFINER=`cmms_user`@`%` FUNCTION `czy_poprawne_haslo` (`login` VARCHAR(20), `haslo` VARCHAR(12)) RETURNS INT(11) BEGIN
    DECLARE p INT;
    DECLARE haslozbazy varchar(120);
    set haslozbazy = (select Uzy_Haslo from Uzytkownicy where Uzy_Login = login);
 
    IF haslozbazy = (select md5(haslo) from dual) THEN
 		SET p = 1;
    ELSE# IF haslozbazy != (select md5(haslo) from dual) THEN
        SET p = 0;
    END IF;
 
 RETURN (p);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `CzytnikiLinialu`
--

CREATE TABLE `CzytnikiLinialu` (
  `Cln_Id` int(11) NOT NULL,
  `Cln_RodzajSygnalu` varchar(45) DEFAULT NULL,
  `Cln_SposobMontazu` varchar(45) DEFAULT NULL,
  `Cln_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `CzytnikiLinialu`
--

INSERT INTO `CzytnikiLinialu` (`Cln_Id`, `Cln_RodzajSygnalu`, `Cln_SposobMontazu`, `Cln_Uwagi`) VALUES
(1, '43', '44', 'test'),
(3, '114', '115', 't'),
(4, '7', '11', '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Glowice`
--

CREATE TABLE `Glowice` (
  `Glw_Id` int(11) NOT NULL,
  `Glw_Nazwa` varchar(45) NOT NULL,
  `Glw_PrdId` int(11) NOT NULL,
  `Glw_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Glowice`
--

INSERT INTO `Glowice` (`Glw_Id`, `Glw_Nazwa`, `Glw_PrdId`, `Glw_Uwagi`) VALUES
(1, 'Glowica1', 2, 'To jest pierwsza glowica'),
(3, 'Glowica1', 2, 'To jest pierwsza glowica'),
(4, 'Glowica3', 2, 'To jest trzecia glowica'),
(5, 'test glowica', 5, 'test'),
(6, 'nowa', 1, 'test'),
(7, 'test', 1, 'test'),
(8, 'testowansko', 6, 'test'),
(9, 'testowansko', 6, 'test'),
(10, 'test', 1, 'test'),
(11, 'gdfg', 1, 'gfdf'),
(12, 'test', 3, 'test'),
(13, 'sfdsf', 1, 'fsdfdf'),
(14, 'asda', 3, 'czxc'),
(15, 'r', 7, 'r'),
(16, 'e', 3, 'e'),
(17, 'e', 9, 'e'),
(18, 't', 10, 't'),
(19, '', 11, ''),
(20, 'a', 1, 'b'),
(21, 'a', 3, NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Klienci`
--

CREATE TABLE `Klienci` (
  `Kln_Id` int(11) NOT NULL,
  `Kln_PelnaNazwa` varchar(200) NOT NULL,
  `Kln_KrotkaNazwa` varchar(45) DEFAULT NULL,
  `Kln_Nip` varchar(100) NOT NULL,
  `Kln_Adres` varchar(45) DEFAULT NULL,
  `Kln_Region` varchar(100) DEFAULT NULL,
  `Kln_KodPocztowy` varchar(15) DEFAULT NULL,
  `Kln_Kraj` varchar(20) DEFAULT NULL,
  `Kln_Telefon` varchar(25) DEFAULT NULL,
  `Kln_Fax` varchar(25) DEFAULT NULL,
  `Kln_Mail` varchar(100) DEFAULT NULL,
  `Kln_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Klienci`
--

INSERT INTO `Klienci` (`Kln_Id`, `Kln_PelnaNazwa`, `Kln_KrotkaNazwa`, `Kln_Nip`, `Kln_Adres`, `Kln_Region`, `Kln_KodPocztowy`, `Kln_Kraj`, `Kln_Telefon`, `Kln_Fax`, `Kln_Mail`, `Kln_Uwagi`) VALUES
(1, 'Biedronka', 'Biedr', '432423542', 'Kraków', 'Małopolskie', '30-389', 'Polska', '5423231', '23124324', 'biedr@b.com', 'test'),
(2, 'Lidl', 'l', '543543', 'Krakow', 'Mal', '234', '4', 'tes', 'sgsd', 'fdsfs', 'fdsf'),
(3, 'test', 'testt', 'st', 'tstg', 'dg', 'gdfg', 'gfd', 'gdg', 'sfs', 'fsdf', 'fsfs'),
(4, 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e', 'e'),
(5, '', '', '', '', '', '', '', '', '', '', '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `KompensacjaTemperatury`
--

CREATE TABLE `KompensacjaTemperatury` (
  `KTM_ID` int(11) NOT NULL,
  `KTM_RodzajCzujnikow` int(11) DEFAULT NULL,
  `KTM_Interfejs` varchar(45) DEFAULT NULL,
  `KTM_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Linialy`
--

CREATE TABLE `Linialy` (
  `Lin_Id` int(11) NOT NULL,
  `Lin_material` varchar(100) DEFAULT NULL,
  `Lin_rozdzielczosc` varchar(45) DEFAULT NULL,
  `Lin_rodzajsygnalu` varchar(45) DEFAULT NULL,
  `Lin_rodzajsygnaluszcz` varchar(45) DEFAULT NULL,
  `Lin_sposobmontazu` varchar(150) DEFAULT NULL,
  `Lin_ClnId` int(11) DEFAULT NULL,
  `Lin_PrdId` int(11) DEFAULT NULL,
  `Lin_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Linialy`
--

INSERT INTO `Linialy` (`Lin_Id`, `Lin_material`, `Lin_rozdzielczosc`, `Lin_rodzajsygnalu`, `Lin_rodzajsygnaluszcz`, `Lin_sposobmontazu`, `Lin_ClnId`, `Lin_PrdId`, `Lin_Uwagi`) VALUES
(1, 'testt', 'est', '48', 'test', '49', 1, 1, 'tests'),
(2, 'gdgdg', 'dgdg', '63', 'dfgdg', '64', 1, 3, 'fsdfsg'),
(3, 'ff', 'ff', '76', 'ff', '77', 1, 3, 'fff'),
(4, 'r', 'r', '89', 'rr', '90', 1, 1, 't'),
(5, 'e', 'e', '102', 'e', '103', 1, 1, 'e'),
(6, 't', 't', '116', 'u', '117', 3, 10, 'tt'),
(7, '', '', '7', '', '11', 4, 11, '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Maszyny`
--

CREATE TABLE `Maszyny` (
  `Mas_Id` int(11) NOT NULL,
  `Mas_PrdId` int(11) NOT NULL,
  `Mas_Model` varchar(45) NOT NULL,
  `Mas_ZakresX` varchar(45) DEFAULT NULL,
  `Mas_ZakresY` varchar(45) DEFAULT NULL,
  `Mas_ZakresZ` varchar(45) DEFAULT NULL,
  `Mas_PMaId` int(11) DEFAULT NULL,
  `Mas_GlwId` int(11) DEFAULT NULL,
  `Mas_PinId` int(11) DEFAULT NULL,
  `Mas_UpnId` int(11) DEFAULT NULL,
  `Mas_NapId` int(11) DEFAULT NULL,
  `Mas_OprId` int(11) DEFAULT NULL,
  `Mas_KlnId` int(11) DEFAULT NULL,
  `Mas_LinId` int(11) DEFAULT NULL,
  `Mas_UioId` int(11) DEFAULT NULL,
  `Mas_StrId` int(11) DEFAULT NULL,
  `Mas_KmtId` int(11) DEFAULT NULL,
  `Mas_TabZnamionowa` varchar(45) DEFAULT NULL,
  `Mas_Opis` varchar(255) DEFAULT NULL,
  `Mas_Informacje` varchar(255) DEFAULT NULL,
  `Mas_UtworzonePrzez` int(11) DEFAULT NULL,
  `Mas_DataUtworzenia` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Mas_DataAktualizacji` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Mas_Aktywnosc` int(11) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Napedy`
--

CREATE TABLE `Napedy` (
  `Nap_Id` int(11) NOT NULL,
  `Nap_ModelSilnika` varchar(45) NOT NULL,
  `Nap_Parametry` varchar(45) DEFAULT NULL,
  `Nap_RodzajNapedu` varchar(45) DEFAULT NULL,
  `Nap_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Napedy`
--

INSERT INTO `Napedy` (`Nap_Id`, `Nap_ModelSilnika`, `Nap_Parametry`, `Nap_RodzajNapedu`, `Nap_Uwagi`) VALUES
(1, 'test', 'test', '42', 'test'),
(2, 'm', 's', '62', 'fsdf'),
(3, 'ee', 'ee', '75', 'ee'),
(4, 'tt', 't', '88', 't'),
(5, 'e', 'e', '101', 'e'),
(6, 't', 't', '88', 't'),
(7, '', '', '40', '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Oprogramowanie`
--

CREATE TABLE `Oprogramowanie` (
  `Opr_Id` int(11) NOT NULL,
  `Opr_Rodzaj` varchar(100) DEFAULT NULL,
  `Opr_wersja` varchar(100) DEFAULT NULL,
  `Opr_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Oprogramowanie`
--

INSERT INTO `Oprogramowanie` (`Opr_Id`, `Opr_Rodzaj`, `Opr_wersja`, `Opr_Uwagi`) VALUES
(1, 'a', 'a', 'a'),
(2, 'b', 'b', 'b'),
(3, 'sfsdf', 'fsfs', 'fsdfsd'),
(4, 'aaa', 'sss', 'sss'),
(5, 't', 'tt', 't'),
(6, 'e', 'e', 'e'),
(7, 't', 't', 't'),
(8, '', '', '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Pinole`
--

CREATE TABLE `Pinole` (
  `Pin_Id` int(11) NOT NULL,
  `Pin_WymiarZewnetrzny` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Pin_WymiarsrubMontazu` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Pin_AdapterGlowicy` varchar(45) NOT NULL,
  `Pin_Opis` varchar(100) DEFAULT NULL,
  `Pin_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Pinole`
--

INSERT INTO `Pinole` (`Pin_Id`, `Pin_WymiarZewnetrzny`, `Pin_WymiarsrubMontazu`, `Pin_AdapterGlowicy`, `Pin_Opis`, `Pin_Uwagi`) VALUES
(1, 'test', 'test', '0', 'fsdf23', 'afdsaf'),
(2, 'tgd', 'gsd', '0', 'tst', 'test'),
(3, 'sfdsdf', 'fsdfs', '0', 'sfsdf', 'fsdf'),
(4, 'zcxzz', 'fsf', '0', 'fscz', 'fsas'),
(5, 'r', 'r', '0', 'r', 'r'),
(6, 'e', 'e', '0', 'e', 'e'),
(7, 't', 't', '0', 't', 't'),
(8, '', '', '0', '', ''),
(9, '4', '5', 'ad', NULL, NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Pliki`
--

CREATE TABLE `Pliki` (
  `Plk_Id` int(11) NOT NULL,
  `Plk_Typ` int(11) NOT NULL,
  `Plk_Plik` blob,
  `Plk_ObjTyp` int(11) DEFAULT NULL,
  `Plk_ObjId` int(11) NOT NULL,
  `Plk_Plik1` mediumblob,
  `Plk_DataUtworzenia` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Plk_DataAktualizacji` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Plk_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Pomiary`
--

CREATE TABLE `Pomiary` (
  `Pom_Id` int(11) NOT NULL,
  `Pom_ObjID` int(11) NOT NULL,
  `Pom_TypObj` int(11) NOT NULL,
  `Pom_UzyId` int(11) NOT NULL,
  `Pom_Data` timestamp NOT NULL,
  `Pom_DataKolejnegoPom` timestamp NOT NULL,
  `Pom_Uwagi` varchar(255) DEFAULT NULL,
  `Pom_DataAktualizacji` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Producenci`
--

CREATE TABLE `Producenci` (
  `Prd_Id` int(11) NOT NULL,
  `Prd_PelnaNazwa` varchar(100) NOT NULL,
  `Prd_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Producenci`
--

INSERT INTO `Producenci` (`Prd_Id`, `Prd_PelnaNazwa`, `Prd_Uwagi`) VALUES
(1, 'Producent2', NULL),
(2, 'Producent1', NULL),
(3, 'Producent3', NULL),
(5, 'testowy producent', NULL),
(6, 'tescik', NULL),
(7, 'rr', NULL),
(8, 'r', NULL),
(9, 'e', NULL),
(10, 't', NULL),
(11, '', NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Sesje`
--

CREATE TABLE `Sesje` (
  `Ses_Id` int(11) NOT NULL,
  `Ses_UzyId` int(11) DEFAULT NULL,
  `Ses_DataLogowania` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Slownik`
--

CREATE TABLE `Slownik` (
  `Slo_Id` int(11) NOT NULL,
  `Slo_InternalId` int(11) DEFAULT NULL,
  `Slo_Nazwa` varchar(45) DEFAULT NULL,
  `Slo_ParentId` varchar(45) DEFAULT NULL,
  `Slo_Int1` int(11) DEFAULT NULL,
  `Slo_Float1` float DEFAULT NULL,
  `Slo_Varchar1` varchar(150) DEFAULT NULL,
  `Slo_Int2` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Slownik`
--

INSERT INTO `Slownik` (`Slo_Id`, `Slo_InternalId`, `Slo_Nazwa`, `Slo_ParentId`, `Slo_Int1`, `Slo_Float1`, `Slo_Varchar1`, `Slo_Int2`) VALUES
(1, 1, 'Role uzytkownikow', NULL, NULL, NULL, 'Administrator', NULL),
(2, 1, 'Role użytkowników', NULL, NULL, NULL, 'Serwisant', NULL),
(3, 2, 'Rodzaje krancowek', NULL, NULL, NULL, 'Mechaniczne', NULL),
(4, 2, 'Rodzaje krancowek', NULL, NULL, NULL, 'Optyczne', NULL),
(5, 2, 'Rodzaje krancowek', NULL, NULL, NULL, 'Magnetyczne', NULL),
(6, 3, 'Rodzaje hamulców', NULL, NULL, NULL, '', NULL),
(7, 4, 'Rodzaje sygnałów', NULL, NULL, NULL, '', NULL),
(9, 6, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, '', NULL),
(10, 7, 'Modele filtrow', NULL, NULL, NULL, '', NULL),
(11, 8, 'Sposoby montazu', NULL, NULL, NULL, '', NULL),
(12, 9, 'Modele przeciwwag', NULL, NULL, NULL, '', NULL),
(14, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, '', NULL),
(15, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, '', NULL),
(16, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, '', NULL),
(17, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, '', NULL),
(18, 10, 'Typy plikow', NULL, NULL, NULL, '', NULL),
(19, 16, 'Typy obiektow', NULL, NULL, NULL, '', NULL),
(32, 7, 'Modele filtrow', NULL, NULL, NULL, 'test', NULL),
(33, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'test', NULL),
(34, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, 'test', NULL),
(35, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, 'test', NULL),
(36, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, 'test', NULL),
(37, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, 'test', NULL),
(38, 17, 'Rodzaje interfejsów', NULL, NULL, NULL, '', NULL),
(39, 18, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, '', NULL),
(40, 19, 'Rodzaje napedow', NULL, NULL, NULL, '', NULL),
(42, 19, 'Rodzeje napedow', NULL, NULL, NULL, 'test', NULL),
(43, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'test', NULL),
(44, 8, 'Sposoby montazu', NULL, NULL, NULL, 'test', NULL),
(48, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'tseet', NULL),
(49, 8, 'Sposoby montazu', NULL, NULL, NULL, 'tsets', NULL),
(50, 17, 'Rodzaje interfejsów', NULL, NULL, NULL, 'testowy', NULL),
(51, 18, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, 'testowa', NULL),
(52, 2, 'Rodzaje hamulców', NULL, NULL, NULL, 'test', NULL),
(53, 3, 'Rodzaje krancowek', NULL, NULL, NULL, 'test', NULL),
(54, 7, 'Modele filtrow', NULL, NULL, NULL, 'mod2', NULL),
(55, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'mod2', NULL),
(56, 7, 'Modele filtrow', NULL, NULL, NULL, 'ggdfg', NULL),
(57, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'gdfgdfg', NULL),
(58, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, 'dgdfg', NULL),
(59, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, 'gdfgdg', NULL),
(60, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, 'gdgdg', NULL),
(61, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, 'gdgdg', NULL),
(62, 19, 'Rodzeje napedow', NULL, NULL, NULL, 'fdsf', NULL),
(63, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'gdgdgg', NULL),
(64, 8, 'Sposoby montazu', NULL, NULL, NULL, 'gdgdg', NULL),
(65, 17, 'Rodzaje interfejsów', NULL, NULL, NULL, 'tset', NULL),
(66, 18, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, 'tst', NULL),
(67, 2, 'Rodzaje hamulców', NULL, NULL, NULL, 'gdfg', NULL),
(68, 3, 'Rodzaje krancowek', NULL, NULL, NULL, 'gdfgdg', NULL),
(69, 7, 'Modele filtrow', NULL, NULL, NULL, 'rr', NULL),
(70, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'eee', NULL),
(71, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, 'eee', NULL),
(72, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, 'ee', NULL),
(73, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, 'eeee', NULL),
(74, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, 'eeee', NULL),
(75, 19, 'Rodzeje napedow', NULL, NULL, NULL, 'eee', NULL),
(76, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'ff', NULL),
(77, 8, 'Sposoby montazu', NULL, NULL, NULL, 'ff', NULL),
(78, 17, 'Rodzaje interfejsów', NULL, NULL, NULL, 'dd', NULL),
(79, 18, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, 'gg', NULL),
(80, 2, 'Rodzaje hamulców', NULL, NULL, NULL, 'dddd', NULL),
(81, 3, 'Rodzaje krancowek', NULL, NULL, NULL, 'fff', NULL),
(82, 7, 'Modele filtrow', NULL, NULL, NULL, 'r', NULL),
(83, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'r', NULL),
(84, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, 'r', NULL),
(85, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, 'r', NULL),
(86, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, 'rr', NULL),
(87, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, 'rr', NULL),
(88, 19, 'Rodzeje napedow', NULL, NULL, NULL, 't', NULL),
(89, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'r', NULL),
(90, 8, 'Sposoby montazu', NULL, NULL, NULL, 'r', NULL),
(91, 17, 'Rodzaje interfejsów', NULL, NULL, NULL, 't', NULL),
(92, 18, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, 't', NULL),
(93, 2, 'Rodzaje hamulców', NULL, NULL, NULL, 't', NULL),
(94, 3, 'Rodzaje krancowek', NULL, NULL, NULL, 't', NULL),
(95, 7, 'Modele filtrow', NULL, NULL, NULL, 'e', NULL),
(96, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'e', NULL),
(97, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, 'e', NULL),
(98, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, 'e', NULL),
(99, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, 'e', NULL),
(100, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, 'e', NULL),
(101, 19, 'Rodzeje napedow', NULL, NULL, NULL, 'e', NULL),
(102, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'e', NULL),
(103, 8, 'Sposoby montazu', NULL, NULL, NULL, 'e', NULL),
(104, 17, 'Rodzaje interfejsów', NULL, NULL, NULL, 'e', NULL),
(105, 18, 'Rodzaje szat sterowniczych', NULL, NULL, NULL, 'e', NULL),
(106, 2, 'Rodzaje hamulców', NULL, NULL, NULL, 'eee', NULL),
(107, 3, 'Rodzaje krancowek', NULL, NULL, NULL, 'e', NULL),
(108, 7, 'Modele filtrow', NULL, NULL, NULL, 't', NULL),
(109, 9, 'Modele przeciwwag', NULL, NULL, NULL, 'tt', NULL),
(110, 12, 'Rodzaje przeciwwag', NULL, NULL, NULL, 't', NULL),
(111, 13, 'Systemy antywibracyjne', NULL, NULL, NULL, 't', NULL),
(112, 14, 'Rodzaj lozysk powietrznych', NULL, NULL, NULL, 't', NULL),
(113, 15, 'Modele lozysk powietrznych', NULL, NULL, NULL, 't', NULL),
(114, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 't', NULL),
(115, 8, 'Sposoby montazu', NULL, NULL, NULL, 't', NULL),
(116, 4, 'Rodzaje sygnalow', NULL, NULL, NULL, 'tt', NULL),
(117, 8, 'Sposoby montazu', NULL, NULL, NULL, 'u', NULL),
(118, 2, 'Rodzaje hamulców', NULL, NULL, NULL, '', NULL),
(119, 20, 'Rodzaje czujnikow', NULL, NULL, NULL, NULL, NULL),
(120, 20, 'Rodzaje czujnikow', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Sterowniki`
--

CREATE TABLE `Sterowniki` (
  `Str_Id` int(11) NOT NULL,
  `Str_PrdId` int(11) NOT NULL,
  `Str_Model` varchar(45) NOT NULL,
  `Str_RodzajSzatySter` varchar(45) DEFAULT NULL,
  `Str_RodzajInterfejsu` varchar(45) DEFAULT NULL,
  `Str_Uwagi` varchar(255) DEFAULT NULL,
  `Str_RodzajPaneluOperatora` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Sterowniki`
--

INSERT INTO `Sterowniki` (`Str_Id`, `Str_PrdId`, `Str_Model`, `Str_RodzajSzatySter`, `Str_RodzajInterfejsu`, `Str_Uwagi`, `Str_RodzajPaneluOperatora`) VALUES
(1, 1, 'mod1', '51', '50', 'test', NULL),
(2, 1, 'tet', '66', '65', 'tst', NULL),
(3, 1, 'eee', '79', '78', 'ff', NULL),
(4, 2, 't', '92', '91', 't', NULL),
(5, 1, 'e', '105', '104', 'e', NULL),
(6, 10, 't', NULL, '92', 't', NULL),
(7, 11, '', NULL, '39', '', NULL),
(8, 11, '', NULL, '39', '', NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `UkladPneumatyczny`
--

CREATE TABLE `UkladPneumatyczny` (
  `Upn_id` int(11) NOT NULL,
  `Upn_FiltryModel` int(11) DEFAULT NULL,
  `Upn_PrzeciwwagaModel` int(11) DEFAULT NULL,
  `Upn_PrzeciwwagaRodzaj` int(11) DEFAULT NULL,
  `Upn_SystemAntywibracyjny` int(11) DEFAULT NULL,
  `Upn_LozyskaPowRodzaj` int(11) DEFAULT NULL,
  `Upn_LozyskaPowModel` int(11) DEFAULT NULL,
  `Upn_LozyskaPowParametryUst` varchar(45) DEFAULT NULL,
  `Upn_PrdId` int(11) NOT NULL,
  `Upn_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `UkladPneumatyczny`
--

INSERT INTO `UkladPneumatyczny` (`Upn_id`, `Upn_FiltryModel`, `Upn_PrzeciwwagaModel`, `Upn_PrzeciwwagaRodzaj`, `Upn_SystemAntywibracyjny`, `Upn_LozyskaPowRodzaj`, `Upn_LozyskaPowModel`, `Upn_LozyskaPowParametryUst`, `Upn_PrdId`, `Upn_Uwagi`) VALUES
(1, 32, 33, 34, 35, 36, 37, 'test', 2, 'testowa uwaga'),
(2, 54, 55, 34, 35, 37, NULL, 'test', 1, 'tst'),
(3, 56, 57, 58, 59, 60, 61, 'gdfgfd', 2, 'dgdg'),
(4, 69, 70, 71, 72, 73, 74, 'ee', 1, 'fsf'),
(5, 82, 83, 84, 85, 86, 87, 'r', 8, 'rr'),
(6, 95, 96, 97, 98, 99, 100, 'e', 5, 'e'),
(7, 108, 109, 110, 111, 112, 113, 't', 10, 't'),
(8, 10, 12, 14, 15, 17, NULL, '', 11, ''),
(9, 10, 12, 14, 15, 17, NULL, '', 11, '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `UrzadzeniaIO`
--

CREATE TABLE `UrzadzeniaIO` (
  `Uio_id` int(11) NOT NULL,
  `Uio_HamulecRodzaj` int(11) NOT NULL,
  `Uio_HamulecNapiecie` varchar(45) NOT NULL,
  `Uio_KrancowkiRodzaj` int(11) NOT NULL,
  `Uio_KrancowkiZasilanie` varchar(45) NOT NULL,
  `Uio_KontrolaCisnieniaRodzajSygn` varchar(45) NOT NULL,
  `Uio_InneUrzadzenia` varchar(45) DEFAULT NULL,
  `Uio_Uwagi` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `UrzadzeniaIO`
--

INSERT INTO `UrzadzeniaIO` (`Uio_id`, `Uio_HamulecRodzaj`, `Uio_HamulecNapiecie`, `Uio_KrancowkiRodzaj`, `Uio_KrancowkiZasilanie`, `Uio_KontrolaCisnieniaRodzajSygn`, `Uio_InneUrzadzenia`, `Uio_Uwagi`) VALUES
(1, 52, 'test', 53, 'test', 'test', NULL, 'test'),
(2, 67, 'dgdfg', 68, 'gdgf', 'sdfs', NULL, 'sffds'),
(3, 80, 'ggg', 81, 'ddd', 'fff', NULL, 'ddd'),
(4, 93, 't', 94, 't', 't', NULL, 't'),
(5, 106, 'e', 107, 'e', 'e', NULL, 'e'),
(6, 118, '', 6, '', '', NULL, '');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `Uzytkownicy`
--

CREATE TABLE `Uzytkownicy` (
  `Uzy_Id` int(11) NOT NULL,
  `Uzy_Login` varchar(45) NOT NULL,
  `Uzy_Imie` varchar(45) NOT NULL,
  `Uzy_Nazwisko` varchar(45) NOT NULL,
  `Uzy_Haslo` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `Uzy_Rola` int(11) DEFAULT NULL,
  `Uzy_Aktywnosc` int(11) DEFAULT '1',
  `Uzy_DataOstatniegoLogowania` timestamp NULL DEFAULT NULL,
  `Uzy_DataUtworzenia` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Uzy_DataAktualizacji` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Zrzut danych tabeli `Uzytkownicy`
--

INSERT INTO `Uzytkownicy` (`Uzy_Id`, `Uzy_Login`, `Uzy_Imie`, `Uzy_Nazwisko`, `Uzy_Haslo`, `Uzy_Rola`, `Uzy_Aktywnosc`, `Uzy_DataOstatniegoLogowania`, `Uzy_DataUtworzenia`, `Uzy_DataAktualizacji`) VALUES
(1, 'Admin', 'Admin', 'Admin', '0192023a7bbd73250516f069df18b500', 1, 1, '2019-09-02 16:09:44', '2019-08-15 19:06:53', '2019-08-15 19:06:53'),
(2, 'MartaJ', 'Marta1', 'Janoska', 'a7d467bfbec8e7d5d7b932ae63d17a28', 1, 1, NULL, '2019-10-09 11:55:24', '2019-10-09 11:55:24'),
(3, 'Serwis', 'Serwis', 'Test', '52bc598185d707e2916d2a14820220a7', 2, 1, NULL, '2019-11-01 17:31:27', '2019-11-01 17:31:27'),
(4, 'Test', 'Test123', 'Test', '94501fa0f24a9daf88362d70288800aa', 1, 1, NULL, '2019-11-01 17:53:24', '2019-11-01 17:53:24'),
(5, 'Kojot13', 'Kajetan', 'Rzeberko', 'ab1ff7ecf8c03d65d4593100da1c22cd', 2, 1, NULL, '2019-11-01 18:12:07', '2019-11-01 18:12:07'),
(6, 'Goplana15', 'Kunegunda', 'Żak', '0b328b777edaf5a550794e5a35567f08', 1, 1, NULL, '2019-11-01 18:14:37', '2019-11-01 18:14:37'),
(7, 'Dlugopis', 'Edward', 'Planeta', '0b328b777edaf5a550794e5a35567f08', 2, 1, NULL, '2019-11-01 18:16:04', '2019-11-01 18:16:04'),
(8, 'Test4', 'Test', 'Test', '29fc1022e261c2bba9f7d7ff62b3beb0', 1, 1, NULL, '2019-11-01 18:28:25', '2019-11-01 18:28:25'),
(9, 'test5345', 'test', 'test', 'f7aa82c01d7246df54d66134132c23f2', 2, 1, NULL, '2019-11-01 18:39:24', '2019-11-01 18:39:24');

--
-- Wyzwalacze `Uzytkownicy`
--
DELIMITER $$
CREATE TRIGGER `Uzytkownicy_haslo` BEFORE INSERT ON `Uzytkownicy` FOR EACH ROW SET NEW.`Uzy_Haslo`= MD5(NEW.`Uzy_Haslo`)
$$
DELIMITER ;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `CzytnikiLinialu`
--
ALTER TABLE `CzytnikiLinialu`
  ADD PRIMARY KEY (`Cln_Id`);

--
-- Indeksy dla tabeli `Glowice`
--
ALTER TABLE `Glowice`
  ADD PRIMARY KEY (`Glw_Id`),
  ADD UNIQUE KEY `Glw_Id_UNIQUE` (`Glw_Id`),
  ADD KEY `fk_Glowice_1_idx` (`Glw_PrdId`);

--
-- Indeksy dla tabeli `Klienci`
--
ALTER TABLE `Klienci`
  ADD PRIMARY KEY (`Kln_Id`),
  ADD UNIQUE KEY `Kln_Id_UNIQUE` (`Kln_Id`),
  ADD UNIQUE KEY `Kln_Nip_UNIQUE` (`Kln_Nip`);

--
-- Indeksy dla tabeli `KompensacjaTemperatury`
--
ALTER TABLE `KompensacjaTemperatury`
  ADD PRIMARY KEY (`KTM_ID`);

--
-- Indeksy dla tabeli `Linialy`
--
ALTER TABLE `Linialy`
  ADD PRIMARY KEY (`Lin_Id`),
  ADD KEY `fk_Linialy_1_idx` (`Lin_ClnId`),
  ADD KEY `fk_Linialy_1_idx1` (`Lin_PrdId`);

--
-- Indeksy dla tabeli `Maszyny`
--
ALTER TABLE `Maszyny`
  ADD PRIMARY KEY (`Mas_Id`),
  ADD UNIQUE KEY `Mas_Id_UNIQUE` (`Mas_Id`),
  ADD KEY `fk_Maszyny_Klienci_idx` (`Mas_KlnId`),
  ADD KEY `fk_Maszyny_1_idx` (`Mas_PrdId`),
  ADD KEY `fk_Maszyny_2_idx` (`Mas_GlwId`),
  ADD KEY `fk_Maszyny_Napedy_idx` (`Mas_NapId`),
  ADD KEY `fk_Maszyny_1_idx1` (`Mas_UioId`),
  ADD KEY `fk_Maszyny_1_idx2` (`Mas_LinId`),
  ADD KEY `fk_Maszyny_1_idx3` (`Mas_UpnId`),
  ADD KEY `fk_Maszyny__idx` (`Mas_PinId`),
  ADD KEY `fk_Maszyny_Sterowniki_idx` (`Mas_StrId`),
  ADD KEY `fk_Maszyny_1_idx4` (`Mas_OprId`),
  ADD KEY `Mas_UtworzonePrzez` (`Mas_UtworzonePrzez`);

--
-- Indeksy dla tabeli `Napedy`
--
ALTER TABLE `Napedy`
  ADD PRIMARY KEY (`Nap_Id`);

--
-- Indeksy dla tabeli `Oprogramowanie`
--
ALTER TABLE `Oprogramowanie`
  ADD PRIMARY KEY (`Opr_Id`);

--
-- Indeksy dla tabeli `Pinole`
--
ALTER TABLE `Pinole`
  ADD PRIMARY KEY (`Pin_Id`);

--
-- Indeksy dla tabeli `Pliki`
--
ALTER TABLE `Pliki`
  ADD PRIMARY KEY (`Plk_Id`),
  ADD KEY `fk_Pliki_ObjTyp_Slo` (`Plk_Typ`),
  ADD KEY `fk_Pliki_Typ_Slo_idx` (`Plk_ObjTyp`);

--
-- Indeksy dla tabeli `Pomiary`
--
ALTER TABLE `Pomiary`
  ADD PRIMARY KEY (`Pom_Id`),
  ADD KEY `fk_Pomiary_TypObj_idx` (`Pom_TypObj`),
  ADD KEY `fk_Pomiary_Uzytkownicy_idx` (`Pom_UzyId`);

--
-- Indeksy dla tabeli `Producenci`
--
ALTER TABLE `Producenci`
  ADD PRIMARY KEY (`Prd_Id`),
  ADD UNIQUE KEY `Prd_Id_UNIQUE` (`Prd_Id`);

--
-- Indeksy dla tabeli `Sesje`
--
ALTER TABLE `Sesje`
  ADD PRIMARY KEY (`Ses_Id`),
  ADD KEY `fk_Sesje_Uzytkownicy_idx` (`Ses_UzyId`);

--
-- Indeksy dla tabeli `Slownik`
--
ALTER TABLE `Slownik`
  ADD PRIMARY KEY (`Slo_Id`);

--
-- Indeksy dla tabeli `Sterowniki`
--
ALTER TABLE `Sterowniki`
  ADD PRIMARY KEY (`Str_Id`),
  ADD UNIQUE KEY `Str_Id_UNIQUE` (`Str_Id`),
  ADD KEY `fk_Sterowniki_Producenci_idx` (`Str_PrdId`);

--
-- Indeksy dla tabeli `UkladPneumatyczny`
--
ALTER TABLE `UkladPneumatyczny`
  ADD PRIMARY KEY (`Upn_id`),
  ADD KEY `fk_UkladPneumatyczny_1_idx` (`Upn_PrdId`),
  ADD KEY `fk_UkladPneumatyczny_Slownik_idx` (`Upn_FiltryModel`),
  ADD KEY `fk_UkladPneumatyczny_Slownik1_idx` (`Upn_PrzeciwwagaModel`),
  ADD KEY `fk_UkladPneumatyczny_1_idx1` (`Upn_SystemAntywibracyjny`),
  ADD KEY `fk_UkladPneumatyczny_2_idx` (`Upn_LozyskaPowRodzaj`),
  ADD KEY `fk_UkladPneumatyczny_1_idx2` (`Upn_PrzeciwwagaRodzaj`),
  ADD KEY `fk_UkladPneumatyczny_LozyskaPowModel_Slo_idx` (`Upn_LozyskaPowModel`);

--
-- Indeksy dla tabeli `UrzadzeniaIO`
--
ALTER TABLE `UrzadzeniaIO`
  ADD PRIMARY KEY (`Uio_id`),
  ADD KEY `fk_UrzadzeniaIO_Slownik_idx` (`Uio_HamulecRodzaj`),
  ADD KEY `fk_UrzadzeniaIO_1_idx` (`Uio_KrancowkiRodzaj`);

--
-- Indeksy dla tabeli `Uzytkownicy`
--
ALTER TABLE `Uzytkownicy`
  ADD PRIMARY KEY (`Uzy_Id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT dla tabeli `CzytnikiLinialu`
--
ALTER TABLE `CzytnikiLinialu`
  MODIFY `Cln_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT dla tabeli `Glowice`
--
ALTER TABLE `Glowice`
  MODIFY `Glw_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT dla tabeli `Klienci`
--
ALTER TABLE `Klienci`
  MODIFY `Kln_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT dla tabeli `KompensacjaTemperatury`
--
ALTER TABLE `KompensacjaTemperatury`
  MODIFY `KTM_ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `Linialy`
--
ALTER TABLE `Linialy`
  MODIFY `Lin_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT dla tabeli `Maszyny`
--
ALTER TABLE `Maszyny`
  MODIFY `Mas_Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `Napedy`
--
ALTER TABLE `Napedy`
  MODIFY `Nap_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT dla tabeli `Oprogramowanie`
--
ALTER TABLE `Oprogramowanie`
  MODIFY `Opr_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT dla tabeli `Pinole`
--
ALTER TABLE `Pinole`
  MODIFY `Pin_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT dla tabeli `Pliki`
--
ALTER TABLE `Pliki`
  MODIFY `Plk_Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `Producenci`
--
ALTER TABLE `Producenci`
  MODIFY `Prd_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT dla tabeli `Sesje`
--
ALTER TABLE `Sesje`
  MODIFY `Ses_Id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `Slownik`
--
ALTER TABLE `Slownik`
  MODIFY `Slo_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT dla tabeli `Sterowniki`
--
ALTER TABLE `Sterowniki`
  MODIFY `Str_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT dla tabeli `UkladPneumatyczny`
--
ALTER TABLE `UkladPneumatyczny`
  MODIFY `Upn_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT dla tabeli `UrzadzeniaIO`
--
ALTER TABLE `UrzadzeniaIO`
  MODIFY `Uio_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT dla tabeli `Uzytkownicy`
--
ALTER TABLE `Uzytkownicy`
  MODIFY `Uzy_Id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `Glowice`
--
ALTER TABLE `Glowice`
  ADD CONSTRAINT `fk_Glowice_Producenci` FOREIGN KEY (`Glw_PrdId`) REFERENCES `Producenci` (`Prd_Id`);

--
-- Ograniczenia dla tabeli `Linialy`
--
ALTER TABLE `Linialy`
  ADD CONSTRAINT `fk_Linialy_CzytnikiLinialu` FOREIGN KEY (`Lin_ClnId`) REFERENCES `CzytnikiLinialu` (`Cln_Id`),
  ADD CONSTRAINT `fk_Linialy_Producenci` FOREIGN KEY (`Lin_PrdId`) REFERENCES `Producenci` (`Prd_Id`);

--
-- Ograniczenia dla tabeli `Maszyny`
--
ALTER TABLE `Maszyny`
  ADD CONSTRAINT `Maszyny_ibfk_1` FOREIGN KEY (`Mas_UtworzonePrzez`) REFERENCES `Uzytkownicy` (`Uzy_Id`),
  ADD CONSTRAINT `fk_Maszyny_Glowice` FOREIGN KEY (`Mas_GlwId`) REFERENCES `Glowice` (`Glw_Id`),
  ADD CONSTRAINT `fk_Maszyny_Klienci` FOREIGN KEY (`Mas_KlnId`) REFERENCES `Klienci` (`Kln_Id`),
  ADD CONSTRAINT `fk_Maszyny_Linialy` FOREIGN KEY (`Mas_LinId`) REFERENCES `Linialy` (`Lin_Id`),
  ADD CONSTRAINT `fk_Maszyny_Napedy` FOREIGN KEY (`Mas_NapId`) REFERENCES `Napedy` (`Nap_Id`),
  ADD CONSTRAINT `fk_Maszyny_Oprogramowanie` FOREIGN KEY (`Mas_OprId`) REFERENCES `Oprogramowanie` (`Opr_Id`),
  ADD CONSTRAINT `fk_Maszyny_Pinole` FOREIGN KEY (`Mas_PinId`) REFERENCES `Pinole` (`Pin_Id`),
  ADD CONSTRAINT `fk_Maszyny_Producenci` FOREIGN KEY (`Mas_PrdId`) REFERENCES `Producenci` (`Prd_Id`),
  ADD CONSTRAINT `fk_Maszyny_Sterowniki` FOREIGN KEY (`Mas_StrId`) REFERENCES `Sterowniki` (`Str_Id`),
  ADD CONSTRAINT `fk_Maszyny_UkladPneumatyczny` FOREIGN KEY (`Mas_UpnId`) REFERENCES `UkladPneumatyczny` (`Upn_id`),
  ADD CONSTRAINT `fk_Maszyny_UrzadzeniaIO` FOREIGN KEY (`Mas_UioId`) REFERENCES `UrzadzeniaIO` (`Uio_id`);

--
-- Ograniczenia dla tabeli `Pliki`
--
ALTER TABLE `Pliki`
  ADD CONSTRAINT `fk_Pliki_ObjTyp_Slo` FOREIGN KEY (`Plk_Typ`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_Pliki_Typ_Slo` FOREIGN KEY (`Plk_ObjTyp`) REFERENCES `Slownik` (`Slo_Id`);

--
-- Ograniczenia dla tabeli `Pomiary`
--
ALTER TABLE `Pomiary`
  ADD CONSTRAINT `fk_Pomiary_TypObj` FOREIGN KEY (`Pom_TypObj`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_Pomiary_Uzytkownicy` FOREIGN KEY (`Pom_UzyId`) REFERENCES `Uzytkownicy` (`Uzy_Id`);

--
-- Ograniczenia dla tabeli `Sesje`
--
ALTER TABLE `Sesje`
  ADD CONSTRAINT `fk_Sesje_Uzytkownicy` FOREIGN KEY (`Ses_UzyId`) REFERENCES `Uzytkownicy` (`Uzy_Id`);

--
-- Ograniczenia dla tabeli `Sterowniki`
--
ALTER TABLE `Sterowniki`
  ADD CONSTRAINT `fk_Sterowniki_Producenci` FOREIGN KEY (`Str_PrdId`) REFERENCES `Producenci` (`Prd_Id`);

--
-- Ograniczenia dla tabeli `UkladPneumatyczny`
--
ALTER TABLE `UkladPneumatyczny`
  ADD CONSTRAINT `fk_UkladPneumatyczny_FiltryModel_Slo` FOREIGN KEY (`Upn_FiltryModel`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_UkladPneumatyczny_LozyskaPowModel_Slo` FOREIGN KEY (`Upn_LozyskaPowModel`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_UkladPneumatyczny_LozyskaPowRodzaj_Slo` FOREIGN KEY (`Upn_LozyskaPowRodzaj`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_UkladPneumatyczny_Producenci` FOREIGN KEY (`Upn_PrdId`) REFERENCES `Producenci` (`Prd_Id`),
  ADD CONSTRAINT `fk_UkladPneumatyczny_PrzeciwwagaModel_Slo` FOREIGN KEY (`Upn_PrzeciwwagaModel`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_UkladPneumatyczny_PrzeciwwagaRodzaj_Slo` FOREIGN KEY (`Upn_PrzeciwwagaRodzaj`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_UkladPneumatyczny_SystemAntywibr_Slo` FOREIGN KEY (`Upn_SystemAntywibracyjny`) REFERENCES `Slownik` (`Slo_Id`);

--
-- Ograniczenia dla tabeli `UrzadzeniaIO`
--
ALTER TABLE `UrzadzeniaIO`
  ADD CONSTRAINT `fk_UrzadzeniaIO_Slownik` FOREIGN KEY (`Uio_HamulecRodzaj`) REFERENCES `Slownik` (`Slo_Id`),
  ADD CONSTRAINT `fk_UrzadzeniaIO_Slownik1` FOREIGN KEY (`Uio_KrancowkiRodzaj`) REFERENCES `Slownik` (`Slo_Id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
