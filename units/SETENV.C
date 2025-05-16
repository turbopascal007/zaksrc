#include <stdio.h>
#include <dos.h>
#include <dir.h>
#include <string.h>
#include <stdlib.h>

int settheenv (char * symbol, char * val);

#define MYINT  0xD3

union  REGS  regs;
struct SREGS sregs;
int    largc;
char   **largv;

void display_help() {
puts("\nSETENV 1.3  by Richard Marks");
puts("     Sets environment variables to a user response (for BAT files)");
puts("     SETENV  <envirn vbl name>  <prompt message>\n");
puts("Example:");
puts("     setenv drv \"PLEASE ENTER DRIVE TO USE : \" ");
puts("the message PLEASE ENTER DRIVE TO USE : is displayed on the console,");
puts("the response is set into variable drv for use by the rest of the BAT file\n");
puts("If there is a keyword instead of a <message>, SETENV will fill certain system");
puts("values into the environment variable:\n");
puts("     SETENV  <envirn vbl name>  %cwd  -  get current working directory");
puts("                                %drive-  get current drive");
puts("                                %dosv -  get dos major version");
puts("                                %num  -  a unique number");
puts("                                %fs file - get size of file");
puts("                                %fn file - just file name (no drive or dir)");
puts("Use %% to represent a single % in BAT files\n");
puts("Multiple sets of arguments can be supplied:");
puts("             SETENV <vbl> <msg> <vbl> <msg> . . .");
}

char get_default_drive () {
	regs.h.ah = 0x19;
	intdos(&regs, &regs);
	return (regs.h.al);
}


long filesize (char *filename) {
	struct ffblk fff;
	if (findfirst (filename, &fff, 0xff) != 0)  return (0);
	return (fff.ff_fsize);
}


char get_special_param(char *val, int *argbase) {
/* plugs the system parmeter specified in the arg into val
   %cwd  = current directory path
   %drive= default drive
   %dosv = dos major version */
	char *func;
	int  i;
	long nn;

	if ( ++(*argbase)>=largc ) return (2);
	func = largv[*argbase];

	if (stricmp(func,"%CWD")==0) {
		getcwd(val, 128);

	} else if (stricmp(func,"%DRIVE")==0) {
		val[0] = get_default_drive() + 'A';
		val[1] = 0;

	} else if (stricmp(func,"%DOSV")==0) {
		val[0] = _osmajor+'0';
		val[1] = 0;

	} else if (stricmp(func,"%NUM")==0) {
		nn = (long) getvect(MYINT);
		setvect (MYINT, (void interrupt (*)()) ++nn);
		ltoa (nn, val, 10);
		val [3] = 0;

	} else if (stricmp(func,"%FS")==0) {
		if ( ++(*argbase)>=largc ) return (2);
		ltoa (filesize(largv[*argbase]), val, 10);

	} else if (stricmp(func,"%FN")==0) {
		if ( ++(*argbase)>=largc ) return (2);
		i = strlen(func =largv[*argbase]);
		while (i!=0) {
			if (func[--i]=='\\'  || func[i]==':') {
				i++;  break;
			}
		}
		strcpy (val, &func[i]);

	} else
		return(2);

	return(0);
}


char get_user_input(char *val, int *argbase) {
/* solicits user for a value (val) by displaying the message (msg).
   then validates the message using criteria in arg.  Criteria are:
   <null>  no criteria test for now */

	if ( ++(*argbase) >= largc ) return (2);
	do {
	   printf("%s", largv[*argbase]);
	   gets(val);
	   } while (0);
	return(0);
	}


char main(int argc, char *argv[]) {
int argbase, ret;
char symbol[16], val[128];

largc = argc;
largv = argv;

if (largc<3) {
HELP_RET:
	display_help(); return(1);
}

for (argbase=1; argbase<argc; argbase++) {

	if ( strlen(largv[argbase])>16 ) goto HELP_RET;
	strcpy(symbol, largv[argbase]);  strupr(symbol);

	if (largv[argbase+1][0]=='%') {
		ret = get_special_param(val, &argbase);
	} else {
		ret = get_user_input(val, &argbase);
	}

	if (ret == 0)
		ret = settheenv(symbol, val);

	if (ret != 0) {
		if (ret == 2)  goto HELP_RET;
		goto ERROR_RET;
	}
}
return(0);

ERROR_RET:
#ifdef DEBUG
puts("SETENV failed");
#endif
return(1);
}
