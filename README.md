# Calculadora de Redes

![Logo](https://img.shields.io/badge/Flutter-Ready-blue?logo=flutter)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

Aplicación multiplataforma desarrollada en Flutter para facilitar el cálculo de subredes, máscaras, rangos de hosts y subneteo VLSM. Ideal para proveedores de servicios gestionados (MSP), estudiantes y profesionales de redes.

---

## 🖥️ Demo

<img width="1919" height="861" alt="image" src="https://github.com/user-attachments/assets/d274fa7c-ee96-45b4-a3ba-fe729c3ac586" />

---
## Tabla de contenidos
- [Características](#-características)
- [Demo](#-demo)
- [Instalación](#-instalación)
- [Uso rápido](#-uso-rápido)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Tecnologías y dependencias](#-tecnologías-y-dependencias)
- [Contribuir](#-contribuir)
- [Pruebas](#-pruebas)
- [Licencia](#-licencia)
- [Autor](#-autor)

---

## 🚀 Características

- **Cálculo de subredes:** Ingresa una IP y una máscara para obtener la red, broadcast y hosts disponibles.
- **Subneteo VLSM:** Genera subredes variables a partir de una red base y los hosts requeridos por subred.
- **Copia de resultados:** Exporta los resultados al portapapeles con un solo clic.
- **Interfaz moderna:** UI responsiva y amigable, optimizada para escritorio, web y móvil.

---

## 📦 Instalación

1. Clona el repositorio:
   ```sh
   git clone https://github.com/tuusuario/calculadora-subredes.git
   cd calculadora-subredes
   ```
2. Instala las dependencias:
   ```sh
   flutter pub get
   ```
3. Ejecuta la aplicación:
   ```sh
   flutter run
   ```

Selecciona el dispositivo (web, Windows, etc.) donde quieras probar la app.

---

## 📝 Uso rápido

### Cálculo de subredes
1. Ingresa la dirección IP y la máscara de subred.
2. Haz clic en "Calcular" para ver los resultados.
3. Usa "Limpiar" para reiniciar los campos.

### Subneteo VLSM
1. Ingresa la red base en formato CIDR (ejemplo: `192.168.1.0/24`).
2. Especifica los hosts requeridos por subred, separados por coma (ejemplo: `50,20,10`).
3. Haz clic en "Calcular VLSM" para ver la tabla de subredes generadas.
4. Copia los resultados fácilmente.

---

## 🗂️ Estructura del proyecto

```
calculadora/
├── lib/
│   └── main.dart         # Lógica principal y UI
├── test/                 # Pruebas unitarias y de widgets
├── android/              # Archivos de plataforma
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
└── README.md             # Este archivo
```

---

## 📚 Tecnologías y dependencias

- [Flutter](https://flutter.dev/) SDK
- [Material Design](https://m3.material.io/)

---

## 👨‍💻 Autor

Desarrollado por **Andersson Ambuludi**.

[LinkedIn](https://www.linkedin.com/in/andersson-ambuludi/) |


