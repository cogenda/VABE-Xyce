#script to compile va file, generate C code and comiled to .so lib
#and this script should be put in the same path with Xyce binary
#!/bin/bash

xyce_install_path=$1
netlist_name=$2
va_filename=$3
XYCE_DEBUG_VAMS_OPT='' #'-v' to print debugging info from xyce_vams code generation
xyce_bin=$xyce_install_path/bin/Xyce
xyce_vams=$xyce_install_path/bin/xyce_vams
#Path of Verilog-A common headers (e.g.,disciplines.vams etc)
hdl_header_path=$xyce_install_path/vaheader

#obtain the module name from va file
va_modulename=`grep "^module " $va_filename|awk '{print $2}'|sed 's/(.*//g'`
vadir="`basename $netlist_name`"
vadir="${vadir%%.*}.vadir"
va_lib="lib${va_modulename}.so"
#Note: should be the first one message print out here, Xyce will get the first line for the so_lib path
echo $vadir/$va_lib

#if the va so file not exists or va file newer than so file then rebuild it
if [ ! -f $vadir/$va_lib ]  || [ -f $vadir/$va_lib -a $vadir/${va_lib} -ot ${va_filename} ]; then 
  echo 'VA code generate...'
  $xyce_vams $XYCE_DEBUG_VAMS_OPT $va_filename
  echo 'VA lib build...'
  mkdir -p $vadir
  cd $vadir
  ln -sf ../${va_modulename}.C  
  ln -sf ../${va_modulename}.h 

  g++ -g -O0 -I $xyce_install_path/include/ \
       -fPIC -c ${va_modulename}.C -o ${va_modulename}.o
  g++ -g -O0 -m64 -Wl,-O1 -shared -o $va_lib -L $xyce_install_path/lib/ -lxyce  \
       -Wl,-rpath=$xyce_install_path/lib ${va_modulename}.o
fi

