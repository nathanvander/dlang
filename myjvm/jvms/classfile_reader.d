module myjvm.jvms.classfile_reader;
import std.file;
import std.system;
import std.bitmanip;
import std.stdio;
import myjvm.jvms.classfile;

class ClassFileReader {
	ubyte[] buffer;
	
	this(string fname) {
		writeln("DEBUG: reading " ~ fname);
		buffer = cast(ubyte[])std.file.read(fname);
	}
	
	public ClassFile readClassFile() {
		ClassFile cf;  //declare ClassFile object, no need for new
		cf.magic = read_uint();
		writeln("DEBUG: magic =", cf.magic);
		//read version
		cf.minor_version=read_ushort();
		cf.major_version=read_ushort();
		write("DEBUG: major_version =", cf.major_version);
		writeln(" DEBUG: minor_version =", cf.minor_version);
		cf.constant_pool_count=read_ushort();
		writeln("DEBUG: constant_pool_count =", cf.constant_pool_count);
		cf.constant_pool=read_constant_pool(cf.constant_pool_count);
		improveConstantPool(cf.constant_pool);
		cf.access_flags=read_ushort();
		writeln("DEBUG: access flags =", cf.access_flags);
		cf.this_class=read_ushort();
		writeln("DEBUG: this class =", cf.this_class);
		cf.super_class=read_ushort();
		writeln("DEBUG: super class =", cf.super_class);
		//-----------------------------------------
    	//interfaces
    	cf.interfaces_count=read_ushort();
    	writeln("DEBUG: interfaces count =", cf.interfaces_count);
    	cf.interfaces=new ushort[cf.interfaces_count];
    	for (int i=0;i<cf.interfaces_count;i++) {
    		//The constant_pool entry at each value of interfaces[i], where 0 = i < interfaces_count, 
    		//must be a CONSTANT_Class_info structure
    		cf.interfaces[i]=read_ushort();
    	}
    	//----------------------------------------
    	//fields
    	cf.fields_count=read_ushort();
    	writeln("DEBUG: fields count =", cf.fields_count);
    	cf.fields=new field_info[cf.fields_count];
    	for (int j=0;j<cf.fields_count;j++) {
    		field_info fx;
    		fx.access_flags=read_ushort();
    		fx.name_index=read_ushort();
    		writeln("DEBUG: name_index =", fx.name_index);
    		fx.descriptor_index=read_ushort();
    		writeln("DEBUG: descriptor_index =", fx.descriptor_index);
    		fx.attributes_count=read_ushort();
    		writeln("DEBUG: field attributes_count =", fx.attributes_count);
    		if (fx.attributes_count>0) {
    			fx.attributes=read_attributes(fx.attributes_count,cf.constant_pool);
    		}
    		cf.fields[j]=fx;
    	}   
    	//--------------------------------------
    	//methods, the same as fields, except for code attribute
    	cf.methods_count=read_ushort();
    	writeln("DEBUG: methods count =", cf.methods_count);
    	cf.methods=new method_info[cf.methods_count];
    	for (int k=0;k<cf.methods_count;k++) {
    		method_info mx;
    		mx.access_flags=read_ushort();
    		mx.name_index=read_ushort();
    		writeln("DEBUG: name_index =", mx.name_index);
    		mx.descriptor_index=read_ushort();
    		writeln("DEBUG: descriptor_index =", mx.descriptor_index);
    		mx.attributes_count=read_ushort();
    		writeln("DEBUG: method attributes_count =", mx.attributes_count);
    		if (mx.attributes_count>0) {
    			mx.attributes=read_attributes(mx.attributes_count,cf.constant_pool);
    		}
    		cf.methods[k]=mx;
    	}       	
    	//------------------------------------
    	//attributes
    	cf.attributes_count=read_ushort();
    	if (cf.attributes_count>0) {
    		cf.attributes=read_attributes(cf.attributes_count,cf.constant_pool);
    	}
		return cf;
	}
	
	ubyte read_ubyte() {
		//return std.bitmanip.read!(ubyte, std.system.Endian.littleEndian)(buffer);
		return buffer.read!ubyte();
	}
	
	public ushort read_ushort() {
		return buffer.read!ushort();
	}
	
	public uint read_uint() {
		return buffer.read!uint();
	}
	
	public int read_int() {
		//return std.bitmanip.read!(int, std.system.Endian.littleEndian)(buffer);
		return buffer.read!int();
	}
	
	public ubyte[] read_bytes(int size) {
		ubyte[] b=new ubyte[size];
		//there has to be a better way of doing this but I haven't learned it yet
		for (int i=0;i<size;i++) {
			b[i]=read_ubyte();
		}
		return b;
	}
	
	//the constant pool has a size of constant_pool_count-1
	//indexed from 1..to constant_pool_count-1
	//we can get the same effect by making it 0..constant_pool_count
	//and leaving constant_pool[0] empty
	cp_info[] read_constant_pool(ushort constant_pool_count) {
		writeln("DEBUG: reading constant pool");
		assert(constant_pool_count>0);
		cp_info[] cp=new cp_info[constant_pool_count];
		for (int i=1;i<constant_pool_count;i++) {
			//read the tag
			ubyte mytag=read_ubyte();
			//writeln("DEBUG: loop ",i,"tag=",mytag);
			switch(mytag) {
				case CONSTANT_Utf8:
					CONSTANT_Utf8_info u=new CONSTANT_Utf8_info();
					assert(u !is null);
					u.tag=mytag;
					u.load(buffer);
					cp[i]=u;
					writeln("DEBUG: #",i," utf8: " ~ u.utf8);
					continue;
				case CONSTANT_Integer:
					CONSTANT_Integer_info ci=new CONSTANT_Integer_info();
					assert(ci !is null);
					ci.tag=mytag;
					ci.load(buffer);
					cp[i]=ci;
					writeln("DEBUG: #",i," constant integer: ", ci.ival);
					continue;
				case CONSTANT_Float:
					CONSTANT_Float_info cf=new CONSTANT_Float_info();
					assert(cf !is null);
					cf.tag=mytag;
					cf.load(buffer);
					cp[i]=cf;
					writeln("DEBUG: #",i," constant float: ", cf.fval);
					continue;				
				case CONSTANT_Long:
					CONSTANT_Long_info colo=new CONSTANT_Long_info();
					assert(colo !is null);
					colo.tag=mytag;
					colo.load(buffer);
					cp[i]=colo;
					writeln("DEBUG: #",i," constant long: ", colo.lval);					
					//All 8-byte constants take up two entries in the constant_pool table of the class file. 
					i=i+1;
					continue;					
				case CONSTANT_Double:
					CONSTANT_Double_info d=new CONSTANT_Double_info();
					assert(d !is null);
					d.tag=mytag;
					d.load(buffer);
					cp[i]=d;
					writeln("DEBUG: #",i," constant double: ", d.dval);					
					i=i+1;
					continue;	
				case CONSTANT_Class:
					CONSTANT_Class_info k=new CONSTANT_Class_info();
					assert(k !is null);
					k.tag=mytag;
					k.load(buffer);
					cp[i]=k;
					//we don't know the actual name yet, just the index to the utf8
					writeln("DEBUG: #",i," class: ", k.name_index);							
					continue;	
				case CONSTANT_String: 
					CONSTANT_String_info cs=new CONSTANT_String_info();
					assert(cs !is null);
					cs.tag=mytag;
					cs.load(buffer);
					cp[i]=cs;
					writeln("DEBUG: #",i," class: ", cs.string_index);	
					continue;					
				case CONSTANT_Fieldref:
				case CONSTANT_Methodref:
				case CONSTANT_InterfaceMethodref:
					//these 3 are identical except for the tag
					CONSTANT_ref_info r=new CONSTANT_ref_info();
					assert(r !is null);
					r.tag=mytag;
					r.load(buffer);
					cp[i]=r;
					writeln("DEBUG: #",i," [",r.tag,"] class_index: ",r.class_index," natx: ",r.name_and_type_index);
					continue;
				case CONSTANT_NameAndType:
					CONSTANT_NameAndType_info cnat=new CONSTANT_NameAndType_info();
					assert(cnat !is null);
					cnat.tag=mytag;
					cnat.load(buffer);
					cp[i]=cnat;	
					writeln("DEBUG: #",i," [NameAndType] name_index: ", cnat.name_index, " descriptor_index: ", cnat.descriptor_index);						
					continue;
				case CONSTANT_MethodHandle:
				case CONSTANT_MethodType:
				case CONSTANT_InvokeDynamic:
					//skip
					writeln("DEBUG: #",i," [",mytag,"] unhandled");	
					continue;
					
				default: 
					writeln("DEBUG: #",i," [",mytag,"] unhandled");	
					continue;		//not necessary since we are at the end
			}
		}
		
		return cp;
	}
	
	//do a second pass on the constant pool and resolve utf8 references to:
	//string, class, and cnat
	//do a 3rd pass on refs
	void improveConstantPool(cp_info[] pool) {
		for (int i=1;i<pool.length;i++) {
			ubyte it=pool[i].type();
			switch (it) {
				case CONSTANT_Class:
					CONSTANT_Class_info k=cast(CONSTANT_Class_info)pool[i];
					CONSTANT_Utf8_info u=cast(CONSTANT_Utf8_info)pool[k.name_index];
					k.cname=u.utf8;
					writeln("DEBUG: #",i," [Class] " ~ k.cname);	
					break;
				case CONSTANT_String:
					CONSTANT_String_info cs=cast(CONSTANT_String_info)pool[i];
					CONSTANT_Utf8_info u=cast(CONSTANT_Utf8_info)pool[cs.string_index];
					cs.strval=u.utf8;
					writeln("DEBUG: #",i," [String] " ~ cs.strval);
					break;				
				case CONSTANT_NameAndType: 
					CONSTANT_NameAndType_info cnat=cast(CONSTANT_NameAndType_info)pool[i];
					CONSTANT_Utf8_info u1=cast(CONSTANT_Utf8_info)pool[cnat.name_index];
					CONSTANT_Utf8_info u2=cast(CONSTANT_Utf8_info)pool[cnat.descriptor_index];
					cnat.name=u1.utf8;
					cnat.descriptor=u2.utf8;
					break;						
				default: break;
			}
		}
		
		//now do a third pass on refs
		for (int i=1;i<pool.length;i++) {
			ubyte it=pool[i].type();
			switch (it) {
				case CONSTANT_Fieldref:
				case CONSTANT_Methodref:
				case CONSTANT_InterfaceMethodref:
					CONSTANT_ref_info cry=cast(CONSTANT_ref_info)pool[i];
					CONSTANT_Class_info k=cast(CONSTANT_Class_info)pool[cry.class_index];
					CONSTANT_NameAndType_info cnat=cast(CONSTANT_NameAndType_info)pool[cry.name_and_type_index];
					cry.cname=k.cname;
					cry.name=cnat.name;
					cry.descriptor=cnat.descriptor;
					writeln("DEBUG: #",i," [",it,"] class=" ~ cry.cname ~ ",name=" ~ cry.name ~ ",descriptor=" ~ cry.descriptor);
					break;						
				default: break;	
			}
		}
	}
	
	//For all attributes, the attribute_name_index must be a valid unsigned 16-bit index into the 
	//constant pool of the class. The constant_pool entry at attribute_name_index must be a 
	//CONSTANT_Utf8_info structure (4.4.7) representing the name of the attribute.
	public attribute_info[] read_attributes(ushort attributes_count,cp_info[] pool) {
		//if attributes_count=0 then this should not be called
		assert(attributes_count>0);
		attribute_info[] attributes=new attribute_info[attributes_count];
		for (int i=0;i<attributes_count;i++) {
			ushort idx=read_ushort();
			uint len=read_uint();
			//get the name of the attribute
			CONSTANT_Utf8_info u=cast(CONSTANT_Utf8_info)pool[idx];
			string aname=u.utf8;
			writeln("DEBUG: attribute name=" ~ aname);
			
			if (aname == "ConstantValue") {
				ConstantValue_attribute cva=new ConstantValue_attribute(idx,aname,len);
				cva.load(buffer);
				attributes[i]=cva;
			} else if (aname == "Code") {
				Code_attribute coda=new Code_attribute(idx,aname,len);
				coda.load_code(buffer,pool);
				attributes[i]=coda;			
			} else if (aname == "Exceptions") {
				Exceptions_attribute x=new Exceptions_attribute(idx,aname,len);
				x.load(buffer);
				attributes[i]=x;				
			} else if (aname == "InnerClasses") {
				InnerClasses_attribute nc=new InnerClasses_attribute(idx,aname,len);
				nc.load(buffer);
				attributes[i]=nc;				
			} else if (aname == "EnclosingMethod") {
				EnclosingMethod_attribute em=new EnclosingMethod_attribute(idx,aname,len);
				em.load(buffer);
				attributes[i]=em;				
			} else if (aname == "Synthetic") {
				Synthetic_attribute sy=new Synthetic_attribute(idx,aname,len);
				sy.load(buffer);
				attributes[i]=sy;					
			} else if (aname == "Signature") {
				Signature_attribute sig=new Signature_attribute(idx,aname,len);
				sig.load(buffer);
				attributes[i]=sig;				
			} else if (aname == "SourceFile") {
				SourceFile_attribute sf=new SourceFile_attribute(idx,aname,len);
				sf.load(buffer);
				attributes[i]=sf;					
			} else if (aname == "Deprecated") {
				Deprecated_attribute d=new Deprecated_attribute(idx,aname,len);
				d.load(buffer);
				attributes[i]=d;				
			} else {
				writeln("unknown attribute: " ~ aname);
			}
		}
		return attributes;
	}
}


//======================================
//command-line
public void main(string[] args) {
	string fname=args[1];
	ClassFileReader cfr=new ClassFileReader(fname);
	ClassFile cf=cfr.readClassFile();
}
