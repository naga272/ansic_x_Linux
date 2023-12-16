cimport cython
from datetime      import datetime, date
from time          import *
import subprocess
import platform
import sys
import os
import re


# macro per orario
__TIMESTAMP__ = datetime.now()                  # data e ora di esecuzione del file sorgente
__DATE__      = date.today()                    # data di esecuzione del file sorgente "yyyy-mm-dd"
__TIME__      = __DATE__.strftime("%H:%M:%S")   # orario formato ora:minuti:secondi

# info file python
__STDC__      = sys.version                     # versione python
__FILE__      = os.path.abspath(__file__)       # nome del file sorgente che si sta eseguendo 


void = None
argc = strlen(sys.argv)
envp = [(key, value) for key, value in os.environ.items()]


cpdef unsigned short int NULL            = 0
cpdef unsigned short int EXIT_SUCCESS    = 0
cpdef unsigned short int EXIT_FAILURE    = 1

operative_system = platform.system()
cpdef unsigned short int __unix__        = 1 if operative_system == "Linux" else 0
cpdef unsigned short int __MacOs__       = 1 if operative_system == "Darwin" else 0
cpdef unsigned short int __WIN__         = 1 if operative_system == "Windows" else 0


if __unix__ == 0 and __WIN__ == 0 and __MacOs__ == 0:
    print("sistema operativo non compatibile con questa libreria")
    sys.exit(EXIT_FAILURE)


@cython.cdivision(True)     # rende la gestione delle divisioni C-Like es. 3 / 2 = 1
@cython.boundscheck(False)  # disabilito il controllo sugli array di python
@cython.wraparound(False)   # disabilito il controllo degli array con indici negativi
cpdef unsigned int strlen(stri):
    """calcolo della lunghezza di una stringa"""
    cdef unsigned int i = 0
    for element in stri: # ciclo for più veloce del while
        i += 1
    return i


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
cpdef unsigned short int system(vettore):
    """
        *
        *  Funzione che permette di scrivere all'interno di una shell del s.o. una lista di elementi.
        *  Ogni elemento della lista vettore indica il comando da eseguire + i suoi parametri, es:  
        *  vettore = ['echo', 'Hello World!'] -> per qualche ragione echo non funziona, tutti gli altri comandi si
        *
    """
    try:
        process = subprocess.Popen(vettore, stdout = subprocess.PIPE, stderr = subprocess.PIPE)

        output, error = process.communicate()
        if process.returncode == EXIT_SUCCESS:
            print(output.decode("utf-8"))
            return EXIT_SUCCESS
        else:
            perror(error.decode("utf-8"))
            return EXIT_FAILURE

    except Exception as e:
        perror(f"{e}")
        return EXIT_FAILURE



@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def perror(communication:str):
    print("error: ", communication)


"""     OPERAZIONI SU FILE      """
cpdef unsigned short int f_exist(percorso):
    try:
        if os.path.exists(percorso):
            return 1
        else:
            return 0
    except Exception as e:
        perror(f"{e}")
        return 0



@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def fopen(FILE, descriptor): # apertura file
    return open(FILE, descriptor)


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def fprintf(FILE, argv): # scrittura file
    FILE.write(argv)


@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def fclose(FILE): # chiusura file
    FILE.close()



"""     STDOUT      """
@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def printf(argv):
    if type(argv) == list:
        perror("Fatal error: Impossibile stampare un array o lista")
        _exit(EXIT_FAILURE)
    system(["echo", argv])


"""    STDIN       """
# da finire


"""    USCITA FORZATA DAL PROGRAMMA   """
@cython.cdivision(True)
@cython.boundscheck(False)
@cython.wraparound(False)
def _exit(x):
    if __unix__ or __MacOs__:
        system(["echo ", f"uscita dal programma con valore: {x}"])
        system(["echo ", "processo ucciso"])
        system(["pkill ", "python"])
    elif __WIN__:
        system(["echo ", f"uscita dal programma con valore: {x}"])
        system(["echo ", "processo ucciso"])
        system(["taskkill ", "/F", "/IM", "python.exe"]) 


def getenv(environ):
    if type(environ) == str:
        try:
            environ = os.environ[environ]
            return environ

        except Exception as e:
            perror(f"{e}")
    return EXIT_FAILURE


# La funzione log_file non fa parte dell'ansic
cpdef unsigned short int log_file(percorso, file_py):
    try:
        if f_exist(percorso) == 0:
            f_out = open(percorso, "a")
            f_out.write(f"user;pc;versione_python;Nome_file;timestamp;localtime;\n")
        else:
            f_out = open(percorso, "a")

        f_out.write(f"{getenv('USERNAME')};{platform.node()};{__STDC__};{file_py};{str(time())};{__TIMESTAMP__};\n") # append
        
        f_out.close()
        return EXIT_SUCCESS

    except Exception as e:
        perror(f"{e}")

    f_out.close()
    return EXIT_FAILURE

