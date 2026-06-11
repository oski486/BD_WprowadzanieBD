import sqlite3
import psycopg2
from psycopg2 import extras
from faker import Faker
import random
from datetime import datetime

# --- KONFIGURACJA BAZY DANYCH ---
SQLITE_DB = 'sklep_elektronika.db'

# TODO: Zmień poniższe dane na namiary Waszego serwera z laboratorium/chmury
PG_HOST = 'localhost'
PG_PORT = '5432'
PG_DB = 'sklep_db'
PG_USER = 'postgres'
PG_PASSWORD = 'twoje_haslo'

# Inicjalizacja generatora danych (ustawiamy język polski)
fake = Faker('pl_PL')

def generate_data():
    """Generuje losowe paczki danych w formie list krotek."""
    print("Generowanie danych testowych...")
    
    # 1. Klienci (100 rekordów)
    klienci = []
    for _ in range(100):
        klienci.append((
            fake.first_name(), fake.last_name(), fake.unique.email(),
            fake.phone_number(), fake.city(), fake.street_name(), fake.postcode()
        ))

    # 2. Kategorie (Sztywna lista)
    kategorie_nazwy = ["Laptopy", "Smartfony", "Monitory", "Podzespoły PC", "Peryferia"]
    kategorie = [(nazwa,) for nazwa in kategorie_nazwy]

    # 3. Producenci (Sztywna lista)
    producenci_nazwy = ["Dell", "Apple", "Samsung", "Lenovo", "Logitech", "ASUS"]
    producenci = [(nazwa,) for nazwa in producenci_nazwy]

    # 4. Produkty (50 rekordów)
    produkty = []
    for _ in range(50):
        produkty.append((
            random.randint(1, len(kategorie)),  # ID_Kategorii
            random.randint(1, len(producenci)), # ID_Producenta
            f"Model {fake.word().capitalize()} {random.randint(100, 999)}", # Nazwa
            fake.sentence(), # Opis
            round(random.uniform(50.0, 8000.0), 2), # Cena_aktualna
            random.randint(0, 100), # Stan magazynowy
            random.choice([12, 24, 36]) # Gwarancja w miesiącach
        ))

    return klienci, kategorie, producenci, produkty

def insert_sqlite(klienci, kategorie, producenci, produkty):
    """Import wsadowy do SQLite za pomocą executemany()"""
    print("Rozpoczęto import do SQLite...")
    try:
        # Podłączenie do pliku bazy SQLite
        conn = sqlite3.connect(SQLITE_DB)
        cur = conn.cursor()

        # Wykonanie schematu tabel (jeśli jeszcze nie istnieją)
        with open('schema_sqlite.sql', 'r', encoding='utf-8') as f:
            cur.executescript(f.read())

        # Wsadowe wstawianie danych (executemany)
        cur.executemany("INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, Miasto, Ulica, Kod_Pocztowy) VALUES (?, ?, ?, ?, ?, ?, ?)", klienci)
        cur.executemany("INSERT INTO Kategorie (Nazwa_kategorii) VALUES (?)", kategorie)
        cur.executemany("INSERT INTO Producenci (Nazwa_producenta) VALUES (?)", producenci)
        cur.executemany("INSERT INTO Produkty (ID_Kategorii, ID_Producenta, Nazwa, Opis, Cena_aktualna, Stan_magazynowy, Gwarancja_miesiace) VALUES (?, ?, ?, ?, ?, ?, ?)", produkty)

        # Zatwierdzenie całej transakcji
        conn.commit()
        print("Import do SQLite zakończony sukcesem!")
    
    except sqlite3.Error as e:
        print(f"Błąd SQLite: {e}")
    finally:
        if conn:
            conn.close()

def insert_postgres(klienci, kategorie, producenci, produkty):
    """Import wsadowy do PostgreSQL za pomocą psycopg2.extras.execute_values()"""
    print("Rozpoczęto import do PostgreSQL...")
    try:
        conn = psycopg2.connect(host=PG_HOST, port=PG_PORT, dbname=PG_DB, user=PG_USER, password=PG_PASSWORD)
        cur = conn.cursor()

        # Opcjonalne: Wykonanie schematu tabel
        with open('schema_postgres.sql', 'r', encoding='utf-8') as f:
            cur.execute(f.read())

        # Wsadowe wstawianie danych (execute_values to niezwykle wydajny mechanizm)
        extras.execute_values(cur, "INSERT INTO Klienci (Imie, Nazwisko, Email, Telefon, Miasto, Ulica, Kod_Pocztowy) VALUES %s", klienci)
        extras.execute_values(cur, "INSERT INTO Kategorie (Nazwa_kategorii) VALUES %s", kategorie)
        extras.execute_values(cur, "INSERT INTO Producenci (Nazwa_producenta) VALUES %s", producenci)
        extras.execute_values(cur, "INSERT INTO Produkty (ID_Kategorii, ID_Producenta, Nazwa, Opis, Cena_aktualna, Stan_magazynowy, Gwarancja_miesiace) VALUES %s", produkty)

        conn.commit()
        print("Import do PostgreSQL zakończony sukcesem!")

    except psycopg2.Error as e:
        print(f"Błąd PostgreSQL: {e}")
    finally:
        if conn:
            cur.close()
            conn.close()

if __name__ == "__main__":
    # 1. Generujemy paczki danych do pamięci
    data_klienci, data_kategorie, data_producenci, data_produkty = generate_data()
    
    # 2. Odpalamy zasilanie SQLite
    insert_sqlite(data_klienci, data_kategorie, data_producenci, data_produkty)
    
    # 3. Odpalamy zasilanie PostgreSQL
    # ZAKOMENTUJ PONIŻSZĄ LINIJKĘ JEŚLI NIE MASZ JESZCZE SKONFIGUROWANEGO POŁĄCZENIA PG
    # insert_postgres(data_klienci, data_kategorie, data_producenci, data_produkty)
