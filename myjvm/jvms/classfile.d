module myjvm.jvms.classfile;
import std.bitmanip;
import std.system;
import std.string;
import std.stdio;

alias ubyte           u1;
alias ushort          u2;
alias uint            u4;

struct ClassFile {
	//the magic number is 3405691582 (0xCAFEBABE)
    u4             magic;
    u2             minor_version;
    u2             major_version;
    u2             constant_pool_count;
    //cp_info[constant_pool_count-1] constant_pool;
    //The constant_pool table is indexed from 1 to constant_pool_count-1
    cp_info[]      constant_pool;
    u2             access_flags;
    u2             this_class;
    u2             super_class;
    u2             interfaces_count;
    //u2[interfaces_count] interfaces;
    u2[]           interfaces;
    u2             fields_count;
    //field_info[fields_count] fields;
    field_info[] fields;
    u2             methods_count;
    //method_info[methods_count] methods;
    method_info[] methods;
    u2             attributes_count;
    //attribute_info[attributes_count] attributes;
    attribute_info[] attributes;
}

//access flags are one of these
enum ACC_PUBLIC =              0x0001;
enum ACC_PRIVATE =             0x0002;
enum ACC_PROTECTED =           0x0004;
enum ACC_STATIC =              0x0008;
enum ACC_FINAL =               0x0010;
enum ACC_SYNCHRONIZED =        0x0020;
enum ACC_SUPER =               0x0020;
enum ACC_VOLATILE =            0x0040;
enum ACC_TRANSIENT =           0x0080;
enum ACC_NATIVE =              0x0100;
enum ACC_INTERFACE =           0x0200;
enum ACC_ABSTRACT =            0x0400;
enum ACC_MIRANDA =             0x0800;
enum ACC_SYNTHETIC =           0x1000;
enum ACC_ANNOTATION =          0x2000;
enum ACC_ENUM =                0x4000;

//-----------------------------------
//constant pool
//struct cp_info {
//    u1 tag;
//    u1[] info;
//}

//I think an interface is better than a base class here
interface cp_info {
    u1 type();
    //after the tag has been read in, load the rest of the cp_info item
    //load self from buffer
    void load(ref ubyte[] buffer);
}

//tag is one of these
enum CONSTANT_Utf8 =                   1;
enum CONSTANT_Integer =                3;
enum CONSTANT_Float =                  4;
enum CONSTANT_Long =                   5;
enum CONSTANT_Double =                 6;
enum CONSTANT_Class =                  7;
enum CONSTANT_String =                 8;
enum CONSTANT_Fieldref =               9;
enum CONSTANT_Methodref =              10;
enum CONSTANT_InterfaceMethodref =     11;
enum CONSTANT_NameAndType =            12;
enum CONSTANT_MethodHandle =           15;
enum CONSTANT_MethodType =             16;
enum CONSTANT_InvokeDynamic =          18;

class CONSTANT_Class_info : cp_info {
	//The tag item has the value CONSTANT_Class (7).
	u1 tag;
    u2 name_index;
    string cname;
    u1 type() {return tag;}
    //after the tag has been read in, load the rest of the cp_info item
    void load(ref ubyte[] buffer) {
    	name_index=buffer.read!ushort();
    }
}

class CONSTANT_ref_info : cp_info {
	//The tag item of a CONSTANT_Fieldref_info structure has the value CONSTANT_Fieldref (9).
	//The tag item of a CONSTANT_Methodref_info structure has the value CONSTANT_Methodref (10).
	//The tag item of a CONSTANT_InterfaceMethodref_info structure has the value
	//	CONSTANT_InterfaceMethodref (11).
	//other than that, they have the same structure
	u1 tag;
    u2 class_index;
    u2 name_and_type_index;
    string cname;
    string name;
    string descriptor;
    
    u1 type() {return tag;}
    void load(ref ubyte[] buffer) {
    	class_index=buffer.read!ushort();
    	name_and_type_index=buffer.read!ushort();
    }    
}

class CONSTANT_String_info : cp_info {
	//The tag item of the CONSTANT_String_info structure has the value CONSTANT_String (8).
	u1 tag;
    u2 string_index;
    string strval;	
    u1 type() {return tag;}
    void load(ref ubyte[] buffer) {
    	string_index=buffer.read!ushort();
    }
}

class CONSTANT_Integer_info : cp_info {
	//The tag item of the CONSTANT_Integer_info structure has the value CONSTANT_Integer (3).
	u1 tag;
    u4 bytes;  //this has the raw unsigned bytes
    int ival; //this is signed
    u1 type() {return tag;}
    void load(ref ubyte[] buffer) {
    	bytes=buffer.read!uint();
    	//we can either cast it or convert it, I dont know which is better
    	ival=cast(int)bytes;
    }
}

class CONSTANT_Float_info : cp_info {
	//The tag item of the CONSTANT_Float_info structure has the value CONSTANT_Float (4).
	u1 tag;
    //The bytes item of the CONSTANT_Float_info structure represents the value of the float constant 
    //in IEEE 754 floating-point single format (2.3.2). The bytes of the single format representation
    //are stored in big-endian (high byte first) order.
    u4 bytes;
    float fval;
    
    u1 type() {return tag;}    
    void load(ref ubyte[] buffer) {
    	//there must be a better way to do this but as long as it works...
    	fval = buffer.peek!(float, Endian.bigEndian);
    	bytes=buffer.read!uint();
    }    
}

class CONSTANT_Long_info : cp_info {
	//The tag item of the CONSTANT_Long_info structure has the value CONSTANT_Long (5).
	u1 tag;
    u4 high_bytes;
    u4 low_bytes;
    long lval;
    u1 type() {return tag;}    
    void load(ref ubyte[] buffer) {
    	//there must be a better way to do this but as long as it works...
    	lval = buffer.peek!(long, Endian.bigEndian);
    	high_bytes=buffer.read!uint();
    	low_bytes=buffer.read!uint();
    }        
}

class CONSTANT_Double_info : cp_info {
	//The tag item of the CONSTANT_Double_info structure has the value CONSTANT_Double (6).
	u1 tag;
    u4 high_bytes;
    u4 low_bytes;
    double dval;
    u1 type() {return tag;} 
    void load(ref ubyte[] buffer) {
    	//there must be a better way to do this but as long as it works...
    	dval = buffer.peek!(double, Endian.bigEndian);
    	high_bytes=buffer.read!uint();
    	low_bytes=buffer.read!uint();
    }       
}

class CONSTANT_NameAndType_info : cp_info {
	//The tag item of the CONSTANT_NameAndType_info structure has the value CONSTANT_NameAndType (12).
	u1 tag;
    u2 name_index;
    u2 descriptor_index;
    string name;
    string descriptor;	
    u1 type() {return tag;} 
    void load(ref ubyte[] buffer) {
    	name_index=buffer.read!ushort();
    	descriptor_index=buffer.read!ushort();
    }
}

class CONSTANT_Utf8_info : cp_info {
	//The tag item of the CONSTANT_Utf8_info structure has the value CONSTANT_Utf8 (1).
    u1 tag;
    u2 length;
    //u1 bytes[length];
    u1[] bytes;
    string utf8;
    u1 type() {return tag;} 
    void load(ref ubyte[] buffer) {  
    	length=buffer.read!ushort();
    	assert(length>0);
    	bytes=new ubyte[length];
    	for (int i=0;i<length;i++) {
    		bytes[i]=buffer.read!ubyte();
    	}
    	utf8=bytes.assumeUTF;
    	assert(utf8!=null);
    }
}

//I don't expect to use this but it is defined in the spec
class CONSTANT_MethodHandle_info : cp_info {
	//The tag item of the CONSTANT_MethodHandle_info structure has the value CONSTANT_MethodHandle (15).
    u1 tag;
    u1 reference_kind;
    u2 reference_index;
    u1 type() {return tag;}   
    void load(ref ubyte[] buffer) {
    	reference_kind=buffer.read!ubyte();
    	reference_index=buffer.read!ushort();
    }
}

class CONSTANT_MethodType_info : cp_info {
	//The tag item of the CONSTANT_MethodType_info structure has the value CONSTANT_MethodType (16).
    u1 tag;
    u2 descriptor_index;
    u1 type() {return tag;} 
    void load(ref ubyte[] buffer) {
    	descriptor_index=buffer.read!ushort();
    }    
}

class CONSTANT_InvokeDynamic_info : cp_info {
	//The tag item of the CONSTANT_InvokeDynamic_info structure has the value CONSTANT_InvokeDynamic (18).
    u1 tag;
    u2 bootstrap_method_attr_index;
    u2 name_and_type_index;
    u1 type() {return tag;}   
    void load(ref ubyte[] buffer) {
    	bootstrap_method_attr_index=buffer.read!ushort();
    	name_and_type_index=buffer.read!ushort();
    }       
}
//end constant pool
//-----------------------------------------------

struct field_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    //attribute_info[attributes_count] attributes;
    attribute_info[] attributes;
}

struct method_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    //attribute_info[attributes_count] attributes;
    attribute_info[] attributes;
}

//--------------------------------------
//attributes

//each attribute_info has a 6 byte header.  The index is to the attribute_name, which is stored as
//utf8 like "ConstantValue", "Code" etc
//I prefer not to use inheritance but it fits here.  There are 10 classes that extend this
class attribute_info {
	u2 attribute_name_index;
	string aname;
	u4 attribute_length;
	//constructor
	this(u2 name_index,string name,u4 length) {
		attribute_name_index=name_index;
		aname=name;
		attribute_length=length;
	}
	u2 index() {return attribute_name_index;}
	string attr_name() {return aname;}
	//The value of the attribute_length item indicates the length of the subsequent information in bytes. 
	//The length does not include the initial six bytes that contain the attribute_name_index and attribute_length items.
	u4 length() {return attribute_length;}

	//after the index and length have been read in, read in the rest of the attribute_info
	abstract void load(ref ubyte[] buffer);
}

//I'm not going to define all of these, just the most common ones
class ConstantValue_attribute : attribute_info {
    u2 constantvalue_index;
    this(u2 name_index,string name,u4 length) {
    	super(name_index,name,length);
    }
	override void load(ref ubyte[] buffer) {
		constantvalue_index=buffer.read!ushort();
	}
}

class Code_attribute : attribute_info {
    //u2 attribute_name_index;
    //string aname;
    //u4 attribute_length;
    u2 max_stack;
    u2 max_locals;
    u4 code_length;
    u1[] code;
    u2 exception_table_length;
    exception_table_entry[] exception_table;
    //nested attributes
    u2 attributes_count;
    //attribute_info attributes[attributes_count];
    attribute_info[] attributes;
    //-------------------------
    this(u2 name_index,string name,u4 length) {
    	super(name_index,name,length);
    }
    //the default load, which we don't use
    override void load(ref ubyte[] buffer) {}
    
    //here is our method
    void load_code(ref ubyte[] buffer,cp_info[] pool) {
		max_stack=buffer.read!ushort();
		max_locals=buffer.read!ushort();
		code_length=buffer.read!uint();
		assert(code_length>0);
		code=new ubyte[code_length];
		//is there a faster way of reading this in?
		for (int i=0;i<code_length;i++) {
			code[i]=buffer.read!ubyte();
		}
		exception_table_length=buffer.read!ushort();
		if (exception_table_length>0) {
			//I don't know if this is necessary, but it makes it clear that you can skip this if length is 0
			exception_table=new exception_table_entry[exception_table_length];
			for (int i=0;i<exception_table_length;i++) {
				exception_table_entry x;
				x.start_pc=buffer.read!ushort();
				x.end_pc=buffer.read!ushort();
				x.handler_pc=buffer.read!ushort();
				x.catch_type=buffer.read!ushort();
				exception_table[i]=x;
			}
		}
		
		//holy crap there are nested attributes?
		//The only attributes defined by this specification as appearing in the attributes table of a Code 
		//attribute are the LineNumberTable (4.7.12), LocalVariableTable (4.7.13), 
		//LocalVariableTypeTable (4.7.14), and StackMapTable (4.7.4) attributes.
		//I don't care about these right now
		attributes_count=buffer.read!ushort();
		if (attributes_count>0) {
			attributes = new attribute_info[attributes_count];
		
			for (int j=0;j<attributes_count;j++) {
				u2 gnidx=buffer.read!ushort();
				CONSTANT_Utf8_info u=cast(CONSTANT_Utf8_info)pool[gnidx];
				string gname=u.utf8;
				writeln("DEBUG: attribute name=" ~ gname);
				u4 glen=buffer.read!uint();
				if (gname == "LineNumberTable") {
					writeln("DEBUG: creating LineNumberTable attribute");
					LineNumberTable_attribute lnt=new LineNumberTable_attribute(gnidx,gname,glen);
					lnt.load(buffer);
					attributes[j]=lnt;
				} else {	
					writeln("DEBUG: NOT creating " ~ gname ~ " attribute");
					Generic_attribute g=new Generic_attribute(gnidx,"Generic",glen);
					g.load(buffer);
					attributes[j]=g;
				}
			}
		} //end if
	} //end load_code
}

struct exception_table_entry {
	u2 start_pc;
    u2 end_pc;
    u2 handler_pc;
    u2 catch_type;
}

//this is a placeholder for attributes that I don't care about but have to deal with
class Generic_attribute : attribute_info {
    //u2 attribute_name_index;
    //string aname;
    //u4 attribute_length;
    u1[] garbage;
    //-------------------------
    this(u2 name_index,string name,u4 length) {
    	super(name_index,name,length);
    }    
	override void load(ref ubyte[] buffer) {
		if (attribute_length>0) {
			garbage=new ubyte[attribute_length];
			for (int k=0;k<attribute_length;k++) {
				garbage[k]=buffer.read!ubyte();
			}
		}
	}
}

//4.7.4. The StackMapTable Attribute
//we don't use this

class Exceptions_attribute : attribute_info {
    u2 number_of_exceptions;
    //Each value in the exception_index_table array must be a valid index into the constant_pool table.
    //The constant_pool entry referenced by each table item must be a CONSTANT_Class_info structure (4.4.1) 
    //representing a class type that this method is declared to throw.
    u2[] exception_index_table;
    //---------------------
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }  

	override void load(ref ubyte[] buffer) {
		number_of_exceptions=buffer.read!ushort();
		assert(number_of_exceptions>0);
		exception_index_table=new ushort[number_of_exceptions];
		for (int i=0;i<number_of_exceptions;i++) {
			exception_index_table[i]=buffer.read!ushort();
		}
	}
}

//4.7.6. The InnerClasses Attribute
class InnerClasses_attribute : attribute_info {
    u2 number_of_classes;
    inner_class_info[] classes;
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }     
   
	override void load(ref ubyte[] buffer) {
		number_of_classes=buffer.read!ushort();
		assert(number_of_classes>0);
		classes=new inner_class_info[number_of_classes];
		for (int i=0;i<number_of_classes;i++) {
			inner_class_info k;
			k.inner_class_info_index=buffer.read!ushort();
			k.outer_class_info_index=buffer.read!ushort();
			k.inner_name_index=buffer.read!ushort();
			k.inner_class_access_flags=buffer.read!ushort();
			classes[i]=k;
		}
	}
}

struct inner_class_info {
	u2 inner_class_info_index;
    u2 outer_class_info_index;
    u2 inner_name_index;
    u2 inner_class_access_flags;
}

class EnclosingMethod_attribute : attribute_info {
    u2 class_index;
    u2 method_index;
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }        
	override void load(ref ubyte[] buffer) {
		class_index=buffer.read!ushort();
		method_index=buffer.read!ushort();
	}
}

//this has nothing except for the name
//for synthetic, The value of the attribute_length item is zero.
class Synthetic_attribute : attribute_info {
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }      
	override void load(ref ubyte[] buffer) {
		//nothing to do, synthetic is just a marker
	}
}

class Signature_attribute : attribute_info {
    u2 signature_index;
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }      

	override void load(ref ubyte[] buffer) {
		signature_index=buffer.read!ushort();
	}
}

class SourceFile_attribute : attribute_info {
    //u2 attribute_name_index;
    //string aname;
    //u4 attribute_length;
    u2 sourcefile_index;
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }      

	override void load(ref ubyte[] buffer) {
		sourcefile_index=buffer.read!ushort();
	}
}

//4.7.11. The SourceDebugExtension Attribute
//I'm skipping this

//LineNumberTable attribute is part of the code attribute
//It may be used by debuggers to determine which part of the Java Virtual Machine code array 
//corresponds to a given line number in the original source file.

class LineNumberTable_attribute : attribute_info {
    u2 line_number_table_length;
    line_number_info[] line_number_table;
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }      
	override void load(ref ubyte[] buffer) {
		line_number_table_length=buffer.read!ushort();
		writeln("DEBUG: line_number_table_length=",line_number_table_length);
		if (line_number_table_length>0) {
			line_number_table=new line_number_info[line_number_table_length];
			for (int i=0;i<line_number_table_length;i++) {
				line_number_info lni;
				lni.start_pc=buffer.read!ushort();
				lni.line_number=buffer.read!ushort();
				line_number_table[i]=lni;
			}
		}
	}
}

struct line_number_info {
	u2 start_pc;
    u2 line_number;	
}

//class LocalVariableTable_attribute : attribute_info {
//    u2 attribute_name_index;
//    u4 attribute_length;
//    u2 local_variable_table_length;
//    local_variable_info[] local_variable_table;
//    u2 index() {return attribute_name_index;}
//    u4 length() {return attribute_length;}     
//}

//struct local_variable_info {
//	u2 start_pc;
//    u2 length;
//    u2 name_index;
//    u2 descriptor_index;
//    u2 index;
//}

//class LocalVariableTypeTable_attribute : attribute_info {
//    u2 attribute_name_index;
//    u4 attribute_length;
//    u2 local_variable_type_table_length;
//    local_variable_type_info[] local_variable_type_table;
//    u2 index() {return attribute_name_index;}
//    u4 length() {return attribute_length;}  
//}

//struct local_variable_type_info {
//	u2 start_pc;
//    u2 length;
//    u2 name_index;
//    u2 signature_index;
//    u2 index;
//}

//for deprecated, The value of the attribute_length item is zero.
class Deprecated_attribute : attribute_info {
    this(u2 name_index,string name,u4 length) {
		super(name_index,name,length);
    }  
	override void load(ref ubyte[] buffer) {
		//nothing to do, deprecated is just a marker
	}
}

//4.7.16. The RuntimeVisibleAnnotations attribute
//4.7.16.1. The element_value structure
//4.7.17. The RuntimeInvisibleAnnotations attribute
//4.7.18. The RuntimeVisibleParameterAnnotations attribute
//4.7.19. The RuntimeInvisibleParameterAnnotations attribute
//4.7.20. The AnnotationDefault attribute
//4.7.21. The BootstrapMethods attribute
//not used