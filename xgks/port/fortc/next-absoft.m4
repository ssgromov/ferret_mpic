divert(-1)
define(`M4__SYSTEM', NEXT)
# transformation from fortran name to name of C module
define(`NAMEF',`$1')
# transformation from string name to corresponding argument name
define(`STRINGF',`$1')
# extra arguments, if any, for string length
define(`STRINGX',`, $1_len')
# extra arguments, if any, for real length
define(`REALX',`, $1_len')
# extra arguments, if any, for integer length
define(`INTEGERX',`, $1_len')
# extra arguments, if any, for function length
define(`FUNCTIONX',`, $1_len')
# extra arguments, if any, for doubleprecision length
define(`DOUBLEX',`, $1_len')
# declaration to be used for argument name descriptor
define(`STRINGD',`
    char      *$1;
    int       $1`'_len;')	# extra string-length argument
# declarations and initializations of canonical local variables
define(`STRINGL',`')
# FORTRAN declaration for a long integer (e.g. integer*4 for Microsoft)
define(`LONG_INT',`integer')
# FORTRAN declaration for a short integer (e.g. integer*2)
define(`SHORT_INT',`integer*2')
# FORTRAN declaration for an integer byte (e.g. integer*1 or byte)
define(`BYTE_INT',`byte')
# FORTRAN declaration for double precision (e.g. real for a Cray)
define(`DOUBLE_PRECISION',`double precision')
# FORTRAN syntax for including a file
define(`M4__RIGHT_QUOTE',')
define(`F_INCLUDE',`      `include' M4__RIGHT_QUOTE`'$1`'M4__RIGHT_QUOTE')
divert(0)dnl
