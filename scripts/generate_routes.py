"""
Route & Trip Duration Synthetic Data Generator
----------------------------------------------
Utility script used to synthesize realistic logistics routes, distances,
and estimated driving times for the Spedice Nedojel database.

Author: Matěj Široký
Course: BI-DBS, CTU FIT
"""

import random

def time_from_distance(distance_km: float) -> str:
    """
    Calculates formatted trip duration (HH:MM:SS) based on a realistic
    freight truck highway cruising speed (70 - 90 km/h).
    """
    speed_kmh = random.uniform(70, 90)
    hours_float = distance_km / speed_kmh
    total_minutes = int(hours_float * 60)
    hours = total_minutes // 60
    minutes = total_minutes % 60
    return f"{hours:02}:{minutes:02}:00"

def generate_route_inserts(count: int = 100, max_address_id: int = 100):
    """
    Generates PostgreSQL INSERT statements for table `trasa`.
    """
    statements = []
    for _ in range(count):
        start = random.randint(1, max_address_id)
        end = random.randint(1, max_address_id)
        while end == start:
            end = random.randint(1, max_address_id)

        distance = random.randint(10, 3000)
        duration = time_from_distance(distance)
        sql = (
            f"INSERT INTO trasa (adresa_start, adresa_cil, vzdalenost, jizda_cas) "
            f"VALUES ({start}, {end}, {distance}, '{duration}');"
        )
        statements.append(sql)
    return statements

if __name__ == "__main__":
    for stmt in generate_route_inserts(100):
        print(stmt)
