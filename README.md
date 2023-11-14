# Freitag 10.11.2023

Bei Übung 133 bauen wir auf dem Stand von Übung 132 auf. Wir haben die Musterlösung genommen und einige Änderungen vorgenommen und sie auch erweitert.

## Änderungen Terraform

- eingecheckten State gelöscht: wir arbeiten auf unseren eigenen accounts in aws, daher wollen wir ein frischen state generieren.
- Variablen angepasst:
  - `dev_vars.auto.tfvars`: profilname auf das profil der awscli angepasst
  - `ec2.tf`: variable `key` definiert, um den default-Wert im Modul zu überschreiben. Wert der Variable ist der NAme des SSH-Keys, welcher bereits in aws gespeichert ist. 
- Im Modul `ec2` haben wir die Security Group angepasst:
  - Port von Grafana auf 3000 gesetzt
  - Ingress-Rule für Alertmanager Port 9093 hinzugefügt. 

Danach konnte die Terraform Configuration in aws ohne Fehler deployed werden.

## Änderungen Ansible

- In Ansible haben wir zunächst einmal die Playbooks angepasst. Die Playbooks `grafana.yml` und `prometheus.yml` haben wir in `node_exporter.yml` und `monitoring.yml` umbenannt und den Inhalt angepasst.
- Wir haben das Inventory erstellt mit den Infos aus Terraform (public IPs).

Dann konnten wir Prometheus deployen.

- Für das Grafana Deployment haben wir in der Grafana Config `grafana.ini` den Port auf 3000 gesetzt.

Dann konnten wir Grafana deployen.

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

# Montag 13.11.2023

Heute haben wir hier weiter gemacht. Zunächst haben wir Alert-Rules erstellt und diese in der Datei `my-rules.yml` gespeichert. Zusätzlich haben wir von hier[https://samber.github.io/awesome-prometheus-alerts/rules#host-and-hardware] Alert-Rules für den node_exporter angeschaut und implementiert.

Das Konstrukt haben wir dann getestet. Wir haben den node_exporter auf dem zweiten Host abgeschalten, was von Prometheus schnell bemerkt wurde. Der Alert `InstanceDown` wurde getriggert und kam beim Alertmanager an.

Wir wollten und vom Alertmanager benachrichtigen lassen. Dazu haben wir in AWS ein neues SNS Topic angelegt. Zusätzlich haben wir dieses Topic per Mail abonniert, sodass Nachrichten in diesem Topic uns per Mail zugeschickt werden. Im Alertmanager haben wir noch die Route für die Alerts so eingestellt, dass die Alerts un diesem SNS Topic veröffentlicht werden. Um das möglich zu machen mussten wir die Alertmanager Config anpassen und die Systemd-Unit des Alertmanagers so anpassen, dass unsere Credentials aus einer Datei mit Umgebungsvariablen gelesen werden.

Zusätzlich haben wir zwischendurch noch in Grafana geschaut. Hier haben wir ein Dashboard für den node_exporter importiert (Node Exporter Full; ID 1860), welches uns detaillierte Einblicke zu den Hosts geben konnte. Das Dashboard haben wir von hier: https://grafana.com/grafana/dashboards/
Wir haben ebenfalls Dashboards für Prometheus und den Alertmanager importiert, welche Daten zu den beiden Systemen visualisiert.
