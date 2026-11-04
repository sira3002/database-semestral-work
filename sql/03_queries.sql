-- =============================================================================
-- LOGISTICS & FREIGHT TRANSPORT MANAGEMENT DATABASE (SPEDICE NEDOJEL)
-- Advanced SQL Query Suite & Relational Algebra Proofs
-- =============================================================================
-- Author:      Matěj Široký
-- Course:      BI-DBS (Database Systems), Faculty of Information Technology, CTU in Prague
-- Engine:      PostgreSQL 14+ / 16+
--
-- This file contains 26 comprehensive analytical queries demonstrating:
--  - Universal Quantification / Relational Division (double NOT EXISTS)
--  - Set Operations (UNION, INTERSECT, EXCEPT)
--  - Multi-table Joins (INNER, LEFT OUTER, FULL OUTER, CROSS JOIN)
--  - Correlated and Nested Subqueries (WHERE, FROM, SELECT)
--  - Advanced Aggregations (GROUP BY, HAVING, subquery benchmarks)
--  - DDL Views & Queries over Views
--  - Data Modification & ACID Transactions (INSERT/UPDATE/DELETE + ROLLBACK)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- [D1] Most frequently utilized tractor truck
-- CZ: Nejčastěji používaný tahač
-- EN: Identifies the tractor truck assigned to the highest number of shipments.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F1: F1 - JOIN ON
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
-- -----------------------------------------------------------------------------
SELECT t.id_tahac, COUNT(*) AS pocet_zasilek
FROM tahac t
JOIN zasilka z ON t.id_tahac = z.id_tahac
GROUP BY t.id_tahac
ORDER BY pocet_zasilek DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- [D2] Name of the youngest driver
-- CZ: Jméno nejmladšího řidiče.
-- EN: Retrieves the driver with the most recent birth date.
-- -----------------------------------------------------------------------------
SELECT jmeno
FROM ridic
ORDER BY datum_narozeni DESC
LIMIT 1;

-- -----------------------------------------------------------------------------
-- [D3] Distinct tractor truck brands
-- CZ: Seznam všech značek tahačů, které firma vlastní
-- EN: Lists all unique manufacturer brands represented in the company fleet.
-- Relational Algebra:
--   tahac[znacka]
-- -----------------------------------------------------------------------------
SELECT DISTINCT znacka FROM tahac

-- -----------------------------------------------------------------------------
-- [D4] Relational Division / Universal Quantification
-- CZ: Vyber tahače, na kterých byly provedeny všechny servisní úkony
-- EN: Selects tractor trucks that have undergone every defined service maintenance procedure (double NOT EXISTS).
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * AR: A (RA) - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * D1: D1 - Vyber ty, kteří/které jsou ve vztahu se všemi - dotaz s univerzální kvantifikací
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F2R: F2 (RA) - NATURAL JOIN|JOIN USING
--   * G1: G1 - Vnořený dotaz v klauzuli WHERE
--   * G1R: G1 (RA) - Vnořený dotaz v klauzuli WHERE
--   * G4: G4 - Vztažený vnořený dotaz (EXISTS, NOT EXISTS)
-- Relational Algebra:
--   {{servisni_ukon_servisni_historie * servisni_historie}[id_tahac,id_ukon]÷servisni_ukon[id_ukon]} * tahac
-- -----------------------------------------------------------------------------
SELECT * FROM tahac t
WHERE NOT EXISTS(
    SELECT * FROM SERVISNI_UKON su
    WHERE NOT EXISTS (
        SELECT 1 FROM SERVISNI_UKON_SERVISNI_HISTORIE shu
        JOIN SERVISNI_HISTORIE sh USING(id_servis)
        WHERE sh.id_tahac = t.id_tahac AND su.id_ukon = shu.id_ukon
    )
)

-- -----------------------------------------------------------------------------
-- [D5] Exclusive relationship (Set difference)
-- CZ: Vyber návěsy, které mohou přepravovat pouze náklad 15 (kapaliny)
-- EN: Finds semi-trailers certified exclusively for liquid cargo (type 15) and no other cargo category.
-- Categories: 
--   * C: C - Vyber ty, kteří mají vztah POUZE k ...
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F2R: F2 (RA) - NATURAL JOIN|JOIN USING
--   * H2: H2 - Množinový rozdíl - MINUS nebo EXCEPT
--   * H2R: H2 (RA) - Množinový rozdíl - MINUS nebo EXCEPT
-- Relational Algebra:
--   {naves<naves.id_naves = typ_nakladu_naves.id_naves]typ_nakladu_naves(id_ntyp = 15)}
--   \
--   {naves<naves.id_naves = typ_nakladu_naves.id_naves]typ_nakladu_naves(id_ntyp != 15)}
-- -----------------------------------------------------------------------------
SELECT n.*
FROM NAVES n
JOIN TYP_NAKLADU_NAVES tnn USING(id_naves) 
WHERE tnn.id_ntyp=15
EXCEPT
SELECT n.*
FROM NAVES n
JOIN TYP_NAKLADU_NAVES tnn USING(id_naves) 
WHERE tnn.id_ntyp!=15

-- -----------------------------------------------------------------------------
-- [D6] Driver rest duration in date window
-- CZ: Celková doba odpočinku řidiče 5 od 2.12.2024 do 9.12.2024
-- EN: Calculates total resting time taken by driver 5 during the first week of December 2024.
-- -----------------------------------------------------------------------------
SELECT id_ridic, SUM(konec - zacatek) AS celkova_doba_odpocinku
FROM pauza
WHERE id_ridic = 5
  AND zacatek >= '2024-12-02 00:00:00'
  AND konec <= '2024-12-09 23:59:59'
GROUP BY id_ridic;

-- -----------------------------------------------------------------------------
-- [D7] Order count for a specific customer
-- CZ: Počet zakázek od zákazníka s id 1
-- EN: Aggregates total transport orders placed by customer ID 1.
-- Categories: 
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
-- -----------------------------------------------------------------------------
SELECT id_zakaznik, COUNT(*) AS pocet_zakazek FROM zakazka WHERE id_zakaznik = 1 GROUP BY id_zakaznik

-- -----------------------------------------------------------------------------
-- [D8] Order counts per customer (Correlated subquery in SELECT)
-- CZ: Vypiš ke každému zákazníkovi počet zakázek které zadal. Zákazníky seřaď podle počtu zakázek od největšího.
-- EN: Displays every customer along with their total order count, sorted in descending order.
-- Categories: 
--   * G3: G3 - Vnořený dotaz v klauzuli SELECT
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
-- -----------------------------------------------------------------------------
SELECT *, (SELECT COUNT(*) FROM zakazka zak WHERE  z.id_zakaznik= zak.id_zakaznik) AS pocet_zakazek
FROM zakaznik z
ORDER BY pocet_zakazek DESC;

-- -----------------------------------------------------------------------------
-- [D10] Tractor trucks with zero service history
-- CZ: Id, značka a model tahače, který ještě nebyl v servisu.
-- EN: Finds tractors that have never been scheduled for or undergone any workshop maintenance.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * AR: A (RA) - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F2R: F2 (RA) - NATURAL JOIN|JOIN USING
--   * F4: F4 - LEFT|RIGHT OUTER JOIN
--   * F4R: F4 (RA) - LEFT|RIGHT OUTER JOIN
-- Relational Algebra:
--   {tahac * {tahac[id_tahac] \ servisni_historie[id_tahac]}}[id_tahac,znacka,model]
-- -----------------------------------------------------------------------------
SELECT t.id_tahac, t.znacka, t.model
FROM TAHAC t
LEFT JOIN SERVISNI_HISTORIE sh USING(id_tahac)
WHERE sh.id_tahac IS NULL;

-- -----------------------------------------------------------------------------
-- [D11] Orders initiated in year 2025
-- CZ: Zakázky, které mají datum zahájení v letošním roce(2025).
-- EN: Filters orders submitted within the 2025 calendar year.
-- Relational Algebra:
--   Zakazka(zadano_dne > '31.12.2024' ∧ zadano_dne < '01.01.2026')
-- -----------------------------------------------------------------------------
SELECT *
FROM ZAKAZKA
WHERE zadano_dne > TO_DATE('31.12.2024','dd.mm.yyyy') AND zadano_dne < TO_DATE('01.01.2026','dd.mm.yyyy');

-- -----------------------------------------------------------------------------
-- [D12] Trailers certified for dangerous goods (ADR)
-- CZ: Všechny návěsy, které jsou určeny pro převoz nebezpečného zboží.
typ_nakladu.nazev='Nebezpečný náklad (ADR)'
-- EN: Multi-table join returning trailers authorized to haul hazardous freight.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * AR: A (RA) - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F2R: F2 (RA) - NATURAL JOIN|JOIN USING
-- Relational Algebra:
--   {naves [naves.id_naves=typ_nakladu_naves.id_naves] 
--       {typ_nakladu_naves [typ_nakladu_naves.id_ntyp = typ_nakladu.id_ntyp] 
--           typ_nakladu (nazev='Nebezpečný náklad (ADR)')
--       }
--   }[naves.id_naves, naves.vyrobce, typ_nakladu.nazev]
-- -----------------------------------------------------------------------------
SELECT n.id_naves, n.vyrobce, tn.nazev FROM NAVES n 
JOIN TYP_NAKLADU_NAVES tnn USING(id_naves) 
JOIN TYP_NAKLADU tn USING(id_ntyp) 
WHERE tn.nazev='Nebezpečný náklad (ADR)'

-- -----------------------------------------------------------------------------
-- [D13] Service operations not yet performed on tractor 14
-- CZ: Servisní úkony, které nebyly provedeny na tahači 14(id_tahac=14)
-- EN: Set difference identifying workshop tasks that have never been executed on a specific tractor.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * AR: A (RA) - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * D2: D2 - Kontrola výsledku dotazu z kategorie D1
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F2R: F2 (RA) - NATURAL JOIN|JOIN USING
--   * G1: G1 - Vnořený dotaz v klauzuli WHERE
--   * G1R: G1 (RA) - Vnořený dotaz v klauzuli WHERE
--   * G4: G4 - Vztažený vnořený dotaz (EXISTS, NOT EXISTS)
--   * H2: H2 - Množinový rozdíl - MINUS nebo EXCEPT
--   * H2R: H2 (RA) - Množinový rozdíl - MINUS nebo EXCEPT
-- Relational Algebra:
--   {servisni_ukon}
--   \
--   {{servisni_historie(id_tahac = 14) [servisni_historie.id_servis = servisni_ukon_servisni_historie.id_servis]servisni_ukon_servisni_historie} 
--   [servisni_ukon_servisni_historie.id_ukon = servisni_ukon.id_ukon> 
--   servisni_ukon
--   }
-- -----------------------------------------------------------------------------
SELECT * FROM SERVISNI_UKON su
EXCEPT
SELECT DISTINCT sup.* FROM SERVISNI_HISTORIE sh
JOIN SERVISNI_UKON_SERVISNI_HISTORIE suh USING(id_servis)
JOIN SERVISNI_UKON sup USING(id_ukon) 
WHERE sh.id_tahac=(
                    SELECT t.id_tahac FROM tahac t
                    WHERE NOT EXISTS(
                        SELECT * FROM SERVISNI_UKON su
                        WHERE NOT EXISTS (
                            SELECT 1 FROM SERVISNI_UKON_SERVISNI_HISTORIE shu
                            JOIN SERVISNI_HISTORIE sh USING(id_servis)
                            WHERE sh.id_tahac = t.id_tahac AND su.id_ukon = shu.id_ukon
                        )
                    )
);

-- -----------------------------------------------------------------------------
-- [D14] Unassigned tractor trucks
-- CZ: Vypiš tahač, který nikdy nebyl přiřazen k žádné zásilce
-- EN: Negative subquery (NOT IN) identifying tractors that have never been dispatched on any shipment.
-- Categories: 
--   * B: B - Negativní dotaz nad spojením alespoň dvou tabulek
--   * G1: G1 - Vnořený dotaz v klauzuli WHERE
--   * G1R: G1 (RA) - Vnořený dotaz v klauzuli WHERE
-- Relational Algebra:
--   zasilka !*> tahac
-- -----------------------------------------------------------------------------
SELECT * FROM TAHAC WHERE id_tahac NOT IN (
    SELECT id_tahac FROM ZASILKA
)

-- -----------------------------------------------------------------------------
-- [D15] Routes originating at driver's home address
-- CZ: Najdi id_trasa a jméno řidiče, která začíná u něj doma
-- EN: Finds all route dispatch origins that coincide with the assigned driver's residence.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * AR: A (RA) - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F1: F1 - JOIN ON
--   * F1R: F1 (RA) - JOIN ON
-- Relational Algebra:
--   {trasa [trasa.adresa_start = ridic.id_adresa] ridic}
--   [id_trasa, jmeno]
-- -----------------------------------------------------------------------------
SELECT t.id_trasa, r.jmeno FROM TRASA t JOIN RIDIC r ON r.id_adresa = t.adresa_start

-- -----------------------------------------------------------------------------
-- [D16] Cartesian product of fleet combinations
-- CZ: Vypiš jaké všechny soupravy lze vytvořit (kombinace tahače a návěsu)
-- EN: CROSS JOIN generating all theoretical permutations of tractor trucks and semi-trailers.
-- Categories: 
--   * F3: F3 - CROSS JOIN
-- Relational Algebra:
--   tahac
--   ×
--   naves
-- -----------------------------------------------------------------------------
SELECT *
FROM TAHAC
CROSS JOIN NAVES;

-- -----------------------------------------------------------------------------
-- [D17] FULL OUTER JOIN with aggregated maintenance tasks
-- CZ: Zobraz všechny tahače a servisní záznamy spolu s počtem servisních úkonů v jednotlivých servisních záznamech.
Pokud tahač nikdy v servisu nebyl, zobraz pouze tahač a pokud servis byl proveden na jiném vozidle než na tahači, tak zobraz pouze údaje o servisu.
Následně seřaď vzestupně podle poču provedených úkonů.
-- EN: Combines all tractors and service records including unmatched rows, with task counts per service event.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F5: F5 - FULL (OUTER) JOIN
--   * G2: G2 - Vnořený dotaz v klauzuli FROM
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
-- -----------------------------------------------------------------------------
SELECT x.id_servis, x.pocet_ukonu, t.id_tahac, t.znacka
FROM 
(SELECT s.id_servis, s.id_tahac, COUNT(*) AS pocet_ukonu 
 FROM servisni_historie s JOIN servisni_ukon_servisni_historie su USING(id_servis) 
 GROUP BY id_servis
) x
FULL OUTER JOIN tahac t ON x.id_tahac = t.id_tahac
ORDER BY x.pocet_ukonu ASC;

-- -----------------------------------------------------------------------------
-- [D18] Multi-condition analytical query with HAVING & Subquery
-- CZ: Vyber zákazníky, kteří odeslali alespoň 3 zásilky a jejich průměrná hmotnost zásilek je vyšší než průměrná hmotnost zásilek všech zákazníků dohromady a zároveň zákazník je právnická osoba a sídlí v česku(stat='Česká republika'). Výsledky seřaď sestupně podle průměrné hmotnosti.
-- EN: Filters corporate Czech clients having >= 3 shipments whose average cargo weight exceeds fleet-wide benchmark.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
--   * K: K - Všechny klauzule v 1 dotazu - SELECT FROM WHERE GROUP BY HAVING ORDER BY
-- -----------------------------------------------------------------------------
SELECT zak.id_zakaznik, COUNT(*) AS pocet_zasilek, AVG(z.hmotnost) AS prumerna_hmotnost
FROM zasilka z JOIN zakazka zak USING(id_zakazka) JOIN pravnicka_osoba po USING (id_zakaznik) JOIN adresa a USING (id_adresa) where a.stat='Česká republika'
GROUP BY zak.id_zakaznik
HAVING COUNT(*) >= 3
   AND AVG(z.hmotnost) > (
       SELECT AVG(z2.hmotnost)
       FROM zasilka z2
   )
ORDER BY AVG(z.hmotnost) DESC;

-- -----------------------------------------------------------------------------
-- [D19] Concept equivalence: Three SQL formulations
-- CZ: Ke každému řidiči vypiš počet odvezených zásilek.
-- EN: Computes shipment count per driver using: 1) Scalar subquery in SELECT, 2) Set UNION & EXCEPT, 3) LEFT JOIN with COALESCE.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * F4: F4 - LEFT|RIGHT OUTER JOIN
--   * G2: G2 - Vnořený dotaz v klauzuli FROM
--   * G3: G3 - Vnořený dotaz v klauzuli SELECT
--   * H1: H1 - Množinové sjednocení - UNION
--   * H2: H2 - Množinový rozdíl - MINUS nebo EXCEPT
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
--   * J: J - Stejný dotaz ve třech různých formulacích SQL
-- -----------------------------------------------------------------------------
SELECT *, (SELECT COUNT(*) FROM zasilka z WHERE r.id_ridic = z.id_ridic) AS pocet_zasilek
FROM ridic r;

SELECT r.*, COUNT(*) AS pocet_zasilek 
FROM ridic r JOIN zasilka USING (id_ridic) 
GROUP BY id_ridic
UNION
SELECT *, 0 AS pocet_zasilek 
FROM (
    SELECT r.* 
    FROM ridic r 
    EXCEPT (
        SELECT DISTINCT ri.* 
        FROM ridic ri 
        JOIN zasilka USING (id_ridic)
        ) 
    );

SELECT r.*, COALESCE(p.pocet_zasilek, 0) AS pocet_zasilek
FROM ridic r
LEFT JOIN (
    SELECT id_ridic, COUNT(*) AS pocet_zasilek
    FROM zasilka
    GROUP BY id_ridic
) p ON r.id_ridic = p.id_ridic;

-- -----------------------------------------------------------------------------
-- [D20] Set intersection: ADR & Electronics drivers
-- CZ: Řidiči, kteří vezli nebezpečný náklad i elektroniku
-- EN: INTERSECT query finding drivers experienced with both hazardous materials and sensitive electronics.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * H3: H3 - Množinový průnik - INTERSECT
-- -----------------------------------------------------------------------------
SELECT r.* 
FROM ridic r 
JOIN zasilka USING (id_ridic) 
JOIN naklad USING(id_zakazka) 
JOIN typ_nakladu tn USING (id_ntyp) 
WHERE tn.nazev = 'Elektronika'

INTERSECT

SELECT r.* 
FROM ridic r 
JOIN zasilka USING (id_ridic) 
JOIN naklad USING(id_zakazka) 
JOIN typ_nakladu tn USING (id_ntyp) 
WHERE tn.nazev = 'Nebezpečný náklad (ADR)'

-- -----------------------------------------------------------------------------
-- [D21] Database View creation
-- CZ: View zásilek s nebezpečným nákladem.
-- EN: Defines reusable database view `nebezpecne_zakazky` isolating hazardous goods shipments.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * L: L - VIEW
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW nebezpecne_zakazky AS
SELECT z.* FROM zasilka z JOIN naklad USING(id_zakazka) JOIN typ_nakladu tn USING(id_ntyp) WHERE tn.nazev = 'Nebezpečný náklad (ADR)';

-- -----------------------------------------------------------------------------
-- [D22] Query over database View
-- CZ: Vyber tahače, které přepravovali nebezpečný náklad
-- EN: Queries the view `nebezpecne_zakazky` to retrieve all tractors utilized for hazardous freight.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * L: L - VIEW
--   * M: M - Dotaz nad pohledem
-- -----------------------------------------------------------------------------
-- Pro případ že by view neexistovalo
CREATE OR REPLACE VIEW nebezpecne_zakazky AS
SELECT z.* FROM zasilka z JOIN naklad USING(id_zakazka) JOIN typ_nakladu tn USING(id_ntyp) WHERE tn.nazev = 'Nebezpečný náklad (ADR)';
--

SELECT t.* FROM tahac t JOIN nebezpecne_zakazky USING (id_tahac) ;

-- -----------------------------------------------------------------------------
-- [D23] Transactional INSERT with nested query
-- CZ: Nový  řidič má shodné údaje s řidičem s nejvyšším id_ridic
-- EN: Demonstrates INSERT INTO ... SELECT within an isolated atomic transaction block (BEGIN ... ROLLBACK).
-- Categories: 
--   * N: N - INSERT, který vloží do některé tabulky množinu řádků, které jsou vybrány dotazem z vybraných tabulek (příkaz INSERT, ve kterém je klauzule VALUES nahrazena vnořeným poddotazem.
-- -----------------------------------------------------------------------------
BEGIN;
SELECT * FROM ridic;
INSERT INTO ridic (id_adresa, jmeno, prijmeni, datum_narozeni)
SELECT id_adresa, jmeno, prijmeni, datum_narozeni FROM ridic ORDER BY id_ridic DESC LIMIT 1;
SELECT * FROM ridic;
ROLLBACK;

-- -----------------------------------------------------------------------------
-- [D24] Transactional UPDATE with nested subquery
-- CZ: Zvýšení nákladů o 2000 na každé zakázce, kde některou zásliku převážel řidič s id 3.
-- EN: Modifies order costs by +2000 for shipments handled by driver 3 inside a transactional sandbox.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * G1: G1 - Vnořený dotaz v klauzuli WHERE
--   * O: O - UPDATE s vnořeným SELECT příkazem
-- -----------------------------------------------------------------------------
BEGIN;
SELECT naklady FROM zakazka JOIN zasilka USING(id_zakazka) WHERE id_ridic = 3;
UPDATE zakazka SET naklady = naklady + 2000 
WHERE id_zakazka IN 
(SELECT id_zakazka FROM zasilka WHERE id_ridic = 3);
SELECT naklady FROM zakazka JOIN zasilka USING(id_zakazka) WHERE id_ridic = 3;
ROLLBACK;

-- -----------------------------------------------------------------------------
-- [D25] Transactional DELETE with set difference
-- CZ: Odstraň řidiče, kteří ještě neodvezli žádnou zásilku.
-- EN: Deletes inactive drivers who have never dispatched a shipment, rolled back safely.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * G1: G1 - Vnořený dotaz v klauzuli WHERE
--   * H2: H2 - Množinový rozdíl - MINUS nebo EXCEPT
--   * P: P - DELETE s vnořeným SELECT příkazem
-- -----------------------------------------------------------------------------
BEGIN;
SELECT * FROM ridic;
DELETE FROM ridic WHERE id_ridic IN (
SELECT id_ridic FROM ridic EXCEPT (SELECT id_ridic FROM ridic JOIN zasilka USING(id_ridic)));
select * FROM ridic;
ROLLBACK;

-- -----------------------------------------------------------------------------
-- [D26] Top 3 customers by transported cargo mass
-- CZ: Vyber TOP 3 zákazníky s největší celkovou přepravenou hmotností
-- EN: Aggregates total tonnage shipped per customer and retrieves top 3 leaderboards.
-- Categories: 
--   * A: A - Pozitivní dotaz nad spojením alespoň dvou tabulek
--   * F2: F2 - NATURAL JOIN|JOIN USING
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
-- -----------------------------------------------------------------------------
SELECT id_zakaznik, SUM(hmotnost) AS celkova_hmotnost
FROM zasilka JOIN zakazka USING(id_zakazka)
GROUP BY id_zakaznik
ORDER BY celkova_hmotnost DESC
LIMIT 3;

-- -----------------------------------------------------------------------------
-- [D27] Multi-purpose trailers (HAVING count > 1)
-- CZ: Návěsy, které mohou přepravovat více typů nákladu
-- EN: Identifies semi-trailers equipped and certified to handle multiple cargo categories.
-- Categories: 
--   * I1: I1 - Agregační funkce (count|sum|min|max|avg)
--   * I2: I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING)
-- -----------------------------------------------------------------------------
SELECT id_naves, count(*) AS pocet_typu
FROM typ_nakladu_naves
GROUP BY id_naves
HAVING COUNT(*) > 1
ORDER BY pocet_typu DESC

