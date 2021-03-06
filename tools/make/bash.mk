#################################################################
## BASH													       ##
#################################################################

BASHVERSION := $(shell cat $(SOURCES) | jq -r '.bash.version' )
BASHARCHIVE := $(shell cat $(SOURCES) | jq -r '.bash.archive' )
BASHURI     := $(shell cat $(SOURCES) | jq -r '.bash.uri' )

#################################################################
##                                                             ##
#################################################################

$(SOURCEDIR)/$(BASHARCHIVE): $(SOURCEDIR)
	$(call box,"Downloading bash source code")
	test -f $@ || $(DOWNLOADCMD) $@ $(BASHURI) || rm -f $@

#################################################################
##                                                             ##
#################################################################

$(BUILDDIR)/bash: $(SOURCEDIR)/$(BASHARCHIVE) $(BUILDDIR)/readline
	$(call box,"Building bash")
	@mkdir -p $(BUILDDIR) && rm -rf $@-$(BASHVERSION)
	@tar -xzf $(SOURCEDIR)/$(BASHARCHIVE) -C $(BUILDDIR)
	@cd $@-$(BASHVERSION)					\
	&& $(BUILDENV)							\
		./configure							\
			--host=$(TARGET)				\
			--prefix=$(PREFIXDIR)			\
			--without-bash-malloc 			\
			--enable-largefile 				\
			--enable-alias 					\
			--enable-history				\
	&& make -j$(PROCS)					 	\
	&& make -j$(PROCS) install 				\
	&& rm $(PREFIXDIR)/lib/bash/Makefile.inc
	@rm -rf $@-$(BASHVERSION)
	@touch $@


#################################################################
##                                                             ##
#################################################################
