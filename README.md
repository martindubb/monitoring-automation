# Freitag 10.11.2023

Bei Übung 133 bauen wir auf dem Stand von Übung 132 auf. Wir haben die Musterlösung von hier[https://github.com/MTeeeee/teaching/tree/main/Monitoring/Grafana_Prometheus] genommen und einige Änderungen vorgenommen und sie auch erweitert.

## Änderungen Terraform

- eingecheckten State gelöscht: wir arbeiten auf unseren eigenen Accounts in aws, daher wollen wir ein frischen eigenen State generieren.
- Variablen angepasst:
  - `dev_vars.auto.tfvars`: Profilname auf das Profil der awscli angepasst
  - `ec2.tf`: Variable `key` definiert, um den default-Wert im Modul zu überschreiben. Wert der Variable ist der Name des SSH-Keys, welcher bereits in aws gespeichert ist.
- Im Modul `ec2` haben wir die Security Group angepasst:
  - Port von Grafana auf 3000 gesetzt
  - Ingress-Rule für Alertmanager Port 9093 hinzugefügt.

Danach konnte die Terraform Configuration in aws ohne Fehler deployed werden.

## Änderungen Ansible

- In Ansible haben wir zunächst einmal die Playbooks angepasst. Die Playbooks `grafana.yml` und `prometheus.yml` haben wir in `node_exporter.yml` und `monitoring.yml` umbenannt und den Inhalt angepasst.
- Wir haben das Inventory erstellt mit den Infos aus Terraform (public IPs).

Dann konnten wir Prometheus deployen.

- Für das Grafana Deployment haben wir in der Grafana Config `grafana.ini` den Port auf 3000 gesetzt.

Dann konnten wir auch Grafana deployen.

Beim Node Exporter haben wir nichts geändert, den konnten wir auch direkt so deployen.

Grundsätzlich haben wir die letzten Tasks, bei denen die Systemd-Unit gestartet wird, angepasst, sodass der Dienst immer restarted anstatt nur gestartet wird. Dadurch stellen wir sicher, dass die neue Config vom System eingelesen und verwendet wird.

## Neu hinzugekommen

Neu hinzugefügt haben wir die Rolle `alertmanager`. Hier haben wir die Installation von Prometheus kopiert und soweit angepasst, dass der Alertmanager installiert und gestartet wird.

---

Das ganze haben wir immer wieder durch Aufruf der Dienste im Browser verifiziert, wir konnten sehen, dass

- die Config sich ändert
- die node_exporter tatsächlich Daten liefern
- diese Metriken von Prometheus abgeholt und danach auch abfragtbar sind

Was nun noch fehlt (Hausaufgabe bzw. arbeiten wir da am Montag weiter dran):

- Schreiben von Alert-Rules
- Testen des Alerting-Systems
- Integration in Grafana
- Alertmanager schickt Benachrichtigungen
