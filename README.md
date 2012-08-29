dpatcher is a general purpose binary file patcher written in D.

dpatcher computes MD5 of target file and looks for an offset file in the current directory. 

dpatcher reads the offset file line by line. For each line it seeks to the specified location and then writes the specified value.

the purpose of dpatcher is for educational purpose only