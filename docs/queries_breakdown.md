# SQL Queries & Relational Algebra Matrix

Comprehensive reference of all SQL queries designed for the **Spedice Nedojel** logistics database, cross-referenced with academic category requirements (ČVUT FIT BI-DBS).

## Category Coverage Overview

| Category | Description | Query IDs |
| :--- | :--- | :--- |
| **A** | A - Pozitivní dotaz nad spojením alespoň dvou tabulek | [`D1`](#d1), [`D4`](#d4), [`D10`](#d10), [`D12`](#d12), [`D13`](#d13), [`D15`](#d15), [`D17`](#d17), [`D18`](#d18), [`D19`](#d19), [`D20`](#d20), [`D21`](#d21), [`D22`](#d22), [`D24`](#d24), [`D25`](#d25), [`D26`](#d26) |
| **AR** | A (RA) - Pozitivní dotaz nad spojením alespoň dvou tabulek | [`D4`](#d4), [`D10`](#d10), [`D12`](#d12), [`D13`](#d13), [`D15`](#d15) |
| **B** | B - Negativní dotaz nad spojením alespoň dvou tabulek | [`D14`](#d14) |
| **C** | C - Vyber ty, kteří mají vztah POUZE k ... | [`D5`](#d5) |
| **D1** | D1 - Vyber ty, kteří/které jsou ve vztahu se všemi - dotaz s univerzální kvantifikací | [`D4`](#d4) |
| **D2** | D2 - Kontrola výsledku dotazu z kategorie D1 | [`D13`](#d13) |
| **F1** | F1 - JOIN ON | [`D1`](#d1), [`D15`](#d15) |
| **F1R** | F1 (RA) - JOIN ON | [`D15`](#d15) |
| **F2** | F2 - NATURAL JOIN|JOIN USING | [`D4`](#d4), [`D5`](#d5), [`D10`](#d10), [`D12`](#d12), [`D13`](#d13), [`D17`](#d17), [`D18`](#d18), [`D19`](#d19), [`D20`](#d20), [`D21`](#d21), [`D22`](#d22), [`D24`](#d24), [`D25`](#d25), [`D26`](#d26) |
| **F2R** | F2 (RA) - NATURAL JOIN|JOIN USING | [`D4`](#d4), [`D5`](#d5), [`D10`](#d10), [`D12`](#d12), [`D13`](#d13) |
| **F3** | F3 - CROSS JOIN | [`D16`](#d16) |
| **F4** | F4 - LEFT|RIGHT OUTER JOIN | [`D10`](#d10), [`D19`](#d19) |
| **F4R** | F4 (RA) - LEFT|RIGHT OUTER JOIN | [`D10`](#d10) |
| **F5** | F5 - FULL (OUTER) JOIN | [`D17`](#d17) |
| **G1** | G1 - Vnořený dotaz v klauzuli WHERE | [`D4`](#d4), [`D13`](#d13), [`D14`](#d14), [`D24`](#d24), [`D25`](#d25) |
| **G1R** | G1 (RA) - Vnořený dotaz v klauzuli WHERE | [`D4`](#d4), [`D13`](#d13), [`D14`](#d14) |
| **G2** | G2 - Vnořený dotaz v klauzuli FROM | [`D17`](#d17), [`D19`](#d19) |
| **G3** | G3 - Vnořený dotaz v klauzuli SELECT | [`D8`](#d8), [`D19`](#d19) |
| **G4** | G4 - Vztažený vnořený dotaz (EXISTS, NOT EXISTS) | [`D4`](#d4), [`D13`](#d13) |
| **H1** | H1 - Množinové sjednocení - UNION | [`D19`](#d19) |
| **H2** | H2 - Množinový rozdíl - MINUS nebo EXCEPT | [`D5`](#d5), [`D13`](#d13), [`D19`](#d19), [`D25`](#d25) |
| **H2R** | H2 (RA) - Množinový rozdíl - MINUS nebo EXCEPT | [`D5`](#d5), [`D13`](#d13) |
| **H3** | H3 - Množinový průnik - INTERSECT | [`D20`](#d20) |
| **I1** | I1 - Agregační funkce (count|sum|min|max|avg) | [`D1`](#d1), [`D7`](#d7), [`D8`](#d8), [`D17`](#d17), [`D18`](#d18), [`D19`](#d19), [`D26`](#d26), [`D27`](#d27) |
| **I2** | I2 - Agregační funkce nad seskupenými řádky - GROUP BY (HAVING) | [`D1`](#d1), [`D7`](#d7), [`D17`](#d17), [`D18`](#d18), [`D19`](#d19), [`D26`](#d26), [`D27`](#d27) |
| **J** | J - Stejný dotaz ve třech různých formulacích SQL | [`D19`](#d19) |
| **K** | K - Všechny klauzule v 1 dotazu - SELECT FROM WHERE GROUP BY HAVING ORDER BY | [`D18`](#d18) |
| **L** | L - VIEW | [`D21`](#d21), [`D22`](#d22) |
| **M** | M - Dotaz nad pohledem | [`D22`](#d22) |
| **N** | N - INSERT, který vloží do některé tabulky množinu řádků, které jsou vybrány dotazem z vybraných tabulek (příkaz INSERT, ve kterém je klauzule VALUES nahrazena vnořeným poddotazem. | [`D23`](#d23) |
| **O** | O - UPDATE s vnořeným SELECT příkazem | [`D24`](#d24) |
| **P** | P - DELETE s vnořeným SELECT příkazem | [`D25`](#d25) |

---

## Detailed Query Catalog

### D1 - Most frequently utilized tractor truck

- **Czech Description:** Nejčastěji používaný tahač
- **English Description:** Identifies the tractor truck assigned to the highest number of shipments.
- **Categories:** `A`, `F1`, `I1`, `I2`

**SQL Statement:**
```sql
SELECT t.id_tahac, COUNT(*) AS pocet_zasilek
FROM tahac t
JOIN zasilka z ON t.id_tahac = z.id_tahac
GROUP BY t.id_tahac
ORDER BY pocet_zasilek DESC
LIMIT 1;
```

---

### D2 - Name of the youngest driver

- **Czech Description:** Jméno nejmladšího řidiče.
- **English Description:** Retrieves the driver with the most recent birth date.

**SQL Statement:**
```sql
SELECT jmeno
FROM ridic
ORDER BY datum_narozeni DESC
LIMIT 1;
```

---

### D3 - Distinct tractor truck brands

- **Czech Description:** Seznam všech značek tahačů, které firma vlastní
- **English Description:** Lists all unique manufacturer brands represented in the company fleet.

**Relational Algebra:**
```text
tahac[znacka]
```

**SQL Statement:**
```sql
SELECT DISTINCT znacka FROM tahac
```

---

### D4 - Relational Division / Universal Quantification

- **Czech Description:** Vyber tahače, na kterých byly provedeny všechny servisní úkony
- **English Description:** Selects tractor trucks that have undergone every defined service maintenance procedure (double NOT EXISTS).
- **Categories:** `A`, `AR`, `D1`, `F2`, `F2R`, `G1`, `G1R`, `G4`

**Relational Algebra:**
```text
{{servisni_ukon_servisni_historie * servisni_historie}[id_tahac,id_ukon]÷servisni_ukon[id_ukon]} * tahac
```

**SQL Statement:**
```sql
SELECT * FROM tahac t
WHERE NOT EXISTS(
    SELECT * FROM SERVISNI_UKON su
    WHERE NOT EXISTS (
        SELECT 1 FROM SERVISNI_UKON_SERVISNI_HISTORIE shu
        JOIN SERVISNI_HISTORIE sh USING(id_servis)
        WHERE sh.id_tahac = t.id_tahac AND su.id_ukon = shu.id_ukon
    )
)
```

---

### D5 - Exclusive relationship (Set difference)

- **Czech Description:** Vyber návěsy, které mohou přepravovat pouze náklad 15 (kapaliny)
- **English Description:** Finds semi-trailers certified exclusively for liquid cargo (type 15) and no other cargo category.
- **Categories:** `C`, `F2`, `F2R`, `H2`, `H2R`

**Relational Algebra:**
```text
{naves<naves.id_naves = typ_nakladu_naves.id_naves]typ_nakladu_naves(id_ntyp = 15)}
\
{naves<naves.id_naves = typ_nakladu_naves.id_naves]typ_nakladu_naves(id_ntyp != 15)}
```

**SQL Statement:**
```sql
SELECT n.*
FROM NAVES n
JOIN TYP_NAKLADU_NAVES tnn USING(id_naves) 
WHERE tnn.id_ntyp=15
EXCEPT
SELECT n.*
FROM NAVES n
JOIN TYP_NAKLADU_NAVES tnn USING(id_naves) 
WHERE tnn.id_ntyp!=15
```

---

### D6 - Driver rest duration in date window

- **Czech Description:** Celková doba odpočinku řidiče 5 od 2.12.2024 do 9.12.2024
- **English Description:** Calculates total resting time taken by driver 5 during the first week of December 2024.

**SQL Statement:**
```sql
SELECT id_ridic, SUM(konec - zacatek) AS celkova_doba_odpocinku
FROM pauza
WHERE id_ridic = 5
  AND zacatek >= '2024-12-02 00:00:00'
  AND konec <= '2024-12-09 23:59:59'
GROUP BY id_ridic;
```

---

### D7 - Order count for a specific customer

- **Czech Description:** Počet zakázek od zákazníka s id 1
- **English Description:** Aggregates total transport orders placed by customer ID 1.
- **Categories:** `I1`, `I2`

**SQL Statement:**
```sql
SELECT id_zakaznik, COUNT(*) AS pocet_zakazek FROM zakazka WHERE id_zakaznik = 1 GROUP BY id_zakaznik
```

---

### D8 - Order counts per customer (Correlated subquery in SELECT)

- **Czech Description:** Vypiš ke každému zákazníkovi počet zakázek které zadal. Zákazníky seřaď podle počtu zakázek od největšího.
- **English Description:** Displays every customer along with their total order count, sorted in descending order.
- **Categories:** `G3`, `I1`

**SQL Statement:**
```sql
SELECT *, (SELECT COUNT(*) FROM zakazka zak WHERE  z.id_zakaznik= zak.id_zakaznik) AS pocet_zakazek
FROM zakaznik z
ORDER BY pocet_zakazek DESC;
```

---

### D10 - Tractor trucks with zero service history

- **Czech Description:** Id, značka a model tahače, který ještě nebyl v servisu.
- **English Description:** Finds tractors that have never been scheduled for or undergone any workshop maintenance.
- **Categories:** `A`, `AR`, `F2`, `F2R`, `F4`, `F4R`

**Relational Algebra:**
```text
{tahac * {tahac[id_tahac] \ servisni_historie[id_tahac]}}[id_tahac,znacka,model]
```

**SQL Statement:**
```sql
SELECT t.id_tahac, t.znacka, t.model
FROM TAHAC t
LEFT JOIN SERVISNI_HISTORIE sh USING(id_tahac)
WHERE sh.id_tahac IS NULL;
```

---

### D11 - Orders initiated in year 2025

- **Czech Description:** Zakázky, které mají datum zahájení v letošním roce(2025).
- **English Description:** Filters orders submitted within the 2025 calendar year.

**Relational Algebra:**
```text
Zakazka(zadano_dne > '31.12.2024' ∧ zadano_dne < '01.01.2026')
```

**SQL Statement:**
```sql
SELECT *
FROM ZAKAZKA
WHERE zadano_dne > TO_DATE('31.12.2024','dd.mm.yyyy') AND zadano_dne < TO_DATE('01.01.2026','dd.mm.yyyy');
```

---

### D12 - Trailers certified for dangerous goods (ADR)

- **Czech Description:** Všechny návěsy, které jsou určeny pro převoz nebezpečného zboží.
typ_nakladu.nazev='Nebezpečný náklad (ADR)'
- **English Description:** Multi-table join returning trailers authorized to haul hazardous freight.
- **Categories:** `A`, `AR`, `F2`, `F2R`

**Relational Algebra:**
```text
{naves [naves.id_naves=typ_nakladu_naves.id_naves] 
    {typ_nakladu_naves [typ_nakladu_naves.id_ntyp = typ_nakladu.id_ntyp] 
        typ_nakladu (nazev='Nebezpečný náklad (ADR)')
    }
}[naves.id_naves, naves.vyrobce, typ_nakladu.nazev]
```

**SQL Statement:**
```sql
SELECT n.id_naves, n.vyrobce, tn.nazev FROM NAVES n 
JOIN TYP_NAKLADU_NAVES tnn USING(id_naves) 
JOIN TYP_NAKLADU tn USING(id_ntyp) 
WHERE tn.nazev='Nebezpečný náklad (ADR)'
```

---

### D13 - Service operations not yet performed on tractor 14

- **Czech Description:** Servisní úkony, které nebyly provedeny na tahači 14(id_tahac=14)
- **English Description:** Set difference identifying workshop tasks that have never been executed on a specific tractor.
- **Categories:** `A`, `AR`, `D2`, `F2`, `F2R`, `G1`, `G1R`, `G4`, `H2`, `H2R`

**Relational Algebra:**
```text
{servisni_ukon}
\
{{servisni_historie(id_tahac = 14) [servisni_historie.id_servis = servisni_ukon_servisni_historie.id_servis]servisni_ukon_servisni_historie} 
[servisni_ukon_servisni_historie.id_ukon = servisni_ukon.id_ukon> 
servisni_ukon
}
```

**SQL Statement:**
```sql
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
```

---

### D14 - Unassigned tractor trucks

- **Czech Description:** Vypiš tahač, který nikdy nebyl přiřazen k žádné zásilce
- **English Description:** Negative subquery (NOT IN) identifying tractors that have never been dispatched on any shipment.
- **Categories:** `B`, `G1`, `G1R`

**Relational Algebra:**
```text
zasilka !*> tahac
```

**SQL Statement:**
```sql
SELECT * FROM TAHAC WHERE id_tahac NOT IN (
    SELECT id_tahac FROM ZASILKA
)
```

---

### D15 - Routes originating at driver's home address

- **Czech Description:** Najdi id_trasa a jméno řidiče, která začíná u něj doma
- **English Description:** Finds all route dispatch origins that coincide with the assigned driver's residence.
- **Categories:** `A`, `AR`, `F1`, `F1R`

**Relational Algebra:**
```text
{trasa [trasa.adresa_start = ridic.id_adresa] ridic}
[id_trasa, jmeno]
```

**SQL Statement:**
```sql
SELECT t.id_trasa, r.jmeno FROM TRASA t JOIN RIDIC r ON r.id_adresa = t.adresa_start
```

---

### D16 - Cartesian product of fleet combinations

- **Czech Description:** Vypiš jaké všechny soupravy lze vytvořit (kombinace tahače a návěsu)
- **English Description:** CROSS JOIN generating all theoretical permutations of tractor trucks and semi-trailers.
- **Categories:** `F3`

**Relational Algebra:**
```text
tahac
×
naves
```

**SQL Statement:**
```sql
SELECT *
FROM TAHAC
CROSS JOIN NAVES;
```

---

### D17 - FULL OUTER JOIN with aggregated maintenance tasks

- **Czech Description:** Zobraz všechny tahače a servisní záznamy spolu s počtem servisních úkonů v jednotlivých servisních záznamech.
Pokud tahač nikdy v servisu nebyl, zobraz pouze tahač a pokud servis byl proveden na jiném vozidle než na tahači, tak zobraz pouze údaje o servisu.
Následně seřaď vzestupně podle poču provedených úkonů.
- **English Description:** Combines all tractors and service records including unmatched rows, with task counts per service event.
- **Categories:** `A`, `F2`, `F5`, `G2`, `I1`, `I2`

**SQL Statement:**
```sql
SELECT x.id_servis, x.pocet_ukonu, t.id_tahac, t.znacka
FROM 
(SELECT s.id_servis, s.id_tahac, COUNT(*) AS pocet_ukonu 
 FROM servisni_historie s JOIN servisni_ukon_servisni_historie su USING(id_servis) 
 GROUP BY id_servis
) x
FULL OUTER JOIN tahac t ON x.id_tahac = t.id_tahac
ORDER BY x.pocet_ukonu ASC;
```

---

### D18 - Multi-condition analytical query with HAVING & Subquery

- **Czech Description:** Vyber zákazníky, kteří odeslali alespoň 3 zásilky a jejich průměrná hmotnost zásilek je vyšší než průměrná hmotnost zásilek všech zákazníků dohromady a zároveň zákazník je právnická osoba a sídlí v česku(stat='Česká republika'). Výsledky seřaď sestupně podle průměrné hmotnosti.
- **English Description:** Filters corporate Czech clients having >= 3 shipments whose average cargo weight exceeds fleet-wide benchmark.
- **Categories:** `A`, `F2`, `I1`, `I2`, `K`

**SQL Statement:**
```sql
SELECT zak.id_zakaznik, COUNT(*) AS pocet_zasilek, AVG(z.hmotnost) AS prumerna_hmotnost
FROM zasilka z JOIN zakazka zak USING(id_zakazka) JOIN pravnicka_osoba po USING (id_zakaznik) JOIN adresa a USING (id_adresa) where a.stat='Česká republika'
GROUP BY zak.id_zakaznik
HAVING COUNT(*) >= 3
   AND AVG(z.hmotnost) > (
       SELECT AVG(z2.hmotnost)
       FROM zasilka z2
   )
ORDER BY AVG(z.hmotnost) DESC;
```

---

### D19 - Concept equivalence: Three SQL formulations

- **Czech Description:** Ke každému řidiči vypiš počet odvezených zásilek.
- **English Description:** Computes shipment count per driver using: 1) Scalar subquery in SELECT, 2) Set UNION & EXCEPT, 3) LEFT JOIN with COALESCE.
- **Categories:** `A`, `F2`, `F4`, `G2`, `G3`, `H1`, `H2`, `I1`, `I2`, `J`

**SQL Statement:**
```sql
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
```

---

### D20 - Set intersection: ADR & Electronics drivers

- **Czech Description:** Řidiči, kteří vezli nebezpečný náklad i elektroniku
- **English Description:** INTERSECT query finding drivers experienced with both hazardous materials and sensitive electronics.
- **Categories:** `A`, `F2`, `H3`

**SQL Statement:**
```sql
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
```

---

### D21 - Database View creation

- **Czech Description:** View zásilek s nebezpečným nákladem.
- **English Description:** Defines reusable database view `nebezpecne_zakazky` isolating hazardous goods shipments.
- **Categories:** `A`, `F2`, `L`

**SQL Statement:**
```sql
CREATE OR REPLACE VIEW nebezpecne_zakazky AS
SELECT z.* FROM zasilka z JOIN naklad USING(id_zakazka) JOIN typ_nakladu tn USING(id_ntyp) WHERE tn.nazev = 'Nebezpečný náklad (ADR)';
```

---

### D22 - Query over database View

- **Czech Description:** Vyber tahače, které přepravovali nebezpečný náklad
- **English Description:** Queries the view `nebezpecne_zakazky` to retrieve all tractors utilized for hazardous freight.
- **Categories:** `A`, `F2`, `L`, `M`

**SQL Statement:**
```sql
-- Pro případ že by view neexistovalo
CREATE OR REPLACE VIEW nebezpecne_zakazky AS
SELECT z.* FROM zasilka z JOIN naklad USING(id_zakazka) JOIN typ_nakladu tn USING(id_ntyp) WHERE tn.nazev = 'Nebezpečný náklad (ADR)';
--

SELECT t.* FROM tahac t JOIN nebezpecne_zakazky USING (id_tahac) ;
```

---

### D23 - Transactional INSERT with nested query

- **Czech Description:** Nový  řidič má shodné údaje s řidičem s nejvyšším id_ridic
- **English Description:** Demonstrates INSERT INTO ... SELECT within an isolated atomic transaction block (BEGIN ... ROLLBACK).
- **Categories:** `N`

**SQL Statement:**
```sql
BEGIN;
SELECT * FROM ridic;
INSERT INTO ridic (id_adresa, jmeno, prijmeni, datum_narozeni)
SELECT id_adresa, jmeno, prijmeni, datum_narozeni FROM ridic ORDER BY id_ridic DESC LIMIT 1;
SELECT * FROM ridic;
ROLLBACK;
```

---

### D24 - Transactional UPDATE with nested subquery

- **Czech Description:** Zvýšení nákladů o 2000 na každé zakázce, kde některou zásliku převážel řidič s id 3.
- **English Description:** Modifies order costs by +2000 for shipments handled by driver 3 inside a transactional sandbox.
- **Categories:** `A`, `F2`, `G1`, `O`

**SQL Statement:**
```sql
BEGIN;
SELECT naklady FROM zakazka JOIN zasilka USING(id_zakazka) WHERE id_ridic = 3;
UPDATE zakazka SET naklady = naklady + 2000 
WHERE id_zakazka IN 
(SELECT id_zakazka FROM zasilka WHERE id_ridic = 3);
SELECT naklady FROM zakazka JOIN zasilka USING(id_zakazka) WHERE id_ridic = 3;
ROLLBACK;
```

---

### D25 - Transactional DELETE with set difference

- **Czech Description:** Odstraň řidiče, kteří ještě neodvezli žádnou zásilku.
- **English Description:** Deletes inactive drivers who have never dispatched a shipment, rolled back safely.
- **Categories:** `A`, `F2`, `G1`, `H2`, `P`

**SQL Statement:**
```sql
BEGIN;
SELECT * FROM ridic;
DELETE FROM ridic WHERE id_ridic IN (
SELECT id_ridic FROM ridic EXCEPT (SELECT id_ridic FROM ridic JOIN zasilka USING(id_ridic)));
select * FROM ridic;
ROLLBACK;
```

---

### D26 - Top 3 customers by transported cargo mass

- **Czech Description:** Vyber TOP 3 zákazníky s největší celkovou přepravenou hmotností
- **English Description:** Aggregates total tonnage shipped per customer and retrieves top 3 leaderboards.
- **Categories:** `A`, `F2`, `I1`, `I2`

**SQL Statement:**
```sql
SELECT id_zakaznik, SUM(hmotnost) AS celkova_hmotnost
FROM zasilka JOIN zakazka USING(id_zakazka)
GROUP BY id_zakaznik
ORDER BY celkova_hmotnost DESC
LIMIT 3;
```

---

### D27 - Multi-purpose trailers (HAVING count > 1)

- **Czech Description:** Návěsy, které mohou přepravovat více typů nákladu
- **English Description:** Identifies semi-trailers equipped and certified to handle multiple cargo categories.
- **Categories:** `I1`, `I2`

**SQL Statement:**
```sql
SELECT id_naves, count(*) AS pocet_typu
FROM typ_nakladu_naves
GROUP BY id_naves
HAVING COUNT(*) > 1
ORDER BY pocet_typu DESC
```

---

