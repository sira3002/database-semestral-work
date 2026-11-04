-- odeberu pokud existuje funkce na oodebrání tabulek a sekvencí
DROP FUNCTION IF EXISTS remove_all();

-- vytvořím funkci která odebere tabulky a sekvence
-- chcete také umět psát PLSQL? Zapište si předmět BI-SQL ;-)
CREATE or replace FUNCTION remove_all() RETURNS void AS $$
DECLARE
    rec RECORD;
    cmd text;
BEGIN
    cmd := '';

    FOR rec IN SELECT
            'DROP SEQUENCE ' || quote_ident(n.nspname) || '.'
                || quote_ident(c.relname) || ' CASCADE;' AS name
        FROM
            pg_catalog.pg_class AS c
        LEFT JOIN
            pg_catalog.pg_namespace AS n
        ON
            n.oid = c.relnamespace
        WHERE
            relkind = 'S' AND
            n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
            pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    FOR rec IN SELECT
            'DROP TABLE ' || quote_ident(n.nspname) || '.'
                || quote_ident(c.relname) || ' CASCADE;' AS name
        FROM
            pg_catalog.pg_class AS c
        LEFT JOIN
            pg_catalog.pg_namespace AS n
        ON
            n.oid = c.relnamespace WHERE relkind = 'r' AND
            n.nspname NOT IN ('pg_catalog', 'pg_toast') AND
            pg_catalog.pg_table_is_visible(c.oid)
    LOOP
        cmd := cmd || rec.name;
    END LOOP;

    EXECUTE cmd;
    RETURN;
END;
$$ LANGUAGE plpgsql;
-- zavolám funkci co odebere tabulky a sekvence - Mohl bych dropnout celé schéma a znovu jej vytvořit, použíjeme však PLSQL
select remove_all();

CREATE TABLE adresa (
    id_adresa SERIAL NOT NULL,
    ulice VARCHAR(100) NOT NULL,
    cislo_popisne VARCHAR(20) NOT NULL,
    mesto VARCHAR(50) NOT NULL,
    psc INTEGER NOT NULL,
    stat VARCHAR(100) NOT NULL
);
ALTER TABLE adresa ADD CONSTRAINT pk_adresa PRIMARY KEY (id_adresa);

CREATE TABLE fyzicka_osoba (
    id_zakaznik INTEGER NOT NULL,
    id_adresa INTEGER NOT NULL,
    jmeno VARCHAR(30) NOT NULL,
    prijmeni VARCHAR(50) NOT NULL,
    ico INTEGER,
    telefon INTEGER NOT NULL,
    email VARCHAR(100) NOT NULL
);
ALTER TABLE fyzicka_osoba ADD CONSTRAINT pk_fyzicka_osoba PRIMARY KEY (id_zakaznik);
ALTER TABLE fyzicka_osoba ADD CONSTRAINT uc_fyzicka_osoba_ico UNIQUE (ico);

CREATE TABLE nabijeni (
    platba_kod SERIAL NOT NULL,
    id_tahac INTEGER NOT NULL,
    datum DATE NOT NULL,
    stav_km INTEGER NOT NULL,
    jmeno_stanice VARCHAR(50) NOT NULL,
    cena_kwh INTEGER NOT NULL,
    nabito_kwh INTEGER NOT NULL,
    cas TIME NOT NULL,
    cena INTEGER NOT NULL
);
ALTER TABLE nabijeni ADD CONSTRAINT pk_nabijeni PRIMARY KEY (platba_kod);

CREATE TABLE naklad (
    id_naklad SERIAL NOT NULL,
    id_ntyp INTEGER NOT NULL,
    id_zakazka INTEGER NOT NULL,
    hmotnost INTEGER NOT NULL
);
ALTER TABLE naklad ADD CONSTRAINT pk_naklad PRIMARY KEY (id_naklad);

CREATE TABLE naves (
    id_naves SERIAL NOT NULL,
    hmotnost INTEGER NOT NULL,
    nosnost INTEGER NOT NULL,
    vyrobce VARCHAR(50) NOT NULL
);
ALTER TABLE naves ADD CONSTRAINT pk_naves PRIMARY KEY (id_naves);

CREATE TABLE pauza (
    zacatek TIMESTAMP NOT NULL,
    konec TIMESTAMP NOT NULL,
    id_ridic INTEGER NOT NULL,
    id_zastavka INTEGER
);
ALTER TABLE pauza ADD CONSTRAINT pk_pauza PRIMARY KEY (zacatek, konec, id_ridic);

CREATE TABLE pravnicka_osoba (
    id_zakaznik INTEGER NOT NULL,
    id_adresa INTEGER NOT NULL,
    spolecnost VARCHAR(100) NOT NULL,
    ico INTEGER NOT NULL,
    ko_jmeno VARCHAR(30) NOT NULL,
    ko_prijmeni VARCHAR(50) NOT NULL,
    telefon INTEGER NOT NULL,
    email VARCHAR(100) NOT NULL
);
ALTER TABLE pravnicka_osoba ADD CONSTRAINT pk_pravnicka_osoba PRIMARY KEY (id_zakaznik);
ALTER TABLE pravnicka_osoba ADD CONSTRAINT uc_pravnicka_osoba_ico UNIQUE (ico);

CREATE TABLE ridic (
    id_ridic SERIAL NOT NULL,
    id_adresa INTEGER NOT NULL,
    jmeno VARCHAR(30) NOT NULL,
    prijmeni VARCHAR(50) NOT NULL,
    datum_narozeni DATE NOT NULL
);
ALTER TABLE ridic ADD CONSTRAINT pk_ridic PRIMARY KEY (id_ridic);

CREATE TABLE servisni_historie (
    id_servis SERIAL NOT NULL,
    id_naves INTEGER,
    id_tahac INTEGER,
    stav_km INTEGER,
    cena INTEGER NOT NULL,
    datum DATE NOT NULL
);
ALTER TABLE servisni_historie ADD CONSTRAINT pk_servisni_historie PRIMARY KEY (id_servis);

CREATE TABLE servisni_ukon (
    id_ukon SERIAL NOT NULL,
    uk_popis VARCHAR(256) NOT NULL,
    uk_nazev VARCHAR(100) NOT NULL
);
ALTER TABLE servisni_ukon ADD CONSTRAINT pk_servisni_ukon PRIMARY KEY (id_ukon);

CREATE TABLE sluzba (
    id_sluzba SERIAL NOT NULL,
    id_zastavka INTEGER,
    nazev VARCHAR(50) NOT NULL,
    popis VARCHAR(256)
);
ALTER TABLE sluzba ADD CONSTRAINT pk_sluzba PRIMARY KEY (id_sluzba);

CREATE TABLE tahac (
    id_tahac SERIAL NOT NULL,
    spz VARCHAR(10) NOT NULL,
    znacka VARCHAR(30) NOT NULL,
    model VARCHAR(50) NOT NULL,
    typ_pohonu VARCHAR(20) NOT NULL,
    spotreba INTEGER NOT NULL,
    nosnost INTEGER NOT NULL
);
ALTER TABLE tahac ADD CONSTRAINT pk_tahac PRIMARY KEY (id_tahac);

CREATE TABLE tankovani (
    platba_kod SERIAL NOT NULL,
    id_tahac INTEGER NOT NULL,
    datum DATE NOT NULL,
    stav_km INTEGER NOT NULL,
    jmeno_stanice VARCHAR(50) NOT NULL,
    cena_l INTEGER NOT NULL,
    celkem_l INTEGER NOT NULL,
    cena INTEGER NOT NULL
);
ALTER TABLE tankovani ADD CONSTRAINT pk_tankovani PRIMARY KEY (platba_kod);

CREATE TABLE trasa (
    id_trasa SERIAL NOT NULL,
    adresa_start INTEGER NOT NULL,
    adresa_cil INTEGER NOT NULL,
    vzdalenost INTEGER NOT NULL,
    jizda_cas INTERVAL NOT NULL
);
ALTER TABLE trasa ADD CONSTRAINT pk_trasa PRIMARY KEY (id_trasa);

CREATE TABLE typ_nakladu (
    id_ntyp SERIAL NOT NULL,
    nazev VARCHAR(100) NOT NULL
);
ALTER TABLE typ_nakladu ADD CONSTRAINT pk_typ_nakladu PRIMARY KEY (id_ntyp);

CREATE TABLE zakazka (
    id_zakazka SERIAL NOT NULL,
    id_zakaznik INTEGER NOT NULL,
    zadano_dne DATE NOT NULL,
    cena INTEGER NOT NULL,
    naklady INTEGER NOT NULL,
    termin_start DATE NOT NULL,
    termin_navrat DATE NOT NULL,
    termin_nakladka DATE NOT NULL,
    termin_vykladka DATE NOT NULL
);
ALTER TABLE zakazka ADD CONSTRAINT pk_zakazka PRIMARY KEY (id_zakazka);

CREATE TABLE zakaznik (
    id_zakaznik SERIAL NOT NULL
);
ALTER TABLE zakaznik ADD CONSTRAINT pk_zakaznik PRIMARY KEY (id_zakaznik);

CREATE TABLE zasilka (
    id_zasilka SERIAL NOT NULL,
    id_naves INTEGER NOT NULL,
    id_tahac INTEGER NOT NULL,
    id_zakazka INTEGER NOT NULL,
    id_ridic INTEGER NOT NULL,
    id_trasa INTEGER NOT NULL,
    hmotnost INTEGER NOT NULL
);
ALTER TABLE zasilka ADD CONSTRAINT pk_zasilka PRIMARY KEY (id_zasilka);
-- ALTER TABLE zasilka ADD CONSTRAINT u_fk_zasilka_trasa UNIQUE (id_trasa);

CREATE TABLE zastavka (
    id_zastavka SERIAL NOT NULL,
    nazev VARCHAR(50) NOT NULL,
    gps_x NUMERIC NOT NULL,
    gps_y NUMERIC NOT NULL
);
ALTER TABLE zastavka ADD CONSTRAINT pk_zastavka PRIMARY KEY (id_zastavka);

CREATE TABLE servisni_ukon_servisni_historie (
    id_ukon INTEGER NOT NULL,
    id_servis INTEGER NOT NULL
);
ALTER TABLE servisni_ukon_servisni_historie ADD CONSTRAINT pk_servisni_ukon_servisni_histo PRIMARY KEY (id_ukon, id_servis);

CREATE TABLE typ_nakladu_naves (
    id_ntyp INTEGER NOT NULL,
    id_naves INTEGER NOT NULL
);
ALTER TABLE typ_nakladu_naves ADD CONSTRAINT pk_typ_nakladu_naves PRIMARY KEY (id_ntyp, id_naves);

CREATE TABLE zastavka_trasa (
    id_zastavka INTEGER NOT NULL,
    id_trasa INTEGER NOT NULL
);
ALTER TABLE zastavka_trasa ADD CONSTRAINT pk_zastavka_trasa PRIMARY KEY (id_zastavka, id_trasa);

ALTER TABLE fyzicka_osoba ADD CONSTRAINT fk_fyzicka_osoba_zakaznik FOREIGN KEY (id_zakaznik) REFERENCES zakaznik (id_zakaznik) ON DELETE CASCADE;
ALTER TABLE fyzicka_osoba ADD CONSTRAINT fk_fyzicka_osoba_adresa FOREIGN KEY (id_adresa) REFERENCES adresa (id_adresa) ON DELETE CASCADE;

ALTER TABLE nabijeni ADD CONSTRAINT fk_nabijeni_tahac FOREIGN KEY (id_tahac) REFERENCES tahac (id_tahac) ON DELETE CASCADE;

ALTER TABLE naklad ADD CONSTRAINT fk_naklad_typ_nakladu FOREIGN KEY (id_ntyp) REFERENCES typ_nakladu (id_ntyp) ON DELETE CASCADE;
ALTER TABLE naklad ADD CONSTRAINT fk_naklad_zakazka FOREIGN KEY (id_zakazka) REFERENCES zakazka (id_zakazka) ON DELETE CASCADE;

ALTER TABLE pauza ADD CONSTRAINT fk_pauza_ridic FOREIGN KEY (id_ridic) REFERENCES ridic (id_ridic) ON DELETE CASCADE;
ALTER TABLE pauza ADD CONSTRAINT fk_pauza_zastavka FOREIGN KEY (id_zastavka) REFERENCES zastavka (id_zastavka) ON DELETE CASCADE;

ALTER TABLE pravnicka_osoba ADD CONSTRAINT fk_pravnicka_osoba_zakaznik FOREIGN KEY (id_zakaznik) REFERENCES zakaznik (id_zakaznik) ON DELETE CASCADE;
ALTER TABLE pravnicka_osoba ADD CONSTRAINT fk_pravnicka_osoba_adresa FOREIGN KEY (id_adresa) REFERENCES adresa (id_adresa) ON DELETE CASCADE;

ALTER TABLE ridic ADD CONSTRAINT fk_ridic_adresa FOREIGN KEY (id_adresa) REFERENCES adresa (id_adresa) ON DELETE CASCADE;

ALTER TABLE servisni_historie ADD CONSTRAINT fk_servisni_historie_naves FOREIGN KEY (id_naves) REFERENCES naves (id_naves) ON DELETE CASCADE;
ALTER TABLE servisni_historie ADD CONSTRAINT fk_servisni_historie_tahac FOREIGN KEY (id_tahac) REFERENCES tahac (id_tahac) ON DELETE CASCADE;

ALTER TABLE sluzba ADD CONSTRAINT fk_sluzba_zastavka FOREIGN KEY (id_zastavka) REFERENCES zastavka (id_zastavka) ON DELETE CASCADE;

ALTER TABLE tankovani ADD CONSTRAINT fk_tankovani_tahac FOREIGN KEY (id_tahac) REFERENCES tahac (id_tahac) ON DELETE CASCADE;

ALTER TABLE trasa ADD CONSTRAINT fk_trasa_adresa FOREIGN KEY (adresa_start) REFERENCES adresa (id_adresa) ON DELETE CASCADE;
ALTER TABLE trasa ADD CONSTRAINT fk_trasa_adresa_1 FOREIGN KEY (adresa_cil) REFERENCES adresa (id_adresa) ON DELETE CASCADE;

ALTER TABLE zakazka ADD CONSTRAINT fk_zakazka_zakaznik FOREIGN KEY (id_zakaznik) REFERENCES zakaznik (id_zakaznik) ON DELETE CASCADE;

ALTER TABLE zasilka ADD CONSTRAINT fk_zasilka_naves FOREIGN KEY (id_naves) REFERENCES naves (id_naves) ON DELETE CASCADE;
ALTER TABLE zasilka ADD CONSTRAINT fk_zasilka_tahac FOREIGN KEY (id_tahac) REFERENCES tahac (id_tahac) ON DELETE CASCADE;
ALTER TABLE zasilka ADD CONSTRAINT fk_zasilka_zakazka FOREIGN KEY (id_zakazka) REFERENCES zakazka (id_zakazka) ON DELETE CASCADE;
ALTER TABLE zasilka ADD CONSTRAINT fk_zasilka_ridic FOREIGN KEY (id_ridic) REFERENCES ridic (id_ridic) ON DELETE CASCADE;
ALTER TABLE zasilka ADD CONSTRAINT fk_zasilka_trasa FOREIGN KEY (id_trasa) REFERENCES trasa (id_trasa) ON DELETE CASCADE;

ALTER TABLE servisni_ukon_servisni_historie ADD CONSTRAINT fk_servisni_ukon_servisni_histo FOREIGN KEY (id_ukon) REFERENCES servisni_ukon (id_ukon) ON DELETE CASCADE;
ALTER TABLE servisni_ukon_servisni_historie ADD CONSTRAINT fk_servisni_ukon_servisni_his_1 FOREIGN KEY (id_servis) REFERENCES servisni_historie (id_servis) ON DELETE CASCADE;

ALTER TABLE typ_nakladu_naves ADD CONSTRAINT fk_typ_nakladu_naves_typ_naklad FOREIGN KEY (id_ntyp) REFERENCES typ_nakladu (id_ntyp) ON DELETE CASCADE;
ALTER TABLE typ_nakladu_naves ADD CONSTRAINT fk_typ_nakladu_naves_naves FOREIGN KEY (id_naves) REFERENCES naves (id_naves) ON DELETE CASCADE;

ALTER TABLE zastavka_trasa ADD CONSTRAINT fk_zastavka_trasa_zastavka FOREIGN KEY (id_zastavka) REFERENCES zastavka (id_zastavka) ON DELETE CASCADE;
ALTER TABLE zastavka_trasa ADD CONSTRAINT fk_zastavka_trasa_trasa FOREIGN KEY (id_trasa) REFERENCES trasa (id_trasa) ON DELETE CASCADE;

ALTER TABLE servisni_historie ADD CONSTRAINT xc_servisni_historie_id_naves_i CHECK ((id_naves IS NOT NULL AND id_tahac IS NULL) OR (id_naves IS NULL AND id_tahac IS NOT NULL));

