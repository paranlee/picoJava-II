/****************************************************************
 ***
 ***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
 ***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
 ***    The contents of this file are subject to the current
 ***    version of the Sun Community Source License, picoJava-II
 ***    Core ("the License").  You may not use this file except
 ***    in compliance with the License.  You may obtain a copy
 ***    of the License by searching for "Sun Community Source
 ***    License" on the World Wide Web at http://www.sun.com.
 ***    See the License for the rights, obligations, and
 ***    limitations governing use of the contents of this file.
 ***
 ***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 ***
 *****************************************************************/




static char *sccsid = "@(#)elf.c 1.4 Last modified 10/06/98 11:39:12 SMI";

#include  <fcntl.h>
#include  <stdio.h>
#include  <stdlib.h>
#include  <string.h>
#include  <exechdr.h>

#ifndef hpux
#include  <libelf.h>
#endif

#include "dsv.h"
#include "decaf.h"
#include "tcl.h"
#include "sim.h"
#include "cm.h"
#include "global_regs.h"


#ifdef hpux
int
loadElfCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    fprintf (stderr, "loadElf command not available in this build for HP-UX!\n");
    return TCL_ERROR;
}
#else
#define PROGRAM_ENTRY 0x0000fff4

static void failure(void);

union {
	struct exec X;
	Elf32_Ehdr Elfhdr;
} ex;

#define	x ex.X
#define	elfhdr ex.Elfhdr

typedef int	(*func_t)();

#define	FAIL	(-1)
#define	ALIGN(x, a)	\
	((a) == 0 ? (int)(x) : (((int)(x) + (a) - 1) & ~((a) - 1)))

#define roundup(x, y)   ((((x)+((y)-1))/(y))*(y))

int use_align = 0;
int npagesize = 0;
u_int icache_flush = 0;
char *cpulist = NULL;

/*Elf32_Boot *elfbootvec;*/		/* ELF bootstrap vector */
/*char	   *module_path;*/	/* path for kernel modules */


int bzero(char *buf, int size)
{
   int i;
   
    for ( i=0; i<size; i++)
	*buf ++=0;
    return 0;
}
int 
readelf(int fd, int print, Elf32_Ehdr *elfhdrp) {
	Elf32_Phdr *phdr;	/* program header */
	Elf32_Nhdr *nhdr;	/* note header */
	int nphdrs, phdrsize;
	caddr_t allphdrs;
	caddr_t	namep, descp;
	u_int loadaddr, size, base;

	/* pj-sim memory */

	u_int maxVaddr, maxSize;
	char * simMemory = NULL;
       
	int off, i, j;
	static char dlname[255];		/* name of interpeter */
	u_int dynamic;				/* dynamic tags array */
	Elf32_Phdr *thdr;			/* "text" program header */
	Elf32_Phdr *dhdr;			/* "data" program header */
	func_t entrypt;	

/* entry point of standalone */

	/* Initialize pointers so we won't free bogus ones on elferror */
	allphdrs = NULL;
	nhdr = NULL;

	if (elfhdrp->e_phnum == 0 || elfhdrp->e_phoff == 0)
		return (-1);

	entrypt = (func_t)elfhdrp->e_entry;
	if (print)
		printf("Entry point: 0x%x\n", entrypt);

	/*
	 * Allocate and read in all the program headers.
	 */
	nphdrs = elfhdrp->e_phnum;
	phdrsize = nphdrs * elfhdrp->e_phentsize;
	if (print)
		printf("Program Header Size: 0x%x\n", phdrsize);
	allphdrs = (caddr_t)malloc(phdrsize);
	if (allphdrs == NULL)
		return(-1);
	if (print)
		printf("lseek: args = %x %x %x\n", fd, elfhdrp->e_phoff, 0);
	if (lseek(fd, elfhdrp->e_phoff, 0) == -1){
		printf("lseek Error");
		return(-1);
        }
	if (read(fd, allphdrs, phdrsize) != phdrsize){
		printf("read error");
		return(-1);
	}

	/* Original Source looking for PT_NOTE, We don't need that here.
	   We will focus on PT_LOAD */
	/*
	 * Next look for PT_LOAD headers to read in.
	 */

	/* now we have allocated all memory required to load file */
	/* simMemory = cmMalloc(base+size);*/

	if (print)
		printf("Size: ");
	for (i = 0; i < nphdrs; i++) {
		phdr = (Elf32_Phdr *)(allphdrs + elfhdrp->e_phentsize * i);
		if (print) {
			printf("Doing header %d\n", i);
			printf("phdr\n");
			printf("\tp_offset = %x, p_vaddr = %x\n",
				phdr->p_offset, phdr->p_vaddr);
			printf("\tp_memsz = %x, p_filesz = %x\n",
				phdr->p_memsz, phdr->p_filesz);
		}
		if (phdr->p_type == PT_LOAD) {
			if (print)
				printf("seeking to 0x%x\n", phdr->p_offset);
			if (lseek(fd, phdr->p_offset, 0) == -1){
				printf("lseek error");
				return(-1);
			}

			if (phdr->p_flags & PF_X) {
				if (print)
					printf("%d+", phdr->p_filesz);
				/*
				 * If we found a new pagesize above, use it
				 * to adjust the memory allocation.
				 */
				loadaddr = phdr->p_vaddr;
				if (use_align && npagesize != 0) {
					off = loadaddr & (npagesize - 1);
					size = roundup(phdr->p_memsz + off,
						npagesize);
					base = loadaddr - off;
				} else {
					npagesize = 0;
					size = phdr->p_memsz;
					base = loadaddr;
				}
				/*
				 *  Check if it's text or data.
				 */
				if (phdr->p_flags & PF_W)
					dhdr = phdr;
				else
					thdr = phdr;


			} else if (phdr->p_vaddr == 0) {
				/*
				 * It's a PT_LOAD segment that is
				 * not executable and has a vaddr
				 * of zero.  We allocate boot memory
				 * for this segment, since we don't want
				 * it mapped in permanently as part of
				 * the kernel image.
				 */
				if ((loadaddr = (u_int)
				    malloc(phdr->p_memsz)) == NULL){
					printf("Malloc error");
					return(-1);
				}
				/*
				 * Save this to pass on
				 * to the interpreter.
				 */
				phdr->p_vaddr = loadaddr;
			}
			else {
			  /* for other load data */
			  loadaddr = phdr->p_vaddr;
			}

			if (print) {
				printf("reading 0x%x bytes into 0x%x 0x%x \n",
				phdr->p_filesz, loadaddr, getAbsAddr(loadaddr) );
			}
			if (read(fd, getAbsAddr(loadaddr), phdr->p_filesz) !=
			    phdr->p_filesz){
				printf("read error!!");
				return(-1);
			}

			/* zero out BSS */
			if (phdr->p_memsz > phdr->p_filesz) {
				loadaddr += phdr->p_filesz;
				if (print) {
					printf("bss from 0x%x (0x%x) size 0x%x\n",
					    loadaddr,getAbsAddr(loadaddr),
					    phdr->p_memsz - phdr->p_filesz);
				}

				bzero((caddr_t)getAbsAddr(loadaddr),
				    phdr->p_memsz - phdr->p_filesz);
				if (print)
					printf("%d Bytes\n",
					    phdr->p_memsz - phdr->p_filesz);
			}

			/* force instructions to be visible to icache */
			/* code removed */

		}
	}
	/* set the entry point of simulator to beginning of
	   elf file. Thus we skip any reset code loaded at 0 
	   prior to this 
	   */
	/* TSC : add casting for type matching */
	pc = (unsigned char *)entrypt;

	/* this was the other way we were going to talk to 
	   reset code, to just to entry point
	   */
	/*cmPoke(PROGRAM_ENTRY,entrypt);*/
}

/*main(int argc, char ** argv) */
int
loadElfCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
      Elf32_Shdr *   shdr;
      Elf32_Ehdr *   ehdr;
      Elf *          elf;
      Elf_Scn * scn;
      Elf_Data *     data;
      int       fd;
      unsigned int   cnt;
      int print;
      int j;


      if (cmInit(NULL) == DSV_FAIL) {
	printf("Fatal Error : Can not initialize cm.\n");	return(DSV_FAIL);
      }      

	   /* Open the input file */
      if ((fd = open(argv[1], O_RDONLY)) == -1)
	     return(TCL_ERROR);

	   /* Obtain the ELF descriptor */
      (void) elf_version(EV_CURRENT);
      if ((elf = elf_begin(fd, ELF_C_READ, NULL)) == NULL) {
	      (void) fprintf(stderr, "%s0, elf_errmsg(elf_errno())");
	      return(TCL_ERROR);
      }

	   /* Obtain the .shstrtab data buffer */
      if (((ehdr = elf32_getehdr(elf)) == NULL) ||
	  ((scn = elf_getscn(elf, ehdr->e_shstrndx)) == NULL) ||
	  ((data = elf_getdata(scn, NULL)) == NULL)) {
	(void) fprintf(stderr, "%s0, elf_errmsg(elf_errno())");
	return(TCL_ERROR);
      }
	/* Here is to verify what we read of this elf header */
        elfhdr = *ehdr; print =1;
	
	if (print) {
			printf("calling readelf, elfheader is:\n");
			printf("e_ident\t0x%x, 0x%x, 0x%x, 0x%x\n",
			    *(int *)&elfhdr.e_ident[0],
			    *(int *)&elfhdr.e_ident[4],
			    *(int *)&elfhdr.e_ident[8],
			    *(int *)&elfhdr.e_ident[12]);
			printf("e_filetype\t0x%x\n", elfhdr.e_type);
			printf("e_machine\t0x%x\n", elfhdr.e_machine);
			printf("e_version\t0x%x\n", elfhdr.e_version);
			printf("e_entry\t0x%x\n", elfhdr.e_entry);
			printf("e_phoff\t0x%x\n", elfhdr.e_phoff);
			printf("e_shoff\t0x%x\n", elfhdr.e_shoff);
			printf("e_flags\t0x%x\n", elfhdr.e_flags);
			printf("e_ehsize\t0x%x\n", elfhdr.e_ehsize);
			printf("e_phentsize\t0x%x\n", elfhdr.e_phentsize);
			printf("e_phnum\t0x%x\n", elfhdr.e_phnum);
			printf("e_shnentsize\t0x%x\n", elfhdr.e_shentsize);
			printf("e_shnum\t0x%x\n", elfhdr.e_shnum);
			printf("e_shstrndx\t0x%x\n", elfhdr.e_shstrndx);
		}

	   /* Traverse input filename, printing each section */
      for (cnt = 1, scn = NULL; scn = elf_nextscn(elf, scn); cnt++) {
	   if ((shdr = elf32_getshdr(scn)) == NULL) {
	     (void) fprintf(stderr, "%s0, elf_errmsg(elf_errno())");
	     return(TCL_ERROR);
	   }

	   /* (void) printf("[%d]%s0\n", cnt, (char *)data->d_buf + shdr->sh_name);*/

      }
      /* Read the elf file */
      readelf(fd, print, &elfhdr);



      return(TCL_OK);
 }         /* end main */

 static void
 failure()
 {
      (void) fprintf(stderr, "%s0, elf_errmsg(elf_errno())");
      exit(1);
 }


#endif /* hpux */
