/* rp2ps is a program that reads a data file           */
/* generated by the ML-Kit containing region profiling */
/* information.                                        */
/* Output is a postScript file.                        */

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "Flags.h"
#include "Rp2Ps.h"
#include "ProfileData.h"
#include "Sample.h"

/*-------------------------------*
 * Command line options.         *
 *-------------------------------*/
int regionNo=0;               /* Region used when object profiling. */
int regionNo2=0;              /* Region used when printing a region. */
int match=0;
int printRegion = 0;          /* if one then print region. */
int printProfile = 0;         /* if one then print profile. */
int interact = 0;             /* if one then print profile. */
int makeObjP = 0;             /* if one then make object profile. */
int makeRP = 0;               /* if one then make region profile. */
int makeSP = 0;               /* if one then make stack profile. */
int printSomeStat = 0;        /* if one then print some statistics. */
int findPrgPoint = 0;         /* if one then find program point prgPoint. */
int prgPoint = 0;               

/*------------------------------------------------*
 * We have all global declarations in this module *
 *------------------------------------------------*/
char* programname; /* Name of program to put on graph. */
char* jobstring;   /* Name of job to put on graph.     */
char* datestring;  /* Date to put on graph.            */

char  logName[100]="profile.rp";   /* Name of log file to use. */
FILE* logFile;
char  rpName[100]="region";        /* Name of regionProfile file. */
char  stackName[100]="stack";      /* Name of regionProfile file. */
char prgName[100];
FILE* stackFile;
char  objName[100]="object";       /* Name of regionProfile file. */
FILE* objFile;
char  rpiName[100]="instance";     /* Name of regionProfile file. */
FILE* rpiFile;
char  dotEnd[100]=".ps";           /* Default end of filenames. */
char  name[100]="";                /* Name of regionProfile file. */
char  tempStr[100]="";             /* temporary string. */

FILE *outfp;       /* Output file. */

int yflag=0;        /* Don't show vertical lines in graph.              */
int eflag;          /* Switch used when doing encapsulated post script. */
double epsfwidth;   /* Width used when doing encapsulated post script.  */
int gflag;
int SampleMax = 64;  /* max. number of samples.         */
int noOfSamples;     /* Number of samples (same as ticks) in input file. */
int sortOpt = TAKE_BY_SAMPLE_NO;
int useTickNo = 0;   /* Use tick number on x-axis instead of seconds. */
int fixedYRange = -1; /* if fixedYRange = -1 then do not use fixed Y range. */

int noOfBands = MAX_NO_OF_BANDS; /* Number of bands shown on the graph. */
int showMax = 0;                 /* Don't show a maximum on the graph. */
double maxValue = 80000.0;       /* The maximal value shown if showMax = 1. */
char maxValueStr[100];           /* String used when printing maxValue. */
char  *timeStr;                  /* Ptr. to string with current time. */
char *yLab;
int    cflag = 0;                /* Flag is one when printing comments. */
double commenttime;
int    mflag = 0;                /* Flag is one when printing marks. */
/*-------------------------------------*
 * Global Sample declarations.         *
 *-------------------------------------*/
float* sampletable;     /* sample intervals.               */
int    nsamples;        /* number of samples.              */
float* marktable;       /* table holding mark times.       */
int    nmarks;          /* number of marks.                */
int    nmarkmax;        /* max. number of marks so far.    */
float* commenttable;    /* table holding comment times.    */
char **commentstring;   /* table holding comment strings.  */
int    ncomments;       /* number of comments.             */
int    ncommentmax;     /* max. number of comments so far. */
int nidents;            /* number of identifiers.          */
ENTRYPTR* identtable;   /* table holding identifier ptr's. */

/*----------------------------------------*
 * Utility functions.                     *
 *----------------------------------------*/
static int min(int i1, int i2) {
  if (i1<i2)
    return i1;
  else
    return i2;
}

void GetTime(void) {
  time_t t;

  t = time(NULL);
  timeStr = ctime(&t);
  timeStr[strlen(timeStr)-1] = '\0'; /* remove new line mark. */
/*  printf("Local time: %s\n", timeStr);*/

  return;
}

/*----------------------------------------------------------------*
 * printUsage:                                                    *
 *   Print help.                                                  *
 *----------------------------------------------------------------*/
static void printUsage(void) {
  printf("Help screen for graph generator %s.\n", prgName);
  printf("The graph generator creates one or more region graphs in postscript from a profile datafile.\n\n");
  printf("usage: %s [-region [filename]] [-stack [filename]] [-object regionNo [filename]]\n", prgName);
  printf("       [-sampleMax n] [-sortByTime | -sortBySize]\n"); 
  printf("       [-vert] [-eps width (in|mm|pt)] \n");
  printf("       [-noOfBands n]\n");
  printf("       [-comment time string] [-mark time]\n");
  printf("       [-pregion regionNo] [-print] [-stat] [-findPrgPoint n]\n");
  printf("       [-source filename] [-name name] [-interact] [-help]\n\n");

  printf("where -region         Profile all regions with respect to size (default output filename is %s%s).\n", rpName, dotEnd);
  printf("      -stack          Profile stack with respect to size (default output filename is %s%s).\n",stackName, dotEnd);
/*  printf("      -instance       Profile all regions with respect to number of instances (default output filename is %s%s).\n", rpiName,dotEnd);*/
  printf("      -object         Profile all objects in region regionNo.\n");
  printf("                      (default output filename is %s#%s, where # is regionNo.\n\n", objName, dotEnd);
			       
  printf("      -sampleMax n    Use only n samples (default is %d).\n", SampleMax);
  printf("      -sortByTime     Choose sampleMax samples equally distributed over sample time.\n");
  printf("      -sortBySize     Choose the sampleMax largest samples.\n");
  if (sortOpt == TAKE_BY_SIZE) 
    printf("                      Default is sortBySize.\n\n");
  else			       
    printf("                      Default is sortByTime.\n\n");
  printf("      -vert           Put a vertical line in the region graph for each sample used.\n");
  printf("      -eps            Produce encapsulated postscript with specified width in\n");
  printf("                      inches (in), milli meters (mm) or points(pt).\n\n");

  printf("      -noOfBands n    Max. number of bands shown on the region graph. Default (and possible maximum) is %d.\n", MAX_NO_OF_BANDS);
  printf("      -fixedYRange n  Use n (bytes) as fixed range of y-axis, -1 means no fixed range on y-axis.\n");
  printf("      -useTickNo      Use tick numbers on x-axis instead of elapsed time\n\n");
			       
  printf("      -comment t str  Insert comment str (one word only) at time t in the region graph.\n");
  printf("      -mark    t      Insert mark at time t in the region graph.\n\n");
			       
  printf("      -pregion n      Print region n on stdout.\n");
  printf("      -print          Print all profiling data on stdout.\n");
  printf("      -stat           Print some statistics on stdout.\n");
  printf("      -findPrgPoint n Print regions containing program point n.\n\n");
			       
  printf("      -source name    Specify name of profile datafile (default is %s).\n", logName);
  printf("      -name name      Name to print on top of region graph (default is %s).\n\n", name);
  printf("      -interactive    Enter interactive mode.\n");
  printf("      -help           This help screen.\n");

  exit(0);
}

/*----------------------------------------------------------------*
 * interactive:                                                   *
 *   Go into interactive mode.                                    *
 *----------------------------------------------------------------*/
static void interactive(void) {
  char button = ' ';
  int regionNo;

  while (button != 'e') {
    printf("\n\nInteractive mode.\n\n\n");
    printf("      (1)   Profile all regions with respect to size.\n");
    printf("      (2)   Profile all objects in a region.\n");
    printf("      (3)   Print region regionNo on stdout.\n");
    printf("      (4)   Print all profiling data on stdout.\n");
    printf("      (5)   Print some statistics on stdout.\n");
    printf("      (6)   Profile stack with respect to size.\n");
    printf("      (e)   Exit.\n");
    printf("\n\nType switch: ");
    scanf("%1s", &button);
    printf("\n\nYou typed %c.\n",button);
    switch (button) {
    case '1':
      printf("\n Type name of output file: ");
      scanf("%s", rpName);
      printf("\n Type name to put on top page: ");
      scanf("%s", name);
      printf("\n Now profiling all regions to file: %s using name %s.\n", rpName, name);
      MakeRegionProfile();
      printf("\n Profiling of all regions now finished. \n");
      break;
    case '2':
      printf("\n Type region to profile: ");
      scanf("%i", &regionNo);
      if (regionNo != 0) {
	printf("\n Type name of output file: ");
	scanf("%s", objName);
	printf("\n Type name to put on top page: ");
	scanf("%s", name);
	printf("\n Now profiling region %d to file: %s using name %s.\n", regionNo, objName, name);
	MakeObjectProfile(regionNo);
	printf("\n Profiling of region %d to file: %s finished.\n", regionNo, objName);
      } else
	printf("\n No valid region number typed: %d\n", regionNo);
      break;
    case '3':
      printf("Type region to print: ");
      scanf("%i", &regionNo);
      PrintRegion(regionNo);
      break;
    case '4':
      PrintProfile();
      break;
    case '5':
      PrintSomeStat();
      break;
    case '6':
      printf("\n Type name of output file: ");
      scanf("%s", stackName);
      printf("\n Type name to put on top page: ");
      scanf("%s", name);
      printf("\n Now profiling the stack to file: %s using name %s.\n", stackName, name);
      MakeStackProfile();
      printf("\n Profiling of the stack now finished. \n");
      break;
    case 'e':
      break;
    }
  }
}

/*----------------------------------------------------------------*
 * checkArgs:                                                     *
 *   Check command line parameters                                *
 *----------------------------------------------------------------*/
static void checkArgs(int argc, char *argv[]) {

  strcpy(prgName, (char *)argv[0]); 
  strcpy(name, prgName); 

  while (--argc > 0) {
    ++argv;    /* next parameter. */
    match = 0; /* no match so far. */

    if (strcmp((char *)argv[0],"-region")==0) {
      if ((argc-1)>0 && (*(argv+1))[0] != '-') {
	--argc;
	++argv;
	strcpy(rpName, (char *)argv[0]);     
      } else
	strcat(rpName, dotEnd);
      printf("Region profiling to output file %s.\n", rpName);
      match = 1;
      makeRP = 1;
    } 

    if (strcmp((char *)argv[0],"-stack")==0) {
      if ((argc-1)>0 && (*(argv+1))[0] != '-') {
	--argc;
	++argv;
	strcpy(stackName, (char *)argv[0]);     
      } else
	strcat(stackName, dotEnd);
      printf("Stack profiling to output file %s.\n", stackName);
      match = 1;
      makeSP = 1;
    } 

    if (strcmp((char *)argv[0],"-object")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a region number. */
	if ((regionNo = atoi((char *)argv[0])) == 0) {
	  printf("Something wrong with the region number after the -object switch.\n");
	  printUsage();
	}
      } else {
	printf("No region number after the -object switch.\n");
	printUsage();
      }
    
      if ((argc-1)>0 && (*(argv+1))[0] != '-') {
	--argc;
	++argv;
	strcpy(objName, (char *)argv[0]);     
      } else {
	sprintf(tempStr, "%d", regionNo);
	strcat(objName, tempStr);
	strcat(objName, dotEnd);
      }
      printf("Object profiling on region %d to output file %s.\n", regionNo, objName);
      match = 1;
      makeObjP = 1;
    } 

    if (strcmp((char *)argv[0],"-findPrgPoint")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a number. */
	if ((prgPoint = atoi((char *)argv[0])) == 0) {
	  printf("Something wrong with the number after the -findPrgPoint switch.\n");
	  printUsage();
	}
      } else {
	printf("No number after the -findPrgPoint switch.\n");
	printUsage();
      }
      printf("Find program point %d.\n", prgPoint);
      findPrgPoint = 1;
      match = 1;
    } 

    if (strcmp((char *)argv[0],"-noOfBands")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a number. */
	if ((noOfBands = atoi((char *)argv[0])) == 0) {
	  printf("Something wrong with the number after the -noOfBands switch.\n");
	  printUsage();
	}
      } else {
	printf("No number after the -noOfBands switch.\n");
	printUsage();
      }
      noOfBands = min(noOfBands, MAX_NO_OF_BANDS);
      printf("Show %d bands on graph.\n", noOfBands);
      match = 1;
    } 

    if (strcmp((char *)argv[0],"-fixedYRange")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a number. */
	if ((fixedYRange = atoi((char *)argv[0])) == 0) {
	  printf("Something wrong with the number after the -fixedYRange switch.\n");
	  printUsage();
	}
      } else {
	printf("No number after the -fixedYRange switch.\n");
	printUsage();
      }
      if (fixedYRange < 0)
	printf("Do not use fixed range on y-axis.\n");
      else
	printf("Use %d bytes as fixed range on y-axis.\n", fixedYRange);
      match = 1;
    } 
    
    if (strcmp((char *)argv[0], "-print")==0) {
      printf("Print profile\n");
      printProfile = 1;
      match = 1;
    } 
          
    if (strcmp((char *)argv[0], "-interact")==0) {
      printf("Interact\n");
      match = 1;
      interact = 1;
    } 

    if ((strcmp((char *)argv[0], "-h")==0) ||
	(strcmp((char *)argv[0], "-help")==0)) {
      printf("Help\n");
      match = 1;
      printUsage();
    }

    if (strcmp((char *)argv[0],"-pregion")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a region number. */
	if ((regionNo2 = atoi((char *)argv[0])) == 0) {
	  printf("Something wrong with the region number after the -pregion switch.\n");
	  printUsage();
	}
      } else {
	printf("No region number after the -pregion switch.\n");
	printUsage();
      }
      printf("Print region %d.\n", regionNo2);
      match = 1;
      printRegion = 1;
    }

    if (strcmp((char *)argv[0],"-source")==0) {
      if ((argc-1)>0 && (*(argv+1))[0] != '-') {
	--argc;
	++argv;
	strcpy(logName, (char *)argv[0]);     
      } else {
	printf("No filename after the -source switch.\n");
	printUsage();
      }
      printf("Using input file %s.\n", logName);
      match = 1;
    } 

    if (strcmp((char *)argv[0],"-name")==0) {
      if ((argc-1)>0 && (*(argv+1))[0] != '-') {
	--argc;
	++argv;
	strcpy(name, (char *)argv[0]);     
      } else {
	printf("No name after the -name switch.\n");
	printUsage();
      }
      printf("Using name %s.\n", name);
      match = 1;
    } 

    if (strcmp((char *)argv[0], "-stat")==0) {
      printf("Print some statistics\n");
      match = 1;
      printSomeStat = 1;
    }

    if (strcmp((char *)argv[0],"-eps")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a width. */
	if ((epsfwidth = atof((char *)argv[0])) == 0) {
	  printf("Something wrong with width after the -eps switch.\n");
	  printUsage();
	}
	if (--argc > 0 && (*++argv)[0]) { /* in, mm or pt. */
	  if (strcmp((char *)argv[0], "in") == 0)
	    epsfwidth *= 72.0;
	  else if (strcmp((char *)argv[0], "mm") == 0)
	    epsfwidth = (float) (epsfwidth*2.834646);
	  else if (strcmp((char *)argv[0], "pt") == 0)
	    epsfwidth = epsfwidth;
	  else {
	    printf("No/wrong in, mm or pt after -eps width switch\n");
	    printUsage();
	  }
	} else {
	  printf("No in, mm or pt after -eps width switch\n");
	  printUsage();
	}
      } else {
	printf("No width after -eps switch.\n");
	printUsage();
      }
      printf("Using encapsulated postscript with width %0.0f pt.\n", epsfwidth);
      eflag = 1;
      match = 1;
    } 

    if (strcmp((char *)argv[0],"-comment")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a time. */
	if ((commenttime = atof((char *)argv[0])) == 0) {
	  printf("Something wrong with time after the -comment switch.\n");
	  printUsage();
	}
	if (--argc > 0 && (*++argv)[0]) { /* comment string. */
	  addComment(commenttime, (char *)argv[0]);
	} else {
	  printf("No comment string after -comment time switch\n");
	  printUsage();
	}
      } else {
	printf("No time after -comment switch.\n");
	printUsage();
      }
      printf("Inserting comment %s at time %4.2f.\n", (char*)argv[0], commenttime);
      cflag = 1;
      match = 1;
    } 

    if (strcmp((char *)argv[0],"-mark")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a time. */
	if ((commenttime = atof((char *)argv[0])) == 0) {
	  printf("Something wrong with time after the -mark switch.\n");
	  printUsage();
	}
	else {
	  addMark(commenttime);
	}
      } else {
	printf("No time after -mark switch.\n");
	printUsage();
      }
      printf("Inserting mark at time %4.2f.\n", commenttime);
      mflag = 1;
      match = 1;
    } 

    if (strcmp((char *)argv[0], "-vert")==0) {
      printf("Show vertical lines in graph.\n");
      yflag = 1;
      match = 1;
    } 

    if (strcmp((char *)argv[0], "-sortByTime")==0) {
      printf("Chose sampleMax samples equally distributed over sample numbers.\n");
      sortOpt = TAKE_BY_SAMPLE_NO;
      match = 1;
    } 

    if (strcmp((char *)argv[0], "-sortBySize")==0) {
      printf("Chose the sampleMax largest samples.\n");
      sortOpt = TAKE_BY_SIZE;
      match = 1;
    } 

    if (strcmp((char *)argv[0], "-useTickNo")==0) {
      printf("Use tick numbers on x-axis instead of elapsed time.\n");
      useTickNo = 1;
      match = 1;
    } 

    if (strcmp((char *)argv[0],"-sampleMax")==0) {
      if (--argc > 0 && (*++argv)[0]) { /* Is there a number. */
	if ((SampleMax = atoi((char *)argv[0])) == 0) {
	  printf("Something wrong with the number after the -sampleMax switch.\n");
	  printUsage();
	}
      } else {
	printf("No number after the -sampleMax switch.\n");
	printUsage();
      }
      printf("Using %d samples.\n", SampleMax);
      match = 1;
    } 

    if (match == 0) {
      printf("Something wrong with the switches, maybe an unknown switch...\n");
      printUsage();
    }
  }

  return;
}

main(int argc, char *argv[]) {

  checkArgs(argc, argv);

  GetTime(); 

  inputProfile();

  if (makeRP)
    MakeRegionProfile();
  if (makeSP)
    MakeStackProfile();
  if (makeObjP)
    MakeObjectProfile(regionNo);
  if (printProfile)
    PrintProfile();
  if (printRegion) 
    PrintRegion(regionNo2);
  if (printSomeStat)
    PrintSomeStat();
  if (findPrgPoint)
    FindProgramPoint(prgPoint);
  if (interact)
    interactive();

  return;
}

