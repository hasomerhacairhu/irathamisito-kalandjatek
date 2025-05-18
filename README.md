# Irathamisító Kalandjáték

Ez a repository az "Irathamisító Kalandjáték" kódját tartalmazza. A játék egy mobil szabadulószoba, melyet Hasomer Hacair fejlesztett.

## A Játékról Bővebben

További információkat a játékról és a kapcsolódó "Irathamisító Műhelyről" a következő weboldalon találhatsz:
[https://somer.hu/irathamisito-muhely](https://somer.hu/irathamisito-muhely)

A játékhoz készülő weboldal tartalmáról és felépítéséről a [website/website_content.md](website/website_content.md) fájlban olvashatsz.

## Telepítés

A Tasmota eszközökre történő telepítéshez használd a következő parancsokat a Tasmota konzolban:

```
Backlog UrlFetch https://raw.githubusercontent.com/hasomerhacairhu/irathamisito-kalandjatek/refs/heads/main/tasmota/autoload.be; Br import autoload; UpdateScripts; Restart 1
```