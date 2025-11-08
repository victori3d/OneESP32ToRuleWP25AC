#!/bin/bash
# CAN-ID Analyse für WPL 25AC
# Ziel: Identifiziere 0x0100 und 0x0500

echo "=========================================="
echo "CAN-ID Frequenz-Analyse"
echo "=========================================="
echo ""

# Zähle wie oft jede CAN-ID vorkommt
echo "Top 10 häufigste CAN-IDs:"
grep "Can message received with CANId" test.log | \
  awk '{print $NF}' | \
  sort | uniq -c | \
  sort -rn | \
  head -10

echo ""
echo "=========================================="
echo "Nachrichten-Beispiele pro CAN-ID"
echo "=========================================="
echo ""

echo "--- 0x0180 (Kessel) ---"
grep -A 1 "CANId 0x0180" test.log | head -6

echo ""
echo "--- 0x0480 (Manager) ---"
grep -A 1 "CANId 0x0480" test.log | head -6

echo ""
echo "--- 0x0100 (UNBEKANNT) ---"
grep -A 1 "CANId 0x0100" test.log | head -6

echo ""
echo "--- 0x0500 (UNBEKANNT) ---"
grep -A 1 "CANId 0x0500" test.log | head -6

echo ""
echo "=========================================="
echo "Timing-Analyse"
echo "=========================================="
echo ""

echo "Nachrichten pro Sekunde:"
grep "Can message received" test.log | \
  awk '{print $1}' | \
  cut -d: -f1-2 | \
  uniq -c | \
  tail -20

echo ""
echo "=========================================="
echo "ZUSAMMENFASSUNG"
echo "=========================================="

TOTAL=$(grep -c "Can message received" test.log)
ID_0180=$(grep -c "CANId 0x0180" test.log)
ID_0480=$(grep -c "CANId 0x0480" test.log)
ID_0100=$(grep -c "CANId 0x0100" test.log)
ID_0500=$(grep -c "CANId 0x0500" test.log)

echo ""
echo "Gesamt empfangene Nachrichten: $TOTAL"
echo ""
echo "Verteilung:"
echo "  0x0180 (Kessel):   $ID_0180 ($(( ID_0180 * 100 / TOTAL ))%)"
echo "  0x0480 (Manager):  $ID_0480 ($(( ID_0480 * 100 / TOTAL ))%)"
echo "  0x0100 (???):      $ID_0100 ($(( ID_0100 * 100 / TOTAL ))%)"
echo "  0x0500 (???):      $ID_0500 ($(( ID_0500 * 100 / TOTAL ))%)"
echo ""

echo "=========================================="
echo "VERMUTUNG basierend auf Stiebel-Dokumentation:"
echo "=========================================="
echo ""
echo "0x0100 → Vermutlich Response-ID"
echo "         (Master sendet 0x100 als Antwort)"
echo ""
echo "0x0500 → Vermutlich Heizmodul"
echo "         (HM = Heating Module)"
echo ""
echo "Empfehlung:"
echo "1. 0x0100 als 'Response' in communication.h hinzufügen"
echo "2. 0x0500 als 'Heizmodul' in communication.h hinzufügen"
echo "3. Neucompilieren und testen"