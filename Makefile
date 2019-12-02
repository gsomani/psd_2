CC = ghdl
ARCHNAME = cpu
TBNAME = tb_cpu

WORKDIR = build

PKGSRC = src/types.vhd src/mem_init.vhd src/mem_init-body.vhd src/utilities.vhd src/utilities-body.vhd
SRC+= src/alu.vhd src/alu_control_unit.vhd src/alu_mux.vhd src/control_unit.vhd src/imm_decoder.vhd src/decode.vhd src/execute.vhd src/fetch.vhd src/memory.vhd src/register_file.vhd src/writeback.vhd src/core.vhd src/cpu.vhd
SRC+= tb_cpu.vhd

.PHONY: all
all: clean analyze elaborate
	@echo "completed"

.PHONY: analyze
analyze:
	@echo "analyzing designs"
	@mkdir $(WORKDIR)
	$(CC) -a --workdir=$(WORKDIR) $(PKGSRC)
	$(CC) -a --workdir=$(WORKDIR) $(SRC)
    $(shell ./extract_bin.sh test.s)

.PHONY: elaborate

elaborate:
	@echo "elaborating design"
	$(CC) --elab-run --workdir=$(WORKDIR) -o $(WORKDIR)/$(TBNAME).bin $(TBNAME) --vcd=core.vcd --stop-time=10us

.PHONY: clean
clean:
	@echo "cleaning design"
	rm -rf $(WORKDIR)
