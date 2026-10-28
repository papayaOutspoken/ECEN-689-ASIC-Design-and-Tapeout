-- ECEN 689 course testbench: YOUR full CPU (microwatt_top) executing a program.
-- The memory model is identical for every team (1-cycle registered ack).
-- Program (preloaded at address 0): r3=0; loop 100 times {r3+=5}; store r3 to
-- byte address 0x2000; spin. Expected stored value: 500.
-- The TB counts clock cycles from reset release to the store and checks it.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_tb_course is
end entity core_tb_course;

architecture behave of core_tb_course is
    constant CLK_PERIOD : time := 10 ns;
    constant TIMEOUT_CYCLES : natural := 2_000_000;
    constant MAGIC_WORD_ADDR : natural := 16#2000# / 8;   -- doubleword address 0x400
    constant EXPECTED : natural := 500;

    signal clk : std_ulogic := '0';
    signal rst : std_ulogic := '1';

    -- instruction bus
    signal wi_adr   : std_ulogic_vector(28 downto 0);
    signal wi_dat_w : std_ulogic_vector(63 downto 0);
    signal wi_sel   : std_ulogic_vector(7 downto 0);
    signal wi_cyc, wi_stb, wi_we : std_ulogic;
    signal wi_dat_r : std_ulogic_vector(63 downto 0) := (others => '0');
    signal wi_ack   : std_ulogic := '0';
    -- data bus
    signal wd_adr   : std_ulogic_vector(28 downto 0);
    signal wd_dat_w : std_ulogic_vector(63 downto 0);
    signal wd_sel   : std_ulogic_vector(7 downto 0);
    signal wd_cyc, wd_stb, wd_we : std_ulogic;
    signal wd_dat_r : std_ulogic_vector(63 downto 0) := (others => '0');
    signal wd_ack   : std_ulogic := '0';

    signal run_out : std_ulogic;
    signal done    : boolean := false;

    -- program memory: 1024 doublewords (8 KB), program at word 0
    type mem_t is array (0 to 1023) of std_ulogic_vector(63 downto 0);
    -- POWER insns, little-endian doubleword packing: low 32 = lower address
    constant mem_init : mem_t := (
        0 => x"38800064" & x"38600000",  -- addi r4,0,100      | addi r3,0,0
        1 => x"38630005" & x"7C8903A6",  -- addi r3,r3,5(loop) | mtctr r4
        2 => x"3CA00000" & x"4200FFFC",  -- addis r5,0,0       | bdnz loop
        3 => x"90650000" & x"60A52000",  -- stw r3,0(r5)       | ori r5,r5,0x2000
        4 => x"48000000" & x"48000000",  -- b .                | b .
        others => (others => '0'));
    signal mem : mem_t := mem_init;

    signal cycles : natural := 0;
begin
    dut: entity work.microwatt_top
        port map (
            clk => clk, rst => rst,
            wb_insn_adr => wi_adr, wb_insn_dat_w => wi_dat_w, wb_insn_sel => wi_sel,
            wb_insn_cyc => wi_cyc, wb_insn_stb => wi_stb, wb_insn_we => wi_we,
            wb_insn_dat_r => wi_dat_r, wb_insn_ack => wi_ack, wb_insn_stall => '0',
            wb_data_adr => wd_adr, wb_data_dat_w => wd_dat_w, wb_data_sel => wd_sel,
            wb_data_cyc => wd_cyc, wb_data_stb => wd_stb, wb_data_we => wd_we,
            wb_data_dat_r => wd_dat_r, wb_data_ack => wd_ack, wb_data_stall => '0',
            ext_irq => '0', run_out => run_out);

    clk_gen: process
    begin
        while not done loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- instruction memory: pipelined slave, ack follows each accepted stb by 1 cycle
    insn_mem: process(clk)
        variable idx : natural;
    begin
        if rising_edge(clk) then
            wi_ack <= '0';
            if wi_cyc = '1' and wi_stb = '1' then
                idx := to_integer(unsigned(wi_adr(9 downto 0)));
                wi_dat_r <= mem(idx);
                wi_ack <= '1';
            end if;
        end if;
    end process;

    -- data memory + magic-store detector
    data_mem: process(clk)
        variable idx   : natural;
        variable waddr : natural;
        variable val   : natural;
    begin
        if rising_edge(clk) then
            wd_ack <= '0';
            if wd_cyc = '1' and wd_stb = '1' then
                wd_ack <= '1';
                if wd_we = '1' then
                    waddr := to_integer(unsigned(wd_adr));
                    if waddr = MAGIC_WORD_ADDR then
                        -- stw to 0x2000: value is in the low 32-bit lane
                        if wd_sel(3 downto 0) /= "0000" then
                            val := to_integer(unsigned(wd_dat_w(31 downto 0)));
                        else
                            val := to_integer(unsigned(wd_dat_w(63 downto 32)));
                        end if;
                        if val = EXPECTED then
                            report "BENCHMARK PASS checksum=" &
                                   integer'image(val) & " cycles=" &
                                   integer'image(cycles) severity note;
                        else
                            report "BENCHMARK FAIL got=" & integer'image(val) &
                                   " expected=" & integer'image(EXPECTED)
                                   severity failure;
                        end if;
                        done <= true;
                    elsif waddr < 1024 then
                        mem(waddr) <= wd_dat_w;   -- ignore sel for simplicity; program never partial-writes
                    end if;
                else
                    idx := to_integer(unsigned(wd_adr(9 downto 0)));
                    wd_dat_r <= mem(idx);
                end if;
            end if;
        end if;
    end process;

    supervisor: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cycles <= 0;
            else
                cycles <= cycles + 1;
                assert cycles < TIMEOUT_CYCLES
                    report "BENCHMARK TIMEOUT after " & integer'image(cycles) &
                           " cycles - CPU never stored to the magic address"
                    severity failure;
            end if;
        end if;
    end process;

    reset_gen: process
    begin
        rst <= '1';
        wait for 10 * CLK_PERIOD;
        rst <= '0';
        wait;
    end process;
end architecture behave;
