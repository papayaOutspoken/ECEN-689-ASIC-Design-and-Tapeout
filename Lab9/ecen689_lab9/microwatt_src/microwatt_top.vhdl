-- ECEN 689 course skeleton: YOUR chip's top level.
-- Edit ONLY the TEAM CONFIGURATION BLOCK. Everything else is verified plumbing:
-- it exposes pin-level ports and ties off unused core inputs so no dangling
-- pins survive to layout (they would become LVS failures).
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.common.all;
use work.wishbone_types.all;

entity microwatt_top is
    port (
        clk       : in  std_ulogic;
        rst       : in  std_ulogic;

        -- instruction fetch wishbone
        wb_insn_adr   : out std_ulogic_vector(28 downto 0);
        wb_insn_dat_w : out std_ulogic_vector(63 downto 0);
        wb_insn_sel   : out std_ulogic_vector(7 downto 0);
        wb_insn_cyc   : out std_ulogic;
        wb_insn_stb   : out std_ulogic;
        wb_insn_we    : out std_ulogic;
        wb_insn_dat_r : in  std_ulogic_vector(63 downto 0);
        wb_insn_ack   : in  std_ulogic;
        wb_insn_stall : in  std_ulogic;

        -- data wishbone
        wb_data_adr   : out std_ulogic_vector(28 downto 0);
        wb_data_dat_w : out std_ulogic_vector(63 downto 0);
        wb_data_sel   : out std_ulogic_vector(7 downto 0);
        wb_data_cyc   : out std_ulogic;
        wb_data_stb   : out std_ulogic;
        wb_data_we    : out std_ulogic;
        wb_data_dat_r : in  std_ulogic_vector(63 downto 0);
        wb_data_ack   : in  std_ulogic;
        wb_data_stall : in  std_ulogic;

        ext_irq       : in  std_ulogic;
        run_out       : out std_ulogic
    );
end entity microwatt_top;

architecture rtl of microwatt_top is

    ----------------------------------------------------------------
    -- TEAM CONFIGURATION BLOCK - edit values below, nothing else
    ----------------------------------------------------------------
    constant CFG_HAS_FPU          : boolean := false;
    constant CFG_ICACHE_NUM_LINES : natural := 16;
    constant CFG_DCACHE_NUM_LINES : natural := 16;
    ----------------------------------------------------------------
    -- (advanced knobs - leave at defaults until Lab 9 or later)
    constant CFG_ICACHE_NUM_WAYS     : natural := 1;
    constant CFG_ICACHE_TLB_SIZE     : natural := 16;
    constant CFG_DCACHE_NUM_WAYS     : natural := 1;
    constant CFG_DCACHE_TLB_SET_SIZE : natural := 16;
    constant CFG_DCACHE_TLB_NUM_WAYS : natural := 1;
    ----------------------------------------------------------------

    signal wi_in  : wishbone_slave_out;
    signal wi_out : wishbone_master_out;
    signal wd_in  : wishbone_slave_out;
    signal wd_out : wishbone_master_out;
begin
    wi_in.dat   <= wb_insn_dat_r;
    wi_in.ack   <= wb_insn_ack;
    wi_in.stall <= wb_insn_stall;
    wb_insn_adr   <= wi_out.adr;
    wb_insn_dat_w <= wi_out.dat;
    wb_insn_sel   <= wi_out.sel;
    wb_insn_cyc   <= wi_out.cyc;
    wb_insn_stb   <= wi_out.stb;
    wb_insn_we    <= wi_out.we;

    wd_in.dat   <= wb_data_dat_r;
    wd_in.ack   <= wb_data_ack;
    wd_in.stall <= wb_data_stall;
    wb_data_adr   <= wd_out.adr;
    wb_data_dat_w <= wd_out.dat;
    wb_data_sel   <= wd_out.sel;
    wb_data_cyc   <= wd_out.cyc;
    wb_data_stb   <= wd_out.stb;
    wb_data_we    <= wd_out.we;

    core_0: entity work.core
        generic map (
            SIM                 => false,
            HAS_FPU             => CFG_HAS_FPU,
            HAS_BTC             => false,
            LOG_LENGTH          => 0,
            ICACHE_NUM_LINES    => CFG_ICACHE_NUM_LINES,
            ICACHE_NUM_WAYS     => CFG_ICACHE_NUM_WAYS,
            ICACHE_TLB_SIZE     => CFG_ICACHE_TLB_SIZE,
            DCACHE_NUM_LINES    => CFG_DCACHE_NUM_LINES,
            DCACHE_NUM_WAYS     => CFG_DCACHE_NUM_WAYS,
            DCACHE_TLB_SET_SIZE => CFG_DCACHE_TLB_SET_SIZE,
            DCACHE_TLB_NUM_WAYS => CFG_DCACHE_TLB_NUM_WAYS
            )
        port map (
            clk               => clk,
            rst               => rst,
            alt_reset         => '0',
            tb_ctrl.reset     => '0',
            tb_ctrl.rd_prot   => '0',
            tb_ctrl.freeze    => '0',
            wishbone_insn_in  => wi_in,
            wishbone_insn_out => wi_out,
            wishbone_data_in  => wd_in,
            wishbone_data_out => wd_out,
            wb_snoop_in       => wishbone_master_out_init,
            dmi_addr          => (others => '0'),
            dmi_din           => (others => '0'),
            dmi_dout          => open,
            dmi_req           => '0',
            dmi_wr            => '0',
            dmi_ack           => open,
            ext_irq           => ext_irq,
            msg_in            => '0',
            msg_out           => open,
            run_out           => run_out,
            terminated_out    => open
            );
end architecture rtl;
