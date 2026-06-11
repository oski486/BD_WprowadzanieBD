-- schema_postgres.sql

CREATE TABLE Klienci (
    ID_Klienta SERIAL PRIMARY KEY,
    Imie VARCHAR(50) NOT NULL,
    Nazwisko VARCHAR(100) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Telefon VARCHAR(15),
    Miasto VARCHAR(100),
    Ulica VARCHAR(150),
    Kod_Pocztowy VARCHAR(10)
);

CREATE TABLE Producenci (
    ID_Producenta SERIAL PRIMARY KEY,
    Nazwa_producenta VARCHAR(100) NOT NULL
);

CREATE TABLE Kategorie (
    ID_Kategorii SERIAL PRIMARY KEY,
    Nazwa_kategorii VARCHAR(50) NOT NULL
);

CREATE TABLE Produkty (
    ID_Produktu SERIAL PRIMARY KEY,
    ID_Kategorii INTEGER NOT NULL REFERENCES Kategorie(ID_Kategorii),
    ID_Producenta INTEGER NOT NULL REFERENCES Producenci(ID_Producenta),
    Nazwa VARCHAR(200) NOT NULL,
    Opis TEXT,
    Cena_aktualna NUMERIC(10,2) NOT NULL CHECK (Cena_aktualna > 0),
    Stan_magazynowy INTEGER NOT NULL DEFAULT 0,
    Gwarancja_miesiace SMALLINT CHECK (Gwarancja_miesiace >= 0)
);

CREATE TABLE Zamowienia (
    ID_Zamowienia SERIAL PRIMARY KEY,
    ID_Klienta INTEGER NOT NULL REFERENCES Klienci(ID_Klienta),
    Data_zamowienia TIMESTAMP NOT NULL,
    Status_zamowienia VARCHAR(50) NOT NULL,
    Sposob_dostawy VARCHAR(50)
);

CREATE TABLE Platnosci (
    ID_Platnosci SERIAL PRIMARY KEY,
    ID_Zamowienia INTEGER NOT NULL REFERENCES Zamowienia(ID_Zamowienia),
    Metoda_platnosci VARCHAR(50),
    Status_platnosci VARCHAR(50)
);

CREATE TABLE Pozycje_Zamowienia (
    ID_Pozycji SERIAL PRIMARY KEY,
    ID_Zamowienia INTEGER NOT NULL REFERENCES Zamowienia(ID_Zamowienia),
    ID_Produktu INTEGER NOT NULL REFERENCES Produkty(ID_Produktu),
    Ilosc INTEGER NOT NULL,
    Cena_historyczna NUMERIC(10,2) NOT NULL
);

CREATE TABLE Opinie (
    ID_Opinii SERIAL PRIMARY KEY,
    ID_Pozycji INTEGER NOT NULL REFERENCES Pozycje_Zamowienia(ID_Pozycji) ON DELETE CASCADE,
    Ocena SMALLINT NOT NULL CHECK (Ocena BETWEEN 1 AND 5),
    Komentarz TEXT
);
