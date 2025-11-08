#!/bin/bash
# Heizkreis-Analyse aus CAN-Log
# Ziel: Unterscheide HK1 und HK2 anhand der Sub-IDs

echo "=========================================="
echo "Heizkreis-Unterscheidung"
echo "=========================================="
echo ""

if [ ! -f "final_log.txt" ]; then
    echo "❌ final_log.txt nicht gefunden!"
    exit 1
fi

echo "=== HKISTTEMP-Nachrichten im Detail ==="
echo ""

# Alle HKISTTEMP-Nachrichten mit voller Info
grep "HKISTTEMP" final_log.txt | \
  sed 's/\[.*\]\[.*\]://g' | \
  awk '{print $5, $6, $9, $10, $13, $14}'

echo ""
echo "=== Gruppiert nach Raw-Wert ==="
echo ""

echo "HKISTTEMP mit Raw ~310 (31.0°C):"
grep "HKISTTEMP.*raw value: 31[0-9]" final_log.txt | \
  awk '{print $0}' | \
  sed 's/.*Read\/Write ID /  ID: /' | \
  sed 's/ for property.*//'

echo ""
echo "HKISTTEMP mit Raw ~375 (37.5°C):"
grep "HKISTTEMP.*raw value: 37[0-9]" final_log.txt | \
  awk '{print $0}' | \
  sed 's/.*Read\/Write ID /  ID: /' | \
  sed 's/ for property.*//'

echo ""
echo "=== Analyse der Sub-IDs ==="
echo ""

echo "Alle Read/Write IDs für HKISTTEMP:"
grep "HKISTTEMP" final_log.txt | \
  sed 's/.*Read\/Write ID //' | \
  sed 's/ for property.*//' | \
  sort | uniq -c

echo ""
echo "=== VERMUTUNG ==="
echo ""
echo "Sub-ID-Format: 0xXX 0xYY(0xCANID)"
echo ""
echo "Wenn 0xYY unterschiedlich ist:"
echo "  → 0xYY könnte HK1/HK2 kennzeichnen"
echo ""
echo "Beispiel aus deinem Log:"
echo "  0xa0 0x00(0x0500) → Raw 375 (37.5°C)"
echo "  0xa0 0x00(0x0500) → Raw 310 (31.0°C)"
echo ""
echo "Problem: Beide haben gleiche Sub-ID!"
echo "Lösung: Nachrichten kommen zu unterschiedlichen Zeiten"
echo ""
echo "=== Zeitliche Verteilung ==="
echo ""

echo "HKISTTEMP-Nachrichten mit Zeitstempel:"
grep "HKISTTEMP" final_log.txt | \
  awk '{print $1, $NF}' | \
  sed 's/\[//g' | sed 's/\]//g'

echo ""
echo "=== EMPFEHLUNG ==="
echo ""
echo "Da beide HKISTTEMP von 0x0500 kommen:"
echo ""
echo "Option 1: BEIDE Werte tracken"
echo "  - Erstelle zwei Sensoren: HK_IST_A und HK_IST_B"
echo "  - Speichere beide Werte parallel"
echo "  - Vergleiche mit WPM3 welcher HK1/HK2 ist"
echo ""
echo "Option 2: Prüfe VORLAUFSOLLTEMP"
echo "  - HK1-Soll: 33.7°C"
echo "  - HK2-Soll: 26.7°C"
echo "  - Wenn die Sollwerte klar zuordenbar sind"
echo "  - Dann können wir HK1/HK2 identifizieren"
echo ""
echo "Option 3: Teste Manager (0x480)"
echo "  - Manager hat evtl. separate HK-Register"
echo "  - Suche nach 0x480 + VORLAUF/RAUMSOLL"