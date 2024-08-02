# NyaShell v2.0 Recoded (Still in developement)

Nsh is a minimalist shell written in C. It supports basic command-line functionality, custom modules and unicode. There is no command history or auto-completion yet, but it will be soon...

### Dependencies

- gcc
- bash
- nasm

### Installation Steps

1. **Clone the repository:**

   ```bash
   git clone https://github.com/SysFugy/nyash.git
   cd nyash
   ```
   
2. **Run the installation script:**

   ```bash
   bash build.sh
   ```

### Configuration

The configuration file is located in **config.asm**, where you can configure only the prompt and the path to the binary files for now.

### Custom modules

Custom modules are located in the **"lib"** directory. To create your own, you can follow the example of the ready-made **"hello.c"** module

To compile ours together with our module, you need to add the **"-modules"** option, and then specify the directory to your .c file:

   ```bash
   bash build.sh -modules lib/hello.c
   ```

You can call module using **"call"** command in the shell:

   ```bash
   call hello SysFugy
   ```
