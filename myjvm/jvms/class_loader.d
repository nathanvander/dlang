module myjvm.jvms.class_loader;
import std.stdio;
import std.algorithm.searching;
import myjvm.jvms.classfile;
import myjvm.jvms.classfile_reader;

//these should be shared but I can't get the syntax right
//it doesn't matter for our small project
class ClassLoader {
	static string path;
	//classes hashtable
	static ClassFile[string] classes;

	static void setPath(string p) {
		//path must end in \, if it doesn't
		if (!endsWith(p,"\\")) {
			p = p ~ "\\";
		}
		path = p;
	}

	static ClassFile getClass(string className) {
		//first, see if we already know about it
		if (className in classes) {
			return classes[className];
		} else {
			//if not, load it and save it
			ClassFile cf=loadClassFile(className);
			//what happens if cf is not found? need more checking
			classes[className]=cf;
			return cf;
		}
	}

	//the class name here does not end in a class, and it has slashes instead of dots
	static ClassFile loadClassFile(string className) {
		writeln("DEBUG: getting class " ~ className);
		if (!endsWith(className,".class")) {
			className = className ~ ".class";
		}
		string filename = null;
		if (path != null) {
			filename = path ~ className;
		} else {
			filename = className;
		}
		
		ClassFileReader cfr = new ClassFileReader(filename);
		ClassFile cfile = cfr.readClassFile();
		return cfile;
	}

}
