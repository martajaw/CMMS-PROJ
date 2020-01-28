#!/usr/bin/env python
# -*- coding: cp1250 -*-
import kivy
import CMMsFunc
from kivy.core.image import Image as CoreImage
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.widget import Widget
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.label import Label
from kivy.uix.gridlayout import GridLayout
from kivy.config import Config
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen
from kivy.properties import ObjectProperty
from kivy.uix.popup import Popup
from kivy.uix.dropdown import DropDown
from kivy.uix.textinput import TextInput
from kivy.properties import ListProperty
from kivy.uix.recycleview.views import RecycleDataViewBehavior
from kivy.uix.button import Button
from kivy.properties import BooleanProperty, ListProperty, StringProperty, ObjectProperty, NumericProperty
from kivy.uix.recyclegridlayout import RecycleGridLayout
from kivy.uix.behaviors import FocusBehavior
from kivy.uix.recycleview.layout import LayoutSelectionBehavior
from kivy.uix.checkbox import CheckBox
import _locale
from kivy.logger import Logger
from kivy.uix.scatter import Scatter
_locale._getdefaultlocale = (lambda *args: ['en_US', 'utf8'])
import os
import io
from kivy.factory import Factory
from kivy.uix.image import Image
Config.set('graphics', 'resizable', '0')
#Config.set('graphics', 'width', '500')
#Config.set('graphics', 'height', '300')
Config.set('graphics', 'fullscreen', 'auto')
#Builder.load_file('myapp.kv')
####################################################
MAX_TABLE_COLS = 6
import mysql.connector
from mysql.connector import Error

class ImageDict(dict):
    def __missing__(self, key):
        self[key] = img = self.load(key)
        return img
    def load(self, key):
        # create a queue if not exist (could be moved to __init__)
        if not hasattr(self, '_queue'):
            self._queue = []
        # pop the oldest entry in the list and the dict
        if len(self._queue) >= 100:
            self.pop(self._queue.pop(0))
        # append this key as a newest entry in the queue
        self._queue.append(key)
        # implement image loading here and return the image instance
        print('loading', key)
        return 'Image for %s' % key











def convertToBinaryData(filename):
    # Convert digital data to binary format
    with open(filename, 'rb' ) as file:
        binaryData = file.read()
    return binaryData
#def PrzechowajPliki()
def insertBLOB(typ,Objtyp,ObjId,Uwagi, zdjecie):
    print("Inserting BLOB into python_employee table")
    try:
        polaczenie = CMMsFunc.polacz_z_bazadanych()
        kursor = CMMsFunc.stworz_kursor(polaczenie)

        sql_insert_blob_query = """ INSERT INTO Pliki
                          (Plk_typ,Plk_ObjTyp,Plk_ObjId,Plk_Uwagi,Plk_Plik) VALUES (%s,%s,%s,%s,%s)"""

        zdj = convertToBinaryData(zdjecie)
        #file = convertToBinaryData(biodataFile)
#121, 127, now(), zdj
        # Convert data into tuple format
        insert_blob_tuple = (typ, Objtyp,ObjId, Uwagi, zdj)
        result = kursor.execute(sql_insert_blob_query, insert_blob_tuple)
        polaczenie.commit()
        print("Image and file inserted successfully as a BLOB into python_employee table", result)

    except mysql.connector.Error as error:
        print("Failed inserting BLOB data into MySQL table {}".format(error))

    finally:
        if (polaczenie.is_connected()):
            kursor.close()
            polaczenie.close()
            print("MySQL connection is closed")

#insertBLOB(1, "Eric", "D:\Python\Articles\my_SQL\images\eric_photo.png",
 #          "D:\Python\Articles\my_SQL\images\eric_bioData.txt")
#insertBLOB(2, "Scott", "D:\Python\Articles\my_SQL\images\scott_photo.png",
#           "D:\Python\Articles\my_SQL\images\scott_bioData.txt")
class Picture(Scatter):
    source = StringProperty(None)



class ComboEdit(TextInput):


    options = ListProperty(('', ))

	 

    def __init__(self, **kw):
        ddn = self.drop_down = DropDown()
        ddn.bind(on_select=self.on_select)
        super(ComboEdit, self).__init__(**kw)
        

    def on_options(self, instance, value):
        ddn = self.drop_down
        ddn.clear_widgets()
        for widg in value:
            widg.bind(on_release=lambda btn: ddn.select(btn.text))
            ddn.add_widget(widg)
	
    def on_select(self, *args):
        self.text = args[1]


    def on_touch_up(self, touch):
        if touch.grab_current == self:
            self.drop_down.open(self)
        return super(ComboEdit, self).on_touch_up(touch)
####################################################
class ManagerEkranow(ScreenManager):
    panel_logowania = ObjectProperty(None)
    panel_glowny_admina = ObjectProperty(None)
    panel_glowny_serwis = ObjectProperty(None)
    panel_stworz_uzytkownika = ObjectProperty(None)
    panel_zarzadzaj_uzytkownikami = ObjectProperty(None)
    panel_edytuj_usun_uzytkownikow = ObjectProperty(None)
    panel_plikow = ObjectProperty(None)


####################################################
class PanelGlownyAdmin(Screen):
    pass



####################################################
class PanelGlownySerwis(Screen):
    pass

####################################################
class PanelZarzadzajUzytkownikami(Screen):
    pass
####################################################
class LoadDialog(FloatLayout):
    load = ObjectProperty(None)
    cancel = ObjectProperty(None)

####################################################
class SaveDialog(FloatLayout):
    save = ObjectProperty(None)
    #text_input = ObjectProperty(None)
    cancel = ObjectProperty(None)







####################################################
class PanelWprowadzDane(Screen):
    loadfile = ObjectProperty(None)
    savefile = ObjectProperty(None)
    aktywnasekcja = ''
    #text_input = ObjectProperty(None)
    max_plikow = 3
    maszyna = [0]
    glowica = [0]
    pinola = [0]
    up = [0]
    a = {'Maszyna': maszyna, 'Glowica': glowica, 'Pinola': pinola, 'UP': up}
    def aktywne_okno(self,nazwa):
        self.aktywnasekcja = nazwa

    @staticmethod
    def pudelko_zdjec(lista_sciezek):
        pudelko = BoxLayout(orientation='vertical')
        pudelko.cols = 3
        pudelko.row = 3
        #check_panel = GridLayout(orientation='horizontal')
        cb = CheckBox(active = False)
        #check_panel.add_widget(cb)
        #pudelko.add_widget(check_panel)
        rozmiarlisty = len(lista_sciezek)
        pliki = []
        if lista_sciezek[0] > 0:

            for i in range(lista_sciezek[0]):
                rozmiarlisty = rozmiarlisty - 2
                pliki.append(lista_sciezek[rozmiarlisty])
                print(i)
            for i in range(len(pliki)):
                print('tu jestem')
                plik = Image(source=pliki[i])
                pudelko.add_widget(plik)
        else:
            CMMsFunc.stworz_okno_bledu('Powiadomienie', 'Brak zdjęć').open()
        return pudelko

    def dismiss_popup(self):
        self._popup.dismiss()
    def show_picture(self,c):
       # decPic = self.a[key].encode('utf-8')
        #data = io.BytesIO(open(self.a[key], "rb").read())
       # data = data.encode('utf-8')
        #content = CoreImage(self.a[key], ext="png").texture
        #content.reload()
       if c == 'Maszyna':
           #self.s = PanelPlikow(name='pliki_maszyna')
           self.p = self.pudelko_zdjec(self.maszyna)
           #self.s.add_widget(self.p)
           #self.manager.current = 'pliki_maszyna'
           self._popup = Popup(title="Plik", content=self.p, size_hint=(None, None), size=(600, 600))
           self._popup.open()


    def show_load(self):
        #key = 'Maszyna'
        content = LoadDialog(load=self.load, cancel=self.dismiss_popup)
        self._popup = Popup(title="Load file", content=content,
                            size_hint=(0.9, 0.9))
        self._popup.open()

    #def show_save(self):
        #content = SaveDialog(save=self.save, cancel=self.dismiss_popup)
       # self._popup = Popup(title="Save file", content=content,
      #                      size_hint=(0.9, 0.9))
      #  self._popup.open()

    def load(self, path, filename):
        #with open(os.path.join(path, filename[0])) as stream:
            #self.text_input.text = stream.read()
        # to do odkomentowania później insertBLOB(121, 127, 1,'',os.path.join(path, filename[0]))
        zdj = convertToBinaryData(os.path.join(path, filename[0]))
        data = io.BytesIO(open(os.path.join(path, filename[0]), "rb").read())
        content = CoreImage(data, ext="png").texture
        #content.reload()
        filen = os.path.join(path, filename[0])
        #self.show_picture(filen)
        if self.aktywnasekcja == 'Maszyna':
            try:#Zwiększamy liczbę maszyna[0] z każdym dodanym zdjęciem. NIe może być więcej zdjęć niż max_plikow
                if self.maszyna[0] < self.max_plikow:
                    self.maszyna.append(os.path.join(path,filename[0]))
                    self.maszyna.append(convertToBinaryData(os.path.join(path, filename[0])))
                    self.maszyna[0] = self.maszyna[0]+1
                    CMMsFunc.stworz_okno_bledu('Powiadomienie', 'Plik dodany do pamięci\n Do bazy załadowany będzie po zatwierdzeniu\n wprowadzonych zmian').open()

                else:
                    print("Nie udało się")
            except: print('Błąd')
        #CMMsFunc.stworz_okno_bledu('BŁĄD', str(self.maszyna[1])).open()
        print(self.maszyna[1])
        self.aktywnasekcja = ''
        self.dismiss_popup()




        #self.dismiss_popup()

    #def save(self, path, filename):
    #    with open(os.path.join(path, filename), 'w') as stream:
     #       stream.write(self.text_input.text)

    #    self.dismiss_popup()



    lista_prod = ListProperty([])
    glo_id = 0
    pin_id = 0
    upn_id = 0
    lin_id = 0
    cln_id = 0
    opr_id = 0
    str_id = 0
    uio_id = 0
    kln_id = 0
    kmt_id = 0

    polaczenie = CMMsFunc.polacz_z_bazadanych()
    kursor = CMMsFunc.stworz_kursor(polaczenie)

    def __init__(self, **kwargs):
        super(PanelWprowadzDane, self).__init__(**kwargs)
        self.lista_producentow()
        
    def lista_producentow(self):

        self.kursor.execute("SELECT Prd_PelnaNazwa FROM Producenci")
        wiersze = self.kursor.fetchall()

        
        for wiersz in wiersze:
            for kolumna in wiersz:
                self.lista_prod.append(kolumna)
                
    def wprowadz_dane_glowica(self,nazwa, producent, uwagi):
        if nazwa == "" or producent == "":
            CMMsFunc.stworz_okno_bledu('BŁĄD', 'GŁOWICA: \nPola Nazwa oraz Producent powinny być uzupełnione').open()
        else:
            l = (nazwa, producent, uwagi)
            self.kursor.callproc('glowice_wprowadz_dane', l)
            self.polaczenie.commit()
            self.kursor.execute('select last_insert_id()')
            self.glo_id = self.kursor.fetchone()[0]
            self.ids.Glo_Nazwa.text = ""
            self.ids.Prd_GloNazwa.text = ""
            # if self.glo_id != 0:
                #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.glo_id)).open()

    def wprowadz_dane_pinola(self,opis,wym_zew,wym_srub,adapter_glow,uwagi):
        if wym_zew != "" and wym_srub != "" and adapter_glow != "":
            l = [opis,wym_zew,wym_srub,adapter_glow,uwagi]
            self.kursor.callproc('pinole_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.pin_id = r.fetchone()
            self.ids.Pin_Opis.text = ""
            self.ids.Pin_WymiarZewnetrzny.text = ""
            self.ids.Pin_WymiarsrubMontazu.text = ""
            self.ids.Pin_AdapterGlowicy.text = ""
            self.ids.Pin_Uwagi.text = ""

        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD', 'PINOLA: \nUzupełnij dane dotyczące Pinoli. Pola obowiązkowe to: \n Wymiar zewnętrzny,\n Wymiar śrub montażu, \nAdapter głowicy.').open()

       # if self.pin_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.pin_id[0])).open()
    def wprowadz_dane_uklad_pneu(self,filtry_model,przeciwwaga_mdl,przeciwwaga_rodzaj,system_antywibracyjny,lozyska_pow_rodzaj,lozyska_pow_model,lozyska_pow_par,producent,uwagi):
        if filtry_model != '' and przeciwwaga_mdl != '' and przeciwwaga_rodzaj != '' and system_antywibracyjny != '' and lozyska_pow_rodzaj != '' and lozyska_pow_model != '' and lozyska_pow_par != '' and producent != '':
            l = [filtry_model,przeciwwaga_mdl,przeciwwaga_rodzaj,system_antywibracyjny,lozyska_pow_rodzaj,lozyska_pow_model,lozyska_pow_par,producent,uwagi]
            self.kursor.callproc('uklad_pneu_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.upn_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD', 'UKŁAD PNEUMATYCZNY:\nUzupełnij dane dotczące tej sekcji.\n Jedynie pole \'UWAGI\' może być puste').open()

       # if self.upn_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.upn_id[0])).open()
            
    def wprowadz_dane_linialy(self, material,rozdzielczosc,rodzaj_sygnalu,rodzaj_sygnalu_szcz,sposob_montazu,producent,uwagi):
        if material != '' and rozdzielczosc != '' and rodzaj_sygnalu != '' and rodzaj_sygnalu_szcz != '' and sposob_montazu != '' and producent != '':
            l =  [material,rozdzielczosc,rodzaj_sygnalu,rodzaj_sygnalu_szcz,sposob_montazu,self.cln_id[0],producent,uwagi]
            self.kursor.callproc('linialy_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.lin_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','LINIAŁY:\nJedynie pole \'uwagi\' może pozostać nieuzupełnione w tej sekcji').open()

        #if self.lin_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.lin_id[0])).open()
            
    def wprowadz_dane_czytnik_linialu(self,rodzaj,sposob_montazu,uwagi):
        if rodzaj != '' and sposob_montazu != '':
            l =  [rodzaj,sposob_montazu,uwagi]
            self.kursor.callproc('czytniki_linialu_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.cln_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','Czytnik Linialu:\nJedynie pole \'uwagi\' może pozostać nieuzupełnione w tej sekcji').open()
        #if self.cln_id != 0:
           #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.cln_id[0])).open()

    def wprowadz_dane_oprogramowanie(self,rodzaj,wersja,uwagi):
        if rodzaj != '' and wersja != '':
            l =  [rodzaj,wersja,uwagi]
            self.kursor.callproc('oprogramowanie_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.opr_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','OPROGRAMOWANIE:\nJedynie pole \'uwagi\' może pozostać nieuzupełnione w tej sekcji').open()


      #  if self.opr_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.opr_id[0])).open()

    def wprowadz_dane_sterowniki(self,producent,model,rodzaj_szatyster,rodzaj_interfejsu,uwagi,rodzaj_panelu):
        if producent != '' and model != '':
            l =[producent,model,rodzaj_szatyster,rodzaj_interfejsu,uwagi,rodzaj_panelu]
            self.kursor.callproc('sterowniki_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.str_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','STEROWNIKI:\nPola: \'Model\' oraz \'Producent\'\nsą polami obowiązkowymi dla tej sekcji').open()


        #if self.str_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.str_id[0])).open()


    def wprowadz_dane_napedy(self,model_silnika,parametry,rodzaj_napedu,uwagi):
        if model_silnika != '' and parametry != '' and rodzaj_napedu != '':
            l =[model_silnika,parametry,rodzaj_napedu,uwagi]
            self.kursor.callproc('napedy_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.nap_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','NAPĘDY:\nJedynie pole \'uwagi\' może pozostać nieuzupełnione w tej sekcji').open()


        #if self.nap_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.nap_id[0])).open()

    def wprowadz_dane_urzadzeniaio(self,hamulec_rodzaj,hamulec_napiecie,krancowki_rodzaj,krancowki_zasilanie,kontrola_cis,inne_urzadzenia,uwagi):
        if hamulec_rodzaj != '' and hamulec_napiecie != '' and krancowki_rodzaj != '' and krancowki_zasilanie !='' and kontrola_cis != '' and uwagi != '':
            l = [hamulec_rodzaj,hamulec_napiecie,krancowki_rodzaj,krancowki_zasilanie,kontrola_cis,inne_urzadzenia,uwagi]
            self.kursor.callproc('urzadzeniaio_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.uio_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD', 'URZĄDZENIA IO:\n Jedynie pole "Inne urządzenia" może być puste. \nUzupełnij pozostałe pola.').open()
        #if self.uio_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.uio_id[0])).open()

    def wprowadz_dane_klienci(self,pelna_nazwa,krotka_nazwa,nip,adres,region,kod_pocztowy,kraj,telefon,fax,mail,uwagi):
        if pelna_nazwa != '' and nip != '':
            l = [pelna_nazwa,krotka_nazwa,nip,adres,region,kod_pocztowy,kraj,telefon,fax,mail,uwagi]
            self.kursor.callproc('klienci_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.kln_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','KLIENCI:\nUzupełnij pełną nazwę klienta oraz NIP').open()

        #if self.kln_id != 0:
            #CMMsFunc.stworz_okno_bledu('SUKCES',str(self.uio_id[0])).open()
    def wprowadz_dane_kompensacja_temp(self,rodzaj_czujnikow,interfejs,uwagi):
        if rodzaj_czujnikow != '' and interfejs != '':
            l = [rodzaj_czujnikow,interfejs,uwagi]
            self.kursor.callproc('kompensacja_temp_wprowadz_dane',l)
            self.polaczenie.commit()
            for r in self.kursor.stored_results():
                self.kmt_id = r.fetchone()
        else:
            CMMsFunc.stworz_okno_bledu('BŁĄD','KOMPENSACJA TEMP:\nJedunie pole \'uwagi\' może być nieuzupełnione w tej sekcji').open()
    

    def wprowadz_dane_maszyna(self,nazwa_producenta,model,zakresx,zakresy,zakresz,tab_znamionowa, opis, informacje):
        l = [nazwa_producenta,model,zakresx,zakresy,zakresz,self.glo_id[0],self.pin_id[0],self.upn_id[0],self.opr_id[0], self.kln_id[0],self.lin_id[0],self.uio_id[0],self.str_id[0],'1',self.knt_id[0], tab_znamionowa,opis,informacje]
        self.kursor.callproc('maszyny_wprowadz_dane',l)
        self.polaczenie.commit()
        CMMsFunc.stworz_okno_bledu('SUKCES','Dane zostały poprawnie wprowadzone').open()

class BoxPlikow(BoxLayout):
    def build(self):
        self.cols = 3
        self.row = 3
        check_panel = GridLayout(orientation='horizontal')
        cb = CheckBox(active=False)
        check_panel.add_widget(cb)
        self.add_widget(check_panel)


class PanelPlikow(Screen):
    def __init__(self, **kwargs):
        super(Screen, self).__init__(**kwargs)
        self.add_widget(BoxPlikow())



Factory.register('Root', cls=PanelWprowadzDane)
Factory.register('LoadDialog', cls=LoadDialog)
Factory.register('SaveDialog', cls=SaveDialog)
####################################################
class PanelRozpocznijPomiar(Screen):
    pass


####################################################
class PanelRaporty(Screen):
    pass


####################################################
class PanelListyElementow(Screen):
    pass




####################################################
class PanelStworzUzytkownika(Screen):
    polaczenie = CMMsFunc.polacz_z_bazadanych()
    kursor = CMMsFunc.stworz_kursor(polaczenie)
    def wyczysc(self):
        self.ids.Uzy_login.text = ""
        self.ids.Uzy_imie.text = ""
        self.ids.Uzy_nazwisko.text = ""
        self.ids.Uzy_haslo.text = ""
        self.ids.Uzy_rola.text = ""

    def stworz_uzytkownika(self,login,imie,nazwisko,haslo,rola):

        #Sprawdzic czy istnieje taki uzytkownik
        
        self.kursor.execute("select czy_login_w_bazie(%s)", (login, ))
        czy_login_istnieje = self.kursor.fetchone()[0]
        if (login != '' and imie != '' and nazwisko != '' and haslo != '' and rola != ''):

            if czy_login_istnieje == 1:
                CMMsFunc.stworz_okno_bledu('BLAD','Login zajety. Wprowadz inny login').open()
            elif (len(haslo) < 12):
                CMMsFunc.stworz_okno_bledu('BLAD','Haslo powinno zawierac wiecej niż 12 znakow').open()
            elif rola != 'Administrator' and rola != 'Serwisant':
                CMMsFunc.stworz_okno_bledu('BLAD','W polu ROLA wprowadz:\nAdministrator lub Serwisant').open()
            else:
                l = [login,imie,nazwisko,haslo,rola]
                if (self.kursor.callproc('uzytkownicy_wprowadz_dane', l)):
                    self.polaczenie.commit()
                    CMMsFunc.stworz_okno_bledu('POWIADOMIENIE','Uzytkownik został utworzony').open()
                    self.wyczysc()
                else:
                    CMMsFunc.stworz_okno_bledu('POWIADOMIENIE', 'Nie udało się wprowadzić użytkownika\n Spróbuj ponownie').open()

        else:
            CMMsFunc.stworz_okno_bledu('BLAD','Wszystkie pola powinny zostać uzupełnione').open()
            return 1


            

        
        
        
        
            




#####################################################
class PanelLogowania(Screen):
    zalogowany_uzytkownik = 0
    def data_logowania(login): 
        polaczenie = CMMsFunc.polacz_z_bazadanych()
        kursor = CMMsFunc.stworz_kursor(polaczenie)
        data = kursor.execute("Select Uzy_DataOstatniegoLogowania from Uzytkownicy where Uzy_Login = %s",login)
    def zaloguj(self,login,haslo):
        self.clear_widgets()

        polaczenie = CMMsFunc.polacz_z_bazadanych()
        kursor = CMMsFunc.stworz_kursor(polaczenie)
        #self.success = Label(text='udane logowanie')
        self.failed = Label(text='nieudane logowanie')
        #sqltest = CMMsFunc.wykonaj_sql(kursor,"select Uzy_haslo from Uzytkownicy where Uzy_Login = 'Admin'")
        kursor.execute("select czy_poprawne_haslo(%s,%s)", (login,haslo))
        czy_poprawne_haslo = kursor.fetchone()[0]
        if czy_poprawne_haslo == 1:
            l = [login]
            kursor.execute('call aktualizuj_date_logowania(%s)', l)
            polaczenie.commit() 
            self.parent.current = "Panel administracyjny"
            kursor.execute("select Uzy_Id from Uzytkownicy where Uzy_Login = %s",l)
            self.zalogowany_uzytkownik = kursor.fetchone()[0]

           
            #ManagerEkranow().run()
        else:
            self.add_widget(self.failed)
class CRUD(Popup):
    """CRUD - Create, Read, Update, Delete"""
    polaczenie = CMMsFunc.polacz_z_bazadanych()
    kursor = CMMsFunc.stworz_kursor(polaczenie)
    label_id_text = ObjectProperty(None)
    label_id_data = ObjectProperty(None)

    mode = StringProperty("")
    label_rec_id = StringProperty("UserID")
    start_point = NumericProperty(0)
    col_data = ListProperty(["", "", "","","",""])

    def __init__(self, obj, **kwargs):
        super(CRUD, self).__init__(**kwargs)
        self.mode = obj.mode
        if obj.mode == "Add":
            self.label_id_text.opacity = 0  # invisible
            self.label_id_data.opacity = 0  # invisible
        else:
            self.label_id_text.opacity = 1  # visible
            self.label_id_data.opacity = 1  # visible
            self.start_point = obj.start_point
            self.col_data[0] = obj.rv_data_popup[obj.start_point]["text"]
            self.col_data[1] = obj.rv_data_popup[obj.start_point + 1]["text"]
            self.col_data[2] = obj.rv_data_popup[obj.start_point + 2]["text"]
            self.col_data[3] = obj.rv_data_popup[obj.start_point + 3]["text"]
            self.col_data[4] = obj.rv_data_popup[obj.start_point + 4]["text"]
            self.col_data[5] = obj.rv_data_popup[obj.start_point + 5]["text"]

    def package_changes(self, login, imie,nazwisko,haslo,rola):
        self.col_data[1] = login
        self.col_data[2] = imie
        self.col_data[3] = nazwisko
        self.col_data[4] = haslo
        self.col_data[5] = rola
    def update_changes(self, obj):
       # if obj.mode == "Add":
            # insert record into Database Table
            #cur.execute("INSERT INTO Uzytkownicy(Uzy_Login,Uzy_Imie,Uzy_Nazwisko,Uzy_Haslo,Uzy_Rola) VALUES(?, ?, ?,?,?,?)",
            #            (obj.col_data[1], obj.col_data[2], obj.col_data[3],obj.col_data[4],obj.col_data[5]))
        #else:
            # update Database Table
        id = [obj.col_data[0]]
        self.kursor.execute("Select Uzy_haslo from Uzytkownicy where Uzy_Id = %s",id)
        haslo = self.kursor.fetchone()[0]
        if obj.col_data[4] == haslo:
            self.kursor.execute("UPDATE Uzytkownicy SET Uzy_Login = %s, Uzy_Imie = %s, Uzy_Nazwisko =%s, Uzy_Rola = %s  WHERE Uzy_Id =%s",
                (obj.col_data[1], obj.col_data[2], obj.col_data[3], obj.col_data[5], obj.col_data[0]))
            self.polaczenie.commit()
        else:

            self.kursor.execute("UPDATE Uzytkownicy SET Uzy_Login = %s, Uzy_Imie = %s, Uzy_Nazwisko =%s, Uzy_Haslo = md5(%s), Uzy_Rola = %s  WHERE Uzy_Id =%s",
                    (obj.col_data[1], obj.col_data[2],obj.col_data[3],obj.col_data[4],obj.col_data[5], obj.col_data[0]))
            self.polaczenie.commit()

class SelectableRecycleGridLayout(FocusBehavior, LayoutSelectionBehavior,
                                  RecycleGridLayout):
    ''' Adds selection and focus behaviour to the view. '''


class SelectableButton(RecycleDataViewBehavior, Button):
    ''' Add selection support to the Button '''
    index = None
    selected = BooleanProperty(False)
    selectable = BooleanProperty(True)
    rv_data = ObjectProperty(None)
    rv_data_popup = ObjectProperty(None)
    start_point = NumericProperty(0)
    mode = StringProperty("")

    def refresh_view_attrs(self, rv, index, data):
        ''' Catch and handle the view changes '''
        self.index = index
        return super(SelectableButton, self).refresh_view_attrs(rv, index, data)

    def on_touch_down(self, touch):
        ''' Add selection on touch down '''
        if super(SelectableButton, self).on_touch_down(touch):
            return True
        if self.collide_point(*touch.pos) and self.selectable:
            return self.parent.select_with_touch(self.index, touch)

    def apply_selection(self, rv, index, is_selected):
        ''' Respond to the selection of items in the view. '''
        self.selected = is_selected
        self.rv_data = rv.data
        self.rv_data_popup = rv.data_popup

    def on_press(self):
        #self.mode = "Update"
        self.start_point = 0
        end_point = MAX_TABLE_COLS
        rows = len(self.rv_data_popup) // MAX_TABLE_COLS
        for row in range(rows):
            if self.index in list(range(end_point)):
                break
            self.start_point += MAX_TABLE_COLS
            end_point += MAX_TABLE_COLS

        popup = CRUD(self)
        popup.open()


class RV(BoxLayout):

    rv_data = ListProperty([])
    rv_data_popup = ListProperty([])
    start_point = NumericProperty(0)
    mode = StringProperty("")

    def __init__(self, **kwargs):
        super(RV, self).__init__(**kwargs)
        self.get_users()

    def get_users(self):
        polaczenie = CMMsFunc.polacz_z_bazadanych()
        kursor = CMMsFunc.stworz_kursor(polaczenie)
        '''This result retrieve from database'''
        self.rv_data.clear()
        self.rv_data_popup.clear()
        self.rv_data = []
        self.rv_data_popup = []


        kursor.execute("SELECT Uzy_Id, Uzy_Login, Uzy_Imie, Uzy_Nazwisko, Uzy_Haslo, Uzy_ROla FROM Uzytkownicy ORDER BY Uzy_id ASC")
        rows = kursor.fetchall()

        # create data_items
        for row in rows:
            for col in row:
               #if len(str(col)) > 10:
                    #self.rv_data.append(col[:10] + '...')
               #else:
                self.rv_data.append(col)

        kursor.execute("SELECT Uzy_Id, Uzy_Login, Uzy_Imie, Uzy_Nazwisko, Uzy_Haslo, Uzy_ROla FROM Uzytkownicy ORDER BY Uzy_id ASC")
        rows_popup = kursor.fetchall()
        for row in rows_popup:
            for col in row:
                if len(str(col)) > 10:
                    self.rv_data_popup.append(col[:10] + '...')
                else:
                    self.rv_data_popup.append(col)

        for row in rows:
            for col in row:
                print(col)

    def add_record(self):
        self.mode = "Add"
        popup = CRUD(self)
        popup.open()

    def update_changes(self, obj):
       # if obj.mode == "Add":
            # insert record into Database Table
            #cur.execute("INSERT INTO Uzytkownicy(Uzy_Login,Uzy_Imie,Uzy_Nazwisko,Uzy_Haslo,Uzy_Rola) VALUES(?, ?, ?,?,?,?)",
            #            (obj.col_data[1], obj.col_data[2], obj.col_data[3],obj.col_data[4],obj.col_data[5]))
        #else:
            # update Database Table
        self.kursor.execute("UPDATE Uzytkownicy SET Uzy_Login = ?, Uzy_Imie = ?, Uzy_Nazwisko = ?, Uzy_Haslo = ?, Uzy_Rola = ?  WHERE Uzy_Id = ?",
                    (obj.col_data[1], obj.col_data[2],obj.col_data[3],obj.col_data[4],obj.col_data[5], obj.col_data[0]))
        con.commit()
        self.get_users()


#####################################################
class PanelEdytujUsunUzytkownikow(Screen):
    def __init__(self, **kwargs):
        super(Screen, self).__init__(**kwargs)
        c=RV()
        c.get_users()
        self.add_widget(c)


#####################################################

        
    

#####################################################
class MyApp(App):
    title = 'CMMs database'
    def build(self):
       return ManagerEkranow()


#polaczenie = mysql.connector.connect(host="db4free.net",user="cmms_user",passwd="cmmsuser123",database="cmms_database")
#kursor = polaczenie.cursor(buffered=True)
if __name__=="__main__":
    MyApp().run()

