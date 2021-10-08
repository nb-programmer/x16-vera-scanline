
PY			:= python

#Generate the sine table
binres: $(OBJDIR)/sintable.bin
$(OBJDIR)/sintable.bin:
	$(PY) $(TOOLDIR)/makesintable.py -c 64 -a 8 $@
