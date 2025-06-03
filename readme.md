# 🦎 Localizard

> ⚠️ **Warning: This package is still under active development.**  
> It is currently in an early version (`0.x.x`), and breaking changes may occur.  
> Feel free to try it out and give feedback, but avoid using it in production just yet.

**Localizard** is a simple and powerful command-line tool for managing localization JSON files. With Localizard, you can easily initialize, add, edit, and delete localization keys from your JSON files without manually modifying them. This makes managing translations for your applications much more efficient!

## 🚀 Features

- **Initialize Localizard**: Quickly set up Localizard.
- **Add new translations**: Easily insert new translation keys into JSON files.
- **Edit existing translations**: Modify the value of any existing localization key.
- **Delete translations**: Remove unwanted localization keys safely.

---

## 📚 Installation

### Install globally via npm

```sh
npm install -g localizard
```

### Verify installation

```sh
lzd --help
```

---

## 🎯 Usage

Localizard supports both **interactive mode** and **direct command execution**.

### Running Localizard in interactive mode

```sh
lzd
```

This will open the Localizard menu:

```
====================================
           🦎 LOCALIZARD
====================================

Available commands:
  1) Init         - Set up Localizard
  2) Add          - Add a new translation key to locales JSON
  3) Edit         - Modify a translation value in locales JSON
  4) Delete       - Delete a translation key from locales JSON
  5) Exit

Enter a number and press ENTER:
```

### Running Localizard with command-line arguments

Instead of using the interactive mode, you can execute specific commands directly:

#### Initialize Localizard

```sh
lzd init
```

This command starts by asking whether you want to create new locale files or use existing ones.

To skip this question, use one of the following options:

```sh
lzd init --new
```

This will create new locale files in the specified directory and generate a configuration file.

```sh
lzd init --link
```

This will prompt you to provide the path to your existing locale files. Localizard will scan the directory for `.json` files and generate a configuration file based on the detected locales.

##### Short options:

- `-n` → Equivalent to `--new`
- `-l` → Equivalent to `--link`

#### Adding a Translation

```sh
lzd add
```

You will be prompted to enter the JSON key and translations.

```
Enter the JSON key (e.g., home.content.body): home.content.body
Enter the translation for en (HOME.CONTENT.BODY): Welcome Home!
Enter the translation for hu (HOME.CONTENT.BODY): Üdv itthon!
```

This updates your JSON files as follows:

**en.json:**

```json
{
  "HOME": {
    "CONTENT": {
      "BODY": "Welcome Home!"
    }
  }
}
```

**hu.json:**

```json
{
  "HOME": {
    "CONTENT": {
      "BODY": "Üdv itthon!"
    }
  }
}
```

#### Editing a Translation

```sh
lzd edit
```

You will be prompted to enter the key to modify and the new translations.

```
Enter the JSON key to modify: home.content.body
Enter the new translation for en (HOME.CONTENT.BODY): Welcome!
Enter the new translation for hu (HOME.CONTENT.BODY): Üdv!
```

#### Deleting a Translation

```sh
lzd delete
```

You will be prompted to enter the key to delete.

---

## ℹ️ Help

To see available commands at any time, run:

```sh
lzd --help
```

---

## 🌐 License

This project is licensed under the [MIT License](LICENSE).
