SUBDIRS := $(wildcard */.)
SUBDIRS := $(filter-out __pycache__/., $(SUBDIRS))

all: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@

.PHONY: all $(SUBDIRS)
