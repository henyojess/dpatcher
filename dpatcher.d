#!bin/rdmd -unittest
import std.stdio;
import std.file;
import std.md5;
import std.conv;
import std.string;

int main(string args[]){    
    if(args.length != 2){
        printUsage();
        return 1;
    }
    string target = args[1];
    if(!exists(target)){
        writeln("Target file not found:" ~ target);
        return 2;
    }    
    string md5 = computeMD5(target);    
    writeln("Computing md5 digest for " ~ target ~ ":" ~ md5);
    string offsetFile = md5 ~ ".offsets";
    if(!exists(offsetFile)){
        writefln("Offset file(%s) not found or target(%s) may have " ~
            "already been patched.",offsetFile,target);
        return 3;   
    }
    return patch(target,offsetFile);
}

void printUsage(){    
write(q"EOS

Usage:patcher <targetFile>
returns 0 on success
returns 1 if insufficient arguments
returns 2 if target file is not found
returns 3 if offset file is not found or target has already been patched

EOS");
}

string computeMD5(string filename)
{
   ubyte[16] digest;

   MD5_CTX context;
   context.start();
   foreach (buffer; File(filename).byChunk(4096 * 1024))
     context.update(buffer);
   context.finish(digest);
   string md5 = digestToString(digest);   
   return md5;
}

unittest{    
    assert("7A6543F613F93E7BB0D90F3AAD275FBD" == computeMD5("README.md"));
}

int patch(string target,string offsetFile){
    File targetFile = File(target,"r+b");
    foreach(line; File(offsetFile).byLine()){
        //do not parse comment lines
        if('#' != stripLeft(line)[0]){
            auto offset = parse!uint(line);
            munch(line," \t");
            auto value = parse!ubyte(line);
            writefln("Writing value:%s to offset:%s ",value, offset);
            targetFile.seek(offset,SEEK_SET);
            targetFile.rawWrite([value]);
        }else{
            //output comment lines to console
            writeln(line);
        }
    }
    targetFile.close();
    writeln("Patch complete.");
    return 0;
}