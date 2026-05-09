# Project Folder Dumper
A simple script that dumps the content of a project folder into a single file using markdown format. Includes exclude options


# Use Cases

* Folder structure
* File paths
* File contents
* Optional exclusions for folders/files

Perfect for:

* Sharing projects with AI tools
* Creating code snapshots
* Sending compact project context to LLMs



# Notes

* Binary files may produce unreadable output.
* Some locked/system files may fail to read.
* Large projects can generate very large output files.
* Output file is always:

  ```txt
  project_dump.txt
  ```

# Example

```bash
read_folder_win.bat C:\Projects\MyApp node_modules .git
```

Output:

```txt
project_dump.txt
```

Containing:

* Full project structure
* Readable source files



# Usage

## Basic

```bash
read_folder_win.bat my_project
```

This creates:

```txt
project_dump.txt
```

---

## With Exclusions

```bash
read_folder_win.bat my_project node_modules .git dist
```

Excluded folders/files will not appear in:

* Structure listing
* File content dump



# Output Format

Example:

````txt
# FOLDER STRUCTURE

src
src/main.js
package.json

# FILE CONTENTS

```src/main.js
console.log("Hello World")
````

```package.json
{
  "name": "demo"
}
```

---

# License

MIT License

Feel free to modify and improve.
