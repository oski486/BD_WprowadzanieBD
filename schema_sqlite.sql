-- schema_sqlite.sql

CREATE TABLE Klienci (
    ID_Klienta INTEGER PRIMARY KEY AUTOINCREMENT,
    Imie TEXT NOT NULL,
    Nazwisko TEXT NOT NULL,
    Email TEXT UNIQUE NOT NULL,
    Telefon TEXT,
    Miasto TEXT,
    Ulica TEXT,
    Kod_Pocztowy TEXT
);

CREATE TABLE Producenci (
    ID_Producenta INTEGER PRIMARY KEY AUTOINCREMENT,
    Nazwa_producenta TEXT NOT NULL
);

CREATE TABLE Kategorie (
    ID_Kategorii INTEGER PRIMARY KEY AUTOINCREMENT,
    Nazwa_kategorii TEXT NOT NULL
);

CREATE TABLE Produkty (
    ID_Produktu INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Kategorii INTEGER NOT NULL,
    ID_Producenta INTEGER NOT NULL,
    Nazwa TEXT NOT NULL,
    Opis TEXT,
    Cena_aktualna REAL NOT NULL CHECK (Cena_aktualna > 0),
    Stan_magazynowy INTEGER NOT NULL DEFAULT 0,
    Gwarancja_miesiace INTEGER,
    FOREIGN KEY(ID_Kategorii) REFERENCES Kategorie(ID_Kategorii),
    FOREIGN KEY(ID_Producenta) REFERENCES Producenci(ID_Producenta)
);

CREATE TABLE Zamowienia (
    ID_Zamowienia INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Klienta INTEGER NOT NULL,
    Data_zamowienia TEXT NOT NULL,
    Status_zamowienia TEXT NOT NULL,
    Sposob_dostawy TEXT,
    FOREIGN KEY(ID_Klienta) REFERENCES Klienci(ID_Klienta)
);

CREATE TABLE Platnosci (
    ID_Platnosci INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Zamowienia INTEGER NOT NULL,
    Metoda_platnosci TEXT,
    Status_platnosci TEXT,
    FOREIGN KEY(ID_Zamowienia) REFERENCES Zamowienia(ID_Zamowienia)
);

CREATE TABLE Pozycje_Zamowienia (
    ID_Pozycji INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Zamowienia INTEGER NOT NULL,
    ID_Produktu INTEGER NOT NULL,
    Ilosc INTEGER NOT NULL,
    Cena_historyczna REAL NOT NULL,
    FOREIGN KEY(ID_Zamowienia) REFERENCES Zamowienia(ID_Zamowienia),
    FOREIGN KEY(ID_Produktu) REFERENCES Produkty(ID_Produktu)
);

CREATE TABLE Opinie (
    ID_Opinii INTEGER PRIMARY KEY AUTOINCREMENT,
    ID_Pozycji INTEGER NOT NULL,
    Ocena INTEGER NOT NULL CHECK (Ocena >= 1 AND Ocena <= 5),
    Komentarz TEXT,
    FOREIGN KEY(ID_Pozycji) REFERENCES Pozycje_Zamowienia(ID_Pozycji) ON DELETE CASCADE
);
