# Intro:

SMS Stands for Symbolic Math System.

Currently, SMS can serve as calculator for basic conversion and trigonometric needs. The long term goal of SMS is to provide a simple general purpose programming language that focuses on mathematics and speed.

In addition to providing a command line, SMS can interpret files.
Run `sms -h` for command line options.

The program currently parses, evaluates, and stores mathematical expressions, strings, arrays and contexts. Contexts are user defined objects with key-value pairs. Functions can also be called with lexical scoping for variables and functions.
SMS has the following built-in functions so far (in double precision):

`+, -, *, /, ^, ln, exp, abs, sin, cos, tan, sinh, cosh, tanh, sec, csc, cot, sqrt, if, ==, >, <` 

# HOW TO DOWNLOAD & RUN / Install
- At the [ Releases page ](https://github.com/reginaldford/sms/releases)  , under 'Assets', you can find binary executable files for Linux, OpenBSD, FreeBSD, and Windows. You may rename the file to 'sms' and copy to anywhere you need. On most Linux/Unix systems, copying to somwhere like /usr/bin directory is a fine way to install the program. The program is small and portable, so you can have copies where necessary.

In SMS, whitespace characters (outside of strings) are ignored. All commands end with a semicolon (`;`) .

Check out `sms_src/example.sms` for example functions and ideas.
You can also run `sms -i examples.sms` to have a calculator loaded with some useful functions and constants.

In addition to the mathematical ideas covered in the example file, SMS has ambitions to be a general purpose programming language. Hence, SMS has premature general purpose programming features that will be embellished further in the near future:

Anonymous functions with javascript-like syntax:

`wave = (x) => sin(x) + 0.5 * cos(x * 2);`

Call the function with familiar syntax:

`wave(4);`

User objects (contexts):

`car = { weight = 2.2; speed = 5; license_plate = "smthg_fnny"; } ; `

Contexts can be nested:

`nested = { example = { x = [ 1, "two" ]; }; k = 5.123; } ;`

Variables can be removed from the current context:

`rm c;`

Exit the program with:

`exit; `

SMS Versions will have 3 significant figures for development periods.                (ex: v 0.135) 
SMS Versions will have 2 significant figures for somewhat stable alpha releases.     (ex: v 0.13)
SMS Versions will have 1 significant figure for somewhat more stable alpha releases. (ex: v 0.1)


# FEATURES:
- [x] Mathematical evaluation. Commands like a=4*sin(3.14/8) will evaluate to a double precision decimal number.
- [x] Support for scripting and pipes by using flags for input and output preferences. Try -h for help.
- [x] User contexts, which allow for the user to create a new context with values of all types including more contexts.
- [x] Fast string manipulation techniques, that avoid unsafe character iteration algorithms.
- [x] Turing completeness. Store variables, run inequality tests, loops, if-statements. Note that, though the control flow is there, many library functions are missing.
- [x] Recursive function calls. 
- [x] Local variables store an array index to their location in the stack frame. This is much faster than binary search.
- [x] The maximum capacity for parsing and storing strings, arrays, and contexts is remarkably high. Generally, if an array, string, or context is too large to parse, it's because 1) The memory available at the time of execution is too low. 2) You are parsing more than 4.29 billion elements/characaters or 3) You are reaching the max heap size of 1 terrabyte of memory for SMS.
- [x] Custom memory heap size can be set from 100 kilabytes to 1 terrabyte.

#PLANS:
- [ ] Standard libraries: file, string, array, math, matrix, net, etc.
- [ ] Support for booting from a serialized memory heap.
- [ ] 'Last moment' garbage collection.
- [ ] Tail call optimization.
- [ ] Package system.
- [ ] Precise syntax error reporting.
- [ ] Try/Catch error syntax.
- [ ] Variable heap size, with min, max, and max_emptiness specs.
- [ ] A diff command for taking derivatives.
- [ ] A integral command for taking integrals.
- [ ] Arbitrary precision support.
- [ ] General documentation.
- [ ] A community!
- [ ] Thread forking support.
- [ ] Simple Webserver and networking tools.
- [ ] Some Unicode support.

# HOW TO COMPILE

Required Packages:

- Flex

- Bison

- GCC or CLANG compiler

- GNU Make ( or compatible build program )

The makefile uses clang by default.
Edit the first lines of the makefile to use your preferred compiler and make program if necessary.

Once you have the necessary packages installed (GCC/Clang, Flex, and Bison),
Change directory to the top level of the project (where LICENSE.txt is located) and run:

`make`

Upon success, you will have a portable executable called 'sms' in the bin directory.

On Linux/Unix systems, You may be able to build and install in one step:

`sudo make install`

This just copies the executable to /usr/bin/sms after compilation.
