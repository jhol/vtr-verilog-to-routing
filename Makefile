#####################################################################
# Makefile to build CAD tools in Verilog-to-Routing (VTR) Framework #
#####################################################################

SUBDIRS = ODIN_II vpr abc_with_bb_support libarchfpga pcre printhandler ace2 torc yosys xdlrc2vpr bnpr2xdl vtr_flow/arch/xilinx

all: notifications subdirs

subdirs: $(SUBDIRS)

# Dependency only target; recipe is given by $(SUBDIRS) target below:
vtr_flow/arch/xilinx: vpr xdlrc2vpr
	
$(SUBDIRS):
	@ $(MAKE) -C $@ --no-print-directory

torc:
ifeq ($(wildcard torc/*),)
	@echo
	@echo "Checking-out Torc v1.0 [torc-isi.sourceforge.net] in 5 seconds"
	@echo
	sleep 5
	svn co https://torc-isi.svn.sourceforge.net/svnroot/torc-isi/tags/torc-1.0 torc
else
	cd torc && svn cleanup && svn up
endif

yosys:
ifeq ($(wildcard yosys/*),)
	@echo
	@echo "Checking-out Yosys v0.5 [www.clifford.at/yosys] in 5 seconds"
	@echo
	sleep 5
	git clone --branch yosys-0.5 http://github.com/cliffordwolf/yosys
endif
	@ $(MAKE) -C $@ --no-print-directory

export BOOST_INCLUDE_DIR = /usr/include
export BOOST_LIB_DIR = /usr/lib
EXTRA_CCFLAGS = -Wno-error=unused-local-typedefs
xdlrc2vpr bnpr2xdl: torc
	@ $(MAKE) -C $@ --no-print-directory CC="$(CC) $(EXTRA_CCFLAGS)"

notifications: 
# checks if required packages are installed, and notifies the user if not
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep exuberant-ctags -c >>/dev/null; then echo "\n\n\n\n***************************************************************\n* Required package 'ctags' not found.                         *\n* Type 'make packages' to install all packages, or            *\n* 'sudo apt-get install exuberant-ctags' to install manually. *\n***************************************************************\n\n\n\n"; fi; fi
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep bison -c >>/dev/null; then echo "\n\n\n\n*****************************************************\n* Required package 'bison' not found.               *\n* Type 'make packages' to install all packages, or  *\n* 'sudo apt-get install bison' to install manually. *\n*****************************************************\n\n\n\n"; fi; fi
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep flex -c >>/dev/null; then echo "\n\n\n\n*****************************************************\n* Required package 'flex' not found.                *\n* Type 'make packages' to install all packages, or  *\n* 'sudo apt-get install flex' to install manually.  *\n*****************************************************\n\n\n\n"; fi; fi
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep g++ -c >>/dev/null; then echo "\n\n\n\n*****************************************************\n* Required package 'g++' not found.                 * \n* Type 'make packages' to install all packages, or  *\n* 'sudo apt-get install g++' to install manually.   *\n*****************************************************\n\n\n\n"; fi; fi

packages:
# checks if required packages are installed, and installs them if not
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep exuberant-ctags -c >>/dev/null; then sudo apt-get install exuberant-ctags; fi; fi
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep bison -c >>/dev/null; then sudo apt-get install bison; fi; fi
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep flex -c >>/dev/null; then sudo apt-get install flex; fi; fi
	@ if cat /etc/issue | grep Ubuntu -c >>/dev/null; then if ! dpkg -l | grep g++ -c >>/dev/null; then sudo apt-get install g++; fi; fi
	@ cd vpr && make packages

ODIN_II: libarchfpga

vpr: libarchfpga

libarchfpga: printhandler

printhandler: pcre

ace2: abc_with_bb_support
clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir $@; \
	done

clean_vpr:
	@ $(MAKE) -C vpr clean

.PHONY: clean packages subdirs $(SUBDIRS)
